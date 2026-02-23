"""
Seed an additional 10 SDG posts (batch 2) into Firestore.
IDs: demo_post_11 to demo_post_20

Usage: python seed_posts_2.py
"""

import firebase_admin
from firebase_admin import credentials, firestore
from datetime import datetime, timezone, timedelta
import random

if not firebase_admin._apps:
    cred = credentials.Certificate(r"C:\Users\user\Downloads\sdg-connect-ff16c-firebase-adminsdk-fbsvc-fed3c83489.json")
    firebase_admin.initialize_app(cred)

db = firestore.client()

USERS = [
    {"uid": "demo_user_6",  "displayName": "Tan Wei Ling",    "photoURL": ""},
    {"uid": "demo_user_7",  "displayName": "Rajan Krishnan",  "photoURL": ""},
    {"uid": "demo_user_8",  "displayName": "Nurul Hidayah",   "photoURL": ""},
    {"uid": "demo_user_9",  "displayName": "Lim Jia Hao",     "photoURL": ""},
    {"uid": "demo_user_10", "displayName": "Kavya Subramaniam","photoURL": ""},
]

POSTS = [
    {
        "caption": "Our school garden is thriving! 🥦🥕 Students learn where food comes from and cut food miles by 90%. #SDG2 #FoodSecurity #SchoolGarden",
        "mediaURL": "https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=800",
        "sdgGoals": [2, 4, 12], "score": 80,
        "aiReason": "A school garden directly connects children to sustainable food production, advancing SDG 2 (Zero Hunger) and SDG 4 (Quality Education).",
        "user": USERS[0],
    },
    {
        "caption": "Installing rainwater harvesting system at our kampung community centre 💧 Clean water for all! #SDG6 #CleanWater #Sustainability",
        "mediaURL": "https://images.unsplash.com/photo-1594010648419-86e6c8745282?w=800",
        "sdgGoals": [6, 11], "score": 85,
        "aiReason": "Rainwater harvesting provides clean water access to rural communities, directly supporting SDG 6 (Clean Water and Sanitation).",
        "user": USERS[1],
    },
    {
        "caption": "Hosted a free mental health workshop today 🧠💚 Breaking stigma, building resilience. #SDG3 #MentalHealth #WellBeing",
        "mediaURL": "https://images.unsplash.com/photo-1559757175-0eb30cd8c063?w=800",
        "sdgGoals": [3, 10], "score": 77,
        "aiReason": "Free mental health workshops improve community wellbeing and reduce inequality in healthcare access, supporting SDG 3 and SDG 10.",
        "user": USERS[2],
    },
    {
        "caption": "Upcycled 200 plastic bottles into planters for our balcony garden today! 🌺 Trash to treasure. #Upcycle #SDG12 #ZeroWaste",
        "mediaURL": "https://images.unsplash.com/photo-1591122947157-26bad3a117d4?w=800",
        "sdgGoals": [12, 15], "score": 62,
        "aiReason": "Upcycling plastic into garden planters reduces waste sent to landfills and promotes responsible production, supporting SDG 12.",
        "user": USERS[3],
    },
    {
        "caption": "Joined the beach cleanup at Port Dickson with 300 volunteers! 🌊 We collected 500kg of trash today. #OceanHeroes #SDG14",
        "mediaURL": "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800",
        "sdgGoals": [14, 17], "score": 93,
        "aiReason": "Organizing a 300-person beach cleanup with 500kg of waste removed is an exceptional, measurable contribution to ocean protection (SDG 14).",
        "user": USERS[4],
    },
    {
        "caption": "Supporting local orang asli artisan crafts at the Kuala Gandah market 🎨 Fair trade = fair wages = thriving communities. #SDG8 #FairTrade",
        "mediaURL": "https://images.unsplash.com/photo-1513519245088-0e12902e5a38?w=800",
        "sdgGoals": [8, 10, 17], "score": 70,
        "aiReason": "Purchasing fairly-traded indigenous crafts supports decent work, economic growth, and reduces systemic inequality (SDG 8 and SDG 10).",
        "user": USERS[0],
    },
    {
        "caption": "Our company switched to 100% renewable energy certificates today ⚡🌿 Net zero journey starts now! #SDG7 #NetZero #CorporateESG",
        "mediaURL": "https://images.unsplash.com/photo-1466611653911-95081537e5b7?w=800",
        "sdgGoals": [7, 9, 13], "score": 88,
        "aiReason": "Corporate adoption of renewable energy certificates drives clean energy demand and accelerates the clean energy transition across SDG 7, 9, and 13.",
        "user": USERS[1],
    },
    {
        "caption": "Opened a micro-library in our apartment lobby 📚 Free books for everyone — knowledge should not have barriers. #SDG4 #ReadForFree",
        "mediaURL": "https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=800",
        "sdgGoals": [4, 10], "score": 68,
        "aiReason": "Community micro-libraries democratize access to knowledge, directly supporting quality education and reducing inequality (SDG 4 and SDG 10).",
        "user": USERS[2],
    },
    {
        "caption": "Coaching rural girls in STEM skills this weekend 👩‍🔬 Every girl deserves to be a scientist! #SDG5 #GirlsInSTEM #WomenEmpowerment",
        "mediaURL": "https://images.unsplash.com/photo-1573496799652-408c2ac9fe98?w=800",
        "sdgGoals": [4, 5, 10], "score": 91,
        "aiReason": "Teaching STEM to rural girls addresses gender disparity in education and empowers the next generation of female scientists, advancing SDG 5 and SDG 4.",
        "user": USERS[3],
    },
    {
        "caption": "Built 3 vertical gardens in our apartment block common area 🌿 Urban farming, reduced heat, fresh air — triple win! #SDG11 #UrbanGreen",
        "mediaURL": "https://images.unsplash.com/photo-1586348943529-beaae6c28db9?w=800",
        "sdgGoals": [11, 13, 15], "score": 74,
        "aiReason": "Urban vertical gardens reduce heat island effects, improve air quality, and promote biodiversity in cities, contributing to SDG 11 and SDG 13.",
        "user": USERS[4],
    },
]

def seed_posts():
    print("Seeding 10 new SDG posts (batch 2)...")
    now = datetime.now(timezone.utc)

    # Ensure demo users exist
    for user in USERS:
        db.collection("users").document(user["uid"]).set({
            "uid": user["uid"],
            "displayName": user["displayName"],
            "email": f"{user['uid']}@demo.com",
            "photoURL": "",
            "sdgScore": random.randint(150, 900),
            "streak": random.randint(1, 21),
            "badges": [],
            "createdAt": firestore.SERVER_TIMESTAMP,
        }, merge=True)

    for i, post_data in enumerate(POSTS):
        post_id = f"demo_post_{i + 11:02d}"  # IDs 11-20
        created_at = now - timedelta(hours=random.randint(1, 120))

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
            "likes": random.randint(5, 63),
            "likedBy": [],
            "createdAt": created_at,
        })
        print(f"  ✅ Post {i + 11}/20: {post_data['user']['displayName']} — SDG {post_data['sdgGoals']} (+{post_data['score']} pts)")

    print("\n🎉 Batch 2 complete! 20 total posts now in Firestore.")

if __name__ == "__main__":
    seed_posts()
