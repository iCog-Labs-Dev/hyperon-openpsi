import unittest

from hyperon import *
from Rule_to_py_object import parse_sexp, Schema
metta = MeTTa()

class TestMettaToSchemaObject(unittest.TestCase):
    """Unit tests for the metta_to_schema module."""



    def test_parse_sexp_valid_input(self):
        """Test parsing a valid MeTTa S-expression with multiple rules."""
        sample_sexp = '''
            (rule1 (C1 C2) A G (tv 0.9 0.8))
            (rule2 C3 A2 G2 (tv 0.7 0.6))
        '''
        result = parse_sexp(sample_sexp)
        self.assertEqual(len(result), 2)
        self.assertEqual(result[0].handle, "rule1")
        self.assertEqual(result[0].context, "(C1 C2)")
        self.assertEqual(result[0].action, "A")
        self.assertEqual(result[0].goal, "G")
        self.assertEqual(result[0].tv, "(tv 0.9 0.8)")
        self.assertEqual(result[1].handle, "rule2")
        self.assertEqual(result[1].context, "C3")
        self.assertEqual(result[1].action, "A2")
        self.assertEqual(result[1].goal, "G2")
        self.assertEqual(result[1].tv, "(tv 0.7 0.6)")


if __name__ == '__main__':
    unittest.main()
