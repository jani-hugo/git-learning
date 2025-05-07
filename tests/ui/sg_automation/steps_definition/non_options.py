from behave import use_step_matcher
use_step_matcher("re")
from behave import given, then
from Automation.classes.all_path_find_elementt import TestElement
from appium.webdriver.common.appiumby import AppiumBy
from selenium.common.exceptions import NoSuchElementException
from selenium.webdriver.support.ui import WebDriverWait  # Use WebDriverWait from selenium
from selenium.webdriver.support import expected_conditions as EC
from Automation.sg_automation.pages.utils import Testing
import time


@given(r'I verify I am on the Home screen')
def step_home_screen(context ):
    cash_account_text = TestElement.all_path_find_element(context.driver, element_xpath='//android.widget.TextView[@resource-id="cashAccountText"]',
                                                               element_ui_automator_path='new UiSelector().resourceId("cashAccountText")', element_id='cashAccountText',
                                                                note="check cash account text link on the home screen", maxtime=30)


    if not cash_account_text["displayed"]==True:
        assert False, "cash account text is not displayed"


@then(r'I tap on the profile icon on the home screen')
def step_home_screen(context ):
    profile_icon =  TestElement.all_path_find_element(context.driver, element_xpath='//android.view.ViewGroup[@resource-id="homeAppMenuIcon"]/android.view.ViewGroup/com.horcrux.svg.SvgView/com.horcrux.svg.GroupView/com.horcrux.svg.PathView',
                                                                      element_ui_automator_path='new UiSelector().className("com.horcrux.svg.PathView").instance(0)',element_click=True,
                                                                      note="clicking on the profile icon  on the home screen")
@then("I scroll down the menu screen")
def step_scroll_down_and_up(context):
    # Perform scrolling action until element found downwards
    down = context.driver.find_element(AppiumBy.ANDROID_UIAUTOMATOR,
                        'new UiScrollable(new UiSelector().scrollable(true)).scrollIntoView(new UiSelector().text("Enjoying our app?"))')
    assert down.is_displayed(), f'{down} is not displayed'
    print(down.text)

@then(r'I tap on the nonprod option in the menu')
def step_tap_on_nonprod_option(context):
    driver = context.driver
    try:
        # Try to find the Nonprod Option
        nonprod_option = driver.find_element(AppiumBy.ANDROID_UIAUTOMATOR, 'new UiSelector().text("Nonprod Options")')
        nonprod_option.click()
        print("Nonprod Option found and tapped.")
    except NoSuchElementException:
        print("Nonprod Option not found. Unlocking it...")

        # Find Current Version and tap 10 times
        try:
            current_version = '//android.widget.TextView[contains(@text, "Current Version")]'
            x = Testing.tap_outside(driver, xpath=current_version)[0]
            y = Testing.tap_outside(driver, xpath=current_version)[1]
            # element = driver.find_element(AppiumBy.XPATH, current_version)
            for _ in range(15):
                Testing.perform_touch_action(driver, x, y)
            print("Tapped on Current Version 10 times.")
            time.sleep(2)
            TestElement.all_path_find_element(context.driver,
                                              element_xpath='//android.view.ViewGroup[@content-desc="Nonprod Options"]',
                                              element_ui_automator_path='new UiSelector().resourceId("nonProdButton")',
                                              element_click=True,
                                              note="clicking nonprod button")
            print("Nonprod Option unlocked and tapped.")
        except NoSuchElementException:
            print("Failed to find Current Version element.")


@then(r'I tap on the Transaction activities option in the non-prod options screen')
def step_tap_transaction_activities_option(context):
    driver = context.driver
    TestElement.all_path_find_element(context.driver, element_xpath='//android.widget.TextView[@resource-id="txnText"]',
                                                                      element_ui_automator_path='new UiSelector().resourceId("txnText")',element_id='txnText',element_click=True,
                                                                      note="clicking on the txnText  on the non-prod options screen")

@then(r"I enter the amount ([^']*)")
def step_tap_transaction_activities_option(context,amount):
    driver = context.driver
    TestElement().all_path_find_element(driver,element_xpath='//android.widget.EditText[@resource-id="inputAmount"]',
                                        element_ui_automator_path='new UiSelector().resourceId("inputAmount")',
                                        element_id='inputAmount',
                                        is_element_input_field=True, input_field_value=int(amount),
                                        note="enter the amount of the transaction in the non-prod options screen")

@then(r"I tap on the Deposit to your account button")
def step_tap_transaction_activities_option(context):

    deposit_button = '//android.view.ViewGroup[@content-desc="Deposit to your account"]'
    deposit = WebDriverWait(context.driver, 30).until(EC.presence_of_element_located((AppiumBy.XPATH, deposit_button)))
    if deposit:
        print("Deposit to your account button tapped.")
        deposit.click()



@then('I tap on the back button on the nonprod screen')
def step_tap_back(context):
    TestElement.all_path_find_element(context.driver,
                                                    element_xpath='//android.view.ViewGroup[@resource-id="nonProdBackButton"]/android.view.ViewGroup/com.horcrux.svg.SvgView/com.horcrux.svg.GroupView/com.horcrux.svg.PathView',
                                                    element_ui_automator_path='new UiSelector().className("com.horcrux.svg.PathView").instance(0)',
                                                    element_click=True,
                                                    note="clicking on the back button on nonprod screen")

@then("I go back to home screen")
def step_tap_back(context):
    driver = context.driver
    element_xpath='//android.view.ViewGroup[@resource-id="homeShowMeAroundIcon"]/android.view.ViewGroup/com.horcrux.svg.SvgView/com.horcrux.svg.GroupView/com.horcrux.svg.PathView'
    element_ui_automator_path='new UiSelector().className("com.horcrux.svg.PathView").instance(7)'

    x = Testing.tap_outside(driver,xpath=element_xpath)[0]
    y =  Testing.tap_outside(driver, xpath=element_xpath)[1]+50
    Testing.perform_touch_action(driver,x,y)





