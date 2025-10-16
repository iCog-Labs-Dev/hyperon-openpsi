import unittest
from utils import preprocessRawOutput, changeSexpToList

class UtilTests(unittest.TestCase):
    
    def test_empty_input(self):
        """Test empty input returns a list with an empty string."""
        self.assertEqual(preprocessRawOutput(''), [''])
    
    def test_no_matching_lines(self):
        """Test lines without matching pattern are processed by removing outer brackets."""
        input_data = '[a]\n[b]'
        expected = ['a', 'b']
        self.assertEqual(preprocessRawOutput(input_data), expected)
    
    def test_matching_line_removed(self):
        """Test a line matching the empty tuple list pattern is removed."""
        input_data = '[()]\n[c]'
        expected = ['c']
        self.assertEqual(preprocessRawOutput(input_data), expected)
    
    def test_multiple_matching_lines(self):
        """Test multiple matching lines are removed, non-matching preserved."""
        input_data = '[()]\n[(), ()]\n[e]\n[(),(),()]'
        expected = ['e']
        self.assertEqual(preprocessRawOutput(input_data), expected)
    
    def test_with_spaces(self):
        """Test handling of spaces around matching patterns."""
        input_data = ' [(),()] \n[d]'
        expected = ['d']
        self.assertEqual(preprocessRawOutput(input_data), expected)
    
    def test_empty_list_line(self):
        """Test an empty list '[]' does not match and becomes empty string."""
        input_data = '[]'
        expected = ['']
        self.assertEqual(preprocessRawOutput(input_data), expected)
    
    def test_line_with_space_inside_parens(self):
        """Test a line with spaces inside parentheses does not match."""
        input_data = '[ ( ) ]'
        expected = [' ( ) ']
        self.assertEqual(preprocessRawOutput(input_data), expected)
    
    def test_non_bracket_line(self):
        """Test a line without brackets is sliced to empty string."""
        input_data = 'f'
        expected = ['']
        self.assertEqual(preprocessRawOutput(input_data), expected)
    
    def test_mixed_lines(self):
        """Test mixed matching and non-matching lines."""
        input_data = '[]\n[g]\n[()]\n[h]'
        expected = ['', 'g', 'h']
        self.assertEqual(preprocessRawOutput(input_data), expected)

    def test_sexp_empty(self):
        """Test with empty s-expression"""
        input_data = '()'
        expected = []
        return self.assertEqual(changeSexpToList(input_data),expected)
    
    def test_sexp_empty_with_spaces(self):
        """Test with an empty s-expression that has middle spaces"""
        input_data = '(   )'
        expected = []
        return self.assertEqual(changeSexpToList(input_data), expected)
    
    def test_sexp_with_instances(self):
        """
            Test with an s-expression that has multiple instances
        """

        input_data = '(exp1 exp2 exp3 exp4)'
        expected = ['exp1','exp2','exp3','exp4']
        return self.assertEqual(changeSexpToList(input_data), expected)
    
    def test_sexp_with_middle_spaces(self):
        """
            Test with an s-expression that has multiple instances but with middle spaces between the elements
        """
        input_data = '(exp1  exp2 exp3 exp4)'
        expected = ['exp1','exp2','exp3','exp4']
        return self.assertEqual(changeSexpToList(input_data),expected)
    
    def test_sexp_with_one(self):
        """
            Test with an s-expression that has only one instance.
        """
        input_data = '(exp1)'
        expected = ['exp1']
        return self.assertEqual(changeSexpToList(input_data),expected)


    

if __name__ == '__main__':
    unittest.main(verbosity=2)