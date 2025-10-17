from typing import List,Union
import re
from models import *
def preprocessRawOutput(data:str) -> List[str]:
    """
        This procedure takes the result of a subprocess and preprocesses it by removing 
        its respective subsuming list.
        Arguments
        ==============
        data: str -> This is a raw output from running the metta file.
        returns
        ================
        refinedResult: List[str]

    """
    dataList = data.strip().split('\n')
    refinedResult = [i[1:-1] for i in dataList if not re.match(r'^\s*\[\s*(?:\s*\(\)\s*(?:,\s*\(\)\s*)*)\s*\]\s*$', i)]
    return refinedResult

def writeListToFile(outPutResult: List[str], fileName:str):
    with open(fileName, 'w') as file:
        for i in outPutResult:
            file.write(i + "\n")


def persistAtomspaceResult(result):
    refinedList = preprocessRawOutput(result)
    writeListToFile(refinedList,"out.metta")


def changeSexpToList(sExp: str) -> List[str]:
    """
    This function changes the result of an s-expression to a Python list of possible actions.
    """
    try:
        sExp = sExp.strip()
        if not sExp.startswith("("):
            raise ValueError(f"Invalid s-expression: missing opening parenthesis. Got: {sExp}")
        if not sExp.endswith(")"):
            raise ValueError(f"Invalid s-expression: missing closing parenthesis. Got: {sExp}")
        return sExp[1:-1].strip().split()
    except Exception as e:
        print(f"Error while converting s-expression: {e}")
        return []


def changeDemandSExp(sExp: str):
    sExpList = sExp.split()
    return Demand(demandName=sExpList[1],demandValue=sExpList[2])

def changeModulatorSExp(sExp: str):
    sExpList = sExp.split()
    return Modulator(modulatorName=sExpList[1],modulatorValue=sExpList[2])


def preprocessMechanicsOutput(sExp: str,instanceType:str) -> List[Union[Demand,Modulator]]:
    '''
        This function changes the result of an s-expression modulators or demands to structured-output
    '''
    sExp = sExp.strip()
    try:
        if not sExp.startswith("("):
            return ValueError(f"The {sExp} is Invalid s-expression the s-expression should start with ( ")
        if not sExp.endswith(")"):
            return ValueError(f"The {sExp} is Invalid s-expression the s-expression should end with )")
        sExpList = [i for i in sExp[1:-1].strip().split(")") if i != ""]
        sExpList = [i.strip()[1:] for i in sExpList]
        if instanceType == 'modulator':
            return [changeModulatorSExp(i) for i in sExpList]
        elif instanceType == 'demand':
            return [changeDemandSExp(i) for i in sExpList]
    except Exception as e:
        print(f"Error while converting s-expression: {e}")
        return []










    
    





    

