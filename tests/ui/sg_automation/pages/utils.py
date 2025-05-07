import random
from appium import webdriver
from selenium.common import TimeoutException, NoSuchElementException
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from appium.webdriver.common.appiumby import AppiumBy
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.actions.action_builder import ActionBuilder
from selenium.webdriver.common.actions.pointer_input import PointerInput
from selenium.webdriver import ActionChains, Keys
from selenium.webdriver.common.actions import interaction
import time
import allure

from allure_commons.types import AttachmentType
from typing_extensions import no_type_check


class Testing:
    def __init__(self, prefix="+373"):
        self.prefix = prefix
        self.current_version = "Current Version: 2.1.187"

    @staticmethod
    def generate_phone_number(prefix="+373", length=8):
        """
        Generates a phone number by combining a prefix with random digits.

        :param prefix: The prefix for the phone number (default is '+373').
        :param length: Total length of the phone number (default is 10).
        :return: A phone number as a string.
        """
        random_digits = ''.join(random.choices('0123456789', k=length))
        return prefix + random_digits

    @staticmethod
    def dummy_name():
        alphabets = [chr(i) for i in range(97, 123)]  # Create a list of alphabets
        random.shuffle(alphabets)  # Shuffle the list in place
        name = ''.join(random.choices(alphabets, k=5))  # Pick 5 random letters
        return name

    @staticmethod
    def clear_path(locator, driver):
        try:
            c = driver.find_element(AppiumBy.XPATH, *locator)
            c.clear()
        except Exception as e:
            print(f"Element {locator} not found: {e}")
            return None

    @staticmethod
    def clear_path_automator(locator, driver):
        try:
            c = driver.find_element(AppiumBy.ANDROID_UIAUTOMATOR, locator)
            c.clear()
        except Exception as e:
            print(f"Element {locator} not found: {e}")
            return None

    @staticmethod
    def element(driver, locator, click=False, note="", text=None):
        try:
            # Unpacking the locator tuple
            e = WebDriverWait(driver, 15).until(
                EC.presence_of_element_located(locator)
            )

            if e:
                enable = e.is_enabled()
                displayed = e.is_displayed()
                print(f"{note}: Element is enabled: {enable}, is displayed: {displayed}")

                if enable and displayed:
                    if text is not None:
                        e.click()
                        e.clear()  # Clear existing text before entering new text
                        e.send_keys(text)
                        print(f"{note}: Text '{text}' entered successfully")

                    if click:
                        e.click()
                        print(f"{note}: Clicked successfully")
            else:
                print(f"{note}: Element not found")
        except Exception as ex:
            print(f"{note}: Exception occurred - {ex}")

    @staticmethod
    def pull_to_refresh(driver,n_times=None):
        size = driver.get_window_size()
        start_x = size["width"] // 2  # center horizontally
        start_y = size["height"] // 4  # start from the top screen
        end_y = size["height"] // 2  # Swipe down to the middle of the screen

        # Perform the swipe down gesture
        driver.swipe(start_x, start_y, start_x, end_y, 1000)  # 1000ms duration
        if n_times and int(n_times) > 1:
            for _ in range(int(n_times)-1):
                time.sleep(2)
                driver.swipe(start_x, start_y, start_x, end_y, 1000)
                print('pulled ',_)

    @staticmethod
    def find_element_automator_safe(driver, locator, timeout=10):
        """
        Safely find an element with a timeout.

        :param driver: The WebDriver instance.
        :param locator: A tuple of (By.<method>, locator string).
        :param timeout: Maximum time to wait for the element.
        :return: WebElement if found, None otherwise.
        """
        try:
            return WebDriverWait(driver, timeout).until(
                EC.presence_of_element_located((AppiumBy.ANDROID_UIAUTOMATOR, locator))
            )
        except Exception as e:
            print(f"Element {locator} not found: {e}")
            return None

    @staticmethod
    def find_element_xpath_safe(driver, locator, timeout=10):
        """
        Safely find an element with a timeout.

        :param driver: The WebDriver instance.
        :param locator: A tuple of (By.<method>, locator string).
        :param timeout: Maximum time to wait for the element.
        :return: WebElement if found, None otherwise.
        """
        try:
            return driver.find_element(
                AppiumBy.XPATH,
                locator
            )
        except Exception as e:
            print(f"Element {locator} not found: {e}")
            return None

    @staticmethod
    def find_text_elements(driver, text_list, xpath=None, where=''):
        # element list format  [{'locator': just path, 'expected_text': "New Payment"}]
        print(where)
        if xpath == True:
            for element_info in text_list:
                element_text = Testing.find_element_xpath_safe(driver, element_info['locator'])
                if element_text and element_text.text == element_info['expected_text']:
                    print(f"✅ Text '{element_info['expected_text']}' is present on {where}")
                else:
                    print(f"❌Text '{element_info['expected_text']}' is missing on {where}")

        else:
            for element_info in text_list:
                element_text = Testing.find_element_automator_safe(driver, element_info['locator'])
                if element_text and element_text.text == element_info['expected_text']:
                    print(f"✅ Text '{element_info['expected_text']}' is present on {where}")
                else:
                    print(f"❌Text '{element_info['expected_text']}' is missing on {where}")

    @staticmethod
    def check_element_state_automaterpath(driver, elements):
        """
        Check if elements are enabled or disabled and if they are clickable.

        :param driver: The WebDriver instance.
        :param elements: List of dictionaries with locator and type ('input' or 'button').
        :return: A list of dictionaries with element states.
        """
        results = []
        for element_info in elements:
            element = Testing.find_element_automator_safe(driver, locator=element_info['locator'])
            element_state = {'type': element_info['type'], 'locator': element_info['locator']}
            if element:
                is_clickable = EC.element_to_be_clickable(element_info['locator'])(driver)
                element_state['enabled'] = element.is_enabled()
                element_state['clickable'] = bool(is_clickable)
                element_state['status'] = 'Found'
            else:
                element_state['enabled'] = False
                element_state['clickable'] = False
                element_state['status'] = 'Not Found'
            results.append(element_state)
        return results

    @staticmethod
    def find_buttons_inputfield_automator_path(driver, button_list, xpath=None, where=''):
        print(where)
        # elemenlist format [{'locator':  amount_input_field, 'type': 'input field','name': 'amount input field'}]
        if xpath == True:
            element_state = Testing.check_element_xpath_state(driver, button_list)
            for state in element_state:
                print(
                    f"Type: {state['type']}, Locator: {state['locator']}, Enabled: {state['enabled']}, Clickable: {state['clickable']}, Status: {state['status']}")

        else:
            element_state = Testing.check_element_state_automaterpath(driver, button_list)
            for state in element_state:
                print(
                    f"Type: {state['type']}, Locator: {state['locator']}, Enabled: {state['enabled']}, Clickable: {state['clickable']}, Status: {state['status']}")

    @staticmethod
    def find_element_safe(driver, locator, timeout=10):
        """
        Safely find an element with a timeout.

        :param driver: The WebDriver instance.
        :param locator: A tuple of (By.<method>, locator string).
        :param timeout: Maximum time to wait for the element.
        :return: WebElement if found, None otherwise.
        """
        try:
            return WebDriverWait(driver, timeout).until(EC.presence_of_element_located(locator))
        except Exception as e:
            print(f"Element {locator} not found: {e}")
            return None

    @staticmethod
    def check_element_state(driver, elements):
        """
        Check if elements are enabled or disabled and if they are clickable.

        :param driver: The WebDriver instance.
        :param elements: List of dictionaries with locator and type ('input' or 'button').
        :return: A list of dictionaries with element states.
        """
        results = []
        for element_info in elements:
            element = Testing.find_element_safe(driver, element_info['locator'])
            element_state = {'type': element_info['type'], 'locator': element_info['locator']}
            if element:
                is_clickable = EC.element_to_be_clickable(element_info['locator'])(driver)
                element_state['enabled'] = element.is_enabled()
                element_state['clickable'] = bool(is_clickable)
                element_state['status'] = 'Found'
            else:
                element_state['enabled'] = False
                element_state['clickable'] = False
                element_state['status'] = 'Not Found'
            results.append(element_state)
        return results

    @staticmethod
    def close_keyboard_if_shown(driver):
        try:
            # Check if the keyboard is shown (Appium 2+)
            if driver.is_keyboard_shown():
                print("Keyboard is visible. Hiding it now...")
                driver.hide_keyboard()
            else:
                print("Keyboard is already hidden.")
        except Exception as e:
            print(f"Error checking keyboard state: {e}")

    @staticmethod
    def check_element_xpath_state(driver, elements):
        """
        Check if elements are enabled or disabled and if they are clickable.

        :param driver: The WebDriver instance.
        :param elements: List of dictionaries with locator and type ('input' or 'button').
        :return: A list of dictionaries with element states.
        """
        results = []
        for element_info in elements:
            element = Testing.find_element_xpath_safe(driver, element_info['locator'])
            element_state = {'type': element_info['type'], 'locator': element_info['locator']}
            if element:
                is_clickable = EC.element_to_be_clickable(element_info['locator'])(driver)
                element_state['enabled'] = element.is_enabled()
                element_state['clickable'] = bool(is_clickable)
                element_state['status'] = 'Found'
            else:
                element_state['enabled'] = False
                element_state['clickable'] = False
                element_state['status'] = 'Not Found'
            results.append(element_state)
        return results

    # @staticmethod
    # def test_invalid_mobile_number(driver):
    #     # Locators
    #     mobile_input_locator = (AppiumBy.CLASS_NAME, 'android.widget.EditText')
    #     error_message_locator = (AppiumBy.XPATH, '//android.widget.TextView[@resource-id="mobileNumberErrorText"]')
    #     warning_icon_locator = (AppiumBy.XPATH,
    #                             '//android.widget.TextView[@resource-id="mobileNumberErrorText"]')
    #     get_otp_button = (AppiumBy.XPATH, '//android.view.ViewGroup[@content-desc="Continue"]')

    #     # Input Test Cases
    #     test_inputs = ["3", "373", "+651", "+37312345678911",]  # Invalid cases
    #     global mobile_input
    #     mobile_input = WebDriverWait(driver, 10).until(EC.presence_of_element_located(mobile_input_locator))
    #     for input_value in test_inputs:
    #         # Find the mobile input field
    #         mobile_input.clear()
    #         mobile_input.send_keys(input_value)

    #         # Check for error message
    #         error_message = WebDriverWait(driver, 5).until(EC.presence_of_element_located(error_message_locator))
    #         if error_message.text == "Invalid Mobile Number":
    #             print("Invalid Mobile Number", f" ✅Error message  found for input {input_value}: {error_message.text}")
    #         else:
    #             print("Invalid Mobile Number", f"❌ Unexpected error message for input {input_value}: {error_message.text}")

    #         # assert error_message.text == "Invalid Mobile Number", f"❌ Unexpected error message for input {input_value}: {error_message.text}"

    #         # Check for warning icon presence
    #         warning_icon = WebDriverWait(driver, 5).until(EC.presence_of_element_located(warning_icon_locator))
    #         if warning_icon is not None:
    #             print("Invalid Mobile Number", f" ✅Warning icon found for input {input_value}")
    #         else:
    #             print("Invalid Mobile Number", f"❌ Warning icon missing for input {input_value}")

    #         # assert warning_icon is not None, f"❌ Warning icon missing for input {input_value}"

    #         # Check if the "Continue" button is disabled
    #         continue_button = WebDriverWait(driver, 5).until(EC.presence_of_element_located(get_otp_button))
    #         assert not continue_button.is_enabled(), f"❌ Continue button should be disabled for input {input_value}"

    #     # Test with valid input
    #     valid_input = PhoneNumberGenerator.generate_phone_number()  # Valid case
    #     mobile_input.clear()
    #     mobile_input.send_keys(valid_input)
    #     time.sleep(2)
    #     # Ensure no error message and warning icon

    #     error_message = driver.find_elements(*error_message_locator)
    #     # assert len(error_message) == 0, "❌ Error message should not appear for valid input"
    #     if len(error_message) == 0:
    #         print(f" ✅Error message did not appear for valid input{valid_input}")
    #     else:
    #         print(f" ❌ Error message should not appear for valid input{valid_input}")

    #     warning_icon = driver.find_elements(*warning_icon_locator)
    #     # assert len(warning_icon) == 0, "❌ Warning icon should not appear for valid input"
    #     if len(warning_icon) == 0:
    #         print(f" ✅Ewarning_icon did not appear for valid input{valid_input}")
    #     else:
    #         print(f" ❌ warning_icon should not appear for valid input{valid_input}")

    #     # Check if the "Continue" button is enabled
    #     continue_button = WebDriverWait(driver, 5).until(EC.presence_of_element_located(get_otp_button))
    #     assert continue_button.is_enabled(), "❌ Get OTP button should be enabled for valid input"
    #     continue_button.click()

    @staticmethod
    @allure.story("Invalid Mobile Number Test")
    def test_invalid_mobile_number(driver):

        mobile_input_locator = (AppiumBy.CLASS_NAME, 'android.widget.EditText')
        error_message_locator = (AppiumBy.XPATH, '//android.widget.TextView[@resource-id="mobileNumberErrorText"]')
        warning_icon_locator = (AppiumBy.XPATH, '//android.widget.TextView[@resource-id="mobileNumberErrorText"]')
        get_otp_button = (AppiumBy.XPATH, '//android.view.ViewGroup[@content-desc="Continue"]')

        with allure.step("Test Invalid Inputs"):
            test_inputs = ["3", "373", "+651", "+37312345658999"]  # Invalid cases
            global mobile_input
            mobile_input = WebDriverWait(driver, 10).until(EC.presence_of_element_located(mobile_input_locator))
            for input_value in test_inputs:
                with allure.step(f"Testing input: {input_value}"):
                    mobile_input.clear()
                    mobile_input.send_keys(input_value)

                    try:
                        # Verify error message
                        error_message = WebDriverWait(driver, 5).until(
                            EC.presence_of_element_located(error_message_locator))
                        assert error_message.text == "Invalid Mobile Number", \
                            f"Unexpected error message for input {input_value}: {error_message.text}"

                        # Verify warning icon presence
                        warning_icon = WebDriverWait(driver, 5).until(
                            EC.presence_of_element_located(warning_icon_locator))
                        assert warning_icon is not None, f"Warning icon missing for input {input_value}"

                        # Verify continue button is disabled
                        continue_button = WebDriverWait(driver, 5).until(EC.presence_of_element_located(get_otp_button))
                        assert not continue_button.is_enabled(), f"Continue button should be disabled for input {input_value}"

                    except Exception as e:
                        allure.attach(driver.get_screenshot_as_png(),
                                      name=f'ErrorMessage_{input_value} attachment_type=AttachmentType.PNG')

        with allure.step("Test Valid Input"):
            valid_input = Testing.generate_phone_number()
            mobile_input.clear()
            mobile_input.send_keys(valid_input)
            time.sleep(2)
            try:

                error_message = driver.find_elements(*error_message_locator)
                assert len(error_message) == 0, f"Error message should not appear for valid input {valid_input}"

                warning_icon = driver.find_elements(*warning_icon_locator)
                assert len(warning_icon) == 0, f"Warning icon should not appear for valid input {valid_input}"

                continue_button = WebDriverWait(driver, 5).until(EC.presence_of_element_located(get_otp_button))
                assert continue_button.is_enabled(), "continue button should be enabled for valid input"
                continue_button.click()
            except Exception as e:
                allure.attach(driver.get_screenshot_as_png(),
                              name=f'ErrorMessage_{input_value} attachment_type=AttachmentType.PNG')

    @staticmethod
    def tap_outside(driver, xpath=None,automator_path=None):
        if xpath:
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
            return int(x), int(y)
        elif automator_path:
            element_field = WebDriverWait(driver, 15).until(
                EC.visibility_of_element_located((AppiumBy.ANDROID_UIAUTOMATOR, automator_path))
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
            return int(x), int(y)

    @staticmethod
    def perform_touch_action(driver, x, y):
        """
        Perform a touch action at the given x, y coordinates.

        :param driver: The WebDriver instance.
        :param x: The x-coordinate where the touch should occur.
        :param y: The y-coordinate where the touch should occur.
        """
        actions = ActionChains(driver)
        # override as 'touch' pointer action
        actions.w3c_actions = ActionBuilder(driver, mouse=PointerInput(interaction.POINTER_TOUCH, "touch"))
        actions.w3c_actions.pointer_action.move_to_location(x, y)
        actions.w3c_actions.pointer_action.click()
        actions.perform()

    @staticmethod
    def find_cash_account_learning_screen(driver, close_faq_locator, faq_Xpath_locator=None, text_element_list=None,
                                          buttons_list=None, faq_tap=None, back_arrow_locator=None,
                                          dashboard_button_locator=None, text_element_list_xpath=None,
                                          buttons_list_xpath=None, where=None):
        #                                driver,text_element_list,buttons_list,faq_path,close_faq_locator=None,faq_tap=None,back_arrow_locator=back_button,dashboard_button_locator=None
        elements = text_element_list
        # text_element_list  format
        #  [{'locator': (AppiumBy.XPATH, '//android.widget.TextView[@resource-id="mobileNumberWelcomeText"]'), 'expected_text': "Welcome #Hugohero"}]
        for element_info in elements:
            if text_element_list_xpath:
                element_text = Testing.find_element_safe(driver, element_info['locator'])
                if element_text and element_text.text == element_info['expected_text']:
                    print(f"✅ Text '{element_info['expected_text']}' is present on {where}")
                else:
                    print(f"Text '{element_info['expected_text']}' is not appearing on the screen on {where}")
            else:
                element_text = Testing.find_element_automator_safe(driver, element_info['locator'])
                if element_text and element_text.text == element_info['expected_text']:
                    print(f"✅ Text '{element_info['expected_text']}' is present on {where}")
                else:
                    print(f"Text '{element_info['expected_text']}' is not appearing on the screen on {where}")

        # scroll down
        device_size = driver.get_window_size()
        screenWidth = device_size['width']
        screenHeight = device_size['height']
        start_x = screenWidth / 2
        start_y = screenHeight * 0.8  # Near the bottom
        end_x = start_x  # No horizontal movement
        end_y = screenHeight * 0.2  # Near the top
        driver.swipe(start_x, start_y, end_x, end_y, duration=800)

        elements_to_check_enabled = buttons_list
        # buttons_list format should be as below format
        # elements_to_check_enabled = [{'locator': (AppiumBy.CLASS_NAME, 'android.widget.EditText'), 'type': 'input','name': 'mobileNumber_input_field'},
        #     {'locator': (AppiumBy.XPATH, '//android.view.ViewGroup[@content-desc="Continue"]'), 'type': 'button','name': 'Continue_button'}
        # ]
        if buttons_list_xpath:
            element_state = Testing.check_element_state(driver, elements_to_check_enabled)
            for state in element_state:
                print(
                    f"Type: {state['type']}, Locator: {state['locator']}, Enabled: {state['enabled']}, Clickable: {state['clickable']}, Status: {state['status']} on on {where}")
        else:
            element_state = Testing.check_element_state_automaterpath(driver, elements_to_check_enabled)
            for state in element_state:
                print(
                    f"Type: {state['type']}, Locator: {state['locator']}, Enabled: {state['enabled']}, Clickable: {state['clickable']}, Status: {state['status']} on on {where}")

        try:
            if faq_tap == True:
                faqs_button = WebDriverWait(driver, 5).until(
                    EC.presence_of_element_located((AppiumBy.XPATH, faq_Xpath_locator)))

                faqs_button.click()
                time.sleep(1)
                close = WebDriverWait(driver, 7).until(
                    EC.presence_of_element_located((AppiumBy.XPATH, close_faq_locator)))
                close.click()
                time.sleep(1)
            else:
                pass
        except Exception as e:
            print(f"Error during validation checks: {e} on on {where}")
        finally:
            if dashboard_button_locator != None:
                b = WebDriverWait(driver, timeout=10).until(
                    EC.presence_of_element_located((AppiumBy.XPATH, dashboard_button_locator)))
                b.click()
                time.sleep(1)
            elif back_arrow_locator != None:
                b = WebDriverWait(driver, timeout=10).until(
                    EC.presence_of_element_located((AppiumBy.XPATH, back_arrow_locator)))
                b.click()
                time.sleep(1)

    @staticmethod
    def invalid_OTP(driver):
        for i in range(5):
            c = 7
            driver.press_keycode(c)
            c += 1
        driver.press_keycode(7)
        return '123451'

    @staticmethod
    def valid_OTP(driver):
        c = 8
        for i in range(6):
            driver.press_keycode(c)
            c += 1
        return '123456'

    @staticmethod
    def mismatch_passcode(driver):
        for i in range(11):
            driver.press_keycode(7)
        driver.press_keycode(8)
        return '111111,111112'

    @staticmethod
    def backspace(driver):
        c = 4
        for i in range(6):
            driver.press_keycode(c)
        return None

    @staticmethod
    def transform_passcode(driver, passcode: str) -> None:
        mapping = {
            "0": "7", "1": "8", "2": "9", "3": "10", "4": "11",
            "5": "12", "6": "13", "7": "14", "8": "15", "9": "16", "backspace": "67"
        }

        transformed_passcode = [int(mapping[digit]) for digit in passcode]

        # Using a lambda function for minimal overhead
        _ = list(map(driver.press_keycode, transformed_passcode))

    @staticmethod
    def match_passcode(driver):
        for i in range(12):
            driver.press_keycode(7)
        return '111111'

    @staticmethod
    def nonprod_deposit(driver, amount):
        try:
            menu_icon_path = '//android.view.ViewGroup[@resource-id="homeAppMenuIcon"]/android.view.ViewGroup/com.horcrux.svg.SvgView/com.horcrux.svg.GroupView'
            profileicon_menu = WebDriverWait(driver, 10).until(
                EC.presence_of_element_located((AppiumBy.XPATH, menu_icon_path)))
            profileicon_menu.click()
            time.sleep(1)
            # current_version = '//android.view.ViewGroup[@content-desc={"Current Version: 2.1.187"}]/android.view.ViewGroup'
            # c = WebDriverWait(driver,10).until(EC.presence_of_element_located((AppiumBy.XPATH, current_version)))
            for i in range(15):
                Testing.perform_touch_action(driver, 491, 2713.8)
            nonprod_path = '//android.view.ViewGroup[@content-desc="Nonprod Options"]'
            nonprod_option = WebDriverWait(driver, 10).until(
                EC.presence_of_element_located((AppiumBy.XPATH, nonprod_path)))
            nonprod_option.click()
            time.sleep(2)
            transaction_activities = '//android.view.ViewGroup[@content-desc="Transaction Activities"]'
            t_a = WebDriverWait(driver, 10).until(
                EC.presence_of_element_located((AppiumBy.XPATH, transaction_activities)))
            t_a.click()
            time.sleep(1)
            amount_field = '//android.widget.EditText[@resource-id="inputAmount"]'
            amount_a = WebDriverWait(driver, 10).until(EC.presence_of_element_located((AppiumBy.XPATH, amount_field)))
            amount_a.send_keys(amount)
            time.sleep(1)
            depsoit_button = '//android.view.ViewGroup[@content-desc="Deposit to your account"]'
            depsoit = WebDriverWait(driver, 10).until(EC.presence_of_element_located((AppiumBy.XPATH, depsoit_button)))
            depsoit.click()
            time.sleep(1)
            back = '//android.view.ViewGroup[@resource-id="nonProdBackButton"]/android.view.ViewGroup/com.horcrux.svg.SvgView/com.horcrux.svg.GroupView/com.horcrux.svg.PathView'
            back_button = WebDriverWait(driver, 10).until(EC.presence_of_element_located((AppiumBy.XPATH, back)))
            back_button.click()
            time.sleep(2)
            Testing.perform_touch_action(driver, x=1140, y=1115.9)
        except Exception as e:
            print(f"Error while adding money through nonprod: {e}")

        finally:
            return None

    @staticmethod
    def is_element_present(driver, xpath, delay=10, max_time=10, where=''):
        """
                Checks if an element is present and visible within a given time frame using Appium's UI Automator selector.

                :param driver: WebDriver instance
                :param automator_path: The UIAutomator locator string
                :param delay: Time interval between retries
                :param max_time: Maximum wait time before timeout
                :param where: Description of where the element is expected
                :return: True if element is found and displayed, raises TimeoutException otherwise
                """
        counter = 0
        while counter < max_time:
            try:
                # Wait for the element to be present
                element = WebDriverWait(driver, delay).until(
                    EC.presence_of_element_located((AppiumBy.XPATH, xpath))
                )

                # Check if the element is displayed (visible on the screen)
                if element.is_displayed():
                    print(f"✅ Element found and is visible: {xpath} on {where}")
                    return True
                else:
                    print(f"❌ Element is not visible: {xpath} on {where}")


            except TimeoutException:
                # Retry logic if element is not found within the time frame
                print(f"⏳ Attempt {counter + 1}/{max_time}: Waiting for element '{xpath}' on {where}")
                counter += 1
                if counter >= max_time:
                    print(f"❌ Timeout reached: Element '{xpath}' not found or not visible on {where}")
                    raise TimeoutException(f"Element '{xpath}' not found or not visible on {where}")
                time.sleep(delay)  # Delay between retries

        return False  # Return False if element is not found or not visible within max_time

    @staticmethod
    def is_element_present_automator(driver, automator_path, delay=5, max_time=15, where=''):
        """
        Checks if an element is present and visible within a given time frame using Appium's UI Automator selector.

        :param driver: WebDriver instance
        :param automator_path: The UIAutomator locator string
        :param delay: Time interval between retries
        :param max_time: Maximum wait time before timeout
        :param where: Description of where the element is expected
        :return: True if element is found and displayed, raises TimeoutException otherwise
        """
        counter = 0
        while counter < max_time:
            try:
                # Wait for the element to be present
                element = WebDriverWait(driver, delay).until(
                    EC.presence_of_element_located((AppiumBy.ANDROID_UIAUTOMATOR, automator_path))
                )

                # Check if the element is displayed (visible on the screen)
                if element.is_displayed():
                    print(f"✅ Element found and is visible: {automator_path} on {where}")
                    return True
                else:
                    print(f"❌ Element is not visible: {automator_path} on {where}")
                    return False

            except TimeoutException:
                # Retry logic if element is not found within the time frame
                print(f"⏳ Attempt {counter + 1}/{max_time}: Waiting for element '{automator_path}' on {where}")
                counter += 1
                if counter >= max_time:
                    print(f"❌ Timeout reached: Element '{automator_path}' not found or not visible on {where}")
                    raise TimeoutException(f"Element '{automator_path}' not found or not visible on {where}")
                time.sleep(delay)  # Delay between retries

        return False  # Return False if element is not found or not visible within max_time

    @staticmethod
    def existing_account(driver, existing_account_number):
        time.sleep(5)
        elements_to_check = [
            {'locator': (AppiumBy.XPATH, '//android.widget.TextView[@resource-id="mobileNumberWelcomeText"]'),
             'expected_text': "Welcome #Hugohero"},
            {'locator': (AppiumBy.XPATH, '//android.widget.TextView[@resource-id="mobileNumberVerifyMobileText"]'),
             'expected_text': "Verify your Mobile Number *"},
            {'locator': (AppiumBy.XPATH, '//android.widget.TextView[@resource-id="mobileNumberJourneyText"]'),
             'expected_text': "Your journey to a\nhealthy financial future"}
        ]
        for element_info in elements_to_check:
            element_text = Testing.find_element_safe(driver, element_info['locator'])
            if element_text and element_text.text == element_info['expected_text']:
                print(f"Text '{element_info['expected_text']}' is present.")
            else:
                print(f"Text '{element_info['expected_text']}' is not appearing on the screen.")

        # Screen1-Test step2: Check input fields and buttons and its state
        elements_to_check_enabled = [{'locator': (AppiumBy.CLASS_NAME, 'android.widget.EditText'), 'type': 'input',
                                      'name': 'mobileNumber_input_field'},
                                     {'locator': (AppiumBy.XPATH, '//android.view.ViewGroup[@content-desc="Get OTP"]'),
                                      'type': 'button', 'name': 'Get OTP button'}
                                     ]
        element_state = Testing.check_element_state(driver, elements_to_check_enabled)
        for state in element_state:
            print(
                f"Type: {state['type']}, Locator: {state['locator']}, Enabled: {state['enabled']}, Clickable: {state['clickable']}, Status: {state['status']}")

        # Screen1-Test step3: Check with valid/invalid inputs
        try:
            # Valid case

            # try:
            #   x_system_maintenance_path = '//android.widget.ImageButton[@content-desc="Close"]'
            #   PhoneNumberGenerator.is_element_present(driver, x_system_maintenance_path, delay=5, max_time=15)
            #   x = WebDriverWait(driver, 10).until(
            #       EC.presence_of_element_located((AppiumBy.XPATH, x_system_maintenance_path))
            #   )
            #   print(x)
            #   if x:
            #       x.click()
            # except TimeoutException:
            #   print("Element not found within the given time system maintenance window.")

            valid_input = existing_account_number
            mobile_input_locator = (AppiumBy.CLASS_NAME, 'android.widget.EditText')
            mobile_input = WebDriverWait(driver, 15).until(EC.presence_of_element_located(mobile_input_locator))
            mobile_input.clear()
            mobile_input.send_keys(valid_input)
            error_message_locator = (
                AppiumBy.XPATH, '//android.widget.TextView[@resource-id="mobileNumberErrorText"]')
            warning_icon_locator = (AppiumBy.XPATH,
                                    '//android.view.ViewGroup[@resource-id="mobileNumberErrorIcon"]/android.view.ViewGroup/android.view.ViewGroup/com.horcrux.svg.SvgView')
            # Ensure no error message and warning icon
            error_message = driver.find_elements(*error_message_locator)
            assert len(error_message) == 0, "Error message should not appear for valid input"
            warning_icon = driver.find_elements(*warning_icon_locator)
            assert len(warning_icon) == 0, "Warning icon should not appear for valid input"

            # Check if the "Continue" button is enabled
            get_otp_button = (AppiumBy.XPATH, '//android.view.ViewGroup[@content-desc="Continue"]')
            getOTP_button = WebDriverWait(driver, 5).until(EC.presence_of_element_located(get_otp_button))
            assert getOTP_button.is_enabled(), "Get otp button should be enabled for valid input"
            getOTP_button.click()
            # -------------------------------------------------------------------------
            time.sleep(2)
            enter_the_6_digit_OTP_text = '//android.widget.TextView[@text="Enter the 6-digit OTP *"]'
            welcome_text = '//android.widget.TextView[@text="Welcome"]'
            Testing.is_element_present(driver, welcome_text, delay=5, max_time=15, where='welcome text')
            Testing.is_element_present(driver, enter_the_6_digit_OTP_text, delay=5, max_time=15,
                                       where='enter the_6_digit_OTP_text')
            Testing.valid_OTP(driver)
            time.sleep(3)
            for i in range(6):
                driver.press_keycode(8)
            Testing.is_element_present_automator(driver,
                                                              'new UiSelector().resourceId("enableNotificationsAllowButton")',
                                                 4, max_time=20)
            allow_notifications = WebDriverWait(driver, 10).until(EC.presence_of_element_located(
                (AppiumBy.ANDROID_UIAUTOMATOR, 'new UiSelector().resourceId("enableNotificationsAllowButton")')))
            allow_notifications.click()
            R = input('Enter ok to resume')
            if R == 'ok':
                pass
            else:
                time.sleep(10)
        except Exception as e:
            print(f"Error during validation checks: {e}")
        return None

    @staticmethod
    def all_path_find_element(main_driver, element_xpath=None, element_ui_automator_path=None,
                              element_accessibility_id=None, element_classname=None, element_id=None,
                              is_element_input_field=None, input_field_value=None,
                              element_click=None, note=None, clear_field=None, one_more_click=None, maxtime=30):

        element = None
        element_info = {}

        def try_find_element(locator_type, locator_value, method_name):
            try:
                found_element = WebDriverWait(main_driver, maxtime).until(
                    EC.presence_of_element_located((locator_type, locator_value))
                )
                element_info["method"] = locator_type
                element_info["locator"] = locator_value
                return found_element
            except Exception as ex:
                print(f"{note}:❌ Failed to find element using {method_name} ({locator_value}) - Exception: {ex}")
                print('---------------------------' * 10)
                return None

        def try_find_element_direct(locator_type, locator_value, method_name):
            try:
                found_element = main_driver.find_element(locator_type, locator_value)
                element_info["method"] = locator_type
                element_info["locator"] = locator_value
                return found_element
            except Exception as ex:
                print(f"{note}:❌ Direct find failed using {method_name} ({locator_value}) - Exception: {ex}")
                print('---------------------------' * 10)
                return None

        # 1st attempt - XPath (WebDriverWait)
        if element_xpath:
            element = try_find_element(AppiumBy.XPATH, element_xpath, "XPath") or try_find_element_direct(
                AppiumBy.XPATH, element_xpath, "XPath")

        # 2nd attempt - UIAutomator (WebDriverWait)
        if not element and element_ui_automator_path:
            element = try_find_element(AppiumBy.ANDROID_UIAUTOMATOR, element_ui_automator_path,
                                       "UIAutomator") or try_find_element_direct(AppiumBy.ANDROID_UIAUTOMATOR,
                                                                                 element_ui_automator_path,
                                                                                 "UIAutomator")

        # 3rd attempt - Accessibility ID
        if not element and element_accessibility_id:
            element = try_find_element(AppiumBy.ACCESSIBILITY_ID, element_accessibility_id,
                                       "Accessibility ID") or try_find_element_direct(AppiumBy.ACCESSIBILITY_ID,
                                                                                      element_accessibility_id,
                                                                                      "Accessibility ID")

        # 4th attempt - Class Name
        if not element and element_classname:
            element = try_find_element(AppiumBy.CLASS_NAME, element_classname, "Class Name") or try_find_element_direct(
                AppiumBy.CLASS_NAME, element_classname, "Class Name")

        # 5th attempt - ID
        if not element and element_id:
            element = try_find_element(AppiumBy.ID, element_id, "ID") or try_find_element_direct(AppiumBy.ID,
                                                                                                 element_id, "ID")

        # Final check if element was found
        if element:
            enable = element.is_enabled()
            displayed = element.is_displayed()
            element_info["enabled"] = enable
            element_info["displayed"] = displayed
            element_info["text"] = element.text
            print(f"{note}: ✅Element found using {element_info['method']} - Locator: {element_info['locator']}")

            if enable and displayed:
                if clear_field == True:
                    element.clear()

                if is_element_input_field is not None:
                    # element.click()
                    element.clear()
                    element.send_keys(input_field_value)
                    print(f"{note}: ✅ Text '{input_field_value}' entered successfully")

                if element_click:
                    WebDriverWait(main_driver, 15).until(lambda d: element.is_enabled())
                    if element.is_enabled():
                        if one_more_click:
                            element.click()
                            element.click()
                        else:
                            element.click()
                        print(f"{note}: ✅ Clicked successfully")
                    else:
                        print(f"{note}: ❌Element is not enabled to perform click action")
                return element_info
            else:
                return element_info
        else:
            print(f"{note}:❌ Element not found using any locator")
            return {"method": None, "locator": None, "enabled": None, "displayed": None}

    @staticmethod
    def is_test_present(driver, expected_text, element_xpath=None, element_uiautomatorpath=None,
                        element_accessibility_id=None, element_classname=None, element_id=None,
                        maxtime=30, note=""):

        locators = [
            (AppiumBy.XPATH, element_xpath, "XPath"),
            (AppiumBy.ANDROID_UIAUTOMATOR, element_uiautomatorpath, "UIAutomator"),
            (AppiumBy.ACCESSIBILITY_ID, element_accessibility_id, "Accessibility ID"),
            (AppiumBy.CLASS_NAME, element_classname, "Class Name"),
            (AppiumBy.ID, element_id, "ID")
        ]

        for by, locator, method_name in locators:
            if locator:
                try:
                    element = WebDriverWait(driver, maxtime).until(
                        EC.presence_of_element_located((by, locator))
                    )
                    if element:
                        element_text = element.text if element.text else ""
                        if expected_text == element_text:
                            print(f"{note}: ✅ Text '{expected_text}' found using {method_name}.")
                            return {
                                "enabled": element.is_enabled(),
                                "displayed": element.is_displayed(),
                                "actualtext": element_text,
                                "status": "Found✅"
                            }
                        else:
                            print(f"{note}: ❌ Text '{expected_text}' not found in element using {method_name}.")
                            return {
                                "enabled": element.is_enabled(),
                                "displayed": element.is_displayed(),
                                "actualtext": element_text,
                                "status": f"Found but text is wrong, got {element_text}"
                            }
                    else:
                        print(f"{note}: ❌ element not found in element using {method_name}.")

                except Exception as e:
                    print(f"{note}: ❌ Exception while searching with {method_name}: {e}")
                    continue

        print(f"{note}: ❌ Text '{expected_text}' not found using any method.")
        return {"enabled": None, "displayed": None, "actualtext": None, "status": None}

    @staticmethod
    def element_state(driver, element_xpath=None, element_uiautomator=None,
                      element_id=None, element_classname=None,
                      element_accessibility_id=None, note=None, timeout=30):
        """
        Find an element using multiple locator strategies and report its attributes.

        :param driver: The Appium WebDriver instance.
        :param element_xpath: The XPath of the element.
        :param element_uiautomator: The UIAutomator selector.
        :param element_id: The resource ID of the element.
        :param element_classname: The class name of the element.
        :param element_accessibility_id: The accessibility ID of the element.
        :param note: A note to identify the element in logs.
        :param timeout: Maximum wait time for the element.
        :return: Dictionary with element status and attributes.
        """

        locators = {
            "XPath": (AppiumBy.XPATH, element_xpath),
            "UIAutomator": (AppiumBy.ANDROID_UIAUTOMATOR, element_uiautomator),
            "ID": (AppiumBy.ID, element_id),
            "ClassName": (AppiumBy.CLASS_NAME, element_classname),
            "AccessibilityID": (AppiumBy.ACCESSIBILITY_ID, element_accessibility_id)
        }

        found_element = None
        found_by = None

        for method, locator in locators.items():
            if locator[1]:  # Check if locator is provided
                try:
                    # Try WebDriverWait
                    found_element = WebDriverWait(driver, timeout).until(
                        EC.presence_of_element_located(locator)
                    )
                    found_by = method
                    print(f"✅{note}: Element found using {method} with WebDriverWait")
                    break  # Exit loop once element is found
                except TimeoutException:
                    print(f"❌{note}: Timeout - Element not found using {method} with WebDriverWait")
                finally:
                    pass

                try:
                    # Try direct find_element
                    found_element = driver.find_element(*locator)
                    found_by = method
                    print(f"✅{note}: Element found using {method} with find_element")
                    break
                except NoSuchElementException:
                    print(f"❌{note}: NoSuchElementException - Element not found using {method} with find_element")
                finally:
                    pass

        if found_element:
            enabled = found_element.is_enabled()
            displayed = found_element.is_displayed()
            clickable = EC.element_to_be_clickable((found_by, found_element)) if found_by else False
            text = found_element.text
            return {
                "where": note,
                "found_by": found_by,
                "enabled": enabled,
                "displayed": displayed,
                "clickable": clickable,
                "actualtext": text,
                "status": "Found✅"

            }
        else:
            return {
                "found_by": None,
                "enabled": False,
                "displayed": False,
                "clickable": False,
                "actualtext": None,
                "status": "Not Found ❌"
            }
        # example usage
        # element_status = element_state(
        # driver,
        # element_xpath="//android.widget.Button[@text='Submit']",
        # element_uiautomator='new UiSelector().text("Submit")',
        # element_id="com.example:id/submitButton",
        # element_classname="android.widget.Button",
        # element_accessibility_id="submitButton",
        # note="Submit Button")

        # print(f"Element Found By: {element_status['found_by']}")
        # print(f"Enabled: {element_status['enabled']}")
        # print(f"Displayed: {element_status['displayed']}")
        # print(f"Clickable: {element_status['clickable']}")
        # print(f"Status: {element_status['status']}")
        # print(f'actualtext:{element_status['actualtext']}')

    @staticmethod
    def input_field_clear(main_driver, element_xpath=None, element_uiautomatorpath=None,
                          element_accedbilityID=None, element_classname=None, element_id=None, note=None, maxtime=20):

        element = None

        def try_find_element(locator_type, locator_value):
            try:
                return WebDriverWait(main_driver, maxtime).until(
                    EC.presence_of_element_located((locator_type, locator_value))
                )
            except Exception as ex:
                print(f"{note}:❌ Failed to find element using {locator_type} ({locator_value}) - Exception: {ex}")
                print('---------------------------' * 10)
                return None
            finally:
                pass

        def try_find_element_direct(locator_type, locator_value):
            try:
                return main_driver.find_element(locator_type, locator_value)
            except Exception as ex:
                print(f"{note}:❌ Direct find failed using {locator_type} ({locator_value}) - Exception: {ex}")
                print('---------------------------' * 10)
                return None
            finally:
                pass

        # 1st attempt - XPath (WebDriverWait)
        if element_xpath:
            element = try_find_element(AppiumBy.XPATH, element_xpath) or try_find_element_direct(AppiumBy.XPATH,
                                                                                                 element_xpath)

        # 2nd attempt - UIAutomator (WebDriverWait)
        if not element and element_uiautomatorpath:
            element = try_find_element(AppiumBy.ANDROID_UIAUTOMATOR,
                                       element_uiautomatorpath) or try_find_element_direct(AppiumBy.ANDROID_UIAUTOMATOR,
                                                                                           element_uiautomatorpath)

        # 3rd attempt - Accessibility ID
        if not element and element_accedbilityID:
            element = try_find_element(AppiumBy.ACCESSIBILITY_ID, element_accedbilityID) or try_find_element_direct(
                AppiumBy.ACCESSIBILITY_ID, element_accedbilityID)

        # 4th attempt - Class Name
        if not element and element_classname:
            element = try_find_element(AppiumBy.CLASS_NAME, element_classname) or try_find_element_direct(
                AppiumBy.CLASS_NAME, element_classname)

        # 5th attempt - ID
        if not element and element_id:
            element = try_find_element(AppiumBy.ID, element_id) or try_find_element_direct(AppiumBy.ID, element_id)

        # Final check if element was found
        if element:
            enable = element.is_enabled()
            displayed = element.is_displayed()
            print(f"{note}: ✅Element is enabled: {enable}, displayed: {displayed}")

            if enable and displayed:
                element.click()
                element.clear()  # Clear existing text before entering new text
        else:
            print(f"{note}:❌ Element not found using any locator")

    import allure

    @allure.severity(allure.severity_level.MINOR)  # Change severity level if needed
    def test_check_text_element_allure(
            driver, step_name, expected_text=None, element_xpath=None,
            element_uiautomatorpath=None, element_accessibility_id=None,
            element_classname=None, element_id=None, is_test_present=None,
            element_state=None, button_should_be_enabled=True,
            should_be_displayed=True, max_time=10
    ):
        """
        Function to check the presence and state of an element on the mobile screen.
        """

        def attach_screenshot(name):
            """Helper function to attach a screenshot."""
            allure.attach(driver.get_screenshot_as_png(), name=name, attachment_type=allure.attachment_type.PNG)

        with allure.step(f"Check {step_name}"):
            # Check element presence
            if is_test_present:
                element_response = Testing().is_test_present(
                    driver, expected_text=expected_text, element_xpath=element_xpath,
                    element_uiautomatorpath=element_uiautomatorpath,
                    element_accessibility_id=element_accessibility_id,
                    element_classname=element_classname, element_id=element_id,
                    maxtime=max_time, note=step_name
                )
                try:
                    allure.dynamic.severity(allure.severity_level.CRITICAL)
                    assert element_response['displayed'] == should_be_displayed, \
                        f"Failed step {step_name} - Expected display status {should_be_displayed}, but got {element_response['displayed']}"
                    attach_screenshot("Mobile Input Field")

                except Exception as e:
                    attach_screenshot("Failure Screenshot - Mobile Input Field")
                    with allure.step(f"❌ Step FAILED: Mobile Input Field - {str(e)}"):
                        pass

            elif element_state:
                element_response = Testing().element_state(
                    driver, element_xpath=element_xpath,
                    element_uiautomator=element_uiautomatorpath,
                    element_accessibility_id=element_accessibility_id,
                    element_classname=element_classname, element_id=element_id,
                    note=step_name
                )
                try:
                    assert element_response['displayed'] == should_be_displayed, \
                        f"Failed step {step_name} - Expected display status {should_be_displayed}, but got {element_response['displayed']}"
                    attach_screenshot("Mobile Input Field")
                except Exception as e:
                    attach_screenshot("Failure Screenshot - Mobile Input Field")
                    with allure.step(f"❌ Step FAILED: Mobile Input Field - {str(e)}"):
                        pass

                try:
                    assert element_response['enabled'] == button_should_be_enabled, \
                        f"Failed step {step_name} - Expected enabled status {button_should_be_enabled}, but got {element_response['enabled']}"
                    attach_screenshot("Mobile Input Field")
                except Exception as e:
                    attach_screenshot("Failure Screenshot - Mobile Input Field")
                    with allure.step(f"❌ Step FAILED: Mobile Input Field - {str(e)}"):
                        pass


