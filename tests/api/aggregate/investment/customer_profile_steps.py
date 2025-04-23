import decimal

from behave import *
from hugoutils.utilities.dataclass_util import DataClassParser
from retry import retry

from tests.api.aggregate.investment import helper as investment_helper
from tests.api.aggregate.investment.investment_dataclass import *

use_step_matcher("re")


@given("I onboard Customer Profile on investment service")
def onboard_customer_profile_success(context):
    request = context.request
    investment_helper.__get_investment_provider_map(context)

    customer_dto_list = DataClassParser.parse_rows(
        context.table.rows, CustomerOnboardRequestDTO
    )
    provider_list = []
    for customer_dto in customer_dto_list:
        customer_profile_identifier = customer_dto.identifier
        customer_dto.customer_id = context.data[customer_profile_identifier].customer_id
        customer_dto.customer_profile_id = context.data[
            customer_profile_identifier
        ].customer_profile_id
        customer_dto.provider_id = [
            provider.strip() for provider in customer_dto.provider_id[1:-1].split(",")
        ]

        provider_id_list = []
        for provider in customer_dto.provider_id:
            provider_id_list.append(context.data["provider_id_map"][provider])
            provider_list.append(context.data["provider_id_map"][provider])

        customer_dto.provider_id = provider_id_list

        response = request.hugoserve_post_request(
            data=customer_dto.get_dict(), path="/investment/v1/admin/customer-profile"
        )

        assert (
            response["headers"]["status_code"] == "200"
        ), f"Response : {response['data']}"

    context.data["customer-provider-list"] = provider_list


@then(
    "I wait until max time to verify Investment Customer-Profile ([^']*) onboard status as ([^']*)"
)
def verify_customer_onboard_success(
    context, customer_profile_identifier: str, onboard_status: str
):
    request = context.request
    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id

    @retry(exceptions=AssertionError, tries=40, delay=20, logger=None)
    def retry_for_onboard_status():
        response = request.hugoserve_get_request(
            path="/investment/v1/customer-profile",
            headers=investment_helper.__get_default_investment_headers(
                customer_profile_id
            ),
        )

        assert len(response["data"]["providers"]) >= len(
            context.data["customer-provider-list"]
        )
        # assert response["headers"]["status_code"] == "200"
        for each_provider_onboard_status in response["data"]["providers"]:
            assert each_provider_onboard_status["onboard_status"] == onboard_status, (
                f"\nExpect data.onboard_status: {onboard_status}"
                f"\nActual data.onboard_status: {each_provider_onboard_status['onboard_status']}, data: {response['data']}"
            )

    retry_for_onboard_status()


@given(
    "I try to onboard invalid Customer Profile on investment service and verify status as ([^']*)"
)
def onboard_customer_profile_invalid_customer_profile_failure(context, status: str):
    request = context.request
    investment_helper.__get_investment_provider_map(context)
    customer_dto_list = DataClassParser.parse_rows(
        context.table.rows, CustomerOnboardRequestDTO
    )

    for customer_dto in customer_dto_list:
        customer_dto.provider_id = [
            provider.strip() for provider in customer_dto.provider_id[1:-1].split(",")
        ]

        provider_id_list = []
        for provider in customer_dto.provider_id:
            provider_id_list.append(context.data["provider_id_map"][provider])

        customer_dto.provider_id = provider_id_list
        response = request.hugoserve_post_request(
            data=customer_dto.get_dict(), path="/investment/v1/admin/customer-profile"
        )

        assert (
            response["headers"]["status_code"] == status
        ), f"Expected status ISM_9107. message:Customer ID not found or Invalid Customer ID is passed\n Response : {response['data']}"


@given("I deposit an amount of ([^']*) in Customer-Profile ([^']*)")
def deposit_success(context, amount: decimal, customer_profile_identifier: str):
    request = context.request
    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id

    @retry(exceptions=AssertionError, tries=15, delay=15, logger=None)
    def retry_for_account_details():
        customer_profile_response = request.hugoserve_get_request(
            path="/investment/v1/customer-profile/float-account/details",
            headers=investment_helper.__get_default_investment_headers(
                customer_profile_id
            ),
        )

        assert customer_profile_response["headers"]["status_code"] == "200"
        return customer_profile_response

    customer_profile_response = retry_for_account_details()

    initial_total_balance = customer_profile_response["data"]["balance_details"][
        "total_balance"
    ]
    initial_available_balance = customer_profile_response["data"]["balance_details"][
        "available_balance"
    ]
    deposit_request_dto = DepositRequestDTO(amount=amount)

    context.data["initial_total_balance_" + customer_profile_id] = initial_total_balance
    context.data["initial_available_balance_" + customer_profile_id] = (
        initial_available_balance
    )

    if initial_available_balance < 500:
        response = request.hugoserve_post_request(
            path=f"/investment/v1/dev/deposit",
            data=deposit_request_dto.get_dict(),
            headers=investment_helper.__get_default_investment_headers(
                customer_profile_id
            ),
        )

        assert response["headers"]["status_code"] == "200"


@given("I request to get all providers for below region")
def get_all_providers_success(context):
    request = context.request
    for region in context.table.rows:
        params = {"region": region}
        response = request.hugoserve_get_request(
            path="/investment/v1/providers", params=params
        )
        assert response["headers"]["status_code"] == "200" and "data" in response
        provider_dto = DataClassParser.dict_to_object(response["data"], ProviderDTO)


@then("I request to get Assets for each Provider")
def get_provider_assets_success(context):
    request = context.request
    investment_helper.__get_investment_provider_map(context)
    for provider in context.data["provider_id_map"]:
        response = request.hugoserve_get_request(
            path="/investment/v1/providers/assets/"
            + context.data["provider_id_map"][provider]
        )
        assert response["headers"]["status_code"] == "200" and "data" in response
        provider_dto = DataClassParser.dict_to_object(
            response["data"], ProviderAssetsDTO
        )


@then("I request to get all Assets for below Region")
def get_all_assets_success(context):
    request = context.request
    for region in context.table.rows:
        params = {"region": region}
        response = request.hugoserve_get_request(
            path="/investment/v1/providers/assets/all", params=params
        )
        assert response["headers"]["status_code"] == "200" and "data" in response
        provider_dto = DataClassParser.dict_to_object(
            response["data"], ProviderAssetsDTO
        )


@then("I request to get Asset for invalid provider and expect ([^']*)")
def get_provider_assets_failure(context, status: str):
    request = context.request
    for provider in context.table.rows[0]:
        response = request.hugoserve_get_request(
            path="/investment/v1/providers/assets/" + provider
        )
        assert response["headers"]["status_code"] == status


@given(
    "I try to onboard Customer Profile on Inactive Provider and expect status ([^']*)"
)
def onboard_customer_profile_failure(context, status: str):
    request = context.request
    customer_dto_list = DataClassParser.parse_rows(
        context.table.rows, CustomerOnboardRequestDTO
    )
    provider_list = []
    for customer_dto in customer_dto_list:
        customer_profile_identifier = customer_dto.identifier
        customer_dto.customer_id = context.data[customer_profile_identifier].customer_id
        customer_dto.customer_profile_id = context.data[
            customer_profile_identifier
        ].customer_profile_id
        customer_dto.provider_id = [
            provider.strip() for provider in customer_dto.provider_id[1:-1].split(",")
        ]

        provider_id_list = []
        for provider in customer_dto.provider_id:
            provider_id_list.append(context.data["provider_id_map"][provider])
            provider_list.append(context.data["provider_id_map"][provider])

        customer_dto.provider_id = provider_id_list

        response = request.hugoserve_post_request(
            data=customer_dto.get_dict(), path="/investment/v1/admin/customer-profile"
        )

        assert response["headers"]["status_code"] == status
