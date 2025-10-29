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

def query_llm(perception_list, rule_count, rule_id):
    SYSTEM_PROMPT = f"""
        You are going to take a list of percetions as an agent of the form (perception $timeCycle $perceptionValue) 
        The perception list is {perception_list} so based on the perception List generate a list of cognitive schemas that 
        Look like the following:
    
                (: Rule @
                    (TTV <<cycle>>)
                    (STV <<belief>> <<confidence>>)
                    (Complexity 1)
                    (Context (<<contextInformation about the environment>>))
                    (Action (<<ATTACK SWORD>>))
                    (Goal (<<Goal Value>>))
                )
                Each rule must start with '(: Rule @)' — always include the '@' symbol exactly as shown.
                If there are multiple contextInformations make sure each is enclosed with a bracket. For example (Context ((person) (walking) (activity))).
                Action always has only one element. For example (Action (Attack)).
                Goal has only one element. Example (Goal (exercise)).
                Make really sure the belief and the confidence values are between [0,1] while the <<cycle>> is a natural number describing the timeCycle. The contextInformation
                about the environment is the an s-expression containing information about the environment. The number of rules generated should be {rule_count} return the rules as a list of python expressions.
                Don't write anything except the generated schemas as a python List.
           """
    llm_instance = connect_llm()
    value = llm_instance.generate_content(SYSTEM_PROMPT, stream=True)
    value.resolve()
    
    processed_response = preprocess_llm_response(value.text, int(rule_id))
    return processed_response

def validateSyntax(rule: str) -> bool:
    """
    Validates the syntax of an OpenPsi-style rule block.

    Expected structure example:
    (: Rule 2
        (TTV 0)
        (STV 0.5 0.002)
        (Complexity 1)
        (Context ((Position CLOSE_RANGE))) 
        (Action (ATTACK))                   
        (Goal (HIT))
    )

    Returns:
        bool: True if the rule matches the general OpenPsi format, False otherwise.
    """
    rule = rule.strip()

    pattern = re.compile(
        r"""
        ^\(\:\s*Rule\s+\d+\s*                      # (: Rule <number>
        \(TTV\s+[0-9.]+\)\s*                       # (TTV <float>)
        \(STV\s+[0-9.]+\s+[0-9.]+\)\s*             # (STV <float> <float>)
        \(Complexity\s+[0-9.]+\)\s*                # (Complexity <float>)
        \(Context\s+\(.+\)\)\s*                    # (Context (<anything>))
        \(Action\s+\(\w+(?:\s+\w+)?\)\)\s*         # (Action (<verb> [object]))
        \(Goal\s+\(\w+\)\)\s*                      # (Goal (<word>))
        \)$                                        # closing parenthesis
        """,
        re.VERBOSE | re.DOTALL,
    )

    return bool(pattern.match(rule))


def preprocess_llm_response(raw_data: str, current_rule_id: int) -> str:
    """
    Cleans LLM output, replaces placeholders with rule IDs, validates schemas,
    and returns them combined as a single parenthesized string.
    """
    clean_output = re.sub(r"```(?:python)?|```", "", raw_data).strip()

    import ast
    try:
        schemas = ast.literal_eval(clean_output)
    except Exception as e:
        raise ValueError(f"Failed to parse LLM output: {e}")

    if not isinstance(schemas, list):
        raise TypeError("Expected a list of schemas from LLM output")

    valid_schemas = []
    for schema in schemas:
        # Insert current rule id
        schema_str = str(schema)
        schema_str = schema_str.replace("@", str(current_rule_id))

        if validateSyntax(schema_str):
            valid_schemas.append(schema_str)
            current_rule_id += 1

    return "(" + " ".join(valid_schemas) + ")"
