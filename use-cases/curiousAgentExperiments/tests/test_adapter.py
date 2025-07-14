# test-adapter.py
import os
import sys
from dotenv import load_dotenv
from hyperon import MeTTa
from typing import List, Optional

# Add the parent directory to Python path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

# import adapter file
from adapter import run_gemini, match_rule


# ========== Setup MeTTa ==========
def setup_hyperon() -> MeTTa:
    metta = MeTTa()

    # Load addRule function from rule.metta file
    # rule_def_path = "/home/hope/Project_package/hyperon-openpsi/main/rules/rule.metta"
    # with open(rule_def_path, "r") as f:
    #     add_rule_def = f.read()
    # metta.run(add_rule_def)

    # Create atomspace
    metta.run("!(bind! &PsiRules (new-space))")

    # Add sample rules directly here in test-adapter.py
    metta.run("""
    !(addRule (PsiRules) id1 (Lunch_time, cafeteria) eat_meal socialize (TTV 1 (STV 1.0 1.0)))
    !(addRule (PsiRules) id2 (Evening, gym) warmup do_exercise (TTV 1 (STV 1.0 1.0)))
    !(addRule (PsiRules) id3 (Evening, family_home) cook_dinner eat_together (TTV 1 (STV 1.0 1.0)))
    !(addRule (PsiRules) id4 (Weekend, park) play_sports relax (TTV 1 (STV 1.0 1.0)))
    !(addRule (PsiRules) id5 (Morning, school) attend_class learn (TTV 1 (STV 1.0 1.0)))
    !(addRule (PsiRules) id6 (Mooring, at_home) washed_Face Eat_breakfast (TTV 1 (STV 1.0 1.0)))
    !(addRule (PsiRules) id7 (Mooring, together) greet_family Pray (TTV 1 (STV 1.0 1.0)))
    !(addRule (PsiRules) id8 (Workplace, arrival) log_in Start_tasks (TTV 1 (STV 1.0 1.0)))
    !(addRule (PsiRules) id9 (Night, bedroom) brush_teeth sleep (TTV 1 (STV 1.0 1.0)))
    !(addRule (PsiRules) id10 (Emergency, hospital) call_doctor get_treatment (TTV 1 (STV 1.0 1.0)))
    """)

    return metta


# ========== Extract All Rules ==========
def extract_all_rules(metta: MeTTa) -> List[str]:
    code = """
    (= (allRule)
        (case (get-atoms (PsiRules))
            (
                ((: $ptr (IMPLICATION_LINK (AND_LINK ($context $action)) $goal)) (: $ptr (IMPLICATION_LINK (AND_LINK ($context $action)) $goal)))
                ((: $ptr (TTV $timestamp $stv) (IMPLICATION_LINK (AND_LINK ($context $action)) $goal)) (: $ptr (TTV $timestamp $stv) (IMPLICATION_LINK (AND_LINK ($context $action)) $goal)))
                ((: $ptr (IMPLICATION_LINK (AND_LINK ($context $action)) $goal)(TTV $timestamp $stv)) (: $ptr (IMPLICATION_LINK (AND_LINK ($context $action)) $goal)(TTV $timestamp $stv)))
            )
        )
    )
    !(allRule)
    """
    result = metta.run(code)
    if result:
        return [str(atom) for atom in result]
    return []


# ========== Main Logic ==========
if __name__ == "__main__":
    metta = setup_hyperon()
    all_rules = extract_all_rules(metta)

    question = "What people do in every morning?"  # Sample Quesion here
    response = run_gemini(question)
    summary = run_gemini(f"Summarize this conversation for context:\n{response}")
    top_rules = match_rule(summary, all_rules)

    # It selects the top 4 rules that best match the context from the rule list.
    print(top_rules)
