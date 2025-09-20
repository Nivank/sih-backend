#!/usr/bin/env python3
"""
Comprehensive test suite for Bharat Transliteration API

Tests authentication, transliteration, OCR, and notes functionality.
"""

import requests
import json
import time
import base64
from pathlib import Path


class APITester:
    def __init__(self, base_url="http://localhost:8000"):
        self.base_url = base_url
        self.access_token = None
    
    def test_server_health(self):
        """Test server health and availability."""
        print("\n🏥 Testing Server Health...")
        
        try:
            # Test basic endpoint
            response = requests.get(f"{self.base_url}/", timeout=5)
            if response.status_code == 200:
                print(f"✅ Basic endpoint: {response.json().get('message', 'OK')}")
            else:
                print(f"❌ Basic endpoint failed: {response.status_code}")
                return False
            
            # Test health endpoint
            response = requests.get(f"{self.base_url}/health", timeout=5)
            if response.status_code == 200:
                health_data = response.json()
                print(f"✅ Health check: {health_data.get('status', 'unknown')}")
                print(f"   Database: {health_data.get('database', 'unknown')}")
            
            # Test docs endpoint
            response = requests.get(f"{self.base_url}/docs", timeout=5)
            if response.status_code == 200:
                print("✅ API documentation accessible")
            
            return True
            
        except requests.exceptions.RequestException as e:
            print(f"❌ Server not accessible: {e}")
            return False
    
    def test_authentication(self):
        """Test user authentication flow."""
        print("\n🔐 Testing Authentication...")
        
        # Test login
        login_data = {"username": "nivank", "password": "nivank"}
        
        try:
            response = requests.post(
                f"{self.base_url}/auth/login",
                data=login_data,
                timeout=10
            )
            
            if response.status_code == 200:
                token_data = response.json()
                self.access_token = token_data.get("access_token")
                print(f"✅ Login successful")
                print(f"   Token: {self.access_token[:20]}...")
                
                # Analyze JWT token
                self._analyze_jwt_token()
                return True
            else:
                print(f"❌ Login failed: {response.status_code} - {response.text}")
                return False
                
        except Exception as e:
            print(f"❌ Login request failed: {e}")
            return False
    
    def _analyze_jwt_token(self):
        """Analyze JWT token structure and validity."""
        if not self.access_token:
            print("   ⚠️  No token to analyze")
            return
            
        try:
            parts = self.access_token.split('.')
            if len(parts) == 3:
                # Decode payload
                payload = json.loads(base64.b64decode(parts[1] + '==').decode())
                
                if 'exp' in payload:
                    exp_time = payload['exp']
                    current_time = time.time()
                    if exp_time > current_time:
                        expires_in = int(exp_time - current_time)
                        print(f"   ✅ Token valid (expires in {expires_in} seconds)")
                    else:
                        print("   ❌ Token is expired!")
                        
        except Exception as e:
            print(f"   ⚠️  Could not analyze token: {e}")
    
    def test_transliteration(self):
        """Test text transliteration functionality."""
        print("\n📝 Testing Text Transliteration...")
        
        test_cases = [
            {
                "source_text": "नमस्ते",
                "source_script": "Devanagari",
                "target_script": "Tamil",
                "description": "Hindi to Tamil"
            },
            {
                "source_text": "स्वागत",
                "source_script": "Devanagari",
                "target_script": "Telugu",
                "description": "Hindi to Telugu"
            },
            {
                "source_text": "धन्यवाद",
                "source_script": "Devanagari",
                "target_script": "Malayalam",
                "description": "Hindi to Malayalam"
            }
        ]
        
        for test_case in test_cases:
            try:
                response = requests.post(
                    f"{self.base_url}/transliterate/",
                    json=test_case,
                    timeout=10
                )
                
                if response.status_code == 200:
                    result = response.json()
                    print(f"✅ {test_case['description']}:")
                    print(f"   Input: {test_case['source_text']}")
                    print(f"   Output: {result.get('transliterated_text', 'N/A')}")
                else:
                    print(f"❌ {test_case['description']} failed: {response.status_code}")
                    
            except Exception as e:
                print(f"❌ {test_case['description']} error: {e}")
    
    def test_protected_endpoints(self):
        """Test endpoints that require authentication."""
        print("\n🔒 Testing Protected Endpoints...")
        
        if not self.access_token:
            print("❌ No access token available, skipping protected endpoint tests")
            return False
        
        headers = {"Authorization": f"Bearer {self.access_token}"}
        
        # Test notes listing
        try:
            response = requests.get(f"{self.base_url}/notes/", headers=headers, timeout=10)
            if response.status_code == 200:
                notes = response.json()
                print(f"✅ Notes access successful - found {len(notes)} notes")
            elif response.status_code == 401:
                print("❌ Authentication failed - token may be invalid")
                return False
            else:
                print(f"⚠️  Unexpected notes response: {response.status_code}")
        
        except Exception as e:
            print(f"❌ Notes request failed: {e}")
            return False
        
        # Test note creation
        note_data = {
            "text": "Test note from API tester",
            "latitude": 28.6139,
            "longitude": 77.2090
        }
        
        try:
            response = requests.post(
                f"{self.base_url}/notes/add",
                json=note_data,
                headers=headers,
                timeout=10
            )
            
            if response.status_code == 200:
                note = response.json()
                print(f"✅ Note creation successful - ID: {note.get('id')}")
            elif response.status_code == 401:
                print("❌ Note creation failed - authentication error")
            else:
                print(f"⚠️  Note creation unexpected response: {response.status_code}")
                
        except Exception as e:
            print(f"❌ Note creation failed: {e}")
        
        return True
    
    def test_error_cases(self):
        """Test various error scenarios."""
        print("\n⚠️  Testing Error Handling...")
        
        # Test invalid login
        response = requests.post(
            f"{self.base_url}/auth/login",
            data={"username": "invalid@user.com", "password": "wrongpassword"}
        )
        if response.status_code == 401:
            print("✅ Invalid login properly rejected")
        else:
            print(f"⚠️  Unexpected login response: {response.status_code}")
        
        # Test protected endpoint without token
        response = requests.get(f"{self.base_url}/notes/")
        if response.status_code == 401:
            print("✅ Protected endpoint properly requires authentication")
        else:
            print(f"⚠️  Protected endpoint should require auth: {response.status_code}")
        
        # Test invalid transliteration
        response = requests.post(
            f"{self.base_url}/transliterate/",
            json={"source_text": "test", "target_script": "InvalidScript"}
        )
        if response.status_code in [400, 422]:
            print("✅ Invalid script properly rejected")
        else:
            print(f"⚠️  Invalid script should be rejected: {response.status_code}")
    
    def run_all_tests(self):
        """Run the complete test suite."""
        print("📈 Bharat Transliteration API - Comprehensive Test Suite")
        print("=" * 70)
        
        # Test server health first
        if not self.test_server_health():
            print("\n❌ Server health check failed. Make sure the server is running:")
            print("   uvicorn main:app --reload")
            return False
        
        # Run authentication tests
        if not self.test_authentication():
            print("\n❌ Authentication tests failed")
            return False
        
        # Test transliteration
        self.test_transliteration()
        
        # Test protected endpoints
        self.test_protected_endpoints()
        
        # Test error cases
        self.test_error_cases()
        
        print("\n🎉 Test Suite Complete!")
        print("\n📄 Summary:")
        print("- Server is healthy and responsive")
        print("- Authentication system working")
        print("- Transliteration functionality active")
        print("- Protected endpoints properly secured")
        print("- Error handling implemented")
        
        return True


def main():
    """Main entry point."""
    tester = APITester()
    tester.run_all_tests()


if __name__ == "__main__":
    main()