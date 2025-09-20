@echo off
REM Bharat Transliteration Flutter App Launcher
REM This script helps setup and run the Flutter app

echo ================================================
echo Bharat Transliteration Flutter App
echo ================================================
echo.

REM Check if Flutter is installed
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Flutter is not installed or not in PATH
    echo.
    echo Please install Flutter first:
    echo https://flutter.dev/docs/get-started/install/windows
    echo.
    pause
    exit /b 1
)

echo ✅ Flutter found
flutter --version
echo.

REM Navigate to frontend directory
cd /d "%~dp0"
if not exist "pubspec.yaml" (
    echo ❌ Could not find pubspec.yaml
    echo Make sure you're running this from the frontend directory
    pause
    exit /b 1
)

echo ✅ In Flutter project directory
echo.

REM Install dependencies
echo 📦 Installing dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo ❌ Failed to install dependencies
    pause
    exit /b 1
)

echo ✅ Dependencies installed
echo.

REM Show options
echo Choose how to run the app:
echo 1. Web (Chrome) - Recommended for quick testing
echo 2. Android (requires emulator or device)
echo 3. Check Flutter setup (flutter doctor)
echo 4. Exit
echo.

set /p choice="Enter your choice (1-4): "

if "%choice%"=="1" (
    echo.
    echo 🌐 Starting app in Chrome...
    echo Backend should be running on configured URL (check assets/env)
    echo.
    flutter run -d chrome
) else if "%choice%"=="2" (
    echo.
    echo 📱 Starting app for Android...
    echo Make sure emulator is running or device is connected
    echo.
    flutter run
) else if "%choice%"=="3" (
    echo.
    echo 🔍 Checking Flutter setup...
    flutter doctor -v
) else if "%choice%"=="4" (
    echo Goodbye!
    exit /b 0
) else (
    echo Invalid choice
)

echo.
pause