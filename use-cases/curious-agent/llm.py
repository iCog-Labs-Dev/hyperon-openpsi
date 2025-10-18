import os
import google.generativeai as genai
from dotenv import load_dotenv

# Import speech-to-text functionality
try:
    from speech_to_text import create_stt_engine, create_interactive_stt
    STT_AVAILABLE = True
except ImportError as e:
    print(f"Warning: Speech-to-text not available: {e}")
    STT_AVAILABLE = False

def getUserInput():
    user_input = input("You: ")
    if user_input.lower() == 'exit':
        print("Gemini Chatbot: Goodbye!")
    return user_input


def getUserInputWithSTT():
    """
    Enhanced input function that supports both text and speech input.
    """
    print("\nInput options:")
    print("1. Type 'text' for text input")
    print("2. Type 'speech' for speech input")
    print("3. Type 'exit' to quit")
    
    while True:
        mode = input("\nChoose input mode (text/speech/exit): ").strip().lower()
        
        if mode == "exit":
            print("Gemini Chatbot: Goodbye!")
            return "exit"
        elif mode == "text":
            return input("You: ")
        elif mode == "speech":
            if not STT_AVAILABLE:
                print("❌ Speech-to-text not available. Please install required dependencies.")
                print("Run: pip install speechrecognition pyaudio pydub openai-whisper")
                continue
            
            try:
                stt_engine = create_stt_engine(backend="google", language="en-US")
                print("\n🎤 Listening for speech... (speak within 10 seconds)")
                text = stt_engine.listen_once(timeout=10.0, phrase_time_limit=5.0)
                
                if text:
                    print(f"🎤 Heard: {text}")
                    return text
                else:
                    print("❌ No speech detected. Please try again.")
                    continue
                    
            except Exception as e:
                print(f"❌ Speech recognition error: {e}")
                print("Falling back to text input...")
                return input("You: ")
        else:
            print("❌ Invalid option. Please choose 'text', 'speech', or 'exit'.")


def getSpeechInput(prompt: str = "Speak now:") -> str:
    """
    Get speech input from the user.
    
    Args:
        prompt: Prompt to display to the user
        
    Returns:
        Transcribed text or empty string if no speech detected
    """
    if not STT_AVAILABLE:
        print("❌ Speech-to-text not available. Please install required dependencies.")
        return ""
    
    try:
        stt_engine = create_stt_engine(backend="google", language="en-US")
        interactive_stt = InteractiveSTT(stt_engine)
        return interactive_stt.get_speech_input(prompt) or ""
    except Exception as e:
        print(f"❌ Speech recognition error: {e}")
        return ""


def chooseInputMode() -> str:
    """
    Allow user to choose input mode for the Curious Agent.
    
    Returns:
        Selected mode: "text", "speech", "interactive", or "mixed"
    """
    print("\n🤖 Welcome to the Curious Agent!")
    print("\nChoose your preferred input mode:")
    print("1. 'text' - Traditional text input only")
    print("2. 'speech' - Speech-to-text input only")
    print("3. 'interactive' - Interactive speech mode with voice commands")
    print("4. 'mixed' - Choose between text and speech for each input (default)")
    
    while True:
        mode = input("\nEnter your choice (text/speech/interactive/mixed): ").strip().lower()
        
        if mode in ["text", "speech", "interactive", "mixed"]:
            print(f"\n✅ Selected mode: {mode}")
            if mode == "speech" or mode == "interactive":
                if not STT_AVAILABLE:
                    print("❌ Speech-to-text not available. Please install required dependencies.")
                    print("Run: pip install speechrecognition pyaudio pydub openai-whisper")
                    print("Falling back to mixed mode...")
                    return "mixed"
            return mode
        else:
            print("❌ Invalid choice. Please enter 'text', 'speech', 'interactive', or 'mixed'.")

def main():
    """
    A simple terminal-based chatbot using Google's Gemini API.
    """
    load_dotenv()
    api_key = os.getenv("GEMINI_API_KEY")
    if not api_key:
        raise ValueError("GEMINI_API_KEY not found in .env file")

    genai.configure(api_key=api_key)
    model = genai.GenerativeModel('models/gemini-2.5-flash')

    print("Gemini Chatbot: Hello! How can I help you today? (Type 'exit' to quit)")

    while True:
        user_input = input("You: ")
        if user_input.lower() == 'exit':
            print("Gemini Chatbot: Goodbye!")
            break

        try:
            response = model.generate_content(user_input, stream=True)
            print("Gemini Chatbot: ", end="")
            for chunk in response:
                print(chunk.text, end="", flush=True)
            print() 
        except Exception as e:
            print(f"An error occurred: {e}")
        

if __name__ == "__main__":
    main()
