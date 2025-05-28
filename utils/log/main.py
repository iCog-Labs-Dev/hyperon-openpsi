import logging
import sys
from hyperon import *
from hyperon.ext import register_atoms
from hyperon.atoms import OperationAtom, GroundedAtom, SymbolAtom, ValueAtom, ExpressionAtom

LOG_FILE_NAME = 'metta_events.log'
LOG_FORMAT = '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
CONSOLE_LOG_LEVEL = logging.DEBUG
FILE_LOG_LEVEL = logging.INFO
LOGGER_NAME = 'MeTTaLogger'

logger = logging.getLogger(LOGGER_NAME)
logger.setLevel(logging.DEBUG)

console_handler = logging.StreamHandler(sys.stdout)
console_handler.setLevel(CONSOLE_LOG_LEVEL)
console_formatter = logging.Formatter(LOG_FORMAT)
console_handler.setFormatter(console_formatter)
if not any(isinstance(h, logging.StreamHandler) for h in logger.handlers):
    logger.addHandler(console_handler)
    try:
        file_handler = logging.FileHandler(LOG_FILE_NAME)
        file_handler.setLevel(FILE_LOG_LEVEL)
        file_formatter = logging.Formatter(LOG_FORMAT)
        file_handler.setFormatter(file_formatter)
        logger.addHandler(file_handler)
        logger.info(f"--- Logger initialized. Logging to console (level {logging.getLevelName(CONSOLE_LOG_LEVEL)}) and file '{LOG_FILE_NAME}' (level {logging.getLevelName(FILE_LOG_LEVEL)}) ---")
    except Exception as e:
        logger.error(f"Failed to initialize file handler for {LOG_FILE_NAME}: {e}")
        print(f"ERROR: Failed to initialize file handler for {LOG_FILE_NAME}: {e}", file=sys.stderr)

def format_modulator_change(name: str, old_value: str, new_value: str) -> str:
    return f"[MODULATOR_UPDATE]-{name} {old_value}' -> {new_value}   diff={float(new_value) - float(old_value)}"

def format_feeling_update(feeling_name: str, old_value: str, new_value: str) -> str:
    return f"[FEELING_UPDATE]-{feeling_name} {old_value}' -> {new_value}  "  

def format_schema_update(schema_id: str, update_type: str, details: str) -> str:
    return f"[SCHEMA_UPDATE]-{schema_id} {update_type} {details}"

EVENT_HANDLERS = {
    "modulator_change": (format_modulator_change, logging.INFO),
    "modulator_debug": (format_modulator_change, logging.DEBUG),
    "feeling_update": (format_feeling_update, logging.INFO),
    "feeling_update_debug": (format_feeling_update, logging.DEBUG),
    "schema_update": (format_schema_update, logging.DEBUG),
}

def log_event_atom_execute(metta: MeTTa, event_type_atom: Atom, *args: Atom):
    try:
        if not isinstance(event_type_atom, SymbolAtom):
            logger.error(f"log-event: Expected Symbol for event_type, got {type(event_type_atom)}: {event_type_atom}")
            return []
        event_type = event_type_atom.get_name()

        handler_info = EVENT_HANDLERS.get(event_type)
        if handler_info is None:
            logger.error(f"log-event: No handler found for event type '{event_type}'")
            return []

        formatter_func, default_level = handler_info

        if len(args) != 1 or not isinstance(args[0], ExpressionAtom):
            arg_types = [type(a) for a in args]
            logger.error(f"log-event: Incorrect structure received. Expected a single ExpressionAtom as the second argument (payload), but got {len(args)} items with types {arg_types}. Content: {args}")
            return []

        payload_expression: ExpressionAtom = args[0]
        actual_arg_atoms = payload_expression.get_children()
        handler_args: list[str] = [str(arg) for arg in actual_arg_atoms]

        try:
            message = formatter_func(*handler_args)
        except TypeError as te:
             expected_args_count = formatter_func.__code__.co_argcount
             logger.error(f"log-event: Handler for '{event_type}' ({formatter_func.__name__}) called with wrong number of arguments. "
                          f"Expected {expected_args_count}, Got {len(handler_args)}. "
                          f"Payload expression content: {payload_expression}. Error: {te}")
             return []
        except Exception as e:
            logger.error(f"log-event: Error executing handler '{event_type}': {e}")
            return []

        logger.log(default_level, message)
        return []

    except Exception as e:
        logger.exception(f"log-event: Unexpected error processing log event: {e}")
        return []

@register_atoms(pass_metta=True)
def register_logger_atoms(metta):
    log_event_atom = OperationAtom(
        "log-event",
        lambda event_type, payload_expr: log_event_atom_execute(metta, event_type, payload_expr),
        ["Atom", "Expression", "Expression"],
        unwrap=False,
    )
    logger.info("`log-event` operation registered for MeTTa.")
    return {"log-event": log_event_atom}