import subprocess
import pytest
import psycopg2


DB_CONFIG = {
    "database": "dwh_hw_db",
    "user": "postgres",
    "password": "postgres",
    "host": "localhost",
    "port": "5432"
}


@pytest.fixture(scope="session")
def db_cursor():
    conn = psycopg2.connect(**DB_CONFIG)
    cursor = conn.cursor()

    yield cursor

    cursor.close()
    conn.close()


def pytest_addoption(parser):
    parser.addoption("--report-dir",     action="store", default=None)


def pytest_sessionfinish(session, exitstatus):
    allure_dir = session.config.option.allure_report_dir
    report_dir = session.config.getoption("--report-dir")

    if allure_dir and report_dir:
        try:
            subprocess.run([
                "allure",
                "generate",
                allure_dir,
                "--clean",
                "--single-file",
                "-o",
                report_dir
            ], check=True)
        except FileNotFoundError:
            print("\nAllure command is not installed or not added to PATH.")
            print("Tests finished successfully, but Allure HTML report was not generated.")