from appium.webdriver.common.appiumby import AppiumBy
from selenium.webdriver.common.by import By  # If you need By locators


class NonProd:
    
    PROFILE_ICON_HOMESCREEN = (AppiumBy.XPATH, '//android.view.ViewGroup[@resource-id="homeAppMenuIcon"]/android.view.ViewGroup/com.horcrux.svg.SvgView')

    VERSION_BUTTON = (AppiumBy.ANDROID_UIAUTOMATOR, 'new UiSelector().textContains("Current Version:")')

    NON_PROD_OPTIONS_BUTTON = (AppiumBy.ACCESSIBILITY_ID, 'Nonprod Options')

    TRANSACTION_ACTIVITIES = (AppiumBy.ACCESSIBILITY_ID, 'Transaction Activities')

    INPUT_AMOUNT_FIELD = (AppiumBy.ANDROID_UIAUTOMATOR, 'new UiSelector().resourceId("inputAmount")')

    DEPOSIT_TO_YOUR_ACCOUNT_BUTTON = (AppiumBy.ACCESSIBILITY_ID, 'Deposit to your account')

    BACK_BUTTON_ON_NONPROD = (AppiumBy.XPATH, '//android.view.ViewGroup[@resource-id="nonProdBackButton"]/android.view.ViewGroup/com.horcrux.svg.SvgView/com.horcrux.svg.GroupView/com.horcrux.svg.PathView')
    
    UMOH_BUTTON_ON_HOMESCREEN = (AppiumBy.XPATH, '//android.view.View[@content-desc="Unlock more"]/android.view.ViewGroup')
    
