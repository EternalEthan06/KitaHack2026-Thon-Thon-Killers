"""
Seed donation projects for each NGO into Firestore.
Run after seed_firestore.py.

Usage: python seed_projects.py
"""

import firebase_admin
from firebase_admin import credentials, firestore
from datetime import datetime, timezone, timedelta

if not firebase_admin._apps:
    cred = credentials.Certificate(r"C:\Users\user\Downloads\sdg-connect-ff16c-firebase-adminsdk-fbsvc-fed3c83489.json")
    firebase_admin.initialize_app(cred)

db = firestore.client()

def get_ngo_ids():
    ngos = {doc.to_dict()["name"]: doc.id for doc in db.collection("ngo_orgs").stream()}
    return ngos

def seed():
    print("Fetching NGO IDs...")
    ngos = get_ngo_ids()
    now = datetime.now(timezone.utc)

    projects = [
        # ── WWF Malaysia ──────────────────────────────────────────────────
        {
            "ngoId": ngos.get("WWF Malaysia", ""),
            "ngoName": "WWF Malaysia",
            "title": "Borneo Mangrove Restoration",
            "description": "Replant 5,000 mangrove seedlings along the Sabah coastline to restore critical marine habitats and protect against coastal erosion.",
            "imageURL": "https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800",
            "sdgGoals": [13, 14, 15],
            "neededItems": ["5,000 mangrove seedlings", "20 planting boats", "50 volunteers for 3 days", "Waterproof gloves (200 pairs)"],
            "targetAmount": 8000.0,
            "raisedAmount": 3240.0,
            "targetPoints": 50000,
            "raisedPoints": 18700,
            "endDate": now + timedelta(days=45),
            "active": True,
        },
        {
            "ngoId": ngos.get("WWF Malaysia", ""),
            "ngoName": "WWF Malaysia",
            "title": "Orangutan Habitat Protection Fund",
            "description": "Purchase and protect 10 hectares of rainforest in Sabah to prevent deforestation and safeguard orangutan corridor habitats.",
            "imageURL": "https://images.unsplash.com/photo-1564349683136-77e08dba1ef7?w=800",
            "sdgGoals": [15],
            "neededItems": ["Legal land acquisition funds", "Camera trap equipment (30 units)", "Ranger patrol supplies", "Anti-poaching signage"],
            "targetAmount": 25000.0,
            "raisedAmount": 9800.0,
            "targetPoints": 120000,
            "raisedPoints": 44000,
            "endDate": now + timedelta(days=90),
            "active": True,
        },

        # ── Yayasan Chow Kit ──────────────────────────────────────────────
        {
            "ngoId": ngos.get("Yayasan Chow Kit", ""),
            "ngoName": "Yayasan Chow Kit",
            "title": "Digital Classroom for Urban Youth",
            "description": "Set up a fully equipped computer lab with 25 workstations for underprivileged children in Chow Kit to learn coding and digital skills.",
            "imageURL": "https://images.unsplash.com/photo-1603354350317-6f7aaa5911c5?w=800",
            "sdgGoals": [4, 10],
            "neededItems": ["25 laptops", "High-speed WiFi router", "Coding curriculum licenses", "Desks and chairs (25 sets)", "Projector & screen"],
            "targetAmount": 12000.0,
            "raisedAmount": 7500.0,
            "targetPoints": 60000,
            "raisedPoints": 31200,
            "endDate": now + timedelta(days=30),
            "active": True,
        },
        {
            "ngoId": ngos.get("Yayasan Chow Kit", ""),
            "ngoName": "Yayasan Chow Kit",
            "title": "Monthly Meal Programme",
            "description": "Provide nutritious daily meals for 50 street-connected children in Kuala Lumpur for 6 months so they can focus on their education.",
            "imageURL": "https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?w=800",
            "sdgGoals": [1, 2, 4],
            "neededItems": ["Rice (500kg/month)", "Fresh vegetables (daily)", "Protein (eggs, chicken)", "Kitchen supplies", "Volunteer cooks"],
            "targetAmount": 9000.0,
            "raisedAmount": 2100.0,
            "targetPoints": 45000,
            "raisedPoints": 9800,
            "endDate": now + timedelta(days=60),
            "active": True,
        },

        # ── Zero Waste Malaysia ───────────────────────────────────────────
        {
            "ngoId": ngos.get("Zero Waste Malaysia", ""),
            "ngoName": "Zero Waste Malaysia",
            "title": "Community Composting Network",
            "description": "Install 20 community compost hubs across Klang Valley to divert food waste from landfills and produce nutrient-rich compost for urban gardens.",
            "imageURL": "https://images.unsplash.com/photo-1542838132-92c53300491e?w=800",
            "sdgGoals": [11, 12, 13],
            "neededItems": ["20 compost bins (large)", "Educational signage (40 boards)", "Compost thermometers (20)", "Volunteer training kits", "Transport to sites"],
            "targetAmount": 5500.0,
            "raisedAmount": 4050.0,
            "targetPoints": 28000,
            "raisedPoints": 21500,
            "endDate": now + timedelta(days=21),
            "active": True,
        },

        # ── Women's Aid Organisation ──────────────────────────────────────
        {
            "ngoId": ngos.get("Women's Aid Organisation", ""),
            "ngoName": "Women's Aid Organisation",
            "title": "Safe House Renovation Fund",
            "description": "Renovate the WAO safe house to provide safe, dignified accommodation for 30 domestic violence survivors and their children.",
            "imageURL": "https://images.unsplash.com/photo-1582213782179-e0d53f98f2ca?w=800",
            "sdgGoals": [5, 10, 16],
            "neededItems": ["Paint & renovation materials", "Beds & mattresses (30 sets)", "Children's play area equipment", "Security cameras (10 units)", "Kitchen appliances"],
            "targetAmount": 15000.0,
            "raisedAmount": 6300.0,
            "targetPoints": 75000,
            "raisedPoints": 28900,
            "endDate": now + timedelta(days=75),
            "active": True,
        },
        {
            "ngoId": ngos.get("Women's Aid Organisation", ""),
            "ngoName": "Women's Aid Organisation",
            "title": "Legal Aid & Counselling Programme",
            "description": "Fund 6 months of free legal consultation and professional counselling sessions for 60 women survivors navigating the justice system.",
            "imageURL": "https://images.unsplash.com/photo-1573496799652-408c2ac9fe98?w=800",
            "sdgGoals": [5, 16],
            "neededItems": ["Legal consultation fees (60 cases)", "Counsellor sessions (240 hrs)", "Case management software", "Printed resource guides (200)"],
            "targetAmount": 18000.0,
            "raisedAmount": 5400.0,
            "targetPoints": 90000,
            "raisedPoints": 27000,
            "endDate": now + timedelta(days=120),
            "active": True,
        },
    ]

    for i, p in enumerate(projects):
        doc_id = f"project_{i + 1:02d}"
        db.collection("donation_projects").document(doc_id).set(p)
        print(f"  ✅ [{p['ngoName']}] {p['title'][:50]}")

    print(f"\n🎉 {len(projects)} donation projects seeded!")
    print("   → Open the app → Donate tab to see them.")

if __name__ == "__main__":
    seed()
