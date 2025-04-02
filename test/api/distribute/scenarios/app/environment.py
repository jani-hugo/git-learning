from test.api.distribute.hugosave_test import HugosaveTest
import time


def before_scenario(context, scenario):
    current_time = int(time.time())
    config_yaml_path = f"{context.config.base_dir}/../../config.yaml"
    context.request = HugosaveTest(config_yaml_path)
    config_data = context.request.params
    # For sharing contextual data for each scenario
    context.data = {"config_data": config_data}
    # Below are the details of a mocked device for testing purposes.
    context.data["device_info"] = {
        "os": "Android",
        "os-build-number": "UP1A.240305.008",
        "os-version": "14",
        "device-brand-name": "Google",
        "x-device-id": "455636",
        "device-type": "Phone",
        "app-first-install-time": str(current_time - 604800),  # One week ago
        "app-version": "4.2.0",
        "app-bundle-identifier": "com.example.myapp.latest",
        "app-build-version": "2025060901",
        "x-epoch": current_time,
    }
