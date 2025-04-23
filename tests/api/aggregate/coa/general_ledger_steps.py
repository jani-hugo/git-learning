from behave import *
from hugoutils.utilities.dataclass_util import DataClassParser

from tests.api.aggregate.coa import coa_helper
from tests.api.aggregate.coa.coa_dataclass import (
    GeneralLedgerDTO,
)
from tests.util.common_util import check_status

use_step_matcher("re")

general_ledger_child_suffix = "GL_CHILD_DATA"


def get_general_ledger_info(context, code, customer_id):
    request = context.request
    customer_profile_id = context.data["config_data"][customer_id]

    response = request.hugoserve_get_request(
        coa_helper.general_ledger_urls["get_node_info"].replace("$book-code$", code),
        headers=coa_helper.get_headers(customer_profile_id),
    )
    check_status(response, "200")
    return response["data"]


def get_general_ledger_code_info(context, parent_code, customer_profile_id):
    request = context.request
    response = request.hugoserve_get_request(
        coa_helper.general_ledger_urls["compute_child_code"].replace(
            "$book-code$", parent_code
        ),
        headers=coa_helper.get_headers(customer_profile_id),
    )
    check_status(response, "200")
    return response["data"]


@Then("I create General Ledger node for customer")
def create_general_ledger(context):
    request = context.request
    general_ledger_request_list = DataClassParser.parse_rows(
        context.table.rows, data_class=GeneralLedgerDTO
    )
    for general_ledger_request in general_ledger_request_list:
        data = general_ledger_request.get_dict()
        customer_profile_id = context.data["config_data"][data["customer_profile_id"]]
        data["customer_profile_id"] = customer_profile_id

        expected_data = get_general_ledger_code_info(
            context, data["parent_gl_code"], data["customer_profile_id"]
        )
        expected_gl_code = expected_data["gl_code"]
        expected_gl_prefix = expected_data["gl_prefix"]
        expected_gl_level_number = expected_data["gl_level_number"]
        expected_gl_type = data["gl_type"]
        expected_gl_name = data["gl_name"]
        expected_gl_description = data["gl_description"]

        response = request.hugoserve_post_request(
            coa_helper.general_ledger_urls["create_general_ledger"],
            data=data,
            headers=coa_helper.get_headers(customer_profile_id),
        )
        check_status(response, general_ledger_request.status_code)

        actual_gl_code = response["data"]["gl_code"]
        actual_gl_prefix = response["data"]["gl_prefix"]
        actual_gl_level_number = response["data"]["gl_level_number"]
        actual_gl_type = response["data"]["gl_type"]
        actual_gl_name = response["data"]["gl_name"]
        actual_gl_description = response["data"]["gl_description"]

        coa_helper.assert_values(
            "General Ledger Node",
            customer_profile_id,
            (
                expected_gl_code,
                expected_gl_prefix,
                expected_gl_level_number,
                expected_gl_type,
                expected_gl_name,
                expected_gl_description,
            ),
            (
                actual_gl_code,
                actual_gl_prefix,
                actual_gl_level_number,
                actual_gl_type,
                actual_gl_name,
                actual_gl_description,
            ),
        )
