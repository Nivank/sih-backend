# Bharat Transliteration App — Flutter Frontend (Web + Android)

## 🔧 Editable UI constants
- Update `lib/utils/config.dart` → `UiConstants.appName`, `UiConstants.supportedScripts`.
- API base URL in `assets/env` (`API_BASE_URL`, optional `USE_NGROK`, `NGROK_URL`).

## Requirements
- Flutter SDK installed and on PATH
- For web: Chrome
- For Android: Android SDK/emulator

## Install deps
```bash
flutter pub get
```

## Run (backend must be running on the same machine)
```bash
# Web
flutter run -d chrome

# Android
flutter run -d emulator-5554
```

## Environment
`assets/env` example:
```
API_BASE_URL=http://localhost:8000
USE_NGROK=false
NGROK_URL=
```

## Android setup
- Add Internet permission (already provided by Flutter).
- Location permissions are requested at runtime via `geolocator`.
- Google Maps SDK: add your API key in `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data android:name="com.google.android.geo.API_KEY" android:value="YOUR_KEY_HERE"/>
```

## Notes on backend API
- Login `POST /auth/login` as x-www-form-urlencoded with `username`, `password`; response `{ access_token }` stored securely.
- Transliteration `POST /transliterate/` JSON `{ source_text, source_script, target_script }`, and `POST /transliterate/image` multipart with `file` + fields.
- Notes `GET /notes/`, `POST /notes/add` JSON `{ text, latitude, longitude }` with `Authorization: Bearer <token>`.

## Troubleshooting
- If CORS issues on web, ensure backend `FRONTEND_ORIGIN` allows your web origin.
- For Android emulator to reach host machine, use `http://10.0.2.2:8000` in `assets/env`.
