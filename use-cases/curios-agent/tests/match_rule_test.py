import sys
import os
import unittest

# Add the parent directory to sys.path to find llm.py
sys.path.append(os.path.dirname(os.path.dirname(__file__)))

from llm import match_rule, Schema

class TestMatchRule(unittest.TestCase):

    def setUp(self):
        # Define some fake rules for testing
        self.rules = [
            Schema(
                handle="rule1",
                context="Order a pizza with extra cheese",
                action="place_order",
                goal="Satisfy hunger",
                tv="N/A"
            ),
            Schema(
                handle="rule2",
                context="Play some music",
                action="start_music",
                goal="Entertainment",
                tv="N/A"
            ),
            Schema(
                handle="rule3",
                context="Set an alarm for 7 AM",
                action="set_alarm",
                goal="Wake up on time",
                tv="N/A"
            ),
        ]

    def test_match_exact_phrase(self):
        query = "I'd like to order a pizza with extra cheese"
        best_rule = match_rule(query, self.rules)
        self.assertEqual(best_rule.handle, "rule1")

    def test_match_music_command(self):
        query = "Can you play music for me?"
        best_rule = match_rule(query, self.rules)
        self.assertEqual(best_rule.handle, "rule2")

    def test_match_alarm_command(self):
        query = "Wake me up at 7 in the morning"
        best_rule = match_rule(query, self.rules)
        self.assertEqual(best_rule.handle, "rule3")

    def test_empty_rulebase_raises(self):
        with self.assertRaises(ValueError):
            match_rule("anything", [])

if __name__ == '__main__':
    unittest.main()
