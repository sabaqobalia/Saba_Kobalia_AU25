import os
import yaml
import pytest


def get_numbers_data():
    base_dir = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    config_path = os.path.join(base_dir, "Configs", "config.yaml")

    with open(config_path, "r") as stream:
        config = yaml.safe_load(stream)

    return config["cases"]


def add_numbers(a, b, c):
    try:
        return a + b + c
    except TypeError:
        raise TypeError("Please check the parameters. All of them must be numeric")


@pytest.mark.smoke
@pytest.mark.unit
@pytest.mark.parametrize(
    "case",
    get_numbers_data(),
    ids=[case["case_name"] for case in get_numbers_data()]
)
def test_add_numbers(case):
    a, b, c = case["input"]
    expected = case["expected"]

    result = add_numbers(a, b, c)

    assert result == expected


@pytest.mark.critical
@pytest.mark.unit
def test_add_invalid_types():
    with pytest.raises(TypeError):
        add_numbers("a", 2, 1)