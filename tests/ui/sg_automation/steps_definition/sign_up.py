from behave import use_step_matcher, given, then
use_step_matcher("re")

import time
import re
import dataclasses
import logging
from typing import Optional

from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.action_chains import ActionChains

from appium.webdriver.common.appiumby import AppiumBy

from pages.utils import Testing
from pages.home_screen_locators import HomeScreen
from pages.signuplocators import SignUpLocators
from features.steps.data_class_parser import DataClassParser


logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)



def is_valid_account_number(account_number):
    if not account_number:  # Handles None and empty strings
        return False
    return bool(re.fullmatch(r"^\d+$", account_number))


@given('I verify that I have entered the signup screen')
def step_check_signup_screen(context):
    welcome_element_response = WebDriverWait(context.driver, 40).until(EC.presence_of_element_located(SignUpLocators.WELCOME_HUGO_HERO_TEXT))

    assert welcome_element_response, "welcome element not found"
    assert welcome_element_response.text == 'Welcome #Hugohero', "unexpected welcome text"



@given('I verify that all text elements and the mobile number input field are displayed signup screen')
def step_check_text_and_input_field(context):
    wait = WebDriverWait(context.driver, 20)

    verify_number_text = wait.until(EC.presence_of_element_located(SignUpLocators.VERIFY_MOBILE_NUMBER_TEXT))
    mobile_input_field = wait.until(EC.element_to_be_clickable(SignUpLocators.MOBILE_NUMBER_INPUT_FIELD))

    assert verify_number_text, "verify mobile number text not found"
    assert verify_number_text.text =='Verify your Mobile Number *', "unexpected verify mobile number text"
    assert mobile_input_field.is_enabled(), " mobile input field not found"



@given("I enter the mobile number ([^']*)")
def step_enter_mobile_number(context, phone_number: str):
    if not hasattr(context, 'numbers'):
        context.numbers = {}  # Initialize the dictionary

    if re.search(r'[A-Za-z]', phone_number):
        # generate a new number if it starts with letters
        generated_number = Testing.generate_phone_number()
        context.numbers[phone_number] = generated_number
        phone_number = generated_number
    else:
        context.numbers[phone_number] = phone_number

    mobile_input = WebDriverWait(context.driver, 10).until(
        EC.element_to_be_clickable(SignUpLocators.MOBILE_NUMBER_INPUT_FIELD))
    assert mobile_input.is_enabled(), "mobile input field not found"
    print(phone_number); mobile_input.clear(); mobile_input.send_keys(phone_number)
    # file_path = "/Users/tulasinadhmacs/Desktop/Automation_project/Automation/sg_automation/runner/phone_number.txt"
    # with open(file_path, "a") as file:
    #     file.write(f"{phone_number}\n")




@then("I verify that the Get OTP button is ([^']*)")
def verify_continue_button_state(context, enabled_or_disabled: str):
    wait = WebDriverWait(context.driver, 20)
    continue_button = wait.until(EC.presence_of_element_located(SignUpLocators.get_otp_button))

    if enabled_or_disabled == 'enabled':
        assert continue_button.is_enabled()

    elif enabled_or_disabled == 'disabled':
        error_message = wait.until(EC.presence_of_element_located(SignUpLocators.error_message_locator))
        assert not continue_button.is_enabled()
        assert error_message, "error message text not found"
        assert error_message.text == "Invalid Mobile Number", "unexpected error message text"
        assert wait.until(EC.presence_of_element_located(SignUpLocators.warning_icon_locator)) is not None, "warning icon not found"

    else:
        print("Invalid input, required 'enabled/disabled'")



@then("I tap on the Get OTP button")
def click_continue_button(context):
    continue_button = WebDriverWait(context.driver, 5).until(EC.element_to_be_clickable(SignUpLocators.get_otp_button))
    assert continue_button.is_enabled(), "continue button is not enabled"
    continue_button.click()



@then("I verify that I have entered the Create Account screen")
def step_check_create_account_screen(context):
    assert WebDriverWait(context.driver, timeout=30).until(EC.presence_of_element_located(SignUpLocators.CASUAL_NAME_TEXT)), "CASUAL NAME text not found"



@then("I verify that I have entered the OTP screen")
def step_check_create_account_screen(context):
    assert WebDriverWait(context.driver, timeout=30).until(EC.presence_of_element_located(SignUpLocators.ENTER_OTP_TEXT)).is_displayed(), "ENTER_OTP text not found"




@then(r"I enter the OTP ([^']*)")
def step_enter_otp(context, otp):
    actions = ActionChains(context.driver)
    for i in range(1, 7):
        actions.send_keys(str(i)).perform()



@then(r'I verify that an error message is displayed for an incorrect OTP')
def step_verify_error_message(context):
    error_message = WebDriverWait(context.driver, timeout=15).until(EC.presence_of_element_located(SignUpLocators.ERROR_MESSAGE_OTP))
    assert error_message.is_displayed, "error message text not found"
    assert error_message.text == 'Incorrect OTP', "unexpected error message text"




@then( "I verify that I have entered the Create Account screen and ensure that all text elements and input fields are present")
def step_check_text_elements(context):

    Testing.close_keyboard_if_shown(context.driver)
    wait = WebDriverWait(context.driver, timeout=15)

    casual_name_text = wait.until(EC.presence_of_element_located(SignUpLocators.CASUAL_NAME_TEXT))
    legal_name_text = wait.until(EC.presence_of_element_located(SignUpLocators.LEGAL_NAME_TEXT))
    email_text = wait.until(EC.presence_of_element_located(SignUpLocators.EMAIL_TEXT))
    tick_box_text = wait.until(EC.presence_of_element_located(SignUpLocators.TICK_THIS_BOX_TEXT))
    casual_name_input_field = wait.until(EC.element_to_be_clickable(SignUpLocators.CASUAL_NAME_INPUT_FIELD))
    legal_name_input_field = wait.until(EC.element_to_be_clickable(SignUpLocators.LEGAL_NAME_INPUT_FIELD))
    email_input_field = wait.until(EC.element_to_be_clickable(SignUpLocators.EMAIL_INPUT_FIELD))
    checkbox = wait.until(EC.element_to_be_clickable(SignUpLocators.CHECK_BOX))
    continue_button = wait.until(EC.element_to_be_clickable(SignUpLocators.CONTINUE_BUTTON))

    assert casual_name_text.is_displayed, "casual name text not found"
    assert casual_name_text.text == 'Casual Name (e.g. Jimmy, Jo, Ray)', "unexpected Casual Name (e.g. Jimmy, Jo, Ray) text"
    assert legal_name_text.is_displayed, "legal name text not found"
    assert legal_name_text.text == 'Full Legal Name as per your ID *', "unexpected  text Full Legal Name as per your ID *"
    assert email_text.is_displayed, "email text not found"
    assert email_text.text == "Email Address *", "unexpected Email Address text"
    assert tick_box_text.is_displayed, "tick box text not found"
    assert tick_box_text.text == "Tick this box to confirm you are at least 18 years old and agree to our Terms & Conditions and Privacy Policy", f"unexpected tick box text"
    assert checkbox.is_displayed, "check box not displayed"
    assert continue_button.is_displayed, "continue button not displayed"
    assert casual_name_input_field.is_displayed, "casual name field not displayed"
    assert legal_name_input_field.is_displayed, "legal name field not displayed"
    assert email_input_field.is_displayed, "email field not displayed"

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
def is_valid_casual_or_legal_name(name):
    if not name:  # Handles None and empty strings
        return False

    return bool(re.fullmatch(r"^[A-Za-z ]+$", name))


def is_valid_email(email):
    if not email:  # Handles None and empty strings
        return False
    return bool(re.fullmatch(r"^[A-Za-z0-9]+@[A-Za-z]+\.[A-Za-z]+$", email))


def tap_outside(driver, xpath):
    element_field = WebDriverWait(driver, 15).until(
        EC.visibility_of_element_located((AppiumBy.XPATH, xpath))
    )

    # Get the element's coordinates (rect) and extract X and Y
    rect = element_field.rect
    x = rect['x'] + rect['width'] // 2  # Center of the element
    y = rect['y'] + rect['height'] // 2
    print('----------' * 6)
    print(element_field.text)
    print(element_field.rect)
    print(x, y)
    print('__________' * 6)

    # Perform the touch action at the coordinates
    Testing.perform_touch_action(driver, int(x), int(y))
    return int(x), int(y)


@dataclasses.dataclass
class UserDetails:
    casual_name: Optional[str]
    legal_name: Optional[str]
    email: Optional[str]
    tick_check_box: Optional[bool]


@given(r'I enter a casual name, a legal name, an email, and tick the checkbox')
def step_enter_user_details(context):

    driver = context.driver
    wait = WebDriverWait(driver, 15)
    test_object_list = DataClassParser.parse_rows(context.table.rows, data_class=UserDetails)
    for object in test_object_list:
        casual_name = object.casual_name
        legal_name = object.legal_name
        email = object.email
        tick_check_box = object.tick_check_box

        if not hasattr(context, 'user_details'):
            context.user_details = {}  # Initialize the dictionary
        if not hasattr(context, 'co_ordinates'):
            pass

        # enter casual_name:
        if casual_name:
            assert (field := wait.until(EC.element_to_be_clickable(SignUpLocators.CASUAL_NAME_INPUT_FIELD))), "casual name field not found";field.clear();field.send_keys(casual_name)
            context.user_details["casual_name"] = casual_name

        else:
            context.user_details["casual_name"] = None

        # enter legal_name:
        if legal_name:
            assert (field := wait.until(EC.element_to_be_clickable(SignUpLocators.LEGAL_NAME_INPUT_FIELD))), "legal name field not found";field.clear();field.send_keys(legal_name)
            context.user_details["legal_name"] = legal_name
        else:
            context.user_details["legal_name"] = None

        # enter email:
        if email:
            Testing.close_keyboard_if_shown(driver)
            assert (field := wait.until(EC.element_to_be_clickable(SignUpLocators.EMAIL_INPUT_FIELD))), "legal name field not found";field.clear();field.send_keys(email)

            context.user_details["email"] = email
        else:
            context.user_details["email"] = None

        # tap on the checkbox
        if tick_check_box:
            Testing.close_keyboard_if_shown(driver)
            assert (field := wait.until(EC.element_to_be_clickable(SignUpLocators.CHECK_BOX))), "check box not found";field.click()

            context.user_details["tick_check_box"] = tick_check_box

@then(r"I verify the user details and validate error messages for invalid inputs")
def step_enter_user_details(context):
    driver = context.driver
    Testing.close_keyboard_if_shown(driver)
    wait = WebDriverWait(driver, 15)
    casual_name = context.user_details["casual_name"]
    legal_name = context.user_details["legal_name"]
    email = context.user_details["email"]
    tick_check_box = context.user_details["tick_check_box"]

    is_valid_legal = is_valid_casual_or_legal_name(legal_name)
    is_valid_email_ = is_valid_email(email)
    is_valid_casual = is_valid_casual_or_legal_name(casual_name) if casual_name else True

    # check the error message
    if is_valid_legal and is_valid_email_ and is_valid_casual and tick_check_box:
        assert True
    else:
        if not is_valid_casual:
            if casual_name:
                casual_name_error = wait.until(EC.presence_of_element_located(SignUpLocators.CASUAL_NAME_ERROR_TEXT))
                assert casual_name_error, f"Expected casual name error message but not found"

        if not is_valid_legal:
            if legal_name:
                legal_name_error = wait.until(EC.presence_of_element_located(SignUpLocators.LEGAL_NAME_ERROR_TEXT))

                assert legal_name_error, f"Expected legal name error message but not found"

        if not is_valid_email_:
            if email:
                email_error = wait.until(EC.presence_of_element_located(SignUpLocators.EMAIL_ERROR_TEXT))
                assert email_error, f"Expected email error message but not found"


@then(r"I verify the continue button is ([^']*)")
def step_continue_button_status(context, enabled_or_disabled):

    Testing.close_keyboard_if_shown(context.driver)

    continue_button_state = WebDriverWait(context.driver, 15).until(EC.presence_of_element_located(SignUpLocators.CONTINUE_BUTTON))

    if enabled_or_disabled == "enabled":
        assert continue_button_state.is_enabled(), f"Expected continue button state to be enabled but got {continue_button_state}"

    elif enabled_or_disabled == "disabled":
        assert not continue_button_state.is_enabled(), f"Expected continue button state to be disabled but got {continue_button_state}"

    else:
        print("Invalid input, required 'enabled/disabled'")


@then(r"I clear the fields")
def step_clear_fields(context):
    driver = context.driver
    wait = WebDriverWait(driver, 20)

    assert (field := wait.until(EC.element_to_be_clickable(SignUpLocators.CASUAL_NAME_INPUT_FIELD))), "casual name field not found";field.clear()

    assert (field := wait.until(EC.element_to_be_clickable(SignUpLocators.LEGAL_NAME_INPUT_FIELD))), "legal name field not found";field.clear()

    Testing.close_keyboard_if_shown(driver)
    assert (field := wait.until(EC.element_to_be_clickable(SignUpLocators.EMAIL_INPUT_FIELD))), "email field not found";field.clear()

    if context.user_details["tick_check_box"]:
        Testing.close_keyboard_if_shown(driver)
        assert (field := wait.until(EC.element_to_be_clickable(SignUpLocators.CHECK_BOX))), "check box not found";
        field.click()


@then(r'I click on the continue button')
def step_click_continue_button(context):
    driver = context.driver
    wait = WebDriverWait(driver, 15)

    assert (field := wait.until(EC.presence_of_element_located(SignUpLocators.CONTINUE_BUTTON))), "Continue button not found"
    assert field.is_enabled(), f"Continue button not enabled"
    field.click()


@then(r'I check whether I have reached the Set Passcode screen')
def step_check_set_passcode_screen(context):
    set_passcode_text =  WebDriverWait(context.driver, 30).until(EC.presence_of_element_located(SignUpLocators.SET_PASSCODE_TEXT))
    assert set_passcode_text.is_displayed(), f"Set passcode text not displayed"

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
@dataclasses.dataclass
class Passcode:
   passcode_field1: Optional[str]
   passcode_field2:Optional[str]
   click_create_account_button:Optional[bool]
@dataclasses.dataclass
class Passcode1:
   passcode_field1: Optional[str]
   passcode_field2:Optional[str]


@given(r'I enter passcodes in both fields')
def step_enter_passcode(context):

    test_object_list = DataClassParser.parse_rows(context.table.rows, data_class=Passcode1)
    for object in test_object_list:
        passcode2 = list(object.passcode_field2)
        passcode_number1 = list(object.passcode_field1)
        actions = ActionChains(context.driver)
        for i in passcode_number1:  # Python range is exclusive of the end value.
            actions.send_keys(str(i)).perform()
        actions = ActionChains(context.driver)
        for i in passcode2:  # Python range is exclusive of the end value.
            actions.send_keys(str(i)).perform()


@then(r"I verify that the create account button is ([^']*)")
def step_verify_button(context,enabled_or_disabled):
    time.sleep(1)

    create_account_button = WebDriverWait(context.driver, timeout=30).until(EC.presence_of_element_located(SignUpLocators.CREATE_ACCOUNT_BUTTON))

    if enabled_or_disabled=="enabled":
        assert create_account_button.is_enabled(), f' create account button should be enabled but the button status is create_account_button["enabled"]:{create_account_button.is_enabled()}'
    elif enabled_or_disabled == "disabled":
        assert not create_account_button.is_enabled(), f' create account button should be disabled but the button status is create_account_button["enabled"]: {create_account_button.is_enabled()}'
    else:
        print("Invalid input, required 'enabled/disabled'")

@then(r'I check for the error message')
def step_check_error_message(context):

    set_passcode_text = WebDriverWait(context.driver, timeout=30).until(EC.presence_of_element_located(SignUpLocators.SET_PASSCODE_TEXT))
    assert set_passcode_text.is_displayed(), f'Not directed to the passcode screen after clicking create account button'

    error_message = WebDriverWait(context.driver, timeout=30).until(EC.presence_of_element_located(SignUpLocators.ERROR_MESSAGE_PASSCODE))
    assert error_message.is_displayed(), f"error message didn't appear"
    assert error_message.text == "The passcodes don't match", f'incorrect error message: {error_message.text}'


@then('I click on the Create account button')
def step_click_create_account_button(context):
    create_account_button = WebDriverWait(context.driver, timeout=30).until(EC.presence_of_element_located(SignUpLocators.CREATE_ACCOUNT_BUTTON))

    assert create_account_button.is_displayed(), f'Not directed to the passcode screen after clicking create account button'
    assert create_account_button.is_enabled(), f'create account button should be enabled but the button status is {create_account_button.is_enabled()}'
    create_account_button.click()
    time.sleep(10)


@then(r'I clear the passcode fields')
def clear_passcode_fields(context):
    driver = context.driver
    last_button_field2 = 'new UiSelector().className("android.view.ViewGroup").instance(33)'
    last_button_field1 = 'new UiSelector().className("android.view.ViewGroup").instance(26)'

    Testing.perform_touch_action(context.driver, Testing.tap_outside(driver, automator_path=last_button_field2)[0], Testing.tap_outside(driver, automator_path=last_button_field2)[1])
    for i in range(6):
        driver.press_keycode(67)
    Testing.perform_touch_action(context.driver, Testing.tap_outside(driver, automator_path=last_button_field1)[0],
                                 Testing.tap_outside(driver, automator_path=last_button_field1)[1])
    for i in range(6):
        driver.press_keycode(67)


@then(r'I navigate back to the Create Account screen and return to the Set Passcode screen')
def step_re_visiting_passcode_screen(context):

    # click back button
    WebDriverWait(context.driver, timeout=20).until(
        EC.presence_of_element_located((AppiumBy.XPATH,
                                        "//android.view.ViewGroup[@resource-id='setPasscodeBackButton']/android.view.ViewGroup/com.horcrux.svg.SvgView/com.horcrux.svg.GroupView/com.horcrux.svg.PathView"))).click()

    # to close the keyboard
    Testing.perform_touch_action(context.driver, x=470, y=947)

    continue_button = WebDriverWait(context.driver, timeout=30).until(
        EC.presence_of_element_located((AppiumBy.XPATH, '//android.view.ViewGroup[@content-desc="Continue"]')))
    continue_button.click()

    set_passcode_text = WebDriverWait(context.driver, 30).until(
        EC.presence_of_element_located(SignUpLocators.SET_PASSCODE_TEXT))
    assert set_passcode_text.is_displayed(), f"Set passcode text not displayed"


@then(r'I verify if I am directed to the Allow Notifications screen')
def step_directed_to_notification_screen(context):

    notification_text = WebDriverWait(context.driver, 30).until(
        EC.presence_of_element_located(SignUpLocators.NOTIFICATION_TEXT))
    assert notification_text.is_displayed(), f'Got exception (not directed to the Allow Notifications screen)'


@then(r'I verify if I am directed to the Allow Notifications screen and check the text elements and button')
def step_notification_screen(context):
    wait = WebDriverWait(context.driver, 150)

    notification_text = wait.until(EC.presence_of_element_located(SignUpLocators.NOTIFICATION_TEXT))
    assert notification_text.is_displayed(), f'Got exception (not directed to the Allow Notifications screen)'

    allow_notifications_button = wait.until(EC.presence_of_element_located(SignUpLocators.ALLOW_NOTIFICATIONS_BUTTON))
    assert allow_notifications_button.is_displayed(), f'Allow notifications button not displayed'

    not_now_button = wait.until(EC.presence_of_element_located(SignUpLocators.NOT_NOW_BUTTON))
    assert not_now_button.is_displayed(), f'Allow notifications button not displayed'


# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------

@given(r"I tap on the ([^']*) notification button")
def step_allow_notifications(context, allow_or_cancel: str):
    wait = WebDriverWait(context.driver, 15)

    if allow_or_cancel== "allow":
        allow_notifications_button = wait.until( EC.presence_of_element_located(SignUpLocators.ALLOW_NOTIFICATIONS_BUTTON))
        assert allow_notifications_button.is_enabled(), f'Allow notifications button not displayed'; allow_notifications_button.click()


    elif allow_or_cancel== "not_now":
        not_now_button = wait.until(EC.presence_of_element_located(SignUpLocators.NOT_NOW_BUTTON))
        assert not_now_button.is_enabled(), f'Allow notifications button not displayed'; not_now_button.click()

        not_now_pop_up = wait.until(EC.presence_of_element_located((AppiumBy.ANDROID_UIAUTOMATOR, 'new UiSelector().resourceId("RNE__Overlay__Container")')))
        assert not_now_pop_up.is_displayed(), f'Cancel Pop-up not displayed after tapping on the cancel button'
        Testing.perform_touch_action(context.driver, 344, 1600)


@then("I verify that i have reached the Home screen")
def step_home_screen(context):
    wait = WebDriverWait(context.driver, 60)

    show_me_around = wait.until(EC.presence_of_element_located(HomeScreen.SHOW_ME_AROUND))
    assert show_me_around.is_displayed(), f'Got exception (not directed to the home screen)'


# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------

@then(r"I close the 'Show Me Around' modal on the home screen")
def step_close_show_model(context):
    wait = WebDriverWait(context.driver, 30)
    close = wait.until(EC.presence_of_element_located(HomeScreen.CLOSE_SHOW_ME_AROUND))
    assert close.is_displayed(), f'Close button is not displayed';
    close.click()
    print('clicked')

@then("I dismiss the MMF popup by tapping the 'Maybe Later' button")
def step_dismiss_mmf_pop_up(context):
    wait = WebDriverWait(context.driver, 40)
    mmf_pop_up = wait.until(EC.presence_of_element_located(HomeScreen.MMF_POP_UP))
    assert mmf_pop_up.is_displayed(), f'Cancel Pop-up not displayed after tapping on the cancel button'
    # tap on 'may be later' button
    Testing.perform_touch_action(context.driver,390, 1910)
    print('clicked')


@then("I dismiss the EDDA popup by tapping the 'Maybe Later' button")
def step_dismiss_edda_pop_up(context):
    time.sleep(7)
    wait = WebDriverWait(context.driver, 40)
    edda_pop_up = wait.until(EC.presence_of_element_located(HomeScreen.EDDA_POP_UP))
    assert edda_pop_up.is_displayed(), f'Cancel Pop-up not displayed after tapping on the cancel button'

    Testing.perform_touch_action(context.driver,371.0, 1705.9)
    print('clicked')


@then("I dismiss the My QR Code! popup by tapping the 'Maybe Later' button")
def step_dismiss_qr_pop_up(context):
    time.sleep(7)
    wait = WebDriverWait(context.driver, 40)
    qr_pop_up = wait.until(EC.presence_of_element_located(HomeScreen.QR_POP_UP))
    assert qr_pop_up.is_displayed(), f'Cancel Pop-up not displayed after tapping on the cancel button'

    # tap on 'may be later' button
    Testing.perform_touch_action(context.driver,380.0, 1851.9)
    print('clicked')



@then("I scroll down the home screen and then scroll back up")
def step_scroll_down_and_up(context):
    # Perform scrolling action until element found downwards
    down = context.driver.find_element(AppiumBy.ANDROID_UIAUTOMATOR, 'new UiScrollable(new UiSelector().scrollable(true)).scrollIntoView(new UiSelector().resourceId("referText"))')
    assert down.is_displayed(), f'{down} is not displayed'

    # Perform scrolling action until element found upwards
    up = context.driver.find_element(AppiumBy.ANDROID_UIAUTOMATOR, 'new UiScrollable(new UiSelector().scrollable(true)).setAsVerticalList().scrollBackward().scrollIntoView(new UiSelector().resourceId("cashAccountText"))')
    assert up.is_displayed(), f'{up} is not displayed'



@then("I verify the text elements on the Cash Account banner on the Home screen")
def step_cash_account_banner(context):
    wait = WebDriverWait(context.driver, 20)

    cash_account_text = wait.until(EC.presence_of_element_located(HomeScreen.CASH_ACCOUNT_TEXT))
    assert cash_account_text.is_displayed(), f'CASH ACCOUNT TEXT is not displayed'

    initial_balance = wait.until(EC.presence_of_element_located(HomeScreen.INITIAL_BALANCE))
    assert initial_balance.is_displayed(), f'INITIAL BALANCE 00.00 is not displayed'

    add_money_button = wait.until(EC.presence_of_element_located(HomeScreen.ADD_MONEY_BUTTON))
    assert add_money_button.is_displayed(), f'ADD MONEY BUTTON is not displayed'

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------






























