import uuid

from hugoutils.utilities.dataclass_util import DataClassParser

from tests.api.aggregate.ledger.ledger_dataclass import (
    CreateLedgerDTO,
    CreateLedgerTransactionDTO,
    LedgerDTO,
    LedgerTransactionDTO,
    MergeLedgerTransactionRequestDTO,
    SplitTransactionRequestDTO,
    UpdateTransactionRequestDTO,
)
from behave import Given, Step, Then, use_step_matcher
from requests import HTTPError

use_step_matcher("re")


@Given("I create below ledgers")
def create_ledgers(context):
    request = context.request

    ledger_dto_list = DataClassParser.parse_rows(
        context.table.rows, data_class=CreateLedgerDTO
    )

    for ledger_dto in ledger_dto_list:
        data = ledger_dto.get_dict()
        if ledger_dto.profile_type == "END_CUSTOMER":
            data["end_customer_profile_id"] = ledger_dto.profile_id
        response = request.hugoserve_post_request(
            path="/ledger/v1/account/create",
            data=ledger_dto.get_dict(),
            headers=__get_default_ledger_headers(
                context.data["config_data"]["customer_profile_id"]
            ),
        )
        ledger_dto.ledger_id = response["data"]["ledger_id"]  # Save ledger_id in object

        assert (
            ledger_dto.ledger_id not in context.data
        ), f"An existing ledger_id: {ledger_dto.ledger_id} found while creating ledgers"
        context.data[ledger_dto.identifier] = (
            ledger_dto  # Save ledger_dto against identifier
        )


@Then("I verify ledgers exist with values")
def verify_ledger_exist(context):
    request = context.request

    ledger_dto_list = DataClassParser.parse_rows(
        context.table.rows, data_class=LedgerDTO
    )

    for expected_ledger_dto in ledger_dto_list:
        ledger_id = context.data[expected_ledger_dto.identifier].ledger_id
        response = request.hugoserve_get_request(
            path="/ledger/v1/account/" + ledger_id,
            headers=__get_default_ledger_headers(
                context.data["config_data"]["customer_profile_id"]
            ),
        )["data"]

        actual_ledger_dto = DataClassParser.dict_to_object(
            response, data_class=LedgerDTO
        )

        sanitized_expected = LedgerDTO.sanitize_ledger_dto(expected_ledger_dto)
        sanitized_actual = LedgerDTO.sanitize_ledger_dto(actual_ledger_dto)
        assert sanitized_expected == sanitized_actual, (
            f"\nExpect ledger_dto: {sanitized_expected}"
            f"\nActual ledger_dto: {sanitized_actual}"
        )


@Step("I delete the above created ledger")
def delete_ledger(context):
    request = context.request

    ledgers_to_delete = DataClassParser.row_to_dict(context.table.rows)

    for ledger_to_delete in ledgers_to_delete:
        identifier = ledger_to_delete["identifier"]
        ledger_id = context.data[identifier].ledger_id
        header_status_code = request.hugoserve_delete_request(
            path="/ledger/v1/account/" + ledger_id,
            headers=__get_default_ledger_headers(
                context.data["config_data"]["customer_profile_id"]
            ),
        )["headers"]["status_code"]

        assert "200" == header_status_code, (
            f"\nExpect headers.status_code: 200"
            f"\nActual headers.status_code: {header_status_code}"
        )


@Step("I verify ledger doesn't exist")
def verify_ledger_not_exist(context):
    request = context.request

    deleted_ledgers = DataClassParser.row_to_dict(context.table.rows)

    for deleted_ledger in deleted_ledgers:
        identifier = deleted_ledger["identifier"]
        ledger_id = context.data[identifier].ledger_id

        response = request.hugoserve_get_request(
            path="/ledger/v1/account/" + ledger_id,
            headers=__get_default_ledger_headers(
                context.data["config_data"]["customer_profile_id"]
            ),
        )

        assert (
            "data" not in response
        ), f"\nExpect response.data: <empty> \nActual response.data: {response['data']}"
        status_code = response["headers"]["status_code"]
    assert status_code == "LSM_9101", (
        f"\nExpect status_code: LSM_9101" f"\nActual status_code: {status_code}"
    )


@Given("I attempt to create ledger with invalid datatype and verify create failed")
def create_ledger_with_invalid_datatype_verify_fail(context):
    request = context.request

    ledger_dto = DataClassParser.row_to_dict(context.table.rows)[0]

    http_error_raised = False
    try:
        request.hugoserve_post_request(
            path="/ledger/v1/account/create",
            data=ledger_dto,
            headers=__get_default_ledger_headers(
                context.data["config_data"]["customer_profile_id"]
            ),
        )
    except HTTPError:
        http_error_raised = True

    assert (
        True is http_error_raised
    ), f"\nExpected HTTPError for the request, but no exception occurred"


@Given("I attempt to create ledger with incorrect data and verify create failed")
def create_ledger_with_incorrect_data_verify_fail(context):
    request = context.request

    ledger_dto = DataClassParser.parse_rows(
        context.table.rows, data_class=CreateLedgerDTO
    )[0]

    response = request.hugoserve_post_request(
        path="/ledger/v1/account/create",
        data=ledger_dto.get_dict(),
        headers=__get_default_ledger_headers(
            context.data["config_data"]["customer_profile_id"]
        ),
    )
    assert "data" not in response, (
        f"\nExpect response.data: <empty>" f"\nActual response.data: {response['data']}"
    )


@Step('I verify for ledger ([^"]*) total balance is (.+) and available balance is (.+)')
def verify_ledger_balance(context, identifier, total_balance, available_balance):
    request = context.request
    total_balance = float(total_balance)
    available_balance = float(available_balance)

    ledger_id = context.data[identifier].ledger_id
    response = request.hugoserve_get_request(
        path="/ledger/v1/account/" + ledger_id,
        headers=__get_default_ledger_headers(
            context.data["config_data"]["customer_profile_id"]
        ),
    )["data"]

    actual_ledger_dto = DataClassParser.dict_to_object(response, data_class=LedgerDTO)

    assert total_balance == actual_ledger_dto.total_units, (
        f"\nExpect total_balance: {total_balance}"
        f"\nActual total_balance: {actual_ledger_dto.total_units}"
    )
    assert available_balance == actual_ledger_dto.available_units, (
        f"\nExpect available_balance: {available_balance}"
        f"\nActual available_balance: {actual_ledger_dto.available_units}"
    )


@Step("I initiate ledger transaction")
def initiate_ledger_transaction(context):
    request = context.request

    ledger_transaction_dto = DataClassParser.parse_row(
        context.table.rows[0], data_class=CreateLedgerTransactionDTO
    )

    source_ledger_id = context.data[ledger_transaction_dto.from_ledger_id].ledger_id
    destination_ledger_id = context.data[ledger_transaction_dto.to_ledger_id].ledger_id

    ledger_transaction_dto.from_ledger_id = source_ledger_id
    ledger_transaction_dto.to_ledger_id = destination_ledger_id

    response = request.hugoserve_post_request(
        path="/ledger/v1/transaction",
        data=ledger_transaction_dto.get_dict(),
        headers=__get_default_ledger_headers(
            context.data["config_data"]["customer_profile_id"]
        ),
    )

    ledger_transaction_dto.transaction_id = response["data"]["transaction_id"]
    context.data[ledger_transaction_dto.identifier] = ledger_transaction_dto


@Step('I verify transaction entry exist for transaction ([^"]*)')
def validate_ledger_entries(context, transaction_identifier: str):
    request = context.request
    transaction_data = context.data[transaction_identifier]
    transaction_id = transaction_data.transaction_id

    expected_transaction_dto = DataClassParser.parse_row(
        context.table.rows[0], data_class=LedgerTransactionDTO
    )
    expected_transaction_dto.from_ledger_id = transaction_data.from_ledger_id
    expected_transaction_dto.to_ledger_id = transaction_data.to_ledger_id

    response = request.hugoserve_get_request(
        path="/ledger/v1/transaction/" + transaction_id,
        headers=__get_default_ledger_headers(
            context.data["config_data"]["customer_profile_id"]
        ),
    )
    actual_transaction_dto = DataClassParser.dict_to_object(
        data=response["data"], data_class=LedgerTransactionDTO
    )

    sanitized_expected = LedgerTransactionDTO.sanitize_ledger_dto(
        expected_transaction_dto
    )
    sanitized_actual = LedgerTransactionDTO.sanitize_ledger_dto(actual_transaction_dto)

    assert sanitized_expected == sanitized_actual, (
        f"\nExpect ledger_transaction_dto: {sanitized_expected}"
        f"\nActual ledger_transaction_dto: {sanitized_actual}"
    )


@Then("I update ledger transaction status as ([^']*) for ([^']*)")
def update_transaction_status(context, transaction_status, transaction_identifier):
    request = context.request
    transaction_data = context.data[transaction_identifier]
    transaction_id = transaction_data.transaction_id

    data = {"transaction_id": transaction_id, "status": transaction_status}

    response = request.hugoserve_put_request(
        path="/ledger/v1/transaction/update-transaction-status",
        data=data,
        headers=__get_default_ledger_headers(
            context.data["config_data"]["customer_profile_id"]
        ),
    )
    actual_transaction_dto = DataClassParser.dict_to_object(
        response["data"], data_class=LedgerTransactionDTO
    )

    assert transaction_status == actual_transaction_dto.transaction_status, (
        f"\nExpect ledger_transaction_status: {transaction_status}"
        f"\nActual ledger_transaction_status: {actual_transaction_dto.transaction_status}"
    )


@Then("I initiate ledger transaction with incorrect data and verify transaction failed")
def initiate_transaction_with_incorrect_data_verify_fail(context):
    request = context.request

    ledger_transaction_dto = DataClassParser.parse_row(
        context.table.rows[0], data_class=CreateLedgerTransactionDTO
    )

    source_ledger_id = context.data[ledger_transaction_dto.from_ledger_id].ledger_id
    destination_ledger_id = context.data[ledger_transaction_dto.to_ledger_id].ledger_id

    ledger_transaction_dto.from_ledger_id = source_ledger_id
    ledger_transaction_dto.to_ledger_id = destination_ledger_id

    response = request.hugoserve_post_request(
        path="/ledger/v1/transaction",
        data=ledger_transaction_dto.get_dict(),
        headers=__get_default_ledger_headers(
            context.data["config_data"]["customer_profile_id"]
        ),
    )
    assert "data" not in response, (
        f"\nExpect response.data: <empty>" f"\nActual response.data: {response['data']}"
    )


@Then(
    "I Update Settled ledger transaction status as ([^']*) for ([^']*) and verify transaction failed"
)
def update_transaction_status(context, transaction_status, transaction_identifier):
    request = context.request
    transaction_data = context.data[transaction_identifier]
    transaction_id = transaction_data.transaction_id

    data = {"transaction_id": transaction_id, "status": transaction_status}

    response = request.hugoserve_put_request(
        path="/ledger/v1/transaction/update-transaction-status",
        data=data,
        headers=__get_default_ledger_headers(
            context.data["config_data"]["customer_profile_id"]
        ),
    )
    assert "data" not in response, (
        f"\nExpect response.data: <empty>" f"\nActual response.data: {response['data']}"
    )


@Step(
    'I verify ledger ([^"]*) total balance is (.+) and available balance is (.+) and '
    "avg source rate per unit is (.+) and avg destination rate per unit is (.+)"
)
def verify_ledger_balance(
    context,
    identifier,
    total_balance,
    available_balance,
    avg_source_rate_per_unit,
    avg_destination_rate_per_unit,
):
    request = context.request
    total_balance = float(total_balance)
    available_balance = float(available_balance)
    avg_source_rate_per_unit = float(avg_source_rate_per_unit)
    avg_destination_rate_per_unit = float(avg_destination_rate_per_unit)

    ledger_id = context.data[identifier].ledger_id
    response = request.hugoserve_get_request(
        path="/ledger/v1/account/" + ledger_id,
        headers=__get_default_ledger_headers(
            context.data["config_data"]["customer_profile_id"]
        ),
    )["data"]

    actual_ledger_dto = DataClassParser.dict_to_object(response, data_class=LedgerDTO)
    assert total_balance == actual_ledger_dto.total_units, (
        f"\nExpect total_balance: {total_balance}"
        f"\nActual total_balance: {actual_ledger_dto.total_units}"
    )
    assert available_balance == actual_ledger_dto.available_units, (
        f"\nExpect available_balance: {available_balance}"
        f"\nActual available_balance: {actual_ledger_dto.available_units}"
    )
    assert avg_source_rate_per_unit == actual_ledger_dto.avg_source_rate_per_unit, (
        f"\nExpect avg_source_rate_per_unit: {avg_source_rate_per_unit}"
        f"\nActual avg_source_rate_per_unit: {actual_ledger_dto.avg_source_rate_per_unit}"
    )
    assert (
        avg_destination_rate_per_unit == actual_ledger_dto.avg_destination_rate_per_unit
    ), (
        f"\nExpect avg_destination_rate_per_unit: {avg_destination_rate_per_unit}"
        f"\nActual avg_destination_rate_per_unit: {actual_ledger_dto.avg_destination_rate_per_unit}"
    )


@Step("I split transaction for ([^']*) and verify it is split successfully")
def split_transaction(context, transaction_identifier: str):
    request = context.request
    transaction_data = context.data[transaction_identifier]
    transaction_id = transaction_data.transaction_id

    split_transaction_request_dto = DataClassParser.parse_row(
        context.table.rows[0], data_class=SplitTransactionRequestDTO
    )
    split_transaction_request_dto.transaction_id = transaction_id

    response = request.hugoserve_put_request(
        path="/ledger/v1/internal/split-transaction",
        data=split_transaction_request_dto.get_dict(),
        headers=__get_default_ledger_headers(
            context.data["config_data"]["customer_profile_id"], str(uuid.uuid4())
        ),
    )

    assert response["headers"]["status_code"] == "200"


@Step("I update transaction for ([^']*) and verify it is updated successfully")
def update_transaction(context, transaction_identifier: str):
    request = context.request
    transaction_data = context.data[transaction_identifier]
    transaction_id = transaction_data.transaction_id

    update_transaction_request_dto = DataClassParser.parse_row(
        context.table.rows[0], data_class=UpdateTransactionRequestDTO
    )
    update_transaction_request_dto.transaction_id = transaction_id
    response = request.hugoserve_put_request(
        path="/ledger/v1/internal/update-transaction",
        data=update_transaction_request_dto.get_dict(),
        headers=__get_default_ledger_headers(
            context.data["config_data"]["customer_profile_id"], str(uuid.uuid4())
        ),
    )

    assert response["headers"]["status_code"] == "200"


@Step("I update transaction for ([^']*) and verify failure")
def update_transaction_failure(context, transaction_identifier: str):
    request = context.request
    transaction_data = context.data[transaction_identifier]
    transaction_id = transaction_data.transaction_id

    update_transaction_request_dto = DataClassParser.parse_row(
        context.table.rows[0], data_class=UpdateTransactionRequestDTO
    )
    update_transaction_request_dto.transaction_id = transaction_id
    response = request.hugoserve_put_request(
        path="/ledger/v1/internal/update-transaction",
        data=update_transaction_request_dto.get_dict(),
        headers=__get_default_ledger_headers(
            context.data["config_data"]["customer_profile_id"], str(uuid.uuid4())
        ),
    )

    assert response["headers"]["status_code"] == "LSM_9200"


@Step(
    "I merge transactions ([^']*) and ([^']*) and verify new merged transaction status as ([^']*)"
)
def merge_transaction_success(context, tx_id1: str, tx_id2: str, merge_status: str):
    request = context.request
    transaction_data_1 = context.data[tx_id1]
    transaction_data_2 = context.data[tx_id2]
    transaction_id_1 = transaction_data_1.transaction_id
    transaction_id_2 = transaction_data_2.transaction_id
    transaction_id_1_units = transaction_data_1.units
    transaction_id_2_units = transaction_data_2.units

    merge_transaction_request_dto = DataClassParser.parse_row(
        context.table.rows[0], data_class=MergeLedgerTransactionRequestDTO
    )

    merge_transaction_request_dto.transaction_id.append(transaction_id_1)
    merge_transaction_request_dto.transaction_id.append(transaction_id_2)

    response = request.hugoserve_put_request(
        path="/ledger/v1/internal/merge-transaction",
        data=merge_transaction_request_dto.get_dict(),
        headers=__get_default_ledger_headers(
            context.data["config_data"]["customer_profile_id"], str(uuid.uuid4())
        ),
    )

    assert response["headers"]["status_code"] == "200"
    merged_transaction_dto = DataClassParser.dict_to_object(
        response["data"], data_class=LedgerTransactionDTO
    )

    assert merge_status == merged_transaction_dto.transaction_status, (
        f"\nExpect ledger_transaction_status: {merge_status}"
        f"\nActual ledger_transaction_status: {merged_transaction_dto.transaction_status}"
    )

    assert (
        transaction_id_1_units + transaction_id_2_units
    ) == merged_transaction_dto.units, f"Merged transaction units : {merged_transaction_dto.units}\nExpected transaction units : {transaction_id_1_units + transaction_id_2_units}  "


@Step("I merge transactions ([^']*) and ([^']*) and verify status as ([^']*)")
def merge_transaction_incorrect_status_failure(
    context, tx_id1: str, tx_id2: str, status: str
):
    request = context.request
    transaction_data_1 = context.data[tx_id1]
    transaction_data_2 = context.data[tx_id2]
    transaction_id_1 = transaction_data_1.transaction_id
    transaction_id_2 = transaction_data_2.transaction_id

    merge_transaction_request_dto = DataClassParser.parse_row(
        context.table.rows[0], data_class=MergeLedgerTransactionRequestDTO
    )

    merge_transaction_request_dto.transaction_id.append(transaction_id_1)
    merge_transaction_request_dto.transaction_id.append(transaction_id_2)

    response = request.hugoserve_put_request(
        path="/ledger/v1/internal/merge-transaction",
        data=merge_transaction_request_dto.get_dict(),
        headers=__get_default_ledger_headers(
            context.data["config_data"]["customer_profile_id"], str(uuid.uuid4())
        ),
    )

    assert (
        response["headers"]["status_code"] == status
    ), f"Expected status {status}\nReceived : {response}"


def __get_default_ledger_headers(customer_profile_id: str, idempotency: str = None):
    headers = {
        "x-customer-profile-id": customer_profile_id,
    }
    if idempotency is not None:
        headers["x-idempotency-key"] = idempotency
    return headers
