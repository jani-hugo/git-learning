from tests.api.distribute.hugosave_test import HugosaveTest


def before_scenario(context, scenario):
    config_yaml_path = f"{context.config.base_dir}/../../config.yaml"
    context.request = HugosaveTest(config_yaml_path)
    config_data = context.request.params
    context.data = {
        "config_data": config_data
    }  # For sharing contextual data for each scenario
