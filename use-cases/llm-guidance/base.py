from pydantic import BaseModel

class Schema(BaseModel):
	handle: str
	context: str
	action: str
	goal: str
	tv: str | None = None
class Action(BaseModel):
	action_name: str
    
class StateParams(BaseModel):
    activation: float
    securing_threshold: float
    pleasure: float
    selection_threshold: float