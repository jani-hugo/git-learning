from behave import *
from hugoutils.utilities.dataclass_util import DataClassParser

from tests.api.aggregate.core.core_dataclass import (
    CreateTransactionCode,
    FetchTransactionCode,
    FetchCoATransactionCode,
    UpdateTransactionCodes,
)
from tests.util.common_util import check_status

transaction_code_callback_url = "/core/v1/transaction-code"
header_customer_profile_id = "x-customer-profile-id"


@When("I try to create a transaction code")
def create_transaction_code_step(context):
    request = context.request
    create_transaction_code_list = DataClassParser.parse_rows(
        context.table.rows, data_class=CreateTransactionCode
    )

    context.data = {} if context.data is None else context.data
    for create_transaction_code in create_transaction_code_list:
        data = create_transaction_code.get_dict()
        status_code = data["status_code"]
        customer_profile_id = data["customer_profile_id"]
        response = request.hugoserve_post_request(
            path=f"{transaction_code_callback_url}",
            headers={header_customer_profile_id: customer_profile_id},
            data=data["requestDTO"],
        )
        check_status(response, status_code)


@When("I try to fetch all transaction codes")
def fetch_transaction_code_step(context):
    request = context.request
    fetch_transaction_code_list = DataClassParser.parse_rows(
        context.table.rows, data_class=FetchTransactionCode
    )

    context.data = {} if context.data is None else context.data
    for fetch_transaction_code in fetch_transaction_code_list:
        data = fetch_transaction_code.get_dict()
        status_code = data["status_code"]
        customer_profile_id = data["customer_profile_id"]
        response = request.hugoserve_get_request(
            path=f"{transaction_code_callback_url}",
            headers={header_customer_profile_id: customer_profile_id},
            params=data,
        )
        check_status(response, status_code)


@When("I try to fetch CoA Transaction Codes")
def fetch_coa_transaction_code_step(context):
    request = context.request
    fetch_coa_transaction_code_list = DataClassParser.parse_rows(
        context.table.rows, data_class=FetchCoATransactionCode
    )

    context.data = {} if context.data is None else context.data
    for fetch_coa_transaction_code in fetch_coa_transaction_code_list:
        data = fetch_coa_transaction_code.get_dict()
        status_code = data["status_code"]
        customer_profile_id = data["customer_profile_id"]
        response = request.hugoserve_get_request(
            path=f"{transaction_code_callback_url}/{data['txn-code']}",
            headers={header_customer_profile_id: customer_profile_id},
        )
        check_status(response, status_code)


@When("I try to map fetch a paginated response from the database")
def fetch_transaction_code_step(context):
    request = context.request
    fetch_transaction_code_list = DataClassParser.parse_rows(
        context.table.rows, data_class=FetchTransactionCode
    )

    context.data = {} if context.data is None else context.data
    for fetch_transaction_code in fetch_transaction_code_list:
        data = fetch_transaction_code.get_dict()
        customer_profile_id = data["customer_profile_id"]
        response = request.hugoserve_get_request(
            path=f"{transaction_code_callback_url}",
            headers={header_customer_profile_id: customer_profile_id},
            params=data,
        )

        if response["headers"]["status_code"] == 200:
            size = len(response["data"]["transaction_codes"])
            fetch_paginated_transaction_code_list = DataClassParser.parse_rows(
                context.table.rows, data_class=FetchTransactionCode
            )
            for (
                fetch_paginated_transaction_code
            ) in fetch_paginated_transaction_code_list:
                fetch_paginated_transaction_code["size"] = size if size > 1 else 1
                customer_profile_id = data["customer_profile_id"]
                response = request.hugoserve_get_request(
                    path=f"{transaction_code_callback_url}/list-txn-code",
                    headers={header_customer_profile_id: customer_profile_id},
                    params=data,
                )

                check_status(response, 200)


@When("I try to update CoA transaction Code")
def update_transaction_code_step(context):
    request = context.request
    update_transaction_code_list = DataClassParser.parse_rows(
        context.table.rows, data_class=UpdateTransactionCodes
    )

    context.data = {} if context.data is None else context.data
    for update_transaction_code in update_transaction_code_list:
        data = update_transaction_code.get_dict()
        status_code = data["status_code"]
        customer_profile_id = data["customer_profile_id"]
        response = request.hugoserve_put_request(
            path=f"{transaction_code_callback_url}/{data['txnCode']}",
            headers={header_customer_profile_id: customer_profile_id},
            data=data["transactionCodeDTO"],
        )
        check_status(response, status_code)
