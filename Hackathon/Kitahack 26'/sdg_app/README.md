# SDG Connect — KitaHack 2026

A social media platform that gamifies UN Sustainable Development Goals (SDGs). Users post SDG-related photos which are **automatically scored by Google Gemini AI**. Earn points, unlock rewards, volunteer with NGOs, and shop the eco marketplace.

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| **Mobile App** | Flutter (Dart) |
| **AI Scoring** | Google Gemini API (`gemini-1.5-flash`) |
| **Auth** | Firebase Authentication |
| **Database** | Cloud Firestore |
| **Storage** | Firebase Storage |
| **Backend** | Cloud Functions for Firebase (Python) |
| **Notifications** | Firebase Cloud Messaging |

---

## 🚀 Setup Instructions

### Step 1: Install Flutter
Download Flutter SDK from https://flutter.dev/docs/get-started/install
Add `flutter/bin` to your PATH. Verify with: `flutter doctor`

### Step 2: Create Firebase Project
1. Go to https://console.firebase.google.com
2. Create a new project called `sdg-connect`
3. Enable:
   - **Authentication** → Sign-in methods: Google, Email/Password
   - **Cloud Firestore** → Start in test mode
   - **Firebase Storage** → Start in test mode
   - **Cloud Functions**

### Step 3: Connect Flutter to Firebase
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# In the sdg_app directory:
flutterfire configure
```
This generates `lib/firebase_options.dart` automatically.

### Step 4: Get API Keys
- **Gemini API Key**: https://aistudio.google.com → Get API Key (free)
- **Google Maps API Key**: https://console.cloud.google.com → Enable Maps SDK for Android/iOS

Add them to `.env`:
```
GEMINI_API_KEY=your_key_here
GOOGLE_MAPS_API_KEY=your_key_here
```

### Step 5: Install Flutter Dependencies
```bash
cd sdg_app
flutter pub get
```

### Step 6: Seed Firestore with Demo Data
```bash
# Install Python dependencies
pip install firebase-admin google-cloud-firestore

# Download service account key from Firebase Console → Project Settings → Service accounts
# Update the path in seed_firestore.py line 14, then run:
python seed_firestore.py
```

### Step 7: Run the App
```bash
flutter run
```

---

## ☁️ Deploy Cloud Functions
```bash
cd sdg_app

# Install Firebase CLI
npm install -g firebase-tools
firebase login

# Set Gemini API key
firebase functions:secrets:set GEMINI_API_KEY

# Deploy
firebase deploy --only functions
```

---

## 📁 Project Structure
```
sdg_app/
├── lib/
│   ├── main.dart                    # Entry point
│   ├── app.dart                     # Root widget
│   ├── core/
│   │   ├── constants/               # SDG names, colors
│   │   ├── models/                  # UserModel, PostModel, NGOModel...
│   │   ├── services/
│   │   │   ├── gemini_service.dart  ← Gemini AI scoring
│   │   │   ├── auth_service.dart    ← Firebase Auth
│   │   │   └── firestore_service.dart ← All DB operations
│   │   ├── theme/                   # Dark theme, SDG colors
│   │   └── router/                  # GoRouter navigation
│   ├── features/
│   │   ├── auth/                    # Login, Register
│   │   ├── home/                    # Bottom nav shell
│   │   ├── feed/                    # For You + SDG tabs
│   │   ├── camera/                  # Photo + Gemini scoring
│   │   ├── profile/                 # Score, streak, posts
│   │   ├── rewards/                 # Redeem SDG points
│   │   ├── volunteer/               # NGO events + register
│   │   ├── donate/                  # Donate to NGOs
│   │   ├── marketplace/             # NGO products
│   │   └── post_detail/             # Full post view
│   └── shared/widgets/
│       ├── post_card.dart           # Feed post card
│       └── sdg_button.dart          # Styled button
├── functions/                       # Cloud Functions (Python)
│   ├── main.py                      # Gemini scoring trigger
│   └── requirements.txt
└── seed_firestore.py                # Demo data seeder
```

---

## ✅ Features Checklist
- [x] Google Sign-In + Email Auth
- [x] Post SDG photos with Gemini AI scoring
- [x] Post normal photos (no scoring)
- [x] Real-time feed (For You + SDG-only tabs)
- [x] SDG goal chips with UN colors
- [x] Like/interact with posts
- [x] User profile with score + streak
- [x] Rewards catalogue (redeem SDG points)
- [x] Volunteer events (register + earn points)
- [x] NGO donations (earn bonus points)
- [x] NGO marketplace
- [x] Cloud Functions SDG scoring backend
- [x] Firestore seed data (4 Malaysian NGOs, events, products, rewards)

---

## 🏆 KitaHack Demo Script
1. Open app → Sign in with Google
2. Tap camera FAB → Select SDG Post → Pick a green/eco image
3. Watch: "Analysing with Gemini AI..." → Score reveal screen
4. Go back to Feed → See your post with SDG badge + AI reason
5. Open Rewards → Show points balance → Redeem a reward
6. Open Volunteer → Register for an event → Points increase
7. Open Donate → Donate RM5 to WWF Malaysia
8. Open Marketplace → Browse eco products

**Total demo time: ~3 minutes**
