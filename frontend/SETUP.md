# Bharat Transliteration Flutter App Setup

## Prerequisites
- Flutter SDK installed (https://flutter.dev/docs/get-started/install)
- For Android: Android Studio with Android SDK
- For Web: Chrome browser

## Quick Start

1. **Install Dependencies**
   ```bash
   cd frontend
   flutter pub get
   ```

2. **Configure Environment**
   - Edit `assets/env` file with your backend API URL
   - For local development, keep `API_BASE_URL=http://localhost:8000`
   - For ngrok testing, set `USE_NGROK=true` and provide `NGROK_URL`

3. **Run the App**

   **For Web:**
   ```bash
   flutter run -d chrome
   ```

   **For Android (with emulator/device connected):**
   ```bash
   flutter run
   ```

## 🔧 Customization Guide

### UI Constants (lib/utils/config.dart)
- `appName`: App title in navigation
- `supportedScripts`: Available transliteration scripts
- `loginLabel`, `transliterateLabel`, etc.: Navigation labels
- Button labels and messages throughout the app

### Environment Variables (assets/env)
- `API_BASE_URL`: Your backend server URL
- `USE_NGROK`: Toggle for ngrok tunnel usage
- `NGROK_URL`: Your ngrok tunnel URL

## Features Implemented

✅ **Login Screen**
- Email/password form with validation
- JWT token storage in secure storage
- Auto-login on app restart

✅ **Transliteration Screen** 
- Text input with script selection dropdown
- Image upload from gallery
- Camera capture for OCR
- Loading indicators and error handling

✅ **Notes Screen**
- Add notes with automatic geolocation
- View saved notes list
- Pull-to-refresh functionality
- Authentication required

✅ **Map Screen**
- Google Maps integration
- Markers for saved notes
- Info windows with note text

✅ **Navigation**
- Bottom navigation between screens
- Consistent UI with editable labels

## Backend Integration

The app connects to these API endpoints:
- `POST /auth/login` - User authentication
- `POST /transliterate/` - Text transliteration
- `POST /transliterate/image` - Image OCR + transliteration
- `GET /notes/` - Fetch user notes
- `POST /notes/add` - Add new note with location

## Troubleshooting

**Web Issues:**
- Ensure CORS is configured on backend for localhost:xxxxx
- Check browser developer console for errors

**Android Issues:**
- Verify permissions in AndroidManifest.xml
- For maps: Ensure Google Maps API key is configured
- For camera: Check camera permissions

**API Connection:**
- Verify backend is running on configured URL
- Check network connectivity
- Validate JWT token storage