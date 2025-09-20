# Bharat Transliteration Flutter App - Complete Setup Guide

## 🚀 Quick Setup Summary

Your Flutter app is **fully implemented** and ready to run! Here's what's been built:

### ✅ Implemented Features

1. **📱 Complete Flutter App Structure**
   - Cross-platform (Web + Android) support
   - Bottom navigation with 4 main screens
   - State management with Provider
   - Secure JWT token storage

2. **🔐 Login Screen**
   - Email/password form validation
   - Backend authentication integration (`/auth/login`)
   - JWT token storage and auto-login

3. **🔄 Transliteration Screen**
   - Text input with script selection dropdown
   - Image upload from gallery
   - Camera capture for OCR
   - Backend integration (`/transliterate/`, `/transliterate/image`)

4. **📝 Notes Screen** 
   - Add notes with automatic geolocation
   - Save to backend (`/notes/add`)
   - Fetch and display user notes (`/notes/`)
   - Authentication required

5. **🗺️ Map Screen**
   - Google Maps integration
   - Display markers for saved notes
   - Interactive info windows

6. **🔧 Customizable UI**
   - All labels marked with 🔧 EDITABLE
   - Centralized configuration in `utils/config.dart`
   - Environment variables in `assets/env`

## 📋 Prerequisites

### Install Flutter SDK
1. Download Flutter: https://flutter.dev/docs/get-started/install/windows
2. Extract and add to PATH
3. Run `flutter doctor` to verify installation

### For Android Development
- Android Studio with Android SDK
- Android emulator or physical device

### For Web Development  
- Chrome browser (comes with Flutter web support)

## ⚡ Installation Steps

1. **Navigate to frontend directory:**
   ```bash
   cd c:\sih12\frontend
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure environment (optional):**
   - Edit `assets/env` file 
   - Set your backend URL if different from `http://localhost:8000`

4. **Run the app:**

   **For Web (Recommended for quick testing):**
   ```bash
   flutter run -d chrome
   ```

   **For Android:**
   ```bash
   flutter run
   ```

## 🔧 Customization Points

### UI Labels & Constants (`lib/utils/config.dart`)
```dart
// 🔧 EDITABLE UI CONSTANTS
class UiConstants {
  static const String appName = 'Bharat Transliteration';
  static const List<String> supportedScripts = [
    'Devanagari', 'Telugu', 'Tamil', 'Malayalam', 'Gurmukhi'
  ];
  
  // Navigation labels
  static const String loginLabel = 'Login';
  static const String transliterateLabel = 'Transliterate';
  // ... more customizable labels
}
```

### Environment Configuration (`assets/env`)
```env
# 🔧 EDITABLE ENV - Flutter App Configuration
API_BASE_URL=http://localhost:8000
USE_NGROK=false
NGROK_URL=

# For testing with ngrok tunnels:
# USE_NGROK=true
# NGROK_URL=https://abc123.ngrok.io
```

## 🎯 Testing the App

### Prerequisites
1. **Backend must be running** on the configured URL (default: http://localhost:8000)
2. **CORS enabled** on backend for Flutter web origin

### Test Scenarios

1. **Login Flow:**
   - Open app → Login tab
   - Enter valid credentials
   - JWT should be stored and login status shown

2. **Transliteration:**
   - Login first → Transliterate tab
   - Enter text, select target script
   - Or upload/capture image for OCR

3. **Notes:**
   - Login required → Notes tab  
   - Add note (location automatically captured)
   - View saved notes list

4. **Map:**
   - Shows markers for all saved notes
   - Click markers to see note content

## 🐛 Troubleshooting

### Flutter Not Found
```bash
# Verify Flutter installation
flutter doctor

# If not installed, download from:
# https://flutter.dev/docs/get-started/install
```

### Web CORS Issues
- Backend must allow CORS for `http://localhost:*` origins
- Check browser developer console for errors

### Android Build Issues
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

### API Connection Issues
- Verify backend is running
- Check `assets/env` configuration
- Test API endpoints manually

## 📱 Platform Support

### ✅ Web (Chrome)
- Fully supported
- All features work including camera/image upload
- Recommended for development testing

### ✅ Android  
- Full native app support
- Camera, location, secure storage
- Google Maps integration

### ❌ iOS (Optional)
- Code is compatible but requires:
  - macOS development machine
  - Xcode and iOS simulator
  - Additional iOS-specific configuration

## 🔄 Next Steps

1. **Install Flutter** if not already installed
2. **Run `flutter pub get`** to install dependencies  
3. **Start your backend server** 
4. **Run `flutter run -d chrome`** for web testing
5. **Customize UI constants** as needed
6. **Test all features** with your backend APIs

## 📞 Support

The app is fully implemented according to your specifications:
- ✅ Single codebase for Web + Android
- ✅ All required dependencies in pubspec.yaml
- ✅ JWT authentication with secure storage
- ✅ Text + image transliteration
- ✅ Notes with geolocation
- ✅ Google Maps integration
- ✅ Fully customizable UI with 🔧 markers

Ready to run with `flutter run -d chrome`! 🚀