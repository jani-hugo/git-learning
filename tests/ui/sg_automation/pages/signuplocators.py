from appium.webdriver.common.appiumby import AppiumBy
from selenium.webdriver.common.by import By  # If you need By locators


class SignUpLocators:
    """Locators for the MOBILE INPUT SCREEN."""

    WELCOME_HUGO_HERO_TEXT = (AppiumBy.XPATH,
                                       '//android.widget.TextView[@resource-id="mobileNumberWelcomeText"]')

    VERIFY_MOBILE_NUMBER_TEXT = (AppiumBy.XPATH, '//android.widget.TextView[@resource-id="mobileNumberVerifyMobileText"]')

    MOBILE_NUMBER_INPUT_FIELD = (AppiumBy.CLASS_NAME,'android.widget.EditText')

    error_message_locator = (AppiumBy.XPATH, '//android.widget.TextView[@resource-id="mobileNumberErrorText"]')

    warning_icon_locator = (AppiumBy.XPATH,
                            '//android.view.ViewGroup[@resource-id="mobileNumberErrorIcon"]/android.view.ViewGroup/android.view.ViewGroup/com.horcrux.svg.SvgView/com.horcrux.svg.GroupView/com.horcrux.svg.PathView')

    get_otp_button = (AppiumBy.XPATH, '//android.view.ViewGroup[@content-desc="Get OTP"]')

    CASUAL_NAME_TEXT = (AppiumBy.XPATH,'//android.widget.TextView[@text="Casual Name (e.g. Jimmy, Jo, Ray)"]')

    LEGAL_NAME_TEXT = (AppiumBy.XPATH, f'//android.widget.TextView[@text="Full Legal Name as per your ID *"]')

    EMAIL_TEXT = (AppiumBy.XPATH,f'//android.widget.TextView[@text="Email Address *"]')

    TICK_THIS_BOX_TEXT = (AppiumBy.XPATH,'//android.widget.TextView[@text="Tick this box to confirm you are at least 18 years old and agree to our Terms & Conditions and Privacy Policy"]')

    CASUAL_NAME_INPUT_FIELD = (AppiumBy.XPATH,'//android.widget.ScrollView/android.view.ViewGroup/android.view.ViewGroup[2]/android.widget.EditText')

    LEGAL_NAME_INPUT_FIELD = (AppiumBy.XPATH,'//android.widget.ScrollView/android.view.ViewGroup/android.view.ViewGroup[4]/android.widget.EditText')

    EMAIL_INPUT_FIELD = (AppiumBy.XPATH,'//android.widget.ScrollView/android.view.ViewGroup/android.view.ViewGroup[6]/android.widget.EditText')

    CHECK_BOX = (AppiumBy.ANDROID_UIAUTOMATOR,'new UiSelector().className("com.horcrux.svg.RectView")')

    CONTINUE_BUTTON = (AppiumBy.ACCESSIBILITY_ID,"Continue")

    CASUAL_NAME_ERROR_TEXT = (AppiumBy.XPATH,'(//android.widget.TextView[@text="You cannot include symbols or numbers"])[1]')
    LEGAL_NAME_ERROR_TEXT = (AppiumBy.XPATH,'(//android.widget.TextView[@text="You cannot include symbols or numbers"])[2]')
    EMAIL_ERROR_TEXT = (AppiumBy.XPATH,'//android.widget.TextView[@text="Invalid email"]')


    ENTER_OTP_TEXT = (AppiumBy.XPATH,'//android.widget.TextView[@text="Enter the 6-digit OTP *"]')

    ERROR_MESSAGE_OTP = (AppiumBy.ANDROID_UIAUTOMATOR,'new UiSelector().text("Incorrect OTP")')

#     SET PASSCODE SCREEN
    SET_PASSCODE_TEXT = (AppiumBy.XPATH, '//android.widget.TextView[@resource-id="setPasscodeText"]')

    CREATE_ACCOUNT_BUTTON = (AppiumBy.XPATH, '//android.view.ViewGroup[@content-desc="Create Account"]')

    ERROR_MESSAGE_PASSCODE = (AppiumBy.ANDROID_UIAUTOMATOR, 'new UiSelector().resourceId("setPasscodeErrorText")')

#     ALLOW NOTIFICATIONS SCREEN

    NOTIFICATION_TEXT = (AppiumBy.ANDROID_UIAUTOMATOR, 'new UiSelector().resourceId("enableNotificationsText")')

    ALLOW_NOTIFICATIONS_BUTTON = (AppiumBy.ANDROID_UIAUTOMATOR, 'new UiSelector().resourceId("enableNotificationsAllowButton")')

    NOT_NOW_BUTTON = (AppiumBy.ANDROID_UIAUTOMATOR,'new UiSelector().resourceId("enableNotificationsNotNowButton")')










