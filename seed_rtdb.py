import firebase_admin
from firebase_admin import credentials, db
import json
import uuid
from datetime import datetime, timedelta

# 1. SETUP
cred = credentials.Certificate('service-account.json')
firebase_admin.initialize_app(cred, {
    'databaseURL': 'https://kitahack2026-f1f3e-default-rtdb.asia-southeast1.firebasedatabase.app/'
})

def seed_database():
    print("🚀 Seeding Realtime Database...")
    
    # ── NGO ORGS (ngo_orgs) ────────────────────────────────────────────────
    ngos = {
        "ngo_1": {
            "name": "EcoGuardians Malaysia",
            "description": "Protecting tropical rainforests through community action.",
            "logoURL": "https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=200",
            "sdgGoals": [13, 15],
            "address": "Kuala Lumpur, Malaysia",
            "location": {"lat": 3.1390, "lng": 101.6869}
        },
        "ngo_2": {
            "name": "OceanClean My",
            "description": "Removing plastic from Malaysian coastlines.",
            "logoURL": "https://images.unsplash.com/photo-1484417894907-623942c8ee29?w=200",
            "sdgGoals": [14, 12],
            "address": "Penang, Malaysia",
            "location": {"lat": 5.4141, "lng": 100.3288}
        }
    }

    # ── MARKETPLACE PRODUCTS (marketplace_products) ─────────────────────────
    products = {
        "prod_1": {
            "name": "Eco-Friendly Bamboo Straws",
            "description": "Set of 5 reusable bamboo straws with cleaning brush.",
            "price": 15.00,
            "stock": 50,
            "ngoId": "ngo_2",
            "ngoName": "OceanClean My",
            "imageURL": "https://images.unsplash.com/photo-1594498653385-d5172b532c00?w=400",
            "sdgGoals": [12, 14]
        },
        "prod_2": {
            "name": "Organic Cotton Tote Bag",
            "description": "Durable tote bag made from 100% organic cotton.",
            "price": 25.00,
            "stock": 30,
            "ngoId": "ngo_1",
            "ngoName": "EcoGuardians Malaysia",
            "imageURL": "https://images.unsplash.com/photo-1544816155-12df9643f363?w=400",
            "sdgGoals": [12, 15]
        }
    }

    # ── REWARDS (rewards) ──────────────────────────────────────────────────
    rewards = {
        "reward_1": {
            "title": "RM10 Grab Voucher",
            "description": "Get RM10 off your next ride.",
            "costInScore": 500,
            "type": "voucher",
            "available": True,
            "imageURL": "https://images.unsplash.com/photo-1621600411688-4be93cd68504?w=200"
        },
        "reward_2": {
            "title": "Plant a Mangrove",
            "description": "We will plant a mangrove tree in your name.",
            "costInScore": 200,
            "type": "tree",
            "available": True,
            "imageURL": "https://images.unsplash.com/photo-1545239351-ef35f43d514b?w=200"
        }
    }

    # ── VOLUNTEER EVENTS (volunteer_events) ────────────────────────────────
    events = {
        "event_1": {
            "ngoId": "ngo_2",
            "ngoName": "OceanClean My",
            "title": "Batu Ferringhi Beach Cleanup",
            "description": "Join us for a morning of beach cleaning and community fun.",
            "address": "Batu Ferringhi Beach, Penang",
            "date": 1740528000000, 
            "sdgGoals": [14],
            "sdgPointsReward": 100,
            "registeredUsers": [],
            "imageURL": "https://images.unsplash.com/photo-1618477402805-081702fcc864?w=500"
        }
    }

    # ── POSTS (posts) ──────────────────────────────────────────────────────
    posts = {
        "post_1": {
            "userId": "system",
            "userDisplayName": "Eco Bot",
            "userPhotoURL": "https://api.dicebear.com/7.x/bottts/svg?seed=eco",
            "caption": "Welcome to SDG Connect! Start posting your impact today! 🌿",
            "mediaURL": "https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=800",
            "mediaType": "image",
            "type": "social",
            "status": "scored",
            "likes": 12,
            "likedBy": ["system"],
            "createdAt": int(datetime.now().timestamp() * 1000)
        }
    }

    # UPLOAD
    ref = db.reference('/')
    ref.update({
        'ngo_orgs': ngos,
        'marketplace_products': products,
        'rewards': rewards,
        'volunteer_events': events,
        'donation_projects': {
             "proj_1": {
                "id": "proj_1",
                "ngoId": "ngo_1",
                "ngoName": "EcoGuardians Malaysia",
                "title": "Save the Tapirs",
                "description": "Funding for wildlife corridors in Pahang.",
                "active": True,
                "targetAmount": 5000,
                "raisedAmount": 1250,
                "targetPoints": 10000,
                "raisedPoints": 3400,
                "sdgGoals": [15, 17],
                "neededItems": ["Drones", "Nature Cameras", "Ranger Kits"],
                "imageURL": "https://images.unsplash.com/photo-1581282662057-da0275841e26?w=600"
            }
        },
        'posts': posts
    })

    print("✅ Database Seeded Successfully with App-Compatible Keys!")

if __name__ == "__main__":
    seed_database()
