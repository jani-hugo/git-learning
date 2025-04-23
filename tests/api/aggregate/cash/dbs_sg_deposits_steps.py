import decimal
from behave import *
from hugoutils.utilities.dataclass_util import DataClassParser
from retry import retry
from uuid import uuid1

from tests.api.aggregate.cash import helper as cash_helper
from tests.api.aggregate.cash.cash_dataclass import (
    DevDepositRequestDTO,
    InstantCreditNotification,
    IntraDayCreditNotification,
    CashDevDepositRequestDTO,
)
from tests.api.aggregate.payment import helper as payment_helper

use_step_matcher("re")


@Given(
    "I deposit an amount of ([^']*) into ([^']*) using ICN for customerProfileId ([^']*)"
)
def deposit_using_icn(
    context,
    amount: decimal,
    bank_account_identifier: str,
    customer_profile_identifier: str,
):
    cash_helper.__validate_provider("DBS Bank Ltd")

    bank_account_id = context.data[bank_account_identifier].account_id
    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id

    account_details = cash_helper.__fetch_bank_account(
        customer_profile_id, context, bank_account_id
    )
    request = context.request

    response = request.hugoserve_get_request(
        path=f"/cash/v1/account/{bank_account_id}/balance",
        headers=cash_helper.__get_default_cash_headers(customer_profile_id),
    )
    trace_id = response["headers"].get("trace_id", "N/A")

    assert (
        "data" in response
    ), f"\n[TraceId: {trace_id}] [AccountId: {bank_account_id}] Expected non empty data object, found empty. Response:{response}"

    initial_total_balance = response["data"]["total_balance"]
    initial_available_balance = response["data"]["available_balance"]

    context.data["initial_total_balance_" + bank_account_id] = initial_total_balance
    context.data["initial_available_balance_" + bank_account_id] = (
        initial_available_balance
    )

    instant_credit_notification_dto = DataClassParser.parse_row(
        context.table.rows[0], InstantCreditNotification
    )
    instant_credit_notification_dto.txn_info.receiving_party.account_no = (
        account_details.account_details.account_number
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
    trace_id = response["headers"].get("trace_id", "N/A")
    status_code = response["headers"]["status_code"]

    assert status_code == "200", (
        f"[TraceId: {trace_id}] [AccountId: {bank_account_id}]\n"
        f"Expected status_code: 200\n"
        f"Actual status_code: {status_code}"
    )


@Given(
    "I deposit an amount of ([^']*) into ([^']*) using DevDeposit expect the header status ([^']*)"
)
def deposit_using_payment_dev(
    context, amount: float, account_id: str, status_code: str
):
    request = context.request

    dev_deposit_dto = DataClassParser.parse_row(
        context.table.rows[0], DevDepositRequestDTO
    )

    dev_deposit_dto.account_id = context.data[account_id].account_id
    customer_profile_id = context.data[
        dev_deposit_dto.customer_profile_id
    ].customer_profile_id

    response = request.hugoserve_post_request(
        path=f"/payment/v1/dev/transaction/deposit",
        data=dev_deposit_dto.get_dict(),
        headers=cash_helper.__get_default_cash_headers(customer_profile_id),
    )

    trace_id = response["headers"].get("trace_id", "N/A")

    assert response["headers"]["status_code"] == status_code, (
        f"[TraceId: {trace_id}] [AccountId: {dev_deposit_dto.account_id}]\n"
        f"Expected status_code: {status_code}\n"
        f"Actual status_code: {response['headers']['status_code']}"
    )

    if response["headers"]["status_code"] == "200":
        assert response["headers"]["message"] == "Success", (
            f"[TraceId: {trace_id}] [AccountId: {dev_deposit_dto.account_id}]\n"
            f"Expected message: Success\n"
            f"Actual message: {response['headers']['message']}"
        )

        assert "data" in response, (
            f"[TraceId: {trace_id}] [AccountId: {dev_deposit_dto.account_id}]\n"
            f"Expected non-empty data object, found empty. Response: {response}"
        )

        assert "transaction_id" in response["data"], (
            f"[TraceId: {trace_id}] [AccountId: {dev_deposit_dto.account_id}]\n"
            f"Expected data object contains transaction_id\n"
            f"Actual data: {response['data']}"
        )

        dev_deposit_dto.transaction_id = response["data"]["transaction_id"]
        context.data[dev_deposit_dto.identifier] = dev_deposit_dto.transaction_id


@Given(
    "I deposit an amount of ([^']*) into ([^']*) using cash DevDeposit and expect the header status ([^']*)"
)
def deposit_using_cash_dev(
    context, amount: float, account_identifier: str, status_code: str
):
    request = context.request

    dev_deposit_dto = DataClassParser.parse_row(
        context.table.rows[0], CashDevDepositRequestDTO
    )

    account_id = context.data[account_identifier].account_id
    dev_deposit_dto.account_id = account_id
    dev_deposit_dto.amount = amount
    customer_profile_id = context.data[
        dev_deposit_dto.customer_profile_id
    ].customer_profile_id

    check_initial_balance_response = request.hugoserve_get_request(
        path=f"/cash/v1/account/{account_id}/balance",
        headers=cash_helper.__get_default_cash_headers(customer_profile_id),
    )
    assert (
        "data" in check_initial_balance_response
    ), f"\nExpected non empty data object, found empty. Response:{check_initial_balance_response}"

    initial_total_balance = check_initial_balance_response["data"]["total_balance"]
    initial_available_balance = check_initial_balance_response["data"][
        "available_balance"
    ]

    context.data["initial_total_balance_" + account_id] = initial_total_balance
    context.data["initial_available_balance_" + account_id] = initial_available_balance

    deposit_response = request.hugoserve_post_request(
        path=f"/cash/v1/dev/transaction/deposit",
        data=dev_deposit_dto.get_dict(),
        headers=cash_helper.__get_default_cash_headers(customer_profile_id),
    )
    assert deposit_response["headers"]["status_code"] == status_code
    if deposit_response["headers"]["status_code"] == "200":
        assert deposit_response["headers"]["message"] == "Success"


@Given(
    "I deposit an amount of ([^']*) into ([^']*) using IDN for customerProfileId ([^']*)"
)
def deposit_using_idn(
    context,
    amount: decimal,
    bank_account_identifier: str,
    customer_profile_identifier: str,
):
    cash_helper.__validate_provider("DBS Bank Ltd")

    bank_account_id = context.data[bank_account_identifier].account_id
    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id

    account_details = cash_helper.__fetch_bank_account(
        customer_profile_id, context, bank_account_id
    )
    request = context.request

    response = request.hugoserve_get_request(
        path=f"/cash/v1/account/{bank_account_id}/balance",
        headers=cash_helper.__get_default_cash_headers(customer_profile_id),
    )
    trace_id = response["headers"].get("trace_id", "N/A")

    assert "data" in response, (
        f"[TraceId: {trace_id}] [AccountId: {bank_account_id}]\n"
        f"Expected non-empty data object, found empty. Response: {response}"
    )

    initial_total_balance = response["data"]["total_balance"]
    initial_available_balance = response["data"]["available_balance"]

    context.data["initial_total_balance_" + bank_account_id] = initial_total_balance
    context.data["initial_available_balance_" + bank_account_id] = (
        initial_available_balance
    )

    credit_notification_dto = DataClassParser.parse_row(
        context.table.rows[0], IntraDayCreditNotification
    )
    credit_notification_dto.txn_info.receiving_party.account_no = (
        account_details.account_details.account_number
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

    assert response["headers"]["status_code"] == "200", (
        f"[TraceId: {response['headers']['trace_id']}] [AccountId: {bank_account_id}]\n"
        f"Expected status_code: 200\n"
        f"Actual status_code: {response['headers']['status_code']}"
    )


@Then(
    "I wait until max time to verify bank account ([^']*) with an increased balance of ([^']*) for customerProfileId ([^']*)"
)
def verify_bank_account_balance(
    context, identifier, amount_increased, customer_profile_identifier
):
    request = context.request
    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id
    bank_account_id = context.data[identifier].account_id

    expected_total_balance = float(
        context.data["initial_total_balance_" + bank_account_id]
    ) + float(amount_increased)
    expected_available_balance = float(
        context.data["initial_available_balance_" + bank_account_id]
    ) + float(amount_increased)

    @retry(
        AssertionError,
        tries=cash_helper.cash_providers_config["DBS Bank Ltd"]["max_wait_time"] / 5,
        delay=3,
        logger=None,
    )
    def retry_for_bank_account_status():
        response = request.hugoserve_get_request(
            path=f"/cash/v1/account/{bank_account_id}/balance",
            headers=cash_helper.__get_default_cash_headers(customer_profile_id),
        )
        trace_id = response["headers"].get("trace_id", "N/A")

        assert "data" in response, (
            f"[TraceId: {trace_id}] [AccountId: {bank_account_id}]\n"
            f"Expected non-empty data object, found empty. Response: {response}"
        )

        actual_total_balance = response["data"]["total_balance"]
        actual_available_balance = response["data"]["available_balance"]

        assert expected_total_balance == actual_total_balance, (
            f"[TraceId: {trace_id}] [AccountId: {bank_account_id}]\n"
            f"Expect total_balance: {expected_total_balance}\n"
            f"Actual total_balance: {actual_total_balance}"
        )

        assert expected_available_balance == actual_available_balance, (
            f"[TraceId: {trace_id}] [AccountId: {bank_account_id}]\n"
            f"Expect available_balance: {expected_available_balance}\n"
            f"Actual available_balance: {actual_available_balance}"
        )

    retry_for_bank_account_status()
