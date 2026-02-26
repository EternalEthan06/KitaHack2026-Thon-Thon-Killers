"""
Patch script: Adds imageURL to existing volunteer events, NGO orgs,
and marketplace products in Firestore.

Usage: python seed_images.py
"""

import firebase_admin
from firebase_admin import credentials, firestore

if not firebase_admin._apps:
    cred = credentials.Certificate(r"C:\Users\user\Downloads\sdg-connect-ff16c-firebase-adminsdk-fbsvc-fed3c83489.json")
    firebase_admin.initialize_app(cred)

db = firestore.client()

# ── Image URLs by keyword matching ────────────────────────────────────────────

VOLUNTEER_IMAGES = {
    "Klang River Cleanup":       "https://images.unsplash.com/photo-1618365908648-e71bd5716cba?w=800",
    "Free Tuition":              "https://images.unsplash.com/photo-1503676260728-1c00da094a0b?w=800",
    "Upcycling Workshop":        "https://images.unsplash.com/photo-1604187351574-c75ca79f5807?w=800",
    "Empowerment Skills":        "https://images.unsplash.com/photo-1573496799652-408c2ac9fe98?w=800",
}

NGO_IMAGES = {
    "WWF Malaysia":              "https://images.unsplash.com/photo-1564349683136-77e08dba1ef7?w=800",
    "Yayasan Chow Kit":          "https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?w=800",
    "Zero Waste Malaysia":       "https://images.unsplash.com/photo-1542838132-92c53300491e?w=800",
    "Women's Aid Organisation":  "https://images.unsplash.com/photo-1582213782179-e0d53f98f2ca?w=800",
}

PRODUCT_IMAGES = {
    "Handmade Tote Bag":         "https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=800",
    "Beeswax Wrap":              "https://images.unsplash.com/photo-1587049352846-4a222e784d38?w=800",
    "WWF Plush":                 "https://images.unsplash.com/photo-1559715541-d4fc97b8d6dd?w=800",
    "Upcycled Notebook":         "https://images.unsplash.com/photo-1531346878377-a5be20888e57?w=800",
    "Handwoven Basket":          "https://images.unsplash.com/photo-1590736969955-71cc94901144?w=800",
}

REWARD_IMAGES = {
    "Grab":                      "https://images.unsplash.com/photo-1565299585323-38d6b0865b47?w=800",
    "Plant a Tree":              "https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800",
    "Touch 'n Go":               "https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=800",
    "SDG Champion":              "https://images.unsplash.com/photo-1567427017947-545c5f8d16ad?w=800",
    "Eco Warrior":               "https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?w=800",
    "NGO Donation":              "https://images.unsplash.com/photo-1532629345422-7515f3d16bb6?w=800",
}

def get_image(mapping, name):
    for keyword, url in mapping.items():
        if keyword.lower() in name.lower():
            return url
    return "https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=800"  # fallback green

def patch_collection(col_name, mapping, name_field="name"):
    docs = db.collection(col_name).stream()
    count = 0
    for doc in docs:
        data = doc.to_dict()
        title = data.get(name_field, data.get("title", ""))
        img = get_image(mapping, title)
        db.collection(col_name).document(doc.id).update({"imageURL": img})
        print(f"    📸 [{col_name}] {title[:45]}")
        count += 1
    return count

print("Adding images to Firestore collections...\n")

n = patch_collection("ngo_orgs",             NGO_IMAGES,       name_field="name")
print(f"  ✅ {n} NGO orgs updated\n")

n = patch_collection("volunteer_events",     VOLUNTEER_IMAGES, name_field="title")
print(f"  ✅ {n} volunteer events updated\n")

n = patch_collection("marketplace_products", PRODUCT_IMAGES,   name_field="name")
print(f"  ✅ {n} marketplace products updated\n")

n = patch_collection("rewards",              REWARD_IMAGES,    name_field="title")
print(f"  ✅ {n} rewards updated\n")

print("🎉 All done! Images now visible in the app.")
