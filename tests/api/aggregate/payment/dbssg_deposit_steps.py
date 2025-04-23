from uuid import uuid1
import decimal

from hugoutils.utilities.dataclass_util import DataClassParser

from tests.api.aggregate.payment import helper as payment_helper
from tests.api.aggregate.payment.payment_dataclass import (
    InstantCreditNotification,
    IntraDayCreditNotification,
)
from behave import *
from retry import retry

use_step_matcher("re")


@Given(
    "I deposit an amount of ([^']*) into account ([^']*) using ICN for customerProfileId ([^']*)"
)
def deposit_using_icn(
    context,
    amount: decimal,
    account_identifier: str,
    customer_profile_identifier: str,
):
    payment_helper.__validate_provider("DBS Bank Ltd")

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

    instant_credit_notification_dto = DataClassParser.parse_row(
        context.table.rows[0], InstantCreditNotification
    )
    instant_credit_notification_dto.txn_info.receiving_party.account_no = (
        account_details.account_details.code_details.sg_code_details.account_number
    )
    instant_credit_notification_dto.txn_info.amt_dtls.txn_amt = amount
    customer_profile_id = instant_credit_notification_dto.customer_profile_id

    instant_credit_notification_dto.txn_info.txn_ref_id = uuid1().hex
    instant_credit_notification_dto.header.msgId = uuid1().hex

    response = request.hugoserve_post_request(
        path=f"/payment/dbs/sg/notification/icn",
        data=instant_credit_notification_dto.get_dict(),
        headers=payment_helper.__get_default_payment_headers(customer_profile_id),
    )
    assert response["headers"]["status_code"] == "200"


@Given(
    "I deposit an amount of ([^']*) into account ([^']*) using IDN for customerProfileId ([^']*)"
)
def deposit_using_idn(
    context, amount: decimal, account_identifier: str, customer_profile_identifier: str
):
    payment_helper.__validate_provider("DBS Bank Ltd")

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

    credit_notification_dto = DataClassParser.parse_row(
        context.table.rows[0], IntraDayCreditNotification
    )
    credit_notification_dto.txn_info.receiving_party.account_no = (
        account_details.account_details.code_details.sg_code_details.account_number
    )
    credit_notification_dto.txn_info.amt_dtls.txn_amt = amount
    credit_notification_dto.txn_info.txn_ref_id = uuid1().hex
    credit_notification_dto.header.msgId = uuid1().hex

    customer_profile_id = credit_notification_dto.customer_profile_id

    response = request.hugoserve_post_request(
        path=f"/payment/dbs/sg/notification/idn",
        data=credit_notification_dto.get_dict(),
        headers=payment_helper.__get_default_payment_headers(customer_profile_id),
    )
    assert response["headers"]["status_code"] == "200"


@Given(
    "I deposit an amount of ([^']*) into master account ([^']*) using IDN for customerProfileId ([^']*)"
)
def deposit_using_idn_master_account(
    context, amount: decimal, account_identifier: str, customer_profile_identifier: str
):
    payment_helper.__validate_provider("DBS Bank Ltd")

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

    credit_notification_dto = DataClassParser.parse_row(
        context.table.rows[0], IntraDayCreditNotification
    )
    credit_notification_dto.txn_info.receiving_party.account_no = (
        account_details.account_details.code_details.sg_code_details.account_number
    )
    credit_notification_dto.txn_info.amt_dtls.txn_amt = amount
    credit_notification_dto.txn_info.txn_ref_id = uuid1().hex
    credit_notification_dto.header.msgId = uuid1().hex

    customer_profile_id = credit_notification_dto.customer_profile_id

    response = request.hugoserve_post_request(
        path=f"/payment/dbs/sg/notification/idn",
        data=credit_notification_dto.get_dict(),
        headers=payment_helper.__get_default_payment_headers(customer_profile_id),
    )
    assert response["headers"]["status_code"] == "200"


@Given(
    "I deposit an amount of ([^']*) into master account ([^']*) using ICN for customerProfileId ([^']*)"
)
def deposit_using_icn_master_account(
    context, amount: decimal, account_identifier: str, customer_profile_identifier: str
):
    payment_helper.__validate_provider("DBS Bank Ltd")

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

    credit_notification_dto = DataClassParser.parse_row(
        context.table.rows[0], IntraDayCreditNotification
    )
    credit_notification_dto.txn_info.receiving_party.account_no = (
        account_details.account_details.code_details.sg_code_details.account_number
    )
    credit_notification_dto.txn_info.amt_dtls.txn_amt = amount
    credit_notification_dto.txn_info.txn_ref_id = uuid1().hex
    credit_notification_dto.header.msgId = uuid1().hex

    customer_profile_id = credit_notification_dto.customer_profile_id

    response = request.hugoserve_post_request(
        path=f"/payment/dbs/sg/notification/icn",
        data=credit_notification_dto.get_dict(),
        headers=payment_helper.__get_default_payment_headers(customer_profile_id),
    )
    assert response["headers"]["status_code"] == "200"


@Then(
    "I wait until max time to verify master account ([^']*) with an increased updated balance of ([^']*) for customerProfileId ([^']*)"
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
        tries=payment_helper.payment_providers_config["DBS Bank Ltd"]["max_wait_time"]
        / 5,
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
