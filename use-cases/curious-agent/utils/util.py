

import logging
import sys
from hyperon import *
from hyperon.ext import register_atoms
from hyperon.atoms import OperationAtom, GroundedAtom, SymbolAtom, ValueAtom, ExpressionAtom
from collections import deque
import os
import google.generativeai as genai
from dotenv import load_dotenv

load_dotenv()
api_key = os.getenv("GEMINI_API_KEY")
if not api_key:
    raise ValueError("GEMINI_API_KEY not found in .env file")
genai.configure(api_key=api_key)
model = genai.GenerativeModel('models/gemini-2.5-flash')

def getUserInput():
    user_input = input("You: ")
    if user_input.lower() == 'exit':
        print("Gemini Chatbot: Goodbye!")
    return user_input


# update dialogue Queue



def generateResponse(user_input:str) -> str:
    response = model.generate_content(user_input)
    print("Gemini Chatbot: ", end="")
    # for chunk in response:
    #     print(chunk.text, end="", flush=True)

    return response.text.strip()

def main():
    """
    A simple terminal-based chatbot using Google's Gemini API.
    """

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

def pyModule (metta:MeTTa,name:Atom,*args: Atom):
    print("Args : ", args)
    payload_expression: ExpressionAtom = args[0]
    actual_arg_atoms = payload_expression.get_children()
    functionName  = name.get_name()
    handler_args: list[str] = [str(arg) for arg in actual_arg_atoms]

    #run
    result =  globals()[functionName](*handler_args)

       
    return [ValueAtom(result)]

@register_atoms(pass_metta=True)
def pyModule_(metta):
    return {
        "pyModule": OperationAtom(
            "pyModule",
            lambda  name, *payload: pyModule(metta,name, *payload),
            ["Atom","Atom", "Atom"],
            unwrap=False
        )
    }


def test_func(name: str): 
    # This is an example call form a metta script
    # !(import! &self t) 
    # !(pyModule tes_func (param1, ...))

 
    return f"Hello, {name}!"

