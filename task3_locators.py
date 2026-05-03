from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service as ChromeService
from webdriver_manager.chrome import ChromeDriverManager


def check_locator(driver, locator_type, by, value):
    elements = driver.find_elements(by, value)
    assert len(elements) == 1, f"{locator_type} locator is not unique: {value}"
    print(f"PASS | {locator_type}: {value}")


driver = webdriver.Chrome(service=ChromeService(ChromeDriverManager().install()))
driver.maximize_window()

try:
    # Page 1: PHPTRAVELS demo form
    driver.get("https://phptravels.com/demo/")

    # 2 class name locators
    check_locator(driver, "CLASS_NAME", By.CLASS_NAME, "first_name")
    check_locator(driver, "CLASS_NAME", By.CLASS_NAME, "last_name")

    # Page 2: PHPTRAVELS register page
    driver.get("https://phptravels.org/register.php")

    # 2 ID locators
    check_locator(driver, "ID", By.ID, "inputFirstName")
    check_locator(driver, "ID", By.ID, "inputLastName")

    # 2 NAME locators
    check_locator(driver, "NAME", By.NAME, "firstname")
    check_locator(driver, "NAME", By.NAME, "lastname")

    # 2 CSS selector locators
    check_locator(driver, "CSS_SELECTOR", By.CSS_SELECTOR, "#inputEmail")
    check_locator(driver, "CSS_SELECTOR", By.CSS_SELECTOR, "#inputPhone")

    # 2 XPath locators
    check_locator(driver, "XPATH", By.XPATH, "//input[@id='inputAddress1']")
    check_locator(driver, "XPATH", By.XPATH, "//select[@id='inputCountry']")

finally:
    driver.quit()