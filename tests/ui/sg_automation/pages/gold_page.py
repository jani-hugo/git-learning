from appium.webdriver.common.appiumby import AppiumBy
from selenium.webdriver.common.by import By  # If you need By locators


class GoldPage:
    """Locators for the Gold module."""

    # locators for BUY actions

    SCROLL_TO_INVEST_EXPLORE_BUTTON = (
        AppiumBy.ANDROID_UIAUTOMATOR,
        'new UiScrollable(new UiSelector().scrollable(true).instance(0)).scrollIntoView(new UiSelector().resourceId("investExploreButton").instance(0))',
    )

    PRECIOUS_METALS_DASHBOARD_BUTTON = (
        AppiumBy.ACCESSIBILITY_ID,
        "Precious Metals Dashboard",
    )
    GOLD_GET_STARTED_BUTTON = (
        AppiumBy.ANDROID_UIAUTOMATOR,
        'new UiSelector().resourceId("metalsCardGetStartedBtnGold")',
    )
    GOLD_DASHBOARD_BUTTON = (AppiumBy.ACCESSIBILITY_ID, "Gold Dashboard")
    BUY_BUTTON = (AppiumBy.ACCESSIBILITY_ID, "Buy")
    AMOUNT_INPUT = (AppiumBy.XPATH, '//android.widget.EditText[@text="00.00"]')
    PREVIEW_BUTTON = (AppiumBy.ACCESSIBILITY_ID, "Preview")
    CONFIRM_BUY_BUTTON = (
        AppiumBy.ACCESSIBILITY_ID,
        "Buy",
    )  # Assuming this is the "Buy" on the confirmation screen
    SKIP_BUTTON = (
        AppiumBy.ACCESSIBILITY_ID,
        "Skip",
    )  # Assuming this is the "Buy" on the confirmation screen
    FIRST_TRNX_RECORD = (
        AppiumBy.ANDROID_UIAUTOMATOR,
        'new UiSelector().text("Buy").instance(0)',
    )

    BACK_BUTTON_GOLD_DASHBOARD = (
        AppiumBy.XPATH,
        '//android.view.ViewGroup[@resource-id="metalsDashboardBackBtn"]/android.view.ViewGroup/com.horcrux.svg.SvgView/com.horcrux.svg.GroupView/com.horcrux.svg.PathView',
    )

    BACK_BUTTON_ON_LEARNING_SCREEN = (
        AppiumBy.XPATH,
        '//android.view.ViewGroup[@resource-id="metalsLearningBackBtn"]/android.view.ViewGroup/com.horcrux.svg.SvgView/com.horcrux.svg.GroupView/com.horcrux.svg.PathView',
    )

    BACK_BUTTON_ON_PRECIOUS_METALS_DASHBOARD = (
        AppiumBy.XPATH,
        '//android.view.ViewGroup[@resource-id="metalVaultsBackBtn"]/android.view.ViewGroup/com.horcrux.svg.SvgView/com.horcrux.svg.GroupView/com.horcrux.svg.PathView',
    )

    BACK_BUTTON_ON_CASH_ACCOUNT_DASHBOARD = (
        AppiumBy.XPATH,
        '//android.view.ViewGroup[@resource-id="backButton"]/android.view.ViewGroup/com.horcrux.svg.SvgView/com.horcrux.svg.GroupView/com.horcrux.svg.PathView',
    )

    GOLD_CARD_ON_HOMEPAGE = (
        AppiumBy.ANDROID_UIAUTOMATOR,
        'new UiSelector().text("Gold")',
    )

    # Trnx validation selectors

    TRANSACTION_TAB_ON_HOMEPAGE = (
        AppiumBy.ANDROID_UIAUTOMATOR,
        'new UiSelector().resourceId("tabBarButton")',
    )

    TRANSACTION_RECORD = (
        AppiumBy.ANDROID_UIAUTOMATOR,
        'new UiSelector().text("To Gold")',
    )

    SETTLED = (
        AppiumBy.ANDROID_UIAUTOMATOR,
        'new UiSelector().resourceId("statusComponentMainDescriptionTestID")',
    )

    BACK_BUTTON_ON_TRNX_RECORD = (
        AppiumBy.XPATH,
        '//android.widget.FrameLayout[@resource-id="android:id/content"]/android.widget.FrameLayout/android.view.ViewGroup/android.view.ViewGroup/android.view.ViewGroup/android.view.ViewGroup/android.widget.FrameLayout/android.view.ViewGroup/android.view.ViewGroup/android.view.ViewGroup[2]/android.view.ViewGroup/android.view.ViewGroup/android.view.ViewGroup/android.view.ViewGroup/android.view.ViewGroup/android.view.ViewGroup/android.view.ViewGroup/android.widget.FrameLayout/android.view.ViewGroup/android.view.ViewGroup/android.view.ViewGroup/android.widget.FrameLayout/android.view.ViewGroup/android.view.ViewGroup/android.view.ViewGroup/android.view.ViewGroup/android.view.ViewGroup/android.widget.FrameLayout/android.view.ViewGroup/android.view.ViewGroup/android.view.ViewGroup/android.view.ViewGroup/android.view.ViewGroup/android.view.ViewGroup/android.view.ViewGroup/android.view.ViewGroup/android.view.ViewGroup/android.view.ViewGroup/com.horcrux.svg.SvgView/com.horcrux.svg.GroupView/com.horcrux.svg.PathView',
    )

    HOME_BUTTON = (
        AppiumBy.XPATH,
        '//android.view.View[@content-desc="Home"]/android.view.ViewGroup',
    )

    CASH_ACCOUNT_BUTTON_ON_HOME = (
        AppiumBy.ANDROID_UIAUTOMATOR,
        'new UiSelector().resourceId("cashAccountText")',
    )

    CASH_ACCOUNT_DASHBOARD_BUTTON = (
        AppiumBy.ANDROID_UIAUTOMATOR,
        'new UiSelector().resourceId("cashDashboardButton")',
    )

    NEXT_BUTTON = (AppiumBy.ANDROID_UIAUTOMATOR, 'new UiSelector().text("Next")')

    DONE_BUTTON = (AppiumBy.ANDROID_UIAUTOMATOR, 'new UiSelector().text("Done")')

    BACK_BUTTON_ON_TRNX_RECORD_CASH_AC = (
        AppiumBy.XPATH,
        '//android.widget.FrameLayout[@resource-id="android:id/content"]/android.widget.FrameLayout/android.view.ViewGroup/android.view.ViewGroup/android.view.ViewGroup/android.view.ViewGroup/android.widget.FrameLayout/android.view.ViewGroup/android.view.ViewGroup/android.view.ViewGroup/android.view.ViewGroup/android.view.ViewGroup/android.view.ViewGroup/android.view.ViewGroup/android.view.ViewGroup/android.widget.FrameLayout/android.view.ViewGroup/android.view.ViewGroup/android.view.ViewGroup/android.view.ViewGroup/android.view.ViewGroup/android.view.ViewGroup/android.view.ViewGroup/android.view.ViewGroup/android.view.ViewGroup/android.view.ViewGroup/com.horcrux.svg.SvgView/com.horcrux.svg.GroupView/com.horcrux.svg.PathView',
    )

    BACK_BUTTON_ON_CASH_ACC_LEARNING_SCREEN = (
        AppiumBy.XPATH,
        '//android.view.ViewGroup[@resource-id="backButton"]/android.view.ViewGroup/com.horcrux.svg.SvgView/com.horcrux.svg.GroupView/com.horcrux.svg.PathView',
    )

    # Networth locators
    NETWORTH_BUTTON = (
        AppiumBy.ANDROID_UIAUTOMATOR,
        'new UiSelector().resourceId("networthText")',
    )

    ALL_ASSETS_BUTTON = (
        AppiumBy.ANDROID_UIAUTOMATOR,
        'new UiSelector().resourceId("AssetsInTrust")',
    )

    BACK_BUTTON_ON_NETWORTH_DASHBOARD = (
        AppiumBy.XPATH,
        '//android.view.ViewGroup[@resource-id="backButton"]/android.view.ViewGroup/com.horcrux.svg.SvgView/com.horcrux.svg.GroupView/com.horcrux.svg.PathView',
    )

    # Locators for the SELL actions
    SELL_BUTTON = (AppiumBy.ACCESSIBILITY_ID, "Sell")
    SELL_AMOUNT_INPUT = (
        AppiumBy.ANDROID_UIAUTOMATOR,
        'new UiSelector().text("00.00")',
    )  # Assuming this is the same input field
    CONFIRM_SELL_BUTTON = (
        AppiumBy.ACCESSIBILITY_ID,
        "Sell",
    )  # Assuming this is the "Sell" button on the confirmation screen
