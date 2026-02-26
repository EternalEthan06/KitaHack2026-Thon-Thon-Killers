import firebase_admin
from firebase_admin import credentials, db
import datetime

cred = credentials.Certificate("service-account.json")
firebase_admin.initialize_app(cred, {
    'databaseURL': 'https://kitahack2026-f1f3e-default-rtdb.asia-southeast1.firebasedatabase.app'
})

def seed():
    print("🚀 Seeding Realtime Database...")
    
    # ── Volunteer Events ───────────────────────────────────────────────────────
    events_ref = db.reference('volunteer_events')
    now = datetime.datetime.now()
    
    events = {
        "event_1": {
            "ngoId": "ngo_1",
            "ngoName": "WWF Malaysia",
            "title": "Klang River Cleanup Day",
            "description": "Join us to clean up the Klang River banks and protect aquatic wildlife. Tools provided!",
            "address": "Pasar Seni, Kuala Lumpur",
            "date": int((now + datetime.timedelta(days=7)).timestamp() * 1000),
            "sdgGoals": [6, 14, 15],
            "sdgPointsReward": 80,
            "registeredUsers": {},
            "imageURL": "https://images.unsplash.com/photo-1618477434123-534bc7e5c54c?q=80&w=800"
        },
        "event_2": {
            "ngoId": "ngo_2",
            "ngoName": "Yayasan Chow Kit",
            "title": "Evening Tutoring for Kids",
            "description": "Help primary school children with their homework and English reading skills.",
            "address": "Chow Kit, Kuala Lumpur",
            "date": int((now + datetime.timedelta(days=3)).timestamp() * 1000),
            "sdgGoals": [4, 10],
            "sdgPointsReward": 60,
            "registeredUsers": {},
            "imageURL": "https://images.unsplash.com/photo-1497633762265-9d179a990aa6?q=80&w=800"
        }
    }
    events_ref.set(events)
    print(f"  ✅ {len(events)} events seeded")

    # ── Donation Projects ──────────────────────────────────────────────────────
    projects_ref = db.reference('donation_projects')
    projects = {
        "proj_1": {
            "ngoId": "ngo_1",
            "ngoName": "WWF Malaysia",
            "title": "Save the Malayan Tiger",
            "description": "Critical funding needed for forest patrols and anti-poaching units to save our tigers.",
            "imageURL": "https://images.unsplash.com/photo-1508817628294-5a453fa0b8fb?q=80&w=800",
            "sdgGoals": [15, 17],
            "neededItems": ["Patrol gear", "Camera traps", "Medical kits"],
            "targetAmount": 50000.0,
            "raisedAmount": 12450.0,
            "targetPoints": 10000,
            "raisedPoints": 0,
            "endDate": int((now + datetime.timedelta(days=30)).timestamp() * 1000),
            "active": True
        }
    }
    projects_ref.set(projects)
    print(f"  ✅ {len(projects)} donation projects seeded")

    print("\n🎉 RTDB seeding complete!")

if __name__ == "__main__":
    seed()
