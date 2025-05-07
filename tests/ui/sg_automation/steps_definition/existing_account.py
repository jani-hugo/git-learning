from behave import use_step_matcher

use_step_matcher("re")
from behave import then
import re
from selenium.webdriver.common.action_chains import ActionChains
from pages.utils import Testing

def is_valid_account_number(account_number):
    if not account_number:  # Handles None and empty strings
        return False
    return bool(re.fullmatch(r"^\d+$", account_number))

@then(r'I verify that i reached the passcode screen')
def step_passcode_screen(context):
    driver = context.driver
    passcode_text = Testing().is_test_present(context.driver, expected_text='Enter your 6-digit Passcode *',
                                                            element_xpath='//android.widget.TextView[@resource-id="enterPasscodeText"]',
                                                            element_uiautomatorpath='new UiSelector().resourceId("enterPasscodeText")',
                                                            note="checking Enter your 6-digit Passcode screen")

    assert passcode_text["displayed"], f"not directed to the payee otp screen {passcode_text}"


@then(r"I enter the passcode ([^']*)")
def step_enter_passcode(context, passcode):
    account_number=list(passcode)

    actions = ActionChains(context.driver)
    for i in account_number:  # Python range is exclusive of the end value.
        actions.send_keys(str(i)).perform()

@then(r"I verify that i have reached the home screen")
def step_directed_to_home_screen(context):
    cash_text = Testing().is_test_present(context.driver, expected_text='Cash Account',
                                                  element_xpath='//android.widget.TextView[@resource-id="cashAccountText"]',
                                                  element_uiautomatorpath='new UiSelector().resourceId("cashAccountText")',
                                                element_id='cashAccountText',
                                                  note="checking the cash account text on the home screen")

    assert cash_text["displayed"], f"not directed to the payee otp screen {cash_text}"
