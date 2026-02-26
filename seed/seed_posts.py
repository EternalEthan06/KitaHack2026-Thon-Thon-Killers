"""
Seed 10 sample posts from demo users into Firestore.
Run AFTER seed_firestore.py (NGOs/events/rewards must exist first).

Usage: python seed_posts.py
"""

import firebase_admin
from firebase_admin import credentials, firestore
from datetime import datetime, timezone, timedelta
import random

# ── Initialize Firebase ──────────────────────────────────────────────────────
if not firebase_admin._apps:
    cred = credentials.Certificate(r"C:\Users\user\Downloads\sdg-connect-ff16c-firebase-adminsdk-fbsvc-fed3c83489.json")
    firebase_admin.initialize_app(cred)

db = firestore.client()

# ── Sample users ──────────────────────────────────────────────────────────────
USERS = [
    {"uid": "demo_user_1", "displayName": "Aisha Rahman",    "photoURL": ""},
    {"uid": "demo_user_2", "displayName": "Wei Jun Lim",     "photoURL": ""},
    {"uid": "demo_user_3", "displayName": "Priya Nair",      "photoURL": ""},
    {"uid": "demo_user_4", "displayName": "Haziq Azman",     "photoURL": ""},
    {"uid": "demo_user_5", "displayName": "Siti Aminah",     "photoURL": ""},
]

# ── Sample posts data ─────────────────────────────────────────────────────────
# Using picsum.photos for realistic demo images (free, no auth needed)
POSTS = [
    {
        "caption": "Joined the Klang River cleanup today! 🌊 Every piece of trash removed is a step toward SDG 14. #CleanOurRivers #SDG14",
        "mediaURL": "https://images.unsplash.com/photo-1618365908648-e71bd5716cba?w=800",
        "sdgGoals": [6, 14, 15], "score": 82,
        "aiReason": "This shows direct action to protect aquatic ecosystems and clean water sources — a strong contribution to SDG 14 and SDG 6.",
        "user": USERS[0],
    },
    {
        "caption": "Our rooftop solar panels are finally installed! ☀️ Net zero energy here we come. #RenewableEnergy #SDG7",
        "mediaURL": "https://images.unsplash.com/photo-1509391366360-2e959784a276?w=800",
        "sdgGoals": [7, 13], "score": 78,
        "aiReason": "Installing solar panels directly supports affordable clean energy (SDG 7) and climate action (SDG 13).",
        "user": USERS[1],
    },
    {
        "caption": "Teaching underprivileged kids coding this weekend at Yayasan Chow Kit 💻❤️ Education is the best investment. #SDG4 #QualityEducation",
        "mediaURL": "https://images.unsplash.com/photo-1603354350317-6f7aaa5911c5?w=800",
        "sdgGoals": [4, 10], "score": 90,
        "aiReason": "Volunteering to teach underprivileged children coding directly advances quality education (SDG 4) and reduces inequality (SDG 10).",
        "user": USERS[2],
    },
    {
        "caption": "Started my zero-waste grocery run 🛒 Reusable bags + bulk buying = less plastic! #ZeroWaste #SDG12",
        "mediaURL": "https://images.unsplash.com/photo-1542838132-92c53300491e?w=800",
        "sdgGoals": [12], "score": 65,
        "aiReason": "Adopting zero-waste grocery habits supports responsible consumption and production (SDG 12).",
        "user": USERS[3],
    },
    {
        "caption": "Planted 50 mangrove seedlings with WWF Malaysia today 🌱 Protecting our coast and carbon sinks! #SDG15 #Mangroves",
        "mediaURL": "https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800",
        "sdgGoals": [13, 14, 15], "score": 95,
        "aiReason": "Planting mangroves is an exceptional action — it sequesters carbon, protects coastlines, and supports marine and land biodiversity across SDG 13, 14, and 15.",
        "user": USERS[4],
    },
    {
        "caption": "Composting food waste at home 🍃 Our garden loves it and landfills hate it. #SDG2 #SDG12 #Composting",
        "mediaURL": "https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=800",
        "sdgGoals": [2, 12], "score": 55,
        "aiReason": "Home composting reduces food waste sent to landfills and contributes to sustainable food systems, supporting SDG 2 and SDG 12.",
        "user": USERS[0],
    },
    {
        "caption": "Cycled to work for the second week straight 🚴 No more carbon footprint from my commute! #GreenCommute #SDG11",
        "mediaURL": "https://images.unsplash.com/photo-1502741338009-cac2772e18bc?w=800",
        "sdgGoals": [11, 13], "score": 60,
        "aiReason": "Commuting by bicycle reduces urban carbon emissions, contributing to sustainable cities (SDG 11) and climate action (SDG 13).",
        "user": USERS[1],
    },
    {
        "caption": "Volunteers at the food bank today — 300 meals packed for families in need 🍚❤️ #ZeroHunger #SDG2",
        "mediaURL": "https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?w=800",
        "sdgGoals": [1, 2], "score": 88,
        "aiReason": "Volunteering at a food bank directly combats hunger and poverty, making a significant impact on SDG 1 and SDG 2.",
        "user": USERS[2],
    },
    {
        "caption": "Switched to bamboo toothbrushes and shampoo bars this month 🧴 Small swaps, big difference. #PlasticFree #SDG14",
        "mediaURL": "https://images.unsplash.com/photo-1607631568010-a87245c0daf8?w=800",
        "sdgGoals": [12, 14], "score": 48,
        "aiReason": "Replacing single-use plastic products with sustainable alternatives reduces ocean plastic pollution, supporting SDG 12 and SDG 14.",
        "user": USERS[3],
    },
    {
        "caption": "Attended a women in STEM workshop in KL today 👩‍💻 Empowering the next generation of female engineers! #SDG5 #WomenInTech",
        "mediaURL": "https://images.unsplash.com/photo-1573496799652-408c2ac9fe98?w=800",
        "sdgGoals": [4, 5], "score": 72,
        "aiReason": "Supporting women in STEM education advances gender equality (SDG 5) and quality education (SDG 4) simultaneously.",
        "user": USERS[4],
    },
]

def seed_posts():
    print("Seeding 10 sample posts...")
    now = datetime.now(timezone.utc)

    # Ensure demo users exist in Firestore
    for user in USERS:
        db.collection("users").document(user["uid"]).set({
            "uid": user["uid"],
            "displayName": user["displayName"],
            "email": f"{user['uid']}@demo.com",
            "photoURL": "",
            "sdgScore": random.randint(200, 800),
            "streak": random.randint(1, 14),
            "badges": [],
            "createdAt": firestore.SERVER_TIMESTAMP,
        }, merge=True)

    # Create 10 posts spread over last 7 days
    for i, post_data in enumerate(POSTS):
        post_id = f"demo_post_{i + 1:02d}"
        created_at = now - timedelta(hours=random.randint(1, 168))  # last 7 days

        db.collection("posts").document(post_id).set({
            "id": post_id,
            "userId": post_data["user"]["uid"],
            "userDisplayName": post_data["user"]["displayName"],
            "userPhotoURL": "",
            "type": "sdg",
            "mediaURL": post_data["mediaURL"],
            "mediaType": "image",
            "caption": post_data["caption"],
            "sdgScore": post_data["score"],
            "sdgGoals": post_data["sdgGoals"],
            "aiReason": post_data["aiReason"],
            "status": "scored",
            "likes": random.randint(3, 47),
            "likedBy": [],
            "createdAt": created_at,
        })
        print(f"  ✅ Post {i + 1}/10: {post_data['user']['displayName']} — SDG {post_data['sdgGoals']} (+{post_data['score']} pts)")

    print("\n🎉 10 sample posts seeded successfully!")
    print("   Open the app → Feed to see them!")

if __name__ == "__main__":
    seed_posts()
