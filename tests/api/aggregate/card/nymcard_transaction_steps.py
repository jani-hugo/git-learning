import uuid

from behave import *
from hugoutils.utilities.dataclass_util import DataClassParser
from retry import retry

from tests.api.aggregate.card import card_helper
from tests.api.aggregate.card.card_dataclass import (
    NymcardTransactionDTO,
    TransactionLogDTO,
    TransactionLogDetailDTO,
)
from datetime import datetime, timezone

use_step_matcher("re")


@Given("I set the following transaction information")
def set_transaction_info(context):
    txn_info = DataClassParser.parse_rows(
        context.table.rows, data_class=NymcardTransactionDTO
    )

    transaction_dto = {}
    for each_txn_info in txn_info:
        transaction_identifier = each_txn_info.transaction_identifier
        parent_transaction_identifier = each_txn_info.parent_transaction_identifier
        rrn_identifier = each_txn_info.rrn_identifier

        if parent_transaction_identifier:
            each_txn_info.parent_transaction_id = transaction_dto[
                parent_transaction_identifier
            ].id

        try:
            each_txn_info.rrn = context.data["nymcard_transactions"][
                "rrn_information_dict"
            ][rrn_identifier]
        except KeyError:
            rrn_information_dict = {}

            each_txn_info.rrn = card_helper.generate_random_number(8)
            rrn_information_dict[rrn_identifier] = each_txn_info.rrn

            transaction_dto["rrn_information_dict"] = rrn_information_dict

        each_txn_info.id = str(uuid.uuid4())
        each_txn_info.stan = card_helper.generate_random_number(8)
        each_txn_info.network_transaction_id = card_helper.generate_random_number(7)

        current_timestamp = card_helper.get_current_timestamp()
        each_txn_info.transaction_timestamp = current_timestamp
        each_txn_info.transmission_timestamp = current_timestamp
        each_txn_info.date_time_acquirer = current_timestamp

        transaction_dto[transaction_identifier] = each_txn_info

    context.data["nymcard_transactions"] = transaction_dto


@Then("I set card information in the transaction context")
def set_card_info(context):
    card_info = DataClassParser.parse_rows(
        context.table.rows, data_class=NymcardTransactionDTO
    )

    for each_card_info in card_info:
        transaction_identifier = each_card_info.transaction_identifier
        card_identifier = each_card_info.card_identifier

        try:
            card_information = context.data["nymcard_transactions"]["card_information"][
                card_identifier
            ]
        except KeyError:
            each_card_info.card_id = context.data[card_identifier]["card_id"]
            each_card_info.user_id = context.data[
                each_card_info.user_identifier
            ].end_customer_profile_id
            each_card_info.card_product_id = context.data["config_data"][
                "nymcard_card_product_id"
            ]
            each_card_info.card_first6_digits = card_helper.generate_random_number(6)
            each_card_info.card_last4_digits = card_helper.generate_random_number(4)
            each_card_info.card_expiry_date = "0101"

            context.data["nymcard_transactions"]["card_information"] = {
                card_identifier: each_card_info
            }
            card_information = each_card_info

        context.data["nymcard_transactions"][transaction_identifier].update(
            card_information
        )


@Then("I set merchant information in transaction context")
def set_merchant_info(context):
    merchant_info = DataClassParser.parse_rows(
        context.table.rows, data_class=NymcardTransactionDTO
    )

    for each_merchant_info in merchant_info:
        transaction_identifier = each_merchant_info.transaction_identifier

        context.data["nymcard_transactions"][transaction_identifier].update(
            each_merchant_info
        )


@Then("I set amount information in transaction context")
def set_amount_info(context):
    amount_info = DataClassParser.parse_rows(
        context.table.rows, data_class=NymcardTransactionDTO
    )

    for each_amount_info in amount_info:
        transaction_identifier = each_amount_info.transaction_identifier

        context.data["nymcard_transactions"][transaction_identifier].update(
            each_amount_info
        )


@Then("I set the following required indicators in transaction context")
def set_indicators(context):
    indicators_info = DataClassParser.parse_rows(
        context.table.rows, data_class=NymcardTransactionDTO
    )

    for each_indicators_info in indicators_info:
        transaction_identifier = each_indicators_info.transaction_identifier

        context.data["nymcard_transactions"][transaction_identifier].update(
            each_indicators_info
        )


@Then("I set clearing information in transaction context")
def set_interchange(context):
    interchange_info = DataClassParser.parse_rows(
        context.table.rows, data_class=NymcardTransactionDTO
    )

    for each_interchange_info in interchange_info:
        transaction_identifier = each_interchange_info.transaction_identifier

        context.data["nymcard_transactions"][transaction_identifier].update(
            each_interchange_info
        )


@When("I initiate below Nymcard Transaction requests")
def initiate_nymcard_transactions(context):
    request = context.request
    expected_nymcard_txn_responses = DataClassParser.parse_rows(
        context.table.rows, data_class=NymcardTransactionDTO
    )

    card_transactions = (
        context.data["card_transactions"] if "card_transactions" in context.data else {}
    )

    for expected_nymcard_txn_response in expected_nymcard_txn_responses:
        transaction_identifier = expected_nymcard_txn_response.transaction_identifier

        if expected_nymcard_txn_response.auto_clearing_ts is not None:
            context.data["nymcard_transactions"][
                transaction_identifier
            ].auto_clearing_ts = expected_nymcard_txn_response.auto_clearing_ts

        expected_nymcard_transaction = context.data["nymcard_transactions"][
            transaction_identifier
        ]

        transaction_message_type = expected_nymcard_transaction.message_type
        path = "authorization"
        if (
            transaction_message_type == "AUTHORIZATION"
            or transaction_message_type == "AUTHORIZATION_ADVICE"
        ):
            path = "authorization"
        elif (
            transaction_message_type == "FINANCIAL"
            or transaction_message_type == "FINANCIAL_ADVICE"
        ):
            path = "financial"
        elif (
            transaction_message_type == "REVERSAL"
            or transaction_message_type == "REVERSAL_ADVICE"
        ):
            path = "reversal"
        elif (
            transaction_message_type == "CLEARING"
            or transaction_message_type == "CLEARING_REVERSAL"
        ):
            path = "clearing"

        actual_nymcard_txn_response = request.hugoserve_post_request(
            path=f"/card/nymcard/transaction/{path}",
            data=expected_nymcard_transaction.get_dict(),
        )

        __assert_nymcard_transaction_response(
            actual_nymcard_txn_response,
            expected_nymcard_txn_response,
            expected_nymcard_transaction,
        )

        if expected_nymcard_txn_response.status_code == "1802":
            continue

        nymcard_transaction_id = actual_nymcard_txn_response["id"]

        response = request.hugoserve_get_request(
            path=f"/card/v1/dev/nymcard/transaction/{nymcard_transaction_id}"
        )
        assert response["headers"]["status_code"] == "200", (
            f"[TraceId: {response['headers']['trace_id']}]\n"
            f"Expect status_code: 200\n"
            f"Actual status_code: {response['headers']['status_code']}"
        )

        actual_nymcard_transaction = __parse_nymcard_transaction_to_dto(response)

        assert expected_nymcard_transaction == actual_nymcard_transaction, (
            f"[TraceId: {response['headers']['trace_id']}]\n"
            f"Expect NymcardTransactionDTO: {expected_nymcard_transaction}\n"
            f"Actual NymcardTransactionDTO: {actual_nymcard_transaction}"
        )

        service_transaction_id = response["data"]["service_transaction_id"]
        if service_transaction_id is None:
            service_transaction_id = uuid.uuid4()

        card_transactions[expected_nymcard_txn_response.transaction_identifier] = {
            "nymcard_transaction_id": nymcard_transaction_id,
            "service_transaction_id": service_transaction_id,
        }

    context.data["card_transactions"] = card_transactions


@Then("I validate TransactionLog entries for the performed Nymcard Transactions")
def validate_transaction_log(context):
    request = context.request
    transaction_logs_dto = DataClassParser.parse_rows(
        context.table.rows, data_class=TransactionLogDTO
    )

    nymcard_transactions = context.data["nymcard_transactions"]

    for expected_transaction_log in transaction_logs_dto:
        transaction_identifier = expected_transaction_log.transaction_identifier

        nymcard_transaction = nymcard_transactions[transaction_identifier]
        service_transaction_id = context.data["card_transactions"][
            transaction_identifier
        ]["service_transaction_id"]

        expected_transaction_log.transaction_id = service_transaction_id
        expected_transaction_log.card_id = nymcard_transaction.card_id

        if (
            expected_transaction_log.linked_transaction_ids is not None
            and expected_transaction_log.linked_transaction_ids != ""
            and expected_transaction_log.linked_transaction_ids
            != "UNKNOWN_AUTH_TRANSACTION_ID"
        ):
            linked_transaction_ids = (
                expected_transaction_log.linked_transaction_ids.split(", ")
            )
            list_of_linked_transaction_ids = []
            for each_linked_transaction_id in linked_transaction_ids:
                nymcard_transaction_id = context.data["nymcard_transactions"][
                    each_linked_transaction_id
                ].id
                response = request.hugoserve_get_request(
                    path=f"/card/v1/dev/nymcard/transaction/{nymcard_transaction_id}"
                )
                list_of_linked_transaction_ids.append(
                    response["data"]["service_transaction_id"]
                )
            expected_transaction_log.linked_transaction_ids = ",".join(
                sorted(list_of_linked_transaction_ids)
            )

        txn_check_max_wait_time = card_helper.card_providers_config["Nymcard"][
            "txn_check_max_wait_time"
        ]

        @retry(AssertionError, tries=txn_check_max_wait_time / 5, delay=5, logger=None)
        def retry_transaction_log_assert_fail(expected_tx_log_dto: TransactionLogDTO):
            response = request.hugoserve_get_request(
                path=f"/card/v1/dev/transaction/{service_transaction_id}"
            )

            assert "data" in response, (
                f"[Response: {response}] [ServiceTransactionId: {service_transaction_id}]\n"
                f"Expect transaction in response\n"
                f"Actual transaction not found in response"
            )

            actual_tx_log_dto = DataClassParser.parse_row(
                response["data"], data_class=TransactionLogDTO
            )

            if actual_tx_log_dto.linked_transaction_ids != "[]":
                actual_linked_transaction_ids = (
                    actual_tx_log_dto.linked_transaction_ids[1:-1].split(", ")
                )
                list_of_actual_linked_transaction_ids = []
                for each_linked_transaction_id in actual_linked_transaction_ids:
                    if each_linked_transaction_id[0] == " ":
                        list_of_actual_linked_transaction_ids.append(
                            each_linked_transaction_id[2:-1]
                        )
                    else:
                        list_of_actual_linked_transaction_ids.append(
                            each_linked_transaction_id[1:-1]
                        )
                actual_tx_log_dto.linked_transaction_ids = ",".join(
                    sorted(list_of_actual_linked_transaction_ids)
                )

            expected_tx_log_dto = TransactionLogDTO.sanitize_transaction_log(
                expected_tx_log_dto
            )

            assert expected_tx_log_dto == actual_tx_log_dto, (
                f"[TraceId: {response['headers']['trace_id']}]\n"
                f"Expect TransactionLog: {expected_tx_log_dto}\n"
                f"Actual TransactionLog: {actual_tx_log_dto}"
            )

        retry_transaction_log_assert_fail(expected_transaction_log)


@Then("I validate TransactionLogDetail entries for the performed Nymcard Transactions")
def validate_transaction_log_detail(context):
    request = context.request
    transaction_log_details_dto = DataClassParser.parse_rows(
        context.table.rows, data_class=TransactionLogDetailDTO
    )

    for expected_tx_log_detail in transaction_log_details_dto:
        transaction_identifier = expected_tx_log_detail.transaction_identifier
        service_transaction_id = context.data["card_transactions"][
            transaction_identifier
        ]["service_transaction_id"]

        expected_tx_log_detail.transaction_id = service_transaction_id

        idempotency_key = context.data["nymcard_transactions"][
            expected_tx_log_detail.idempotency_key
        ].id
        expected_tx_log_detail.idempotency_key = idempotency_key

        txn_check_max_wait_time = card_helper.card_providers_config["Nymcard"][
            "txn_check_max_wait_time"
        ]

        @retry(AssertionError, tries=txn_check_max_wait_time / 5, delay=5, logger=None)
        def retry_transaction_log_detail_assert_fail(
            expected_tx_log_detail_dto: TransactionLogDetailDTO,
        ):
            response = request.hugoserve_get_request(
                path=f"/card/v1/dev/transaction/{service_transaction_id}/log"
            )
            actual_tx_log_detail_dto = None
            for each_tx_log_detail in response["data"]["transactionLogDetail"]:
                if (
                    each_tx_log_detail["idempotency_key"]
                    == expected_tx_log_detail_dto.idempotency_key
                ):
                    actual_tx_log_detail_dto = DataClassParser.parse_row(
                        each_tx_log_detail, data_class=TransactionLogDetailDTO
                    )
                    break

            expected_tx_log_detail_dto = (
                TransactionLogDetailDTO.sanitize_transaction_log_detail(
                    expected_tx_log_detail_dto
                )
            )

            assert actual_tx_log_detail_dto is not None
            assert expected_tx_log_detail_dto == actual_tx_log_detail_dto, (
                f"[TraceId: {response['headers']['trace_id']}]\n"
                f"Expect TransactionLogDetail: {expected_tx_log_detail_dto}\n"
                f"Actual TransactionLogDetail: {actual_tx_log_detail_dto}"
            )

        retry_transaction_log_detail_assert_fail(expected_tx_log_detail)


@Then(
    "I update Nymcard Transaction auto clearing ts to current ts manually and trigger the auto clearing process for Nymcard Transactions"
)
def update_auto_clearing_ts(context):
    request = context.request
    expected_nymcard_auto_clear_update_responses = DataClassParser.parse_rows(
        context.table.rows, data_class=NymcardTransactionDTO
    )

    card_transactions = (
        context.data["card_transactions"] if "card_transactions" in context.data else {}
    )

    for (
        expected_nymcard_auto_clear_update_response
    ) in expected_nymcard_auto_clear_update_responses:
        transaction_identifier = (
            expected_nymcard_auto_clear_update_response.transaction_identifier
        )

        nymcard_transaction_id = card_transactions[transaction_identifier][
            "nymcard_transaction_id"
        ]

        # Get the current UTC time
        now = datetime.now(timezone.utc)

        timestamp_json = now.strftime("%Y-%m-%dT%H:%M:%S.%fZ")[:-4] + "Z"

        timestamp_request_dto = {"timestamp": timestamp_json}
        actual_nymcard_auto_clear_update_response = request.hugoserve_put_request(
            path=f"/card/v1/dev/nymcard/transaction/{nymcard_transaction_id}/update-auto-clearing-ts",
            data=timestamp_request_dto,
        )

        assert (
            actual_nymcard_auto_clear_update_response["headers"]["status_code"]
            == expected_nymcard_auto_clear_update_response.status_code
        ), (
            f"[TraceId: {actual_nymcard_auto_clear_update_response['headers']['trace_id']}]\n"
            f"Expect status_code: {expected_nymcard_auto_clear_update_response.status_code}\n"
            f"Actual status_code: {actual_nymcard_auto_clear_update_response['headers']['status_code']}"
        )

    initiate_auto_clearing_response = request.hugoserve_post_request(
        path=f"/card/v1/admin/nymcard/initiate-auto-clearing"
    )

    assert initiate_auto_clearing_response["headers"]["status_code"] == "200", (
        f"[TraceId: {initiate_auto_clearing_response['headers']['trace_id']}]\n"
        f"Expect status_code: 200\n"
        f"Actual status_code: {initiate_auto_clearing_response['headers']['status_code']}"
    )


@Then("I validate NymcardTransaction entry after auto clearing process")
def validate_nymcard_transaction_post_auto_clearing(context):
    request = context.request
    expected_nymcard_transaction_responses = DataClassParser.parse_rows(
        context.table.rows, data_class=NymcardTransactionDTO
    )

    card_transactions = (
        context.data["card_transactions"] if "card_transactions" in context.data else {}
    )

    for expected_nymcard_transaction_response in expected_nymcard_transaction_responses:
        transaction_identifier = (
            expected_nymcard_transaction_response.transaction_identifier
        )

        nymcard_transaction_id = card_transactions[transaction_identifier][
            "nymcard_transaction_id"
        ]

        response = request.hugoserve_get_request(
            path=f"/card/v1/dev/nymcard/transaction/{nymcard_transaction_id}"
        )

        assert response["data"]["auto_cleared_ts"] is not None, (
            "Expected: Auto cleared ts to be not None\n"
            "Actual: Auto cleared ts is None"
        )

        assert (
            response["data"]["processing_status_reason"]
            == expected_nymcard_transaction_response.processing_status_reason
        ), (
            f"[TraceId: {response['headers']['trace_id']}]\n"
            f"Expected processing_status_reason: {expected_nymcard_transaction_response.processing_status_reason}\n"
            f"Actual processing_status_reason: {response['data']['processing_status_reason']}"
        )


@Then(
    "I validate authorization TransactionLog entry for the performed Nymcard Transaction auto clearing"
)
def validate_auth_transaction_log_auto_clear(context):
    request = context.request
    transaction_logs_dto = DataClassParser.parse_rows(
        context.table.rows, data_class=TransactionLogDTO
    )

    nymcard_transactions = context.data["nymcard_transactions"]
    card_transactions = (
        context.data["card_transactions"] if "card_transactions" in context.data else {}
    )

    for expected_transaction_log in transaction_logs_dto:
        transaction_identifier = expected_transaction_log.transaction_identifier

        nymcard_transaction = nymcard_transactions[transaction_identifier]
        service_transaction_id = card_transactions[transaction_identifier][
            "service_transaction_id"
        ]

        expected_transaction_log.transaction_id = service_transaction_id
        expected_transaction_log.card_id = nymcard_transaction.card_id

        txn_check_max_wait_time = card_helper.card_providers_config["Nymcard"][
            "txn_check_max_wait_time"
        ]

        @retry(AssertionError, tries=txn_check_max_wait_time / 5, delay=5, logger=None)
        def retry_transaction_log_assert_fail(expected_tx_log_dto: TransactionLogDTO):
            response = request.hugoserve_get_request(
                path=f"/card/v1/dev/transaction/{service_transaction_id}"
            )

            assert "data" in response, (
                f"[Response: {response}] [ServiceTransactionId: {service_transaction_id}]\n"
                f"Expect transaction in response\n"
                f"Actual transaction not found in response"
            )

            actual_tx_log_dto = DataClassParser.parse_row(
                response["data"], data_class=TransactionLogDTO
            )

            expected_tx_log_dto = TransactionLogDTO.sanitize_transaction_log(
                expected_tx_log_dto
            )

            expected_tx_log_dto.linked_transaction_ids = (
                actual_tx_log_dto.linked_transaction_ids
            )
            context.data["card_transactions"][transaction_identifier][
                "linked_transaction_id"
            ] = actual_tx_log_dto.linked_transaction_ids[2:-2]

            assert expected_tx_log_dto == actual_tx_log_dto, (
                f"[TraceId: {response['headers']['trace_id']}]\n"
                f"Expect TransactionLog: {expected_tx_log_dto}\n"
                f"Actual TransactionLog: {actual_tx_log_dto}"
            )

        retry_transaction_log_assert_fail(expected_transaction_log)


@Then(
    "I validate clearing TransactionLog entry for the performed Nymcard Transaction auto clearing"
)
def validate_clear_transaction_log_auto_clear(context):
    request = context.request
    clear_transaction_logs_dto = DataClassParser.parse_rows(
        context.table.rows, data_class=TransactionLogDTO
    )

    nymcard_transactions = context.data["nymcard_transactions"]
    card_transactions = (
        context.data["card_transactions"] if "card_transactions" in context.data else {}
    )

    for expected_clear_transaction_log in clear_transaction_logs_dto:
        transaction_identifier = expected_clear_transaction_log.transaction_identifier

        nymcard_transaction = nymcard_transactions[transaction_identifier]
        linked_service_transaction_id = card_transactions[transaction_identifier][
            "linked_transaction_id"
        ]

        expected_clear_transaction_log.transaction_id = linked_service_transaction_id
        expected_clear_transaction_log.card_id = nymcard_transaction.card_id
        expected_clear_transaction_log.linked_transaction_ids = f"""['{(
            card_transactions[transaction_identifier]['service_transaction_id']
        )}']"""

        txn_check_max_wait_time = card_helper.card_providers_config["Nymcard"][
            "txn_check_max_wait_time"
        ]

        @retry(AssertionError, tries=txn_check_max_wait_time / 5, delay=5, logger=None)
        def retry_transaction_log_assert_fail(expected_tx_log_dto: TransactionLogDTO):
            response = request.hugoserve_get_request(
                path=f"/card/v1/dev/transaction/{linked_service_transaction_id}"
            )

            assert "data" in response, (
                f"[Response: {response}] [ServiceTransactionId: {linked_service_transaction_id}]\n"
                f"Expect transaction in response\n"
                f"Actual transaction not found in response"
            )

            actual_tx_log_dto = DataClassParser.parse_row(
                response["data"], data_class=TransactionLogDTO
            )

            expected_tx_log_dto = TransactionLogDTO.sanitize_transaction_log(
                expected_tx_log_dto
            )

            assert expected_tx_log_dto == actual_tx_log_dto, (
                f"[TraceId: {response['headers']['trace_id']}]\n"
                f"Expect TransactionLog: {expected_tx_log_dto}\n"
                f"Actual TransactionLog: {actual_tx_log_dto}"
            )

        retry_transaction_log_assert_fail(expected_clear_transaction_log)


def __assert_nymcard_transaction_response(
    actual_response, expected_response, request_dto
):
    assert actual_response["statusCode"] == expected_response.status_code, (
        f"[Response: {actual_response}]\n"
        f"Expected status_code : {expected_response.status_code} in response\n"
        f"Received status_code : {actual_response['statusCode']} in response"
    )

    assert actual_response["statusDescription"].startswith(
        expected_response.status_description
    ), (
        f"[Response: {actual_response}]\n"
        f"Expected status_description : {expected_response.status_description} in response\n"
        f"Received status_description : {actual_response['statusDescription']} in response"
    )

    assert actual_response["id"] == request_dto.id, (
        f"[Response: {actual_response}]\n"
        f"Expected transaction_id : {request_dto.id} in response\n"
        f"Received transaction_id : {actual_response['id']} in response"
    )

    assert actual_response["network"] == request_dto.network, (
        f"[Response: {actual_response}]\n"
        f"Expected network : {request_dto.network} in response\n"
        f"Received network : {actual_response['network']} in response"
    )

    assert actual_response["messageType"] == request_dto.message_type, (
        f"[Response: {actual_response}]\n"
        f"Expected message_type : {request_dto.message_type} in response\n"
        f"Received message_type : {actual_response['messageType']} in response"
    )

    assert actual_response["transactionType"] == request_dto.transaction_type, (
        f"[Response: {actual_response}]\n"
        f"Expected transaction_type : {request_dto.transaction_type} in response\n"
        f"Received transaction_type : {actual_response['transactionType']} in response"
    )

    assert actual_response["cardId"] == request_dto.card_id, (
        f"[Response: {actual_response}]\n"
        f"Expected card_id : {request_dto.card_id} in response\n"
        f"Received card_id : {actual_response['cardId']} in response"
    )

    assert actual_response["cardFirst6Digits"] == request_dto.card_first6_digits, (
        f"[Response: {actual_response}]\n"
        f"Expected card_first6_digits : {request_dto.card_first6_digits} in response\n"
        f"Received card_first6_digits : {actual_response['cardFirst6Digits']} in response"
    )

    assert actual_response["cardLast4Digits"] == request_dto.card_last4_digits, (
        f"[Response: {actual_response}]\n"
        f"Expected card_last4_digits : {request_dto.card_last4_digits} in response\n"
        f"Received card_last4_digits : {actual_response['cardLast4Digits']} in response"
    )

    assert actual_response["cardExpiryDate"] == request_dto.card_expiry_date, (
        f"[Response: {actual_response}]\n"
        f"Expected card_expiry_date : {request_dto.card_expiry_date} in response\n"
        f"Received card_expiry_date : {actual_response['cardExpiryDate']} in response"
    )


def __parse_nymcard_transaction_to_dto(actual_nymcard_transaction):
    actual_nymcard_transaction_dto = NymcardTransactionDTO

    actual_nymcard_transaction_dto.id = __fetch_key_from_map(
        actual_nymcard_transaction, ["data", "nymcard_transaction_id"]
    )
    actual_nymcard_transaction_dto.parent_transaction_id = __fetch_key_from_map(
        actual_nymcard_transaction, ["data", "transaction", "parent_transaction_id"]
    )
    actual_nymcard_transaction_dto.sms_clearing_transaction_id = __fetch_key_from_map(
        actual_nymcard_transaction, ["data", "sms_clearing_transaction_id"]
    )
    actual_nymcard_transaction_dto.transaction_timestamp = __fetch_key_from_map(
        actual_nymcard_transaction, ["data", "transaction", "transaction_timestamp"]
    )
    actual_nymcard_transaction_dto.network = __fetch_key_from_map(
        actual_nymcard_transaction, ["data", "network"]
    )
    actual_nymcard_transaction_dto.message_type = __fetch_key_from_map(
        actual_nymcard_transaction, ["data", "message_type"]
    )
    actual_nymcard_transaction_dto.transaction_type = __fetch_key_from_map(
        actual_nymcard_transaction, ["data", "transaction_type"]
    )
    actual_nymcard_transaction_dto.transaction_description = __fetch_key_from_map(
        actual_nymcard_transaction, ["data", "transaction_description"]
    )
    actual_nymcard_transaction_dto.transmission_timestamp = __fetch_key_from_map(
        actual_nymcard_transaction, ["data", "transaction", "transmission_timestamp"]
    )
    actual_nymcard_transaction_dto.date_time_acquirer = __fetch_key_from_map(
        actual_nymcard_transaction, ["data", "transaction", "date_time_acquirer"]
    )

    actual_nymcard_transaction_dto.user_id = __fetch_key_from_map(
        actual_nymcard_transaction, ["data", "user_id"]
    )
    actual_nymcard_transaction_dto.card_id = __fetch_key_from_map(
        actual_nymcard_transaction, ["data", "card_id"]
    )
    actual_nymcard_transaction_dto.card_product_id = __fetch_key_from_map(
        actual_nymcard_transaction, ["data", "card", "card_product_id"]
    )
    actual_nymcard_transaction_dto.card_first6_digits = __fetch_key_from_map(
        actual_nymcard_transaction, ["data", "card", "card_first6_digits"]
    )
    actual_nymcard_transaction_dto.card_last4_digits = __fetch_key_from_map(
        actual_nymcard_transaction, ["data", "card", "card_last4_digits"]
    )
    actual_nymcard_transaction_dto.card_expiry_date = __fetch_key_from_map(
        actual_nymcard_transaction, ["data", "card", "card_expiry_date"]
    )

    actual_nymcard_transaction_dto.acquirer_id = __fetch_key_from_map(
        actual_nymcard_transaction, ["data", "merchant", "acquirer_id"]
    )
    actual_nymcard_transaction_dto.merchant_id = __fetch_key_from_map(
        actual_nymcard_transaction, ["data", "merchant", "merchant_id"]
    )
    actual_nymcard_transaction_dto.mcc = __fetch_key_from_map(
        actual_nymcard_transaction, ["data", "merchant", "mcc"]
    )
    actual_nymcard_transaction_dto.merchant_name = __fetch_key_from_map(
        actual_nymcard_transaction, ["data", "merchant", "merchant_name"]
    )
    actual_nymcard_transaction_dto.merchant_city = __fetch_key_from_map(
        actual_nymcard_transaction, ["data", "merchant", "merchant_city"]
    )
    actual_nymcard_transaction_dto.merchant_country = __fetch_key_from_map(
        actual_nymcard_transaction, ["data", "merchant", "merchant_country"]
    )
    actual_nymcard_transaction_dto.terminal_id = __fetch_key_from_map(
        actual_nymcard_transaction, ["data", "merchant", "terminal_id"]
    )

    actual_nymcard_transaction_dto.rrn = __fetch_key_from_map(
        actual_nymcard_transaction, ["data", "rrn"]
    )
    actual_nymcard_transaction_dto.stan = __fetch_key_from_map(
        actual_nymcard_transaction, ["data", "transaction", "system_trace_audit_number"]
    )
    actual_nymcard_transaction_dto.network_transaction_id = __fetch_key_from_map(
        actual_nymcard_transaction, ["data", "network_transaction_id"]
    )

    actual_nymcard_transaction_dto.transaction_amount = __fetch_key_from_map(
        actual_nymcard_transaction, ["data", "transaction", "transaction_amount"]
    )
    actual_nymcard_transaction_dto.transaction_currency = __fetch_key_from_map(
        actual_nymcard_transaction, ["data", "transaction", "transaction_currency"]
    )
    actual_nymcard_transaction_dto.billing_amount = __fetch_key_from_map(
        actual_nymcard_transaction, ["data", "transaction", "billing_amount"]
    )
    actual_nymcard_transaction_dto.billing_currency = __fetch_key_from_map(
        actual_nymcard_transaction, ["data", "transaction", "billing_currency"]
    )
    actual_nymcard_transaction_dto.original_transaction_amount = __fetch_key_from_map(
        actual_nymcard_transaction,
        ["data", "transaction", "original_transaction_amount"],
    )
    actual_nymcard_transaction_dto.original_billing_amount = __fetch_key_from_map(
        actual_nymcard_transaction, ["data", "transaction", "original_billing_amount"]
    )

    actual_nymcard_transaction_dto.incremental_transaction = __fetch_key_from_map(
        actual_nymcard_transaction, ["data", "transaction", "incremental_transaction"]
    )
    actual_nymcard_transaction_dto.is_pre_auth = __fetch_key_from_map(
        actual_nymcard_transaction, ["data", "transaction", "is_pre_auth"]
    )
    actual_nymcard_transaction_dto.eci = __fetch_key_from_map(
        actual_nymcard_transaction, ["data", "transaction", "eci"]
    )
    actual_nymcard_transaction_dto.card_entry = __fetch_key_from_map(
        actual_nymcard_transaction, ["data", "transaction", "card_entry"]
    )
    actual_nymcard_transaction_dto.pos_environment = __fetch_key_from_map(
        actual_nymcard_transaction, ["data", "transaction", "pos_environment"]
    )
    actual_nymcard_transaction_dto.pin_present = __fetch_key_from_map(
        actual_nymcard_transaction, ["data", "transaction", "pin_present"]
    )
    actual_nymcard_transaction_dto.moto = __fetch_key_from_map(
        actual_nymcard_transaction, ["data", "transaction", "moto"]
    )
    actual_nymcard_transaction_dto.performed_operation_type = __fetch_key_from_map(
        actual_nymcard_transaction, ["data", "transaction", "performed_operation_type"]
    )
    actual_nymcard_transaction_dto.processing_code = __fetch_key_from_map(
        actual_nymcard_transaction, ["data", "transaction", "processing_code"]
    )
    actual_nymcard_transaction_dto.three_DS_indicator = __fetch_key_from_map(
        actual_nymcard_transaction, ["data", "transaction", "three_ds_indicator"]
    )

    actual_nymcard_transaction_dto.settlement_status = __fetch_key_from_map(
        actual_nymcard_transaction, ["data", "clearing", "clearing_outcome"]
    )
    actual_nymcard_transaction_dto.interchange_fee = __fetch_key_from_map(
        actual_nymcard_transaction, ["data", "clearing", "interchange_fee"]
    )
    actual_nymcard_transaction_dto.interchange_fee_indicator = __fetch_key_from_map(
        actual_nymcard_transaction, ["data", "clearing", "interchange_fee_indicator"]
    )

    actual_nymcard_transaction_dto.auto_clearing_ts = __fetch_key_from_map(
        actual_nymcard_transaction, ["data", "auto_clearing_ts"]
    )
    actual_nymcard_transaction_dto.auto_cleared_ts = __fetch_key_from_map(
        actual_nymcard_transaction, ["data", "auto_cleared_ts"]
    )

    actual_nymcard_transaction_dto.create_ts = __fetch_key_from_map(
        actual_nymcard_transaction, ["data", "create_ts"]
    )
    actual_nymcard_transaction_dto.update_ts = __fetch_key_from_map(
        actual_nymcard_transaction, ["data", "update_ts"]
    )

    return actual_nymcard_transaction_dto


def __fetch_key_from_map(map, address_list):
    curr_data = map
    for address_point in address_list:
        if curr_data.get(address_point) is None:
            return None
        curr_data = curr_data.get(address_point)

    return curr_data
