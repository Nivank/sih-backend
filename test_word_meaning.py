#!/usr/bin/env python3
"""
Test script to verify enhanced word meaning interpretation functionality
"""

import requests
import json

# Test data with various Indian language words
test_cases = [
    {
        "text": "नमस्ते",
        "source_script": "Devanagari", 
        "target_script": "IAST",
        "expected_meaning_contains": "Hello/Greetings"
    },
    {
        "text": "धन्यवाद",
        "source_script": "Devanagari",
        "target_script": "Tamil", 
        "expected_meaning_contains": "Thank you"
    },
    {
        "text": "प्रेम",
        "source_script": "Hindi",
        "target_script": "English",
        "expected_meaning_contains": "Love"
    },
    {
        "text": "hello",
        "source_script": "IAST",
        "target_script": "Devanagari",
        "expected_meaning_contains": "नमस्ते"
    },
    {
        "text": "ज्ञान",
        "source_script": "Devanagari",
        "target_script": "IAST", 
        "expected_meaning_contains": "Knowledge"
    },
    {
        "text": "unknown_word",
        "source_script": "IAST",
        "target_script": "Devanagari",
        "expected_meaning_contains": "English word"
    }
]

def test_word_meaning():
    """Test the enhanced word meaning functionality"""
    base_url = "http://127.0.0.1:8000"
    
    print("🧪 Testing Enhanced Word Meaning Interpretation")
    print("=" * 60)
    
    for i, test_case in enumerate(test_cases, 1):
        print(f"\n📝 Test {i}: {test_case['text']}")
        print(f"   From: {test_case['source_script']} → To: {test_case['target_script']}")
        
        try:
            # Make API request
            response = requests.post(
                f"{base_url}/transliterate/",
                json={
                    "source_text": test_case["text"],
                    "source_script": test_case["source_script"],
                    "target_script": test_case["target_script"]
                },
                timeout=10
            )
            
            if response.status_code == 200:
                data = response.json()
                transliterated_text = data.get("transliterated_text", "")
                word_meaning = data.get("word_meaning", "No meaning provided")
                
                print(f"   ✅ Transliteration: {transliterated_text}")
                print(f"   🔍 Meaning: {word_meaning}")
                
                # Check if expected meaning is contained
                if test_case["expected_meaning_contains"].lower() in word_meaning.lower():
                    print(f"   ✅ Meaning test PASSED")
                else:
                    print(f"   ❌ Meaning test FAILED")
                    print(f"      Expected to contain: {test_case['expected_meaning_contains']}")
                
            else:
                print(f"   ❌ API Error: {response.status_code}")
                print(f"      Response: {response.text}")
                
        except Exception as e:
            print(f"   ❌ Request failed: {e}")
    
    print("\n" + "=" * 60)
    print("🏁 Test completed!")

if __name__ == "__main__":
    test_word_meaning()#!/usr/bin/env python3
"""
Test script to verify enhanced word meaning interpretation functionality
"""

import requests
import json

# Test data with various Indian language words
test_cases = [
    {
        "text": "नमस्ते",
        "source_script": "Devanagari", 
        "target_script": "IAST",
        "expected_meaning_contains": "Hello/Greetings"
    },
    {
        "text": "धन्यवाद",
        "source_script": "Devanagari",
        "target_script": "Tamil", 
        "expected_meaning_contains": "Thank you"
    },
    {
        "text": "प्रेम",
        "source_script": "Hindi",
        "target_script": "English",
        "expected_meaning_contains": "Love"
    },
    {
        "text": "hello",
        "source_script": "IAST",
        "target_script": "Devanagari",
        "expected_meaning_contains": "नमस्ते"
    },
    {
        "text": "ज्ञान",
        "source_script": "Devanagari",
        "target_script": "IAST", 
        "expected_meaning_contains": "Knowledge"
    },
    {
        "text": "unknown_word",
        "source_script": "IAST",
        "target_script": "Devanagari",
        "expected_meaning_contains": "English word"
    }
]

def test_word_meaning():
    """Test the enhanced word meaning functionality"""
    base_url = "http://127.0.0.1:8000"
    
    print("🧪 Testing Enhanced Word Meaning Interpretation")
    print("=" * 60)
    
    for i, test_case in enumerate(test_cases, 1):
        print(f"\n📝 Test {i}: {test_case['text']}")
        print(f"   From: {test_case['source_script']} → To: {test_case['target_script']}")
        
        try:
            # Make API request
            response = requests.post(
                f"{base_url}/transliterate/",
                json={
                    "source_text": test_case["text"],
                    "source_script": test_case["source_script"],
                    "target_script": test_case["target_script"]
                },
                timeout=10
            )
            
            if response.status_code == 200:
                data = response.json()
                transliterated_text = data.get("transliterated_text", "")
                word_meaning = data.get("word_meaning", "No meaning provided")
                
                print(f"   ✅ Transliteration: {transliterated_text}")
                print(f"   🔍 Meaning: {word_meaning}")
                
                # Check if expected meaning is contained
                if test_case["expected_meaning_contains"].lower() in word_meaning.lower():
                    print(f"   ✅ Meaning test PASSED")
                else:
                    print(f"   ❌ Meaning test FAILED")
                    print(f"      Expected to contain: {test_case['expected_meaning_contains']}")
                
            else:
                print(f"   ❌ API Error: {response.status_code}")
                print(f"      Response: {response.text}")
                
        except Exception as e:
            print(f"   ❌ Request failed: {e}")
    
    print("\n" + "=" * 60)
    print("🏁 Test completed!")

if __name__ == "__main__":
    test_word_meaning()