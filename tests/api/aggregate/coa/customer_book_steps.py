from hugoutils.utilities.dataclass_util import DataClassParser

from tests.api.aggregate.coa import coa_helper
from tests.api.aggregate.coa.coa_dataclass import (
    CustomerBookDTO,
)

from behave import *

from tests.util.common_util import check_status

use_step_matcher("re")

customer_book_child_suffix = "-CUSTOMER_BOOK_CHILD_DATA"


def get_customer_book_info(context, code, customer_profile_id):
    request = context.request
    response = request.hugoserve_get_request(
        coa_helper.customer_book_urls["get_node_info"].replace("$book-code$", code),
        headers=coa_helper.get_headers(customer_profile_id),
    )
    check_status(response, "200")
    return response["data"]


def get_customer_book_code_info(context, parent_code, customer_profile_id):
    request = context.request

    response = request.hugoserve_get_request(
        coa_helper.customer_book_urls["compute_child_code"].replace(
            "$book-code$", parent_code
        ),
        headers=coa_helper.get_headers(customer_profile_id),
    )
    check_status(response, "200")
    return response["data"]


@Then("I create Customer Book node for customer")
def create_customer_book(context):
    request = context.request
    customer_book_request_list = DataClassParser.parse_rows(
        context.table.rows, data_class=CustomerBookDTO
    )
    for customer_book_request in customer_book_request_list:
        data = customer_book_request.get_dict()
        customer_profile_id = context.data["config_data"][data["customer_profile_id"]]
        data["customer_profile_id"] = customer_profile_id

        expected_data = get_customer_book_code_info(
            context, data["parent_cb_code"], data["customer_profile_id"]
        )
        expected_cb_code = expected_data["cb_code"]
        expected_cb_prefix = expected_data["cb_prefix"]
        expected_cb_level_number = expected_data["cb_level_number"]
        expected_cb_attribute_name = expected_data["cb_attribute_name"]
        expected_cb_attribute_value = data["cb_attribute_value"]

        response = request.hugoserve_post_request(
            coa_helper.customer_book_urls["create_customer_book"],
            data=data,
            headers=coa_helper.get_headers(customer_profile_id),
        )
        check_status(response, customer_book_request.status_code)

        actual_cb_code = response["data"]["cb_code"]
        actual_cb_prefix = response["data"]["cb_prefix"]
        actual_cb_level_number = response["data"]["cb_level_number"]
        actual_cb_attribute_name = response["data"]["cb_attribute_name"]
        actual_cb_attribute_value = response["data"]["cb_attribute_value"]

        coa_helper.assert_values(
            "Customer Book Node",
            customer_profile_id,
            (
                expected_cb_code,
                expected_cb_prefix,
                expected_cb_level_number,
                expected_cb_attribute_value,
                expected_cb_attribute_name,
            ),
            (
                actual_cb_code,
                actual_cb_prefix,
                actual_cb_level_number,
                actual_cb_attribute_value,
                actual_cb_attribute_name,
            ),
        )
