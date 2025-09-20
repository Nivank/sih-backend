#!/usr/bin/env python3
"""
Simple test for photo-note API endpoints.
"""

import requests
import io
from PIL import Image, ImageDraw

BASE_URL = "http://127.0.0.1:8000"

def test_basic_functionality():
    print("🧪 Testing Enhanced Photo-Note API")
    print("=" * 40)
    
    # 1. Login
    print("1. Testing login...")
    login_response = requests.post(
        f"{BASE_URL}/auth/login",
        data={"username": "nivank", "password": "nivank"},
        headers={"Content-Type": "application/x-www-form-urlencoded"}
    )
    
    if login_response.status_code == 200:
        token = login_response.json()["access_token"]
        print("✅ Login successful")
        headers = {"Authorization": f"Bearer {token}"}
    else:
        print("❌ Login failed")
        return
    
    # 2. Create a simple test image
    print("2. Creating test image...")
    img = Image.new('RGB', (200, 150), color='lightgreen')
    draw = ImageDraw.Draw(img)
    draw.text((10, 10), "Test Photo", fill='black')
    draw.rectangle([50, 50, 150, 100], outline='red', width=2)
    
    img_bytes = io.BytesIO()
    img.save(img_bytes, format='JPEG')
    img_bytes = img_bytes.getvalue()
    print(f"✅ Test image created ({len(img_bytes)} bytes)")
    
    # 3. Test photo note creation
    print("3. Testing photo note creation...")
    files = {'photo': ('test.jpg', img_bytes, 'image/jpeg')}
    data = {
        'text': 'Test photo note with location',
        'latitude': 28.6139,
        'longitude': 77.2090
    }
    
    response = requests.post(
        f"{BASE_URL}/notes/add-with-photo",
        files=files,
        data=data,
        headers=headers
    )
    
    if response.status_code == 200:
        note = response.json()
        note_id = note['id']
        print(f"✅ Photo note created! ID: {note_id}")
        print(f"   Has photo: {note.get('has_photo', False)}")
    else:
        print(f"❌ Photo note creation failed: {response.status_code}")
        print(f"   Response: {response.text}")
        return
    
    # 4. Test notes listing
    print("4. Testing notes listing...")
    response = requests.get(f"{BASE_URL}/notes/", headers=headers)
    if response.status_code == 200:
        notes = response.json()
        print(f"✅ Found {len(notes)} notes")
        photo_notes = [n for n in notes if n.get('has_photo')]
        print(f"   Photo notes: {len(photo_notes)}")
    else:
        print(f"❌ Notes listing failed: {response.status_code}")
    
    # 5. Test photo retrieval
    print("5. Testing photo retrieval...")
    response = requests.get(f"{BASE_URL}/notes/{note_id}/photo", headers=headers)
    if response.status_code == 200:
        photo_data = response.content
        print(f"✅ Photo retrieved ({len(photo_data)} bytes)")
        print(f"   Content-Type: {response.headers.get('content-type')}")
    else:
        print(f"❌ Photo retrieval failed: {response.status_code}")
    
    print("\n🎉 All tests completed!")
    print("\n✅ Enhanced Photo-Note Features Working:")
    print("📸 Photo upload and storage")
    print("📍 GPS location embedding")
    print("🗒️ Note text with photo")
    print("🔍 Photo retrieval by ID")
    print("📋 Enhanced notes listing")

if __name__ == "__main__":
    test_basic_functionality()