import firebase_admin
from firebase_admin import credentials, db
from datetime import datetime, timezone, timedelta
import random
import uuid

# -- Configuration --
SERVICE_ACCOUNT = r"c:\2.0 Ethan Tiang\Projects\KitaHack 2026\service-account.json"
DATABASE_URL = "https://kitahack2026-f1f3e-default-rtdb.asia-southeast1.firebasedatabase.app"

if not firebase_admin._apps:
    cred = credentials.Certificate(SERVICE_ACCOUNT)
    firebase_admin.initialize_app(cred, {
        'databaseURL': DATABASE_URL
    })

ref = db.reference()

# -- Dummy Users --
USERS = [
    {"uid": "user_aisha", "displayName": "Aisha Rahman", "photoURL": "https://i.pravatar.cc/150?img=47"},
    {"uid": "user_weijun", "displayName": "Wei Jun Lim", "photoURL": "https://i.pravatar.cc/150?img=12"},
    {"uid": "user_priya", "displayName": "Priya Nair", "photoURL": "https://i.pravatar.cc/150?img=5"},
    {"uid": "user_haziq", "displayName": "Haziq Azman", "photoURL": "https://i.pravatar.cc/150?img=33"},
]

def seed_users():
    print("Seeding dummy users...")
    for u in USERS:
        ref.child("users").child(u["uid"]).update({
            "uid": u["uid"],
            "displayName": u["displayName"],
            "photoURL": u["photoURL"],
            "email": f"{u['uid']}@example.com",
            "sdgScore": random.randint(100, 500),
            "streak": random.randint(1, 10),
            "createdAt": int(datetime.now().timestamp() * 1000)
        })

def seed_posts():
    print("Seeding posts (SDG and For-You)...")
    
    # 1. SDG Posts (Target: Both feeds)
    sdg_posts = [
        {
            "caption": "Just finished my weekend beach cleanup! 🏖️ Collected 3 bags of plastic. #SDG14 #CleanOcean",
            "mediaURL": "https://images.unsplash.com/photo-1618365908648-e71bd5716cba?w=800",
            "type": "sdg", "score": 85, "goals": [14]
        },
        {
            "caption": "Solar panels are finally up! ☀️ Switching to clean energy feels great. #SDG7 #ClimateAction",
            "mediaURL": "https://images.unsplash.com/photo-1509391366360-2e959784a276?w=800",
            "type": "sdg", "score": 90, "goals": [7, 13]
        }
    ]

    # 2. Normal Posts (Target: ONLY For-You feed)
    normal_posts = [
        {
            "caption": "Enjoying a beautiful sunset today. Nature is amazing! 🌅 #Relax #Sunset",
            "mediaURL": "https://images.unsplash.com/photo-1501854140801-50d01698950b?w=800",
            "type": "normal", "score": 0, "goals": []
        },
        {
            "caption": "Brunch with the team after a long week! 🥐☕ #LifeUpdates",
            "mediaURL": "https://images.unsplash.com/photo-1582213776866-3397b995280b?w=800",
            "type": "normal", "score": 0, "goals": []
        }
    ]

    all_data = []
    for p in sdg_posts:
        user = random.choice(USERS)
        all_data.append({**p, "user": user})
    for p in normal_posts:
        user = random.choice(USERS)
        all_data.append({**p, "user": user})

    for i, p in enumerate(all_data):
        pid = str(uuid.uuid4())
        created_at = int((datetime.now() - timedelta(hours=i)).timestamp() * 1000)
        
        post_data = {
            "id": pid,
            "userId": p["user"]["uid"],
            "userDisplayName": p["user"]["displayName"],
            "userPhotoURL": p["user"]["photoURL"],
            "type": p["type"],
            "mediaURL": p["mediaURL"],
            "mediaType": "image",
            "caption": p["caption"],
            "sdgScore": p.get("score", 0),
            "sdgGoals": p.get("goals", []),
            "aiReason": "Seeded demo post" if p["type"] == "sdg" else "",
            "status": "scored",
            "likes": random.randint(5, 50),
            "createdAt": created_at
        }
        ref.child("posts").child(pid).set(post_data)
        print(f"  Post {p['type'].upper()} created by {p['user']['displayName']}")

def seed_stories():
    print("Seeding stories...")
    now = datetime.now(timezone.utc)
    expires = now + timedelta(hours=24)

    story_samples = [
        {
            "caption": "Mangrove planting in progress! 🌱",
            "imageURL": "https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=600",
            "sdgGoals": [13, 15]
        },
        {
            "caption": "Helping out at the local food bank today. 🍚",
            "imageURL": "https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?w=600",
            "sdgGoals": [2]
        }
    ]

    for s in story_samples:
        user = random.choice(USERS)
        sid = str(uuid.uuid4())
        ref.child("stories").child(sid).set({
            "userId": user["uid"],
            "userDisplayName": user["displayName"],
            "userPhotoURL": user["photoURL"],
            "imageURL": s["imageURL"],
            "caption": s["caption"],
            "sdgGoals": s["sdgGoals"],
            "pointsAwarded": 20,
            "aiReason": "Active community participation",
            "createdAt": int(now.timestamp() * 1000),
            "expiresAt": int(expires.timestamp() * 1000),
            "viewedBy": []
        })
        print(f"  Story created for {user['displayName']}")

if __name__ == "__main__":
    print("Unified Seeding Started...")
    seed_users()
    seed_posts()
    seed_stories()
    print("All demo data seeded to RTDB!")
