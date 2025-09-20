# Bharat Transliteration - Flutter Frontend

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)](https://dart.dev)

Cross-platform Flutter application for the Bharat Transliteration API, supporting both web and mobile platforms.

## Features

- **🔐 Authentication**: Secure JWT-based login with token storage
- **📝 Text Transliteration**: Convert text between multiple Indic scripts
- **📷 Image OCR**: Extract and transliterate text from images
- **📍 Location Notes**: Create and view location-tagged notes
- **🗺️ Map Integration**: Interactive map with Google Maps
- **🌐 Cross-Platform**: Works on web browsers and mobile devices

## Quick Start

### Prerequisites
- Flutter 3.0+
- Dart 3.0+
- Backend API running on `http://localhost:8000`

### Installation

1. **Install dependencies**
   ```bash
   flutter pub get
   ```

2. **Configure environment**
   - Edit `assets/env` to set API endpoint
   - Default configuration points to `http://localhost:8000`

3. **Run the application**
   ```bash
   # Web browser
   flutter run -d chrome
   
   # Android device/emulator
   flutter run -d android
   
   # iOS device/simulator (macOS only)
   flutter run -d ios
   ```

## Configuration

### Environment Settings (`assets/env`)

```
API_BASE_URL=http://localhost:8000
USE_NGROK=false
NGROK_URL=
```

### Test Credentials

- **User 1**: Email: `nivank`, Password: `nivank`
- **User 2**: Email: `nivank2`, Password: `nivank2`

## Application Structure

```
lib/
├── main.dart              # Application entry point
├── screens/               # UI screens
│   ├── login_screen.dart      # Authentication
│   ├── transliteration_screen.dart  # Text conversion
│   ├── notes_screen.dart      # Notes management
│   └── map_screen.dart        # Map view
├── services/              # API and external services
│   └── api_client.dart        # HTTP client wrapper
├── state/                 # State management
│   └── auth_state.dart        # Authentication state
└── utils/                 # Utilities
    └── config.dart            # App configuration
```

## Dependencies

### Core Dependencies
- `http` - HTTP client for API communication
- `provider` - State management
- `flutter_secure_storage` - Secure token storage

### Feature Dependencies
- `camera` - Camera access for OCR
- `image_picker` - Image selection
- `google_maps_flutter` - Map integration
- `geolocator` - Location services
- `flutter_dotenv` - Environment configuration

## Development

### Code Style
- Uses `flutter_lints` for code analysis
- Follows Dart/Flutter conventions
- Material Design 3 components

### Building

```bash
# Development build
flutter run --debug

# Release build for web
flutter build web

# Release build for Android
flutter build apk
```

### Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/
```

## Platform Support

| Platform | Status | Notes |
|----------|--------:|-------|
| **Web** | ✅ | Primary platform, full functionality |
| **Android** | ✅ | Full native support |
| **iOS** | ✅ | Requires macOS for development |
| **Windows** | ⚠️ | Limited testing |
| **macOS** | ⚠️ | Limited testing |
| **Linux** | ⚠️ | Limited testing |

## Troubleshooting

### Common Issues

**Authentication Errors (401)**
- Ensure backend is running on correct port
- Check API base URL in `assets/env`
- Verify login credentials
- Clear app data and re-login

**Network Errors**
- Check internet connectivity
- Verify backend server is accessible
- Review CORS configuration on backend

**Camera/Gallery Issues**
- Grant camera permissions
- Grant storage permissions
- Check device compatibility

### Debug Mode

The app includes debug information in the login screen showing:
- Current API base URL
- Authentication status
- Token availability

## Contributing

1. Follow Flutter/Dart style guidelines
2. Add tests for new features
3. Update documentation
4. Test on multiple platforms

## License

MIT License - see the main project LICENSE file.