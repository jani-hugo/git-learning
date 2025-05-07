from behave import given, then, use_step_matcher
from appium.webdriver.common.appiumby import AppiumBy
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.action_chains import ActionChains
from selenium.common.exceptions import NoSuchElementException

from features.steps.data_class_parser import DataClassParser
from pages.payee_locators import PayeeLocators
from pages.home_screen_locators import HomeScreen
from pages.utils import Testing

from typing import Optional
import dataclasses
import re
import time

# Set step matcher once
use_step_matcher("re")


def is_valid_account_number(account_number):
    if not account_number:  # Handles None and empty strings
        return False
    return bool(re.fullmatch(r"^\d+$", account_number))

def is_valid_payee_name(name):
    if not name:  # Handles None and empty strings
        return False
    return bool(re.fullmatch(r"^[A-Za-z]+(?: [A-Za-z]+)*$", name))

def format_amount(amount):
    return "{:.2f}".format(float(amount))

# --------------------------------------------------------------------------------------------------------------------------------------
# cash account dashboard

@given(r'I verify that My QR code pop-up is displayed')
def step_cash_account(context):
    time.sleep(3)

    wait = WebDriverWait(context.driver, 20)
    next_button = wait.until(EC.presence_of_element_located((AppiumBy.ANDROID_UIAUTOMATOR,'new UiSelector().text("Next")')))
    assert next_button.is_displayed(), f'next_button was not displayed'; next_button.click()

    done_button = wait.until(EC.presence_of_element_located((AppiumBy.ANDROID_UIAUTOMATOR, 'new UiSelector().text("Done")')))
    assert done_button.is_displayed(), f'done_button was not displayed'; done_button.click()


@given(r'I verify that i have reached the Cash account dashboard')
def step_cash_account(context):
    wait = WebDriverWait(context.driver, 30)
    cash_account_text = wait.until(EC.presence_of_element_located(HomeScreen.CASH_ACCOUNT_TITLE))
    assert cash_account_text.is_displayed(), f'CASH ACCOUNT TEXT is not displayed';


@given(r'I check the text elements "Screen Title, User Name, Bank Name, Account Number, Balance as 0, "Add Money" text, "Send Money to Payee" text, and "Add Payee" text" on the Cash Account Dashboard screen')
def step_check_text_elements(context):
    wait = WebDriverWait(context.driver, 30)
    casual_name = context.user_details["casual_name"]
    legal_name = context.user_details["legal_name"]
    user_name = casual_name
    if casual_name is None:
        user_name = legal_name

    cash_account_title_text = wait.until(EC.presence_of_element_located(HomeScreen.CASH_ACCOUNT_TITLE))
    assert cash_account_title_text.is_displayed(), f'CASH ACCOUNT TEXT is not displayed';


    user_name_text = wait.until(EC.presence_of_element_located((AppiumBy.ANDROID_UIAUTOMATOR, f'new UiSelector().text("{user_name}")')))
    assert user_name_text.is_displayed() and user_name_text.text==user_name, f'user_name_text was not displayed';

    dbs_bank_name_text = wait.until(EC.presence_of_element_located(HomeScreen.DBS_BANK_NAME))
    assert dbs_bank_name_text.is_displayed(), f'DBS BANK NAME was not displayed';

    account_number = wait.until(EC.presence_of_element_located(HomeScreen.ACCOUNT_NUMBER))
    assert account_number.is_displayed() and account_number.text is not None, f'account number was not displayed';

    balance_as_0 = wait.until(EC.presence_of_element_located(HomeScreen.BALANCE_AS_0))
    assert balance_as_0.is_displayed() and balance_as_0.text == '00.00', f'bank balance as 0 was not displayed';

    add_money_text =  wait.until(EC.presence_of_element_located(HomeScreen.ADD_MONEY_TEXT))
    assert add_money_text.is_displayed(), f'add money text was not displayed';

    send_money_to_payee_text =  wait.until(EC.presence_of_element_located(HomeScreen.SEND_MONEY_TO_PAYEE_TEXT))
    assert send_money_to_payee_text.is_displayed(), f'send money to payee text was not displayed';

    add_payee_text = wait.until(EC.presence_of_element_located(HomeScreen.ADD_PAYEE_TEXT))
    assert add_payee_text.is_displayed(), f'add payee text was not displayed';

    learn_more_link = wait.until(EC.presence_of_element_located(HomeScreen.LEARN_MORE_LINK_))
    assert add_payee_text.is_displayed(), f'learn more link was not displayed';

    book_icon = Testing.all_path_find_element(context.driver,
                                                  element_xpath='//android.widget.ScrollView[@resource-id="cashScrollView"]/android.view.ViewGroup/android.view.ViewGroup[1]/android.view.ViewGroup[1]/android.view.ViewGroup/android.view.ViewGroup/android.view.ViewGroup/com.horcrux.svg.SvgView/com.horcrux.svg.GroupView/com.horcrux.svg.PathView',
                                                  element_ui_automator_path='new UiSelector().className("com.horcrux.svg.PathView").instance(0)',
                                                  note="checking book icon on the cash account dashboard")

    assert book_icon["displayed"], "book icon not displayed"



@given(r'I check the text elements "Upcoming money scheduled to leave cash account," "Next 7 days," and "Next 30 days" on the upcoming schedule card on the Cash Account Dashboard screen')
def step_check_schedule_card(context):
    upcoming_schedule_card = Testing().is_test_present(context.driver, expected_text='Upcoming money scheduled to leave Cash Account',
                                                           element_xpath='//android.widget.TextView[@resource-id="upcomingScheduleText"]',
                                                           element_uiautomatorpath='new UiSelector().resourceId("upcomingScheduleText")',
                                                           element_id='upcomingScheduleText', maxtime=30, note="checking Upcoming money scheduled to leave Cash Account text  on the cash account dashboard")

    next_days7 = Testing().is_test_present(context.driver, expected_text='Next 7 days',
                                               element_uiautomatorpath='new UiSelector().resourceId("next7daysText")',
                                               element_xpath='//android.widget.TextView[@resource-id="next7daysText"]',
                                               element_id='next7daysText',
                                               maxtime=30,
                                               note="checking Next 7 days text on the cash account learning screen")

    next_days30 = Testing().is_test_present(context.driver, expected_text='Next 30 days',
                                                element_uiautomatorpath='new UiSelector().resourceId("next30daysText")',
                                                element_xpath='//android.widget.TextView[@resource-id="next30daysText"]',
                                                element_id='next30daysText',
                                                maxtime=30,
                                                note="checking Next 30 days text on the cash account learning screen")

    assert upcoming_schedule_card["displayed"], "Upcoming money schedule text not displayed"
    assert next_days7["displayed"], "Next 7 days text not displayed"
    assert next_days30["displayed"], "Next 30 days text not displayed"

@given(r'I check the buttons/icons Add Money icon, Add Payee button, and View Details text link on the Cash Account Dashboard screen')
def step_check_buttons(context):
    add_money_icon = Testing.all_path_find_element(context.driver, element_xpath='//android.view.ViewGroup[@resource-id="openAddMoneyInfoPage"]',
                                                       element_ui_automator_path='new UiSelector().resourceId("openAddMoneyInfoPage")',
                                                       element_id='openAddMoneyInfoPage',
                                                       note="checking add money button  on the cash account dashboard")

    add_payee_icon = Testing.all_path_find_element(context.driver,
                                                       element_xpath='//android.view.ViewGroup[@resource-id="addPayeeButton"]',
                                                       element_ui_automator_path='new UiSelector().resourceId("addPayeeButton")',
                                                       element_id='addPayeeButton',
                                                       note="checking add payee button on the cash account dashboard")

    view_details_link = Testing.all_path_find_element(context.driver,
                                                          element_xpath='//android.widget.TextView[@text="View Details"]',
                                                          element_ui_automator_path='new UiSelector().text("View Details")',
                                                          note="checking view details link on the cash account dashboard")


    assert add_money_icon["displayed"], "add money icon not displayed"
    assert add_payee_icon["displayed"], "add payee icon not displayed"
    assert view_details_link["displayed"], "view details link not displayed"


@given(r'I scroll down the Cash Account Dashboard screen')
def step_scroll_down(context):
    no_transactions_text = context.driver.find_element(AppiumBy.ANDROID_UIAUTOMATOR,
                                              'new UiScrollable(new UiSelector().scrollable(true)).scrollIntoView(new UiSelector().resourceId("notransactionsText"))')

    assert no_transactions_text.is_displayed(), "Scrolling failed, no transactions text element not found"

@given(r'I check the "Transactions" text and "No transactions yet!" message on the Cash account dashboard')
def step_check_transactions_text(context):
    transactions_text = Testing().is_test_present(context.driver,
                                                      expected_text='Transactions',
                                                      element_xpath='//android.widget.TextView[@resource-id="transactionsText"]',
                                                      element_uiautomatorpath='new UiSelector().resourceId("transactionsText")',
                                                      element_id='transactionsText', maxtime=30,
                                                      note="checking Transactions text on the cash account dashboard")

    no_transactions_yet_text = Testing().is_test_present(context.driver, expected_text='No transactions yet!',
                                                             element_uiautomatorpath='new UiSelector().resourceId("notransactionsText")',
                                                             element_xpath='//android.widget.TextView[@resource-id="notransactionsText"]',
                                                             element_id='notransactionsText',
                                                             maxtime=30,
                                                             note="checking No transactions yet! on the cash account learning screen")

    assert transactions_text["displayed"], "Transactions text not displayed"
    assert no_transactions_yet_text["displayed"], "No Transactions Yet text not displayed"


@given(r'I scroll up the Cash Account Dashboard screen')
def step_scroll_up(context):
    up = context.driver.find_element(AppiumBy.ANDROID_UIAUTOMATOR,
                            'new UiScrollable(new UiSelector().scrollable(true)).setAsVerticalList().scrollBackward().scrollIntoView(new UiSelector().resourceId("bank"))')
    assert up.is_displayed(), f'{up} DBS bank is not displayed'

@then(r'I tap on the back button on the cash account dashboard')
def step_tap_back(context):
    back_button = Testing.all_path_find_element(context.driver,
                                                    element_xpath='//android.view.ViewGroup[@resource-id="backButton"]/android.view.ViewGroup/com.horcrux.svg.SvgView/com.horcrux.svg.GroupView/com.horcrux.svg.PathView',
                                                    element_ui_automator_path='new UiSelector().className("com.horcrux.svg.PathView").instance(12)',
                                                    element_click=True,
                                                    note="clicking on the back button on the cash account dashboard")


@then(r"I scroll up the Cash Account Dashboard screen")
def step_scroll_up(context):
    driver = context.driver
    size = driver.get_window_size()
    width = size["width"]
    height = size["height"]
    start_x = width // 2
    start_y = height // 2
    end_y = start_y - (height // 10)  # scroll up just a little

    driver.swipe(start_x, start_y, start_x, end_y, 1300)  # shorter duration for a smaller swipe


@then(r"I tap on the Add Payee button on the ([^']*)")
def step_tap_add_payee(context,screen_name):

    wait = WebDriverWait(context.driver, 30)
    add_payee_button = wait.until(EC.presence_of_element_located(PayeeLocators.ADD_PAYEE_BUTTON))
    assert add_payee_button.is_enabled(), f'Add payee button not displayed';
    add_payee_button.click()

# --------------------------------------------------------------------------------------------------------------------------------------
# cash account learning screen

@given(r'I tap on the Cash account banner on the home screen')
def step_tap_cash_account_banner(context):
    wait = WebDriverWait(context.driver, 40)
    cash_account_text = wait.until(EC.presence_of_element_located(HomeScreen.CASH_ACCOUNT_TEXT))
    assert cash_account_text.is_displayed(), f'CASH ACCOUNT TEXT is not displayed'; cash_account_text.click(); cash_account_text.click()



@given(r'I verify that i reached the Cash Account learning screen')
def step_check_learning_screen(context):
    wait = WebDriverWait(context.driver, 30)
    cash_account_title = wait.until(EC.presence_of_element_located(HomeScreen.CASH_ACCOUNT_TEXT))
    assert cash_account_title.is_displayed(), f'CASH ACCOUNT TITLE is not displayed on the cash account learning screen'



@given(r'I scroll down the Cash Account learning screen')
def step_scroll_down_cash_account_learning_screen(context):
    # Perform scrolling action until element found downwards

    faq_element = context.driver.find_element(AppiumBy.ANDROID_UIAUTOMATOR,
                                'new UiScrollable(new UiSelector().scrollable(true)).scrollIntoView(new UiSelector().text("Cash Account FAQs"))')

    assert faq_element.is_displayed(), "Scrolling failed, element not found"



@given(r'I check the "How to" videos section, Cash Account FAQs button, and "See All >" link')
def step_check_how_to_videos_section(context):
    wait = WebDriverWait(context.driver, 30)

    how_to_videos = wait.until(EC.presence_of_element_located(HomeScreen.HOW_TO_VIDEOS))
    assert how_to_videos.is_displayed(), f'how to videos is not displayed';

    cash_account_faqs = wait.until(EC.presence_of_element_located(HomeScreen.CASH_ACCOUNT_FAQ_BUTTON))
    assert cash_account_faqs.is_displayed(), f'cash account faqs is not displayed';

    see_all_link = wait.until(EC.presence_of_element_located(HomeScreen.SEE_ALL_LINK))
    assert see_all_link.is_displayed(), f'see all link  is not displayed';



@given(r'I verify the Cash Account Dashboard button and the back button on the Cash Account learning screen')
def step_verify_cash_account_dashboard_button(context):
    wait = WebDriverWait(context.driver, 30)
    back_button = Testing().element_state(context.driver,
                                              element_xpath='//android.view.ViewGroup[@resource-id="backButton"]/android.view.ViewGroup/com.horcrux.svg.SvgView/com.horcrux.svg.GroupView/com.horcrux.svg.PathView',
                                              element_uiautomator='new UiSelector().className("com.horcrux.svg.PathView").instance(10)',
                                              note="checking back arrow on the cash account learning screen")

    cash_account_dashboard = wait.until(EC.presence_of_element_located(HomeScreen.CASH_ACCOUNT_DASHBOARD_BUTTON))
    assert cash_account_dashboard.is_displayed(), f'CASH ACCOUNT DASHBOARD BUTTON is not displayed'

    if not back_button["enabled"]:
        assert False, "back button is not displayed"



@then(r'I tap on the Cash Account Dashboard button')
def step_tap_cash_account_dashboard_button(context):

    cash_account_dashboard = WebDriverWait(context.driver, 30).until(EC.presence_of_element_located(HomeScreen.CASH_ACCOUNT_DASHBOARD_BUTTON))
    assert cash_account_dashboard.is_displayed(), f'CASH ACCOUNT DASHBOARD BUTTON is not displayed'
    assert cash_account_dashboard.is_enabled(), f'CASH ACCOUNT DASHBOARD BUTTON is not enabled'
    cash_account_dashboard.click()


@then(r'I tap on the back button to navigate away from the Cash Account learning screen')
def step_tap_back_button(context):
    try:
        try:
            back_button = context.driver.find_element(AppiumBy.ANDROID_UIAUTOMATOR,
                                                      'new UiSelector().className("com.horcrux.svg.PathView").instance(16)'
                                                      )
            back_button.click()
            print("✅ Back button clicked using UiAutomator.")
            time.sleep(5)
            return
        except NoSuchElementException:
            print("⚠️ UiAutomator back button not found.")

        # If still not working, use the native Android back button
        context.driver.back()
        print("✅ Used Android system back button as fallback.")

    except Exception as e:
        print(f"❌ Error while tapping back button: {e}")

# -----------------------------------------------------------------------------------------------------------------------------------
# add_new_payee

@dataclasses.dataclass
class PayeeDetails:
   payee_name: Optional[str]
   bank_name:Optional[str]
   account_no:Optional[str]

def int_or_ext_payee(bank_name, driver):
    if bank_name is not None and bank_name != 'DBS Bank Ltd':
        try:
            # Check if Trust Bank is already visible
            bnp_bank_list = driver.find_elements(AppiumBy.ANDROID_UIAUTOMATOR,
                                                   'new UiSelector().resourceId("undefined3")')

            if bnp_bank_list:
                bnp_bank_list[0].click()
            else:
                # Scroll only if the element isn't found initially
                bnp_bank = driver.find_element(
                    AppiumBy.ANDROID_UIAUTOMATOR,
                    'new UiScrollable(new UiSelector().scrollable(true)).scrollIntoView(new UiSelector().resourceId("undefined3"))'
                )
                bnp_bank.click()

        except Exception as e:
            print(f"Error clicking trust bank: {e}")

    elif bank_name == 'DBS Bank Ltd':
        try:
            # Check if DBS Bank is already visible
            dbs_bank_list = driver.find_elements(AppiumBy.ANDROID_UIAUTOMATOR,
                                                 'new UiSelector().resourceId("undefined32")')

            if dbs_bank_list:
                dbs_bank_list[0].click()
            else:
                # Scroll only if the element isn't found initially
                dbs_bank = driver.find_element(
                    AppiumBy.ANDROID_UIAUTOMATOR,
                    'new UiScrollable(new UiSelector().scrollable(true)).scrollIntoView(new UiSelector().resourceId("undefined32"))'
                )
                dbs_bank.click()

        except Exception as e:
            print(f"Error clicking dbs bank: {e}")

    else:
        print("Invalid bank name entered. Please provide a valid bank name.")
        assert False


@given(r"I wait for ([^']*) seconds")
def step_reached_add_new_payee_screen(context,seconds):
    print('waiting ',seconds, 'seconds')
    time.sleep(int(seconds))


@given(r'I verify that i reached the Add New Payee Screen')
def step_reached_add_new_payee_screen(context):
    wait = WebDriverWait(context.driver, 30)
    add_new_payee_text = wait.until(EC.presence_of_element_located(PayeeLocators.ADD_NEW_PAYEE_TEXT))
    assert add_new_payee_text.is_displayed(), f'add new payee text was not displayed';


@then(r'I check all the text elements on the Add New Payee screen')
def step_check_all_text_elements(context):
    wait = WebDriverWait(context.driver, 20)

    favourite_text = wait.until(EC.presence_of_element_located(PayeeLocators.FAVOURITE_TEXT))
    assert favourite_text.is_displayed(), f'favourite text was not displayed';

    payee_name_text = wait.until(EC.presence_of_element_located(PayeeLocators.PAYEE_TEXT))
    assert payee_name_text.is_displayed(), f'payee name text was not displayed';

    as_on_their_bank_account_text = wait.until(EC.presence_of_element_located(PayeeLocators.AS_ON_THEIR_BANK_TEXT))
    assert as_on_their_bank_account_text.is_displayed(), f'as_on_their_bank_account_text was not displayed';

    bank_name_text = wait.until(EC.presence_of_element_located(PayeeLocators.BANK_NAME_TEXT))
    assert bank_name_text.is_displayed(), f'Bank name_text was not displayed'

    account_no_text = wait.until(EC.presence_of_element_located(PayeeLocators.ACCOUNT_NUMBER_TEXT))
    assert account_no_text.is_displayed(), f'Account number text was not displayed'

    confirm_button = wait.until(EC.presence_of_element_located(PayeeLocators.CONFIRM_BUTTON))
    assert confirm_button.is_displayed(), f'Confirm button was not displayed'


# --------------------------------------------------------------------------------------------------------------------------------
@given(r'I enter Payee Name, Select Bank and Account Number')
def step_enter_payee_details(context):
    driver = context.driver
    wait = WebDriverWait(driver, 20)
    if not hasattr(context, 'co_ordinates'):
        context.co_ordinates = {}

    test_object_list = DataClassParser.parse_rows(context.table.rows, data_class= PayeeDetails)
    for object in test_object_list:
        payee_name = object.payee_name
        bank_name = object.bank_name
        account_no = object.account_no

        if not hasattr(context, 'payee_details'):
            context.payee_details = {}  # Initialize the dictionary

        # enter payee_name:
        if payee_name:
            payee_name_field = wait.until(EC.presence_of_element_located(PayeeLocators.PAYEE_NAME_INPUT_FIELD))
            assert payee_name_field.is_displayed(), f'payee name field was not displayed'
            payee_name_field.clear()
            payee_name_field.send_keys(payee_name)

            context.payee_details[payee_name] = {"payee_name": payee_name}

        else:
            payee_name = 'None'
            context.payee_details["None"] = {"payee_name": None}

        # select bank_name:
        if bank_name:
            # Perform the touch action at the coordinates
            bank = WebDriverWait(driver, 15).until(
                EC.presence_of_element_located((AppiumBy.XPATH, '//android.widget.TextView[@text="Bank Name"]')))
            if bank:
                bank.click()
                time.sleep(2)
                int_or_ext_payee(bank_name, driver)

            context.payee_details[payee_name]["bank_name"] = bank_name

        else:
            context.payee_details[payee_name]["bank_name"] = None


        # enter account_no:
        if account_no:
            Testing.close_keyboard_if_shown(driver)
            account_no_field = wait.until(EC.presence_of_element_located(PayeeLocators.ACCOUNT_NUMBER_FIELD))
            assert account_no_field.is_displayed(), f'payee name field was not displayed'
            account_no_field.clear(); account_no_field.send_keys(account_no)

            context.payee_details[payee_name]["account_no"] = account_no
            context.payee_details[payee_name]["reason_chip"] = None
        else:
            context.payee_details[payee_name]["account_no"] = None
            context.payee_details[payee_name]["reason_chip"] = None

@then(r"I verify the payee ([^']*) details and validate error messages for invalid inputs")
def step_enter_user_details(context,name):
    driver = context.driver
    Testing.close_keyboard_if_shown(driver)
    if name=='None':
        payee_name = None
    else:
        payee_name = context.payee_details[name]["payee_name"]

    is_valid_name_payee = is_valid_payee_name(payee_name)

    if is_valid_name_payee:
        assert True
    else:
        if not is_valid_name_payee:
            if payee_name:
                payee_name_error = driver.find_elements(AppiumBy.XPATH,
                                                        '//android.widget.TextView[@resource-id="payeeNameErrorText"]')
                assert payee_name_error, f"Expected payee name error message but not found"

@then(r"I verify the confirm button is ([^']*)")
def step_confirm_button_status(context,enabled_or_disabled ):
    wait = WebDriverWait(context.driver, 30)

    confirm_button = wait.until(EC.presence_of_element_located(PayeeLocators.CONFIRM_BUTTON))
    assert confirm_button.is_displayed(), f'Confirm button was not displayed'

    if enabled_or_disabled == "enabled":
         assert confirm_button.is_enabled(); f"Expected confirm button state to be enabled but got {confirm_button.is_enabled()}"
    elif enabled_or_disabled == "disabled":
        assert not confirm_button.is_enabled(); f"Expected confirm button state to be disabled but got {confirm_button.is_enabled()}"
    else:
        print("Invalid input, required 'enabled/disabled'")

@then('I tap on the back button on the Add New Payee screen')
def step_tap_back(context):
    Testing.all_path_find_element(context.driver,
                                                    element_xpath='//android.view.ViewGroup[@resource-id="backButton"]/android.view.ViewGroup/com.horcrux.svg.SvgView/com.horcrux.svg.GroupView/com.horcrux.svg.PathView',
                                                    element_ui_automator_path='new UiSelector().className("com.horcrux.svg.PathView").instance(4)',
                                                    element_click=True,
                                                    note="clicking on the back button on the Add New Payee screen")



@then(r"I clear the payee input fields")
def step_clear_fields(context):
    wait = WebDriverWait(context.driver, 20)

    payee_name_field = wait.until(EC.presence_of_element_located(PayeeLocators.PAYEE_NAME_INPUT_FIELD))
    assert payee_name_field.is_displayed(), f'payee name field was not displayed'; payee_name_field.clear()

    account_no_field = wait.until(EC.presence_of_element_located(PayeeLocators.ACCOUNT_NUMBER_FIELD))
    assert account_no_field.is_displayed(), f'account number field was not displayed'; account_no_field.clear()


@then(r'I click on the confirm button')
def step_click_continue_button(context):
    wait = WebDriverWait(context.driver, 20)
    Testing.close_keyboard_if_shown(context.driver)

    confirm_button = wait.until(EC.presence_of_element_located(PayeeLocators.CONFIRM_BUTTON))
    assert confirm_button.is_displayed() and confirm_button.is_enabled(), f'Confirm button was not displayed/enabled'
    confirm_button.click()


@then(r'I verify that i reached the OTP Screen')
def step_payee_otp_screen(context):
    wait = WebDriverWait(context.driver, 20)
    otp_text = wait.until(EC.presence_of_element_located(PayeeLocators.OTP_SCREEN_TEXT))
    assert otp_text.is_displayed(), f'otp text was not displayed'


@then(r"I enter the OTP ([^']*) to add payee")
def step_enter_otp(context, otp):
    otp_number = list(otp)
    actions = ActionChains(context.driver)
    for i in otp_number:  # Python range is exclusive of the end value.
        actions.send_keys(str(i)).perform()
    time.sleep(2)


@then(r'I check for then error message for incorrect OTP while adding payee')
def step_check_for_error_message_for_incorrect_otp(context):
    wait = WebDriverWait(context.driver, 20)
    otp_text = wait.until(EC.presence_of_element_located(PayeeLocators.INCORRECT_OTP_TEXT))
    assert otp_text.is_displayed(), f'otp text was not displayed'


@then(r"I wait for the 15-second timer to reach 0 and verify the presence of the Resend OTP button")
def step_verify_resend_button(context):
    wait = WebDriverWait(context.driver, 20)
    time.sleep(10)
    Testing.close_keyboard_if_shown(context.driver)
    resend_otp_button = wait.until(EC.presence_of_element_located(PayeeLocators.RESEND_OTP_BUTTON))
    assert resend_otp_button.is_displayed(), f'resend otp button was not displayed';

@then('I tap on the back button on the Payee OTP screen')
def step_tap_back(context):
    Testing.all_path_find_element(context.driver,
                                                    element_xpath='//android.view.ViewGroup[@resource-id="backButton"]/android.view.ViewGroup/com.horcrux.svg.SvgView/com.horcrux.svg.GroupView/com.horcrux.svg.PathView',
                                                    element_ui_automator_path='new UiSelector().className("com.horcrux.svg.PathView").instance(0)',
                                                    element_click=True,
                                                    note="clicking on the back button on the Payee OTP screen")



@then(r"I verify the payee's addition by checking the payee ([^']*) account number on the auto-directed individual screen after OTP entry")
def step_verify_payee_individual_screen(context, name):
    time.sleep(3)
    print('123')
    wait = WebDriverWait(context.driver, 20)
    payee_account_no = wait.until(EC.presence_of_element_located(PayeeLocators.PAYEE_ACCOUNT_NUMBER_ON_PAYEE_SCREEN))
    assert payee_account_no.is_displayed(), f'payee account number was not displayed';
    assert payee_account_no.text==context.payee_details[name]["account_no"],f'{payee_account_no.is_displayed()} payee account number not displayed'

    # payee_account_no = (Testing().is_test_present(driver, expected_text=context.payee_details[name]["account_no"],
    #                                                         element_xpath='//android.widget.TextView[@resource-id="payeeAccount"]',
    #                                                         element_uiautomatorpath='new UiSelector().resourceId("payeeAccount")',
    #                                                         element_id='payeeAccount',
    #                                                         maxtime=30,
    #                                                         note="checking payee account number"))
    # assert payee_account_no['displayed']==True, f'{payee_account_no["displayed"]} payee account number not displayed'

@then(r"I check the text elements and buttons on the ([^']*) payee individual screen")
def step_payee_screen(context,name):
    print(context.payee_details[name]["bank_name"])
    wait = WebDriverWait(context.driver, 30)

    bank_name_text = wait.until(EC.presence_of_element_located((AppiumBy.XPATH,f'//android.widget.TextView[@text="{context.payee_details[name]["bank_name"]}"]')))
    assert bank_name_text.is_displayed(), f'bank name text was not displayed';
    assert bank_name_text.text==context.payee_details[name]["bank_name"], f'bank name text was not as expected'

    account_number = wait.until(EC.presence_of_element_located(PayeeLocators.PAYEE_ACCOUNT_NUMBER_ON_PAYEE_SCREEN))
    assert account_number.is_displayed(), f'payee account number was not displayed';
    assert account_number.text == context.payee_details[name]["account_no"], f'payee account number was not as expected'

    payee_name = wait.until(EC.presence_of_element_located(PayeeLocators.PAYEE_PAYEE_NAME_ON_PAYEE_SCREEN))
    assert payee_name.is_displayed(), f'payee account number was not displayed';
    assert payee_name.text == context.payee_details[name]["payee_name"], f'payee account number was not as expected'

    new_payment_button = wait.until(EC.presence_of_element_located(PayeeLocators.NEW_PAYMENT_BUTTON))
    assert new_payment_button.is_displayed(), f'new_payment_button was not displayed';


@then(r'I tap on the back button on the payee individual screen')
def step_tap_back(context):
   Testing.all_path_find_element(context.driver,
                                                    element_xpath='//com.horcrux.svg.PathView',
                                                    element_ui_automator_path='new UiSelector().className("com.horcrux.svg.PathView")',
                                                    element_id='com.horcrux.svg.PathView',
                                                    element_click=True,
                                                    note="clicking on the back button on the cash account dashboard")

@then(r"I check if the newly added payee ([^']*) is appearing on the ([^']*)")
def step_payee_name(context,name,screen_name):
    payee_name = WebDriverWait(context.driver, 20).until(
        EC.presence_of_element_located((AppiumBy.ANDROID_UIAUTOMATOR, f'new UiSelector().text("{context.payee_details[name]["payee_name"]}")')))
    if payee_name:
        print(payee_name.text)
        if payee_name.text == context.payee_details[name]["payee_name"]:
            assert True
    else:
       assert False


@then(r'I tap on the See All text link on the Cash account dashboard')
def step_see(context):
    payee_name = WebDriverWait(context.driver, 20).until(
        EC.presence_of_all_elements_located(
            (AppiumBy.ANDROID_UIAUTOMATOR, f'new UiSelector().text("See All")')))
    if payee_name:
        payee_name[0].click()
        payee_name[0].click()

@then(r'I verify that i reached the All Payees Screen')
def step_all_payees_screen(context):
    all_payees_text = WebDriverWait(context.driver, 20).until(EC.presence_of_element_located(PayeeLocators.ALL_PAYEES_TEXT))
    assert all_payees_text.is_displayed(), f'all payees text was not displayed';
    assert all_payees_text.text=='All Payees', f'all payees text was not as expected'



@then(r'I tap on the back button on the All Payees screen')
def step_tap_back(context):
    Testing.all_path_find_element(context.driver,
                                                    element_xpath='//android.view.ViewGroup[@resource-id="backButton"]/android.view.ViewGroup/com.horcrux.svg.SvgView/com.horcrux.svg.GroupView/com.horcrux.svg.PathView',
                                                    element_ui_automator_path='new UiSelector().className("com.horcrux.svg.PathView").instance(3)',
                                                    element_click=True,
                                                    note="clicking on the back button on the all paayes screen")

@then(r"I tap on the payee name ([^']*) on the ([^']*)")
def step_payee_name(context,name,screen_name):

    payee_name = WebDriverWait(context.driver, 20).until(
        EC.presence_of_element_located((AppiumBy.ANDROID_UIAUTOMATOR, f'new UiSelector().text("{context.payee_details[name]["payee_name"]}")')))

    assert payee_name.is_displayed(), f'payee name was not displayed'
    print(payee_name.text)
    assert payee_name.text == context.payee_details[name]["payee_name"]

    Testing.perform_touch_action(context.driver, Testing.tap_outside(context.driver,
                                                                         automator_path=f'new UiSelector().text("{context.payee_details[name]["payee_name"]}")')[
            0],
            Testing.tap_outside(context.driver,automator_path=f'new UiSelector().text("{context.payee_details[name]["payee_name"]}")')[
                                         1] - 80)



@then(r"I click on the payee name ([^']*) on the Payee individual screen")
def step_payee_name(context,name):
    payee_name = WebDriverWait(context.driver, 20).until(
        EC.presence_of_element_located((AppiumBy.ANDROID_UIAUTOMATOR, f'new UiSelector().resourceId("payeeName")')))
    assert payee_name.is_displayed(), f'payee name was not displayed'
    print(payee_name.text)
    if payee_name.text == context.payee_details[name]["payee_name"]:
        Testing.perform_touch_action(context.driver, Testing.tap_outside(context.driver,
                                                                         automator_path=f'new UiSelector().resourceId("payeeName")')[
            0],
                                     Testing.tap_outside(context.driver,
                                                         automator_path=f'new UiSelector().resourceId("payeeName")')[
                                         1])



@then(r"I check the payee details on the ([^']*) payee edit screen")
def step_payee_screen(context,name):
    print(context.payee_details[name]["bank_name"])
    bank_name = context.payee_details[name]["bank_name"]
    account_no = context.payee_details[name]["account_no"]
    payee_name = context.payee_details[name]["payee_name"]
    wait = WebDriverWait(context.driver, 20)


    bank_name_text = wait.until(
        EC.presence_of_element_located((AppiumBy.ANDROID_UIAUTOMATOR,f'new UiSelector().text("{bank_name}")')))
    assert bank_name_text.is_displayed(), f'bank name text was not displayed';
    assert bank_name_text.text == bank_name, f'bank name text was not as expected'

    account_number = wait.until(
        EC.presence_of_element_located((AppiumBy.ANDROID_UIAUTOMATOR, f'new UiSelector().text("{account_no}")')))
    assert account_number.is_displayed(), f'account_number was not displayed';
    assert account_number.text == account_no, f'account_number was not as expected'


    payee_namee = wait.until(
        EC.presence_of_element_located((AppiumBy.ANDROID_UIAUTOMATOR, f'new UiSelector().text("{payee_name}")')))
    assert payee_namee.is_displayed(), f'account_number was not displayed';
    assert payee_namee.text == payee_name, f'account_number was not as expected'



@then(r'I tap on the three vertical dots on the payee edit screen')
def step_vertical_dots(context):
    vertical_dots = WebDriverWait(context.driver, 20).until(
        EC.presence_of_element_located((AppiumBy.ANDROID_UIAUTOMATOR, f'new UiSelector().className("com.horcrux.svg.SvgView").instance(4)')))
    if vertical_dots:
        vertical_dots.click()
        assert True
    else:
        assert False

@then(r'I click on the delete payee option')
def step_delete_payee(context):
    delete_payee = WebDriverWait(context.driver, 20).until(
        EC.presence_of_element_located((AppiumBy.ANDROID_UIAUTOMATOR, f'new UiSelector().resourceId("deleteText")')))
    if delete_payee:
        delete_payee.click()
        assert True
    else:
        assert False

@then(r'I verify if confirmation pop-up appeared')
def step_pop_up(context):
    pop_up = WebDriverWait(context.driver, 20).until(
        EC.presence_of_element_located((AppiumBy.ANDROID_UIAUTOMATOR, f'new UiSelector().resourceId("deleteDescription")')))
    if pop_up:
        print(pop_up.text)
        assert pop_up.text=='Are you sure you want to delete payee?'
    else:
        assert False

@then(r"I click on the ([^']*) button on the confirmation pop-up appeared")
def step_confirmation(context,no_or_yes ):
    if no_or_yes == "Yes":
        context.driver.find_element(AppiumBy.ANDROID_UIAUTOMATOR, 'new UiSelector().resourceId("yes")').click()
    elif no_or_yes == "No":
        context.driver.find_element(AppiumBy.ANDROID_UIAUTOMATOR, 'new UiSelector().resourceId("no")').click()
    else:
        print("Invalid input, required 'enabled/disabled'")
        assert False


@then(r"I click on the camera icon")
def step_payee_name(context):
    camera_icon = WebDriverWait(context.driver, 20).until(
        EC.presence_of_element_located((AppiumBy.ANDROID_UIAUTOMATOR, f'new UiSelector().className("com.horcrux.svg.PathView").instance(1)')))
    if camera_icon:
        Testing.perform_touch_action(context.driver, Testing.tap_outside(context.driver,
                                                                         automator_path=f'new UiSelector().className("com.horcrux.svg.PathView").instance(1)')[
            0],
                                     Testing.tap_outside(context.driver,
                                                         automator_path=f'new UiSelector().className("com.horcrux.svg.PathView").instance(1)')[
                                         1])
        assert True
    else:
        assert False

@then(r'I tap on the Take Photo to upload the payee photo')
def step_payee_name(context):
    camera_icon = WebDriverWait(context.driver, 20).until(
        EC.presence_of_element_located((AppiumBy.ANDROID_UIAUTOMATOR, f'new UiSelector().text("Take Photo")')))
    if camera_icon:
        Testing.perform_touch_action(context.driver, Testing.tap_outside(context.driver,
                                                                         automator_path=f'new UiSelector().text("Take Photo")')[
            0],
                                     Testing.tap_outside(context.driver,
                                                         automator_path=f'new UiSelector().text("Take Photo")')[
                                         1])
        WebDriverWait(context.driver, 20).until(
            EC.presence_of_element_located((AppiumBy.ANDROID_UIAUTOMATOR, f'new UiSelector().resourceId("com.android.camera2:id/shutter_button")'))).click()
        WebDriverWait(context.driver, 20).until(
            EC.presence_of_element_located((AppiumBy.ANDROID_UIAUTOMATOR,
                                            f'new UiSelector().resourceId("com.android.camera2:id/done_button")'))).click()
        WebDriverWait(context.driver, 20).until(
            EC.presence_of_element_located((AppiumBy.ANDROID_UIAUTOMATOR,
                                            f'new UiSelector().resourceId("com.hugosave.nonprod:id/menu_crop")'))).click()


        assert True
    else:
        assert False

@then(r"I click on the Favourite icon")
def step_payee_name(context):
    favourite_icon = WebDriverWait(context.driver, 20).until(
        EC.presence_of_element_located((AppiumBy.ANDROID_UIAUTOMATOR, f'new UiSelector().className("com.horcrux.svg.PathView").instance(2)')))
    if favourite_icon:
        favourite_icon.click()
        assert True
    else:
        assert False

@then(r'I click on the Favourite icon on the Add New Payee screen')
def step_payee_name(context):
    favourite_icon = WebDriverWait(context.driver, 20).until(
        EC.presence_of_element_located((AppiumBy.ANDROID_UIAUTOMATOR, 'new UiSelector().className("com.horcrux.svg.PathView").instance(2)')))
    if favourite_icon:
        favourite_icon.click()
        assert True
    else:
        assert False

@then(r"I verify the save button is ([^']*)")
def step_confirm_button_status(context,enabled_or_disabled ):
    wait = WebDriverWait(context.driver, 20)
    save_button_state = wait.until(
        EC.presence_of_element_located(PayeeLocators.SAVE_BUTTON))


    if enabled_or_disabled == "enabled":
         assert save_button_state.is_enabled(); f"Expected save button state to be enabled but got {save_button_state}"
    elif enabled_or_disabled == "disabled":
        assert not save_button_state.is_enabled(); f"Expected save button state to be disabled but got {save_button_state}"
    else:
        print("Invalid input, required 'enabled/disabled'")

@then(r"I tap on the save button on the payee edit screen")
def step_confirm_button_status(context ):
    wait = WebDriverWait(context.driver, 20)
    save_button_state = wait.until(EC.presence_of_element_located(PayeeLocators.SAVE_BUTTON))
    assert save_button_state.is_enabled(); f"Expected save button state to be enabled but got {save_button_state}"
    save_button_state.click()



@then(r"I verify if i auto-directed to the payee ([^']*) individual screen")
def step_verify_payee_individual_screen(context, name):
    wait = WebDriverWait(context.driver, 20)
    payee_account_no = wait.until(EC.presence_of_element_located(PayeeLocators.PAYEE_ACCOUNT_NUMBER_ON_PAYEE_SCREEN))
    assert payee_account_no.is_displayed(); f"Expected payee button to be displayed but got {payee_account_no.is_displayed()}"
    assert payee_account_no.text==context.payee_details[name]["account_no"],f'payee account number is not as expected'



@then('I tap on the back arrow on the cashaccountdashboard screen')
def step_tap_back(context):
    Testing.all_path_find_element(context.driver,
                                                    element_xpath='//android.view.ViewGroup[@resource-id="backButton"]/android.view.ViewGroup/com.horcrux.svg.SvgView/com.horcrux.svg.GroupView/com.horcrux.svg.PathView',
                                                    element_ui_automator_path='new UiSelector().className("com.horcrux.svg.PathView").instance(9)',
                                                    element_click=True,one_more_click=True,
                                                    note="clicking on the back button on the cash account dashboard")


@then('I tap on the New Payment button on the payee individual screen')
def step_tap_new_payment(context):
    wait = WebDriverWait(context.driver, 20)
    new_payment_button = wait.until(EC.presence_of_element_located(PayeeLocators.NEW_PAYMENT_BUTTON))
    assert new_payment_button.is_enabled();
    f"Expected new_payment_button state to be enabled but got {new_payment_button.is_enabled()}"
    new_payment_button.click()


@then(r"I verify if i directed to the new payment screen")
def step_verify_payee_individual_screen(context):
    wait = WebDriverWait(context.driver, 20)
    new_payment_text = wait.until(EC.presence_of_element_located(PayeeLocators.NEW_PAYMENT_SCREEN))
    assert new_payment_text.is_displayed();
    f"Expected new_payment_button state to be displayed but got {new_payment_text.is_displayed()}"



@then(r"I check the text elements and buttons on the ([^']*) payee New Payment screen")
def step_new_payment_screen(context,name):
    wait = WebDriverWait(context.driver, 20)

    bank_name_text = wait.until(
        EC.presence_of_element_located((AppiumBy.ANDROID_UIAUTOMATOR, f'new UiSelector().text("{context.payee_details[name]["bank_name"]}")')))
    assert bank_name_text.is_displayed(), f'bank name text was not displayed';
    assert bank_name_text.text == context.payee_details[name]["bank_name"], f'bank name text was not as expected'

    account_number = wait.until(EC.presence_of_element_located(PayeeLocators.ACCOUNT_NUMBER_NEW_PAYMENT_SCREEN))
    assert account_number.is_displayed(), f'account_number was not displayed';
    assert account_number.text == context.payee_details[name]["account_no"], f'account_number was not as expected'


    payee_namee = wait.until(EC.presence_of_element_located(PayeeLocators.PAYEE_NAME_NEW_PAYMENT_SCREEN))
    assert payee_namee.is_displayed(), f'account_number was not displayed';
    assert payee_namee.text == context.payee_details[name]["payee_name"], f'account_number was not as expected'


    cancel_button = wait.until(EC.presence_of_element_located(PayeeLocators.CANCEL_BUTTON))
    assert cancel_button.is_displayed(), f'cancel_button was not displayed';

    preview_button = wait.until(EC.presence_of_element_located(PayeeLocators.PREVIEW_BUTTON))
    assert preview_button.is_displayed(), f'preview_button was not displayed';



@then(r"I enter the payee amount ([^']*) on the New Payment screen")
def step_tap_transaction_activities_option(context,amount):
    wait = WebDriverWait(context.driver, 20)
    amount_str = f"S$ {format_amount(amount)}"  # Format as it appears in the UI
    context.payee_amount_dict = {"last_transaction": amount_str}  # Store the last entered amount

    amount_input = wait.until(EC.presence_of_element_located(PayeeLocators.PAYEMNT_INPUT_FIELD))
    assert amount_input.is_enabled(), f'payment input field was not enabled';amount_input.clear();amount_input.send_keys(amount)


@then("I select the reason chip ([^']*) on the ([^']*) payee New payment screen")
def step_scroll_right_to_last_chip(context,reason_chip,name):
    context.payee_details[name]["reason_chip"] = reason_chip
    print(context.payee_details[name]["reason_chip"])
    driver = context.driver
    insurance = '//android.view.ViewGroup[@content-desc="Insurance"]'
    Testing().all_path_find_element(driver, element_xpath=insurance,
                                        element_ui_automator_path='new UiSelector().resourceId("chip1")',
                                        element_click=True)


@then(r"I verify the Preview button is ([^']*) on the New Payment screen")
def step_confirm_button_status(context,enabled_or_disabled ):
    wait = WebDriverWait(context.driver, 20)
    preview_button = wait.until(EC.presence_of_element_located(PayeeLocators.PREVIEW_BUTTON))

    if enabled_or_disabled == "enabled":
        assert preview_button.is_enabled(), f'preview_button was not enabled'
    elif enabled_or_disabled == "disabled":
        assert not preview_button.is_enabled(), f'preview_button was not disabled'
    else:
        print("Invalid input, required 'enabled/disabled'")

@then(r"I tap on the Preview button on the New Payment screen")
def step_confirm_button_status(context):
    wait = WebDriverWait(context.driver, 20)
    preview_button = wait.until(EC.presence_of_element_located(PayeeLocators.PREVIEW_BUTTON))
    assert preview_button.is_enabled(), f'preview_button was not enabled';preview_button.click()



@then(r"I check the text elements and buttons on the ([^']*) payee New Payment Preview screen")
def step_payee_screen(context,name):
    wait = WebDriverWait(context.driver, 20)

    bank_name_text = wait.until(
        EC.presence_of_element_located(
            (AppiumBy.ANDROID_UIAUTOMATOR, f'new UiSelector().text("{context.payee_details[name]["bank_name"]}")')))
    assert bank_name_text.is_displayed(), f'bank name text was not displayed';
    assert bank_name_text.text == context.payee_details[name]["bank_name"], f'bank name text was not as expected'

    account_number = wait.until(EC.presence_of_element_located(PayeeLocators.ACCOUNT_NUMBER_NEW_PAYMENT_PREVIEW_SCREEN))
    assert account_number.is_displayed(), f'account_number was not displayed';
    assert account_number.text == context.payee_details[name]["account_no"], f'account_number was not as expected'


    payee_namee = wait.until(EC.presence_of_element_located(PayeeLocators.PAYEE_NAME_NEW_PAYMENT_PREVIEW_SCREEN))
    assert payee_namee.is_displayed(), f'account_number was not displayed';
    assert payee_namee.text == context.payee_details[name]["payee_name"], f'account_number was not as expected'


    chip = context.payee_details[name]["reason_chip"]
    print(chip)
    reason_chip = wait.until(EC.presence_of_element_located((AppiumBy.ANDROID_UIAUTOMATOR, f'new UiSelector().text("{chip}")')))
    assert reason_chip.is_displayed(), f'reason chip was not displayed';



@then(r"I verify the Pay button is ([^']*) on the New Payment Preview screen")
def step_confirm_button_status(context,enabled_or_disabled ):

    wait = WebDriverWait(context.driver, 20)
    pay_button = wait.until(EC.presence_of_element_located(PayeeLocators.PAY_BUTTON))

    if enabled_or_disabled == "enabled":
        assert pay_button.is_enabled(), f'pay button was not enabled'

    elif enabled_or_disabled == "disabled":
        assert not pay_button.is_enabled(), f"Expected pay button state to be disabled but got {pay_button.is_enabled()}"
    else:
        print("Invalid input, required 'enabled/disabled'")

@then(r"I tap on the Pay button on the New Payment Preview screen")
def step_confirm_button_status(context):
    wait = WebDriverWait(context.driver, 20)
    pay_button = wait.until(EC.presence_of_element_located(PayeeLocators.PAY_BUTTON))
    assert pay_button.is_enabled(), f'pay button was not enabled'; pay_button.click()
    time.sleep(7)

@then("I verify the latest transaction record appears for the ([^']*) payee")
def step_verify_transaction_record(context,name):
    driver = context.driver
    last_amount = context.payee_amount_dict.get("last_transaction")

    if not last_amount:
        raise ValueError("No last transaction amount stored in context!")

    ui_automator_selector = f'new UiSelector().text("{last_amount}")'

    elements = WebDriverWait(driver, 20).until(
                        EC.presence_of_all_elements_located((AppiumBy.ANDROID_UIAUTOMATOR, ui_automator_selector)))
    payees = WebDriverWait(driver, 20).until(
        EC.presence_of_all_elements_located((AppiumBy.ANDROID_UIAUTOMATOR, f'new UiSelector().text("To {context.payee_details[name]["payee_name"]}")')))

    if not elements:
        raise AssertionError(f"Transaction record with amount {last_amount} not found!")

    # the latest transaction should be at instance(0)
    latest_transaction = elements[0]  # The first element is the latest one
    payee_name = payees[0]
    print(latest_transaction.text)
    print(payee_name.text)
    assert latest_transaction.is_displayed(), f"Latest transaction ({last_amount}) is not displayed!"
    assert payee_name.is_displayed(), f"Latest transaction ({name}) is not displayed!"

@then("I click on the latest transaction record appears for the ([^']*) payee")
def step_verify_transaction_record(context, name):
    driver = context.driver
    last_amount = context.payee_amount_dict.get("last_transaction")
    if not last_amount:
        raise ValueError("No last transaction amount stored in context!")

    ui_automator_selector = f'new UiSelector().text("{last_amount}")'

    Testing.perform_touch_action(context.driver, Testing.tap_outside(context.driver,
                                                                     automator_path=ui_automator_selector)[0],
                                 Testing.tap_outside(context.driver,
                                                     automator_path=ui_automator_selector)[1])

@then("I verify the latest transaction is settled for the ([^']*) payee")
def step_verify_transaction_record(context, name):
    driver = context.driver
    last_amount = context.payee_amount_dict.get("last_transaction")

    if not last_amount:
        raise ValueError("No last transaction amount stored in context!")

    ui_automator_selector = 'new UiSelector().resourceId("statusComponentMainDescriptionTestID")'

    status_elements = WebDriverWait(driver, 20).until(
        EC.presence_of_all_elements_located((AppiumBy.ANDROID_UIAUTOMATOR, ui_automator_selector))
    )

    payee_selector = f'new UiSelector().text("To {context.payee_details[name]["payee_name"]}")'
    payee_elements = WebDriverWait(driver, 20).until(
        EC.presence_of_all_elements_located((AppiumBy.ANDROID_UIAUTOMATOR, payee_selector))
    )

    if not status_elements:
        raise AssertionError(f"Transaction status with amount {last_amount} not found!")

    # Latest transaction should be at instance(0)
    latest_transaction = status_elements[0]  # The first element is the latest one
    payee_name = payee_elements[0]

    print(latest_transaction.text)
    print(payee_name.text)

    transaction_status = latest_transaction.text

    if "Settled" in transaction_status:
        return  # No need to assert True; the function completes successfully

    elif "Processing" in transaction_status:
        Testing.pull_to_refresh(driver, n_times=3)

        # Recheck status after refresh
        status_elements = WebDriverWait(driver, 20).until(
            EC.presence_of_all_elements_located((AppiumBy.ANDROID_UIAUTOMATOR, ui_automator_selector))
        )

        if "Settled" in status_elements[0].text:
            return  # Successfully settled after refresh
        else:
            raise AssertionError("Transaction status is still not settled after refresh!")

    elif "Reversed" in transaction_status:
        raise AssertionError("Transaction has been reversed! It is not settled.")
    else:
        raise AssertionError("Transaction status is unknown or not settled!")


@then('I tap on the back button on the Transaction details screen')
def step_tap_back(context):
    Testing.all_path_find_element(context.driver,element_ui_automator_path='new UiSelector().className("com.horcrux.svg.PathView").instance(15)',
                                                    element_click=True,
                                                    note="clicking on the back button on the transaction details screen")





