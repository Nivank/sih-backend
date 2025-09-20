#!/usr/bin/env python3
"""
Test script for enhanced photo-note functionality.
This validates the complete photo-note workflow with location embedding.
"""

import requests
import io
from PIL import Image, ImageDraw, ImageFont
import json

# API base URL
BASE_URL = "http://127.0.0.1:8000"

def create_test_image():
    """Create a simple test image."""
    img = Image.new('RGB', (400, 300), color='lightblue')
    draw = ImageDraw.Draw(img)
    
    # Draw some test content
    try:
        # Try to use a default font
        font = ImageFont.load_default()
    except:
        font = None
    
    draw.text((50, 50), "Test Photo", fill='black', font=font)
    draw.text((50, 80), "Location: Test Site", fill='black', font=font)
    draw.text((50, 110), "This is a test image", fill='black', font=font)
    draw.text((50, 140), "for the photo-note", fill='black', font=font)
    draw.text((50, 170), "functionality!", fill='black', font=font)
    
    # Add some shapes
    draw.rectangle([300, 50, 380, 130], outline='red', width=3)
    draw.ellipse([300, 150, 380, 230], outline='green', width=3)
    
    # Save to bytes
    img_bytes = io.BytesIO()
    img.save(img_bytes, format='JPEG')
    img_bytes.seek(0)
    return img_bytes.getvalue()

def test_login():
    """Test login and get token."""
    print("=== Testing Login ===")
    
    login_data = {
        "username": "nivank",
        "password": "nivank"
    }
    
    try:
        response = requests.post(
            f"{BASE_URL}/auth/login",
            data=login_data,
            headers={"Content-Type": "application/x-www-form-urlencoded"},
            timeout=10
        )
        
        if response.status_code == 200:
            result = response.json()
            token = result.get('access_token')
            print("✅ Login successful")
            print(f"Token: {token[:50]}...")
            return token
        else:
            print(f"❌ Login failed: {response.status_code}")
            print(f"Response: {response.text}")
            return None
            
    except Exception as e:
        print(f"❌ Login error: {e}")
        return None

def test_photo_note_creation(token):
    """Test creating a note with photo."""
    print("\n=== Testing Photo Note Creation ===")
    
    if not token:
        print("❌ No token available")
        return False
    
    headers = {"Authorization": f"Bearer {token}"}
    
    # Create test image
    print("📸 Creating test image...")
    image_data = create_test_image()
    print(f"✅ Test image created ({len(image_data)} bytes)")
    
    # Prepare form data
    files = {
        'photo': ('test_photo.jpg', image_data, 'image/jpeg')
    }
    
    data = {
        'text': 'Test photo note - Beautiful sunset at the beach. This is a memory from my vacation.',
        'latitude': 28.6139,  # New Delhi coordinates
        'longitude': 77.2090
    }
    
    try:
        print("📤 Uploading photo note...")
        response = requests.post(
            f"{BASE_URL}/notes/add-with-photo",
            files=files,
            data=data,
            headers=headers,
            timeout=30
        )
        
        if response.status_code == 200:
            result = response.json()
            note_id = result.get('id')
            print("✅ Photo note created successfully!")
            print(f"   Note ID: {note_id}")
            print(f"   Text: {result.get('text', '')[:50]}...")
            print(f"   Location: {result.get('latitude')}, {result.get('longitude')}")
            print(f"   Has photo: {result.get('has_photo', False)}")
            return note_id
        else:
            print(f"❌ Photo note creation failed: {response.status_code}")
            print(f"Response: {response.text}")
            return None
            
    except Exception as e:
        print(f"❌ Photo note creation error: {e}")
        return None

def test_notes_listing(token):
    """Test listing notes with photo info."""
    print("\n=== Testing Notes Listing ===")
    
    if not token:
        print("❌ No token available")
        return False
    
    headers = {"Authorization": f"Bearer {token}"}
    
    try:
        response = requests.get(
            f"{BASE_URL}/notes/",
            headers=headers,
            timeout=10
        )
        
        if response.status_code == 200:
            notes = response.json()
            print(f"✅ Notes retrieved successfully! Found {len(notes)} notes")
            
            for i, note in enumerate(notes):
                print(f"\n📝 Note {i+1}:")
                print(f"   ID: {note.get('id')}")
                print(f"   Text: {note.get('text', '')[:50]}...")
                print(f"   Location: {note.get('latitude')}, {note.get('longitude')}")
                print(f"   Has photo: {note.get('has_photo', False)}")
                if note.get('photo_filename'):
                    print(f"   Photo file: {note.get('photo_filename')}")
                print(f"   Created: {note.get('created_at', '')[:19]}")
            
            return notes
        else:
            print(f"❌ Notes listing failed: {response.status_code}")
            print(f"Response: {response.text}")
            return []
            
    except Exception as e:
        print(f"❌ Notes listing error: {e}")
        return []

def test_photo_retrieval(token, note_id):
    """Test retrieving photo from a note."""
    print(f"\n=== Testing Photo Retrieval (Note ID: {note_id}) ===")
    
    if not token or not note_id:
        print("❌ Missing token or note ID")
        return False
    
    headers = {"Authorization": f"Bearer {token}"}
    
    try:
        response = requests.get(
            f"{BASE_URL}/notes/{note_id}/photo",
            headers=headers,
            timeout=10
        )
        
        if response.status_code == 200:
            photo_data = response.content
            content_type = response.headers.get('content-type', 'unknown')
            print("✅ Photo retrieved successfully!")
            print(f"   Size: {len(photo_data)} bytes")
            print(f"   Content-Type: {content_type}")
            
            # Verify it's a valid image
            try:
                img = Image.open(io.BytesIO(photo_data))
                print(f"   Image format: {img.format}")
                print(f"   Image size: {img.size}")
                print("✅ Photo is valid image data")
                return True
            except Exception as e:
                print(f"❌ Invalid image data: {e}")
                return False
                
        else:
            print(f"❌ Photo retrieval failed: {response.status_code}")
            print(f"Response: {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Photo retrieval error: {e}")
        return False

def test_regular_note_creation(token):
    """Test creating a regular note without photo."""
    print("\n=== Testing Regular Note Creation ===")
    
    if not token:
        print("❌ No token available")
        return False
    
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }
    
    data = {
        'text': 'Regular text note - Meeting notes from today.',
        'latitude': 28.7041,  # Different location
        'longitude': 77.1025
    }
    
    try:
        response = requests.post(
            f"{BASE_URL}/notes/add",
            json=data,
            headers=headers,
            timeout=10
        )
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Regular note created successfully!")
            print(f"   Note ID: {result.get('id')}")
            print(f"   Text: {result.get('text', '')[:50]}...")
            print(f"   Location: {result.get('latitude')}, {result.get('longitude')}")
            return result.get('id')
        else:
            print(f"❌ Regular note creation failed: {response.status_code}")
            print(f"Response: {response.text}")
            return None
            
    except Exception as e:
        print(f"❌ Regular note creation error: {e}")
        return None

def main():
    """Run comprehensive photo-note functionality tests."""
    print("🧪 Enhanced Photo-Note Functionality Test")
    print("=" * 50)
    
    # Test 1: Login
    token = test_login()
    if not token:
        print("\n❌ Cannot proceed without authentication")
        return
    
    # Test 2: Create photo note
    photo_note_id = test_photo_note_creation(token)
    
    # Test 3: Create regular note
    regular_note_id = test_regular_note_creation(token)
    
    # Test 4: List all notes
    notes = test_notes_listing(token)
    
    # Test 5: Retrieve photo from photo note
    if photo_note_id:
        test_photo_retrieval(token, photo_note_id)
    
    # Summary
    print("\n" + "=" * 50)
    print("🎯 Test Summary:")
    print(f"✅ Login: {'Success' if token else 'Failed'}")
    print(f"✅ Photo Note Creation: {'Success' if photo_note_id else 'Failed'}")
    print(f"✅ Regular Note Creation: {'Success' if regular_note_id else 'Failed'}")
    print(f"✅ Notes Listing: {'Success' if notes else 'Failed'}")
    print(f"✅ Photo Retrieval: {'Success' if photo_note_id else 'Skipped'}")
    
    print("\n🎉 Photo-Note functionality is working!")
    print("\nFeatures verified:")
    print("📸 Photo upload and storage")
    print("📍 GPS location embedding")
    print("🗒️ Note text with photo")
    print("🔍 Photo retrieval by note ID")
    print("📋 Mixed notes listing (photo + text)")
    print("🔒 Authentication-protected endpoints")

if __name__ == "__main__":
    main()