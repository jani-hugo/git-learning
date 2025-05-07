from typing import Any, Dict
from appium.options.common import AppiumOptions
from appium import webdriver
from Automation.sg_automation.caps.capabilities import dcaps
from selenium.webdriver.support.ui import WebDriverWait
import os
import allure
import subprocess
import shutil

# Get base directory of the project
BASE_DIR =os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ALLURE_RAW_DIR = os.path.join(BASE_DIR, "reports", "allure_raw")
ALLURE_REPORT_DIR = os.path.join(BASE_DIR, "reports", "allure_report")
SCREENSHOT_DIR = os.path.join(BASE_DIR, "screenshots")


def clear_app_cache():
    subprocess.run(["adb", "shell", "pm", "clear", "com.hugosave.nonprod"], check=True)


def before_all(context):
    """Called once before all feature files."""
    # dcaps_instance = dcaps()
    # options = dcaps_instance.get_options()
    # url = 'http://127.0.0.1:4723'
    # context.driver = webdriver.Remote(url, options=options)
    # # Clean up raw allure results from last run
    # os.makedirs(ALLURE_RAW_DIR, exist_ok=True)
    # for f in os.listdir(ALLURE_RAW_DIR):
    #     if f.endswith(".json"):
    #         os.remove(os.path.join(ALLURE_RAW_DIR, f))


def before_feature(context, feature):
   """Called before each feature starts."""
   context.feature_name = feature.name.replace(" ", "_")


def before_scenario(context, scenario):
    """Called before each scenario."""
    # context.scenario_name = scenario.name.replace(" ", "_")
    dcaps_instance = dcaps()
    options = dcaps_instance.get_options()
    url = 'http://127.0.0.1:4723'
        # 'http://localhost:4444/wd/hub'
    context.driver = webdriver.Remote(url, options=options)
    # Clean up raw allure results from last run
    os.makedirs(ALLURE_RAW_DIR, exist_ok=True)
    for f in os.listdir(ALLURE_RAW_DIR):
        if f.endswith(".json"):
            os.remove(os.path.join(ALLURE_RAW_DIR, f))

def after_scenario(context, scenario):
    context.driver.quit()


def after_step(context, step):
    """Called after each step. Take screenshot if step fails."""
    if step.status == "failed":
        print(BASE_DIR)
        print(ALLURE_RAW_DIR)
        print(ALLURE_REPORT_DIR)
        feature_name = context.feature.name.replace(" ", "_")
        scenario_name = context.scenario.name.replace(" ", "_")
        step_name = step.name.replace(" ", "_")
        screenshot_name = f"{feature_name}_{scenario_name}_{step_name}.png"
        screenshot_path = os.path.join(SCREENSHOT_DIR, screenshot_name)

        try:
            if not os.path.exists(SCREENSHOT_DIR):
                os.makedirs(SCREENSHOT_DIR)
                print("created directory ", SCREENSHOT_DIR)

            context.driver.save_screenshot(screenshot_path)
            print(f"[Screenshot saved] {screenshot_path}")

            # Attach screenshot to Allure report
            with open(screenshot_path, "rb") as file:
                allure.attach(file.read(), name=screenshot_name, attachment_type=allure.attachment_type.PNG)

        except Exception as e:
            print(f"[Screenshot failed] Could not save screenshot: {e}")


def after_all(context):
    """Called after each scenario."""
    pass






