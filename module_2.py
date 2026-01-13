# from collections import defaultdict as dd
# from itertools import product
from typing import Any, Dict, List, Tuple


def task_1(data_1: Dict[str, int], data_2: Dict[str, int]):
    dict3 = {}
    for i in data_1:
        if i in data_2:
            dict3[i] = data_2[i] + data_1[i]
        else:
            dict3[i] = data_1[i]
    for i in data_2:
        if i not in data_1:
            dict3[i] = data_2[i]
    return dict3


def task_2():
    dict_sq = {}
    for i in range(1, 16):
        dict_sq[i] = i ** 2
    return dict_sq


def task_3(data: Dict[Any, List[str]]):
    result = ['']
    for values in data.values():
        new_result = []
        for prefix in result:
            for char in values:
                new_result.append(prefix + char)
        result = new_result
    return result


def task_4(data: Dict[str, int]):
    dlist = list(data.items())

    def d_sort(emp):
        return emp[1]

    result = sorted(dlist, key=d_sort, reverse=True)

    realresult = []
    for i in result:
        realresult.append(i[0])
    return realresult[:3]


def task_5(data: List[Tuple[Any, Any]]) -> Dict[str, List[int]]:
    dicty = {}
    for i, j in data:
        if i not in dicty:
            dicty[i] = [j]
        else:
            dicty[i].append(j)
    return dicty


def task_6(data: List[Any]):
    pass


def task_7(words: List[str]) -> str:
    pass


def task_8(haystack: str, needle: str) -> int:
    pass