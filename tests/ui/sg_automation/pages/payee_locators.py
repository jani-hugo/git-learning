from appium.webdriver.common.appiumby import AppiumBy
from selenium.webdriver.common.by import By  # If you need By locators


class PayeeLocators:
    """Locators for the Payee module."""
    ADD_PAYEE_BUTTON = (AppiumBy.ANDROID_UIAUTOMATOR,'new UiSelector().resourceId("addPayeeButton")')

    ADD_NEW_PAYEE_TEXT = (AppiumBy.ANDROID_UIAUTOMATOR, 'new UiSelector().resourceId("addPayeeText")')

    FAVOURITE_TEXT = (AppiumBy.ANDROID_UIAUTOMATOR, 'new UiSelector().text("Favourite")')

    PAYEE_TEXT = (AppiumBy.ANDROID_UIAUTOMATOR, 'new UiSelector().text("Payee Name")')

    AS_ON_THEIR_BANK_TEXT = (AppiumBy.ANDROID_UIAUTOMATOR, 'new UiSelector().resourceId("bankAccountText")')

    BANK_NAME_TEXT = (AppiumBy.ANDROID_UIAUTOMATOR, 'new UiSelector().text("Bank Name")')

    ACCOUNT_NUMBER_TEXT = (AppiumBy.ANDROID_UIAUTOMATOR, 'new UiSelector().text("Account No.")')

    CONFIRM_BUTTON = (AppiumBy.ANDROID_UIAUTOMATOR, 'new UiSelector().resourceId("confirmButton")')

    PAYEE_NAME_INPUT_FIELD = (AppiumBy.ANDROID_UIAUTOMATOR, 'new UiSelector().resourceId("payeeName")')

    ACCOUNT_NUMBER_FIELD = (AppiumBy.ANDROID_UIAUTOMATOR, 'new UiSelector().resourceId("accountNumber")')

    OTP_SCREEN_TEXT =  (AppiumBy.ANDROID_UIAUTOMATOR, 'new UiSelector().resourceId("enterOTPText")')

    INCORRECT_OTP_TEXT = (AppiumBy.ANDROID_UIAUTOMATOR, 'new UiSelector().resourceId("incorrectOtpText")')

    RESEND_OTP_BUTTON =  (AppiumBy.ANDROID_UIAUTOMATOR, 'new UiSelector().resourceId("resendOTPButton")')

    # payee individual screen
    PAYEE_ACCOUNT_NUMBER_ON_PAYEE_SCREEN = (AppiumBy.ANDROID_UIAUTOMATOR, 'new UiSelector().resourceId("payeeAccount")')

    PAYEE_PAYEE_NAME_ON_PAYEE_SCREEN = (AppiumBy.ANDROID_UIAUTOMATOR, f'new UiSelector().resourceId("payeeName")')

    NEW_PAYMENT_BUTTON = (AppiumBy.ANDROID_UIAUTOMATOR, 'new UiSelector().resourceId("newPaymentButton")')

    ALL_PAYEES_TEXT = (AppiumBy.ANDROID_UIAUTOMATOR, 'new UiSelector().resourceId("allPayeesText")')

#     payee edit screen
    SAVE_BUTTON = (AppiumBy.ANDROID_UIAUTOMATOR, 'new UiSelector().resourceId("save")')

#     NEW PAYMENT SCREEN
    NEW_PAYMENT_SCREEN = (AppiumBy.ANDROID_UIAUTOMATOR, 'new UiSelector().text("New Payment")')

    ACCOUNT_NUMBER_NEW_PAYMENT_SCREEN =(AppiumBy.ANDROID_UIAUTOMATOR, f'new UiSelector().resourceId("payeeAccount")')

    PAYEE_NAME_NEW_PAYMENT_SCREEN = (AppiumBy.ANDROID_UIAUTOMATOR, f'new UiSelector().resourceId("payeeName")')
    # ------------------------------------------------------------
    CANCEL_BUTTON = (AppiumBy.ANDROID_UIAUTOMATOR, 'new UiSelector().resourceId("cancel")')

    PREVIEW_BUTTON = (AppiumBy.ANDROID_UIAUTOMATOR, 'new UiSelector().resourceId("save")')

    PAYEMNT_INPUT_FIELD = (AppiumBy.ANDROID_UIAUTOMATOR, 'new UiSelector().resourceId("paymentInput")')

#     PREVIEW SCREEN

    ACCOUNT_NUMBER_NEW_PAYMENT_PREVIEW_SCREEN = (AppiumBy.ANDROID_UIAUTOMATOR, f'new UiSelector().resourceId("payeeAccount")')

    PAYEE_NAME_NEW_PAYMENT_PREVIEW_SCREEN = (AppiumBy.ANDROID_UIAUTOMATOR, f'new UiSelector().resourceId("payeeName")')

    PAY_BUTTON = (AppiumBy.ANDROID_UIAUTOMATOR, 'new UiSelector().resourceId("newPaymentButton")')



















