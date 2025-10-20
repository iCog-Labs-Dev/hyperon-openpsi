from typing import Optional
from pydantic import BaseModel


class RuleCreate(BaseModel):
    action: Optional[str] = None
    context: Optional[str] = None
    goal: Optional[str] = None


class Rules(BaseModel):
    rules: RuleCreate


class ContextCreate(BaseModel):
    current_state: str
