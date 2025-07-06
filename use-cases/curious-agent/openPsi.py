import base64
import os
import sys
from typing import List
from google import genai
from google.genai import types
from base import Schema
import json
from adapter import *

def correlate(conversation_summary: str, rules_list: List[str]) -> List[str]:
    client = genai.Client(
        api_key="AIzaSyBCWD1mXOatWSAIlRTQfCX5iCUbohuMuXs",
    )

    model = "gemini-2.0-flash"
    
    prompt = f"""
Your task is to select and sort cognitive schematic rules from the list provided as {rules_list} that correlate with the current chat conversation summary: {conversation_summary}.

- Return only a single-line JSON array of strings in the exact format: ["rule1", "rule2", "rule3"] where each rule represents the entire cognitive schematics of the form  (: R1 (IMPLICATION_LINK (AND_LINK ((Conversation-Started)) (Greet-Human)) (Initiate-Engagement)) (TTV 100 (STV-0.9-0.8))) .
- The returned array must be a subset of the originally provided list of rules.
- The array must be sorted by relevance to the conversation summary, with the most relevant rules first.
- Do not include any explanations, comments, or additional text in your response.
- Preserve the exact syntax format as specified.
"""

    contents = [
        types.Content(
            role="user",
            parts=[
                types.Part.from_text(text=prompt),
            ],
        ),
    ]

    generate_content_config = types.GenerateContentConfig(
       response_mime_type= "application/json",
        response_schema= {"type": "array", "items": {"type": "string"}}
    )

    result = ""
    response = client.models.generate_content(
        model=model,
        contents=contents,
        config=generate_content_config,
    
    )
    

    for candidate in response.candidates:
        for part in candidate.content.parts:
            if hasattr(part, 'text'):
                result += part.text.strip()

    # Parse the JSON string into a Python list
    try:
        rules_array = json.loads(result.strip())
        return rules_array
    except json.JSONDecodeError as e:
        print(f"Error decoding JSON from Gemini response: {e}")
        print(f"Raw response: {result.strip()}")
        return [] # Return an empty list or handle the error as appropriate


def correlation_matcher(conversation_summary:str, rules_list:List[str]) -> Schema:
    """
    This function takes the conversation summary and the list of rules as input,
    correlates them, validates the syntax and existence of the selected rules,
    and returns the most relevant validated rule as a Schema object.
    Returns None if no valid rule is found.
    """
    raw_rules_string = correlate(conversation_summary, rules_list)
    # print("Raw rules: ", raw_rules_string)
    # print(type(raw_rules_string))
   
    for rule_string in raw_rules_string:
        print("validating synthax: ", validateSyntax(rule_string))
       
        if validateSyntax(rule_string):
           
            if validateExistence(rule_string, rules_list):
                return rule_string

    # Return None if no valid rule is found after checking all selected rules
    return None
