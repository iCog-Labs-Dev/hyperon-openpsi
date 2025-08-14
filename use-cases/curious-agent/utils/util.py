from typing import List

from langchain_core.runnables import RunnableConfig
# from google import genai

from langgraph.checkpoint.memory import InMemorySaver

# from google.genai import types
# from ..base import Schema

import re

# from adapter import *
from hyperon import *
from hyperon.ext import register_atoms
from hyperon.atoms import (
    OperationAtom,
    ValueAtom,
    ExpressionAtom,
)
import os
from dotenv import load_dotenv

from typing import Annotated, TypedDict

from langgraph.graph import add_messages, MessagesState, StateGraph
from langchain_core.messages import (
    HumanMessage,
    RemoveMessage,
    SystemMessage,

)
from langgraph.graph import END
from langchain_google_genai import ChatGoogleGenerativeAI

from pydantic import BaseModel

import re
import re

import re

def validateSyntax(rule: str) -> bool:
    rule = rule.strip()
    
    # Adjusted regex to support underscores and multi-line formatting
    pattern = re.compile(
        r'''
        ^\(\(:\s*\w+\s+                                   # rule ID (e.g., r7)
        \(\(TTV\s+\d+\s+\(STV\s+[0-9.]+\s+[0-9.]+\)\)\s+   # TTV and STV
        \(IMPLICATION_LINK\s+
            \(AND_LINK\s+
                \(\(Goal\s+[\w\-]+                         # Goal name (allowing _)
                \s+[0-9.]+\s+[0-9.]+\)\s+                   # Goal confidence values
                [\w\-]+\)\)\s+                             # Action name (with _ allowed)
            \(Goal\s+[\w\-]+\s+[0-9.]+\s+[0-9.]+\)         # Goal conclusion
        \)\)\)\s+[0-9.]+\)$                                # trailing number (score)
        ''',
        re.VERBOSE | re.DOTALL
    )

    return bool(pattern.match(rule))


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
    model="gemini-1.5-flash",  # Specify the model (e.g., gemini-1.5-flash, gemini-1.5-pro)
    temperature=0,  # Control randomness (0 for deterministic)
    max_tokens=None,  # Maximum tokens in response (optional)
    timeout=None,  # Request timeout (optional)
    max_retries=2,  # Number of retries for failed requests
    google_api_key=api_key,  # Use environment variable
)
summarization_model = ChatGoogleGenerativeAI(
    model="gemini-1.5-flash",  # Specify the model (e.g., gemini-1.5-flash, gemini-1.5-pro)
    temperature=0,  # Control randomness (0 for deterministic)
    max_tokens=None,  # Maximum tokens in response (optional)
    timeout=None,  # Request timeout (optional)
    max_retries=2,  # Number of retries for failed requests
    google_api_key=api_key,  # Use environment variable
)


model = ChatGoogleGenerativeAI(
    model="gemini-1.5-flash",  # Specify the model (e.g., gemini-1.5-flash, gemini-1.5-pro)
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
    print(f"""call_model:
          system prompt : {system_prompt_with_context}
          """)
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
    # print("Args : ", args)
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
    

    # Properly format the system message
    system_message_template = """
Your task is to select and sort cognitive schematic rules from the list provided in {rules_list}, based on their relevance to the current chat conversation summary ({conversation_summary}) and the latest user response ({userResponse}).

Each rule follows this strict format:
((: {{handle}} ({{tv}}) (IMPLICATION_LINK (AND_LINK (({{context}}) {{action}})) ({{goal}})))) {{weight}})

Where:
- {{handle}} is the symbolic name for the rule (e.g., r1)
- {{tv}} is the truth value format, e.g., (TTV 1 (STV 0.8 0.7))
- {{context}} is a Goal expression that defines the context (e.g., (Goal Conversation-Started 0.9 0.6))
- {{action}} is the action to take (e.g., initiate-dialogue)
- {{goal}} is the target Goal of the implication (e.g., (Goal Send-Greeting 1.0 1.0))
- {{weight}} is a number between 0 and 2 indicating the rule's strength

Instructions:
- From the provided {rules_list}, select the most relevant rules and return them as a JSON object conforming to the `SchemaList` structure.
- The `SchemaList` object should contain a `rules` field, which is a list of `Schema` objects.
- Each `Schema` object must accurately represent a rule from the {rules_list} by extracting its components:
    - `handle`: The symbolic name (e.g., "r1").
    - `tv`: The full truth value expression (e.g., "(TTV 1 (STV 0.8 0.7))").
    - `context`: The full context Goal expression (e.g., "(Goal Conversation-Started 0.9 0.6)").
    - `action`: The action string (e.g., "initiate-dialogue").
    - `goal`: The full target Goal expression (e.g., "(Goal Send-Greeting 1.0 1.0)").
    - `weight`: The final strength or value (e.g., 4 or 7.0).
- The `rules` array in the `SchemaList` must be a **subset** of the original {rules_list}, sorted in descending order of relevance to the conversation.
- You must **not add**, **modify**, or generate new rules.
- Do **not** include any explanations, comments, or formatting outside of the JSON object.
"""


    system_message_text = system_message_template.format(
        conversation_summary=state.get("summary", ""),
        rules_list=config.get("metadata").get("rules_list", ""),
        userResponse=state.get("messages")[-1].content,
    )
    print(f"Current System Message {system_message_text}")

    # Compose message list (assuming LangChain-style message objects)
    messages = [SystemMessage(content=system_message_text)] + state["messages"]

    # Call the model with structured message history
    response = correlation_model.invoke(messages)

    print(f"response: {response}")

    # Parse rules from response
    # Assuming response is a dict with .rules or a stringified JSON array
    

    # Return updated state
    return {
        "messages": state["messages"] ,
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
    """Parses a cognitive Schema into properly formatted MeTTa-compatible syntax."""
    return f"""((: {schema.handle} (({schema.tv}) 
        (IMPLICATION_LINK 
          (AND_LINK (({schema.context}) {schema.action})) 
          ({schema.goal})))) {schema.weight})"""


def rules_to_lists(rules: str) -> List[str]:
    """
    Parses a string of rules and converts it into a list of individual rule strings.
    """
    # This regex splits the string based on the start of a new rule `((:`.
    # The `(?=\(\(:\s*\w)` is a positive lookahead that asserts that the following characters match the pattern, without including them in the split.
    rule_list = re.split(r"\s*(?=\(\(:\s*\w)", rules.strip())
    # The first element might be empty if the string starts with the delimiter, so filter it out.
    return [rule.strip() for rule in rule_list if rule.strip()]


def correlation_matcher(
    conversation_summary: str, rules: str, userResponse: str
) -> str:
    """
    This function takes the conversation summary and the list of rules as input,
    correlates them, validates the syntax and existence of the selected rules,
    and returns the most relevant validated rule as a Schema object.
    Returns None if no valid rule is found.
    """
    correlated_schema_list = correlate(
        conversation_summary=conversation_summary,
        rules_list=rules,
        userResponse=userResponse,
    )
    print("Raw rules: ", correlated_schema_list)
    # print(type(raw_rules_string))
    # rules_list = rules_to_lists(raw_rules_string)
    rules_list = [parse_schema(schema) for schema in correlated_schema_list]
    print("Parsed rules: ", rules_list)

    for rule_string in rules_list:
        print(f"""validating synthax: {validateSyntax(rule_string)}

for the rule : {rule_string}

              """)

        if validateSyntax(rule_string):
        # if rule_string in rule_list: TODO: enforce this later with the existence validator.
            return rule_string

    # Return None if no valid rule is found after checking all selected rules
    return ""

if __name__ == "__main__":
    rules = """
    ((: r2 (TTV 2 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Send-Greeting 0.9 0.6) elicit-response)) (Goal Receive-User-Response 1.0 1.0)))) 7)
    (((: r1 ((TTV 1 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Conversation-Started 0.9 0.6) initiate-dialogue)) (Goal Send-Greeting 1.0 1.0)))) 4)
    ((: r2 ((TTV 2 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Send-Greeting 0.9 0.6) elicit-response)) (Goal Receive-User-Response 1.0 1.0)))) 7.0)
    ((: r3a ((TTV 3 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Receive-User-Response 0.9 0.6) interpret-mood)) (Goal Understand-Initial-Mood 1.0 1.0)))) 8)
    ((: r3b ((TTV 3 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Receive-User-Response 0.9 0.6) interpret-context)) (Goal Understand-Initial-Context 1.0 1.0)))) 5)
    ((: r4 ((TTV 4 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Understand-Initial-Mood 0.9 0.6) probe-mood)) (Goal Explore-Mood-Details 1.0 1.0)))) 6)
    ((: r5 ((TTV 5 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Explore-Mood-Details 0.9 0.6) ask-activities)) (Goal Ask-Daily-Activities 1.0 1.0)))) 5)
    ((: r6 ((TTV 6 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Understand-Initial-Context 0.9 0.6) request-activities)) (Goal Ask-Daily-Activities 1.0 1.0)))) 3)
    ((: r7 ((TTV 7 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Ask-Daily-Activities 0.9 0.6) collect-activity-details)) (Goal Learn-Activity-Details 1.0 1.0)))) 2)
    ((: r8a ((TTV 8 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Learn-Activity-Details 0.9 0.6) explore-hobbies)) (Goal Understand-Hobby-Preferences 1.0 1.0)))) 9)
    ((: r8b ((TTV 8 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Learn-Activity-Details 0.9 0.6) explore-goals)) (Goal Understand-Future-Goals 1.0 1.0)))) 7)
    ((: r9 ((TTV 9 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Understand-Hobby-Preferences 0.9 0.6) query-aspirations)) (Goal Summarize-User-Preferences 1.0 1.0)))) 4)
    ((: r10 ((TTV 10 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Understand-Future-Goals 0.9 0.6) synthesize-preferences)) (Goal Summarize-User-Preferences 1.0 1.0)))) 6)
    ((: r11 ((TTV 11 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Summarize-User-Preferences 0.9 0.6) finalize-understanding)) (Goal Understand-User-Interests 1.0 1.0)))) 10)
    ((: d1 ((TTV 12 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Receive-User-Response 0.9 0.6) discuss-random-topic)) (Goal Off-Topic-Discussion 1.0 1.0)))) 10)
    ((: d2 ((TTV 13 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Understand-Initial-Mood 0.9 0.6) share-joke)) (Goal Engage-User-Fun 1.0 1.0)))) 9)
    ((: d3 ((TTV 14 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Ask-Daily-Activities 0.9 0.6) redirect-conversation)) (Goal Send-Greeting 1.0 1.0)))) 8)
    ((: d4 ((TTV 15 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Learn-Activity-Details 0.9 0.6) offer-advice)) (Goal Provide-Feedback 1.0 1.0)))) 10)
    ((: d5 ((TTV 16 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Understand-Hobby-Preferences 0.9 0.6) explore-unrelated-topics)) (Goal Off-Topic-Discussion 1.0 1.0)))) 7)
    ((: d6 ((TTV 17 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Understand-Future-Goals 0.9 0.6) ask-irrelevant-question)) (Goal Irrelevant-Topic 1.0 1.0)))) 9)
    ((: d7 ((TTV 18 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal Explore-Mood-Details 0.9 0.6) share-story)) (Goal Engage-User-Story 1.0 1.0)))) 8))
    """
    print(rules_to_lists(rules))
    res = correlation_matcher(
        "The user introduced themselves as Sam",
        rules,
        "I want to learn a new hobby",
    )
    print(res)
