import spacy
from pydantic import BaseModel
from typing import List

class Schema(BaseModel):
    handle: str
    context: str
    action: str
    goal: str
    tv: str

# Load the spaCy model once at module level for efficiency
# Using the medium model for faster execution and lower memory requirements
nlp = spacy.load("en_core_web_md")

def match_rule(conversation_summary: str, rule_base: List[Schema]) -> Schema:
    """
    Finds and returns the single rule from the rule base that best matches the given conversation summary.

    This function uses spaCy's semantic similarity to compare the conversation summary
    with the context of each rule. The rule with the highest similarity score is returned.
    """
    if not rule_base:
        raise ValueError("rule_base must not be empty")

    conversation_doc = nlp(conversation_summary)

    best_rule = None
    best_score = -1.0

    for rule in rule_base:
        rule_doc = nlp(rule.context)
        score = rule_doc.similarity(conversation_doc)

        if score > best_score:
            best_score = score
            best_rule = rule

    return best_rule
