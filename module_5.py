# from collections import Counter
import os
from pathlib import Path
from random import choice, seed
from typing import List, Union
import requests
from requests.exceptions import RequestException

S5_PATH = Path(os.path.realpath(__file__)).parent

PATH_TO_NAMES = S5_PATH / "names.txt"
PATH_TO_SURNAMES = S5_PATH / "last_names.txt"
PATH_TO_OUTPUT = S5_PATH / "sorted_names_and_surnames.txt"
PATH_TO_TEXT = S5_PATH / "random_text.txt"
PATH_TO_STOP_WORDS = S5_PATH / "stop_words.txt"


def task_1():
    seed(1)
    with open(PATH_TO_NAMES, "r", encoding="utf-8") as f:
        names = [name.strip().lower() for name in f if name.strip()]
    with open(PATH_TO_SURNAMES, "r", encoding="utf-8") as f:
        last_names = [last_name.strip().lower() for last_name in f if last_name.strip()]
    names.sort()
    with open(PATH_TO_OUTPUT, "w", encoding="utf-8") as f:
        for name in names:
            surname = choice(last_names)
            f.write(f"{name} {surname}\n")


def task_2(top_k: int):
    with open(PATH_TO_STOP_WORDS, "r", encoding="utf-8") as file1:
        stop_words = set(word.strip().lower() for word in file1.read().split())
    with open(PATH_TO_TEXT, "r", encoding="utf-8") as file2:
        not_deleted_words = file2.read().lower().split()
    filtered_words = [word for word in not_deleted_words if word.isalpha() and word not in stop_words]

    counted = []
    for i in filtered_words:
        found = False
        for j in counted:
            if i == j[0]:
                j[1] += 1
                found = True
                break
        if not found:
            counted.append([i, 1])

    counted.sort(key=lambda item: item[1], reverse=True)
    return [(item[0], item[1]) for item in counted[:top_k]]


def task_3(url: str):
    try:
        response = requests.get(url)
        response.raise_for_status()
        return response
    except RequestException as e:
        raise e


def task_4(data: List[Union[int, str, float]]):
    summed = 0
    for i in data:
        try:
            summed += i
        except TypeError:
            try:
                summed += float(i)
            except ValueError:
                pass
    return summed


def task_5():
    try:
        a, b = input().split()
        a = float(a)
        b = float(b)
        if b == 0:
            print("Can't divide by zero")
        else:
            result = a / b
            if result.is_integer():
                print(int(result))
            else:
                print(f"{result:.3f}")
    except ValueError:
        print("Entered value is wrong")
