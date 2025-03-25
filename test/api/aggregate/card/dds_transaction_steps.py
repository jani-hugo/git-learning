import uuid

from aggregate.card import card_helper
from aggregate.card.card_dataclass import (
    AcquirerDTO,
    CardDTO,
    ClearingDTO,
    CustomerDTO,
    DynamicDataStreamDTO,
    DynamicDataStreamResponseDTO,
    StatusDTO,
    TransactionDTO,
    TransactionLogDetailDTO,
    TransactionLogDTO,
    UpdateDTO,
)
from behave import *
from common.utils import DataClassParser
from retry import retry
from datetime import datetime, timezone

use_step_matcher("re")


@Given("I build below transactions")
def build_transactions(context):
    dto_request = DataClassParser.parse_rows(
        context.table.rows, data_class=DynamicDataStreamDTO
    )

    transaction_dto = {}
    for each_dto_request in dto_request:
        transaction_identifier = each_dto_request.transaction_identifier
        transaction_dto[transaction_identifier] = each_dto_request

    context.data["dynamic_data_streams"] = transaction_dto


@Then("I set card objects in transaction context")
def set_card_in_context(context):
    card_dto_request = DataClassParser.parse_rows(context.table.rows, data_class=CardDTO)

    for each_card_dto in card_dto_request:
        transaction_identifier = each_card_dto.transaction_identifier
        card_identifier = each_card_dto.card_identifier
        each_card_dto.card_id = context.data[card_identifier]["card_id"]

        transaction_dto = context.data["dynamic_data_streams"][transaction_identifier]
        transaction_dto.card = each_card_dto


@Then("I set customer objects in transaction context")
def set_customer_in_context(context):
    customer_dto_request = DataClassParser.parse_rows(
        context.table.rows, data_class=CustomerDTO
    )
    for each_customer_dto in customer_dto_request:
        transaction_identifier = each_customer_dto.transaction_identifier
        card_account_identifier = each_customer_dto.customer_identifier

        each_customer_dto.customer_id = context.data[card_account_identifier]["card_account_id"]

        transaction_dto = context.data["dynamic_data_streams"][transaction_identifier]
        transaction_dto.customer = each_customer_dto


@Then("I set transaction objects in transaction context")
def set_transaction_in_context(context):
    txn_dto_request = DataClassParser.parse_rows(context.table.rows, data_class=TransactionDTO)

    transaction_details = {}
    txn_amounts = {}
    for each_txn_dto in txn_dto_request:
        # TODO: need to set this in feature file
        each_txn_dto.credential_on_file = 'y'
        transaction_identifier = each_txn_dto.transaction_identifier
        transaction_id = each_txn_dto.transaction_id
        transaction_amount = each_txn_dto.transaction_amount
        transaction_currency_code = each_txn_dto.transaction_currency_code
        billing_amount = each_txn_dto.cardholder_billing_amount
        billing_currency_code = each_txn_dto.cardholder_billing_currency_code
        if len(transaction_amount) == 0 and each_txn_dto.reversal_type == "FULL":
            transaction_amount = '0'

        if len(transaction_amount) == 0 and len(billing_amount) == 0:
            transaction_amount = 0
            billing_amount = 0
        elif len(transaction_amount) == 0:
            transaction_amount = billing_amount
            transaction_currency_code = billing_currency_code
        elif len(billing_amount) == 0:
            billing_amount = transaction_amount
            billing_currency_code = transaction_currency_code

        txn_amounts[transaction_identifier] = {
            "transaction_amount": transaction_amount,
            "transaction_currency_code": transaction_currency_code,
            "billing_amount": billing_amount,
            "billing_currency_code": billing_currency_code,
        }

        context.data["txn_amounts"] = txn_amounts
        system_trace_audit_number = each_txn_dto.system_trace_audit_number
        retrieval_reference_number = each_txn_dto.retrieval_reference_number
        network_transaction_id = each_txn_dto.network_transaction_id

        if transaction_id in transaction_details:
            transaction_id = transaction_details[transaction_id]
            system_trace_audit_number = transaction_details[system_trace_audit_number]
        else:
            transaction_id = str(uuid.uuid4())
            system_trace_audit_number = card_helper.generate_random_number(6)

            transaction_details[each_txn_dto.transaction_id] = transaction_id
            transaction_details[each_txn_dto.system_trace_audit_number] = (
                system_trace_audit_number
            )

        if retrieval_reference_number in transaction_details:
            retrieval_reference_number = transaction_details[retrieval_reference_number]
        else:
            retrieval_reference_number = (
                card_helper.generate_random_number(6) + system_trace_audit_number
            )
            transaction_details[each_txn_dto.retrieval_reference_number] = (
                retrieval_reference_number
            )

        if network_transaction_id in transaction_details:
            network_transaction_id = transaction_details[network_transaction_id]
        else:
            network_transaction_id = card_helper.generate_random_number(15)
            transaction_details[each_txn_dto.network_transaction_id] = (
                network_transaction_id
            )

        each_txn_dto.system_trace_audit_number = system_trace_audit_number
        each_txn_dto.retrieval_reference_number = retrieval_reference_number
        each_txn_dto.network_transaction_id = network_transaction_id
        each_txn_dto.transaction_id = transaction_id

        if len(each_txn_dto.transaction_amount) != 0:
            each_txn_dto.transaction_amount = card_helper.calculate_precision(
                transaction_currency_code, each_txn_dto.transaction_amount
            )

        if len(each_txn_dto.cardholder_billing_amount) != 0:
            each_txn_dto.cardholder_billing_amount = card_helper.calculate_precision(
                billing_currency_code, each_txn_dto.cardholder_billing_amount
            )

        transaction_dto = context.data["dynamic_data_streams"][transaction_identifier]
        transaction_dto.transaction = each_txn_dto

    context.data["transaction_info"] = transaction_details


@Then("I set update in transaction context")
def set_update_in_context(context):
    update_dto_request = DataClassParser.parse_rows(context.table.rows, data_class=UpdateDTO)

    transaction_details = context.data["transaction_info"] if "transaction_info" in context.data.keys() else {}
    for each_update_dto in update_dto_request:
        transaction_identifier = each_update_dto.transaction_identifier
        transaction_dto = context.data["dynamic_data_streams"][transaction_identifier]
        original_transaction_id = each_update_dto.original_transaction_id
        if original_transaction_id not in transaction_details:
            original_transaction_id = str(uuid.uuid4())
            transaction_details[each_update_dto.original_transaction_id] = (
                original_transaction_id
            )
        each_update_dto.original_transaction_id = transaction_details[each_update_dto.original_transaction_id]

        original_system_trace_audit_number = each_update_dto.original_system_trace_audit_number
        each_update_dto.original_system_trace_audit_number = context.data["transaction_info"][
            original_system_trace_audit_number
        ]

        original_retrieval_reference_number = (
            each_update_dto.original_retrieval_reference_number
        )
        each_update_dto.original_retrieval_reference_number = context.data["transaction_info"][
            original_retrieval_reference_number
        ]

        original_transaction_amount = each_update_dto.original_transaction_amount
        actual_transaction_amount = each_update_dto.actual_transaction_amount
        transaction_currency_code = context.data["dynamic_data_streams"][
            transaction_identifier
        ].transaction.transaction_currency_code

        if len(transaction_currency_code) > 0 and len(original_transaction_amount) > 0:
            each_update_dto.original_transaction_amount = card_helper.calculate_precision(
                transaction_currency_code, original_transaction_amount
            )

        # Conditionally set actual transaction amount as it is not mandatory in case of full reversal
        if (
            len(transaction_currency_code) > 0
            and actual_transaction_amount is not None
            and len(actual_transaction_amount) > 0
        ):
            each_update_dto.actual_transaction_amount = card_helper.calculate_precision(
                transaction_currency_code, actual_transaction_amount
            )
        transaction_dto.transaction.update = each_update_dto


@Then("I set status in transaction context")
def set_status_in_context(context):
    status_dto_request = DataClassParser.parse_rows(context.table.rows, data_class=StatusDTO)

    for each_status_dto in status_dto_request:
        transaction_identifier = each_status_dto.transaction_identifier
        transaction_dto = context.data["dynamic_data_streams"][transaction_identifier]
        transaction_dto.transaction.status = each_status_dto


@Then("I set acquirer objects in transaction context")
def set_acquirer_in_context(context):
    acquirer_dto_request = DataClassParser.parse_rows(
        context.table.rows, data_class=AcquirerDTO
    )

    for each_acquirer_dto in acquirer_dto_request:
        transaction_identifier = each_acquirer_dto.transaction_identifier
        transaction_dto = context.data["dynamic_data_streams"][transaction_identifier]
        transaction_dto.acquirer = each_acquirer_dto
        if len(transaction_dto.acquirer.acquiring_institution_country_code) == 0:
            transaction_dto.acquirer.acquiring_institution_country_code = context.data[
                "txn_amounts"
            ][transaction_identifier]["transaction_currency_code"]


@Then("I set clearing objects in transaction context")
def set_clearing_in_context(context):
    clearing_dto_request = DataClassParser.parse_rows(
        context.table.rows, data_class=ClearingDTO
    )
    txn_amounts = context.data["txn_amounts"] if "txn_amounts" in context.data.keys() else {}
    authorization_dict = {}
    transaction_details = (
        context.data["transaction_info"] if "transaction_info" in context.data.keys() else {}
    )
    for each_clearing_dto in clearing_dto_request:
        transaction_identifier = each_clearing_dto.transaction_identifier
        record_id_clearing = each_clearing_dto.record_id_clearing
        if record_id_clearing not in transaction_details:
            record_id_clearing = str(uuid.uuid4())
            transaction_details[each_clearing_dto.record_id_clearing] = record_id_clearing
        each_clearing_dto.record_id_clearing = record_id_clearing
        if each_clearing_dto.card_id != None:
            card_identifier = each_clearing_dto.card_id
            card_id = context.data[card_identifier]["card_id"]
            each_clearing_dto.card_id = card_id

        transaction_amount = each_clearing_dto.transaction_amount
        transaction_currency_code = each_clearing_dto.transaction_currency_code
        if len(transaction_amount) != 0:
            each_clearing_dto.transaction_amount = card_helper.calculate_precision(
                transaction_currency_code, transaction_amount
            )

        billing_amount = each_clearing_dto.billing_amount
        billing_currency_code = each_clearing_dto.billing_currency_code
        each_clearing_dto.billing_amount = card_helper.calculate_precision(
            billing_currency_code, billing_amount
        )

        txn_amounts[transaction_identifier] = {
            "transaction_amount": transaction_amount,
            "transaction_currency_code": transaction_currency_code,
            "billing_amount": billing_amount,
            "billing_currency_code": billing_currency_code,
        }
        authorizations = []
        authorization_dict[transaction_identifier] = authorizations

        transaction_dto = context.data["dynamic_data_streams"][transaction_identifier]
        transaction_dto.clearing = each_clearing_dto

    context.data["txn_amounts"] = txn_amounts
    context.data["clearing_authorizations"] = authorization_dict
    context.data["transaction_info"] = transaction_details


@Then("I set authorizations to be cleared in transaction context")
def set_clearing_authorization(context):
    clearing_authorization_dto = DataClassParser.parse_rows(
        context.table.rows, data_class=ClearingDTO.ClearingAuthDTO
    )

    for each_authorization in clearing_authorization_dto:
        transaction_identifier = each_authorization.transaction_identifier
        auth_transaction_id = each_authorization.auth_transaction_id
        system_trace_audit_number = each_authorization.system_trace_audit_number
        retrieval_reference_number = each_authorization.retrieval_reference_number

        if auth_transaction_id not in context.data["transaction_info"].keys():
            each_authorization.auth_transaction_id = str(uuid.uuid4())
        else:
            each_authorization.auth_transaction_id = context.data["transaction_info"][
                auth_transaction_id
            ]

        if system_trace_audit_number not in context.data["transaction_info"].keys():
            each_authorization.system_trace_audit_number = card_helper.generate_random_number(6)
        else:
            each_authorization.system_trace_audit_number = context.data["transaction_info"][
                system_trace_audit_number
            ]

        if retrieval_reference_number not in context.data["transaction_info"].keys():
            each_authorization.retrieval_reference_number = (
                card_helper.generate_random_number(6)
                + each_authorization.system_trace_audit_number
            )
        else:
            each_authorization.retrieval_reference_number = context.data["transaction_info"][
                retrieval_reference_number
            ]

        authorizations = context.data["clearing_authorizations"][transaction_identifier]
        authorizations.append(each_authorization)
        context.data["dynamic_data_streams"][
            transaction_identifier
        ].clearing.authorizations = authorizations
        context.data["clearing_authorizations"][transaction_identifier] = authorizations


@When("I initiate below Dynamic Data Stream transaction requests")
def initiate_transaction(context):
    request = context.request
    dds_response_dtos = DataClassParser.parse_rows(
        context.table.rows, data_class=DynamicDataStreamResponseDTO
    )

    card_transactions = (
        context.data["card_transactions"] if "card_transactions" in context.data else {}
    )
    for expected_dds_response_dto in dds_response_dtos:
        if expected_dds_response_dto.auto_clearing_ts is not None:
            context.data["dynamic_data_streams"][expected_dds_response_dto.transaction_identifier].auto_clearing_ts = (
                expected_dds_response_dto.auto_clearing_ts
            )

        expected_dds_dto = context.data["dynamic_data_streams"][
            expected_dds_response_dto.transaction_identifier
        ]
        if expected_dds_dto.message_type == 'administrative':
            pass
        elif expected_dds_dto.message_type == 'clearing':
            expected_dds_dto.clearing.transaction_currency = (
                expected_dds_response_dto.transaction_currency
            )
            expected_dds_dto.clearing.billing_currency = (
                expected_dds_response_dto.cardholder_billing_currency
            )
        else:
            expected_dds_dto.transaction.transaction_currency = (
                expected_dds_response_dto.transaction_currency
            )
            expected_dds_dto.transaction.cardholder_billing_currency = (
                expected_dds_response_dto.cardholder_billing_currency
            )

        path = "request"
        if expected_dds_dto.message_type == "authorization":
            path = "request"
        elif expected_dds_dto.message_type == "clearing":
            path = "clearing"
        elif expected_dds_dto.message_type == "administrative":
            path = "administrative"

        response = request.hugoserve_post_request(
            path=f"/card/clowd9/{path}", data=expected_dds_dto.get_dict()
        )

        if expected_dds_response_dto.case_type == "bad_request":
            assert int(response["code"]) == 400, (
                f"[Response: {response}]\n"
                f"Expect case_type: bad_request\n"
                f"Actual case_type: {expected_dds_response_dto.case_type}"
            )
            continue
        elif expected_dds_response_dto.case_type == "positive":
            __assert_dds_response_dto(expected_dds_dto, expected_dds_response_dto, response)
        else:
            raise NotImplementedError(
                f"Case type {expected_dds_response_dto.case_type} is not yet implemented!"
            )

        # TODO: need to do correct validation for messages of type 'administrative'
        if expected_dds_dto.message_type == 'administrative':
            continue
        if expected_dds_dto.message_type == "clearing":
            clowd9_transaction_id = expected_dds_dto.clearing.record_id_clearing
        else:
            clowd9_transaction_id = response["transaction"]["transaction_id"]

        response = request.hugoserve_get_request(
            path=f"/card/v1/dev/clowd9/dds/{clowd9_transaction_id}"
        )
        assert response["headers"]["status_code"] == "200", (
            f"[TraceId: {response['headers']['trace_id']}]\n"
            f"Expect status_code: 200\n"
            f"Actual status_code: {response['headers']['status_code']}"
        )

        if expected_dds_response_dto.is_empty_service_tx_id:
            # Set valid UUID to actual_dds_dto prevent assertion failure
            # This case is specially for unsolicited reversals
            response['data']['service_transaction_id'] = uuid.uuid4()
        actual_dds_dto = DataClassParser.parse_row(response['data'], DynamicDataStreamDTO)

        expected_dds_dto = DynamicDataStreamDTO.sanitize_dynamic_data_stream(expected_dds_dto)
        assert expected_dds_dto == actual_dds_dto, (
            f"[TraceId: {response['headers']['trace_id']}]\n"
            f"Expect DynamicDataStreamDTO: {expected_dds_dto}\n"
            f"Actual DynamicDataStreamDTO: {actual_dds_dto}"
        )

        service_transaction_id = response["data"]["service_transaction_id"]

        card_transactions[expected_dds_response_dto.transaction_identifier] = {
            "clowd9_transaction_id": clowd9_transaction_id,
            "service_transaction_id": service_transaction_id,
        }
        # TODO: Validate DynamicDataStream entries

    context.data["card_transactions"] = card_transactions



@Then("I validate below Transaction entries")
def validate_transaction_log(context):
    request = context.request
    transaction_logs_dto = DataClassParser.parse_rows(
        context.table.rows, data_class=TransactionLogDTO
    )
    dds_dict = context.data["dynamic_data_streams"]

    for expected_tx_log in transaction_logs_dto:
        # TODO: Validate with retry for status like SETTLED
        transaction_identifier = expected_tx_log.transaction_identifier
        dds = dds_dict[transaction_identifier]
        service_transaction_id = context.data["card_transactions"][transaction_identifier][
            "service_transaction_id"
        ]

        expected_tx_log.transaction_id = service_transaction_id
        expected_tx_log.card_id = (
            dds.clearing.card_id if dds.message_type == 'clearing' else dds.card.card_id
        )

        if (
            expected_tx_log.linked_transaction_ids is not None
            and expected_tx_log.linked_transaction_ids != ''
            and expected_tx_log.linked_transaction_ids != "UNKNOWN_AUTH_TRANSACTION_ID"
        ):
            linked_transaction_ids = expected_tx_log.linked_transaction_ids.split(", ")
            list_of_linked_transaction_ids = []
            for each_linked_transaction_id in linked_transaction_ids:
                clowd9_transaction_id = context.data["transaction_info"][
                    each_linked_transaction_id
                ]
                response = request.hugoserve_get_request(
                    path=f"/card/v1/dev/clowd9/dds/{clowd9_transaction_id}"
                )
                list_of_linked_transaction_ids.append(
                    response["data"]["service_transaction_id"]
                )
            expected_tx_log.linked_transaction_ids = ','.join(
                sorted(list_of_linked_transaction_ids)
            )
        txn_check_max_wait_time = card_helper.card_providers_config["Clowd9"][
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
            # TODO: need to standardise this parsing logic
            if actual_tx_log_dto.linked_transaction_ids != '[]':
                linked_transaction_ids = actual_tx_log_dto.linked_transaction_ids[1:-1].split(
                    ", "
                )
                list_of_linked_transaction_ids = []
                for each_linked_transaction_id in linked_transaction_ids:
                    if each_linked_transaction_id[0] == ' ':
                        list_of_linked_transaction_ids.append(each_linked_transaction_id[2:-1])
                    else:
                        list_of_linked_transaction_ids.append(each_linked_transaction_id[1:-1])
                actual_tx_log_dto.linked_transaction_ids = ','.join(
                    sorted(list_of_linked_transaction_ids)
                )

            expected_tx_log_dto = TransactionLogDTO.sanitize_transaction_log(
                expected_tx_log_dto
            )
            assert expected_tx_log_dto == actual_tx_log_dto, (
                f"[TraceId: {response['headers']['trace_id']}]\n"
                f"Expect TransactionLog: {expected_tx_log_dto}\n"
                f"Actual TransactionLog: {actual_tx_log_dto}"
            )

        retry_transaction_log_assert_fail(expected_tx_log)


@Then("I validate below TransactionLog entries")
def validate_transaction_log_details(context):
    request = context.request
    transaction_log_details_dto = DataClassParser.parse_rows(
        context.table.rows, data_class=TransactionLogDetailDTO
    )

    for expected_tx_log_detail in transaction_log_details_dto:
        transaction_identifier = expected_tx_log_detail.transaction_identifier
        service_transaction_id = context.data["card_transactions"][transaction_identifier][
            "service_transaction_id"
        ]

        expected_tx_log_detail.transaction_id = service_transaction_id

        idempotency_key = context.data["transaction_info"][
            expected_tx_log_detail.idempotency_key
        ]
        expected_tx_log_detail.idempotency_key = idempotency_key

        txn_check_max_wait_time = card_helper.card_providers_config["Clowd9"][
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
            for each_tx_log_detail in response['data']['transactionLogDetail']:
                if (
                    each_tx_log_detail['idempotency_key']
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
        # TODO @Abhishek

@Then("I update DDS Transaction auto clearing ts to current ts manually and trigger the auto clearing process for DDS Transactions")
def update_auto_clearing_ts(context):
    request = context.request
    dds_response_dtos = DataClassParser.parse_rows(
        context.table.rows, data_class=DynamicDataStreamResponseDTO
    )

    card_transactions = (
        context.data["card_transactions"] if "card_transactions" in context.data else {}
    )
    for expected_dds_response_dto in dds_response_dtos:
        transaction_identifier = expected_dds_response_dto.transaction_identifier

        clowd9_transaction_id = card_transactions[transaction_identifier]['clowd9_transaction_id']

        # Get the current UTC time
        now = datetime.now(timezone.utc)

        timestamp_json = now.strftime('%Y-%m-%dT%H:%M:%S.%fZ')[:-4] + 'Z'

        timestamp_request_dto = {
            "timestamp": timestamp_json
        }
        actual_clowd9_auto_clear_update_response = request.hugoserve_put_request(
            path=f"/card/v1/dev/clowd9/dds/{clowd9_transaction_id}/update-auto-clearing-ts",
            data=timestamp_request_dto,
        )

        assert actual_clowd9_auto_clear_update_response['headers']['status_code'] == expected_dds_response_dto.status_code, (
            f"[TraceId: {actual_clowd9_auto_clear_update_response['headers']['trace_id']}]\n"
            f"Expect status_code: {expected_dds_response_dto.status_code}\n"
            f"Actual status_code: {actual_clowd9_auto_clear_update_response['headers']['status_code']}"
        )

    initiate_auto_clearing_response = request.hugoserve_post_request(
        path=f"/card/v1/admin/clowd9/initiate-auto-clearing"
    )

    assert  initiate_auto_clearing_response['headers']['status_code'] == "200", (
        f"[TraceId: {initiate_auto_clearing_response['headers']['trace_id']}]\n"
        f"Expect status_code: 200\n"
        f"Actual status_code: {initiate_auto_clearing_response['headers']['status_code']}"
    )

@Then("I validate DynamicDataStream entry after auto clearing process")
def validate_clowd9_transaction_post_auto_clearing(context):
    request = context.request
    dds_response_dtos = DataClassParser.parse_rows(
        context.table.rows, data_class=DynamicDataStreamResponseDTO
    )

    card_transactions = (
        context.data["card_transactions"] if "card_transactions" in context.data else {}
    )
    for expected_dds_response_dto in dds_response_dtos:
        transaction_identifier = expected_dds_response_dto.transaction_identifier

        clowd9_transaction_id = card_transactions[transaction_identifier]["clowd9_transaction_id"]

        response = request.hugoserve_get_request(
            path=f"/card/v1/dev/clowd9/dds/{clowd9_transaction_id}"
        )

        assert response['data']['auto_cleared_ts'] is not None, (
            "Expected: Auto cleared ts to be not None\n"
            "Actual: Auto cleared ts is None"
        )

        assert response['data']['status_reason'] == expected_dds_response_dto.status_reason, (
            f"[TraceId: {response['headers']['trace_id']}]\n"
            f"Expected status_reason: {expected_dds_response_dto.status_reason}\n"
            f"Actual status_reason: {response['data']['status_reason']}"
        )

@Then("I validate authorization TransactionLog entry for the performed DDS Transaction auto clearing")
def validate_auth_transaction_log_auto_clear(context):
    request = context.request
    transaction_logs_dto = DataClassParser.parse_rows(
        context.table.rows, data_class=TransactionLogDTO
    )

    dds_transactions = context.data["dynamic_data_streams"]
    card_transactions = (context.data["card_transactions"] if "card_transactions" in context.data else {})

    for expected_tx_log in transaction_logs_dto:
        transaction_identifier = expected_tx_log.transaction_identifier

        dds_transaction = dds_transactions[transaction_identifier]
        service_transaction_id = card_transactions[transaction_identifier][
            "service_transaction_id"
        ]

        expected_tx_log.transaction_id = service_transaction_id
        expected_tx_log.card_id = (
            dds_transaction.clearing.card_id if dds_transaction.message_type == 'clearing' else dds_transaction.card.card_id
        )

        txn_check_max_wait_time = card_helper.card_providers_config["Clowd9"][
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

            expected_tx_log_dto.linked_transaction_ids = actual_tx_log_dto.linked_transaction_ids
            context.data['card_transactions'][transaction_identifier]['linked_transaction_id'] = (
                actual_tx_log_dto.linked_transaction_ids[2:-2]
            )

            assert expected_tx_log_dto == actual_tx_log_dto, (
                f"[TraceId: {response['headers']['trace_id']}]\n"
                f"Expect TransactionLog: {expected_tx_log_dto}\n"
                f"Actual TransactionLog: {actual_tx_log_dto}"
            )

        retry_transaction_log_assert_fail(expected_tx_log)

@Then("I validate clearing TransactionLog entry for the performed DDS Transaction auto clearing")
def validate_clear_transaction_log_auto_clear(context):
    request = context.request
    clear_transaction_logs_dto = DataClassParser.parse_rows(
        context.table.rows, data_class=TransactionLogDTO
    )

    dds_transactions = context.data["dynamic_data_streams"]
    card_transactions = (context.data["card_transactions"] if "card_transactions" in context.data else {})

    for expected_clear_transaction_log in clear_transaction_logs_dto:
        transaction_identifier = expected_clear_transaction_log.transaction_identifier

        dds_transaction = dds_transactions[transaction_identifier]
        linked_service_transaction_id = card_transactions[transaction_identifier][
            "linked_transaction_id"
        ]

        expected_clear_transaction_log.transaction_id = linked_service_transaction_id
        expected_clear_transaction_log.card_id = (
            dds_transaction.clearing.card_id if dds_transaction.message_type == 'clearing' else dds_transaction.card.card_id
        )
        expected_clear_transaction_log.linked_transaction_ids = f"""['{(
            card_transactions[transaction_identifier]['service_transaction_id']
        )}']"""

        txn_check_max_wait_time = card_helper.card_providers_config["Clowd9"][
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

def __assert_dds_response_dto(
    expected_dds_dto, expected_dds_response_dto, actual_dds_response_dto
):
    assert "transaction" in actual_dds_response_dto, (
        f"[Response: {actual_dds_response_dto}]\n"
        f"Expect transaction in response\n"
        f"Actual transaction not found in response"
    )
    assert "outcome" in actual_dds_response_dto["transaction"], (
        f"[Response: {actual_dds_response_dto}]\n"
        f"Expect outcome in transaction\n"
        f"Actual outcome not found in transaction"
    )
    assert "response_code" in actual_dds_response_dto["transaction"]["outcome"], (
        f"[Response: {actual_dds_response_dto}]\n"
        f"Expect response_code in transaction outcome\n"
        f"Actual response_code not found in transaction outcome"
    )
    assert expected_dds_response_dto.message_type == actual_dds_response_dto["message_type"], (
        f"[Response: {actual_dds_response_dto}]\n"
        f"Expect message_type: {expected_dds_response_dto.message_type}\n"
        f"Actual message_type: {actual_dds_response_dto['message_type']}"
    )
    expected_message_qual = (
        "response"
        if expected_dds_dto.message_qualifier == "request"
        else "notification acknowledged"
    )
    assert expected_message_qual == actual_dds_response_dto["message_qualifier"], (
        f"[Response: {actual_dds_response_dto}]\n"
        f"Expect message_qualifier: {expected_message_qual}\n"
        f"Actual message_qualifier: {actual_dds_response_dto['message_qualifier']}"
    )

    if (
        expected_dds_response_dto.message_type == 'authorization'
        and expected_dds_response_dto.message_type == 'reversal'
    ):
        assert card_helper.is_valid_uuid(actual_dds_response_dto["card"]["card_id"]), (
            f"[Response: {actual_dds_response_dto}]\n"
            f"Expect card_id: {actual_dds_response_dto['card']['card_id']} as valid UUID"
        )
        assert card_helper.is_valid_uuid(
            actual_dds_response_dto["transaction"]["transaction_id"]
        ), (
            f"[Response: {actual_dds_response_dto}]\n"
            f"Expect card_id: {actual_dds_response_dto['transaction']['transaction_id']} as valid UUID"
        )
        expected_authorized_tx_amount = card_helper.round_up(
            card_helper.calculate_precision(
                expected_dds_response_dto.transaction_currency_code,
                expected_dds_response_dto.authorized_tx_amount,
            ),
            0,
        )
        assert float(expected_authorized_tx_amount) == float(
            actual_dds_response_dto["transaction"]["transaction_amount"]
        ), (
            f"[Response: {actual_dds_response_dto}]\n"
            f"Expect authorized_tx_amount: {expected_authorized_tx_amount}\n"
            f"Actual authorized_tx_amount: {actual_dds_response_dto['transaction']['transaction_amount']}"
        )
        assert (
            expected_dds_response_dto.transaction_currency_code
            == actual_dds_response_dto["transaction"]["transaction_currency_code"]
        ), (
            f"[Response: {actual_dds_response_dto}]\n"
            f"Expect transaction_currency_code: {expected_dds_response_dto.transaction_currency_code}\n"
            f"Actual transaction_currency_code: {actual_dds_response_dto['transaction']['transaction_currency_code']}"
        )

    assert (
        expected_dds_response_dto.response_code
        == actual_dds_response_dto["transaction"]["outcome"]["response_code"]
    ), (
        f"[Response: {actual_dds_response_dto}]\n"
        f"Expect response_code: {expected_dds_response_dto.response_code}\n"
        f"Actual response_code: {actual_dds_response_dto['transaction']['outcome']['response_code']}"
    )
    assert (
        expected_dds_response_dto.response_reason
        == actual_dds_response_dto["transaction"]["outcome"]["response_reason"]
    ), (
        f"[Response: {actual_dds_response_dto}]\n"
        f"Expect response_reason: {expected_dds_response_dto.response_reason}\n"
        f"Actual response_reason: {actual_dds_response_dto['transaction']['outcome']['response_reason']}"
    )
    assert (
        "HugoServe" == actual_dds_response_dto["transaction"]["outcome"]["response_source"]
    ), (
        f"[Response: {actual_dds_response_dto}]\n"
        f"Expect response_reason: HugoServe\n"
        f"Actual response_reason: {actual_dds_response_dto['transaction']['outcome']['response_source']}"
    )
