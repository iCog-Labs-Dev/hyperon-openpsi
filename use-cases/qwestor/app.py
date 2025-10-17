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
    try:
      
        process = await asyncio.create_subprocess_shell(
            "metta main-loop.metta",
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE
        )

        stdout, stderr = await process.communicate()

        
        if process.returncode != 0:
            return {
                "error": f"metta failed with code {process.returncode}",
                "stderr": stderr.decode().strip()
            }

        try:
            result = stdout.decode().strip()
            refinedOutput = preprocessRawOutput(result)
            actions_expression = refinedOutput[-1]
            json_result = {"actions": changeSexpToList(actions_expression)}

           
            await asyncio.to_thread(writeListToFile, refinedOutput, "out.metta")

            return json_result

        except Exception as e:
            return {"error": f"Processing error: {e}"}

    except asyncio.SubprocessError as e:
        return {"error": f"Async subprocess failed: {e}"}

    except Exception as e:
        return {"error": f"Unexpected server error: {e}"}


@app.get("/fetchModulators")
async def fetchModulators():
    try:
        process = await asyncio.create_subprocess_shell(
            "metta fetch-modulators.metta",
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE
        )

        stdout, stderr = await process.communicate()

        if process.returncode != 0:
            return {"error": f"metta failed with code {process.returncode}", "stderr": stderr.decode()}
        try:
            result = stdout.decode().strip()
            refinedOutput = preprocessRawOutput(result)
            modulatorSexp = refinedOutput[-1]
            return {"modulators": preprocessMechanicsOutput(modulatorSexp, "modulator")}
        except Exception as e:
            return {"error": f"processing Error {e}"}
    except asyncio.SubprocessError as e:
        return {"error": f"Async subprocess failed: {e}"}

    except Exception as e:
        return {"error": f"Unexpected server error: {e}"}
    




@app.get("/fetchDemands")
async def fetchDemands():
    try:
        process = await asyncio.create_subprocess_shell(
            "metta fetch-demands.metta",
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE
        )

        stdout, stderr = await process.communicate()

        if process.returncode != 0:
            return {"error": f"metta failed with code {process.returncode}", "stderr": stderr.decode()}
        try: 
            result = stdout.decode().strip()
            refinedOutput = preprocessRawOutput(result)
            demandSexp = refinedOutput[-1]
            return {"demands": preprocessMechanicsOutput(demandSexp, "demand")}
        except Exception as e:
            return {"error": f"processing error {e}"}
    except asyncio.SubprocessError as e:
        return {"error": f"Async subprocess failed: {e}"}

    except Exception as e:
        return {"error": f"Unexpected server error: {e}"}
    





