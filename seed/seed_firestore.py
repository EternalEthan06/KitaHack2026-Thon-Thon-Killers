"""
Firestore Seed Script — Run this ONCE to populate your database with demo data.
Usage: python seed_firestore.py
Requires: firebase-admin, google-cloud-firestore
"""

import firebase_admin
from firebase_admin import credentials, firestore
from datetime import datetime, timezone, timedelta

# 1. Download your service account key from Firebase Console (Project Settings -> Service accounts)
# 2. Save it as 'service-account.json' in this folder.
cred = credentials.Certificate("service-account.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

def seed():
    print("Seeding Firestore...")

    # ── Rewards ────────────────────────────────────────────────────────────────
    rewards = [
        {"title": "Grab e-Voucher RM5", "description": "Redeem a RM5 Grab food voucher.", "costInScore": 300, "type": "voucher", "available": True},
        {"title": "Plant a Tree 🌳", "description": "We'll plant a real tree in Borneo on your behalf.", "costInScore": 500, "type": "tree", "available": True},
        {"title": "Touch 'n Go RM10", "description": "Redeem RM10 to your Touch 'n Go eWallet.", "costInScore": 600, "type": "voucher", "available": True},
        {"title": "SDG Champion Badge", "description": "Unlock the exclusive SDG Champion profile badge.", "costInScore": 100, "type": "badge", "available": True},
        {"title": "Eco Warrior Badge", "description": "Showcase your commitment to climate action.", "costInScore": 150, "type": "badge", "available": True},
        {"title": "NGO Donation RM20", "description": "We donate RM20 to an NGO of your choice.", "costInScore": 800, "type": "voucher", "available": True},
    ]
    for r in rewards:
        db.collection("rewards").add(r)
    print(f"  ✅ {len(rewards)} rewards seeded")

    # ── NGO Organizations ──────────────────────────────────────────────────────
    ngos = [
        {
            "name": "WWF Malaysia", "description": "Protecting Malaysia's wildlife and natural habitats.",
            "sdgGoals": [13, 14, 15], "contactEmail": "contact@wwf.org.my", "address": "Level 6, Menara Landmark, Johor Bahru",
        },
        {
            "name": "Yayasan Chow Kit", "description": "Supporting underprivileged urban youth in KL.",
            "sdgGoals": [1, 4, 10], "contactEmail": "info@yayasanchowkit.org", "address": "Jalan Chow Kit, Kuala Lumpur",
        },
        {
            "name": "Zero Waste Malaysia", "description": "Promoting sustainable consumption and circular economy.",
            "sdgGoals": [12, 13], "contactEmail": "hello@zerowaste.my", "address": "Petaling Jaya, Selangor",
        },
        {
            "name": "Women's Aid Organisation", "description": "Supporting survivors of domestic violence.",
            "sdgGoals": [5, 10, 16], "contactEmail": "wao@wao.org.my", "address": "Petaling Jaya, Selangor",
        },
    ]
    ngo_ids = []
    for ngo in ngos:
        ref = db.collection("ngo_orgs").add(ngo)
        ngo_ids.append(ref[1].id)
    print(f"  ✅ {len(ngos)} NGOs seeded")

    # ── Volunteer Events ───────────────────────────────────────────────────────
    now = datetime.now(timezone.utc)
    events = [
        {
            "ngoId": ngo_ids[0], "ngoName": "WWF Malaysia",
            "title": "Klang River Cleanup Day", "description": "Join us to clean up the Klang River banks and protect aquatic wildlife.",
            "address": "Petronas Twin Towers, Kuala Lumpur", "date": now + timedelta(days=7),
            "sdgGoals": [6, 14, 15], "sdgPointsReward": 80, "registeredUsers": [],
            "location": firestore.GeoPoint(3.1579, 101.7123),
        },
        {
            "ngoId": ngo_ids[1], "ngoName": "Yayasan Chow Kit",
            "title": "Free Tuition for Underprivileged Kids", "description": "Volunteer as a tutor for primary school children in Chow Kit.",
            "address": "Batu Caves, Selangor", "date": now + timedelta(days=3),
            "sdgGoals": [4, 10], "sdgPointsReward": 60, "registeredUsers": [],
            "location": firestore.GeoPoint(3.2374, 101.6841),
        },
        {
            "ngoId": ngo_ids[2], "ngoName": "Zero Waste Malaysia",
            "title": "Upcycling Workshop", "description": "Learn to turn waste into valuable products. Take home your creation!",
            "address": "Merdeka Square, Kuala Lumpur", "date": now + timedelta(days=14),
            "sdgGoals": [12, 13], "sdgPointsReward": 70, "registeredUsers": [],
            "location": firestore.GeoPoint(3.1486, 101.6932),
        },
        {
            "ngoId": ngo_ids[3], "ngoName": "Women's Aid Organisation",
            "title": "Empowerment Skills Day", "description": "Help facilitate skills training workshops for women survivors.",
            "address": "KL Tower, Kuala Lumpur", "date": now + timedelta(days=10),
            "sdgGoals": [5, 8], "sdgPointsReward": 90, "registeredUsers": [],
            "location": firestore.GeoPoint(3.1528, 101.7038),
        },
    ]
    for e in events:
        db.collection("volunteer_events").add(e)
    print(f"  ✅ {len(events)} volunteer events seeded")

    # ── Marketplace Products ───────────────────────────────────────────────────
    products = [
        {"ngoId": ngo_ids[2], "ngoName": "Zero Waste Malaysia", "name": "Handmade Tote Bag", "description": "Eco-friendly cotton tote bag made from upcycled materials.", "price": 25.00, "stock": 50, "sdgGoals": [12]},
        {"ngoId": ngo_ids[2], "ngoName": "Zero Waste Malaysia", "name": "Beeswax Wrap Set", "description": "Replace cling wrap with natural beeswax food wrap.", "price": 18.00, "stock": 30, "sdgGoals": [12, 13]},
        {"ngoId": ngo_ids[0], "ngoName": "WWF Malaysia", "name": "WWF Plush Toy (Orangutan)", "description": "Adopt an orangutan! Proceeds fund conservation.", "price": 45.00, "stock": 20, "sdgGoals": [15]},
        {"ngoId": ngo_ids[1], "ngoName": "Yayasan Chow Kit", "name": "Upcycled Notebook", "description": "Handmade notebook crafted by youth from Chow Kit.", "price": 12.00, "stock": 100, "sdgGoals": [4, 8]},
        {"ngoId": ngo_ids[3], "ngoName": "Women's Aid Organisation", "name": "Handwoven Basket", "description": "Beautiful basket woven by women artisans.", "price": 35.00, "stock": 15, "sdgGoals": [5, 8]},
    ]
    for p in products:
        db.collection("marketplace_products").add(p)
    print(f"  ✅ {len(products)} marketplace products seeded")

    print("\n🎉 Firestore seeding complete!")

if __name__ == "__main__":
    seed()
