from typing import List
from base import *
import re
import json
from pydantic import ValidationError



def parse_schema(schema: Schema) -> str:
    """A function that parses a cognitive Schema into represented in Python to MeTTa structure."""
    # Assuming context, action, and goal are already in the correct Metta format
    # Format weight as an integer to match the expected output
    return f"""((: {schema.handle} ({schema.tv} (IMPLICATION_LINK (AND_LINK ({schema.context} {schema.action})) {schema.goal}))) {schema.weight})"""


def parse_action(actions: str) -> List[Action]:
    """a function that parses MeTTa's tuple of actions to a Python List of Actions. The MeTTa expression has the form -> (action1 action2 action3 ...)"""
    pattern = r"\(\s*(\w+\s*\d+)\s*\)"
    actions_list = re.findall(pattern, actions)
    action_tuple = (Action(action_name=action) for action in actions_list)
    return action_tuple


def parse_exp(sexpr: str) -> List[Schema]:
    pattern = re.compile(r"""
        \(                       # opening of the outermost tuple
          \( :\s*(r\d+)\s*       # handle (e.g. r1)
          \(                     # opening of the rule body
            \( TTV\s*\d+\s*\( STV\s*([\d.]+)\s+([\d.]+)\) \)\s*    # STV values
            \( IMPLICATION_LINK\s*
              \( AND_LINK\s*
                \( \( Goal\s+([a-zA-Z0-9_]+)\s+[\d.]+\s+[\d.]+ \)\s+([a-zA-Z0-9_]+) \)\s*  # context + action
              \)\s*
              \( Goal\s+([a-zA-Z0-9_]+)\s+[\d.]+\s+[\d.]+ \)       # goal
            \)
          \)\s*
        (\d+(?:\.\d+)?)              # weight
        \)
    """, re.VERBOSE)

    result = []
    for match in pattern.finditer(sexpr):
        handle, stv1, stv2, context, action, goal, weight = match.groups()
        result.append(Schema(
            handle=handle,
            context=context,
            action=action,
            goal=goal,
            weight=float(weight),
            tv=f"(STV {stv1} {stv2})"
        ))

    return result


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
    matches = re.findall(r"\(modulator\s+(\w+)\s+([\d.]+)\)", state_params)
    if not matches:
        return None
    params_obj = {name: float(value) for name, value in matches}

    try:
        return StateParams(**params_obj)
    except ValidationError:
        return None


def validateSyntax(rule: str) -> bool:
    # The pattern is designed to match a specific MeTTa rule structure.
    # It uses \s* to allow for zero or more whitespace characters, making the validation flexible with spacing.
    pattern = r"""
    \(\(:\s*                                    # Start of the outer expression with a colon
    (\w+)\s*                                    # Capture the rule handle (e.g., r1)
    \(\(TTV\s*\d\s*                             # Start of TTV with a single digit
    \(STV\s*\d\.\d\s+\d\.\d\s*\)\)\s*             # STV with two single-digit decimal numbers
    \(IMPLICATION_LINK\s*                       # IMPLICATION_LINK keyword
    \(\s*AND_LINK\s*                            # AND_LINK keyword
    \(\(\s*Goal\s+\w+\s+\d\.\d\s+\d\.\d\s*\)\s*    # Goal expression with a name and two single-digit decimal numbers
    \w+\s*\)\)\s*                               # Action keyword
    \(\s*Goal\s+\w+\s+\d\.\d\s+\d\.\d\s*\)       # Goal expression again
    \)\)\)\s*                                   # Closing parentheses for the structure
    ([0-1](\.\d)?|2(\.0)?)\s*\)                  # Final weight number (0-2) with one decimal place and closing parenthesis
    """
    return bool(re.match(pattern, rule, re.VERBOSE))


def validateExistence(rule: str, ruleSpace: List[str]) -> bool:
    """
    Validates if a rule string exists within the ruleSpace string.
    """
    # This is a simple validation . It  assumes there is no discrepancy in the spacing within the rule strings.

    return rule in ruleSpace


def extract_rules_from_llm(raw_rules: str) -> List[Schema]:
    # Extracts the selected rules from the LLM response.
    # Assumes the the raw_rules is a string representation of a list of rules in the form:
    # "[(rule1), (rule2), ...]"
    rules = raw_rules.strip().strip("[]").split(",")
    stripped_rules = (
        raw_rules.strip().strip("[]").strip()
    )  # Strip outer whitespace again after removing brackets

    if not stripped_rules:
        return []

    # Now split and strip each rule
    rules = [rule.strip() for rule in stripped_rules.split(",")]

    return rules


# string = "( (modulator activation 0.5) (modulator securing_threshold 0.7) (modulator pleasure 0.8) (modulator selection_threshold 0.6) )"
# state_params = parse_state_params(string)
# print(state_params)


# print(parse_schema(Schema(handle="test_schema", context="(Self Is Outside) (Self Has Key) (Self See Door)", action="(Go to Door)", goal="(Self at Door)", tv="(TTV 1 (STV 0.5 0.1))")))
