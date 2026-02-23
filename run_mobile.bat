@echo off
setlocal enabledelayedexpansion

:: Configuration
set PORT=8080

echo ========================================
echo   SDG Connect - Mobile Web Server
echo ========================================

:: Step 1: Kill any existing process on the port to ensure it's free
echo [1/2] Preparing port %PORT%...
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :%PORT% ^| findstr LISTENING') do taskkill /f /pid %%a >nul 2>&1

:: Step 2: Detect Local IP
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr IPv4') do (
    set IP=%%a
    set IP=!IP:~1!
)

:: Step 3: Save IP to .env for the app to read
echo MOBILE_IP=%IP% >> .env
:: Remove duplicate lines if any (simplified)
powershell -Command "$content = Get-Content .env; $content | Select-Object -Unique | Set-Content .env"

echo [2/2] Starting Flutter Web Server...
echo.
echo   🏠 Access on your mobile devices:
echo   🔗 Local IP: http://%IP%:%PORT%
echo   🔗 Hostname: http://%COMPUTERNAME%.local:%PORT%
echo.
echo ========================================

flutter run -d web-server --web-hostname 0.0.0.0 --web-port %PORT%