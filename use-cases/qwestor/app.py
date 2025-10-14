from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List
import subprocess



# ----- Schemas -----
class Item(BaseModel):
    id: int
    name: str
    description: str | None = None

# Fake in-memory database
items_db: List[Item] = []


app = FastAPI(title="Qwestor PoC")



@app.get("/")
def root():
    return {"message": "Welcome to the PoC qwestor Motivation System"}
@app.post("/plan")
def plan(data: dict):
    result = subprocess.run("metta main-loop.metta", shell=True, capture_output=True, text=True)
    return result.stdout.strip()

