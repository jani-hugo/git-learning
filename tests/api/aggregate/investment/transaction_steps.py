import time

from behave import *
from hugoutils.utilities.dataclass_util import DataClassParser
from retry import retry

from tests.api.aggregate.investment import helper as investment_helper
from tests.api.aggregate.investment.investment_dataclass import *

use_step_matcher("re")


@given(
    "I process below transaction ([^']*) for Customer-Profile ([^']*) and expect header status of ([^']*)"
)
def create_transaction_success(
    context, transaction_type: str, customer_profile_identifier: str, status_code: str
):
    request = context.request
    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id

    transaction_dto_list = DataClassParser.parse_rows(
        context.table.rows, TransactionRequestDTO
    )
    for transaction_dto in transaction_dto_list:
        if transaction_dto.is_rate_included:
            transaction_dto.rate = get_rate_success(
                context, transaction_dto.portfolio_id, customer_profile_identifier
            )
            if status_code == "ISM_9408":
                transaction_dto.rate["asset_rates"][0]["offer_price"] -= 20
            if status_code == "ISM_9410":
                time.sleep(100)

        transaction_dto.portfolio_id = context.data[
            transaction_dto.portfolio_id
        ].portfolio_id
        response = request.hugoserve_post_request(
            path="/investment/v1/transaction",
            headers=investment_helper.__get_default_investment_headers(
                customer_profile_id
            ),
            data=transaction_dto.get_dict(),
        )
        assert response["headers"]["status_code"] == status_code
        if response["headers"]["status_code"] == "200":
            assert (
                "transaction_id" in response["data"]
            ), f"Expected transaction_id. {response}"
            transaction_response_dto = DataClassParser.dict_to_object(
                response["data"], TransactionResponseDTO
            )
            sanitized_transaction_response_dto = (
                TransactionResponseDTO.sanitize_transaction_response_dto(
                    transaction_response_dto
                )
            )
            context.data[transaction_dto.transaction_identifier] = (
                sanitized_transaction_response_dto
            )


@then(
    "I wait until max time to verify transaction status of ([^']*) of Customer-Profile ([^']*) as ([^']*)"
)
def verify_transaction_settled_invest_success(
    context,
    transaction_identifier: str,
    customer_profile_identifier: str,
    transaction_status: str,
):
    request = context.request
    transaction_id = context.data[transaction_identifier].transaction_id
    customer_profile_id = context.data[
        customer_profile_identifier.strip()
    ].customer_profile_id

    @retry(exceptions=AssertionError, tries=40, delay=10, logger=None)
    def retry_for_transaction_status():
        response = request.hugoserve_get_request(
            path="/investment/v1/transaction/" + transaction_id,
            headers=investment_helper.__get_default_investment_headers(
                customer_profile_id
            ),
        )
        assert (
            response["headers"]["status_code"] == "200"
            and "transaction_status" in response["data"]
        )
        assert response["data"]["transaction_status"] == transaction_status, (
            f"\nExpect data.transaction_status: {transaction_status}"
            f"\nActual data.transaction_status: {response['data']['transaction_status']}, data: {response['data']}"
        )

    retry_for_transaction_status()


@then(
    "I wait until max time to verify withdraw transaction status of ([^']*) of Customer-Profile ([^']*) as ([^']*)"
)
def verify_transaction_settled_withdraw_success(
    context,
    transaction_identifier: str,
    customer_profile_identifier: str,
    transaction_status: str,
):
    request = context.request
    transaction_id = context.data[transaction_identifier].transaction_id
    customer_profile_id = context.data[
        customer_profile_identifier.strip()
    ].customer_profile_id

    @retry(exceptions=AssertionError, tries=40, delay=10, logger=None)
    def retry_for_transaction_status():
        response = request.hugoserve_get_request(
            path="/investment/v1/transaction/" + transaction_id,
            headers=investment_helper.__get_default_investment_headers(
                customer_profile_id
            ),
        )
        assert (
            response["headers"]["status_code"] == "200"
            and "transaction_status" in response["data"]
        )
        assert response["data"]["transaction_status"] == "TRANSACTION_STATUS_PENDING", (
            f"\nExpect data.transaction_status: {transaction_status}"
            f"\nActual data.transaction_status: {response['data']['transaction_status']}, data: {response['data']}"
        )

    retry_for_transaction_status()
    #     after asset settled
    settle_response = request.hugoserve_post_request(
        path="/investment/v1/dev/settle-transaction/" + transaction_id,
        headers=investment_helper.__get_default_investment_headers(customer_profile_id),
    )
    assert settle_response["headers"]["status_code"] == "200"

    settle_count = 0
    status = transaction_status

    @retry(exceptions=AssertionError, tries=20, delay=10, logger=None)
    def retry_for_transaction_settlement():
        nonlocal settle_count
        nonlocal status

        settle_count += 1
        response = request.hugoserve_get_request(
            path="/investment/v1/transaction/" + transaction_id,
            headers=investment_helper.__get_default_investment_headers(
                customer_profile_id
            ),
        )
        assert (
            response["headers"]["status_code"] == "200"
            and "transaction_status" in response["data"]
        )
        if settle_count >= 10:
            status = "TRANSACTION_STATUS_ASSET_SETTLED"
        assert response["data"]["transaction_status"] == status, (
            f"\nExpect data.transaction_status after TRANSACTION_STATUS_ASSET_SETTLED as : {status}"
            f"\nActual data.transaction_status: {response['data']['transaction_status']}, data: {response['data']}"
        )

    retry_for_transaction_settlement()


@then(
    "I request to get transaction details of ([^']*) of Customer-Profile ([^']*) and expect header status of ([^']*) and below details"
)
def get_transaction_details_success(
    context,
    transaction_identifier: str,
    customer_profile_identifier: str,
    status_code: str,
):
    request = context.request
    transaction_id = context.data[transaction_identifier].transaction_id
    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id

    response = request.hugoserve_get_request(
        path="/investment/v1/transaction/" + transaction_id,
        headers=investment_helper.__get_default_investment_headers(customer_profile_id),
    )
    assert response["headers"]["status_code"] == status_code
    transaction_detail_dto = DataClassParser.dict_to_object(
        response["data"], TransactionDetailsDTO
    )

    assert transaction_detail_dto


@given(
    "I request to get Transactions For Customer-Profile ([^']*) and expect header as ([^']*)"
)
def get_transaction_details_customer_profile_success(
    context, customer_profile_identifier: str, status_code: str
):
    request = context.request
    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id

    response = request.hugoserve_get_request(
        path="/investment/v1/customer-profile/transactions",
        headers=investment_helper.__get_default_investment_headers(customer_profile_id),
    )

    assert (
        response["headers"]["status_code"] == status_code
        and len(response["data"]["transactions"]) > 0
    )
    transactions_dto = DataClassParser.dict_to_object(response["data"], TransactionsDTO)


@given(
    "I process below transaction for Customer-Profile ([^']*) with insufficient balance and verify ([^']*)"
)
def create_transaction_insufficient_balance_failure(
    context, customer_profile_identifier: str, transaction_status: str
):
    request = context.request
    transaction_dto_list = DataClassParser.parse_rows(
        context.table, TransactionRequestDTO
    )
    for transaction_dto in transaction_dto_list:
        customer_profile_id = context.data[
            customer_profile_identifier
        ].customer_profile_id
        transaction_dto.portfolio_id = context.data[
            transaction_dto.portfolio_id
        ].portfolio_id
        response = request.hugoserve_post_request(
            path="/investment/v1/transaction",
            headers=investment_helper.__get_default_investment_headers(
                customer_profile_id
            ),
            data=transaction_dto.get_dict(),
        )

        assert (
            "data" in response
        ), f"Expected status :TRANSACTION_STATUS_RECEIVED. {response}"
        transaction_response_dto = DataClassParser.dict_to_object(
            response["data"], TransactionResponseDTO
        )
        sanitized_transaction_response_dto = (
            TransactionResponseDTO.sanitize_transaction_response_dto(
                transaction_response_dto
            )
        )
        transaction_id = sanitized_transaction_response_dto.transaction_id

        @retry(exceptions=AssertionError, tries=15, delay=10, logger=None)
        def retry_for_transaction_status():
            get_response = request.hugoserve_get_request(
                path="/investment/v1/transaction/" + transaction_id,
                headers=investment_helper.__get_default_investment_headers(
                    customer_profile_id
                ),
            )

            assert (
                get_response["headers"]["status_code"] == "200"
                and get_response["data"]["transaction_status"] == transaction_status
            ), (
                f"\nExpect data.transaction_status: {transaction_status}"
                f"\nActual data.transaction_status: {get_response['data']['transaction_status']}, data: {get_response['data']}"
            )

        retry_for_transaction_status()


@given(
    "I process below transaction for incorrect Customer-Profile ([^']*) and verify header status as ([^']*)"
)
def create_transaction_incorrect_customer_failure(
    context, customer_profile_identifier: str, transaction_status: str
):
    request = context.request
    transaction_dto_list = DataClassParser.parse_rows(
        context.table, TransactionRequestDTO
    )
    for transaction_dto in transaction_dto_list:
        customer_profile_id = "1352b654-ac6c-42fe-897e-4d7247275f38"
        transaction_dto.portfolio_id = context.data[
            transaction_dto.portfolio_id
        ].portfolio_id

        response = request.hugoserve_post_request(
            path="/investment/v1/transaction",
            headers=investment_helper.__get_default_investment_headers(
                customer_profile_id
            ),
            data=transaction_dto.get_dict(),
        )

        assert (
            response["headers"]["status_code"] == transaction_status
        ), f"Expected ISM_9101. CustomerProfile not found or Invalid CustomerProfile ID is passed.\nReceived {response}"


@given(
    "I process below transaction ([^']*) for invalid Customer-Profile ([^']*) and verify header status as ([^']*)"
)
def create_transaction_invalid_customer_failure(
    context, transaction_type: str, customer_profile_id: str, transaction_status: str
):
    request = context.request
    transaction_dto_list = DataClassParser.parse_rows(
        context.table, TransactionRequestDTO
    )
    for transaction_dto in transaction_dto_list:
        transaction_dto.portfolio_id = context.data[
            transaction_dto.portfolio_id
        ].portfolio_id

        response = request.hugoserve_post_request(
            path="/investment/v1/transaction",
            headers=investment_helper.__get_default_investment_headers(
                customer_profile_id
            ),
            data=transaction_dto.get_dict(),
        )
        assert (
            response["headers"]["status_code"] == transaction_status
        ), f"Expected ISM_9101. CustomerProfile not found or Invalid CustomerProfile ID is passed.\nReceived {response}"


@given(
    "I process below transaction for Customer-Profile ([^']*) with incorrect portfolio-id and verify status as ([^']*)"
)
def create_transaction_incorrect_portfolio_failure(
    context, customer_profile_identifier: str, transaction_status: str
):
    request = context.request
    transaction_dto_list = DataClassParser.parse_rows(
        context.table, TransactionRequestDTO
    )
    for transaction_dto in transaction_dto_list:
        customer_profile_id = context.data[
            customer_profile_identifier
        ].customer_profile_id
        response = request.hugoserve_post_request(
            path="/investment/v1/transaction",
            headers=investment_helper.__get_default_investment_headers(
                customer_profile_id
            ),
            data=transaction_dto.get_dict(),
        )

        assert response["headers"]["status_code"] == transaction_status, (
            f"Expected header status ISM_9402. message : Portfolio Id not found or Invalid portfolio id is passed."
            f"{response}"
        )


@given(
    "I process below transaction for Customer-Profile ([^']*) with invalid transaction_type ([^']*) and verify status as ([^']*)"
)
def create_transaction_invalid_transaction_type_failure(
    context,
    customer_profile_identifier: str,
    invalid_transaction_type: str,
    transaction_status: str,
):
    request = context.request
    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id
    transaction_dto_list = DataClassParser.parse_rows(
        context.table, TransactionRequestDTO
    )
    for transaction_dto in transaction_dto_list:
        transaction_dto.portfolio_id = context.data[
            transaction_dto.portfolio_id
        ].portfolio_id
        transaction_dto.transaction_type = invalid_transaction_type
        response = request.hugoserve_post_request(
            path="/investment/v1/transaction",
            headers=investment_helper.__get_default_investment_headers(
                customer_profile_id
            ),
            data=transaction_dto.get_dict(),
        )
        transaction_response_dto = DataClassParser.dict_to_object(
            response["data"], TransactionResponseDTO
        )
        sanitized_transaction_response_dto = (
            TransactionResponseDTO.sanitize_transaction_response_dto(
                transaction_response_dto
            )
        )
        transaction_id = sanitized_transaction_response_dto.transaction_id

        @retry(exceptions=AssertionError, tries=15, delay=10, logger=None)
        def retry_for_transaction_status():
            get_response = request.hugoserve_get_request(
                path="/investment/v1/transaction/" + transaction_id,
                headers=investment_helper.__get_default_investment_headers(
                    customer_profile_id
                ),
            )

            assert (
                get_response["headers"]["status_code"] == "200" and "data" in response
            )
            assert (
                get_response["data"]["transaction_status"] == transaction_status
                and get_response["data"]["transaction_type"]
                == "TRANSACTION_TYPE_UNKNOWN"
            ), (
                f"\nExpect data.transaction_status: {transaction_status}"
                f"\nActual data.transaction_status: {get_response['data']['transaction_status']}, data: {get_response['data']}"
            )

        retry_for_transaction_status()


@given(
    "I process below transaction ([^']*) for Customer-Profile ([^']*) with invalid amount and expect status of ([^']*)"
)
def create_transaction_invalid_amount_failure(
    context, transaction_type: str, customer_profile_identifier: str, status: str
):
    request = context.request
    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id
    transaction_dto_list = DataClassParser.parse_rows(
        context.table, TransactionRequestDTO
    )
    for transaction_dto in transaction_dto_list:
        response = request.hugoserve_post_request(
            path="/investment/v1/transaction",
            headers=investment_helper.__get_default_investment_headers(
                customer_profile_id
            ),
            data=transaction_dto.get_dict(),
        )
        assert response["headers"]["status_code"] == status


@given(
    "I request to get Transactions for below Portfolios and expect header as ([^']*)"
)
def get_transaction_details_portfolio_success(context, status: str):
    request = context.request
    for row in context.table:
        portfolio_identifier = row[0]
        customer_profile_identifier = row[1]
        customer_profile_id = context.data[
            customer_profile_identifier
        ].customer_profile_id
        portfolio_id = context.data[portfolio_identifier].portfolio_id
        response = request.hugoserve_get_request(
            path="/investment/v1/portfolio/" + portfolio_id + "/transactions",
            headers=investment_helper.__get_default_investment_headers(
                customer_profile_id
            ),
        )
        assert response["headers"]["status_code"] == status


@given(
    "I request to get transaction details of End Customer-Profile ([^']*) and expect header as ([^']*)"
)
def get_transaction_details_end_customer_success(
    context, end_customer_profile_identifier: str, status: str
):
    request = context.request
    for row in context.table:
        portfolio_identifier = row[0]
        customer_profile_identifier = row[1]
        customer_profile_id = context.data[
            customer_profile_identifier
        ].customer_profile_id
        end_customer_profile_id = context.data[
            end_customer_profile_identifier
        ].end_customer_profile_id
        portfolio_id = context.data[portfolio_identifier].portfolio_id
        response = request.hugoserve_get_request(
            path="/investment/v1/end-customer-profile/"
            + end_customer_profile_id
            + "/transactions",
            headers=investment_helper.__get_default_investment_headers(
                customer_profile_id
            ),
        )
        assert response["headers"]["status_code"] == status


@given(
    "I request to get portfolio rate of metals for ([^']*) of Customer Profile ([^']*)"
)
def get_rate_success(
    context, portfolio_identifier: str, customer_profile_identifier: str
):
    request = context.request
    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id
    portfolio_id = context.data[portfolio_identifier].portfolio_id
    response = request.hugoserve_get_request(
        path="/investment/v1/portfolio/" + portfolio_id + "/rate",
        headers=investment_helper.__get_default_investment_headers(customer_profile_id),
    )
    assert response["headers"]["status_code"] == "200"
    context.data["rate"] = response["data"]
    return response["data"]


@then(
    "I modify the portfolio rate of metals of below provider to test for malformed token"
)
def modify_rate_token_success(context):
    for rate in context.data["rate"]["asset_rates"]:
        rate["offer_price"] -= 20
