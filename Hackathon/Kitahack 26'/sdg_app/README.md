# 🌱 SDG Connect — KitaHack 2026

A social impact app powered by Flutter + Firebase + Gemini AI, built for **KitaHack 2026**.

Users earn SDG points by posting impact content, volunteering, and donating. AI automatically scores posts and stories based on UN Sustainable Development Goals (SDGs).

---

## Prerequisites

| Tool | Version |
|------|---------|
| [Flutter](https://docs.flutter.dev/get-started/install) | ≥ 3.19 |
| [Dart](https://dart.dev/get-dart) | ≥ 3.3 |
| A web browser (Chrome recommended) | — |

---

## Setup

### 1. Clone the repo

```bash
git clone https://github.com/EternalEthan06/KitaHack2026-Thon-Thon-Killers.git
cd "KitaHack2026-Thon-Thon-Killers/Hackathon/Kitahack 26'/sdg_app"
```

### 2. Get dependencies

```bash
flutter pub get
```

### 3. Add the `.env` file

Create a file called `.env` in the `sdg_app/` root (same level as `pubspec.yaml`):

```env
GEMINI_API_KEY=your_gemini_api_key_here
```

Get a free key from [Google AI Studio](https://aistudio.google.com/app/apikey).

### 4. Add Firebase config

This app uses an existing Firebase project. Get `google-services.json` (Android) and/or `GoogleService-Info.plist` (iOS/macOS) from a team member, then place them:

- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist` *(if running on iOS)*

For **web**, the Firebase config is already embedded in `web/index.html`.

> 💡 **Team members:** Ask the project owner for the Firebase config files — they are not in the repo for security reasons.

### 5. Run the app

```bash
# Web (recommended for dev)
flutter run -d chrome

# Windows desktop
flutter run -d windows

# Android (with device/emulator connected)
flutter run -d android
```

---

## Project Structure

```
lib/
├── core/
│   ├── models/       # Data models (Post, User, Story, NGO…)
│   ├── services/     # Firebase, Auth, Gemini AI services
│   ├── theme/        # App colours & typography
│   └── constants/    # SDG goal names, icons, colours
├── features/
│   ├── feed/         # Feed, Stories, Story viewer/creator
│   ├── volunteer/    # Volunteer events + personal calendar
│   ├── donate/       # NGO donation flow
│   ├── rewards/      # SDG points, badges, leaderboard
│   └── profile/      # User profile
└── shared/
    └── widgets/      # PostCard, StoryBar, etc.
```

---

## Key Features

- 📸 **Stories** — 24h expiry, AI-scored SDG impact points
- 🏆 **Leaderboard sidebar** — Top contributors & most active NGOs
- 🖼️ **Multi-photo posts** — Up to 5 images per post with swipeable carousel
- 🤖 **Gemini AI** — Auto-scores posts & stories for SDG relevance
- 🤝 **Volunteer** — Register for events, track calendar, earn points on completion
- 💚 **Donate** — Support NGOs, earn SDG points

---

## Team

Built by **Thon Thon Killers** for KitaHack 2026.
