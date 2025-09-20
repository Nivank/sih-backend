#!/usr/bin/env python3
"""Manual test for photo note functionality."""

import requests
import json

# Test the backend photo API manually
BASE_URL = "http://127.0.0.1:8000"

print("Testing photo note backend...")

# 1. Login
print("1. Login...")
response = requests.post(f"{BASE_URL}/auth/login", 
    data={"username": "nivank", "password": "nivank"},
    headers={"Content-Type": "application/x-www-form-urlencoded"})

if response.status_code == 200:
    token = response.json()["access_token"]
    print(f"✅ Login OK - Token: {token[:20]}...")
else:
    print(f"❌ Login failed: {response.status_code}")
    exit(1)

# 2. Create a test image
print("2. Creating simple test image...")
test_image = b'\xff\xd8\xff\xe0\x00\x10JFIF\x00\x01\x01\x01\x00H\x00H\x00\x00\xff\xdb\x00C\x00\x08\x06\x06\x07\x06\x05\x08\x07\x07\x07\t\t\x08\n\x0c\x14\r\x0c\x0b\x0b\x0c\x19\x12\x13\x0f\x14\x1d\x1a\x1f\x1e\x1d\x1a\x1c\x1c $.\' ",#\x1c\x1c(7),01444\x1f\'9=82<.342\xff\xc0\x00\x11\x08\x00\x01\x00\x01\x01\x01\x11\x00\x02\x11\x01\x03\x11\x01\xff\xc4\x00\x14\x00\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x08\xff\xc4\x00\x14\x10\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xff\xda\x00\x0c\x03\x01\x00\x02\x11\x03\x11\x00\x3f\x00\x00\xff\xd9'

# 3. Test photo note creation
print("3. Testing photo upload...")
files = {'photo': ('test.jpg', test_image, 'image/jpeg')}
data = {
    'text': 'Manual test photo note',
    'latitude': 28.6139,
    'longitude': 77.2090
}

response = requests.post(f"{BASE_URL}/notes/add-with-photo", 
    files=files, data=data,
    headers={"Authorization": f"Bearer {token}"})

if response.status_code == 200:
    note = response.json()
    print(f"✅ Photo note created! ID: {note['id']}")
    print(f"   Text: {note['text']}")
    print(f"   Location: {note['latitude']}, {note['longitude']}")
    
    # 4. Test photo retrieval
    print("4. Testing photo retrieval...")
    response = requests.get(f"{BASE_URL}/notes/{note['id']}/photo",
        headers={"Authorization": f"Bearer {token}"})
    
    if response.status_code == 200:
        print(f"✅ Photo retrieved! Size: {len(response.content)} bytes")
        print(f"   Content-Type: {response.headers.get('content-type')}")
    else:
        print(f"❌ Photo retrieval failed: {response.status_code}")
else:
    print(f"❌ Photo upload failed: {response.status_code}")
    print(f"   Response: {response.text}")

print("\n🎉 Manual backend test completed!")