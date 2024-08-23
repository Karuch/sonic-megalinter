"""
Module docstring: This module contains the example_function for demonstration purposes.
"""


def example_function(arg1, arg2):
    """
    Function docstring: Prints information based on the values of arg1 and arg2.

    Args:
        arg1 (int): The first argument.
        arg2 (str): The second argument.
    """
    if arg1 == 1:
        print("arg1 is one")
    else:
        print("arg1 is not one")
        print("arg1 is:", arg1)
    print("arg2 is:", arg2)


example_function(1, "test")
