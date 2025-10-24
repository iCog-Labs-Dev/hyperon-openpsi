from hyperon import *
from hyperon.atoms import OperationAtom
from hyperon.ext import register_atoms

from typing import List
import google.generativeai as genai
from dotenv import load_dotenv
import re
import os 

def pyModuleX(metta: MeTTa, name: str, *args: Atom):
    payload_expression: ExpressionAtom = args[0]
    actual_arg_atoms = payload_expression.get_children()
    functionName = str(name)
    handler_args: list[str] = [str(arg) for arg in actual_arg_atoms]

    # run
    result = globals()[functionName](*handler_args)

    return metta.parse_all(result)

@register_atoms(pass_metta=True)
def main(metta):
    moduleX = OperationAtom(
        "pyModuleX",
        lambda name, *payload: pyModuleX(metta, name, *payload),
        ["Atom", "Atom", "Expression"],
        unwrap=False,
    )

    return {
        r"pyModuleX": moduleX
    }

def connect_llm():
    """
    A simple terminal-based chatbot using Google's Gemini API.
    """
    load_dotenv()
    api_key = os.getenv("GEMINI_API_KEY")
    if not api_key:
        raise ValueError("GEMINI_API_KEY not found in .env file")

    genai.configure(api_key=api_key)
    model = genai.GenerativeModel('models/gemini-2.5-flash')
    return model

def query_llm(perceptionList, noOfRules):
    SYSTEM_PROMPT = f"""
        You are going to take a list of percetions as an agent of the form (perception $timeCycle $perceptionValue) 
        The perception list is {perceptionList} so based on the perception List generate a list of cognitive schemas that 
        Look like the following:
    
                (: <<name reference>>
                    (TTV <<cycle>>)
                    (STV <<belief>> <<confidence>>)
                    (Complexity 1)
                    (Context (<<contextInformation about the environment>>)
                    (Action <<ATTACK SWORD>>)
                    (Goal <<Goal Value>>
                )
                The belief and the confidence values are between [0,1] while the <<cycle>> is a natural number describing the timeCycle. The contextInformation
                about the environment is the an s-expression containing information about the environment. The number of rules generated should be {noOfRules} return the rules as a list of python expressions.
                Please Bro, don't write anything except the generated schemas as a python List.
    
           """
    llm_instance = connect_llm()
    value = llm_instance.generate_content(SYSTEM_PROMPT, stream=True)
    value.resolve()

    return preprocess_llm_response(value.text)

def preprocess_llm_response(raw_data:str) -> List:
    import ast
    clean_output = re.sub(r"```(?:python)?|```", "", raw_data).strip()
    schemas = ast.literal_eval(clean_output)
    data = " "
    for i in schemas:
        data+=" "
        data+=i 
    return "(" + data + ")"
