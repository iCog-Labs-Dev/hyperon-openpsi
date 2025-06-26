from pydantic import BaseModel
from typing import List


class Schema(BaseModel):
    handle: str
    context: str
    action: str
    goal: str
    tv: str


class Action(BaseModel):
    action_name: str


def parse_sexp(sexpr: str) -> List[Schema]:
    """A function that parses an expression from MeTTa to Python."""
    pass

def parse_action(actions: str) -> List[Action]:
    """Action Plan Parser: A function that parses meTTa's tuple of actions"""
    actions = actions.strip("()")
    action_list = actions.split(") (")
    parsed_actions = []
    for act in action_list:
        parsed_actions.append(Action(action_name=act))
    return parsed_actions
