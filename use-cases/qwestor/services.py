import asyncio
from typing import List
from schemas import RuleCreate
from agent import AgentState, agent
from utils import writeListToFile


def format_rules(rules: List[RuleCreate]) -> str:
    output = ""

    for i, rule in enumerate(rules):
        output += """((: r{id} ((TTV {id} (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal {context} 0.9 0.6) {action})) (Goal {goal} 1.0 1.0)))) {id})\n""".format(
            id=i, context=rule.context, action=rule.action, goal=rule.goal
        )

    return output


async def pair_to_goals(payload: list[RuleCreate]):
    rules = format_rules(payload)

    result = await agent.ainvoke(AgentState(rules=rules, output=None))
    await asyncio.to_thread(
        writeListToFile,
        [result["rules"].strip()],
        "rules.metta",
    )

    await asyncio.to_thread(
        writeListToFile,
        [result["output"].strip()],
        "demand-goal-links.metta",
    )
    return result
