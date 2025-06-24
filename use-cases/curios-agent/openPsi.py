from pydantic import BaseModel
from typing import List


class Schema(BaseModel):
    handle: str
    context: str
    action: str
    goal: str
    tv: str


def parse_sexp(sexpr: str) -> List[Schema]:
    """A function that parses an expression from MeTTa to Python."""
    pass
