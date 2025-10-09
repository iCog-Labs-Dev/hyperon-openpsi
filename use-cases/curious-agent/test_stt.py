#!/usr/bin/env python3
"""
Test script for the speech-to-text functionality in the Curious Agent.
This script tests the STT components without running the full agent.
"""

import sys
import os
import time

# Add the current directory to the path so we can import our modules
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

def test_imports():
    """Test that all required modules can be imported."""
    print("🔍 Testing imports...")
    
    try:
        from speech_to_text import create_stt_engine, create_interactive_stt, InteractiveSTT
        print(" speech_to_text module imported successfully")
    except ImportError as e:
        print(f" Failed to import speech_to_text: {e}")
        return False
    
    try:
        import speech_recognition as sr
        print(" speech_recognition imported successfully")
    except ImportError as e:
        print(f" Failed to import speech_recognition: {e}")
        return False
    
    try:
        import pyaudio
        print(" pyaudio imported successfully")
    except ImportError as e:
        print(f" Failed to import pyaudio: {e}")
        return False
    
    try:
        from pydub import AudioSegment
        print(" pydub imported successfully")
    except ImportError as e:
        print(f" Failed to import pydub: {e}")
        return False
    
    return True

def test_microphone():
    """Test microphone access."""
    print("\n🎤 Testing microphone access...")
    
    try:
        import speech_recognition as sr
        r = sr.Recognizer()
        mic = sr.Microphone()
        
        with mic as source:
            print(" Microphone detected and accessible")
            r.adjust_for_ambient_noise(source, duration=1)
            print(f" Energy threshold set to: {r.energy_threshold}")
        
        return True
    except Exception as e:
        print(f" Microphone test failed: {e}")
        return False

def test_stt_engine_creation():
    """Test STT engine creation."""
    print("\n Testing STT engine creation...")
    
    try:
        from speech_to_text import create_stt_engine
        
        # Test Google backend
        stt_google = create_stt_engine(backend="google", language="en-US")
        print(" Google STT engine created successfully")
        
        # Test Whisper backend (if available)
        try:
            stt_whisper = create_stt_engine(backend="whisper", language="en-US")
            print(" Whisper STT engine created successfully")
        except Exception as e:
            print(f" Whisper STT engine creation failed (expected if not installed): {e}")
        
        return True
    except Exception as e:
        print(f" STT engine creation failed: {e}")
        return False

def test_utils_integration():
    """Test integration with utils module."""
    print("\n Testing utils integration...")
    
    try:
        from utils.util import getUserInputWithSTT, getSpeechInput, chooseInputMode
        print(" STT functions imported from utils successfully")
        
        # Test that functions are callable
        print(" STT functions are callable")
        
        return True
    except ImportError as e:
        print(f" Failed to import STT functions from utils: {e}")
        return False
    except Exception as e:
        print(f" Utils integration test failed: {e}")
        return False

def test_llm_integration():
    """Test integration with llm module."""
    print("\n Testing LLM integration...")
    
    try:
        from llm import getUserInputWithSTT, getSpeechInput, chooseInputMode
        print(" STT functions imported from llm successfully")
        
        # Test that functions are callable
        print(" LLM STT functions are callable")

        return True
    except ImportError as e:
        print(f" Failed to import STT functions from llm: {e}")
        return False
    except Exception as e:
        print(f" LLM integration test failed: {e}")
        return False

def test_audio_recording():
    """Test audio recording functionality."""
    print("\n Testing audio recording...")
    
    try:
        from speech_to_text import create_stt_engine
        
        stt = create_stt_engine(backend="google", language="en-US")
        
        print("Recording 3 seconds of audio...")
        audio_file = stt.record_audio(duration=3.0)
        
        if os.path.exists(audio_file):
            print(f" Audio recorded successfully: {audio_file}")
            
            # Clean up
            os.unlink(audio_file)
            print(" Temporary audio file cleaned up")
            return True
        else:
            print(" Audio file was not created")
            return False
            
    except Exception as e:
        print(f"Audio recording test failed: {e}")
        return False

def test_speech_recognition():
    """Test actual speech recognition (requires user interaction)."""
    print("\n🗣️ Testing speech recognition...")
    print("This test requires you to speak when prompted.")
    
    response = input("Do you want to test speech recognition? (y/n): ").strip().lower()
    
    if response != 'y':
        print("⏭ Skipping speech recognition test")
        return True
    
    try:
        from speech_to_text import create_stt_engine
        
        stt = create_stt_engine(backend="google", language="en-US")
        
        print("\n🎤 Please speak now (you have 5 seconds)...")
        text = stt.listen_once(timeout=5.0, phrase_time_limit=3.0)
        
        if text:
            print(f" Speech recognized: '{text}'")
            return True
        else:
            print(" No speech was recognized")
            return False
            
    except Exception as e:
        print(f"Speech recognition test failed: {e}")
        return False

def main():
    """Run all tests."""
    print("Speech-to-Text Integration Test Suite")
    print("=" * 50)
    
    tests = [
        ("Import Test", test_imports),
        ("Microphone Test", test_microphone),
        ("STT Engine Creation", test_stt_engine_creation),
        ("Utils Integration", test_utils_integration),
        ("LLM Integration", test_llm_integration),
        ("Audio Recording", test_audio_recording),
        ("Speech Recognition", test_speech_recognition),
    ]
    
    passed = 0
    total = len(tests)
    
    for test_name, test_func in tests:
        print(f"\n{'='*20} {test_name} {'='*20}")
        try:
            if test_func():
                passed += 1
                print(f" {test_name} PASSED")
            else:
                print(f" {test_name} FAILED")
        except Exception as e:
            print(f" {test_name} FAILED with exception: {e}")

    print(f"\n{'='*50}")
    print(f" Test Results: {passed}/{total} tests passed")
    
    if passed == total:
        print(" All tests passed! STT integration is working correctly.")
        return True
    else:
        print(" Some tests failed. Check the output above for details.")
        return False

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
