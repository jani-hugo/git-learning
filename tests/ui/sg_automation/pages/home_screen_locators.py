from appium.webdriver.common.appiumby import AppiumBy
from selenium.webdriver.common.by import By  # If you need By locators


class HomeScreen:
    """Locators for the Gold module."""

    # locators for BUY actions
    SHOW_ME_AROUND = (AppiumBy.ANDROID_UIAUTOMATOR,
                                       'new UiSelector().text("Show me around >")')


    CLOSE_SHOW_ME_AROUND = (AppiumBy.XPATH,'//android.view.ViewGroup[@resource-id="homeShowMeSroundOverlay"]/android.view.ViewGroup/com.horcrux.svg.SvgView/com.horcrux.svg.GroupView/com.horcrux.svg.GroupView/com.horcrux.svg.PathView')
    # new UiSelector().className("com.horcrux.svg.PathView").instance(0)

    MMF_POP_UP = (AppiumBy.ANDROID_UIAUTOMATOR, 'new UiSelector().resourceId("RNE__Overlay__Container")')

    EDDA_POP_UP = (AppiumBy.ANDROID_UIAUTOMATOR, 'new UiSelector().resourceId("RNE__Overlay__Container")')

    QR_POP_UP = (AppiumBy.ANDROID_UIAUTOMATOR, 'new UiSelector().resourceId("RNE__Overlay__Container")')

    CASH_ACCOUNT_TEXT = (AppiumBy.ANDROID_UIAUTOMATOR,'new UiSelector().resourceId("cashAccountText")')

    INITIAL_BALANCE = (AppiumBy.ANDROID_UIAUTOMATOR, 'new UiSelector().text("00.00").instance(0)')

    ADD_MONEY_BUTTON = (AppiumBy.ANDROID_UIAUTOMATOR, 'new UiSelector().className("android.view.ViewGroup").instance(53)')


    # CASH ACCOUNT LEARNING SCREEN
    HOW_TO_VIDEOS = (AppiumBy.ANDROID_UIAUTOMATOR, 'new UiSelector().text("How to Videos")')

    CASH_ACCOUNT_FAQ_BUTTON = (AppiumBy.ANDROID_UIAUTOMATOR, 'new UiSelector().text("Cash Account FAQs")')

    SEE_ALL_LINK = (AppiumBy.ANDROID_UIAUTOMATOR, 'new UiSelector().text("See all")')

    CASH_ACCOUNT_DASHBOARD_BUTTON = (AppiumBy.ANDROID_UIAUTOMATOR, 'new UiSelector().resourceId("cashDashboardButton")')


    # CASH ACCOUNT DASHBOARD
    CASH_ACCOUNT_TITLE = (AppiumBy.ANDROID_UIAUTOMATOR,'new UiSelector().resourceId("cashAccountTitle")')

    DBS_BANK_NAME = (AppiumBy.ANDROID_UIAUTOMATOR, 'new UiSelector().resourceId("bank")')

    ACCOUNT_NUMBER = (AppiumBy.ANDROID_UIAUTOMATOR, 'new UiSelector().resourceId("accountNumber")')

    BALANCE_AS_0 = (AppiumBy.ANDROID_UIAUTOMATOR, 'new UiSelector().text("00.00")')

    ADD_MONEY_TEXT = (AppiumBy.ANDROID_UIAUTOMATOR, 'new UiSelector().text("Add Money")')

    SEND_MONEY_TO_PAYEE_TEXT = (AppiumBy.ANDROID_UIAUTOMATOR, 'new UiSelector().resourceId("sendMoneyText")')

    ADD_PAYEE_TEXT = (AppiumBy.ANDROID_UIAUTOMATOR, 'new UiSelector().resourceId("addPayeeText")')

    LEARN_MORE_LINK_ = (AppiumBy.ANDROID_UIAUTOMATOR, 'new UiSelector().text("Learn More")')

    BOOK_ICON = (AppiumBy.ANDROID_UIAUTOMATOR, 'new UiSelector().className("com.horcrux.svg.PathView").instance(0)')



