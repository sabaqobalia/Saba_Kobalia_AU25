# import time
from typing import List
import time

Matrix = List[List[int]]


def task_1(exp: int):
    def power(n):
        result = n ** exp
        return result
    return power


def task_2(*args, **kwargs):
    for value in args:
        print(value)
    for value in kwargs.values():
        print(value)


def helper(func):
    def wrapper(*args, **kwargs):
        print("Hi, friend! What's your name?")
        func(*args, **kwargs)
        print("See you soon!")
    return wrapper


@helper
def task_3(name: str):
    print(f"Hello! My name is {name}.")


def timer(func):
    def wrapper(*args, **kwargs):
        start = time.time()
        result = func(*args, **kwargs)
        end = time.time()
        run_time = end - start
        print(f"Finished {func.__name__} in {run_time:.4f} secs")
        return result
    return wrapper


@timer
def task_4():
    return len([1 for _ in range(0, 10**8)])


def task_5(matrix: Matrix) -> Matrix:
    y = len(matrix)
    x = len(matrix[0])
    transposed_matrix = []

    for i in range(x):
        transposed_matrix.append([])

    for i in range(y):
        for j in range(x):
            transposed_matrix[j].append(matrix[i][j])

    return transposed_matrix


def task_6(queue: str):
    stack = []
    for char in queue:
        if char == "(":
            stack.append(char)
        elif char == ")":
            if not stack:
                return False
            stack.pop()
    return not stack
