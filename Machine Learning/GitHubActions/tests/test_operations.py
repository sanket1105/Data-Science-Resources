import os
import sys

# Get the current directory of the test file
current_dir = os.path.dirname(os.path.abspath(__file__))

# Go one directory up from the current directory
parent_dir = os.path.dirname(current_dir)

# Add the 'src' directory to the system path
src_path = os.path.join(parent_dir, "src")
sys.path.insert(0, src_path)  # Add src to the system path

print("Current Directory:", current_dir)
print("Parent Directory:", parent_dir)
print("Source Path:", src_path)

try:
    from MathOperations import add, subtract  # Try importing without 'src'
except ModuleNotFoundError as e:
    print(f"Error: {e}")
    print("Trying with full path...")
    from src.MathOperations import add, subtract  # Full import path


def test_add():
    """
    Test the add function with some values
    """
    assert add(2, 3) == 5
    assert add(-1, 1) == 0


def test_subtract():
    """
    Test the subtract function with some values
    """
    assert subtract(4, 3) == 1
    assert subtract(0, 0) == 0
