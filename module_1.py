# module_1.py

# Task 1: Find two numbers in a list that sum to target
def task_1(sample, target):
    result = []
    for i in sample:
        if target - i in sample and i not in result and (target - i) not in result:
            result.append(i)
            result.append(target - i)
            break  # only one pair needed
    return result

# Task 2: Reverse digits of an integer, ignore trailing zeros
def task_2(sample):
    negative = sample < 0
    sample = abs(sample)
    # Remove trailing zeros
    while sample % 10 == 0 and sample != 0:
        sample //= 10
    reversed_num = 0
    while sample > 0:
        reversed_num = reversed_num * 10 + sample % 10
        sample //= 10
    return -reversed_num if negative else reversed_num

# Task 3: First duplicate in a list, -1 if none
def task_3(sample):
    seen = set()
    for i in sample:
        if i in seen:
            return i
        seen.add(i)
    return -1

# Task 4: Roman numeral to integer
def task_4(s):
    roman_dict = {'I': 1, 'V': 5, 'X': 10, 'L': 50, 'C': 100, 'D': 500, 'M': 1000}
    total = 0
    prev_value = 0
    for c in reversed(s):
        value = roman_dict[c]
        if value < prev_value:
            total -= value
        else:
            total += value
        prev_value = value
    return total

# Task 5: Minimum value in a list
def task_5(sample):
    if not sample:
        return None  # return None for empty list
    minimal = sample[0]
    for i in sample:
        if i < minimal:
            minimal = i
    return minimal
