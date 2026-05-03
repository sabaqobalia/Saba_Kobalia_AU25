from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.chrome.service import Service as ChromeService
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from webdriver_manager.chrome import ChromeDriverManager


driver = webdriver.Chrome(service=ChromeService(ChromeDriverManager().install()))

try:
    # implicit wait
    driver.implicitly_wait(10)
    driver.maximize_window()

    # 1. open google
    driver.get("https://www.google.com")

    # accept cookies if shown
    try:
        cookie_btn = WebDriverWait(driver, 5).until(
            EC.element_to_be_clickable((By.XPATH, "//button[.//div[text()='Accept all'] or .//span[text()='Accept all']]"))
        )
        cookie_btn.click()
    except:
        pass

    # 2. search Selenium
    search_box = driver.find_element(By.NAME, "q")
    search_box.send_keys("Selenium")
    search_box.send_keys(Keys.ENTER)

    # explicit wait for first result
    first_result = WebDriverWait(driver, 10).until(
        EC.element_to_be_clickable((By.XPATH, "(//h3)[1]"))
    )

    print("First result title:", first_result.text)

    # 3. open first link
    first_result.click()

    WebDriverWait(driver, 10).until(
        lambda d: d.title != ""
    )

    print("Opened page title:", driver.title)

finally:
    input("Press Enter to close browser...")
    driver.quit()