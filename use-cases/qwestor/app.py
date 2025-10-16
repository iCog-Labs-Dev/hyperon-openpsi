from fastapi import FastAPI
import asyncio
from typing import List
from .utils import *

app = FastAPI(title="Qwestor PoC")

@app.get("/")
def root():
    return {"message": "Welcome to the PoC qwestor Motivation System"}

@app.post("/plan")
async def plan():
    process = await asyncio.create_subprocess_shell(
        "metta main-loop.metta",
        stdout=asyncio.subprocess.PIPE,
        stderr=asyncio.subprocess.PIPE
    )

    stdout, stderr = await process.communicate()

    if process.returncode != 0:
        return {"error": f"metta failed with code {process.returncode}", "stderr": stderr.decode()}
    result = stdout.decode().strip()
    refinedOutput = preprocessRawOutput(result)
    actions_expression = refinedOutput[-1]
    json_result = {"actions": changeSexpToList(actions_expression)}
    await asyncio.to_thread(writeListToFile, refinedOutput, "out.metta")

    return json_result


@app.get("/fetchModulators")
async def fetchModulators():
    process = await asyncio.create_subprocess_shell(
        "metta fetch-modulators.metta",
        stdout=asyncio.subprocess.PIPE,
        stderr=asyncio.subprocess.PIPE
    )

    stdout, stderr = await process.communicate()

    if process.returncode != 0:
        return {"error": f"metta failed with code {process.returncode}", "stderr": stderr.decode()}
    result = stdout.decode().strip()
    refinedOutput = preprocessRawOutput(result)
    modulatorSexp = refinedOutput[-1]
    return {"modulators": preprocessMechanicsOutput(modulatorSexp, "modulator")}



@app.get("/fetchDemands")
async def fetchDemands():
    process = await asyncio.create_subprocess_shell(
        "metta fetch-demands.metta",
        stdout=asyncio.subprocess.PIPE,
        stderr=asyncio.subprocess.PIPE
    )

    stdout, stderr = await process.communicate()

    if process.returncode != 0:
        return {"error": f"metta failed with code {process.returncode}", "stderr": stderr.decode()}
    result = stdout.decode().strip()
    refinedOutput = preprocessRawOutput(result)
    demandSexp = refinedOutput[-1]
    return {"demands": preprocessMechanicsOutput(demandSexp, "demand")}





