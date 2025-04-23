import random
import decimal
import uuid

from hugoutils.utilities.dataclass_util import DataClassParser

from tests.api.aggregate.payment import helper as payment_helper
from tests.api.aggregate.payment.payment_dataclass import (
    CreditAdviseRequest,
    CreditPostingRequest,
)
from behave import *
from retry import retry
from datetime import datetime

from tests.api.aggregate.payment.payment_dataclass import CreditInquiryRequest

use_step_matcher("re")


@Given(
    "I deposit an amount of ([^']*) into account ([^']*) using CreditPosting for customerProfileId ([^']*)"
)
def deposit_using_credit_posting(
    context,
    amount: decimal,
    account_identifier: str,
    customer_profile_identifier: str,
):
    payment_helper.__validate_provider("PAYSYS")

    payment_account_id = context.data[account_identifier]["account_id"]
    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id

    account_details = payment_helper.__fetch_payment_account(
        customer_profile_id, context, payment_account_id
    )
    request = context.request
    response = request.hugoserve_get_request(
        path=f"/payment/v1/account/{payment_account_id}",
        headers=payment_helper.__get_default_payment_headers(
            customer_profile_id, request_origin="CASH_SERVICE"
        ),
    )
    master_account_id = response["data"]["master_account_id"]
    response = request.hugoserve_get_request(
        path=f"/payment/v1/account/master-account/{master_account_id}/balance",
        headers=payment_helper.__get_default_payment_headers(
            customer_profile_id, request_origin="CASH_SERVICE"
        ),
    )

    assert (
        "data" in response
    ), f"\nExpected non empty data object, found empty. Response:{response}"

    initial_total_balance = response["data"]["total_balance"]
    initial_available_balance = response["data"]["available_balance"]

    context.data["initial_total_balance_" + master_account_id] = initial_total_balance
    context.data["initial_available_balance_" + master_account_id] = (
        initial_available_balance
    )

    credit_posting_request_dto = DataClassParser.parse_row(
        context.table.rows[0], CreditPostingRequest
    )

    credit_posting_request_dto.txn_info.receiverinfo.to_account = (
        account_details.account_details.code_details.pk_code_details.account_number
    )
    credit_posting_request_dto.txn_info.payment_info.amount = amount
    customer_profile_id = credit_posting_request_dto.customer_profile_id
    current_date_time = datetime.now()
    credit_posting_request_dto.txn_info.info.rrn = random.randint(10**11, 10**12 - 1)
    credit_posting_request_dto.txn_info.info.stan = current_date_time.strftime("%H%M%S")
    credit_posting_request_dto.txn_info.info.txndate = current_date_time.strftime(
        "%Y%m%d"
    )
    credit_posting_request_dto.txn_info.info.txntime = current_date_time.strftime(
        "%H%M%S"
    )
    credit_posting_request_dto.txn_info.payment_info.msg_id = str(uuid.uuid4())[:-1]

    response = request.hugoserve_post_request(
        path=f"/payment/paysys/pk/transaction/credit/posting",
        data=credit_posting_request_dto.txn_info.get_dict(),
        headers=payment_helper.__get_default_payment_headers(customer_profile_id),
    )
    assert response["response"]["response_code"] == "200"

    context.data[credit_posting_request_dto.identifier] = credit_posting_request_dto


@Given(
    "I deposit an amount of ([^']*) into master account ([^']*) using CreditPosting for customerProfileId ([^']*)"
)
def deposit_using_credit_posting_master_account(
    context, amount: decimal, account_identifier: str, customer_profile_identifier: str
):
    payment_helper.__validate_provider("PAYSYS")

    master_account_id = context.data[account_identifier]["master_account_id"]
    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id

    account_details = payment_helper.__fetch_master_account(
        customer_profile_id, context, master_account_id
    )
    request = context.request

    response = request.hugoserve_get_request(
        path=f"/payment/v1/account/master-account/{master_account_id}/balance",
        headers=payment_helper.__get_default_payment_headers(
            customer_profile_id, request_origin="CASH_SERVICE"
        ),
    )
    assert (
        "data" in response
    ), f"\nExpected non empty data object, found empty. Response:{response}"

    initial_total_balance = response["data"]["total_balance"]
    initial_available_balance = response["data"]["available_balance"]

    context.data["initial_total_balance_" + master_account_id] = initial_total_balance
    context.data["initial_available_balance_" + master_account_id] = (
        initial_available_balance
    )

    credit_posting_request_dto = DataClassParser.parse_row(
        context.table.rows[0], CreditPostingRequest
    )

    credit_posting_request_dto.txn_info.receiverinfo.to_account = (
        account_details.account_details.code_details.pk_code_details.iban
    )
    credit_posting_request_dto.txn_info.receiverinfo.to_account_title = "HUGOBANK"
    credit_posting_request_dto.txn_info.payment_info.amount = amount
    customer_profile_id = credit_posting_request_dto.customer_profile_id
    current_date_time = datetime.now()
    credit_posting_request_dto.txn_info.info.rrn = random.randint(10**11, 10**12 - 1)
    credit_posting_request_dto.txn_info.info.stan = current_date_time.strftime("%H%M%S")
    credit_posting_request_dto.txn_info.info.txndate = current_date_time.strftime(
        "%Y%m%d"
    )
    credit_posting_request_dto.txn_info.info.txntime = current_date_time.strftime(
        "%H%M%S"
    )
    credit_posting_request_dto.txn_info.payment_info.msg_id = str(uuid.uuid4())[:-1]

    response = request.hugoserve_post_request(
        path=f"/payment/paysys/pk/transaction/credit/posting",
        data=credit_posting_request_dto.txn_info.get_dict(),
        headers=payment_helper.__get_default_payment_headers(customer_profile_id),
    )
    assert response["response"]["response_code"] == "200"


@Given(
    "I initiate a creditInquiry request to get the status of the credit ([^']*) that is processed successfully"
)
def credit_inquiry(context, credit_identifier: str):
    payment_helper.__validate_provider("PAYSYS")

    org_credit_info = context.data[credit_identifier].txn_info.info

    credit_inquiry_request_dto = DataClassParser.parse_row(
        context.table.rows[0], CreditInquiryRequest
    )

    current_date_time = datetime.now()
    credit_inquiry_request_dto.txn_info.info.rrn = random.randint(10**11, 10**12 - 1)
    credit_inquiry_request_dto.txn_info.info.stan = current_date_time.strftime("%H%M%S")
    credit_inquiry_request_dto.txn_info.info.txndate = current_date_time.strftime(
        "%Y%m%d"
    )
    credit_inquiry_request_dto.txn_info.info.txntime = current_date_time.strftime(
        "%H%M%S"
    )
    credit_inquiry_request_dto.txn_info.orgTxnInfo.orgtxnrrn = org_credit_info.rrn
    credit_inquiry_request_dto.txn_info.orgTxnInfo.orgtxnstan = org_credit_info.stan
    credit_inquiry_request_dto.txn_info.orgTxnInfo.orgtxndate = org_credit_info.txndate
    credit_inquiry_request_dto.txn_info.orgTxnInfo.orgtxntime = org_credit_info.txntime

    request = context.request
    response = request.hugoserve_post_request(
        path=f"/payment/paysys/pk/inquiry/credit",
        data=credit_inquiry_request_dto.txn_info.get_dict(),
    )

    assert response["response"]["response_code"] == "200"


# @Given(
#     "I deposit an amount of ([^']*) into account ([^']*) using Credit Advise for customerProfileId ([^']*)"
# )
# def deposit_using_credit_advise(
#         context, amount: decimal, account_identifier: str, customer_profile_identifier: str
# ):
#     payment_helper.__validate_provider("PAYSYS")
#
#     payment_account_id = context.data[account_identifier]['account_id']
#     customer_profile_id = context.data[customer_profile_identifier].customer_profile_id
#
#     account_details = payment_helper.__fetch_payment_account(
#         customer_profile_id, context, payment_account_id
#     )
#     request = context.request
#
#     response = request.hugoserve_get_request(
#         path=f"/payment/v1/account/{payment_account_id}",
#         headers=payment_helper.__get_default_payment_headers(
#             customer_profile_id, request_origin='CASH_SERVICE'
#         ),
#     )
#     master_account_id = response['data']['master_account_id']
#     response = request.hugoserve_get_request(
#         path=f"/payment/v1/account/master-account/{master_account_id}/balance",
#         headers=payment_helper.__get_default_payment_headers(
#             customer_profile_id, request_origin='CASH_SERVICE'
#         ),
#     )
#     assert (
#             "data" in response
#     ), f"\nExpected non empty data object, found empty. Response:{response}"
#
#     initial_total_balance = response["data"]["total_balance"]
#     initial_available_balance = response["data"]["available_balance"]
#
#     context.data["initial_total_balance_" + master_account_id] = initial_total_balance
#     context.data["initial_available_balance_" + master_account_id] = initial_available_balance
#
#     credit_advise_request_dto = DataClassParser.parse_row(
#         context.table.rows[0], CreditAdviseRequest
#     )
#
#     credit_advise_request_dto.receiver_info.to_account = (
#         account_details.account_details.account_number
#     )
#     credit_advise_request_dto.payment_info.amount = amount
#     customer_profile_id = credit_advise_request_dto.customer_profile_id
#     current_date_time = datetime.now()
#     credit_advise_request_dto.info.rrn = random.randint(10**11, 10**12 - 1)
#     credit_advise_request_dto.info.stan = current_date_time.strftime('%H%M%S')
#     credit_advise_request_dto.info.txndate = current_date_time.strftime('%Y%m%d')
#     credit_advise_request_dto.info.txntime = current_date_time.strftime('%H%M%S')
#
#     response = request.hugoserve_post_request(
#         path=f"/payment/paysys/pk/transaction/credit/advise",
#         data=credit_advise_request_dto.get_dict(),
#         headers=payment_helper.__get_default_payment_headers(customer_profile_id),
#     )
#     assert response["body"]["response"]["responseCode"] == "0000"
#
#
#
#
# @Given(
#     "I deposit an amount of ([^']*) into master account ([^']*) using Credit Advise for customerProfileId ([^']*)"
# )
# def deposit_using_credit_advise_master_account(
#         context, amount: decimal, account_identifier: str, customer_profile_identifier: str
# ):
#     payment_helper.__validate_provider("PAYSYS")
#
#     master_account_id = context.data[account_identifier]['master_account_id']
#     customer_profile_id = context.data[customer_profile_identifier].customer_profile_id
#
#     account_details = payment_helper.__fetch_master_account(
#         customer_profile_id, context, master_account_id
#     )
#     request = context.request
#
#     response = request.hugoserve_get_request(
#         path=f"/payment/v1/account/master-account/{master_account_id}/balance",
#         headers=payment_helper.__get_default_payment_headers(
#             customer_profile_id, request_origin='CASH_SERVICE'
#         ),
#     )
#     assert (
#             "data" in response
#     ), f"\nExpected non empty data object, found empty. Response:{response}"
#
#     initial_total_balance = response["data"]["total_balance"]
#     initial_available_balance = response["data"]["available_balance"]
#
#     context.data["initial_total_balance_" + master_account_id] = initial_total_balance
#     context.data["initial_available_balance_" + master_account_id] = initial_available_balance
#
#     credit_advise_request_dto = DataClassParser.parse_row(
#         context.table.rows[0], CreditAdviseRequest
#     )
#
#     credit_advise_request_dto.txn_info.receiverinfo.to_account = (
#         account_details.account_details.code_details.pk_code_details.account_number
#     )
#     credit_advise_request_dto.txn_info.payment_info.amount = amount
#     customer_profile_id = credit_advise_request_dto.customer_profile_id
#     current_date_time = datetime.now()
#     credit_advise_request_dto.txn_info.info.rrn = random.randint(10**11, 10**12 - 1)
#     credit_advise_request_dto.txn_info.info.stan = current_date_time.strftime('%H%M%S')
#     credit_advise_request_dto.txn_info.info.txndate = current_date_time.strftime('%Y%m%d')
#     credit_advise_request_dto.txn_info.info.txntime = current_date_time.strftime('%H%M%S')
#     credit_advise_request_dto.txn_info.payment_info.msg_id = str(uuid.uuid4())[:-1]
#
#     response = request.hugoserve_post_request(
#         path=f"/payment/paysys/pk/transaction/credit/posting",
#         data=credit_advise_request_dto.txn_info.get_dict(),
#         headers=payment_helper.__get_default_payment_headers(customer_profile_id),
#     )
#     assert response['response']['response_code']== "0000"


@Then(
    "I wait until max time to verify master  account ([^']*) with an increased updated balance of ([^']*) for customerProfileId ([^']*) in Paysys"
)
def verify_master_account_balance(
    context, identifier, amount, customer_profile_identifier
):
    request = context.request
    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id

    payment_account_id = context.data[identifier]["account_id"]
    response = request.hugoserve_get_request(
        path=f"/payment/v1/account/{payment_account_id}",
        headers=payment_helper.__get_default_payment_headers(
            customer_profile_id, request_origin="CASH_SERVICE"
        ),
    )
    master_account_id = response["data"]["master_account_id"]
    request.hugoserve_get_request(
        path=f"/payment/v1/account/master-account/{master_account_id}/balance",
        headers=payment_helper.__get_default_payment_headers(
            customer_profile_id, request_origin="CASH_SERVICE"
        ),
    )
    expected_total_balance = float(
        context.data["initial_total_balance_" + master_account_id]
    ) + float(amount)
    expected_available_balance = float(
        context.data["initial_available_balance_" + master_account_id]
    ) + float(amount)

    @retry(
        AssertionError,
        tries=payment_helper.payment_providers_config["PAYSYS"]["max_wait_time"] / 5,
        delay=20,
        logger=None,
    )
    def retry_for_payment_account_status():
        response = request.hugoserve_get_request(
            path=f"/payment/v1/account/master-account/{master_account_id}/balance",
            headers=payment_helper.__get_default_payment_headers(
                customer_profile_id, request_origin="CASH_SERVICE"
            ),
        )
        assert (
            "data" in response
        ), f"\nExpected non empty data object, found empty. Response:{response}"

        actual_total_balance = response["data"]["total_balance"]
        actual_available_balance = response["data"]["available_balance"]

        assert expected_total_balance == actual_total_balance, (
            f"\nExpect total_balance: {expected_total_balance}"
            f"\nActual total_balance: {actual_total_balance}"
        )
        assert expected_available_balance == actual_available_balance, (
            f"\nExpect available_balance: {expected_available_balance}"
            f"\nActual available_balance: {actual_available_balance}"
        )

    retry_for_payment_account_status()
