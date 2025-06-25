from pydantic import BaseModel
from typing import List
from hyperon import *
metta = MeTTa()

class Schema(BaseModel):
    handle: str
    context: str
    action: str
    goal: str
    tv: str

def parse_sexp(sexpr: str) -> List[Schema]:
    atoms = metta.parse_all(sexpr)
    schemas = []
    for atom in atoms:
        if atom.get_metatype() == AtomKind.EXPR:
            children = atom.get_children()
            if len(children) == 5 :
                handle = children[0]
                context = children[1]
                action = children[2]
                goal = children[3]
                tv = children[4]
                handle_str = handle.get_name() if handle.get_metatype() == AtomKind.SYMBOL else str(handle)
                context_str = str(context)
                action_str = str(action)
                goal_str = str(goal)
                tv_str = str(tv)
                schema = Schema(
                    handle=handle_str,
                    context=context_str,
                    action=action_str,
                    goal=goal_str,
                    tv=tv_str
                )
                schemas.append(schema)
    return schemas
#print(parse_sexp('(rule2 C3 A2 G2 (STV 0.7 0.6))'))

def main():
    metta= MeTTa()
    #when querying it should be
    #!(match &psiRules (: $rule (IMPLICATION_LINK (AND_LINK ($context $action)) $goal)) ($rule $context $action $goal TV(0.0 1.0)))
    # i have added tv(0.0 1.0) because it is not clear how to handle the TV in the query but there iss a truth value when adding a rule
    print(parse_sexp('(rule1 (C1 C2) A G (TV 0.9 0.8))'))
    
main()
