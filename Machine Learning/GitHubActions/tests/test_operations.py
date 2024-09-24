# File: test_math_operations.py (make sure to name it properly)
import os
import sys

# Add the parent directory to the system path to import from src
sys.path.append(
    os.path.abspath("E:\\Data Science Bootcamp\\Machine Learning\\GitHubActions\\src")
)

from MathOperations import add, subtract


def test_add():
    """
    Test the add function with some values.
    """
    assert add(2, 3) == 5
    assert add(-1, 1) == 0
    assert add(0, 0) == 0  # Testing zero addition
    assert add(-2, -3) == -5  # Testing negative addition


def test_subtract():
    """
    Test the subtract function with some values.
    """
    assert subtract(4, 3) == 1
    assert subtract(0, 0) == 0
    assert subtract(5, 10) == -5  # Testing negative result
    assert subtract(-2, -3) == 1  # Testing subtraction of negatives
