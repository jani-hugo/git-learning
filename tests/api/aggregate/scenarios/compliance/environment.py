from tests.api.aggregate.hugoserve_test import HugoserveTest


def before_scenario(context, scenario):
    config_yaml_path = f"{context.config.base_dir}/../../config.yaml"
    context.request = HugoserveTest(config_yaml_path)
    config_data = context.request.params
    context.data = {
        "config_data": config_data
    }  # For sharing contextual data for each scenario
