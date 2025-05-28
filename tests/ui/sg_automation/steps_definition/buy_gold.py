
from behave import then, when, given
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By
from selenium.common.exceptions import TimeoutException
from appium.webdriver.common.appiumby import AppiumBy
from selenium.webdriver.common.action_chains import ActionChains
import time
from pages.gold_page import GoldPage
from pages.utils import Testing
from pages.non_prod_options_locators import NonProd
from pages.home_screen_locators import HomeScreen
from behave import *
import re
use_step_matcher("re")

@given(u'I move to the gold dashboard')
def step_impl(context):
    
    driver = context.driver
    wait = context.wait

    wait.until(EC.element_to_be_clickable(GoldPage.SCROLL_TO_INVEST_EXPLORE_BUTTON)).click()
    
    wait.until(EC.element_to_be_clickable(GoldPage.PRECIOUS_METALS_DASHBOARD_BUTTON)).click()
    
    wait.until(EC.element_to_be_clickable(GoldPage.GOLD_GET_STARTED_BUTTON)).click()
    
    wait.until(EC.element_to_be_clickable(GoldPage.GOLD_DASHBOARD_BUTTON)).click()
    

@then(u'I validate buy and sell buttons')
def step_impl(context):
    
    driver = context.driver
    wait = context.wait

    
    BUY = wait.until(EC.visibility_of_element_located(GoldPage.BUY_BUTTON))

    SELL = wait.until(EC.visibility_of_element_located(GoldPage.SELL_BUTTON))


    assert not BUY.is_enabled() and not SELL.is_enabled()
    
    
@when(u'I move to the homescreen')
def step_impl(context):
    
    
    driver = context.driver
    wait = context.wait

    wait.until(EC.element_to_be_clickable(GoldPage.BACK_BUTTON_GOLD_DASHBOARD)).click()
    
    wait.until(EC.element_to_be_clickable(GoldPage.BACK_BUTTON_ON_LEARNING_SCREEN)).click()
    
    wait.until(EC.element_to_be_clickable(GoldPage.BACK_BUTTON_ON_PRECIOUS_METALS_DASHBOARD)).click()
    
    wait.until(EC.element_to_be_clickable(GoldPage.BACK_BUTTON_ON_LEARNING_SCREEN)).click()
    


@when(r"I add ([^']*) to the cash account")
def step_impl(context,amount):
    
    driver = context.driver
    wait = context.wait
    
    amount = int(amount)
    
    wait.until(EC.element_to_be_clickable(NonProd.PROFILE_ICON_HOMESCREEN)).click()
    
    tap_on_version = wait.until(EC.element_to_be_clickable(NonProd.VERSION_BUTTON))
    
    for i in range(1,16):
        
        tap_on_version.click()
        time.sleep(0.5)
    
    
    driver.find_element(AppiumBy.ANDROID_UIAUTOMATOR, 'new UiScrollable(new UiSelector().scrollable(true)).scrollIntoView(new UiSelector().text("Enjoying our app?"))')
    
    wait.until(EC.element_to_be_clickable(NonProd.NON_PROD_OPTIONS_BUTTON)).click()
    
    wait.until(EC.element_to_be_clickable(NonProd.TRANSACTION_ACTIVITIES)).click()
    
    wait.until(EC.element_to_be_clickable(NonProd.INPUT_AMOUNT_FIELD)).send_keys(amount)

    wait.until(EC.element_to_be_clickable(NonProd.DEPOSIT_TO_YOUR_ACCOUNT_BUTTON)).click()

    wait.until(EC.element_to_be_clickable(NonProd.BACK_BUTTON_ON_NONPROD)).click()

    time.sleep(5)

    wait.until(EC.element_to_be_clickable(NonProd.UMOH_BUTTON_ON_HOMESCREEN)).click()
    

 
    

    

@then(u'I validate buy and sell buttons state')
def step_impl(context):
    
    driver = context.driver
    wait = context.wait
    
    wait.until(EC.element_to_be_clickable(GoldPage.SCROLL_TO_INVEST_EXPLORE_BUTTON)).click()
    
    wait.until(EC.element_to_be_clickable(GoldPage.GOLD_GET_STARTED_BUTTON)).click()
    
    Testing.pull_to_refresh(driver, n_times=2)
    
    BUY = wait.until(EC.element_to_be_clickable(GoldPage.BUY_BUTTON))

    assert BUY.is_enabled()
    
    SELL = wait.until(EC.visibility_of_element_located(GoldPage.SELL_BUTTON))

    assert not SELL.is_enabled()

    
    

@when(u'I click on the buy button')
def step_impl(context):
    
    driver = context.driver
    wait = context.wait
    
    Testing.pull_to_refresh(driver, n_times=1)
    
    wait.until(EC.element_to_be_clickable(GoldPage.BUY_BUTTON)).click()
    

@then(u'I validate static text on the buy screen')
def step_impl(context):
    
    driver = context.driver
    wait = context.wait
    
    wait.until(EC.visibility_of_element_located(GoldPage.BUY_TEXT_ON_BUY_SCREEN))
    
    wait.until(EC.visibility_of_element_located(GoldPage.TO_TEXT_ON_THE_BUY_SCREEN))
    
    wait.until(EC.visibility_of_element_located(GoldPage.GOLD_VAULT_TEXT_ON_THE_SCREEN))
    
    wait.until(EC.visibility_of_element_located(GoldPage.CURRENT_VALUE_TEXT))
    
    wait.until(EC.visibility_of_element_located(GoldPage.FROM_TEXT_ON_THE_BUY_SCREEN))
    
    wait.until(EC.visibility_of_element_located(GoldPage.CASH_ACCOUNT_NUMBER_TEXT))
    
    wait.until(EC.visibility_of_element_located(GoldPage.LIVE_TEXT))
    
    wait.until(EC.visibility_of_element_located(GoldPage.BUY_PRICE_TEXT))
    
    wait.until(EC.visibility_of_element_located(GoldPage.GOLD_IMAGE))
    
    wait.until(EC.visibility_of_element_located(GoldPage.AMOUNT_PREDEFINED_BUTTON_FIFTY))
    
    wait.until(EC.visibility_of_element_located(GoldPage.AMOUNT_PREDEFINED_BUTTON_FIVE_HUNDRED))
    
    wait.until(EC.visibility_of_element_located(GoldPage.AMOUNT_PREDEFINED_BUTTON_FIVE_HUNDRED))
    
    wait.until(EC.visibility_of_element_located(GoldPage.AMOUNT_PREDEFINED_BUTTON_THOUSAND))
    
    wait.until(EC.visibility_of_element_located(GoldPage.GOLD_PRICE_TREND_TAB))
    
    
    

@when(u'I enter amount greater than cash account balance')
def step_impl(context):
    
    driver = context.driver
    wait = context.wait
    
    amount = 500
    
    wait.until(EC.element_to_be_clickable(GoldPage.AMOUNT_INPUT)).send_keys(amount)
    
    
    
    

@then(u'I validate Insufficient balance text on the screen')
def step_impl(context):
    
    driver = context.driver
    wait = context.wait
    
    wait.until(EC.visibility_of_element_located(GoldPage.INSUFFICIENT_BALANCE_TEXT))
    
    

@then(u'I validate cancel and preview buttons on the screen')
def step_impl(context):
    driver = context.driver
    wait = context.wait
    
    wait.until(EC.visibility_of_element_located(GoldPage.CANCEL_BUTTON))
    wait.until(EC.visibility_of_element_located(GoldPage.PREVIEW_BUTTON))
    




@when(r"I enter amount ([^']*) and click on preview")
def step_impl(context,amount):
    
    driver = context.driver
    wait = context.wait
    
    amount = int(amount)
    
    wait.until(EC.element_to_be_clickable(GoldPage.AMOUNT_INPUT)).send_keys(amount)
    
    wait.until(EC.element_to_be_clickable(GoldPage.PREVIEW_BUTTON)).click()
    
    
    

@then(u'I validate static text on the preview screen')
def step_impl(context):
    
    driver = context.driver
    wait = context.wait
    
    wait.until(EC.visibility_of_element_located(GoldPage.PREVIEW_TEXT))
    
    wait.until(EC.visibility_of_element_located(GoldPage.BUYING_TEXT))
    
    wait.until(EC.visibility_of_element_located(GoldPage.TRANSACTION_FEE_TEXT))
    
    wait.until(EC.visibility_of_element_located(GoldPage.BUYING_TEXT))
    
    wait.until(EC.visibility_of_element_located(GoldPage.PAYING_FROM_TEXT))
    
    wait.until(EC.visibility_of_element_located(GoldPage.CASH_ACCOUNT_TEXT))
    
    
 
@when(u'I click on buy button on the preview screen')
def step_impl(context):
    
    driver = context.driver
    wait = context.wait
    
    wait.until(EC.element_to_be_clickable(GoldPage.BUY_BUTTON)).click()
    

@then(u'I validate successfully bought message on the screen')
def step_impl(context):
    
    driver = context.driver
    wait = context.wait
    
    wait.until(EC.visibility_of_element_located(GoldPage.BOUGHT_SUCCESSFULLY_TEXT))
    
    wait.until(EC.visibility_of_element_located(GoldPage.AUTOMATE_YOUR_SAVINGS_TEXT))
    
@when(r"I switch to grams and enter ([^']*) grams")
def step_impl(context,amount):
    
    driver = context.driver
    wait = context.wait
    amount = int(amount)
    
    wait.until(EC.element_to_be_clickable(GoldPage.GRAMS_BUTTON)).click()
    
    wait.until(EC.element_to_be_clickable(GoldPage.GRAMS_INPUT_FIELD)).clear()
    
    wait.until(EC.element_to_be_clickable(GoldPage.AMOUNT_INPUT)).send_keys(amount)
    
    
@when(u'I click on the preview button')
def step_impl(context):
    
    driver = context.driver
    wait = context.wait
    
    wait.until(EC.element_to_be_clickable(GoldPage.PREVIEW_BUTTON)).click()
    

@when(u'I select 50 pre defined button and validate input field')
def step_impl(context):
    
    driver = context.driver
    wait = context.wait
    
    wait.until(EC.element_to_be_clickable(GoldPage.AMOUNT_PREDEFINED_BUTTON_FIFTY)).click()
    
    wait.until(EC.visibility_of_element_located(GoldPage.FIFTY_PREDEFINED_TEXT))
    

@when(u'I select 100 pre defined button and validate input field')
def step_impl(context):
    
    driver = context.driver
    wait = context.wait
    
    wait.until(EC.element_to_be_clickable(GoldPage.AMOUNT_PREDEFINED_BUTTON_HUNDRED)).click()
    
    wait.until(EC.visibility_of_element_located(GoldPage.HUNDRED_PREDEFINED_TEXT))
    
    
@when(u'I select 500 pre defined button and validate input field')
def step_impl(context):
    
    driver = context.driver
    wait = context.wait
    
    wait.until(EC.element_to_be_clickable(GoldPage.AMOUNT_PREDEFINED_BUTTON_FIVE_HUNDRED)).click()
    
    wait.until(EC.visibility_of_element_located(GoldPage.FIVE_HUNDRED_PREDEFINED_TEXT))
    
@when(r"I buy gold of ([^']*)")
def step_impl(context,amount):
    
    driver = context.driver
    wait = context.wait
    
    
    
    wait.until(EC.element_to_be_clickable(GoldPage.SCROLL_TO_INVEST_EXPLORE_BUTTON)).click()
    
    wait.until(EC.element_to_be_clickable(GoldPage.PRECIOUS_METALS_DASHBOARD_BUTTON)).click()
    
    wait.until(EC.element_to_be_clickable(GoldPage.GOLD_GET_STARTED_BUTTON)).click()
    
    wait.until(EC.element_to_be_clickable(GoldPage.GOLD_DASHBOARD_BUTTON)).click()
    
    wait.until(EC.element_to_be_clickable(GoldPage.BUY_BUTTON)).click()
    
    amount = 500
    
    wait.until(EC.element_to_be_clickable(GoldPage.AMOUNT_INPUT)).send_keys(amount)
    
    wait.until(EC.element_to_be_clickable(GoldPage.PREVIEW_BUTTON)).click()
    
    wait.until(EC.element_to_be_clickable(GoldPage.BUY_BUTTON)).click()
    
    wait.until(EC.element_to_be_clickable(GoldPage.SKIP_BUTTON)).click()
    
    Testing.pull_to_refresh(driver, n_times=2)
    
    