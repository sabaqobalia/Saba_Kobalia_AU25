import time
import pytest


@pytest.fixture()
def track_test_time():
    start_time = time.time()
    yield
    end_time = time.time()
    print(f"\nTest execution time: {end_time - start_time:.2f} seconds")


def add_numbers(a, b):
    return a + b


def test_add_two_positive_numbers(track_test_time):
    result = add_numbers(3, 5)
    time.sleep(2)
    assert result == 8


def test_add_two_negative_numbers(track_test_time):
    result = add_numbers(-3, -5)
    time.sleep(3)
    assert result == -8


def test_add_negative_and_positive_numbers(track_test_time):
    result = add_numbers(-3, 5)
    time.sleep(1)
    assert result == 2