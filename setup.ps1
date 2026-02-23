# SDG Connect - Setup Script
# Run this in PowerShell as Administrator
# Right-click PowerShell → "Run as Administrator" then run: .\setup.ps1

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  SDG Connect - KitaHack 2026 Setup" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# ── Step 0: Refresh PATH ──────────────────────────────────────────────────────
Write-Host "[1/5] Refreshing PATH..." -ForegroundColor Yellow
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# ── Step 1: Check Node.js ──────────────────────────────────────────────────────
Write-Host "[2/5] Checking Node.js..." -ForegroundColor Yellow
$nodeVersion = node --version 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "  ❌ Node.js not found. Please install from https://nodejs.org and re-run this script." -ForegroundColor Red
    exit 1
}
Write-Host "  ✅ Node.js $nodeVersion" -ForegroundColor Green

# ── Step 2: Install Firebase CLI ──────────────────────────────────────────────
Write-Host "[3/5] Installing Firebase CLI..." -ForegroundColor Yellow
npm install -g firebase-tools
if ($LASTEXITCODE -ne 0) {
    Write-Host "  ❌ Firebase CLI install failed." -ForegroundColor Red
    exit 1
}
Write-Host "  ✅ Firebase CLI installed!" -ForegroundColor Green

# ── Step 3: Firebase Login ────────────────────────────────────────────────────
Write-Host "[4/5] Logging in to Firebase (browser will open)..." -ForegroundColor Yellow
firebase login
if ($LASTEXITCODE -ne 0) {
    Write-Host "  ❌ Firebase login failed." -ForegroundColor Red
    exit 1
}
Write-Host "  ✅ Firebase logged in!" -ForegroundColor Green

# ── Step 4: Flutter pub get ───────────────────────────────────────────────────
Write-Host "[5/5] Installing Flutter packages..." -ForegroundColor Yellow
Set-Location "$PSScriptRoot"
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "  ❌ flutter pub get failed." -ForegroundColor Red
    exit 1
}
Write-Host "  ✅ Flutter packages installed!" -ForegroundColor Green

# ── Step 5: FlutterFire Configure ─────────────────────────────────────────────
Write-Host "`n[FINAL] Connecting Flutter to your Firebase project..." -ForegroundColor Yellow
Write-Host "  → Select your Firebase project from the list (e.g. sdg-connect)" -ForegroundColor Gray
Write-Host "  → Select Android (and iOS if needed)`n" -ForegroundColor Gray
flutterfire configure

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "  ✅ Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "`nNext steps:" -ForegroundColor Cyan
Write-Host "  1. Fill in your API keys in .env" -ForegroundColor White
Write-Host "  2. Connect an Android phone or start an emulator" -ForegroundColor White
Write-Host "  3. Run: flutter run" -ForegroundColor White
Write-Host "  4. Run: python seed_firestore.py  (to load demo data)`n" -ForegroundColor White
