from sentence_transformers import SentenceTransformer
from sklearn.metrics.pairwise import cosine_similarity
import numpy as np

def match_rule(m, conversation_summary: str) -> str:
    """
    Finds the most relevant and satisfiable rule for the given conversation summary.
    Uses OpenPsi to get the rules, checks satisfiability, and computes semantic similarity.
    
    :param m: py-metta Metta instance
    :param conversation_summary: Current conversation context (string)
    :return: The best matching rule handle
    """

    # Load the embedding model
    embedder = SentenceTransformer("all-MiniLM-L6-v2")
    summary_vector = embedder.encode(conversation_summary)

    # Get all rule handles from &psiRules
    rules = m.run('(getAllRules)')
    if not rules:
        print("[WARN] No rules found.")
        return None

    print(f"[INFO] Found {len(rules)} rules in &psiRules.")

    #Iterate and find satisfiable + most similar
    best_rule = None
    best_score = -1

    for rule in rules:
        # Check satisfiability first
        sat = m.run(f'(checkSatisfiability {rule} &satisfiabilityCache)')
        if 'True' not in str(sat) and 'TRUE_TV' not in str(sat):
            print(f"[DEBUG] Rule {rule} is not satisfiable. Skipping.")
            continue

        # Get the rule context
        context_atoms = m.run(f'(getContext &psiRules {rule})')
        if not context_atoms:
            print(f"[WARN] Rule {rule} has no context. Skipping.")
            continue

        # For simplicity, I convert the context to string
        context_str = " ".join(str(atom) for atom in context_atoms)
        context_vector = embedder.encode(context_str)

        # Compute similarity
        similarity = cosine_similarity(
            [summary_vector],
            [context_vector]
        )[0][0]

        print(f"[INFO] Rule {rule} → Similarity: {similarity:.3f}")

        if similarity > best_score:
            best_score = similarity
            best_rule = rule

    if best_rule:
        print(f"[RESULT] Best matching rule: {best_rule} with similarity {best_score:.3f}")
    else:
        print("[RESULT] No satisfiable matching rule found.")

    return best_rule