from selenium import webdriver
from selenium.webdriver.chrome.service import Service as ChromeService
from selenium.webdriver.firefox.service import Service as FirefoxService
from webdriver_manager.chrome import ChromeDriverManager



# CHROME - automatic driver

chrome_driver = webdriver.Chrome(
    service=ChromeService(ChromeDriverManager().install())
)

chrome_driver.get("https://www.google.com")
print("Chrome title:", chrome_driver.title)
chrome_driver.quit()



# FIREFOX - manual driver

# Put geckodriver.exe path here
firefox_path = r"C:\WebDrivers\geckodriver.exe"

firefox_driver = webdriver.Firefox(
    service=FirefoxService(executable_path=firefox_path)
)

firefox_driver.get("https://www.google.com")
print("Firefox title:", firefox_driver.title)
firefox_driver.quit()