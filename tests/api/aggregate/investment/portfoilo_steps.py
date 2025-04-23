import random
import string
import json

from behave import *
from hugoutils.utilities.dataclass_util import DataClassParser
from retry import retry

from tests.api.aggregate.investment import helper as investment_helper
from tests.api.aggregate.investment.investment_dataclass import *

use_step_matcher("re")


@Given("I create a product with customer profile ([^']*)")
def create_product(context, customer_profile_identifier: str):
    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id
    product_dto_list = DataClassParser.parse_rows(context.table.rows, ProductRequestDTO)
    product_request_dto = DataClassParser.parse_row(
        context.table.rows[0], data_class=ProductRequestDTO
    )

    for product_dto in product_dto_list:
        product_dto.product_name = "".join(random.choices(string.digits, k=9))
        allowed_chars = string.ascii_letters + string.digits + "_"
        product_dto.product_code = "".join(
            random.choices(allowed_chars, k=random.randint(8, 9))
        )
        product_dto.provider_id = product_dto.provider_id
        product_request_dict = product_dto.get_dict()

        allocation_param = ParamRequestDTO(
            param_name="allocation",
            value=Value(string_value=String("").to_dict()),
        ).to_dict()

        allocation_strategy_param = ParamRequestDTO(
            param_name="allocation_strategy",
            value=Value(string_value=String(product_dto.allocation_strategy).to_dict()),
        ).to_dict()

        re_balance_strategy_param = ParamRequestDTO(
            param_name="re_balance_strategy",
            value=Value(string_value=String(product_dto.re_balance_strategy).to_dict()),
        ).to_dict()

        product_request_dict["product_params"] = [
            allocation_param,
            allocation_strategy_param,
            re_balance_strategy_param,
        ]

        response = context.request.hugoserve_post_request(
            path="/investment/v1/product",
            data=product_request_dict,
            headers=investment_helper.__get_default_investment_headers(
                customer_profile_id
            ),
        )

        assert response["headers"]["status_code"] == "200", (
            f"Expect status_code: {200}\n"
            f"Actual status_code: {response['headers']['status_code']}"
        )

        assert (
            "product_id" in response["data"]
        ), f"Expected data object to contain product_id\nActual data: {response['data']}"
        context.data[product_request_dto.identifier] = response["data"]["product_id"]
        context.data[response["data"]["product_id"]] = product_request_dto
        product_id = response["data"]["product_id"]

        allocation_request = {
            "customerProfileId": customer_profile_id,
            "allocationCode": "".join(random.choices(string.digits, k=9)),
            "productId": product_id,
            "providerId": product_dto.provider_id,
            "allocationDetails": json.loads(product_dto.allocation),
            "allocationDescription": "int",
        }
        response = context.request.hugoserve_post_request(
            path="/investment/v1/allocation",
            data=allocation_request,
            headers=investment_helper.__get_default_investment_headers(
                customer_profile_id
            ),
        )

        assert response["headers"]["status_code"] == "200", (
            f"Expect status_code: {200}\n"
            f"Actual status_code: {response['headers']['status_code']}"
        )
        allocation_id = response["data"]["allocation_id"]

        allocation_param = {"value": {"stringValue": {"values": [allocation_id]}}}

        context.request.hugoserve_put_request(
            path=f"/investment/v1/product/{product_id}/param?param-name=allocation",
            data=allocation_param,
            headers=investment_helper.__get_default_investment_headers(
                customer_profile_id
            ),
        )

        response = context.request.hugoserve_put_request(
            path=f"/investment/v1/product/{product_id}/activate",
            headers=investment_helper.__get_default_investment_headers(
                customer_profile_id
            ),
        )

        status_code = "200"
        assert (
            response["headers"]["status_code"] == status_code
        ), f"Expected status_code: {status_code}, Actual: {response['headers']['status_code']}"

        response = context.request.hugoserve_get_request(
            path=f"/investment/v1/product/{product_id}",
            headers=investment_helper.__get_default_investment_headers(
                customer_profile_id
            ),
        )
        assert (
            response["headers"]["status_code"] == status_code
        ), f"Expected status_code: {status_code}, Actual: {response['headers']['status_code']}"


@Given(
    "I create Portfolio for End Customer-Profile ([^']*) of Customer-Profile ([^']*)"
)
def create_portfolio_success(
    context, end_customer_profile_identifier: str, customer_profile_identifier: str
):
    request = context.request
    customer_profile_id = context.data[
        end_customer_profile_identifier
    ].customer_profile_id

    portfolio_dto_list = DataClassParser.parse_rows(
        context.table.rows, PortfolioRequestDTO
    )
    for portfolio_dto in portfolio_dto_list:
        enc_customer_profile_id = context.data[
            end_customer_profile_identifier
        ].end_customer_profile_id
        product_id = context.data[portfolio_dto.product_id]
        p_request = {
            "end_customer_profile_id": enc_customer_profile_id,
            "product_id": product_id,
        }
        response = request.hugoserve_post_request(
            path="/investment/v1/portfolio",
            headers=investment_helper.__get_default_investment_headers(
                customer_profile_id
            ),
            data=p_request,
        )

        assert (
            response["headers"]["status_code"] == "200"
            and "portfolio_id" in response["data"]
        )
        portfolio_response_dto = DataClassParser.dict_to_object(
            response["data"], data_class=PortfolioResponseDTO
        )
        sanitised_response = PortfolioResponseDTO.sanitize_portfolio_response_dto(
            portfolio_response_dto
        )
        sanitised_response.identifier = portfolio_dto.portfolio_identifier
        context.data[portfolio_dto.portfolio_identifier] = sanitised_response


@then(
    "I wait until max time for Portfolio creation of Customer-Profile ([^']*) and verify Portfolio status"
)
def verify_portfolio_success(context, customer_profile_identifier: str):
    request = context.request
    for row in context.table:
        portfolio_identifier = row[0]
        portfolio_id = context.data[portfolio_identifier].portfolio_id
        customer_profile_id = context.data[
            customer_profile_identifier
        ].customer_profile_id
        status = row[2]

        @retry(exceptions=AssertionError, tries=15, delay=10, logger=None)
        def retry_for_portfolio_creation_status():
            response = request.hugoserve_get_request(
                path="/investment/v1/portfolio/" + portfolio_id,
                headers=investment_helper.__get_default_investment_headers(
                    customer_profile_id
                ),
            )
            assert (
                response["headers"]["status_code"] == "200"
                and response["data"]["status"] == status
            ), f"Expected status 200. {response}"
            portfolio_account_dto = DataClassParser.dict_to_object(
                response["data"], PortfolioAccountDTO
            )

        retry_for_portfolio_creation_status()


@then(
    "I request to get Asset Rate for Portfolio ([^']*) of End Customer-Profile ([^']*) and expect the response body to contain the Portfolio assetRates"
)
def get_portfolio_asset_rate_success(
    context, portfolio_identifier: str, end_customer_profile_identifier: str
):
    request = context.request
    portfolio_id = context.data[portfolio_identifier].portfolio_id
    customer_profile_id = context.data[
        end_customer_profile_identifier
    ].customer_profile_id

    response = request.hugoserve_get_request(
        path="/investment/v1/portfolio/" + portfolio_id + "/rate",
        headers=investment_helper.__get_default_investment_headers(customer_profile_id),
    )
    assert (
        response["headers"]["status_code"] == "200" and "data" in response
    ), f"Expected assetRate JSON. {response}"
    portfolio_rate_dto = DataClassParser.dict_to_object(
        response["data"], data_class=PortfolioRateDTO
    )
    assert portfolio_rate_dto


@then("I request to delete the Portfolio ([^']*) of End Customer-Profile ([^']*)")
def delete_portfolio_success(
    context, portfolio_identifier: str, end_customer_profile_identifier: str
):
    request = context.request
    portfolio_id = context.data[portfolio_identifier].portfolio_id
    customer_profile_id = context.data[
        end_customer_profile_identifier
    ].customer_profile_id
    response = request.hugoserve_delete_request(
        path="/investment/v1/portfolio/" + portfolio_id,
        headers=investment_helper.__get_default_investment_headers(customer_profile_id),
    )

    assert response["headers"]["status_code"] == "200", f"Expected JSON. {response}"


@then(
    "I verify Asset Rate is not found for Portfolio ([^']*) of End Customer-Profile ([^']*)"
)
def get_portfolio_asset_rate_deleted_portfolio_failure(
    context, portfolio_identifier: str, end_customer_profile_identifier: str
):
    request = context.request
    portfolio_id = context.data[portfolio_identifier].portfolio_id
    customer_profile_id = context.data[
        end_customer_profile_identifier
    ].customer_profile_id

    response = request.hugoserve_get_request(
        path="/investment/v1/portfolio/" + portfolio_id + "/rate",
        headers=investment_helper.__get_default_investment_headers(customer_profile_id),
    )
    assert (
        response["headers"]["status_code"] == "ISM_9402"
    ), f"Expected status_code: ISM_9402,message: Portfolio Id not found or Invalid portfolio id is passed. {response}"


@then("I verify Portfolio ([^']*) is not found for End-Customer ([^']*)")
def get_portfolio_deleted_portfolio_failure(
    context, portfolio_identifier: str, end_customer_profile_identifier: str
):
    request = context.request
    portfolio_id = context.data[portfolio_identifier].portfolio_id
    customer_profile_id = context.data[
        end_customer_profile_identifier
    ].customer_profile_id

    response = request.hugoserve_get_request(
        path="/investment/v1/portfolio/" + portfolio_id,
        headers=investment_helper.__get_default_investment_headers(customer_profile_id),
    )
    assert (
        response["headers"]["status_code"] == "ISM_9402"
    ), f"Expected status_code: ISM_9402,message: Portfolio Id not found or Invalid portfolio id is passed. {response}"


@given(
    "I create Portfolio for End Customer-Profile ([^']*) of incorrect Customer-Profile ([^']*) and verify ([^']*)"
)
def create_portfolio_incorrect_customer_failure(
    context,
    end_customer_profile_identifier: str,
    customer_profile_identifier: str,
    status_code: str,
):
    request = context.request
    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id

    portfolio_dto = DataClassParser.parse_row(
        context.table.rows[0], PortfolioRequestDTO
    )
    product_id = context.data[portfolio_dto.product_id]
    p_request = {"end_customer_profile_id": None, "product_id": product_id}
    response = request.hugoserve_post_request(
        path="/investment/v1/portfolio",
        headers=investment_helper.__get_default_investment_headers(customer_profile_id),
        data=p_request,
    )

    assert (
        response["headers"]["status_code"] == status_code
    ), f"Expected status code: ISM_9201 and message :EndCustomerProfile not found or Invalid EndCustomerProfile id is passed. {response}"


@given(
    "I create Portfolio for incorrect End Customer-Profile ([^']*) of Customer-Profile ([^']*) and verify ([^']*)"
)
def create_portfolio_incorrect_end_customer_failure(
    context,
    end_customer_profile_identifier: str,
    customer_profile_identifier: str,
    status_code: str,
):
    request = context.request

    end_customer_profile_id = end_customer_profile_identifier
    customer_profile_id = end_customer_profile_identifier

    portfolio_dto = DataClassParser.parse_row(
        context.table.rows[0], PortfolioRequestDTO
    )
    portfolio_dto.portfolio.end_customer_profile_id = end_customer_profile_id

    portfolio_allocation_list = portfolio_dto.portfolio.portfolio_allocation
    for portfolio_allocation in portfolio_allocation_list:
        for asset in portfolio_allocation["assets"]:
            asset["provider_id"] = context.data["provider_id_map"][asset["provider_id"]]

    portfolio_dto.portfolio.portfolio_allocation = portfolio_allocation_list

    response = request.hugoserve_post_request(
        path="/investment/v1/portfolio",
        headers=investment_helper.__get_default_investment_headers(customer_profile_id),
        data=portfolio_dto.portfolio.get_dict(),
    )

    assert (
        response["headers"]["status_code"] == status_code
    ), f"Expected status code: ISM_9201 and message :EndCustomerProfile not found or Invalid EndCustomerProfile id is passed. {response}"


@given(
    "I create Portfolio for End Customer-Profile ([^']*) with incorrect portfolio allocation and verify ([^']*)"
)
def create_portfolio_incorrect_portfolio_allocation_failure(
    context, end_customer_profile_identifier: str, status_code: str
):
    request = context.request
    customer_profile_id = context.data[
        end_customer_profile_identifier
    ].customer_profile_id

    portfolio_dto_list = DataClassParser.parse_rows(
        context.table.rows, PortfolioRequestDTO
    )
    for portfolio_dto in portfolio_dto_list:
        portfolio_dto.portfolio.end_customer_profile_id = context.data[
            end_customer_profile_identifier
        ].end_customer_profile_id

        portfolio_allocation_list = portfolio_dto.portfolio.portfolio_allocation
        for portfolio_allocation in portfolio_allocation_list:
            for asset in portfolio_allocation["assets"]:
                asset["provider_id"] = context.data["provider_id_map"][
                    asset["provider_id"]
                ]

        portfolio_dto.portfolio.portfolio_allocation = portfolio_allocation_list
        response = request.hugoserve_post_request(
            path="/investment/v1/portfolio",
            headers=investment_helper.__get_default_investment_headers(
                customer_profile_id
            ),
            data=portfolio_dto.portfolio.get_dict(),
        )

        assert (
            response["headers"]["status_code"] == status_code
        ), f"Expected status code: ISM_9403 and message :Total Asset allocation percentage is not 100. {response}"


@given(
    "I create Portfolio for INACTIVE End Customer-Profile ([^']*) of Customer-Profile ([^']*) and verify failure"
)
def create_portfolio_inactive_end_customer_failure(
    context, end_customer_profile_identifier: str, customer_profile_identifier: str
):
    request = context.request

    end_customer_profile_id = end_customer_profile_identifier
    customer_profile_id = context.data[
        end_customer_profile_identifier
    ].customer_profile_id

    # update provider id in body
    provider_id_list = context.data["provider_id_list"]
    portfolio_dto = DataClassParser.parse_row(
        context.table.rows[0], PortfolioRequestDTO
    )
    portfolio_dto.portfolio.end_customer_profile_id = end_customer_profile_id

    portfolio_allocation_list = portfolio_dto.portfolio.portfolio_allocation
    # TO-DO: why replacing all provider by last-one
    for provider_id in provider_id_list:
        for portfolio_allocation in portfolio_allocation_list:
            for asset in portfolio_allocation["assets"]:
                asset["provider_id"] = provider_id
    portfolio_dto.portfolio.portfolio_allocation = portfolio_allocation_list

    response = request.hugoserve_post_request(
        path="/investment/v1/portfolio",
        headers=investment_helper.__get_default_investment_headers(customer_profile_id),
        data=portfolio_dto.portfolio.get_dict(),
    )

    assert (
        response["headers"]["status_code"] == "ISM_9201"
    ), f"Expected status code: ISM_9403 and message :Customer/EndCustomer onBoarding to providerId status is not ACTIVE . {response}"


@then(
    "I request to get Asset Rate for incorrect Portfolio ([^']*) of End Customer-Profile ([^']*) and verify ([^']*)"
)
def get_portfolio_asset_rate_incorrect_portfolio_failure(
    context,
    portfolio_identifier: str,
    end_customer_profile_identifier: str,
    status_code: str,
):
    request = context.request
    portfolio_id = portfolio_identifier
    customer_profile_id = context.data[
        end_customer_profile_identifier
    ].customer_profile_id

    response = request.hugoserve_get_request(
        path="/investment/v1/portfolio/" + portfolio_id + "/rate",
        headers=investment_helper.__get_default_investment_headers(customer_profile_id),
    )
    assert (
        response["headers"]["status_code"] == status_code
    ), f"Expected status : ISM_9402 and message : Portfolio Id not found or Invalid portfolio id is passed. {response}"


@then(
    "I request to get Asset Rate for Portfolio ([^']*) of End Customer-Profile ([^']*) of incorrect Customer-Profile ([^']*) and verify ([^']*)"
)
def get_portfolio_assetRate_incorrect_customer_profile_failure(
    context,
    portfolio_identifier: str,
    end_customer_profile_identifier: str,
    customer_profile_identifier: str,
    status_code,
):
    request = context.request
    portfolio_id = portfolio_identifier
    customer_profile_id = customer_profile_identifier

    response = request.hugoserve_get_request(
        path="/investment/v1/portfolio/" + portfolio_id + "/rate",
        headers=investment_helper.__get_default_investment_headers(customer_profile_id),
    )
    assert (
        response["headers"]["status_code"] == status_code
    ), f"Expected status : ISM_9402 and message : Portfolio Id not found or Invalid portfolio id is passed. {response}"


@then(
    "I try to delete the Portfolio ([^']*) of End Customer-Profile ([^']*) of incorrect Customer-Profile ([^']*) and verify ([^']*)"
)
def delete_portfolio_incorrect_customer_profile_failure(
    context,
    portfolio_identifier: str,
    end_customer_profile_identifier: str,
    customer_profile_identifier: str,
    status_code: str,
):
    request = context.request
    portfolio_id = context.data[portfolio_identifier].portfolio_id
    customer_profile_id = customer_profile_identifier
    response = request.hugoserve_delete_request(
        path="/investment/v1/portfolio/" + portfolio_id,
        headers=investment_helper.__get_default_investment_headers(customer_profile_id),
    )

    assert (
        response["headers"]["status_code"] == status_code
    ), f"Expected status:ISM_9101 and message: CustomerProfile not found or Invalid CustomerProfile ID is passed . {response}"


@then(
    "I try to delete the incorrect Portfolio ([^']*) of End Customer-Profile ([^']*) of Customer-Profile ([^']*) and verify ([^']*)"
)
def delete_portfolio_incorrect_portfolio_failure(
    context,
    portfolio_identifier: str,
    end_customer_profile_identifier: str,
    customer_profile_identifier: str,
    status_code: str,
):
    request = context.request
    portfolio_id = portfolio_identifier
    customer_profile_id = context.data[
        end_customer_profile_identifier
    ].customer_profile_id
    response = request.hugoserve_delete_request(
        path="/investment/v1/portfolio/" + portfolio_id,
        headers=investment_helper.__get_default_investment_headers(customer_profile_id),
    )

    assert (
        response["headers"]["status_code"] == status_code
    ), f"Expected status : ISM_9402. {response}"


@given(
    "I create Portfolio for End Customer-Profile ([^']*) with invalid asset symbol and verify ([^']*)"
)
def create_portfolio_incorrect_asset_symbol_failure(
    context, end_customer_profile_identifier: str, status_code: str
):
    create_portfolio_incorrect_portfolio_allocation_failure(
        context, end_customer_profile_identifier, status_code
    )
