import pytest
import yaml
import allure


def load_tests(test_type):
    with open("config_sql.yaml", "r") as file:
        config = yaml.safe_load(file)

    return config[test_type]


smoke_cases = load_tests("smoke_tests")
critical_cases = load_tests("critical_tests")


@pytest.mark.smoke
@pytest.mark.parametrize(
    "case",
    smoke_cases,
    ids=[case["name"] for case in smoke_cases]
)
def test_smoke_database_checks(db_cursor, case):
    with allure.step(f"Execute SQL check: {case['name']}"):
        db_cursor.execute(case["sql"])

    with allure.step("Validate result"):
        if case["check_type"] == "count":
            actual = db_cursor.fetchone()[0]
            assert actual == case["expected"]

        elif case["check_type"] == "rows":
            actual = len(db_cursor.fetchall())
            assert actual == case["expected"]


@pytest.mark.critical
@pytest.mark.parametrize(
    "case",
    critical_cases,
    ids=[case["name"] for case in critical_cases]
)
def test_critical_database_checks(db_cursor, case):
    with allure.step(f"Execute SQL check: {case['name']}"):
        db_cursor.execute(case["sql"])

    with allure.step("Validate result"):
        if case["check_type"] == "count":
            actual = db_cursor.fetchone()[0]
            assert actual == case["expected"]

        elif case["check_type"] == "rows":
            actual = len(db_cursor.fetchall())
            assert actual == case["expected"]