import asyncio
import platform
from datetime import datetime
from enum import Enum
from typing import Callable, List, Dict, Any, Union
import inspect

# Standard log levels
class LogLevel(Enum):
    DEBUG = "debug"
    INFO = "info"
    WARNING = "warning"
    ERROR = "error"
    CRITICAL = "critical"

# Base event class
class LogEvent:
    def __init__(self, event_type: str, timestamp: datetime, **kwargs):
        self.event_type = event_type
        self.timestamp = timestamp
        self.data = kwargs

# Specific event class for modulator updates
class ModulatorUpdateEvent(LogEvent):
    def __init__(self, modulator_name:str,previous_value: float, current_value: float):
        super().__init__("modulator_update", datetime.now(), 
                        modulator_name= modulator_name,
                        previous_value=previous_value, 
                        current_value=current_value)

class EventLogger:
    def __init__(self):
        # Handlers for both standard log levels and custom events
        self.handlers: Dict[str, List[Callable[[LogEvent], Any]]] = {}
        
    def register_handler(self, event_type: Union[LogLevel, str], 
                       handler: Callable[[LogEvent], Any]):
        """Register a handler for an event type (standard or custom)"""
        event_key = event_type.value if isinstance(event_type, LogLevel) else event_type
        if event_key not in self.handlers:
            self.handlers[event_key] = []
        self.handlers[event_key].append(handler)
        
    def trigger_event(self, event: LogEvent):
        """Trigger any type of log event"""
        event_key = event.event_type
        if event_key in self.handlers:
            for handler in self.handlers[event_key]:
                handler(event)
                
    async def trigger_event_async(self, event: LogEvent):
        """Asynchronously trigger any type of log event"""
        event_key = event.event_type
        if event_key in self.handlers:
            tasks = []
            for handler in self.handlers[event_key]:
                if inspect.iscoroutinefunction(handler):
                    tasks.append(handler(event))
                else:
                    handler(event)  # Call sync handlers directly
            if tasks:  # Only gather if we have async tasks
                await asyncio.gather(*tasks)
            
    # Convenience methods for standard logging
    def log(self, level: LogLevel, message: str):
        event = LogEvent(level.value, datetime.now(), message=message)
        self.trigger_event(event)
        
    def modulator_update(self,modulator_name:str, previous_value: float, current_value: float):
        event = ModulatorUpdateEvent(modulator_name,previous_value, current_value)
        self.trigger_event(event)

# Example handlers
def console_handler(event: LogEvent):
    if event.event_type in [level.value for level in LogLevel]:
        print(f"[{event.timestamp}] {event.event_type.upper()}: {event.data['message']}")

async def async_console_handler(event: LogEvent):
    if event.event_type in [level.value for level in LogLevel]:
        await asyncio.sleep(0.1)  # Simulate async work
        print(f"[{event.timestamp}] ASYNC {event.event_type.upper()}: {event.data['message']}")
        
def modulator_handler(event: LogEvent):
    if event.event_type == "modulator_update":
        diff = event.data['current_value'] - event.data['previous_value']
        print(f"[{event.timestamp}] MODULATOR_UPDATED: {event.data['modulator_name']} {event.data['previous_value']} -> "
              f"{event.data['current_value']} (diff: {diff})")

# Example usage
logger = EventLogger()
logger.register_handler(LogLevel.INFO, console_handler)
logger.register_handler(LogLevel.INFO, async_console_handler)
logger.register_handler(LogLevel.ERROR, console_handler)
logger.register_handler("modulator_update", modulator_handler)

def mofi(modulator_name, previous_value, current_value):
     event = ModulatorUpdateEvent(modulator_name,previous_value, current_value)
     logger.trigger_event(event)
    
