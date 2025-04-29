from behave import *
from hugoutils.utilities.dataclass_util import DataClassParser
from retry import retry

import tests.api.aggregate.cash.helper as cash_helper
import decimal

from tests.api.aggregate.cash.cash_dataclass import PayRequestDTO, CashDevDepositRequestDTO, FloatAccountResponseDTO, ApplyFeeRequestDTO

use_step_matcher("re")

@Given(
    "I initialise card for Customer Profile ([^']*) and expect request status code as ([^']*) and status as ([^']*)"
)
def initialise_customer_on_card(
        context,
        customer_profile_identifier: str,
        status_code: str,
        status: str
):
    request = context.request
    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id

    response = request.hugoserve_post_request(
        path="/cash/v1/card/customer-profile",
        headers=cash_helper.__get_default_cash_headers(customer_profile_id)
    )

    assert (
            response["headers"]["status_code"] == status_code
    ), (
        f"\nExpect Status Code: {status_code}"
        f"\nActual Status Code: {response['headers']['status_code']}"
    )

    if response["headers"]["status_code"] == "200":
        assert (
                response["data"]["status"] == status
        ), (
            f"\nExpect Initialisation Status: {status}"
            f"\nActual Initialisation Status: {response['data']['status']}"
        )

@Then(
    "I setup card float account ([^']*) for Customer Profile ([^']*) and expect request status code as ([^']*) and status as ([^']*)"
)
def setup_float_account(
        context,
        float_acc_id: str,
        customer_profile_identifier: str,
        status_code: str,
        status: str
):
    request = context.request
    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id

    response = request.hugoserve_post_request(
        path="/cash/v1/card/float-account",
        headers=cash_helper.__get_default_cash_headers(customer_profile_id)
    )

    assert (
            response["headers"]["status_code"] == status_code
    ), (
        f"\nExpect Status Code: {status_code}"
        f"\nActual Status Code: {response['headers']['status_code']}"
    )

    if response["headers"]["status_code"] == "200":
        assert (
                response["data"]["status"] == status
        ), (
            f"\nExpect Initialisation Status: {status}"
            f"\nActual Initialisation Status: {response['data']['status']}"
        )
        context.data[float_acc_id] = DataClassParser.dict_to_object(
            {
                "account_id": response["data"]["float_account_id"]
            }, data_class=FloatAccountResponseDTO
        )


@Then(
    "I onboard EndCustomerProfile ([^']*) of CustomerProfile ([^']*) on card service and expect request status as ([^']*) and onboard_status as ([^']*)"
)
def onboard_end_customer_on_card(
        context,
        end_customer_profile_id: str,
        customer_profile_identifier: str,
        status: str,
        onboard_status: str
):
    request = context.request
    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id

    response = request.hugoserve_post_request(
        path="/cash/v1/internal/end-customer-profile",
        data={
            "end_customer_profile_id": context.data[end_customer_profile_id].end_customer_profile_id
        },
        headers=cash_helper.__get_default_cash_headers(customer_profile_id, None, None, "CARD_SERVICE")
    )

    assert (
            response["headers"]["status_code"] == status
    ), (
        f"\nExpect Status Code: {status}"
        f"\nActual Status Code: {response['headers']['status_code']}"
    )

    if response["headers"]["status_code"] == "200":
        assert (
                response["data"]["providers"][0]["onboard_status"] == onboard_status
        ), (
            f"\nExpect Initialisation Status: {onboard_status}"
            f"\nActual Initialisation Status: {response['data']['providers'][0]['onboard_status']}"
        )


@Then(
    "I attach a card onto the cash wallet ([^']*) and CustomerProfileId ([^']*) and expect request status ([^']*) and attach status ([^']*)"
)
def attach_card_to_cash_wallet(
        context,
        cash_wallet_id: str,
        customer_profile_identifier: str,
        status: str,
        attach_status: str
):
    request = context.request
    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id

    response = request.hugoserve_post_request(
        path="/cash/v1/card/attach-card",
        data={
            "account_id": context.data[cash_wallet_id].account_id
        },
        headers=cash_helper.__get_default_cash_headers(customer_profile_id),
    )

    assert (
            response["headers"]["status_code"] == status
    ), (
        f"\nExpect Status Code: {status}"
        f"\nActual Status Code: {response['headers']['status_code']}"
    )

    if response["headers"]["status_code"] == "200":
        assert (
                response["data"]["status"] == attach_status
        ), (
            f"\nExpect Initialisation Status: {attach_status}"
            f"\nActual Initialisation Status: {response['data']['status']}"
        )


@then("I initiate a Card Pay Transaction ([^']*) on cash wallet ([^']*) and CustomerProfileId ([^']*) and expect request status ([^']*) and txn status ([^']*)")
def initiate_card_txn(
        context,
        transaction_id: str,
        cash_wallet_id: str,
        customer_profile_identifier: str,
        status: str,
        transaction_status: str
):
    request = context.request
    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id

    pay_request_dto = DataClassParser.parse_row(
        context.table.rows[0], data_class=PayRequestDTO
    )

    pay_request_dto.source_account_id = context.data[cash_wallet_id].account_id

    pay_request_dto.transfer_out_account_details = {
        "account_holder_name": "Jane Smith",
        "country": "SGP",
        "currency": "SGD",
        "code_details": {
            "sg_bank_details": {
                "account_number": "9876543210",
                "swift_bic": "DBSSSGSGXXX",
            }
        },
    }

    response = request.hugoserve_post_request(
        path="/cash/v1/card/pay",
        data=pay_request_dto.get_dict(),
        headers=cash_helper.__get_default_cash_headers(customer_profile_id),
    )

    assert (
            response["headers"]["status_code"] == status
    ), (
        f"\nExpect Status Code: {status}"
        f"\nActual Status Code: {response['headers']['status_code']}"
    )

    if response["headers"]["status_code"] == "200":
        assert (
                response["data"]["pay_status"] == transaction_status
        ), (
            f"\nExpect Initialisation Status: {transaction_status}"
            f"\nActual Initialisation Status: {response['data']['pay_status']}"
        )
        context.data[transaction_id] = response["data"]["transaction_id"]


@Given(
    "I deposit an amount of ([^']*) into cash account ([^']*) and expect the header status ([^']*)"
)
def dev_deposit_on_cash_account(
        context,
        amount: float,
        cash_account_identifier: str,
        status_code: str
):
    request = context.request

    dev_deposit_dto = DataClassParser.parse_row(
        context.table.rows[0], CashDevDepositRequestDTO
    )

    cash_account_id = context.data[cash_account_identifier].account_id
    dev_deposit_dto.account_id = cash_account_id
    dev_deposit_dto.amount = amount
    customer_profile_id = context.data[
        dev_deposit_dto.customer_profile_id
    ].customer_profile_id

    deposit_response = request.hugoserve_post_request(
        path=f"/cash/v1/dev/transaction/deposit",
        data=dev_deposit_dto.get_dict(),
        headers=cash_helper.__get_default_cash_headers(customer_profile_id),
    )

    assert deposit_response["headers"]["status_code"] == status_code

    if deposit_response["headers"]["status_code"] == "200":
        assert deposit_response["headers"]["message"] == "Success"


@Then(
    "I wait until max time to verify cash account ([^']*) with an available balance of ([^']*) and total balance of ([^']*) for customerProfileId ([^']*)"
)
def verify_bank_account_balance(
        context,
        cash_account_identifier: str,
        expected_available_balance: decimal,
        expected_total_balance: decimal,
        customer_profile_identifier: str,
):
    request = context.request

    cash_account_id = context.data[cash_account_identifier].account_id
    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id

    @retry(
        AssertionError,
        tries=cash_helper.cash_providers_config["DBS Bank Ltd"]["max_wait_time"] / 20,
        delay=5,
        logger=None,
    )
    def retry_for_bank_account_status():
        response = request.hugoserve_get_request(
            path=f"/cash/v1/card/balance/{cash_account_id}",
            headers=cash_helper.__get_default_cash_headers(customer_profile_id),
        )
        assert (
                "data" in response
        ), f"\nExpected non empty data object, found empty. Response:{response}"

        actual_total_balance = response["data"]["total_balance"]
        actual_available_balance = response["data"]["available_balance"]

        assert float(expected_total_balance) == actual_total_balance, (
            f"\nExpect total_balance: {expected_total_balance}"
            f"\nActual total_balance: {actual_total_balance}"
        )
        assert float(expected_available_balance) == actual_available_balance, (
            f"\nExpect available_balance: {expected_available_balance}"
            f"\nActual available_balance: {actual_available_balance}"
        )

    retry_for_bank_account_status()



@Then("I initiate a Apply Fee on Card Transaction ([^']*) on cash wallet ([^']*) and CustomerProfileId ([^']*) and expect request status ([^']*) and txn status ([^']*)")
def initiate_apply_fee_txn(
        context,
        transaction_id: str,
        cash_wallet_id: str,
        customer_profile_identifier: str,
        status: str,
        transaction_status: str
):
    request = context.request
    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id

    apply_fees_request_dto = DataClassParser.parse_row(
        context.table.rows[0], data_class=ApplyFeeRequestDTO
    )

    apply_fees_request_dto.account_id = context.data[cash_wallet_id].account_id

    response = request.hugoserve_post_request(
        path="/cash/v1/card/apply-fee",
        data=apply_fees_request_dto.get_dict(),
        headers=cash_helper.__get_default_cash_headers(customer_profile_id),
    )

    assert (
            response["headers"]["status_code"] == status
    ), (
        f"\nExpect Status Code: {status}"
        f"\nActual Status Code: {response['headers']['status_code']}"
    )

    if response["headers"]["status_code"] == "200":
        assert (
                response["data"]["status"] == transaction_status
        ), (
            f"\nExpect Initialisation Status: {transaction_status}"
            f"\nActual Initialisation Status: {response['data']['status']}"
        )
        context.data[transaction_id] = response["data"]["transaction_id"]

@Then(
    "I initiate a Apply Tax on Card Transaction ([^']*) on cash wallet ([^']*) and CustomerProfileId ([^']*) and expect request status ([^']*) and txn status ([^']*)"
)
def initiate_apply_tax_txn(
        context,
        transaction_id: str,
        cash_wallet_id: str,
        customer_profile_identifier: str,
        status: str,
        transaction_status: str
):
    request = context.request
    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id

    apply_fees_request_dto = DataClassParser.parse_row(
        context.table.rows[0], data_class=ApplyFeeRequestDTO
    )

    apply_fees_request_dto.account_id = context.data[cash_wallet_id].account_id

    response = request.hugoserve_post_request(
        path="/cash/v1/card/apply-tax",
        data=apply_fees_request_dto.get_dict(),
        headers=cash_helper.__get_default_cash_headers(customer_profile_id),
    )

    assert (
            response["headers"]["status_code"] == status
    ), (
        f"\nExpect Status Code: {status}"
        f"\nActual Status Code: {response['headers']['status_code']}"
    )

    if response["headers"]["status_code"] == "200":
        assert (
                response["data"]["status"] == transaction_status
        ), (
            f"\nExpect Initialisation Status: {transaction_status}"
            f"\nActual Initialisation Status: {response['data']['status']}"
        )
        context.data[transaction_id] = response["data"]["transaction_id"]

@Then(
    "I initiate a Apply Yield on Card Transaction ([^']*) on cash wallet ([^']*) and CustomerProfileId ([^']*) and expect request status ([^']*) and txn status ([^']*)"
)
def initiate_apply_yield_txn(
        context,
        transaction_id: str,
        cash_wallet_id: str,
        customer_profile_identifier: str,
        status: str,
        transaction_status: str
):
    request = context.request
    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id

    apply_fees_request_dto = DataClassParser.parse_row(
        context.table.rows[0], data_class=ApplyFeeRequestDTO
    )

    apply_fees_request_dto.account_id = context.data[cash_wallet_id].account_id

    response = request.hugoserve_post_request(
        path="/cash/v1/card/apply-yield",
        data=apply_fees_request_dto.get_dict(),
        headers=cash_helper.__get_default_cash_headers(customer_profile_id),
    )

    assert (
            response["headers"]["status_code"] == status
    ), (
        f"\nExpect Status Code: {status}"
        f"\nActual Status Code: {response['headers']['status_code']}"
    )

    if response["headers"]["status_code"] == "200":
        assert (
                response["data"]["status"] == transaction_status
        ), (
            f"\nExpect Initialisation Status: {transaction_status}"
            f"\nActual Initialisation Status: {response['data']['status']}"
        )
        context.data[transaction_id] = response["data"]["transaction_id"]

@Then(
    "I wait until max time to verify the Card transaction ([^']*) status as ([^']*) for customerProfileId ([^']*)"
)
def wait_and_verify_card_transaction_status(
        context, identifier: str, transaction_status: str, customer_profile_identifier: str
):
    request = context.request
    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id
    try:
        transaction_id = context.data[identifier]
    except:
        print(f"\n {identifier} not present in context so ignoring")

    @retry(
        AssertionError,
        tries=10,
        delay=5,
        logger=None,
    )
    def retry_for_transaction_status():
        response = request.hugoserve_get_request(
            f"/cash/v1/card/transaction/{transaction_id}",
            headers=cash_helper.__get_default_cash_headers(customer_profile_id),
        )

        assert response["headers"]["status_code"] == "200", (
            f"[TraceId: {response['headers']['trace_id']}]\n"
            f"Expect status_code: 200\n"
            f"Actual status_code: {response['headers']['status_code']}"
        )

        assert response["data"] is not None
        assert response["data"]["status"] == transaction_status
        if response["data"] is not None:
            assert response["data"]["status"] == transaction_status, print(
                f"\nExpect data.status: {transaction_status}"
                f"\nActual data.status: {response['data']['status']}, data: {response['data']}"
            )

        # Validate other fields values

    retry_for_transaction_status()