from typing import List
import re
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


    
    





    

