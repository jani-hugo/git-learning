from appium.options.common import AppiumOptions
from appium.options.android import UiAutomator2Options
from appium.options.android import UiAutomator2Options
class dcaps:
    def __init__(self):
        # Initialize the Appium capabilities
        self.options = UiAutomator2Options()
        # Set the desired capabilities for the Appium session
        self.options.set_capability('platformName', 'Android')
        self.options.set_capability('automationName', 'UiAutomator2')
        self.options.set_capability('deviceName', 'PIXEL')  # Your device name
        self.options.set_capability('appPackage', 'com.hugosave.nonprod')  # Your app package
        self.options.set_capability('appActivity', 'com.hugosave.SplashActivity')  # Your app activity
        self.options.set_capability('autoGrantPermissions', True)
        # self.options.set_capability('appium:noReset', 'true')
        self.options.set_capability('udid', 'emulator-5554')

    def get_options(self):
        return self.options




































    # medium_phone_device_caps = {"platformName": "Android",
    #                 "automationName": "uiautomator2",
    #                 "deviceName": "Medium Phone API 35",  # Use the exact name from `adb devices -l`
    #                 "udid": "emulator-5556",  # Explicitly specify the unique device ID
    #                 "appPackage": "com.hugosave.nonprod",
    #                 "appActivity": "com.hugosave.SplashActivity",
    #                 "platformVersion": "15",
    #                 "language": "en",
    #                 "locale": "US",
    #                 "autoGrantPermissions": "true",
    #                 "ignoreHiddenApiPolicyError": True,
    #                 "unicodeKeyboard": True,  # Enables Unicode keyboard for input fields
    #                 "resetKeyboard": True,
    #                 'appium:noReset':'true'}