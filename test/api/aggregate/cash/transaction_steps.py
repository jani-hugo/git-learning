from hugoutils.utilities.dataclass_util import DataClassParser

from test.api.aggregate.cash import helper as cash_helper
from test.api.aggregate.cash.cash_dataclass import (
    CancelTransactionRequestDTO,
    CloseTransactionRequestDTO,
    InitiateTransactionRequestDTO,
    RefundRequestDTO,
    SettleTransactionRequestDTO,
    UpdateTransactionRequestDTO,
)
from behave import *
from retry import retry

use_step_matcher("re")

@Then(
    "I wait until max time to verify the transaction ([^']*) status as ([^']*) for customerProfileId ([^']*)"
)
def wait_and_verify_transaction_status(
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
            f"/cash/v1/transaction/{transaction_id}",
            headers=cash_helper.__get_default_cash_headers(customer_profile_id),
        )

        assert response["headers"]["status_code"] == "200", (
            f"[TraceId: {response['headers']['trace_id']}]\n"
            f"Expect status_code: 200\n"
            f"Actual status_code: {response['headers']['status_code']}"
        )

        assert response["data"] is not None
        assert response["data"]["transaction_status"] == transaction_status
        if response["data"] is not None:
            assert response["data"]["transaction_status"] == transaction_status, print(
                f"\nExpect data.transaction_status: {transaction_status}"
                f"\nActual data.transaction_status: {response['data']['transaction_status']}, data: {response['data']}"
            )

        # Validate other fields values

    retry_for_transaction_status()

@Then(
    "I initiate refund for transaction with below details expect the header statuscode ([^']*)"
)
def refund_transaction(context, status_code):
    request = context.request

    refund_tx_request_dto = DataClassParser.parse_row(context.table.rows[0], RefundRequestDTO)
    refund_tx_request_dto.original_transaction_id = context.data[
        refund_tx_request_dto.original_transaction_id
    ]

    refund_tx_request_dto.customer_profile_id = context.data[
        refund_tx_request_dto.customer_profile_id
    ].customer_profile_id

    response = request.hugoserve_post_request(
        path=f"/cash/v1/transaction/refund",
        data=refund_tx_request_dto.get_dict(),
        headers=cash_helper.__get_default_cash_headers(
            refund_tx_request_dto.customer_profile_id
        ),
    )

    assert response["headers"]["status_code"] == status_code, (
        f"[TraceId: {response['headers']['trace_id']}]\n"
        f"Expect status_code: {status_code}\n"
        f"Actual status_code: {response['headers']['status_code']}"
    )

    if response["headers"]["status_code"] == "200":
        assert "transaction_id" in response["data"], (
            f"\nExpected data object contains transaction_id"
            f"\nActual data: {response['data']}"
        )

        context.data["TxId2"] = response["data"]["transaction_id"]

        assert response["data"]["transaction_status"] == "TRANSACTION_PENDING", (
            f"\nExpect data.account_status: TRANSACTION_PENDING"
            f"\nActual data.account_status: {response['data']['transaction_status']}, data: {response['data']}"
        )


@Then(
    "I initiate transaction to transfer funds with below details and expect the header statuscode ([^']*) and transaction status as ([^']*)"
)
def initiate_transaction_and_verify_status(context, status_code, txn_status):
    request = context.request

    initiate_tx_request_dto = DataClassParser.parse_row(
        context.table.rows[0], InitiateTransactionRequestDTO
    )
    if context.table.rows[0]["receiver_account_id"] == '':
        transfer_out_details = {
            "account_holder_name":"Jane Smith",
            "country":"SGP",
            "currency":"SGD",
            "code_details":{
                "sg_bank_details":{
                    "account_number":"9876543210",
                    "swift_bic":"DBSSSGSGXXX"}
            }
        }

    else:
        account_details = context.data[context.table.rows[0]["receiver_account_id"]].account_details
        transfer_out_details = {
            "account_holder_name": account_details.account_holder_name,
            "country": account_details.country,
            "currency": account_details.currency,
            "code_details": {
                "sg_bank_details": {
                    "account_number": account_details.code_details.sg_code_details.account_number,
                    "swift_bic": account_details.code_details.sg_code_details.swift_bic,
                }
            }
        }

    initiate_tx_request_dto.transfer_out_details = transfer_out_details

    initiate_tx_request_dto.account_id = context.data[
        initiate_tx_request_dto.account_id
    ].account_id

    initiate_tx_request_dto.customer_profile_id = context.data[
        initiate_tx_request_dto.customer_profile_id
    ].customer_profile_id
    idempotency_key = initiate_tx_request_dto.idempotency_key
    response = request.hugoserve_post_request(
        path=f"/cash/v1/transaction/initiate",
        data=initiate_tx_request_dto.get_dict(),
        headers=cash_helper.__get_default_cash_headers(
            initiate_tx_request_dto.customer_profile_id, idempotency_key
        ),
    )

    assert response["headers"]["status_code"] == status_code, (
        f"[TraceId: {response['headers']['trace_id']}]\n"
        f"Expect status_code: {status_code}\n"
        f"Actual status_code: {response['headers']['status_code']}"
    )

    if response["headers"]["status_code"] == "200":
        assert response["headers"]["message"] == "Success"

        assert response["data"]["transaction_status"] == txn_status
        assert (
            "data" in response
        ), f"\nExpected non-empty data object, found empty. Response:{response}"

        assert "transaction_id" in response["data"], (
            f"\nExpected data object contains transaction_id"
            f"\nActual data: {response['data']}"
        )
        initiate_tx_request_dto.transaction_id = response["data"]["transaction_id"]
        context.data[initiate_tx_request_dto.identifier] = (
            initiate_tx_request_dto.transaction_id
        )


@Then(
    "I initiate transaction to transfer funds with below details and expect the header statuscode ([^']*)"
)
def initiate_transaction_and_verify_status(context, status_code):
    request = context.request

    initiate_tx_request_dto = DataClassParser.parse_row(
        context.table.rows[0], InitiateTransactionRequestDTO
    )

    initiate_tx_request_dto.account_id = context.data[
        initiate_tx_request_dto.account_id
    ].account_id

    initiate_tx_request_dto.customer_profile_id = context.data[
        initiate_tx_request_dto.customer_profile_id
    ].customer_profile_id

    response = request.hugoserve_post_request(
        path=f"/cash/v1/transaction/initiate",
        data=initiate_tx_request_dto.get_dict(),
        headers=cash_helper.__get_default_cash_headers(
            initiate_tx_request_dto.customer_profile_id
        ),
    )

    assert response["headers"]["status_code"] == status_code, (
        f"[TraceId: {response['headers']['trace_id']}]\n"
        f"Expect status_code: {status_code}\n"
        f"Actual status_code: {response['headers']['status_code']}"
    )

    if response["headers"]["status_code"] == "200":
        assert response["headers"]["message"] == "Success"
        assert (
            "data" in response
        ), f"\nExpected non-empty data object, found empty. Response:{response}"

        assert "transaction_id" in response["data"], (
            f"\nExpected data object contains transaction_id"
            f"\nActual data: {response['data']}"
        )
        initiate_tx_request_dto.transaction_id = response["data"]["transaction_id"]
        context.data[initiate_tx_request_dto.identifier] = (
            initiate_tx_request_dto.transaction_id
        )


@Then(
    "I update transaction with transaction_id ([^']*) with the negative_transfer_allowed as ([^']*) and expect the header statuscode ([^']*) and transaction status as ([^']*)"
)
def update_transaction_and_verify_status(
    context,
    transaction_id: str,
    negative_transfer_allowed: bool,
    status_code: str,
    message,
):
    request = context.request

    update_tx_request_dto = DataClassParser.parse_row(
        context.table.rows[0], UpdateTransactionRequestDTO
    )

    update_tx_request_dto.transaction_id = context.data[update_tx_request_dto.transaction_id]
    update_tx_request_dto.customer_profile_id = context.data[
        update_tx_request_dto.customer_profile_id
    ].customer_profile_id
    response = request.hugoserve_put_request(
        path=f"/cash/v1/transaction/{update_tx_request_dto.transaction_id}",
        data=update_tx_request_dto.get_dict(),
        headers=cash_helper.__get_default_cash_headers(
            update_tx_request_dto.customer_profile_id
        ),
    )

    assert response["headers"]["status_code"] == status_code, (
        f"[TraceId: {response['headers']['trace_id']}]\n"
        f"Expect status_code: {status_code}\n"
        f"Actual status_code: {response['headers']['status_code']}"
    )

    if response["headers"]["status_code"] == "200":
        assert response["headers"]["message"] == "Success"

        assert response["data"]["transaction_status"] == message
        assert (
            "data" in response
        ), f"\nExpected non-empty data object, found empty. Response:{response}"

        assert "transaction_id" in response["data"], (
            f"\nExpected data object contains transaction_id"
            f"\nActual data: {response['data']}"
        )
    else:
        assert response["headers"]["message"] == message


@Then(
    "I cancel transaction with transaction_id ([^']*) with the negative_transfer_allowed as ([^']*) and expect the header statuscode ([^']*) and transaction status as ([^']*)"
)
def cancel_transaction_and_verify_status(
    context,
    transaction_id: str,
    negative_transfer_allowed: bool,
    status_code: str,
    message,
):
    request = context.request

    cancel_txn_request_dto = DataClassParser.parse_row(
        context.table.rows[0], CancelTransactionRequestDTO
    )

    cancel_txn_request_dto.transaction_id = context.data[cancel_txn_request_dto.transaction_id]
    cancel_txn_request_dto.customer_profile_id = context.data[
        cancel_txn_request_dto.customer_profile_id
    ].customer_profile_id
    response = request.hugoserve_put_request(
        path=f"/cash/v1/transaction/{cancel_txn_request_dto.transaction_id}/cancel",
        data=cancel_txn_request_dto.get_dict(),
        headers=cash_helper.__get_default_cash_headers(
            cancel_txn_request_dto.customer_profile_id
        ),
    )

    assert response["headers"]["status_code"] == status_code, (
        f"[TraceId: {response['headers']['trace_id']}]\n"
        f"Expect status_code: {status_code}\n"
        f"Actual status_code: {response['headers']['status_code']}"
    )

    if response["headers"]["status_code"] == "200":
        assert response["headers"]["message"] == "Success"

        assert response["data"]["transaction_status"] == message
        assert (
            "data" in response
        ), f"\nExpected non-empty data object, found empty. Response:{response}"

        assert "transaction_id" in response["data"], (
            f"\nExpected data object contains transaction_id"
            f"\nActual data: {response['data']}"
        )


@Then(
    "I close transaction with transaction_id ([^']*) with the negative_transfer_allowed as ([^']*) and expect the header statuscode ([^']*) and transaction status as ([^']*)"
)
def close_transaction_and_verify_status(
    context,
    transaction_id: str,
    negative_transfer_allowed: bool,
    status_code: str,
    message,
):
    request = context.request

    close_tx_request_dto = DataClassParser.parse_row(
        context.table.rows[0], CloseTransactionRequestDTO
    )

    close_tx_request_dto.transaction_id = context.data[close_tx_request_dto.transaction_id]
    customer_profile_id = context.data[
        close_tx_request_dto.customer_profile_id
    ].customer_profile_id
    response = request.hugoserve_put_request(
        path=f"/cash/v1/transaction/{close_tx_request_dto.transaction_id}/close",
        data=close_tx_request_dto.get_dict(),
        headers=cash_helper.__get_default_cash_headers(customer_profile_id),
    )

    assert response["headers"]["status_code"] == status_code, (
        f"[TraceId: {response['headers']['trace_id']}]\n"
        f"Expect status_code: {status_code}\n"
        f"Actual status_code: {response['headers']['status_code']}"
    )

    if response["headers"]["status_code"] == "200":
        assert response["headers"]["message"] == "Success"

        assert response["data"]["transaction_status"] == message
        assert (
            "data" in response
        ), f"\nExpected non-empty data object, found empty. Response:{response}"

        assert "transaction_id" in response["data"], (
            f"\nExpected data object contains transaction_id"
            f"\nActual data: {response['data']}"
        )


@Then(
    "I update transaction with transaction_id ([^']*) with the negative_transfer_allowed as ([^']*) and expect the header statuscode ([^']*)"
)
def update_transaction_and_verify_status(
    context, transaction_id: str, negative_transfer_allowed: bool, status_code: str
):
    request = context.request

    update_tx_request_dto = DataClassParser.parse_row(
        context.table.rows[0], UpdateTransactionRequestDTO
    )

    update_tx_request_dto.transaction_id = context.data[update_tx_request_dto.transaction_id]
    update_tx_request_dto.customer_profile_id = context.data[
        update_tx_request_dto.customer_profile_id
    ].customer_profile_id
    response = request.hugoserve_put_request(
        path=f"/cash/v1/transaction/{update_tx_request_dto.transaction_id}",
        data=update_tx_request_dto.get_dict(),
        headers=cash_helper.__get_default_cash_headers(
            update_tx_request_dto.customer_profile_id
        ),
    )

    assert response["headers"]["status_code"] == status_code, (
        f"[TraceId: {response['headers']['trace_id']}]\n"
        f"Expect status_code: {status_code}\n"
        f"Actual status_code: {response['headers']['status_code']}"
    )

    if response["headers"]["status_code"] == "200":
        assert response["headers"]["message"] == "Success"

        assert (
            "data" in response
        ), f"\nExpected non-empty data object, found empty. Response:{response}"

        assert "transaction_id" in response["data"], (
            f"\nExpected data object contains transaction_id"
            f"\nActual data: {response['data']}"
        )


@Then(
    "I settle transaction to transfer funds with below details and expect the header statuscode ([^']*) and transaction_status as ([^']*)"
)
def settle_transaction_and_verify_status(
    context,
    status_code: str,
    message: str,
):
    request = context.request

    settle_tx_request_dto = DataClassParser.parse_row(
        context.table.rows[0], SettleTransactionRequestDTO
    )

    settle_tx_request_dto.transaction_id = context.data[settle_tx_request_dto.transaction_id]
    settle_tx_request_dto.customer_profile_id = context.data[
        settle_tx_request_dto.customer_profile_id
    ].customer_profile_id
    idempotency_key = settle_tx_request_dto.idempotency_key
    if (
        settle_tx_request_dto.overdraft_funding_account_id is not None
        and settle_tx_request_dto.overdraft_funding_account_id != ""
    ):
        settle_tx_request_dto.overdraft_funding_account_id = context.data[
            settle_tx_request_dto.overdraft_funding_account_id
        ].account_id
    else:
        settle_tx_request_dto.overdraft_funding_account_id = None

    response = request.hugoserve_put_request(
        path=f"/cash/v1/transaction/{settle_tx_request_dto.transaction_id}/settle",
        data=settle_tx_request_dto.get_dict(),
        headers=cash_helper.__get_default_cash_headers(
            settle_tx_request_dto.customer_profile_id, idempotency_key
        ),
    )
    assert response["headers"]["status_code"] == status_code, (
        f"[TraceId: {response['headers']['trace_id']}]\n"
        f"Expect status_code: {status_code}\n"
        f"Actual status_code: {response['headers']['status_code']}"
    )

    if response["headers"]["status_code"] == "200":
        assert "transaction_id" in response["data"], (
            f"\nExpected data object contains transaction_id"
            f"\nActual data: {response['data']}"
        )
        assert response["data"]["transaction_status"] == "TRANSACTION_PENDING", (
            f"\nExpect data.account_status: TRANSACTION_PENDING"
            f"\nActual data.account_status: {response['data']['transaction_status']}, data: {response['data']}"
        )
    else:
        assert response["headers"]["message"] == message


@Then(
    "I settle transaction to transfer funds with below details and expect the header statuscode ([^']*)"
)
def settle_transaction_and_verify_status(
    context,
    status_code: str,
):
    request = context.request

    settle_tx_request_dto = DataClassParser.parse_row(
        context.table.rows[0], SettleTransactionRequestDTO
    )

    settle_tx_request_dto.transaction_id = context.data[settle_tx_request_dto.transaction_id]
    settle_tx_request_dto.customer_profile_id = context.data[
        settle_tx_request_dto.customer_profile_id
    ].customer_profile_id
    idempotency_key = settle_tx_request_dto.idempotency_key
    if (
        settle_tx_request_dto.overdraft_funding_account_id is not None
        and settle_tx_request_dto.overdraft_funding_account_id != ""
    ):
        settle_tx_request_dto.overdraft_funding_account_id = context.data[
            settle_tx_request_dto.overdraft_funding_account_id
        ].account_id
    else:
        settle_tx_request_dto.overdraft_funding_account_id = None

    response = request.hugoserve_put_request(
        path=f"/cash/v1/transaction/{settle_tx_request_dto.transaction_id}/settle",
        data=settle_tx_request_dto.get_dict(),
        headers=cash_helper.__get_default_cash_headers(
            settle_tx_request_dto.customer_profile_id, idempotency_key
        ),
    )

    assert response["headers"]["status_code"] == status_code, (
        f"[TraceId: {response['headers']['trace_id']}]\n"
        f"Expect status_code: {status_code}\n"
        f"Actual status_code: {response['headers']['status_code']}"
    )

    if response["headers"]["status_code"] == "200":
        assert "transaction_id" in response["data"], (
            f"\nExpected data object contains transaction_id"
            f"\nActual data: {response['data']}"
        )


@Then(
    "I settle transaction to transfer funds with below details for requested amount less than blocked amount and expect the header statuscode ([^']*) and transaction_status as ([^']*)"
)
def settle_transaction_and_verify_status(
    context,
    status_code: str,
    message: str,
):
    request = context.request

    settle_tx_request_dto = DataClassParser.parse_row(
        context.table.rows[0], SettleTransactionRequestDTO
    )

    settle_tx_request_dto.transaction_id = context.data[settle_tx_request_dto.transaction_id]
    settle_tx_request_dto.customer_profile_id = context.data[
        settle_tx_request_dto.customer_profile_id
    ].customer_profile_id
    idempotency_key = settle_tx_request_dto.idempotency_key
    if (
        settle_tx_request_dto.overdraft_funding_account_id is not None
        and settle_tx_request_dto.overdraft_funding_account_id != ""
    ):
        settle_tx_request_dto.overdraft_funding_account_id = context.data[
            settle_tx_request_dto.overdraft_funding_account_id
        ].account_id
    else:
        settle_tx_request_dto.overdraft_funding_account_id = None

    response = request.hugoserve_put_request(
        path=f"/cash/v1/transaction/{settle_tx_request_dto.transaction_id}/settle",
        data=settle_tx_request_dto.get_dict(),
        headers=cash_helper.__get_default_cash_headers(
            settle_tx_request_dto.customer_profile_id, idempotency_key
        ),
    )
    assert response["headers"]["status_code"] == status_code, (
        f"[TraceId: {response['headers']['trace_id']}]\n"
        f"Expect status_code: {status_code}\n"
        f"Actual status_code: {response['headers']['status_code']}"
    )

    if response["headers"]["status_code"] == "200":
        assert "transaction_id" in response["data"], (
            f"\nExpected data object contains transaction_id"
            f"\nActual data: {response['data']}"
        )

        context.data["TxId2"] = response["data"]["transaction_id"]

        assert response["data"]["transaction_status"] == "TRANSACTION_PENDING", (
            f"\nExpect data.account_status: TRANSACTION_PENDING"
            f"\nActual data.account_status: {response['data']['transaction_status']}, data: {response['data']}"
        )
    else:
        assert response["headers"]["message"] == message


@Then(
    "I settle transaction to transfer funds with below details for requested amount less than blocked amount and expect the header statuscode ([^']*)"
)
def settle_transaction_and_verify_status(
    context,
    status_code: str,
):
    request = context.request

    settle_tx_request_dto = DataClassParser.parse_row(
        context.table.rows[0], SettleTransactionRequestDTO
    )

    settle_tx_request_dto.transaction_id = context.data[settle_tx_request_dto.transaction_id]
    settle_tx_request_dto.customer_profile_id = context.data[
        settle_tx_request_dto.customer_profile_id
    ].customer_profile_id
    idempotency_key = settle_tx_request_dto.idempotency_key
    if (
        settle_tx_request_dto.overdraft_funding_account_id is not None
        and settle_tx_request_dto.overdraft_funding_account_id != ""
    ):
        settle_tx_request_dto.overdraft_funding_account_id = context.data[
            settle_tx_request_dto.overdraft_funding_account_id
        ].account_id
    else:
        settle_tx_request_dto.overdraft_funding_account_id = None

    response = request.hugoserve_put_request(
        path=f"/cash/v1/transaction/{settle_tx_request_dto.transaction_id}/settle",
        data=settle_tx_request_dto.get_dict(),
        headers=cash_helper.__get_default_cash_headers(
            settle_tx_request_dto.customer_profile_id, idempotency_key
        ),
    )
    assert response["headers"]["status_code"] == status_code, (
        f"[TraceId: {response['headers']['trace_id']}]\n"
        f"Expect status_code: {status_code}\n"
        f"Actual status_code: {response['headers']['status_code']}"
    )


@Then(
    "I check if we are getting same transaction_id for two requests for TxId1 ([^']*) and TxId2 ([^']*)"
)
def idempotency_and_verify_status(context, txid1, txid2):
    assert context.data[txid1] == context.data[txid2]
