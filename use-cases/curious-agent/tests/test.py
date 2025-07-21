import unittest
import sys
import os

# Add the parent directory to the Python path to allow importing adapter and base
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from adapter import parse_schema, parse_state_params, validateSyntax, extract_rules_from_llm
from base import Schema, StateParams
from openPsi import *
from typing import List

class TestAdapter(unittest.TestCase):

    def test_parse_schema(self):
        schema = Schema(
            handle="r1",
            context="(Goal init 0.9 0.6)",
            action="explore",
            goal="(Goal found_target 1.0 1.0)",
            tv="(TTV 1 (STV 0.8 0.7))",
            weight=2
        )
        expected_metta = """((: r1 ((TTV 1 (STV 0.8 0.7)) (IMPLICATION_LINK (AND_LINK ((Goal init 0.9 0.6) explore)) (Goal found_target 1.0 1.0)))) 2.0)"""
        self.assertEqual(parse_schema(schema), expected_metta)


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
        # Valid rule from the original test
        valid_rule = """((: r1 ((TTV 1 (STV 0.8 0.7)) 
            (IMPLICATION_LINK 
            (AND_LINK ((Goal init 0.9 0.6) explore)) 
            (Goal found_target 1.0 1.0)))) 2.0)"""
        self.assertTrue(validateSyntax(valid_rule))

        # Valid rule with extra spaces
        valid_rule_extra_spaces = """((: r1  ((TTV  1  (STV  0.8   0.7))  
            (IMPLICATION_LINK   (AND_LINK  ((Goal  init  0.9  0.6)  explore))  
            (Goal  found_target  1.0  1.0))))  2.0)"""
        self.assertTrue(validateSyntax(valid_rule_extra_spaces))

        # Valid rule with minimal spaces
        valid_rule_min_spaces = """((:r1((TTV 1(STV 0.8 0.7))(IMPLICATION_LINK(AND_LINK((Goal init 0.9 0.6)explore))(Goal found_target 1.0 1.0))))2.0)"""
        self.assertTrue(validateSyntax(valid_rule_min_spaces))

        # Valid rule with different identifiers and numbers
        valid_rule_different = """((: rule2 ((TTV 0 (STV 0.5 0.9)) 
            (IMPLICATION_LINK 
            (AND_LINK ((Goal start 0.7 0.8) discover)) 
            (Goal target_reached 1.0 0.9)))) 1.0)"""
        self.assertTrue(validateSyntax(valid_rule_different))

        # Invalid rule: incorrect final number (3.2 instead of 0-2 range)
        invalid_rule_number = """((: r1 ((TTV 1 (STV 0.8 0.7)) 
            (IMPLICATION_LINK 
            (AND_LINK ((Goal init 0.9 0.6) explore)) 
            (Goal found_target 1.0 1.0)))) 3.2)"""
        self.assertFalse(validateSyntax(invalid_rule_number))

        # Invalid rule: missing TTV keyword
        invalid_rule_missing_ttv = """((: r1 (( 1 (STV 0.8 0.7)) 
            (IMPLICATION_LINK 
            (AND_LINK ((Goal init 0.9 0.6) explore)) 
            (Goal found_target 1.0 1.0)))) 2.0)"""
        self.assertFalse(validateSyntax(invalid_rule_missing_ttv))

        # Invalid rule: malformed number (0.88 instead of single decimal)
        invalid_rule_malformed_number = """((: r1 ((TTV 1 (STV 0.88 0.7)) 
            (IMPLICATION_LINK 
            (AND_LINK ((Goal init 0.9 0.6) explore)) 
            (Goal found_target 1.0 1.0)))) 2.0)"""
        self.assertFalse(validateSyntax(invalid_rule_malformed_number))

        # Invalid rule: missing closing parenthesis
        invalid_rule_missing_paren = """((: r1 ((TTV 1 (STV 0.8 0.7)) 
            (IMPLICATION_LINK 
            (AND_LINK ((Goal init 0.9 0.6) explore)) 
            (Goal found_target 1.0 1.0))) 2.0)"""
        self.assertFalse(validateSyntax(invalid_rule_missing_paren))

        # Invalid rule: incorrect keyword (GOAL instead of Goal)
        invalid_rule_wrong_keyword = """((: r1 ((TTV 1 (STV 0.8 0.7)) 
            (IMPLICATION_LINK 
            (AND_LINK ((GOAL init 0.9 0.6) explore)) 
            (Goal found_target 1.0 1.0)))) 2.0)"""
        self.assertFalse(validateSyntax(invalid_rule_wrong_keyword))

        # Invalid rule: empty identifier
        invalid_rule_empty_identifier = """((:  ((TTV 1 (STV 0.8 0.7)) 
            (IMPLICATION_LINK 
            (AND_LINK ((Goal init 0.9 0.6) explore)) 
            (Goal found_target 1.0 1.0)))) 2.0)"""
        self.assertFalse(validateSyntax(invalid_rule_empty_identifier))

        # Valid rule with integer values
        valid_rule_integers = """((: r1 ((TTV 1 (STV 1.0 0.0)) 
            (IMPLICATION_LINK 
            (AND_LINK ((Goal init 1.0 0.0) explore)) 
            (Goal found_target 1.0 0.0)))) 2.0)"""
        self.assertTrue(validateSyntax(valid_rule_integers))

        # Valid rule with floating-point values
        valid_rule_floats = """((: r1 ((TTV 1 (STV 0.1 0.2)) 
            (IMPLICATION_LINK 
            (AND_LINK ((Goal init 0.3 0.4) explore)) 
            (Goal found_target 0.5 0.6)))) 1.0)"""
        self.assertTrue(validateSyntax(valid_rule_floats))

        # Invalid rule with a negative value
        invalid_rule_negative_value = """((: r1 ((TTV 1 (STV -0.8 0.7)) 
            (IMPLICATION_LINK 
            (AND_LINK ((Goal init 0.9 0.6) explore)) 
            (Goal found_target 1.0 1.0)))) 2.0)"""
        self.assertFalse(validateSyntax(invalid_rule_negative_value))

        # Invalid rule with an incorrect keyword
        invalid_rule_bad_keyword = """((: r1 ((TTV 1 (STV 0.8 0.7)) 
            (IMPLICATION_LINK 
            (AND_LINK ((BadKeyword init 0.9 0.6) explore)) 
            (Goal found_target 1.0 1.0)))) 2.0)"""
        self.assertFalse(validateSyntax(invalid_rule_bad_keyword))
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
