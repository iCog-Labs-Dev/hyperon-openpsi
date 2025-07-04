import base64
import os
import sys
from typing import List
from google import genai
from google.genai import types
from base import Schema

def correlate(conversation_summary: str, rules_list: str) -> str:
    client = genai.Client(
        api_key="AIzaSyBCWD1mXOatWSAIlRTQfCX5iCUbohuMuXs",
    )

    model = "gemini-2.0-flash"
    
    prompt = f"""
Your task is to select and sort cognitive schematic rules from the list provided as {rules_list} that correlate with the current chat conversation summary: {conversation_summary}.

- Return only a single-line Python list of strings in the exact format: ['rule1', 'rule2', 'rule3'] where each rule represents the entire cogritive schematics of the form  (: R1 (IMPLICATION_LINK (AND_LINK ((Conversation-Started)) (Greet-Human)) (Initiate-Engagement)) (TTV 100 (STV-0.9-0.8))) .
- The returned list must be a subset of the originally provided list of rules.
- The list must be sorted by relevance to the conversation summary, with the most relevant rules first.
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

    return result.strip()


def correlation_matcher(conversation_summary:str, rules_list:str) -> Schema:

    # This function should take the conversation summary and the list of rules as input
    # and validate the synthax and existence of the rules in the rule space
    selected_rules = correlate(conversation_summary, rules_list).splitlines()
    sorted_rules = sorted(selected_rules, key=lambda rule: rule.split(" (")[1].split(")")[0], reverse=True)
    return [Schema(rule) for rule in sorted_rules]