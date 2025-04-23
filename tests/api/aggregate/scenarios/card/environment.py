from behave.model import Scenario
from hugoutils.telemetry.logger import LogManager

from tests.api.aggregate.hugoserve_test import HugoserveTest

logger = LogManager.get_logger("Environment")


def before_scenario(context, scenario: Scenario):
    logger.info(f"Running test scenario: {scenario.name}")
    config_yaml_path = f"{context.config.base_dir}/../../config.yaml"
    context.request = HugoserveTest(config_yaml_path)
    config_data = context.request.params
    context.data = {
        "config_data": config_data
    }  # For sharing contextual data for each scenario


def after_scenario(context, scenario: Scenario) -> None:
    logger.info(
        f"Test {scenario.name} run completed with status: {scenario.status.name} in "
        f"{round(scenario.duration, 2)} seconds."
    )
