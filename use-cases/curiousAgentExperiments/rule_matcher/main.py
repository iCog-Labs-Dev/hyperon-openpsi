import os
from hyperon import MeTTa
from correlation_matcher import match_rule  

def load_metta_file(metta: MeTTa, folder: str, filename: str):
    base_dir = os.path.dirname(__file__)  # folder of main.py
    filepath = os.path.join(base_dir, folder, filename)
    with open(filepath, "r") as f:
        metta.run(f.read())

def main():
    m = MeTTa()
    load_metta_file(m, "rules", "rule.metta")
    load_metta_file(m, "rules", "implicator.metta")
    load_metta_file(m, ".", "sample_rules.metta")

    summary = "customer asked about billing issues"
    best_rule = match_rule(m, summary)

    print("Best rule:", best_rule)

if __name__ == "__main__":
    main()
