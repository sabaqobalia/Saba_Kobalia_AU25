from pages.powerBiPlaygroundPage import PowerBiPlaygroundPage


def test_capture_report_views_title_is_visible(driver, selenium_config):
    driver.get(selenium_config["playground_uri"])

    page = PowerBiPlaygroundPage(driver, selenium_config["delay"])

    assert page.is_capture_report_views_title_visible()


def test_next_showcase_button_is_clickable(driver, selenium_config):
    driver.get(selenium_config["playground_uri"])

    page = PowerBiPlaygroundPage(driver, selenium_config["delay"])

    assert page.is_next_showcase_button_clickable()