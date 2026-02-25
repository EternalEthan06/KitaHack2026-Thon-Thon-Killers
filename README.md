# 🌿 EcoRise — KitaHack 2026

[![Live Demo](https://img.shields.io/badge/Live-Demo-brightgreen?style=for-the-badge)](https://kitahack2026-f1f3e.web.app)

A high-performance social impact platform built with **Flutter**, **Firebase**, and **Gemini AI**. **EcoRise** empowers users to document and gamify their contributions to the UN Sustainable Development Goals (SDGs), turning climate action into a rewarding social experience.

---

## 🚀 Live Access
Judges and users can access the fully deployed application here:  
👉 **[https://kitahack2026-f1f3e.web.app](https://kitahack2026-f1f3e.web.app)**

---

## 🛠️ Setup & Installation

### 1. Prerequisites
- **Flutter SDK**: ≥ 3.3.0 ([Installation Guide](https://docs.flutter.dev/get-started/install))
- **Firebase Account**: (App uses Firebase Realtime Database & Firestore)
- **Google AI Studio Key**: For Gemini AI scoring ([Get Key Here](https://aistudio.google.com/app/apikey))

### 2. Getting Started
```bash
# Clone the repository
git clone https://github.com/EternalEthan06/KitaHack2026-Thon-Thon-Killers.git

# Install dependencies
flutter pub get
```

### 3. Environment Configuration
Create a `.env` file in the project root to enable AI features:
```env
GEMINI_API_KEY=your_gemini_api_key_here
```

---

## 📱 Running the App

### Standard Web Deployment
```bash
flutter run -d chrome
```

### Mobile Testing (Local Network / Camera Support)
To test high-impact features like the **Live Camera Verification**, use the provided batch file or the command below:

```bash
.\run_mobile.bat
```

---

## 🧪 Technical Innovation

### 🧠 Self-Healing AI Architecture
EcoRise features a multi-stage **AI Fallback System**. If the primary `gemini-1.5-flash` model is restricted or unavailable, the app automatically cycles through `gemini-pro` and `gemini-1.5-flash-8b`. If all API paths fail, it enters a **Demo-Safe Mode** to ensure the user's experience is never interrupted during a presentation.

### 🛡️ Low-Latency Impact Proofing
- **PWA Ready**: Can be installed directly from the browser as a standalone app.
- **Base64 Optimization**: Captured images are processed and stored efficiently as Base64 strings to remain 100% compatible with the Firebase Free (Spark) tier while maintaining high visual quality.
- **Persistent State**: Integrated recovery using `shared_preferences` to prevent data loss during browser RAM refreshes when using the camera.

---

## 📂 Project Structure

```
lib/
├── core/
│   ├── services/     # Self-Healing AI, Firebase Logic, Auth
│   ├── models/       # SDG, Post, NGO, and User Models
│   └── theme/        # EcoRise Neon Design System
├── features/
│   ├── feed/         # Social For-You & Certified SDG Feeds
│   ├── camera/       # AI-driven Impact Analysis
│   ├── volunteer/    # NGO Event & Calendar Integration
│   └── donate/       # Rewarding Donation System (20x Points)
```

---

## 🏆 Team: Thon Thon Killers
Built for **KitaHack 2026**.
- **Ethan Tiang**
- **Chloe Lai Phui Yan**
- **Lee Jasmin**
- **Wong Kai Heng**

Powered by **Google Cloud**, **Flutter**, & **Gemini AI**.
