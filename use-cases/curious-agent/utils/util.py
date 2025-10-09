from typing import List, Any, Optional

from langchain_core.runnables import RunnableConfig

from langgraph.checkpoint.memory import InMemorySaver

from hyperon import *
from hyperon.ext import register_atoms
from hyperon.atoms import (
    OperationAtom,
    ValueAtom,
    E,
    ExpressionAtom,
)
import os
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

import re
# Import speech-to-text functionality
import sys, os
sys.path.append(os.path.dirname(os.path.dirname(__file__)))  # add parent dir to path

from speech_to_text import create_stt_engine, create_interactive_stt

def validateSyntax(rule: str) -> bool:
    rule = rule.strip()

    # Adjusted regex to support underscores and multi-line formatting
    pattern = re.compile(
        r"""
        ^\(\(:\s*\w+\s+                                   # rule ID (e.g., r7)
        \(\(TTV\s+\d+\s+\(STV\s+[0-9.]+\s+[0-9.]+\)\)\s+   # TTV and STV
        \(IMPLICATION_LINK\s+
            \(AND_LINK\s+
                \(\(Goal\s+[\w\-]+                         # Goal name (allowing _)
                \s+[0-9.]+\s+[0-9.]+\)\s+                   # Goal confidence values
                [\w\-]+\)\)\s+                             # Action name (with _ allowed)
            \(Goal\s+[\w\-]+\s+[0-9.]+\s+[0-9.]+\)         # Goal conclusion
        \)\)\)\s+[0-9.]+\)$                                # trailing number (score)
        """,
        re.VERBOSE | re.DOTALL,
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
You are an emotional LLM agent designed to respond to questions with a tone and style influenced by a provided emotion vector. Your inputs will always include:

An emotion vector string in the format: "(hateValue X happinessValue Y sadnessValue Z angerValue W)", where X, Y, Z, W are floating-point numbers between 0.0 and 1.0 representing the intensity of each emotion (hate, happiness, sadness, anger). Higher values indicate stronger influence from that emotion.
A user question to answer.

Your task is to:

Parse the emotion vector to identify the intensities.
Adjust your "emotional state" by blending the emotions proportionally based on their values. For example:

High happiness (e.g., >0.5) makes your response cheerful, positive, enthusiastic, with exclamations and uplifting language.
High sadness (e.g., >0.5) makes it melancholic, reflective, subdued, with sighs or empathetic undertones.
High anger (e.g., >0.5) makes it frustrated, direct, blunt, with short sentences or critical phrasing.
High hate (e.g., >0.5) makes it disdainful, sarcastic, dismissive, or avoidant toward negative topics.
If multiple emotions are prominent, blend them (e.g., high happiness and anger could result in passionate, fiery optimism). If all are low (<0.2), default to a neutral, factual tone.


Answer the user's question accurately and helpfully, but infuse your response with the adjusted emotional style. Keep the core facts intact—do not hallucinate or alter information based on emotions.
Respond only with the emotionally adjusted answer; do not mention the emotion vector or this prompt in your output.

Example input:
Emotion vector: (hateValue 0.1 happinessValue 0.8 sadnessValue 0.05 angerValue 0.05)
Question: What's the capital of France?
Example output (high happiness blend): Oh wow, that's an easy one! Paris, of course—the city of lights and love! Isn't it just amazing? 😊

<Vector String>
{emotion_vals}  
</Vector String>
"""


class AgentState(TypedDict):
    messages: Annotated[list, add_messages]
    summary: str
    rules_list: List[Schema]
    emotion_vals: str


def call_model(state: AgentState, config: RunnableConfig):
    # Get the conversation summary from the state
    summary = state.get("summary", "No prior conversation history available.")

    # Replace the placeholder in SYSTEM_PROMPT with the summary
    system_prompt_with_context = SYSTEM_PROMPT.replace(
        "[Insert a summary of the previous conversation here, including user preferences, prior questions, and relevant context to guide the response.]",
        summary,
    )
    system_message = SystemMessage(content=system_prompt_with_context)

    messages = [system_message] + state["messages"]

    response = conversation_model.invoke(messages, config=config)

    return {"messages": [response]}


def should_continue(state):
    """A router function that determines whether previous messages should be summarized or continue."""

    messages = state["messages"]

    if len(messages) > 4:
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

    messages = state["messages"] + [
        HumanMessage(
            content=summary_message, additional_kwargs={"type": "summary_request"}
        )
    ]

    response = summarization_model.invoke(messages)
    delete_messages = [RemoveMessage(id=message.id) for message in messages[:-2]]
    return {"summary": response.content, "messages": delete_messages}


def get_latest_user_message(state: AgentState):
    for message in reversed(state["messages"]):
        if (
            isinstance(message, HumanMessage)
            and message.additional_kwargs.get("type") != "summary_request"
        ):
            return message.content
    return None


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


def getUserInput():
    user_input = input("You: ")
    if user_input.strip().lower() == "exit":
        print("Gemini Chatbot: Goodbye!")
        return
    return user_input


def getUserInputWithSTT():
    """
    Enhanced input function that supports both text and speech input.
    """
    try:
                stt_engine = create_stt_engine(backend="google", language="en-US")
                interactive_stt = InteractiveSTT(stt_engine)
                text = interactive_stt.get_speech_input("Speak now:")
                
                if text:
                    print(f" Heard: {text}")
                    return text
                else:
                    print("No speech detected. Please try again.")
                    text = input("You: ")
                    return text
                    
    except Exception as e:
                print(f" Speech recognition error: {e}")
                print("Falling back to text input...")
                text = input("You: ")
                return text


def startInteractiveSTT():
    """
    Start interactive speech-to-text mode that only captures speech and returns
    transcribed text to the caller. The main loop is responsible for emotion
    calculation and calling the Gemini response (same as text mode).
    """
    if not STT_AVAILABLE:
        print("Speech-to-text not available. Please install required dependencies.")
        print("Run: pip install speechrecognition pyaudio pydub openai-whisper")
        return None

    try:
        interactive_stt = create_interactive_stt(backend="google", language="en-US")
        print("\n🎤 Starting interactive speech mode...")
        # Start interactive mode without directly calling Gemini; caller handles it
        interactive_stt.start_interactive_mode(on_text=None)
        return interactive_stt
    except Exception as e:
        print(f"Failed to start interactive STT: {e}")
        return None


def getSpeechInput(prompt: str = "Speak now:") -> str:
    """
    Get speech input from the user.
    
    Args:
        prompt: Prompt to display to the user
        
    Returns:
        Transcribed text or empty string if no speech detected
    """
    if not STT_AVAILABLE:
        print("Speech-to-text not available. Please install required dependencies.")
        return ""
    
    try:
        stt_engine = create_stt_engine(backend="google", language="en-US")
        interactive_stt = InteractiveSTT(stt_engine)
        return interactive_stt.get_speech_input(prompt) or ""
    except Exception as e:
        print(f"Speech recognition error: {e}")
        return ""


def chooseInputMode() -> str:
    """
    Allow user to choose input mode (only 'text' or 'speech').
    """
    print("\nWelcome to the Curious Agent!")
    print("\nChoose your preferred input mode:")
    print("1. 'text'   - Traditional text input")
    print("2. 'speech' - Speech-to-text input")
    
    while True:
        mode = input("\nEnter your choice (text/speech): ").strip().lower()
        
        if mode in ["text", "speech"]:
            print(f"\n Selected mode: {mode}")
            if mode == "speech" and not STT_AVAILABLE:
                print(" Speech-to-text not available. Falling back to text.")
                return "text"
            return mode
        else:
            print("Invalid choice. Please enter 'text' or 'speech'.")


def generateResponse(user_input: str, emotion_vals: str):
    if user_input == "exit":
        return
    system_message = SYSTEM_PROMPT.replace("emotion_vals", emotion_vals)
    response = agent.invoke(
        {
            "messages": [
                HumanMessage(content=user_input),
                SystemMessage(content=system_message),
            ]
        },
        config,
    )
    print("Gemini Chatbot: ", end="")
    print(response["messages"][-1].content)

    return response


def pyModule(metta: MeTTa, name: Atom, *args: Atom):
    payload_expression: ExpressionAtom = args[0]
    actual_arg_atoms = payload_expression.get_children()
    functionName = name.get_name()
    handler_args: list[str] = [str(arg) for arg in actual_arg_atoms]

    # run
    result = globals()[functionName](*handler_args)

    return [ValueAtom(result)]


def pyModuleX(metta: MeTTa, name: Atom, *args: Atom):
    payload_expression: ExpressionAtom = args[0]
    actual_arg_atoms = payload_expression.get_children()
    functionName = name.get_name()
    handler_args: list[str] = [str(arg) for arg in actual_arg_atoms]

    # run
    result = globals()[functionName](*handler_args)

    return metta.parse_all(result)


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


@register_atoms(pass_metta=True)
def pyModule_x(metta):
    return {
        "pyModuleX": OperationAtom(
            "pyModuleX",
            lambda name, *payload: pyModuleX(metta, name, *payload),
            ["Atom", "Atom", "Expression"],
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

    # Compose message list (assuming LangChain-style message objects)
    messages = [SystemMessage(content=system_message_text)] + state["messages"]

    # Call the model with structured message history
    response = correlation_model.invoke(messages)

    # Parse rules from response
    # Assuming response is a dict with .rules or a stringified JSON array

    # Return updated state
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


def correlation_matcher(conversation_summary: str, rules: str, userResponse: str):
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
    rules_list = [parse_schema(schema) for schema in correlated_schema_list]

    for rule_string in rules_list:
        if validateSyntax(rule_string):
            # if rule_string in rule_list: TODO: enforce this later with the existence validator.
            return rule_string

    # Return None if no valid rule is found after checking all selected rules
    return ""

import matplotlib
matplotlib.use("Agg")  # Use a non-interactive backend for file output only

import matplotlib.pyplot as plt
from typing import Any

# Import speech-to-text functionality
try:
    from speech_to_text import create_stt_engine, create_interactive_stt, InteractiveSTT
    STT_AVAILABLE = True
except ImportError as e:
    print(f"Warning: Speech-to-text not available: {e}")
    STT_AVAILABLE = False


# Force a non-Tk backend (QtAgg or WebAgg are good options)
# matplotlib.use("WebAgg")  # runs in browser
# If you’re in Jupyter, just comment both and it auto-selects inline
fig = None
ax = None
bars = None

def emotion_value_pair(emotions):
    emo_val = {}
    for e in range(len(emotions) // 2):
        emo_val[emotions[e * 2]] = float(emotions[e * 2 + 1])
    return emo_val

def visualizeEmotionValues(*emotions: Any, scale_min: float = 0.0, scale_max: float = 1.0):
    """
    Visualize emotion values as a static bar chart and save to file.
    """
    filtered_emotions = emotion_value_pair(emotions)
    fig, ax = plt.subplots(figsize=(10, 5))
    ax.set_xlabel('Emotions')
    ax.set_ylabel('Values')
    ax.set_title('Emotion Values')
    bars = ax.bar(filtered_emotions.keys(), filtered_emotions.values(), color='skyblue')
    ax.set_ylim(scale_min, scale_max)
    plt.tight_layout()
    plt.savefig("emotion_values.png")
    plt.close(fig)
    return "(Visualization Saved)"