from src.MathOperations import add, subtract


def test_add():
    """
    Test the test casees with some values
    """

    assert add(2, 3) == 5
    assert add(-1, 1) == 0


def test_subtract():
    """
    Test the test casees with some values
    """

    assert subtract(4, 3) == 1
    assert subtract(0, 0) == 0
