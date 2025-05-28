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



@when(u'I click on the sell button')
def step_impl(context):
    
    driver = context.driver
    wait = context.wait
    
    
    wait.until(EC.element_to_be_clickable(GoldPage.SELL_BUTTON)).click()
    


@when(u'I enter amount greater than gold balance to sell')
def step_impl(context):
    
    driver = context.driver
    wait = context.wait
    
    amount = 500
    
    wait.until(EC.element_to_be_clickable(GoldPage.AMOUNT_INPUT)).send_keys(amount)
    
    


@then(u'I validate successfully sold message on the screen')
def step_impl(context):
    
    driver = context.driver
    wait = context.wait
    
    wait.until(EC.visibility_of_element_located(GoldPage.SOLD_SUCCESS_TEXT))
