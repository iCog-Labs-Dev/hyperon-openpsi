from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List
from .utils import *
import subprocess






app = FastAPI(title="Qwestor PoC")


@app.get("/")
def root():
    return {"message": "Welcome to the PoC qwestor Motivation System"}
@app.post("/plan")
def plan():
    result = subprocess.run("metta main-loop.metta", shell=True, capture_output=True, text=True).stdout.strip()
    persistAtomspaceResult(result)
    return result

