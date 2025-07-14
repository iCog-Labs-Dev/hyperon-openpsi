

import logging
import sys
from hyperon import *
from hyperon.ext import register_atoms
from hyperon.atoms import OperationAtom, GroundedAtom, SymbolAtom, ValueAtom, ExpressionAtom


def pyModule (metta:MeTTa,name:Atom,*args: Atom):
    print("Args : ", args)
    payload_expression: ExpressionAtom = args[0]
    actual_arg_atoms = payload_expression.get_children()
    functionName  = name.get_name()
    handler_args: list[str] = [str(arg) for arg in actual_arg_atoms]

    #run
    result =  globals()[functionName](*handler_args)

       
    return [ValueAtom(result)]

@register_atoms(pass_metta=True)
def pyModule_(metta):
    return {
        "pyModule": OperationAtom(
            "pyModule",
            lambda  name, *payload: pyModule(metta,name, *payload),
            ["Atom","Atom", "Atom"],
            unwrap=False
        )
    }


def test_func(name: str): 
    # This is an example call form a metta script
    # !(import! &self t) 
    # !(pyModule tes_func (param1, ...))

 
    return f"Hello, {name}!"

