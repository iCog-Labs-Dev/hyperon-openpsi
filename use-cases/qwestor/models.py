from pydantic import BaseModel


class Modulator(BaseModel):
    modulatorName: str
    modulatorValue: float

class Demand(BaseModel):
    demandName: str
    demandValue: float

