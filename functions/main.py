import firebase_admin
from firebase_admin import credentials, firestore
from google import generativeai as genai
import json
import base64
import os

# Initialize Firebase Admin
if not firebase_admin._apps:
    firebase_admin.initialize_app()

db = firestore.client()

# Configure Gemini
GEMINI_API_KEY = os.environ.get("GEMINI_API_KEY", "")
genai.configure(api_key=GEMINI_API_KEY)
model = genai.GenerativeModel(
    model_name="gemini-1.5-flash",
    generation_config={"response_mime_type": "application/json", "temperature": 0.3},
)

SDG_SCORING_PROMPT = """
Analyse this image submitted for a sustainable social media platform.

1. Does this image relate to any UN Sustainable Development Goals (SDGs)?
2. If yes, which SDG numbers (1-17)?
3. Give an SDG Impact Score from 0-100:
   - 0-20: No SDG relevance
   - 21-50: Mild relevance
   - 51-80: Clear, meaningful SDG action
   - 81-100: Exceptional direct impact
4. Short reason (1-2 sentences, encouraging tone).

Return ONLY valid JSON:
{
  "is_sdg_related": true,
  "sdg_goals": [4, 12],
  "score": 75,
  "reason": "This image shows..."
}
"""

SAFETY_PROMPT = """
Is this image safe and appropriate for a family-friendly social platform?
Return ONLY: {"is_safe": true, "reason": "..."}
"""


def score_sdg_post(event, context):
    """
    Cloud Storage trigger: fires when a new file is uploaded to the 'posts/' prefix.
    Reads Firestore to find the pending post, calls Gemini, updates the score.
    """
    bucket = event["bucket"]
    file_path = event["name"]  # e.g. "posts/abc123.jpg"

    if not file_path.startswith("posts/"):
        return

    # Derive postId from filename
    post_id = file_path.split("/")[1].rsplit(".", 1)[0]

    # Get post document
    post_ref = db.collection("posts").document(post_id)
    post_doc = post_ref.get()
    if not post_doc.exists:
        print(f"Post {post_id} not found in Firestore.")
        return

    post_data = post_doc.to_dict()
    if post_data.get("type") != "sdg":
        print(f"Post {post_id} is not an SDG post. Skipping scoring.")
        return

    # Download image bytes from Cloud Storage
    from google.cloud import storage as gcs
    gcs_client = gcs.Client()
    blob = gcs_client.bucket(bucket).blob(file_path)
    image_bytes = blob.download_as_bytes()

    # Safety check
    safety_result = _call_gemini_with_image(image_bytes, SAFETY_PROMPT)
    if not safety_result.get("is_safe", True):
        post_ref.update({"status": "rejected", "aiReason": "Image failed safety check."})
        print(f"Post {post_id} rejected: not safe.")
        return

    # SDG scoring
    score_result = _call_gemini_with_image(image_bytes, SDG_SCORING_PROMPT)
    is_sdg = score_result.get("is_sdg_related", False)
    score = int(score_result.get("score", 0))
    sdg_goals = score_result.get("sdg_goals", [])
    reason = score_result.get("reason", "")
    is_accepted = is_sdg and score > 20

    # Update post document
    update_data = {
        "sdgScore": score,
        "sdgGoals": sdg_goals,
        "aiReason": reason,
        "status": "scored" if is_accepted else "rejected",
    }
    post_ref.update(update_data)

    # Update user score
    if is_accepted and score > 0:
        user_id = post_data.get("userId")
        if user_id:
            _update_user_score(user_id, score)

    print(f"Post {post_id} scored: {score} pts, SDGs: {sdg_goals}")


def _call_gemini_with_image(image_bytes: bytes, prompt: str) -> dict:
    try:
        image_part = {"mime_type": "image/jpeg", "data": image_bytes}
        response = model.generate_content([image_part, prompt])
        return json.loads(response.text)
    except Exception as e:
        print(f"Gemini error: {e}")
        return {}


def _update_user_score(user_id: str, points: int):
    user_ref = db.collection("users").document(user_id)
    user_ref.update({
        "sdgScore": firestore.Increment(points),
        "lastPostDate": firestore.SERVER_TIMESTAMP,
    })
    # Update streak
    user_doc = user_ref.get()
    if user_doc.exists:
        data = user_doc.to_dict()
        from datetime import datetime, timezone, timedelta
        now = datetime.now(timezone.utc)
        last_post = data.get("lastPostDate")
        streak = data.get("streak", 0)
        if last_post:
            delta = (now - last_post).days
            if delta == 0:
                pass  # Same day
            elif delta == 1:
                streak += 1
            else:
                streak = 1
        else:
            streak = 1
        user_ref.update({"streak": streak})
