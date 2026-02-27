<div align="center">

# 🌿 EcoRise
### A Sustainable Future Built Together

![Flutter](https://img.shields.io/badge/Flutter-SDK-%2302569B.svg?style=flat&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-Language-%230175C2.svg?style=flat&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-Backend-%23FFCA28.svg?style=flat&logo=firebase&logoColor=black)
![Gemini AI](https://img.shields.io/badge/Gemini_AI-Google_Cloud-%234285F4.svg?style=flat&logo=googlecloud&logoColor=white)
![Status](https://img.shields.io/badge/Status-Live-success)
[![Live Demo](https://img.shields.io/badge/Live-Demo-brightgreen?logo=googlechrome&logoColor=white)](https://kitahack2026-f1f3e.web.app)

[Live Demo](https://kitahack2026-f1f3e.web.app) • [GitHub Repository](https://github.com/EternalEthan06/KitaHack2026-Thon-Thon-Killers)

</div>

---
## 📑 Table of Contents
- [Problem Statement](#-problem-statement)
- [SDG Alignment](#-sdg-alignment)
- [Our Solution -- Ecorise](#-our-solution----ecorise)
- [Key Features](#-key-features)
- [Project Structure](#-project-structure)
- [Setup & Installation](#-setup--installation)
- [Running the App](#-running-the-app)
- [Live Access](#-live-access)
- [Tech Stack](#-tech-stack)
- [Team: Thon Thon Killers](#-team-thon-thon-killers)
- [License](#-license)
---
## Problem Statement
### A) Volunteer Connection Gap
- People want to volunteer but lack a centralized, trusted platform while NGOs struggle to recruit and promote events efficiently.

### B) Daily Motivation Deficit
- SDGs feel abstract and unrewarding. No system tracks or gamifies real-life impact to build lasting habits.

### C) NGO Funding & Visibility Struggle
- NGOs lack high-visibility channels for donations and product sales while needing to compete with commercial algorithms on traditional social media.

---

### **SDG Alignment**
EcoRise is designed to accelerate the **UN Sustainable Development Goals (SDGs)**, specifically focusing on:
*   **SDG 12**: Responsible Consumption and Production.
*   **SDG 13**: Climate Action.
*   **SDG 14/15**: Life Below Water & On Land.

---

## Our Solution -- EcoRise
### 📖 About EcoRise

**EcoRise** is a modern application built to promote sustainable development goals (SDGs) by integrating AI-driven impact analysis, social feeds, and rewarding donation systems. 

EcoRise leverages generative AI to automatically verify and score user activities, ensuring seamless operations even under API restrictions with its self-healing AI architecture. Built by the Thon Thon Killers for the **KitaHack 2026** hackathon.

![Display Demo](image-2.png)

---

## ✨ Key Features

### 📸 Smart Impact Capture & AI Validation
* **Live Camera SDG Posts:** Capture sustainable actions in real-time. Our Gemini AI automatically analyzes the image and awards proportionate SDG Scores based on the environmental impact.
* **Gallery Uploads:** Share moments from your device gallery with the community (Note: Gallery posts are standard posts and bypass AI scoring to ensure authenticity).
* **Self-Healing AI Architecture:** Features a multi-stage AI fallback cycling through `gemini-1.5-flash`, `gemini-pro`, and `gemini-1.5-flash-8b`. Enters a seamless Demo-Safe Mode if all connections drop.

### 🌟 Gamified Sustainability & Rewards
* **Eco-Streaks:** Build consistent green habits. Users earn extra SDG points for maintaining daily action streaks.
* **Rewards Redemption:** Exchange your hard-earned SDG scores for real-world incentives, such as exclusive vouchers or planting actual trees.
* **Rewarding Donations:** Support charities and NGO projects directly through the app, helping fund volunteer programs while earning bonus points.

### 🤝 Community & NGO Ecosystem
* **Social Platform:** A fully-featured social media space uniting the community to share information, communicate, and draw inspiration.
* **Volunteer Hub:** A dedicated space for NGOs to advertise volunteering programs and collaborate with the community.
* **NGO Marketplace:** Support non-profits by purchasing their goods (e.g., handmade tote bags, upcycled crafts) directly through the platform.

### 🛡️ Personalized Eco-Diary
* **Impact Tracking:** Every sustainable act is recorded as a personal diary.
* **AI Recommendations:** The system analyzes your activity preferences to recommend tailored, suitable acts.
* **Dynamic Profile:** Your profile dynamically showcases your eco-diary, highlighting the scores you've earned day by day.

### ⚡ Seamless Performance
* **PWA Ready & Low-Latency:** Install directly from the browser. Employs Base64 image optimization to maximize Firebase efficiency.
* **Persistent State:** High-reliability integrated recovery using `shared_preferences` prevents data loss during camera usage or browser refreshes.

---

## 🛠️ Overview of Technologies Used
### **Google Developer Technologies**
*   **Flutter**: Chosen over alternatives for its **"Write Once, Run Anywhere"** capability, allowing us to build a high-performance PWA and Mobile app from a single codebase.
*   **Firebase Realtime Database (RTDB)**: We switched from Firestore to RTDB to achieve **sub-millisecond synchronization** for our social gamification loops.
*   **Gemini AI (1.5 Flash)**: Chosen for its native **Multimodal SDK** which allows EcoRise to process image bytes faster and more affordably than OpenAI or Llama alternatives.
*   **Firebase Analytics**: integrated to track "Impact Ratios" and user retention across SDG categories.
### **Supporting Tools**
*   **Dart SDK**: Powering the frontend logic.
*   **Google AI Studio**: For rapid prototyping of self-healing prompts.

---


## 🏗️ Implementation Details & Innovation
### **System Architecture**
EcoRise uses a **Decoupled AI Pipeline**. The UI generates a thread for the camera, the AI Service processes the multimodal analysis in the background, and the RTDB triggers a "Push Notification" style update to the UI state without blocking the user.
### **Self-Healing Workflow**
1.  **Stage 1 (Primary)**: Try `gemini-1.5-flash` for high-speed analysis.
2.  **Stage 2 (Fallback)**: If Stage 1 fails, the system attempts `gemini-pro` (Text) or `1.5-flash-8b`.
3.  **Stage 3 (Safety)**: If total API failure occurs, the app enters **Demo Mode** with mock success data to ensure zero user frustration.

---

## ⚠️ Challenges Faced
*   **Architectural Migration**: Moving from Firestore to RTDB required a total rewrite of our [DatabaseService](lib/core/services/firestore_service.dart) to handle flat JSON trees instead of structured collections.
*   **AI Model Incompatibility**: We overcame challenges where older models (Gemini Pro) were unable to handle modern JSON-response configurations used in our newer models.
*   **Web Image Processing**: Browser restrictions on local file paths forced us to innovate using `Uint8List` byte-processing for universal camera support.

---

## 🚀 Live Access

Judges and users can access the fully deployed application here:  
👉 **[https://kitahack2026-f1f3e.web.app](https://kitahack2026-f1f3e.web.app)**

---

## 📂 Project Structure

```text
lib/
├── core/
│   ├── services/     # Self-Healing AI, Firebase Logic, Auth
│   ├── models/       # SDG, Post, NGO, and User Models
│   └── theme/        # EcoRise Neon Design System
│
└── features/
    ├── feed/         # Social For-You & Certified SDG Feeds
    ├── camera/       # AI-driven Impact Analysis
    ├── volunteer/    # NGO Event & Calendar Integration
    └── donate/       # Rewarding Donation System (20x Points)
```

## 🛠️ Setup & Installation

### 1. Prerequisites
* **Flutter SDK**: ≥ 3.3.0 ([Installation Guide](https://docs.flutter.dev/get-started/install))
* **Firebase Account**: App uses Firebase Realtime Database & Firestore.
* **Google AI Studio Key**: For Gemini AI scoring ([Get Key Here](https://aistudio.google.com/app/apikey))

### 2. Getting Started
```bash
# Clone the repository
git clone https://github.com/EternalEthan06/KitaHack2026-Thon-Thon-Killers.git

# Navigate to project
cd KitaHack2026-Thon-Thon-Killers

# Install dependencies
flutter pub get
```

### 3. Environment Configuration
Create a `.env` file in the project root to enable AI features:
```env
GEMINI_API_KEY=your_gemini_api_key_here
```

## 📱 Running the App

### Standard Web Deployment
To launch the app in standard web deployment mode:
```bash
flutter run -d chrome
```

### Mobile Testing (Local Network / Camera Support)
To test high-impact features like the **Live Camera Verification**, use the provided batch file or the command below:
```bash
.\run_mobile.bat
```

---

## 🗺️ Future Roadmap
*   **Google Maps Integration**: Visualizing local "Impact Clusters" to see which Malaysian neighborhoods are making the most change.
*   **NGO Verified Partnerships**: Allowing NGO's to verify actions manually for 2x points.
*   **Eco-Marketplace Expansion**: Real-world voucher redemptions with local green businesses.

## ⚙️ Tech Stack

**Frontend:**
* Flutter
* Dart

**Backend / Tools:**
* Firebase (Realtime Database, Firestore)
* Google Cloud
* Gemini AI API

---

## 🏆 Team: Thon Thon Killers
Built for **KitaHack 2026**.
* **Ethan Tiang Yong Xuan** : Software Engineering
* **Chloe Lai Phui Yan** : Software Engineering
* **Lee Jasmin** : Robotics and Mechatronics Engineering
* **Wong Kai Heng** : Robotics and Mechatronics Engineering

---
## License
Distributed under the MIT License. See `LICENSE` for more information.
