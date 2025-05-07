import os
import subprocess
import shutil
import datetime

# -------------------- Paths & Setup --------------------
BASE_DIR = os.path.dirname(os.path.dirname(__file__))
FEATURES_DIR = os.path.join(BASE_DIR, "features")
ALLURE_RAW_DIR = os.path.join(BASE_DIR, "reports", "allure_raw")
ALLURE_REPORT_DIR = os.path.join(BASE_DIR, "reports", "allure_report")
MERGED_RAW_DIR = os.path.join(ALLURE_RAW_DIR, 'merged_raw')

FEATURES_IN_ORDER = [
    "whole_onboarding.feature"
    # "payee.feature",
]

# Scenario filters: key = feature name, value = scenario name or None to run all
FEATURE_SCENARIOS = {
    "whole_onboarding.feature": 'onboard to cash account dashboard'  # Run all scenarios
    # "payee.feature": "END TO END",  # Run only this scenario
}

# -------------------- Utility --------------------
def clean_directory(path):
    """Delete all contents of a directory without deleting the directory itself."""
    if os.path.exists(path):
        for filename in os.listdir(path):
            file_path = os.path.join(path, filename)
            try:
                if os.path.isfile(file_path) or os.path.islink(file_path):
                    os.unlink(file_path)
                elif os.path.isdir(file_path):
                    shutil.rmtree(file_path)
            except Exception as e:
                print(f"[Error] Failed to delete {file_path}. Reason: {e}")

# -------------------- Prepare Directories --------------------
clean_directory(ALLURE_REPORT_DIR)

# If ALLURE_RAW_DIR exists, just delete it entirely
if os.path.exists(ALLURE_RAW_DIR):
    shutil.rmtree(ALLURE_RAW_DIR)

# Create necessary folders
os.makedirs(MERGED_RAW_DIR, exist_ok=True)
os.makedirs(ALLURE_REPORT_DIR, exist_ok=True)

# Timestamp for unique naming
timestamp = datetime.datetime.now().strftime("%Y-%m-%d_%H-%M-%S")

# -------------------- Run Each Feature --------------------
for feature in FEATURES_IN_ORDER:
    feature_name = os.path.splitext(feature)[0]
    feature_path = os.path.join(FEATURES_DIR, feature)
    raw_dir = os.path.join(ALLURE_RAW_DIR, f'{feature_name}_raw_{timestamp}')
    os.makedirs(raw_dir, exist_ok=True)

    print(f"\n➡️  Running: {feature_name}")

    # Base behave command
    command = [
        "behave",
        "-f", "allure_behave.formatter:AllureFormatter",
        "-o", raw_dir,
    ]

    scenario_filter = FEATURE_SCENARIOS.get(feature)
    if scenario_filter:
        command.extend(["--name", scenario_filter])

    command.append(feature_path)

    subprocess.run(command)

#     individual_report_dir = os.path.join(ALLURE_REPORT_DIR, f"{feature_name}_{timestamp}")
#     subprocess.run([
#         "allure", "generate", raw_dir, "-o", individual_report_dir, "--clean"
#     ])
#
#     print(f"✅ Individual report generated: {individual_report_dir}")
#
#     # Copy raw results to merged_raw
#     for file in os.listdir(raw_dir):
#         shutil.copy(os.path.join(raw_dir, file), MERGED_RAW_DIR)
#
# # -------------------- Generate Final Merged Report --------------------
# merged_report_dir = os.path.join(ALLURE_REPORT_DIR, f"All_Features_{timestamp}")
# subprocess.run([
#     "allure", "generate", MERGED_RAW_DIR, "-o", merged_report_dir, "--clean"
# ])
#
# print(f"\n✅✅ Merged report generated: {merged_report_dir}")
#
# # -------------------- Open Final Merged Report --------------------
# subprocess.run(["allure", "open", merged_report_dir])
#


# DEDEDEEDEDEDE

