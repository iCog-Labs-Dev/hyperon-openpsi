from fastapi import FastAPI
import asyncio
from typing import List

from fastapi import status
from schemas import RuleCreate, ContextCreate
from services import pair_to_goals
from utils import *

app = FastAPI(title="Qwestor PoC")


@app.get("/")
def root():
    return {"message": "Welcome to the PoC qwestor Motivation System"}


@app.post("/plan")
async def plan(payload: ContextCreate):
    try:
        process = await asyncio.create_subprocess_shell(
            "metta main-loop.metta",
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE,
        )

        stdout, stderr = await process.communicate()

        if process.returncode != 0:
            return {
                "error": f"metta failed with code {process.returncode}",
                "stderr": stderr.decode().strip(),
            }

        try:
            result = stdout.decode().strip()
            refinedOutput = preprocessRawOutput(result)
            actions_expression = refinedOutput[-1]
            json_result = {"actions": changeSexpToList(actions_expression)}

            await asyncio.to_thread(writeListToFile, refinedOutput, "out.metta")
            await asyncio.to_thread(
                writeListToFile,
                ["""(INPUT_CONTEXT {})""".replace("{}", payload.current_state)],
                "in.metta",
            )

            return json_result

        except Exception as e:
            return {"error": f"Processing error: {e}"}

    except Exception as e:
        return {"error": f"Unexpected server error: {e}"}


@app.get("/fetchModulators")
async def fetchModulators():
    try:
        process = await asyncio.create_subprocess_shell(
            "metta fetch-modulators.metta",
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE,
        )

        stdout, stderr = await process.communicate()

        if process.returncode != 0:
            return {
                "error": f"metta failed with code {process.returncode}",
                "stderr": stderr.decode(),
            }
        try:
            result = stdout.decode().strip()
            refinedOutput = preprocessRawOutput(result)
            modulatorSexp = refinedOutput[-1]
            return {"modulators": preprocessMechanicsOutput(modulatorSexp, "modulator")}
        except Exception as e:
            return {"error": f"processing Error {e}"}

    except Exception as e:
        return {"error": f"Unexpected server error: {e}"}


@app.get("/fetchDemands")
async def fetchDemands():
    try:
        process = await asyncio.create_subprocess_shell(
            "metta fetch-demands.metta",
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE,
        )

        stdout, stderr = await process.communicate()

        if process.returncode != 0:
            return {
                "error": f"metta failed with code {process.returncode}",
                "stderr": stderr.decode(),
            }
        try:
            result = stdout.decode().strip()
            refinedOutput = preprocessRawOutput(result)
            demandSexp = refinedOutput[-1]
            return {"demands": preprocessMechanicsOutput(demandSexp, "demand")}
        except Exception as e:
            return {"error": f"processing error {e}"}

    except Exception as e:
        return {"error": f"Unexpected server error: {e}"}


@app.post(
    "/addRules",
)
async def addRules(payload: list[RuleCreate]):
    try:
        result = await pair_to_goals(payload=payload)

        if result["status"] == "success":
            return {"status": 201, "message": "Rules Created", "rules": result["data"]}
        elif result["status"] == "duplicate found":
            return {
                "status": 400,
                "message": "Rules already exist",
                "rules": result["data"],
            }

    except Exception as e:
        print("Error adding rules: ", e)
        raise e
