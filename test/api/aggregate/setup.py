import json
import logging
import os
import sys
from pathlib import Path

import requests
import yaml
from products.scripts.product_config import Product, ProductConfig
from scripts.setups.stack_details import StackDetails

logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)

default_headers = {
    "Content-Type": "application/json",
    "Accept": "application/json",
}


class SetupConfig:
    def __init__(self, stack_name):
        path = Path(os.path.abspath(__file__)).parent
        self.config_file = os.path.join(path, "config.yaml")

        self.backend_path = Path(os.path.abspath(__file__)).parent.parent.parent.parent
        self.product_config = ProductConfig(
            Product.HUGOHUB_SG, stack_name, self.backend_path
        )
        self.aggregate_endpoint = self.product_config.get_host()
        self.param_store_api = StackDetails(self.product_config).get_param_store_api()

    def run(self):
        hugosave_config = json.loads(
            self.param_store_api.get_parameter_value("/tests/hugosave", {})
        )
        silverbullion_config = json.loads(
            self.param_store_api.get_parameter_value("/tests/silverbullion", {})
        )
        hugobank_config = json.loads(
            self.param_store_api.get_parameter_value("/tests/hugobank", {})
        )

        config = {
            "AGGREGATE_ENDPOINT": self.aggregate_endpoint,
            "customer_id": hugosave_config["profile"]["customer_id"],
            "customer_profile_id": hugosave_config["profile"]["customer_profile_id"],
            # Values for payment
            "customer_id_2": silverbullion_config["profile"]["customer_id"],
            "customer_profile_id_2": silverbullion_config["profile"][
                "customer_profile_id"
            ],
            # Values for card
            "card_config_id": hugosave_config["card"]["design"]["GREEN_C9"][
                "design_config_id"
            ],
            "card_account_product_id": hugosave_config["card"]["product"]["C9_DEB_CA"][
                "product_id"
            ],
            "card_product_id": hugosave_config["card"]["product"]["C9_DEBIT"][
                "product_id"
            ],
            "sg_customer_profile_id": hugosave_config["profile"]["customer_profile_id"],
            "clowd9_card_config_id": hugosave_config["card"]["design"]["GREEN_C9"][
                "design_config_id"
            ],
            "clowd9_card_account_product_id": hugosave_config["card"]["product"][
                "C9_DEB_CA"
            ]["product_id"],
            "clowd9_card_product_id": hugosave_config["card"]["product"]["C9_DEBIT"][
                "product_id"
            ],
            # Change these to create another customer
            "pk_customer_profile_id": hugobank_config["profile"]["customer_profile_id"],
            "nymcard_card_config_id": hugobank_config["card"]["design"]["GREEN_NC"][
                "design_config_id"
            ],
            "nymcard_card_account_product_id": hugobank_config["card"]["product"][
                "NC_DEB_CA"
            ]["product_id"],
            "nymcard_card_product_id": hugobank_config["card"]["product"]["NC_DEBIT"][
                "product_id"
            ],
        }
        with open(self.config_file, "w+") as file:
            file.write(yaml.dump(config, default_flow_style=False, sort_keys=False))

        # self.__top_up_card_float_accounts(config)


if __name__ == "__main__":
    usage = "python3 tests/integrations/aggregate/setup.py <stack_name>"
    if len(sys.argv) != 2:
        print(usage)
        exit(1)

    stack_name = sys.argv[1]

    SetupConfig(stack_name).run()
