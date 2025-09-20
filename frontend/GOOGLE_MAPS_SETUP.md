# Google Maps Setup Guide for Flutter Web

## Step 1: Get Google Maps API Key

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing project
3. Enable the following APIs:
   - Maps JavaScript API
   - Geocoding API (optional, for address lookup)
   - Places API (optional, for place search)

4. Create API Key:
   - Go to "Credentials" > "Create Credentials" > "API Key"
   - Copy your API key
   - Restrict the API key for security:
     - Application restrictions: HTTP referrers (web sites)
     - Website restrictions: Add your domain (e.g., localhost:5174 for development)
     - API restrictions: Select "Restrict key" and choose the APIs you enabled

## Step 2: Configure API Key for Flutter Web

### Option A: Environment Variable (Recommended)
Add to `frontend/assets/env`:
```
GOOGLE_MAPS_API_KEY=your_api_key_here
```

### Option B: Direct Configuration
Add to `frontend/web/index.html` before `</head>`:
```html
<script src="https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY"></script>
```

## Step 3: Enable Google Maps in Flutter

1. Uncomment in `pubspec.yaml`:
```yaml
dependencies:
  google_maps_flutter: ^2.9.0
  google_maps_flutter_web: ^0.5.10
```

2. Run:
```bash
flutter pub get
```

3. In `map_screen_google.dart`, uncomment all Google Maps code sections

## Step 4: Security Best Practices

1. **API Key Restrictions**: Always restrict your API key to specific domains
2. **Environment Variables**: Never commit API keys to version control
3. **Billing Alerts**: Set up billing alerts in Google Cloud Console
4. **Usage Quotas**: Monitor API usage to avoid unexpected charges

## Step 5: Testing

1. Start your Flutter app with hot reload enabled
2. Navigate to the Map screen
3. Select "Google Maps" option
4. Verify that the map loads correctly with markers for your notes

## Troubleshooting

### Common Issues:

1. **"Maps JavaScript API error: InvalidKeyMapError"**
   - Check if API key is correct
   - Verify Maps JavaScript API is enabled
   - Check domain restrictions

2. **"Cannot read properties of undefined (reading 'maps')"**
   - Ensure Google Maps script is loaded before Flutter app
   - Check network connectivity

3. **Map shows gray area**
   - Check API key permissions
   - Verify billing is enabled for the project

### Development vs Production

- **Development**: Use localhost restrictions
- **Production**: Update restrictions to your actual domain
- Consider using different API keys for different environments

## Cost Considerations

Google Maps pricing (as of 2024):
- Maps JavaScript API: $7 per 1,000 requests
- First $200/month is free (Google Cloud credits)
- Monitor usage in Google Cloud Console

## Alternative Solutions

If you prefer free alternatives:
- ✅ OpenStreetMap (already implemented)
- MapBox (has free tier)
- Leaflet with various tile providers
- Apple Maps (iOS only)

---

**Note**: This app already includes OpenStreetMap implementation which works without any API keys and provides similar functionality.