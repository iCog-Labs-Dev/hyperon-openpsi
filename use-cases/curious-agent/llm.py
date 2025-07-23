import os
import google.generativeai as genai
from dotenv import load_dotenv

def getUserInput():
    user_input = input("You: ")
    if user_input.lower() == 'exit':
        print("Gemini Chatbot: Goodbye!")
    return user_input

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
