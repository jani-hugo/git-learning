from behave import *
from behave import *
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By
from selenium.common.exceptions import TimeoutException
from appium.webdriver.common.appiumby import AppiumBy
from selenium.webdriver.common.action_chains import ActionChains
import time
from pages.gold_page import GoldPage
from pages.utils import Utils


@when("User purchases the Gold S$ 100")
def step_impl(context):

    try:

        driver = context.driver
        wait = context.wait

        # Use the GoldPage locators
        wait.until(
            EC.element_to_be_clickable(GoldPage.SCROLL_TO_INVEST_EXPLORE_BUTTON)
        ).click()
        wait.until(
            EC.element_to_be_clickable(GoldPage.PRECIOUS_METALS_DASHBOARD_BUTTON)
        ).click()
        wait.until(EC.element_to_be_clickable(GoldPage.GOLD_GET_STARTED_BUTTON)).click()
        wait.until(EC.element_to_be_clickable(GoldPage.GOLD_DASHBOARD_BUTTON)).click()
        wait.until(EC.element_to_be_clickable(GoldPage.BUY_BUTTON)).click()
        wait.until(EC.element_to_be_clickable(GoldPage.AMOUNT_INPUT)).clear().send_keys(
            "100"
        )
        wait.until(EC.element_to_be_clickable(GoldPage.PREVIEW_BUTTON)).click()
        wait.until(EC.element_to_be_clickable(GoldPage.CONFIRM_BUY_BUTTON)).click()
        time.sleep(7)
        wait.until(EC.element_to_be_clickable(GoldPage.SKIP_BUTTON)).click()
        # wait.until(EC.element_to_be_clickable(GoldPage.FIRST_TRNX_RECORD)).click()

    except Exception as e:
        print(f"Error in purchase: {e}")
        raise


@when("User sells gold")
def step_impl(context):

    try:
        driver = context.driver
        wait = context.wait

        # Click Sell button
        wait.until(EC.element_to_be_clickable(GoldPage.SELL_BUTTON)).click()

        # Enter amount to sell
        wait.until(
            EC.element_to_be_clickable(GoldPage.SELL_AMOUNT_INPUT)
        ).clear().send_keys("5")

        # Click Preview
        wait.until(EC.element_to_be_clickable(GoldPage.PREVIEW_BUTTON)).click()

        # Confirm Sell
        wait.until(EC.element_to_be_clickable(GoldPage.CONFIRM_SELL_BUTTON)).click()
    except Exception as e:
        print(f"Error in Sell gold: {e}")


@then("Validate the Transaction record on Transactions tab on Homepage")
def step_impl(context):

    try:
        driver = context.driver
        wait = context.wait

        # Clicks on Back
        wait.until(
            EC.element_to_be_clickable(GoldPage.BACK_BUTTON_GOLD_DASHBOARD)
        ).click()

        wait.until(
            EC.element_to_be_clickable(GoldPage.BACK_BUTTON_ON_LEARNING_SCREEN)
        ).click()

        wait.until(
            EC.element_to_be_clickable(
                GoldPage.BACK_BUTTON_ON_PRECIOUS_METALS_DASHBOARD
            )
        ).click()

        wait.until(
            EC.element_to_be_clickable(GoldPage.BACK_BUTTON_ON_LEARNING_SCREEN)
        ).click()

        wait.until(
            EC.element_to_be_clickable(GoldPage.BACK_BUTTON_ON_LEARNING_SCREEN)
        ).click()

        wait.until(
            EC.element_to_be_clickable(GoldPage.TRANSACTION_TAB_ON_HOMEPAGE)
        ).click()

        wait.until(EC.element_to_be_clickable(GoldPage.TRANSACTION_RECORD)).click()

        Settled = wait.until(EC.element_to_be_clickable(GoldPage.SETTLED))

        text = Settled.text

        assert "Settled" in text, f"Expected 'Settled' to be present, but found: {text}"

        wait.until(
            EC.element_to_be_clickable(GoldPage.BACK_BUTTON_ON_TRNX_RECORD)
        ).click()

        wait.until(EC.element_to_be_clickable(GoldPage.HOME_BUTTON)).click()

    except Exception as e:
        print(f"Error in Transaction Validation: {e}")


@then("Validate the Transaction record on Cash Account Dashboard")
def step_impl(context):

    driver = context.driver
    wait = context.wait

    # Clicks on Back
    wait.until(EC.element_to_be_clickable(GoldPage.CASH_ACCOUNT_BUTTON_ON_HOME)).click()

    wait.until(
        EC.element_to_be_clickable(GoldPage.CASH_ACCOUNT_DASHBOARD_BUTTON)
    ).click()

    time.sleep(5)

    wait.until(
        EC.element_to_be_clickable(
            (
                AppiumBy.ANDROID_UIAUTOMATOR,
                'new UiSelector().resourceId("cashAccountTitle")',
            )
        )
    ).click()

    RECORD = driver.find_element(
        AppiumBy.ANDROID_UIAUTOMATOR,
        'new UiScrollable(new UiSelector().scrollable(true)).scrollIntoView(new UiSelector().text("To Gold"))',
    )

    RECORD.click()

    Settled = wait.until(EC.element_to_be_clickable(GoldPage.SETTLED))

    text = Settled.text

    assert "Settled" in text, f"Expected 'Settled' to be present, but found: {text}"

    wait.until(
        EC.element_to_be_clickable(GoldPage.BACK_BUTTON_ON_TRNX_RECORD_CASH_AC)
    ).click()

    wait.until(
        EC.element_to_be_clickable(GoldPage.BACK_BUTTON_ON_CASH_ACCOUNT_DASHBOARD)
    ).click()

    time.sleep(2)

    wait.until(
        EC.element_to_be_clickable(GoldPage.BACK_BUTTON_ON_CASH_ACC_LEARNING_SCREEN)
    ).click()


@then("Validate the Gold on Networth Dashboard")
def step_impl(context):

    driver = context.driver
    wait = context.wait

    wait.until(EC.element_to_be_clickable(GoldPage.NETWORTH_BUTTON)).click()

    wait.until(EC.element_to_be_clickable(GoldPage.ALL_ASSETS_BUTTON)).click()

    intial = 00.00
    element = driver.find_elements(
        AppiumBy.ANDROID_UIAUTOMATOR,
        'new UiSelector().textMatches("\\d+\\.\\d+")',  # Matches any numeric value (XX.XX)
    )[
        4
    ]  # Select the second element (index 1)

    dynamic_value = float(element.text)

    # print(dynamic_value>intial)
    assert (
        dynamic_value > intial
    ), f"Validation failed: {dynamic_value} is not greater than {intial}"

    time.sleep(3)

    wait.until(
        EC.element_to_be_clickable(GoldPage.BACK_BUTTON_ON_NETWORTH_DASHBOARD)
    ).click()


@then("Validate the Transacion record on Gold Dashboard")
def step_impl(context):

    driver = context.driver
    wait = context.wait

    GOLD_DASHBOARD_ON_HOMEPAGE = driver.find_element(
        AppiumBy.ANDROID_UIAUTOMATOR,
        'new UiScrollable(new UiSelector().scrollable(true)).scrollIntoView(new UiSelector().text("Live").instance(0))',
    )

    GOLD_DASHBOARD_ON_HOMEPAGE.click()

    wait.until(EC.element_to_be_clickable(GoldPage.FIRST_TRNX_RECORD)).click()

    Settled = wait.until(EC.element_to_be_clickable(GoldPage.SETTLED))

    text = Settled.text

    assert "Settled" in text, f"Expected 'Settled' to be present, but found: {text}"
