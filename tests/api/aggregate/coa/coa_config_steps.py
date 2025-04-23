from hugoutils.utilities.dataclass_util import DataClassParser

from tests.api.aggregate.coa import coa_helper
from tests.api.aggregate.coa.coa_dataclass import OnboardRequestDTO, LevelConfigDTO

from behave import *
import uuid

from tests.util.common_util import check_status

use_step_matcher("re")


@Given("I onboard Customer to Chart of Accounts")
def onboard_customer(context):
    request = context.request
    onboard_customer_request_list = DataClassParser.parse_rows(
        context.table.rows, data_class=OnboardRequestDTO
    )
    context.data = {} if context.data is None else context.data
    customer_profile_id = str(uuid.uuid4())
    for onboard_customer_request in onboard_customer_request_list:
        data = onboard_customer_request.get_dict()
        context.data["config_data"][data["customer_profile_id"]] = customer_profile_id
        data["customer_profile_id"] = customer_profile_id

        if data["node_type"] == "CUSTOMER_BOOK":
            response = request.hugoserve_post_request(
                coa_helper.customer_book_urls["onboard_customer"],
                data=data,
                headers=coa_helper.get_headers(customer_profile_id),
            )
        else:
            response = request.hugoserve_post_request(
                coa_helper.general_ledger_urls["onboard_customer"],
                data=data,
                headers=coa_helper.get_headers(customer_profile_id),
            )
        check_status(response, onboard_customer_request.status_code)

        if onboard_customer_request.status_code == "200":
            expected_root_code = "0" * data["node_code_length"]
            actual_root_code = response["data"]["node_code"]
            coa_helper.assert_values(
                "Root node Code",
                customer_profile_id,
                expected_root_code,
                actual_root_code,
            )
        else:
            coa_helper.assert_values(
                "Onboard error status",
                customer_profile_id,
                onboard_customer_request.status_code,
                coa_helper.status_codes[response["headers"]["message"]],
            )


@Then("I set the level config for the Chart of Account Nodes for customer")
def set_level_config(context):
    request = context.request
    level_config_request_list = DataClassParser.parse_rows(
        context.table.rows, data_class=LevelConfigDTO
    )
    for level_config_request in level_config_request_list:
        data = level_config_request.get_dict()
        if data["customer_profile_id"] in context.data["config_data"]:
            customer_profile_id = context.data["config_data"][
                data["customer_profile_id"]
            ]
        else:
            customer_profile_id = str(uuid.uuid4())
        data["customer_profile_id"] = customer_profile_id

        if data["node_type"] == "CUSTOMER_BOOK":
            response = request.hugoserve_post_request(
                coa_helper.customer_book_urls["level_config"],
                data=data,
                headers=coa_helper.get_headers(customer_profile_id),
            )
        else:
            response = request.hugoserve_post_request(
                coa_helper.general_ledger_urls["level_config"],
                data=data,
                headers=coa_helper.get_headers(customer_profile_id),
            )
        check_status(response, level_config_request.status_code)

        if level_config_request.status_code == "200":
            coa_helper.assert_values(
                "Level Config",
                customer_profile_id,
                data["level_config"],
                response["data"]["level_config"],
            )
        else:
            coa_helper.assert_values(
                "Level config error",
                customer_profile_id,
                level_config_request.status_code,
                coa_helper.status_codes[response["headers"]["message"]],
            )
