
# from datetime import datetime
# from utils.logger import EventLogger, eventLogger
# from utils.logger import LogEvent



# # Specific event class for modulator updates
# class ModulatorUpdateEvent(LogEvent):
#     def __init__(self, modulator_name:str,previous_value: float, current_value: float):
#         super().__init__("modulator_update", datetime.now(), 
#                         modulator_name= modulator_name,
#                         previous_value=previous_value, 
#                         current_value=current_value)


# def modulator_handler(event: LogEvent):
#     if event.event_type == "modulator_update":
#         diff = event.data['current_value'] - event.data['previous_value']
#         print(f"[{event.timestamp}] MODULATOR_UPDATED: {event.data['modulator_name']} {event.data['previous_value']} -> "
#               f"{event.data['current_value']} (diff: {diff})")
# # def mofi(modulator_name, previous_value, current_value):
# #      event = ModulatorUpdateEvent(modulator_name,previous_value, current_value)
# #      eventLogger.trigger_event(event)
# # Example usage
# eventLogger = EventLogger()
# eventLogger.register_handler("modulator_update", modulator_handler)

    
# def test(text):
#     print(text)