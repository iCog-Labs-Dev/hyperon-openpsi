from pydantic import BaseModel
from typing import List


class Schema(BaseModel):
    handle: str
    context: str
    action: str
    goal: str
    tv: str


def parse_sexp(sexpr: str) -> List[Schema]:
    """A function that parses an expression from MeTTa to Python."""
    pass

class Action(BaseModel):
    action_name: str

def parse_action(actions: str) -> List[Action]:
    """Action Plan Parser: A function that parses meTTa's tuple of actions"""
    # Example input: "((P2 Kick to P3) (P1 Kick to P2))"
    action_list = []
    stack = []
    current_action = []

    for char in actions[1:-1]:
        if char == '(':
            if stack:
                current_action.append(char)
            stack.append('(')
        elif char == ')':
            stack.pop()
            if stack:
                current_action.append(char)
            if not stack:
                action_str = "".join(current_action).strip()
                action_list.append(Action(action_name=action_str))
                current_action = []
        else:
            current_action.append(char)

    return action_list

def simple_parse_action(actions: str) -> List[Action]:
    actions = actions.strip("()")
    action_list = actions.split(") (")
    parsed_actions = []
    for act in action_list:
        parsed_actions.append(Action(action_name=act))
    return parsed_actions

# print(parse_action("((P2 Kick to() (()(P3))) (P1 Kick to P2))"))
print(parse_action("((P2 Kick to P3) (P1 Kick to P2))"))
print(simple_parse_action("((P2 Kick to P3) (P1 Kick to P2))"))