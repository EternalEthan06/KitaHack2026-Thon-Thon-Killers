"""
Seed 10 sample stories into Firestore.
Stories expire after 24h so we set createdAt = now, expiresAt = now + 24h.

Run: python seed_stories.py
"""
import firebase_admin
from firebase_admin import credentials, firestore
from datetime import datetime, timezone, timedelta
import random

if not firebase_admin._apps:
    cred = credentials.Certificate(
        r"C:\Users\user\Downloads\sdg-connect-ff16c-firebase-adminsdk-fbsvc-fed3c83489.json"
    )
    firebase_admin.initialize_app(cred)

db = firestore.client()
now = datetime.now(timezone.utc)
expires = now + timedelta(hours=24)

stories = [
    {
        "userId": "user_01",
        "userDisplayName": "Aisha Rahman",
        "userPhotoURL": "https://i.pravatar.cc/150?img=47",
        "imageURL": "https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=600",
        "caption": "Planted 20 mangrove seedlings along Klang estuary today! Every tree counts 🌱 #SDG15",
        "sdgGoals": [13, 15],
        "pointsAwarded": 45,
        "aiReason": "User is engaged in reforestation activity directly tied to SDG 15 (Life on Land). High environmental impact.",
        "createdAt": firestore.SERVER_TIMESTAMP,
        "expiresAt": expires,
        "viewedBy": [],
    },
    {
        "userId": "user_02",
        "userDisplayName": "Darren Lim",
        "userPhotoURL": "https://i.pravatar.cc/150?img=12",
        "imageURL": "https://images.unsplash.com/photo-1559027615-cd4628902d4a?w=600",
        "caption": "Beach cleanup at Port Dickson — 15kg of plastic removed! Join us next Saturday 🏖️",
        "sdgGoals": [14, 12],
        "pointsAwarded": 40,
        "aiReason": "Coastal cleanup activity directly impacts SDG 14 (Life Below Water) and SDG 12 (Responsible Consumption).",
        "createdAt": firestore.SERVER_TIMESTAMP,
        "expiresAt": expires,
        "viewedBy": [],
    },
    {
        "userId": "user_03",
        "userDisplayName": "Mei Lin Tan",
        "userPhotoURL": "https://i.pravatar.cc/150?img=5",
        "imageURL": "https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?w=600",
        "caption": "Serving 80 meals at Yayasan Chow Kit today. Hunger is real — let's act ❤️ #SDG2",
        "sdgGoals": [1, 2],
        "pointsAwarded": 50,
        "aiReason": "Directly addressing zero hunger (SDG 2) and poverty reduction (SDG 1) through food distribution.",
        "createdAt": firestore.SERVER_TIMESTAMP,
        "expiresAt": expires,
        "viewedBy": [],
    },
    {
        "userId": "user_04",
        "userDisplayName": "Raj Kumar",
        "userPhotoURL": "https://i.pravatar.cc/150?img=33",
        "imageURL": "https://images.unsplash.com/photo-1509099836639-18ba1795216d?w=600",
        "caption": "Free coding workshop for 30 underprivileged kids in Chow Kit. Education changes lives 💻 #SDG4",
        "sdgGoals": [4, 10],
        "pointsAwarded": 55,
        "aiReason": "Educational outreach for underprivileged youth directly supports SDG 4 (Quality Education) and SDG 10 (Reduced Inequalities).",
        "createdAt": firestore.SERVER_TIMESTAMP,
        "expiresAt": expires,
        "viewedBy": [],
    },
    {
        "userId": "user_05",
        "userDisplayName": "Fatimah Yusof",
        "userPhotoURL": "https://i.pravatar.cc/150?img=9",
        "imageURL": "https://images.unsplash.com/photo-1542838132-92c53300491e?w=600",
        "caption": "Set up composting bins in our taman today with Zero Waste Malaysia! Less waste = better earth 🌍",
        "sdgGoals": [11, 12, 13],
        "pointsAwarded": 35,
        "aiReason": "Waste reduction initiative supports SDG 11 (Sustainable Cities), SDG 12 (Responsible Consumption), and SDG 13 (Climate Action).",
        "createdAt": firestore.SERVER_TIMESTAMP,
        "expiresAt": expires,
        "viewedBy": [],
    },
    {
        "userId": "user_06",
        "userDisplayName": "James Chong",
        "userPhotoURL": "https://i.pravatar.cc/150?img=68",
        "imageURL": "https://images.unsplash.com/photo-1521791136064-7986c2920216?w=600",
        "caption": "Donated blood today — 450ml can save 3 lives! 🩸 Visit Hospital KL donation drive this week.",
        "sdgGoals": [3],
        "pointsAwarded": 30,
        "aiReason": "Blood donation directly supports SDG 3 (Good Health and Well-Being) by contributing to medical supply chains.",
        "createdAt": firestore.SERVER_TIMESTAMP,
        "expiresAt": expires,
        "viewedBy": [],
    },
    {
        "userId": "user_07",
        "userDisplayName": "Nurul Ain",
        "userPhotoURL": "https://i.pravatar.cc/150?img=44",
        "imageURL": "https://images.unsplash.com/photo-1573496799652-408c2ac9fe98?w=600",
        "caption": "Volunteered at WAO legal clinic today helping 5 domestic violence survivors navigate court processes 💜 #SDG5",
        "sdgGoals": [5, 16],
        "pointsAwarded": 60,
        "aiReason": "Legal aid supporting domestic violence survivors directly advances SDG 5 (Gender Equality) and SDG 16 (Peace & Justice).",
        "createdAt": firestore.SERVER_TIMESTAMP,
        "expiresAt": expires,
        "viewedBy": [],
    },
    {
        "userId": "user_08",
        "userDisplayName": "Eric Wong",
        "userPhotoURL": "https://i.pravatar.cc/150?img=17",
        "imageURL": "https://images.unsplash.com/photo-1466611653911-95081537e5b7?w=600",
        "caption": "Installed 3 solar panels for a rural Orang Asli family in Pahang today ☀️ #SDG7 #SDG1",
        "sdgGoals": [7, 1],
        "pointsAwarded": 65,
        "aiReason": "Providing renewable energy access to rural indigenous communities supports SDG 7 (Clean Energy) and SDG 1 (No Poverty).",
        "createdAt": firestore.SERVER_TIMESTAMP,
        "expiresAt": expires,
        "viewedBy": [],
    },
    {
        "userId": "user_09",
        "userDisplayName": "Priya Nair",
        "userPhotoURL": "https://i.pravatar.cc/150?img=56",
        "imageURL": "https://images.unsplash.com/photo-1593113630400-ea4288922559?w=600",
        "caption": "Urban garden at Cheras community centre is thriving! Local produce for the neighbourhood 🥬 #SDG11 #SDG2",
        "sdgGoals": [2, 11],
        "pointsAwarded": 40,
        "aiReason": "Community urban farming promotes food security (SDG 2) and sustainable community development (SDG 11).",
        "createdAt": firestore.SERVER_TIMESTAMP,
        "expiresAt": expires,
        "viewedBy": [],
    },
    {
        "userId": "user_10",
        "userDisplayName": "Haziq Azman",
        "userPhotoURL": "https://i.pravatar.cc/150?img=22",
        "imageURL": "https://images.unsplash.com/photo-1610296669228-602fa827fc1f?w=600",
        "caption": "Teaching orang asli kids English in Gombak. Education is the most powerful tool ✏️ #SDG4",
        "sdgGoals": [4],
        "pointsAwarded": 50,
        "aiReason": "Literacy education for indigenous minority children strongly aligns with SDG 4 (Quality Education) and SDG 10 (Reduced Inequalities).",
        "createdAt": firestore.SERVER_TIMESTAMP,
        "expiresAt": expires,
        "viewedBy": [],
    },
]

print("Seeding 10 stories...")
for i, s in enumerate(stories):
    doc_id = f"story_{i+1:02d}"
    db.collection("stories").document(doc_id).set(s)
    print(f"  ✅ [{s['userDisplayName']}] {s['caption'][:50]}...")

# Also update existing posts to have imageURLs for the multi-photo carousel
print("\nUpdating seeded posts with extra imageURLs...")
extra_images = {
    "post_01": [
        "https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=600",
        "https://images.unsplash.com/photo-1518173946687-a4c8892bbd9f?w=600",
    ],
    "post_02": [
        "https://images.unsplash.com/photo-1559027615-cd4628902d4a?w=600",
        "https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=600",
        "https://images.unsplash.com/photo-1503220317375-aaad61436b1b?w=600",
    ],
    "post_03": [
        "https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?w=600",
        "https://images.unsplash.com/photo-1536010305525-f7aa0834e2c7?w=600",
    ],
    "post_04": [
        "https://images.unsplash.com/photo-1509099836639-18ba1795216d?w=600",
        "https://images.unsplash.com/photo-1573496799652-408c2ac9fe98?w=600",
        "https://images.unsplash.com/photo-1521737604893-d14cc237f11d?w=600",
    ],
    "post_05": [
        "https://images.unsplash.com/photo-1542838132-92c53300491e?w=600",
        "https://images.unsplash.com/photo-1466611653911-95081537e5b7?w=600",
    ],
}

for post_id, urls in extra_images.items():
    try:
        db.collection("posts").document(post_id).update({"imageURLs": urls})
        print(f"  📸 {post_id}: {len(urls)} extra images added")
    except Exception as e:
        print(f"  ⚠️  {post_id}: {e}")

print(f"\n🎉 Done! 10 stories + multi-photo updates complete.")
