from behave import *
import random 

from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By
from selenium.common.exceptions import TimeoutException
from appium.webdriver.common.appiumby import AppiumBy
from selenium.webdriver.common.action_chains import ActionChains
import time
from pages.signuplocators import SignUpLocators
from pages.home_screen_locators import HomeScreen
from pages.utils import Testing





@given(u'I signup')
def signup(context):
    
    driver = context.driver
    wait = context.wait
    
    # Enter valid mobile number
    
    random_digits = "".join(random.choice("0123456789") for _ in range(10))
    mobile_number = "+373" + random_digits
    
    wait.until(EC.element_to_be_clickable(SignUpLocators.MOBILE_NUMBER_INPUT_FIELD)).clear().send_keys(mobile_number)
    
    
    wait.until(EC.element_to_be_clickable(SignUpLocators.get_otp_button)).click()
    
    
    # Enter Valid OTP
    
    OTP = wait.until(
        EC.visibility_of_element_located(SignUpLocators.ENTER_6_DIGIT_OTP_TEXT)
    )

    if OTP:
    
        actions = ActionChains(driver)
        for i in range(1, 7):
            actions.send_keys(str(i)).perform()
            time.sleep(0.1)
            
    # Enter valid details
    
    detailsScreen = wait.until(
        EC.visibility_of_element_located(SignUpLocators.EMAIL_TEXT)
    )

    if detailsScreen:
    
        wait.until(
            EC.element_to_be_clickable(SignUpLocators.CASUAL_NAME_INPUT_FIELD)
        ).clear().send_keys("Jones")

        wait.until(
            EC.element_to_be_clickable(SignUpLocators.LEGAL_NAME_INPUT_FIELD)
        ).clear().send_keys("John Jones")

        wait.until(
            EC.element_to_be_clickable(SignUpLocators.EMAIL_INPUT_FIELD)
        ).clear().send_keys("jj@12gmail.com")

        wait.until(EC.element_to_be_clickable(SignUpLocators.CHECK_BOX)).click()
    
        wait.until(EC.element_to_be_clickable(SignUpLocators.CONTINUE_BUTTON)).click()
    
    
    
    # Set Passcode
    
    passcode = wait.until(
        EC.visibility_of_element_located(SignUpLocators.SET_PASSCODE_TEXT)
    )
    
    if passcode:
        
        actions = ActionChains(driver)
        for i in range(1, 13):
            actions.send_keys(str(1)).perform()
            time.sleep(0.1)
            
        wait.until(EC.element_to_be_clickable(SignUpLocators.CREATE_ACCOUNT_BUTTON)).click()
    
    
    wait.until(EC.element_to_be_clickable(SignUpLocators.ALLOW_NOTIFICATIONS_BUTTON)).click()
    
    # Close the Show Me around
    
    wait.until(
            EC.element_to_be_clickable(
                (
                    AppiumBy.XPATH,
                    '//android.view.ViewGroup[@resource-id="homeShowMeSroundOverlay"]/android.view.ViewGroup/com.horcrux.svg.SvgView/com.horcrux.svg.GroupView/com.horcrux.svg.GroupView/com.horcrux.svg.PathView',
                )
            )
        ).click()
    

    time.sleep(20)
    driver.tap([(315, 1601)])
    time.sleep(15)
    driver.tap([(315, 1601)])
    time.sleep(15)
    driver.tap([(311, 1573)])

    
 
    
    # MMF modal 
    
    # MMF = wait.until(EC.presence_of_element_located(HomeScreen.MMF_POP_UP))
    
    # if MMF:
    
    #     driver.tap([(315, 1605)])
        
    # else:
        
    #     time.sleep(7)
        
    #     driver.tap([(315, 1605)])
    
    # #eDDA modal
    
    # eDDA = wait.until(EC.presence_of_element_located(HomeScreen.EDDA_POP_UP))
    
    # if eDDA:
    
    #     driver.tap([(311, 1438)])
        
    # else:
        
    #     time.sleep(7)
        
    #     driver.tap([(311, 1438)])
    
    # # QR Pay
    
    # QR = wait.until(EC.presence_of_element_located(HomeScreen.QR_POP_UP))
    
    # if QR:
    
    #     driver.tap([(315, 1605)])
        
    # else:
        
    #     time.sleep(7)
        
    #     driver.tap([(315, 1605)])
    
    


    
    
    

    
    
    
    
    

