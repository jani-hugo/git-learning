from hugoutils.utilities.dataclass_util import DataClassParser

from test.api.aggregate.payment import helper as payment_helper
from test.api.aggregate.payment.payment_dataclass import (
    DevDepositRequestDTO,
    RefundRequestDTO,
    TransferOutRequestDTO,
    BillPaymentRequestDTO,
)
from behave import *
from retry import retry

use_step_matcher("re")


@Then(
    "I initiate transfer out to transfer funds with below details from ([^']*) and expect the header status ([^']*) and status as ([^']*)"
)
def transfer_out(
    context, request_origin: str, status_code: str, transaction_status: str
):
    request = context.request

    transfer_out_request_dto = DataClassParser.parse_row(
        context.table.rows[0], TransferOutRequestDTO
    )
    transfer_out_request_dto.account_id = context.data[
        transfer_out_request_dto.account_id
    ]["account_id"]
    receiver_account_id = context.data[transfer_out_request_dto.receiver_account_id]

    customer_profile_id = context.data[
        transfer_out_request_dto.customer_profile_id
    ].customer_profile_id
    account_details = payment_helper.__fetch_payment_account(
        customer_profile_id, context, receiver_account_id
    )
    transfer_out_request_dto.customer_profile_id = customer_profile_id
    transfer_out_request_dto.transfer_out_account_details.code_details.sg_bank_details.account_number = (
        account_details.account_details.code_details.sg_code_details.account_number
    )
    transfer_out_request_dto.transfer_out_account_details.account_holder_name = (
        account_details.account_details.account_holder_name
    )
    process_transfer_out_request(
        context,
        transfer_out_request_dto,
        customer_profile_id,
        request_origin,
        status_code,
        transaction_status,
    )


@Then(
    "I initiate transfer out to transfer funds to same account with below details from ([^']*) and expect the header status ([^']*) and status as ([^']*)"
)
def transfer_out(
    context, request_origin: str, status_code: str, transaction_status: str
):
    request = context.request

    transfer_out_request_dto = DataClassParser.parse_row(
        context.table.rows[0], TransferOutRequestDTO
    )
    transfer_out_request_dto.account_id = context.data[
        transfer_out_request_dto.account_id
    ]["account_id"]
    receiver_account_id = context.data[transfer_out_request_dto.receiver_account_id][
        "account_id"
    ]

    customer_profile_id = context.data[
        transfer_out_request_dto.customer_profile_id
    ].customer_profile_id
    account_details = payment_helper.__fetch_payment_account(
        customer_profile_id, context, receiver_account_id
    )
    transfer_out_request_dto.transfer_out_account_details.code_details.sg_bank_details.account_number = (
        account_details.account_details.code_details.sg_code_details.account_number
    )
    transfer_out_request_dto.transfer_out_account_details.account_holder_name = (
        account_details.account_details.account_holder_name
    )
    process_transfer_out_request(
        context,
        transfer_out_request_dto,
        customer_profile_id,
        request_origin,
        status_code,
        transaction_status,
    )


@Then(
    "I initiate transfer out to transfer funds between 2 different master accounts of 2 different customer profiles with below details from ([^']*) and expect the header status ([^']*) and status as ([^']*)"
)
def transfer_out(
    context, request_origin: str, status_code: str, transaction_status: str
):
    request = context.request

    transfer_out_request_dto = DataClassParser.parse_row(
        context.table.rows[0], TransferOutRequestDTO
    )
    transfer_out_request_dto.account_id = context.data[
        transfer_out_request_dto.account_id
    ].master_account_id
    receiver_account_id = context.data[
        transfer_out_request_dto.receiver_account_id
    ].master_account_id
    receiver_customer_profile_id = context.data[
        transfer_out_request_dto.receiver_account_id
    ].customer_profile_id

    customer_profile_id = context.data[
        transfer_out_request_dto.customer_profile_id
    ].customer_profile_id
    receiver_account_details = payment_helper.__fetch_master_account(
        receiver_customer_profile_id, context, receiver_account_id
    )
    transfer_out_request_dto.transfer_out_account_details.code_details.sg_bank_details.account_number = (
        receiver_account_details.account_details.code_details.sg_code_details.account_number
    )
    transfer_out_request_dto.transfer_out_account_details.account_holder_name = (
        receiver_account_details.account_details.account_holder_name
    )
    process_transfer_out_request(
        context,
        transfer_out_request_dto,
        customer_profile_id,
        request_origin,
        status_code,
        transaction_status,
    )


@Then(
    "I initiate transfer out to transfer funds between from customer profile ([^']*) master account to account under different customer profile ([^']*) with below details from ([^']*) and expect the header status ([^']*) and status as ([^']*)"
)
def transfer_out(
    context,
    customer_identifier: str,
    receiver_identifier: str,
    request_origin: str,
    status_code: str,
    transaction_status: str,
):
    request = context.request
    transfer_out_request_dto = DataClassParser.parse_row(
        context.table.rows[0], TransferOutRequestDTO
    )
    transfer_out_request_dto.account_id = context.data[
        transfer_out_request_dto.account_id
    ].master_account_id
    receiver_account_id = context.data[transfer_out_request_dto.receiver_account_id]
    receiver_customer_profile_id = context.data[receiver_identifier].customer_profile_id

    customer_profile_id = context.data[
        transfer_out_request_dto.customer_profile_id
    ].customer_profile_id
    receiver_account_details = payment_helper.__fetch_payment_account(
        receiver_customer_profile_id, context, receiver_account_id
    )
    transfer_out_request_dto.transfer_out_account_details.code_details.sg_bank_details.account_number = (
        receiver_account_details.account_details.code_details.sg_code_details.account_number
    )
    transfer_out_request_dto.transfer_out_account_details.account_holder_name = (
        receiver_account_details.account_details.account_holder_name
    )
    process_transfer_out_request(
        context,
        transfer_out_request_dto,
        customer_profile_id,
        request_origin,
        status_code,
        transaction_status,
    )


@Then(
    "I initiate transfer out to transfer funds between from customer profile ([^']*) account to master account under different customer profile ([^']*) with below details from ([^']*) and expect the header status ([^']*) and status as ([^']*)"
)
def transfer_out(
    context,
    customer_identifier: str,
    receiver_identifier: str,
    request_origin: str,
    status_code: str,
    transaction_status: str,
):
    request = context.request
    transfer_out_request_dto = DataClassParser.parse_row(
        context.table.rows[0], TransferOutRequestDTO
    )
    transfer_out_request_dto.account_id = context.data[
        transfer_out_request_dto.account_id
    ]
    receiver_account_id = context.data[
        transfer_out_request_dto.receiver_account_id
    ].master_account_id
    receiver_customer_profile_id = context.data[receiver_identifier].customer_profile_id

    customer_profile_id = context.data[
        transfer_out_request_dto.customer_profile_id
    ].customer_profile_id
    receiver_account_details = payment_helper.__fetch_master_account(
        receiver_customer_profile_id, context, receiver_account_id
    )
    transfer_out_request_dto.transfer_out_account_details.code_details.sg_bank_details.account_number = (
        receiver_account_details.account_details.code_details.sg_code_details.account_number
    )
    transfer_out_request_dto.transfer_out_account_details.account_holder_name = (
        receiver_account_details.account_details.account_holder_name
    )
    process_transfer_out_request(
        context,
        transfer_out_request_dto,
        customer_profile_id,
        request_origin,
        status_code,
        transaction_status,
    )


@Then(
    "I initiate transfer out to transfer funds between from customer profile ([^']*) account to account under different customer profile ([^']*) with below details from ([^']*) and expect the header status ([^']*) and status as ([^']*)"
)
def transfer_out(
    context,
    customer_identifier: str,
    receiver_identifier: str,
    request_origin: str,
    status_code: str,
    transaction_status: str,
):
    request = context.request
    transfer_out_request_dto = DataClassParser.parse_row(
        context.table.rows[0], TransferOutRequestDTO
    )
    transfer_out_request_dto.account_id = context.data[
        transfer_out_request_dto.account_id
    ]
    receiver_account_id = context.data[transfer_out_request_dto.receiver_account_id]
    receiver_customer_profile_id = context.data[receiver_identifier].customer_profile_id

    customer_profile_id = context.data[
        transfer_out_request_dto.customer_profile_id
    ].customer_profile_id
    receiver_account_details = payment_helper.__fetch_payment_account(
        receiver_customer_profile_id, context, receiver_account_id
    )
    transfer_out_request_dto.transfer_out_account_details.code_details.sg_bank_details.account_number = (
        receiver_account_details.account_details.code_details.sg_code_details.account_number
    )
    transfer_out_request_dto.transfer_out_account_details.account_holder_name = (
        receiver_account_details.account_details.account_holder_name
    )
    process_transfer_out_request(
        context,
        transfer_out_request_dto,
        customer_profile_id,
        request_origin,
        status_code,
        transaction_status,
    )


@Then(
    "I initiate transfer out to transfer funds from master account to account under same master account with below details from ([^']*) and expect the header status ([^']*) and status as ([^']*)"
)
def transfer_out(
    context, request_origin: str, status_code: str, transaction_status: str
):
    request = context.request

    transfer_out_request_dto = DataClassParser.parse_row(
        context.table.rows[0], TransferOutRequestDTO
    )
    transfer_out_request_dto.account_id = context.data[
        transfer_out_request_dto.account_id
    ].master_account_id
    receiver_account_id = context.data[transfer_out_request_dto.receiver_account_id]

    customer_profile_id = context.data[
        transfer_out_request_dto.customer_profile_id
    ].customer_profile_id
    receiver_account_details = payment_helper.__fetch_payment_account(
        customer_profile_id, context, receiver_account_id
    )
    transfer_out_request_dto.transfer_out_account_details.code_details.sg_bank_details.account_number = (
        receiver_account_details.account_details.code_details.sg_code_details.account_number
    )
    transfer_out_request_dto.transfer_out_account_details.account_holder_name = (
        receiver_account_details.account_details.account_holder_name
    )
    process_transfer_out_request(
        context,
        transfer_out_request_dto,
        customer_profile_id,
        request_origin,
        status_code,
        transaction_status,
    )


@Then(
    "I initiate transfer out to transfer funds from account to master account with below details from ([^']*) and expect the header status ([^']*) and status as ([^']*)"
)
def transfer_out(
    context, request_origin: str, status_code: str, transaction_status: str
):
    request = context.request

    transfer_out_request_dto = DataClassParser.parse_row(
        context.table.rows[0], TransferOutRequestDTO
    )
    transfer_out_request_dto.account_id = context.data[
        transfer_out_request_dto.account_id
    ]
    receiver_account_id = context.data[
        transfer_out_request_dto.receiver_account_id
    ].master_account_id

    customer_profile_id = context.data[
        transfer_out_request_dto.customer_profile_id
    ].customer_profile_id
    receiver_account_details = payment_helper.__fetch_master_account(
        customer_profile_id, context, receiver_account_id
    )
    transfer_out_request_dto.transfer_out_account_details.code_details.sg_bank_details.account_number = (
        receiver_account_details.account_details.code_details.sg_code_details.account_number
    )
    transfer_out_request_dto.transfer_out_account_details.account_holder_name = (
        receiver_account_details.account_details.account_holder_name
    )
    process_transfer_out_request(
        context,
        transfer_out_request_dto,
        customer_profile_id,
        request_origin,
        status_code,
        transaction_status,
    )


@Then(
    "I initiate transfer out to transfer funds to an external account from ([^']*) and expect the header status ([^']*) and status as ([^']*)"
)
def transfer_out(
    context, request_origin: str, status_code: str, transaction_status: str
):
    request = context.request

    transfer_out_request_dto = DataClassParser.parse_row(
        context.table.rows[0], TransferOutRequestDTO
    )
    transfer_out_request_dto.account_id = context.data[
        transfer_out_request_dto.account_id
    ]["account_id"]

    customer_profile_id = context.data[
        transfer_out_request_dto.customer_profile_id
    ].customer_profile_id

    process_transfer_out_request(
        context,
        transfer_out_request_dto,
        customer_profile_id,
        request_origin,
        status_code,
        transaction_status,
    )


def process_transfer_out_request(
    context,
    transfer_out_request_dto,
    customer_profile_id,
    request_origin,
    status_code,
    transaction_status,
):
    request = context.request
    response = request.hugoserve_post_request(
        path=f"/payment/v1/transaction/transfer-out",
        data=transfer_out_request_dto.get_dict(),
        headers=payment_helper.__get_default_payment_headers(
            customer_profile_id, request_origin
        ),
    )

    assert response["headers"]["status_code"] == status_code
    if response["headers"]["status_code"] == "200":
        assert "transaction_id" in response["data"], (
            f"\nExpected data object contains transaction_id"
            f"\nActual data: {response['data']}"
        )
        assert response["data"]["txn_status"] == transaction_status, (
            f"\nExpect data.account_status: {transaction_status}"
            f"\nActual data.account_status: {response['data']['txn_status']}, data: {response['data']}"
        )
        context.data[transfer_out_request_dto.identifier] = response["data"][
            "transaction_id"
        ]


@Then(
    "I wait until max time to verify the transaction ([^']*) status as ([^']*) for customerProfileId ([^']*) from ([^']*)"
)
def wait_and_verify_transaction_status(
    context,
    identifier: str,
    transaction_status: str,
    customer_profile_identifier: str,
    request_origin: str,
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
            f"/payment/v1/transaction/{transaction_id}",
            headers=payment_helper.__get_default_payment_headers(
                customer_profile_id, request_origin
            ),
        )
        assert response["headers"]["status_code"] == "200"
        assert response["data"] is not None
        assert response["data"]["txn_status"] == transaction_status
        if response["data"] is not None:
            assert response["data"]["txn_status"] == transaction_status, print(
                f"\nExpect data.txn_status: {transaction_status}"
                f"\nActual data.txn_status: {response['data']['txn_status']}, data: {response['data']}"
            )

    retry_for_transaction_status()


@Then(
    "I initiate refund for transaction with below details from ([^']*) expect the header statuscode ([^']*)"
)
def refund_transaction(context, request_origin: str, status_code: str):
    request = context.request

    refund_tx_request_dto = DataClassParser.parse_row(
        context.table.rows[0], RefundRequestDTO
    )
    refund_tx_request_dto.original_transaction_id = context.data[
        refund_tx_request_dto.original_transaction_id
    ]

    refund_tx_request_dto.customer_profile_id = context.data[
        refund_tx_request_dto.customer_profile_id
    ].customer_profile_id

    response = request.hugoserve_post_request(
        path=f"/payment/v1/transaction/refund",
        data=refund_tx_request_dto.get_dict(),
        headers=payment_helper.__get_default_payment_headers(
            refund_tx_request_dto.customer_profile_id, request_origin
        ),
    )

    assert response["headers"]["status_code"] == status_code
    if response["headers"]["status_code"] == "200":
        assert "transaction_id" in response["data"], (
            f"\nExpected data object contains transaction_id"
            f"\nActual data: {response['data']}"
        )

        context.data["TxId2"] = response["data"]["transaction_id"]

        assert response["data"]["txn_status"] == "TRANSACTION_SETTLED", (
            f"\nExpect data.account_status: TRANSACTION_SETTLED"
            f"\nActual data.account_status: {response['data']['txn_status']}, data: {response['data']}"
        )


@Given(
    "I deposit an amount of ([^']*) into master account ([^']*) using DevDeposit expect the header status ([^']*)"
)
def deposit_using_dev(context, amount: float, account_id: str, status_code: str):
    request = context.request

    dev_deposit_dto = DataClassParser.parse_row(
        context.table.rows[0], DevDepositRequestDTO
    )

    dev_deposit_dto.account_id = context.data[account_id].master_account_id
    customer_profile_id = context.data[
        dev_deposit_dto.customer_profile_id
    ].customer_profile_id

    response = request.hugoserve_post_request(
        path=f"/payment/v1/dev/transaction/deposit",
        data=dev_deposit_dto.get_dict(),
        headers=payment_helper.__get_default_payment_headers(
            customer_profile_id, request_origin="CASH_SERVICE"
        ),
    )
    assert response["headers"]["status_code"] == status_code
    if response["headers"]["status_code"] == "200":
        assert response["headers"]["message"] == "Success"
        assert (
            "data" in response
        ), f"\nExpected non-empty data object, found empty. Response:{response}"

        assert "transaction_id" in response["data"], (
            f"\nExpected data object contains transaction_id"
            f"\nActual data: {response['data']}"
        )
        dev_deposit_dto.transaction_id = response["data"]["transaction_id"]
        context.data[dev_deposit_dto.identifier] = dev_deposit_dto.transaction_id


@Given(
    "I deposit an amount of ([^']*) into ([^']*) using DevDeposit expect the header status ([^']*)"
)
def deposit_using_dev(context, amount: float, account_id: str, status_code: str):
    request = context.request

    dev_deposit_dto = DataClassParser.parse_row(
        context.table.rows[0], DevDepositRequestDTO
    )

    dev_deposit_dto.account_id = context.data[account_id]
    customer_profile_id = context.data[
        dev_deposit_dto.customer_profile_id
    ].customer_profile_id

    response = request.hugoserve_post_request(
        path=f"/payment/v1/dev/transaction/deposit",
        data=dev_deposit_dto.get_dict(),
        headers=payment_helper.__get_default_payment_headers(
            customer_profile_id, request_origin="CASH_SERVICE"
        ),
    )
    assert response["headers"]["status_code"] == status_code
    if response["headers"]["status_code"] == "200":
        assert response["headers"]["message"] == "Success"
        assert (
            "data" in response
        ), f"\nExpected non-empty data object, found empty. Response:{response}"

        assert "transaction_id" in response["data"], (
            f"\nExpected data object contains transaction_id"
            f"\nActual data: {response['data']}"
        )
        dev_deposit_dto.transaction_id = response["data"]["transaction_id"]
        context.data[dev_deposit_dto.identifier] = dev_deposit_dto.transaction_id


@Then(
    "I initiate transfer out to transfer funds to an external account from ([^']*) and expect the header status ([^']*) with error status as ([^']*)"
)
def transfer_out_error(
    context, request_origin: str, status_code: str, error_status: str
):
    request = context.request

    transfer_out_request_dto = DataClassParser.parse_row(
        context.table.rows[0], TransferOutRequestDTO
    )
    transfer_out_request_dto.account_id = context.data[
        transfer_out_request_dto.account_id
    ]["account_id"]

    customer_profile_id = context.data[
        transfer_out_request_dto.customer_profile_id
    ].customer_profile_id

    process_transfer_out_request(
        context,
        transfer_out_request_dto,
        customer_profile_id,
        request_origin,
        error_status,
        "null",
    )


@Then(
    "I initiate transfer out to transfer funds internally with below details from ([^']*) and expect the header status ([^']*) and status as ([^']*) in Paysys"
)
def transfer_out(
    context, request_origin: str, status_code: str, transaction_status: str
):
    request = context.request

    transfer_out_request_dto = DataClassParser.parse_row(
        context.table.rows[0], TransferOutRequestDTO
    )
    transfer_out_request_dto.account_id = context.data[
        transfer_out_request_dto.account_id
    ]["account_id"]
    receiver_account_id = context.data[transfer_out_request_dto.receiver_account_id]

    customer_profile_id = context.data[
        transfer_out_request_dto.customer_profile_id
    ].customer_profile_id
    account_details = payment_helper.__fetch_payment_account(
        customer_profile_id, context, receiver_account_id
    )

    transfer_out_request_dto.transfer_out_account_details.code_details.pk_bank_details.account_number = (
        account_details.account_details.code_details.pk_code_details.account_number
    )
    transfer_out_request_dto.transfer_out_account_details.code_details.pk_bank_details.bank_bic = (
        account_details.account_details.code_details.pk_code_details.bank_bic
    )
    transfer_out_request_dto.transfer_out_account_details.code_details.pk_bank_details.bank_imd = (
        account_details.account_details.code_details.pk_code_details.bank_imd
    )
    transfer_out_request_dto.transfer_out_account_details.code_details.pk_bank_details.iban = (
        account_details.account_details.code_details.pk_code_details.iban
    )
    transfer_out_request_dto.transfer_out_account_details.account_holder_name = (
        account_details.account_details.account_holder_name
    )
    process_transfer_out_request(
        context,
        transfer_out_request_dto,
        customer_profile_id,
        request_origin,
        status_code,
        transaction_status,
    )


@Then(
    "I initiate transfer out to transfer funds to an external account from ([^']*) and expect the header status ([^']*) and status as ([^']*) in Paysys"
)
def transfer_out(
    context, request_origin: str, status_code: str, transaction_status: str
):
    request = context.request

    transfer_out_request_dto = DataClassParser.parse_row(
        context.table.rows[0], TransferOutRequestDTO
    )
    transfer_out_request_dto.account_id = context.data[
        transfer_out_request_dto.account_id
    ]["account_id"]

    customer_profile_id = context.data[
        transfer_out_request_dto.customer_profile_id
    ].customer_profile_id

    process_transfer_out_request(
        context,
        transfer_out_request_dto,
        customer_profile_id,
        request_origin,
        status_code,
        transaction_status,
    )


@Then(
    "I initiate bill payment to transfer funds to an external biller from ([^']*) and expect the header status ([^']*) and status as ([^']*) in Paysys"
)
def bill_payment(
    context, request_origin: str, status_code: str, transaction_status: str
):
    bill_payment_request_dto = DataClassParser.parse_row(
        context.table.rows[0], BillPaymentRequestDTO
    )

    bill_payment_request_dto.account_id = context.data[
        bill_payment_request_dto.account_id
    ]["account_id"]
    customer_profile_id = context.data[
        bill_payment_request_dto.customer_profile_id
    ].customer_profile_id

    process_bill_payment_request(
        context,
        bill_payment_request_dto,
        customer_profile_id,
        request_origin,
        status_code,
        transaction_status,
    )


def process_bill_payment_request(
    context,
    bill_payment_request_dto,
    customer_profile_id,
    request_origin,
    status_code,
    transaction_status,
):
    request = context.request
    response = request.hugoserve_post_request(
        path=f"/payment/v1/transaction/bill-payment",
        data=bill_payment_request_dto.get_dict(),
        headers=payment_helper.__get_default_payment_headers(
            customer_profile_id, request_origin
        ),
    )

    assert response["headers"]["status_code"] == status_code
    if response["headers"]["status_code"] == "200":
        assert "transaction_id" in response["data"], (
            f"\nExpected data object contains transaction_id"
            f"\nActual data: {response['data']}"
        )
        assert response["data"]["txn_status"] == transaction_status, (
            f"\nExpect data.account_status: {transaction_status}"
            f"\nActual data.account_status: {response['data']['transaction_status']}, data: {response['data']}"
        )
        context.data[bill_payment_request_dto.identifier] = response["data"][
            "transaction_id"
        ]
