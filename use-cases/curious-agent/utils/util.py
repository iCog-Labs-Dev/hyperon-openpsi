from typing import List

from langchain_core.runnables import RunnableConfig
# from google import genai

from langgraph.checkpoint.memory import InMemorySaver

# from google.genai import types
# from ..base import Schema
import json

import re

# from adapter import *
import logging
import sys
from hyperon import *
from hyperon.ext import register_atoms
from hyperon.atoms import (
    OperationAtom,
    GroundedAtom,
    SymbolAtom,
    ValueAtom,
    ExpressionAtom,
)
from collections import deque
import os
import google.generativeai as genai
from dotenv import load_dotenv

from typing import Annotated, TypedDict

from langgraph.graph import add_messages, MessagesState, StateGraph
from langchain_core.messages import (
    AIMessage,
    HumanMessage,
    RemoveMessage,
    SystemMessage,
)
from langgraph.graph import END
from langchain_google_genai import ChatGoogleGenerativeAI

from pydantic import BaseModel


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


class Schema(BaseModel):
    handle: str
    context: str
    action: str
    goal: str
    weight: float | str = 0
    tv: str | None = None


load_dotenv()
api_key = os.getenv("GEMINI_API_KEY")
# Initialize the Gemini model
conversation_model = ChatGoogleGenerativeAI(
    model="gemini-2.0-flash",  # Specify the model (e.g., gemini-2.0-flash, gemini-2.5-pro)
    temperature=0,  # Control randomness (0 for deterministic)
    max_tokens=None,  # Maximum tokens in response (optional)
    timeout=None,  # Request timeout (optional)
    max_retries=2,  # Number of retries for failed requests
    google_api_key=api_key,  # Use environment variable
)
summarization_model = ChatGoogleGenerativeAI(
    model="gemini-2.0-flash",  # Specify the model (e.g., gemini-2.0-flash, gemini-2.5-pro)
    temperature=0,  # Control randomness (0 for deterministic)
    max_tokens=None,  # Maximum tokens in response (optional)
    timeout=None,  # Request timeout (optional)
    max_retries=2,  # Number of retries for failed requests
    google_api_key=api_key,  # Use environment variable
)


model = ChatGoogleGenerativeAI(
    model="gemini-2.0-flash",  # Specify the model (e.g., gemini-2.0-flash, gemini-2.5-pro)
    temperature=0,  # Control randomness (0 for deterministic)
    max_tokens=None,  # Maximum tokens in response (optional)
    timeout=None,  # Request timeout (optional)
    max_retries=2,  # Number of retries for failed requests
    google_api_key=api_key,  # Use environment variable
)


class SchemaList(BaseModel):
    rules: List[Schema]


# correlation_model = model.with_structured_output(SchemaList)
correlation_model = model.with_structured_output(SchemaList)


SYSTEM_PROMPT = """

"""


class AgentState(TypedDict):
    messages: Annotated[list, add_messages]
    summary: str
    rules_list: List[Schema]


def call_model(state: AgentState, config: RunnableConfig):
    # Get the conversation summary from the state
    summary = state.get("summary", "No prior conversation history available.")

    # Replace the placeholder in SYSTEM_PROMPT with the summary
    system_prompt_with_context = SYSTEM_PROMPT.replace(
        "[Insert a summary of the previous conversation here, including user preferences, prior questions, and relevant context to guide the response.]",
        summary,
    )

    # print(system_prompt_with_context)
    system_message = SystemMessage(content=system_prompt_with_context)

    messages = [system_message] + state["messages"]

    response = conversation_model.invoke(messages, config=config)

    return {"messages": [response]}


def should_continue(state):
    """A router function that determines whether previous messages should be summarized or continue."""

    messages = state["messages"]

    if len(messages) > 6:
        return "summarize_conversation"

    return END


def summarize_conversation(state: AgentState) -> AgentState:
    """A function to generate a summary of the chat history, using any existing summary as context for the next summary."""

    summary = state.get("summary", "")

    if summary:
        summary_message = (
            f"This is a summary of the conversation to date: {summary}\n\n"
            "Extend the summary by taking into account the new messages above:"
        )
    else:
        summary_message = "Create a summary of the conversation above:"

    messages = state["messages"] + [HumanMessage(content=summary_message)]

    response = summarization_model.invoke(messages)
    # print("CONTEXT: ", response.content)
    delete_messages = [RemoveMessage(id=message.id) for message in messages[:-2]]
    return {"summary": response.content, "messages": delete_messages}


graph = StateGraph(AgentState)

# register node to graph
graph.add_node("agent", call_model)
graph.add_node("summarize_conversation", summarize_conversation)

graph.set_entry_point("agent")

graph.add_conditional_edges(
    "agent",
    should_continue,
)

graph.add_edge("summarize_conversation", END)
checkpointer = InMemorySaver()
agent = graph.compile(checkpointer=checkpointer)
config = {"configurable": {"thread_id": "1"}}
# result = agent.invoke({"messages": [HumanMessage(content="Hi")], "summary": ""})
# print(result["messages"][-1].content)


def getUserInput():
    user_input = input("You: ")
    if user_input.lower() == "exit":
        print("Gemini Chatbot: Goodbye!")
    return user_input


def generateResponse(user_input: str) -> dict:
    response = agent.invoke({"messages": [HumanMessage(content=user_input)]}, config)
    print("Gemini Chatbot: ", end="")
    print(response["messages"][-1].content)
    # for chunk in response:
    #     print(chunk.text, end="", flush=True)

    return response


def pyModule(metta: MeTTa, name: Atom, *args: Atom):
    print("Args : ", args)
    payload_expression: ExpressionAtom = args[0]
    actual_arg_atoms = payload_expression.get_children()
    functionName = name.get_name()
    handler_args: list[str] = [str(arg) for arg in actual_arg_atoms]

    # run
    result = globals()[functionName](*handler_args)

    return [ValueAtom(result)]


@register_atoms(pass_metta=True)
def pyModule_(metta):
    return {
        "pyModule": OperationAtom(
            "pyModule",
            lambda name, *payload: pyModule(metta, name, *payload),
            ["Atom", "Atom", "Atom"],
            unwrap=False,
        )
    }


def test_func(name: str):
    # This is an example call form a metta script
    # !(import! &self t)
    # !(pyModule tes_func (param1, ...))

    return f"Hello, {name}!"


def call_correlation_model(state: AgentState, config: RunnableConfig):
    system_message = """
Your task is to select and sort cognitive schematic rules from the list provided as {rules_list} that correlate with the current chat conversation summary: {conversation_summary} ,and the latest user response : {userResponse}

- Return only a single-line JSON array of strings in the exact format: ["rule1", "rule2", "rule3"] where each rule represents the entire cognitive schematics of the form  (: R1 (IMPLICATION_LINK (AND_LINK ((Conversation-Started)) (Greet-Human)) (Initiate-Engagement)) (TTV 100 (STV-0.9-0.8))) .
- The returned array must be a subset of the originally provided list of rules.
- The array must be sorted by relevance to the conversation summary, with the most relevant rules first.
- Do not include any explanations, comments, or additional text in your response.
- Preserve the exact syntax format as specified.
"""
    system_message.format(
        conversation_summary=state.get("summary", ""),
        rules_list=config.get("rules_list", ""),
        userResponse=state.get("messages")[-1].content,
    )

    messages = [system_message] + state["messages"]
    response = correlation_model.invoke(messages)

    # print(response)
    # rules_list = [schema for schema in response.rules]  # Extract rule strings
    # response_content = json.dumps(rules_list)  # Convert to JSON array string

    # Append as AIMessage to messages
    # state["messages"] = state["messages"] + [AIMessage(content=response_content)]
    return {
        "messages": state["messages"],
        "summary": state["summary"],
        "rules_list": response.rules,
    }


corr_graph = StateGraph(AgentState)
corr_graph.add_node("corr_agent", call_correlation_model)
corr_graph.set_entry_point("corr_agent")
corr_graph.add_edge("corr_agent", END)

corr_agent = corr_graph.compile()


def correlate(
    conversation_summary: str, rules_list: str, userResponse: str
) -> List[str]:
    config = {"configurable": {"rules_list": rules_list, "thread_id": "1"}}
    response = corr_agent.invoke(
        {
            "messages": [HumanMessage(content=userResponse)],
            "summary": conversation_summary,
        },
        config=config,
    )

    return response.get("rules_list", [])

    # for candidate in response.candidates:
    #     for part in candidate.content.parts:
    #         if hasattr(part, "text"):
    #             result += part.text.strip()
    #
    # # Parse the JSON string into a Python list
    # try:
    #     rules_array = json.loads(result.strip())
    #     return rules_array
    # except json.JSONDecodeError as e:
    #     print(f"Error decoding JSON from Gemini response: {e}")
    #     print(f"Raw response: {result.strip()}")
    #     return []  # Return an empty list or handle the error as appropriate


def parse_schema(schema: Schema) -> str:
    """A function that parses a cognitive Schema into represented in Python to MeTTa structure."""
    # Assuming context, action, and goal are already in the correct Metta format
    # Format weight as an integer to match the expected output
    return f"""((: {schema.handle} ({schema.tv} (IMPLICATION_LINK (AND_LINK ({schema.context} {schema.action})) {schema.goal}))) {schema.weight})"""


def correlation_matcher(
    conversation_summary: str, rules_list: str, userResponse: str
) -> str:
    """
    This function takes the conversation summary and the list of rules as input,
    correlates them, validates the syntax and existence of the selected rules,
    and returns the most relevant validated rule as a Schema object.
    Returns None if no valid rule is found.
    """
    raw_rules_string = correlate(
        conversation_summary=conversation_summary,
        rules_list=rules_list,
        userResponse=userResponse,
    )
    # print("Raw rules: ", raw_rules_string)
    # print(type(raw_rules_string))

    for rule_string in raw_rules_string:
        print("validating synthax: ", validateSyntax(rule_string))

        if rule_string in raw_rules_string:
            return rule_string

    # Return None if no valid rule is found after checking all selected rules
    return ""


# res = correlation_matcher(
#     "The user introduced themselves as Sam",
#     """
# ((: r1 ((TTV 1 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Conversation-Started 0.9 0.6) initiate-dialogue)) (Goal Send-Greeting 1.0 1.0)))) 4)
# ((: r2 ((TTV 2 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Send-Greeting 0.9 0.6) elicit-response)) (Goal Receive-User-Response 1.0 1.0)))) 7)
# ((: r3a ((TTV 3 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Receive-User-Response 0.9 0.6) interpret-mood)) (Goal Understand-Initial-Mood 1.0 1.0)))) 8)
# ((: r3b ((TTV 3 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Receive-User-Response 0.9 0.6) interpret-context)) (Goal Understand-Initial-Context 1.0 1.0)))) 5)
# ((: r4 ((TTV 4 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Understand-Initial-Mood 0.9 0.6) probe-mood)) (Goal Explore-Mood-Details 1.0 1.0)))) 6)
# ((: r5 ((TTV 5 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Explore-Mood-Details 0.9 0.6) ask-activities)) (Goal Ask-Daily-Activities 1.0 1.0)))) 5)
# ((: r6 ((TTV 6 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Understand-Initial-Context 0.9 0.6) request-activities)) (Goal Ask-Daily-Activities 1.0 1.0)))) 3)
# ((: r7 ((TTV 7 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Ask-Daily-Activities 0.9 0.6) collect-activity-details)) (Goal Learn-Activity-Details 1.0 1.0)))) 2)
# ((: r8a ((TTV 8 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Learn-Activity-Details 0.9 0.6) explore-hobbies)) (Goal Understand-Hobby-Preferences 1.0 1.0)))) 9)
# ((: r8b ((TTV 8 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Learn-Activity-Details 0.9 0.6) explore-goals)) (Goal Understand-Future-Goals 1.0 1.0)))) 7)
# ((: r9 ((TTV 9 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Understand-Hobby-Preferences 0.9 0.6) query-aspirations)) (Goal Summarize-User-Preferences 1.0 1.0)))) 4)
# ((: r10 ((TTV 10 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Understand-Future-Goals 0.9 0.6) synthesize-preferences)) (Goal Summarize-User-Preferences 1.0 1.0)))) 6)
# ((: r11 ((TTV 11 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Summarize-User-Preferences 0.9 0.6) finalize-understanding)) (Goal Understand-User-Interests 1.0 1.0)))) 10)
# ((: d1 ((TTV 12 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Receive-User-Response 0.9 0.6) discuss-random-topic)) (Goal Off-Topic-Discussion 1.0 1.0)))) 10)
# ((: d2 ((TTV 13 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Understand-Initial-Mood 0.9 0.6) share-joke)) (Goal Engage-User-Fun 1.0 1.0)))) 9)
# ((: d3 ((TTV 14 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Ask-Daily-Activities 0.9 0.6) redirect-conversation)) (Goal Send-Greeting 1.0 1.0)))) 8)
# ((: d4 ((TTV 15 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Learn-Activity-Details 0.9 0.6) offer-advice)) (Goal Provide-Feedback 1.0 1.0)))) 10)
# ((: d5 ((TTV 16 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Understand-Hobby-Preferences 0.9 0.6) explore-unrelated-topics)) (Goal Off-Topic-Discussion 1.0 1.0)))) 7)
# ((: d6 ((TTV 17 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Understand-Future-Goals 0.9 0.6) ask-irrelevant-question)) (Goal Irrelevant-Topic 1.0 1.0)))) 9)
# ((: d7 ((TTV 18 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Explore-Mood-Details 0.9 0.6) share-story)) (Goal Engage-User-Story 1.0 1.0)))) 8)
# """,
#     "I want to learn a new hobby",
# )
# print(res)
