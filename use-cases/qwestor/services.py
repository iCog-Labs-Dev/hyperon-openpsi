import asyncio
from typing import List
from schemas import RuleCreate
from agent import AgentState, agent
from utils import appendListToFile, writeListToFile
from hyperon import MeTTa


def format_rules(rules: List[RuleCreate]) -> dict:
    rule_dict = {"comparator_rules": "", "output_rules": ""}

    for i, rule in enumerate(rules):
        rule_dict["output_rules"] += (
            """((: r{id} ((TTV {id} (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal {context} 0.9 0.6) {action})) (Goal {goal} 1.0 1.0)))) {id})\n""".format(
                id=i, context=rule.context, action=rule.action, goal=rule.goal
            )
        )
        rule_dict["comparator_rules"] += """({context} {action} {goal})\n""".format(
            context=rule.context, action=rule.action, goal=rule.goal
        )

    return rule_dict


def run_metta_function(metta_code: str, function_name: str, args: list):
    metta = MeTTa()

    # Load the MeTTa function definitions
    metta.run(metta_code)

    # Build the call expression dynamically, e.g. ! (myfunc 42)
    call_expr = f"!({function_name} {' '.join([arg for arg in args])})"

    # Evaluate the call
    result = metta.run(call_expr)

    return result[0]


def check_duplicate(rule: str):
    rules = run_metta_function(
        """
        !(register-module! ../../../hyperon-openpsi)
        !(import! &self hyperon-openpsi:use-cases:qwestor:rules)
        (= (fetchRulesFromDb $self)
            (match $self 
                ((: $ruleId ((TTV $tv $stv) (IMPLICATION_LINK (AND_LINK ((Goal $goal_name $gv $dgv) $action_name)) (Goal $goal_name' $gv' $dgv')))) $val)
                ($goal_name $action_name $goal_name')
            )
        )

        """,
        "fetchRulesFromDb",
        ["&self"],
    )

    rules = "(\n" + "\n".join([r for r in (list(map(str, rules)))]) + "\n)"
    result = run_metta_function(
        """
        (= (comparatorFn $rule $ruleList)
            (if (== $ruleList ())
                False
                (let* (
                    (($head $tail) (decons-atom $ruleList))
                )
                    (if (== $rule $head)
                        True
                        (comparatorFn $rule $tail)
                    )
                )
            )
        )

        """,
        "comparatorFn",
        [rule, rules],
    )

    return result[0]


async def add_rule_goal_links(pairs: dict):
    try:
        comp_rules = pairs["comparator_rules"].split("\n")[:-1]
        rules = pairs["rules"].split("\n")[:-1]

        for rule in zip(comp_rules, rules):
            pred = check_duplicate(rule[0]).get_object().value
            if not pred:  # Cast from GroundedAtom to Boolean
                print("Entering write block")  # Confirm entry
                await asyncio.to_thread(
                    appendListToFile,
                    [rule[1].strip()],
                    "rules.metta",
                )
                await asyncio.to_thread(
                    writeListToFile,
                    [pairs["output"].strip()],
                    "demand-goal-links.metta",
                )
            else:
                return False  # if duplicate is found exit the operation

        return True
    except Exception as e:
        print("error in add_rule_goal_links: ", e)
        raise e


async def pair_to_goals(payload: list[RuleCreate]):
    try:
        rules = format_rules(payload)

        result = await agent.ainvoke(
            AgentState(
                rules=rules["output_rules"],
                output=None,
                comparator_rules=rules["comparator_rules"],
            )
        )
        res = await add_rule_goal_links(result)

        if res:
            return {"status": "success", "data": result}
        else:
            return {"status": "duplicate found", "data": {}}
    except Exception as e:
        print("error in pair_to_goals: ", e)
        raise e
