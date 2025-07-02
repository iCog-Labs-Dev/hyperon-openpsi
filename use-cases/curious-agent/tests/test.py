import unittest
from adapter import parse_schema, parse_state_params, validateSyntax, extract_rules_from_llm
from base import Schema, StateParams
from typing import List

class TestAdapter(unittest.TestCase):

    def test_parse_schema(self):
      
        schema1 = Schema(handle="R1", context="(Self Is Outside) (Self Has Key) (Self See Door)", action="(Go to Door)", goal="(Self at Door)", tv="(TTV 100 (STV 0.9 0.8))")
        expected_metta1 = """(: R1 (IMPLICATION_LINK (AND_LINK ((Self Is Outside) (Self Has Key) (Self See Door)) (Go to Door)) (Self at Door))) (TTV 100 (STV 0.9 0.8)))"""
        self.assertEqual(parse_schema(schema1), expected_metta1)

        # Test case with different values
        schema2 = Schema(handle="R3", context="(Agent Sees Object)", action="(Pick Up Object)", goal="(Agent Has Object)", tv="(TTV 50 (STV 0.7 0.2))")
        expected_metta2 = """(: R3 (IMPLICATION_LINK (AND_LINK ((Agent Sees Object)) (Pick Up Object)) (Agent Has Object))) (TTV 50 (STV 0.7 0.2)))"""
        self.assertEqual(parse_schema(schema2), expected_metta2)

        # Test case with simpler context and no TV
        schema3 = Schema(handle="R3", context="(True)", action="(Do Nothing)", goal="(Done)", tv=None)
        expected_metta3 = """(: R3 (IMPLICATION_LINK (AND_LINK ((True)) (Do Nothing)) (Done))) None)"""
        self.assertEqual(parse_schema(schema3), expected_metta3)


    def test_parse_state_params(self):
        state_params_str = "( (modulator activation 0.5) (modulator securing_threshold 0.7) (modulator pleasure 0.8) (modulator selection_threshold 0.6) )"
        expected_state_params = StateParams(activation=0.5, securing_threshold=0.7, pleasure=0.8, selection_threshold=0.6)
        actual_state_params = parse_state_params(state_params_str)
        self.assertEqual(actual_state_params, expected_state_params)

        state_params_str_empty = ""
        self.assertIsNone(parse_state_params(state_params_str_empty))

        state_params_str_invalid = "( (modulator activation 0.5) (modulator securing_threshold 0.7) (pleasure 0.8) (modulator selection_threshold 0.6) )"
        self.assertIsNone(parse_state_params(state_params_str_invalid))

    def test_validate_syntax(self):
        valid_rule = """(: R1 (IMPLICATION_LINK
						(AND_LINK (((Self Is Outside) (Self Has Key) (Self See Door)) (Go to Door))
						(Open Door))
					)
					(TTV 100 (STV 0.9 0.8))
		)"""
        self.assertFalse(validateSyntax(valid_rule))

        invalid_rule_no_tv = """(: R1 (IMPLICATION_LINK
						(AND_LINK (((Self Is Outside) (Self Has Key) (Self See Door)) (Go to Door))
						(Open Door))
					)
		)"""
        self.assertFalse(validateSyntax(invalid_rule_no_tv))

        valid_rule_with_tv = """(: R1 (IMPLICATION_LINK
						(AND_LINK (((Self Is Outside) (Self Has Key) (Self See Door)) (Go to Door))
						(Open Door))
					)
					(TTV 100 (STV 0.9 0.8))
		)"""
        self.assertFalse(validateSyntax(valid_rule_with_tv))

    def test_extract_rules_from_llm(self):
        raw_rules = """[
            (: R1 (IMPLICATION_LINK (AND_LINK (((Self at Door) (Self Has Key))) (Open Door)) ) (TTV 100 (STV 0.9 0.8))),
            (: R2 (IMPLICATION_LINK (AND_LINK (((Self Inside))) (Go Inside)) ) (TTV 100 (STV 0.9 0.8))),
            (: R3 (IMPLICATION_LINK (AND_LINK (((Self Inside Room))) (Search for Diamond)) ) (TTV 100 (STV 0.9 0.8)))
        ]"""
        expected_rules = [
            '(: R1 (IMPLICATION_LINK (AND_LINK (((Self at Door) (Self Has Key))) (Open Door)) ) (TTV 100 (STV 0.9 0.8)))',
            '(: R2 (IMPLICATION_LINK (AND_LINK (((Self Inside))) (Go Inside)) ) (TTV 100 (STV 0.9 0.8)))',
            '(: R3 (IMPLICATION_LINK (AND_LINK (((Self Inside Room))) (Search for Diamond)) ) (TTV 100 (STV 0.9 0.8)))'
        ]
        self.assertEqual(extract_rules_from_llm(raw_rules), expected_rules)

        raw_rules_empty = "[]"
        self.assertEqual(extract_rules_from_llm(raw_rules_empty), [])

        raw_rules_single = "[(: R1 (IMPLICATION_LINK (AND_LINK (((Self at Door) (Self Has Key))) (Open Door)) ) (TTV 100 (STV 0.9 0.8))))]"
        expected_rules_single = ['(: R1 (IMPLICATION_LINK (AND_LINK (((Self at Door) (Self Has Key))) (Open Door)) ) (TTV 100 (STV 0.9 0.8))))']
        self.assertEqual(extract_rules_from_llm(raw_rules_single), expected_rules_single)

        # Test case with leading/trailing whitespace
        raw_rules_whitespace = "  [ (: R1 (IMPLICATION_LINK (AND_LINK (((Self at Door) (Self Has Key))) (Open Door)) ) (TTV 100 (STV 0.9 0.8)))) ]  "
        expected_rules_whitespace = ['(: R1 (IMPLICATION_LINK (AND_LINK (((Self at Door) (Self Has Key))) (Open Door)) ) (TTV 100 (STV 0.9 0.8))))']
        self.assertEqual(extract_rules_from_llm(raw_rules_whitespace), expected_rules_whitespace)

        # Test case with extra whitespace between rules
        raw_rules_extra_whitespace = """[
            (: R1 (IMPLICATION_LINK (AND_LINK (((Self at Door) (Self Has Key))) (Open Door)) ) (TTV 100 (STV 0.9 0.8)))),

            (: R2 (IMPLICATION_LINK (AND_LINK (((Self Inside))) (Go Inside)) ) (TTV 100 (STV 0.9 0.8)))
        ]"""
        expected_rules_extra_whitespace = [
            '(: R1 (IMPLICATION_LINK (AND_LINK (((Self at Door) (Self Has Key))) (Open Door)) ) (TTV 100 (STV 0.9 0.8))))', # Corrected to match input string
            '(: R2 (IMPLICATION_LINK (AND_LINK (((Self Inside))) (Go Inside)) ) (TTV 100 (STV 0.9 0.8)))'
        ]
        self.assertEqual(extract_rules_from_llm(raw_rules_extra_whitespace), expected_rules_extra_whitespace)

        # Test case with an empty rule string (should not happen with valid input, but good for robustness)
        raw_rules_empty_rule = "[, (: R1 (IMPLICATION_LINK (AND_LINK (((Self at Door) (Self Has Key))) (Open Door)) ) (TTV 100 (STV 0.9 0.8))))]"
        expected_rules_empty_rule = ['', '(: R1 (IMPLICATION_LINK (AND_LINK (((Self at Door) (Self Has Key))) (Open Door)) ) (TTV 100 (STV 0.9 0.8))))']
        self.assertEqual(extract_rules_from_llm(raw_rules_empty_rule), expected_rules_empty_rule)


if __name__ == '__main__':
    unittest.main()
