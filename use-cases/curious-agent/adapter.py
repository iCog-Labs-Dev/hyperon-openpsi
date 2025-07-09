from typing import List
from base import *
import re
import os
import json
from pydantic import ValidationError
from typing import List, Optional
import google.generativeai as genai
from dotenv import load_dotenv



def parse_schema(schema: Schema) -> str:
    """A function that parses a cognitive Schema into represented in Python to MeTTa structure."""
    return f"""(: {schema.handle} (IMPLICATION_LINK (AND_LINK ({schema.context}) {schema.action}) {schema.goal})) {schema.tv})"""
def parse_state_params(state_params: str) -> StateParams:
    """parses the string representation of MeTTa's state params and return a Python StateParam object."""
    pass
		
def parse_action(actions: str) -> List[Action]:
    """a function that parses MeTTa's tuple of actions to a Python List of Actions. The MeTTa expression has the form -> (action1 action2 action3 ...)"""
    pattern = r'\(\s*(\w+\s*\d+)\s*\)'
    actions_list = re.findall(pattern, actions)
    action_tuple = (Action(action_name=action) for action in actions_list )
    return action_tuple
	
def parse_exp(sexpr: str) -> List[Schema]:
	"""A function that parses an expression from MeTTa to Python."""
	pass
def parse_state_params(state_params: str) -> StateParams:
    """
    Parse the string representation of MeTTa's state parameters and return a Python StateParams object.

    This function takes a string representation of state parameters from MeTTa and converts it
    into a Python StateParams object for further processing or analysis.

    Args:
        state_params (str): A string representation of MeTTa's state parameters.

    Returns:
        StateParams: A Python object representing the parsed state parameters.

    """
	
    # Assumes the inpute string(state_params) is a metta tuple of the form ((modulator name value) ...)
    matches = re.findall(r'\(modulator\s+(\w+)\s+([\d.]+)\)', state_params)
    if not matches:
        return None
    params_obj = {name:float(value) for name,value in matches}

    try:
        return StateParams(**params_obj)
    except ValidationError:
        return None


def validateSyntax(rule: str) -> bool:
    pattern = r"""
    ^\(:\s+
    (\w+)\s+
    \(IMPLICATION_LINK\s+
        \(AND_LINK\s+
            \(\(\s*(\((?:\w+-?)+\)\s*)+\s*\)\s*
            \(\w+-?\)\)\s+
        \(\w+-?\)\s*
    \)\s+
    \(TTV\s+
        (\d+)\s+
        \(STV\s+([\d.]+)\s+([\d.]+)\)
    \)\)\)$
    """
    return bool(re.match(pattern, rule, re.VERBOSE))
def checkExistence(rule: Schema, ruleSpace: List[Schema]) -> bool:
	pass

def extract_rules_from_llm(raw_rules: str) -> List[Schema]: 
    #Extracts the selected rules from the LLM response.
	#Assumes the the raw_rules is a string representation of a list of rules in the form:
	# "[(rule1), (rule2), ...]"
    rules = raw_rules.strip().strip('[]').split(',')
    stripped_rules = raw_rules.strip().strip('[]').strip() # Strip outer whitespace again after removing brackets

    if not stripped_rules:
        return []

    # Now split and strip each rule
    rules = [rule.strip() for rule in stripped_rules.split(',')]

    return rules

# string = "( (modulator activation 0.5) (modulator securing_threshold 0.7) (modulator pleasure 0.8) (modulator selection_threshold 0.6) )"
# state_params = parse_state_params(string)
# print(state_params)


# print(parse_schema(Schema(handle="test_schema", context="(Self Is Outside) (Self Has Key) (Self See Door)", action="(Go to Door)", goal="(Self at Door)", tv="(TTV 1 (STV 0.5 0.1))")))


# ========== Correlation Matcher ==========
def match_rule(conversation_summary: str, rule_base: List[str]) -> Optional[str]:
    prompt = (
        f"You are a rule selection engine.\n\n"
        f"Given the following conversation summary:\n"
        f"{conversation_summary}\n\n"
        f"And this list of rules:\n"
        f"{rule_base}\n\n"
        f"Compare the summary to all rules. Select only the top 4 most relevant rules "
        f"that closely match the conversation context. Return them in descending order "
        f"of relevance — from most relevant to least relevant.\n\n"
        f"Output Format Requirement:\n"
        f"- Return only the full rule texts (no headings, no extra words, no explanations).\n"
        f"- Do NOT include any unrelated rules or commentary.\n"
        f"- Return exactly 4 rules or fewer if fewer match — clean output."
    )
    return run_gemini(prompt)



## ========== Gemini Setup ==========

# = Load ENV =======
load_dotenv()
GEMINI_API_KEY = os.getenv("API_KEY")

# = Setup Gemini =====
genai.configure(api_key=GEMINI_API_KEY)

def run_gemini(prompt: str, system_instruction: Optional[str] = None) -> str:
    try:
        model = genai.GenerativeModel("gemini-1.5-flash")
        generation_config = genai.types.GenerationConfig(
            temperature=0.5,
            top_p=1,
            top_k=1,
            max_output_tokens=1024,
        )
        if system_instruction:
            response = model.generate_content(prompt, generation_config=generation_config, system_instruction=system_instruction)
        else:
            response = model.generate_content(prompt, generation_config=generation_config)
        return response.text.strip()
    except Exception as e:
        return f"[Gemini Error] {str(e)}"
  