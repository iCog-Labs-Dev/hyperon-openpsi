from typing import Optional, TypedDict
import os

from langchain_core.prompts import PromptTemplate
from langchain_google_genai import ChatGoogleGenerativeAI
from langgraph.graph import StateGraph, END

SYSTEM_PROMPT = """
You are an expert in analyzing motivational systems and linking rules to psychological demands. The demands are defined as follows:
- Affiliation: Relates to building connections, rapport, and social engagement with users.
- Competence: Relates to achieving mastery, optimizing strategies, and gaining deep or broad knowledge.
- Certainty: Relates to ensuring reliability, predictability, focus on verifiable insights, and timely outcomes.
- Integrity: Relates to honest assessments, accurate information, consistent professionalism, and ethical filtering.
- Energy: Relates to maintaining dynamism, infusing vitality, efficient resource use, and keeping interactions lively.

Given the following rules in the system:

{rules}

Your task is to:
1. Identify all unique goals mentioned in the rules (e.g., from structures like (Goal goal_name ...)).
2. For each goal, determine which demands it relates to based on the definitions above. A goal can relate to multiple demands.
3. Output only the linkages in the exact format below, with each on a new line:
(: demand (Goal goal_name 1.0 1.0))

Do not include any explanations, additional text, or duplicates. Ensure every relevant goal is covered at least once, but only list associations that logically fit, the names of the demands are in lowercase .
"""


class AgentState(TypedDict):
    rules: str  # Input: the rules string
    comparator_rules: str
    output: Optional[str] | None  # Output: the generated linkages


def link_demands_node(state: AgentState) -> AgentState:
    prompt = PromptTemplate.from_template(SYSTEM_PROMPT)
    llm = ChatGoogleGenerativeAI(
        model="gemini-2.0-flash", temperature=0.0, api_key=os.getenv("GEMINI_API_KEY")
    )
    chain = prompt | llm

    result = chain.invoke({"rules": state["rules"]})

    return {"output": result.content, "rules": state["rules"]}


graph = StateGraph(AgentState)
graph.add_node("linker", link_demands_node)
graph.set_entry_point("linker")
graph.add_edge("linker", END)

agent = graph.compile()
