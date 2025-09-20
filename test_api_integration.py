#!/usr/bin/env python3
"""
Comprehensive API Integration Test for Word Meaning Interpretation
This test validates the transliteration API with enhanced word meaning functionality.
"""

import requests
import json

# API base URL
BASE_URL = "http://127.0.0.1:8000"

def test_transliteration_with_meaning():
    """Test transliteration endpoint with word meaning interpretation"""
    
    test_cases = [
        {
            "input": {
                "source_text": "नमस्ते",
                "source_script": "Devanagari", 
                "target_script": "IAST"
            },
            "expected_transliteration": "namaste",
            "expected_meaning_contains": "Hello/Greetings"
        },
        {
            "input": {
                "source_text": "धन्यवाद",
                "source_script": "Devanagari",
                "target_script": "IAST"
            },
            "expected_transliteration": "dhanyavāda",
            "expected_meaning_contains": "Thank you"
        },
        {
            "input": {
                "source_text": "प्रेम",
                "source_script": "Devanagari",
                "target_script": "IAST"
            },
            "expected_transliteration": "prema",
            "expected_meaning_contains": "Love"
        },
        {
            "input": {
                "source_text": "ज्ञान",
                "source_script": "Devanagari",
                "target_script": "IAST"
            },
            "expected_transliteration": "jñāna",
            "expected_meaning_contains": "Knowledge"
        }
    ]
    
    print("=== API Integration Test for Word Meaning Interpretation ===\n")
    
    for i, test_case in enumerate(test_cases, 1):
        print(f"Test Case {i}: {test_case['input']['source_text']}")
        print(f"Input: {test_case['input']}")
        
        try:
            # Make API request
            response = requests.post(
                f"{BASE_URL}/transliterate/",
                headers={"Content-Type": "application/json"},
                json=test_case['input'],
                timeout=10
            )
            
            if response.status_code == 200:
                result = response.json()
                print(f"✅ API call successful")
                print(f"Response: {json.dumps(result, ensure_ascii=False, indent=2)}")
                
                # Check transliteration result
                if 'transliteration' in result:
                    transliteration = result['transliteration'].lower()
                    expected = test_case['expected_transliteration'].lower()
                    if expected in transliteration or transliteration in expected:
                        print(f"✅ Transliteration correct: {result['transliteration']}")
                    else:
                        print(f"⚠️ Transliteration differs: got '{result['transliteration']}', expected '{test_case['expected_transliteration']}'")
                
                # Check word meaning
                if 'word_meaning' in result and result['word_meaning']:
                    meaning = result['word_meaning']
                    expected_meaning = test_case['expected_meaning_contains']
                    if expected_meaning.lower() in meaning.lower():
                        print(f"✅ Word meaning correct: {meaning}")
                    else:
                        print(f"⚠️ Word meaning differs: got '{meaning}', expected to contain '{expected_meaning}'")
                else:
                    print(f"❌ No word meaning returned")
                    
            else:
                print(f"❌ API call failed with status {response.status_code}")
                print(f"Response: {response.text}")
                
        except requests.exceptions.RequestException as e:
            print(f"❌ Network error: {e}")
        except Exception as e:
            print(f"❌ Unexpected error: {e}")
            
        print("-" * 60)
        print()

def test_api_health():
    """Test API health endpoint"""
    print("=== API Health Check ===")
    try:
        response = requests.get(f"{BASE_URL}/", timeout=5)
        if response.status_code == 200:
            print("✅ API is running")
            print(f"Response: {response.json()}")
        else:
            print(f"❌ API health check failed: {response.status_code}")
    except Exception as e:
        print(f"❌ API is not accessible: {e}")
    print()

if __name__ == "__main__":
    # Run tests
    test_api_health()
    test_transliteration_with_meaning()
    
    print("=== Integration Test Complete ===")
    print("If all tests pass, the word meaning interpretation feature is working correctly!")