import sys
import os

# Add the src directory to the system path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '../../src')))

from MathOperations import add, subtract

def test_add():
    """Test the add function with some values."""
    assert add(2, 3) == 5
    assert add(-1, 1) == 0

def test_subtract():
    """Test the subtract function with some values."""
    assert subtract(4, 3) == 1
    assert subtract(0, 0) == 0
