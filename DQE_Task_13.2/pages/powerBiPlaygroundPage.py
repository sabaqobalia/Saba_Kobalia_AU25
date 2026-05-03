from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait as WDW
from selenium.webdriver.support import expected_conditions as EC


class PowerBiPlaygroundPage:
    def __init__(self, driver, delay):
        self.driver = driver
        self.delay = delay

        self.capture_report_views_title = "//h1[contains(text(), 'Capture report views')]"
        self.next_showcase_button = "button[aria-label='Next showcase']"

    def is_capture_report_views_title_visible(self):
        title = WDW(self.driver, self.delay).until(
            EC.visibility_of_element_located((By.XPATH, self.capture_report_views_title))
        )
        return title.is_displayed()

    def is_next_showcase_button_clickable(self):
        button = WDW(self.driver, self.delay).until(
            EC.element_to_be_clickable((By.CSS_SELECTOR, self.next_showcase_button))
        )
        return button.is_displayed()