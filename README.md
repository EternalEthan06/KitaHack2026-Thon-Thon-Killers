# 🌱 SDG Connect — KitaHack 2026

A high-performance social impact platform built with **Flutter**, **Firebase**, and **Gemini AI**. Designed to gamify UN Sustainable Development Goals (SDGs) for **KitaHack 2026**.

---

## 🚀 Quick Start (For Developers)

### 1. Prerequisites
- **Flutter SDK**: ≥ 3.19 ([Installation Guide](https://docs.flutter.dev/get-started/install))
- **Firebase Account**: (Spark/Free Plan is sufficient)
- **Google AI Studio Key**: For Gemini AI scoring ([Get Key Here](https://aistudio.google.com/app/apikey))

### 2. Installation
```bash
# Clone the repository
git clone https://github.com/EternalEthan06/KitaHack2026-Thon-Thon-Killers.git

# Navigate to the project
cd "KitaHack2026-Thon-Thon-Killers/Hackathon/Kitahack 26'/sdg_app"

# Install dependencies
flutter pub get
```

### 3. Environment Setup
Create a `.env` file in the project root:
```env
GEMINI_API_KEY=your_gemini_api_key_here
```

---

## 📱 Running the App

### Standard Web (Desktop)
```bash
flutter run -d chrome
```

### Mobile Testing (Local Network)
If you want to test the **Camera** and **Story** features on your actual phone, use our auto-detect command (Windows PowerShell):

```powershell
$ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.AddressState -eq 'Preferred' -and $_.InterfaceAlias -notmatch 'Loopback|Virtual|vEthernet'} | Select-Object -First 1).IPAddress; Write-Host "`n📱 MOBILE ACCESS: http://$($ip):8080`n" -ForegroundColor Cyan; flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080
```
*Or simply run `.\run_mobile.bat` if you are on Windows.*

---

## 🛠️ Specialized Technical Features

### 💎 Hackathon-Free Mode (Base64 Storage)
To remain compatible with the **Firebase Spark (Free) Plan**, this app does not require a paid "Blaze" plan for storage. 
- Captured images are converted to **Base64** strings.
- Stored directly in **Firestore documents**.
- Optimized at **512px** to stay well within the 1MB Firestore limit.

### 🛡️ Crash-Proof Session Recovery
Mobile browsers (Chrome/Safari) often refresh the page after the camera closes to save RAM. 
- Integrated **Persistent State Recovery** using `shared_preferences`.
- Automatically restores your photo and caption if the browser reloads.
- Seamlessly redirects you back to the upload screen so you never lose your progress.

### 🤖 Gemini-Powered SDG Scoring
- Automatic image analysis using **Gemini 1.5 Flash**.
- Maps user activities to specific UN Sustainable Development Goals.
- Dynamic point awarding based on "Impact Relevance."

---

## 📂 Project Architecture

```
lib/
├── core/
│   ├── services/     # AI (Gemini), Database (Firestore), Auth
│   ├── models/       # Type-safe data structures
│   └── router/       # GoRouter with refresh-resilient redirects
├── features/
│   ├── feed/         # Story Bar + Main Impact Feed
│   ├── camera/       # AI-integrated capture system
│   ├── volunteer/    # NGO Event management
│   └── marketplace/  # Reward redemption system
└── shared/
    └── theme/        # Premium SDG-themed design system
```

---

## 🏆 Team: Thon Thon Killers
Built with ❤️ for **KitaHack 2026**.
- **Ethan Tiang**
- **Chloe Lai Phui Yan**
- **Lee Jasmin**
- **Wong Kai Heng**
- Powered by **Google Cloud** & **Flutter**
