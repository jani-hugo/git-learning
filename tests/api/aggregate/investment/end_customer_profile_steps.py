import time

from behave import *
from hugoutils.utilities.dataclass_util import DataClassParser
from retry import retry

from tests.api.aggregate.investment import helper as investment_helper
from tests.api.aggregate.investment.investment_dataclass import *

use_step_matcher("re")


@then("I create below End Customer-Profile for ([^']*) on Profile Service")
def create_end_customer_success(context, customer_profile_identifier: str):
    request = context.request
    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id
    end_customer_dto = DataClassParser.parse_row(
        context.table.rows[0], data_class=CreateUpdateEndCustomerProfileDTO
    )

    response = request.hugoserve_post_request(
        path="/profile/v1/end-customer-profile",
        headers=investment_helper.__get_default_investment_headers(customer_profile_id),
        data=end_customer_dto.get_dict(),
    )

    assert response["headers"]["status_code"] == "200", f"response : {response}"

    response_dto = EndCustomerProfileDTO.from_dict(response["data"])
    response_dto.end_customer_identifier = end_customer_dto.end_customer_identifier
    context.data[end_customer_dto.end_customer_identifier] = response_dto


@then("I verify End Customer-Profile exists for ([^']*) with values")
def verify_end_customer_success(context, customer_profile_identifier: str):
    request = context.request
    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id

    for row in context.table:
        end_customer_identifier = row[0]
        expected_dto = context.data[end_customer_identifier]
        end_customer_profile_id = expected_dto.end_customer_profile_id

        response = request.hugoserve_get_request(
            path="/profile/v1/end-customer-profile/" + end_customer_profile_id,
            headers=investment_helper.__get_default_investment_headers(
                customer_profile_id
            ),
        )
        assert response["headers"]["status_code"] == "200"
        # we get a list of end-customer-profiles back so code for it as a list here


@given(
    "I onboard End Customer-Profile of Customer-Profile ([^']*) on Investment Service"
)
def onboard_end_customer_profile_success(context, customer_profile_identifier: str):
    request = context.request
    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id
    end_customer_dto_list = DataClassParser.parse_rows(
        context.table.rows, EndCustomerOnboardRequestDTO
    )
    end_customer_provider_list = []
    for end_customer_dto in end_customer_dto_list:
        end_customer_dto.end_customer_profile_id = context.data[
            end_customer_dto.end_customer_identifier
        ].end_customer_profile_id

        end_customer_dto.provider_id = [
            provider.strip()
            for provider in end_customer_dto.provider_id[1:-1].split(",")
        ]
        provider_list = []
        for provider in end_customer_dto.provider_id:
            provider_list.append(context.data["provider_id_map"][provider])
            end_customer_provider_list.append(context.data["provider_id_map"][provider])

        end_customer_dto.provider_id = provider_list
        response = request.hugoserve_post_request(
            data=end_customer_dto.get_dict(),
            headers=investment_helper.__get_default_investment_headers(
                customer_profile_id
            ),
            path="/investment/v1/end-customer-profile",
        )

        assert response["headers"]["status_code"] == "200", f"{response}"

    context.data["end-customer-provider-list"] = end_customer_provider_list


@given(
    "I onboard End Customer-Profile of invalid Customer-Profile ([^']*) and verify ([^']*)"
)
def onboardEndCustomerProfile_invalidCustomerProfile_failure(
    context, customer_profile_identifier: str, status: str
):
    request = context.request
    customer_profile_id = customer_profile_identifier
    end_customer_dto_list = DataClassParser.parse_rows(
        context.table.rows, EndCustomerOnboardRequestDTO
    )
    for end_customer_dto in end_customer_dto_list:
        end_customer_dto.end_customer_profile_id = context.data[
            end_customer_dto.end_customer_identifier
        ].end_customer_profile_id

        end_customer_dto.provider_id = [
            provider.strip()
            for provider in end_customer_dto.provider_id[1:-1].split(",")
        ]
        provider_list = []
        for provider in end_customer_dto.provider_id:
            provider_list.append(context.data["provider_id_map"][provider])

        end_customer_dto.provider_id = provider_list

        response = request.hugoserve_post_request(
            data=end_customer_dto.get_dict(),
            headers=investment_helper.__get_default_investment_headers(
                customer_profile_id
            ),
            path="/investment/v1/end-customer-profile",
        )

        assert response["headers"]["status_code"] == status, f"{response}"


@given(
    "I onboard End Customer-Profile to incorrect Customer-Profile ([^']*) and verify ([^']*)"
)
def onboard_end_customer_profile_incorrect_customer_profile_failure(
    context, customer_profile_identifier: str, status: str
):
    request = context.request
    customer_profile_id = "6646f329-eadb-4b33-a4c5-4367e28b33a1"
    end_customer_dto_list = DataClassParser.parse_rows(
        context.table.rows, EndCustomerOnboardRequestDTO
    )
    for end_customer_dto in end_customer_dto_list:
        end_customer_dto.end_customer_profile_id = context.data[
            end_customer_dto.end_customer_identifier
        ].end_customer_profile_id

        end_customer_dto.provider_id = [
            provider.strip()
            for provider in end_customer_dto.provider_id[1:-1].split(",")
        ]
        provider_list = []
        for provider in end_customer_dto.provider_id:
            provider_list.append(context.data["provider_id_map"][provider])

        end_customer_dto.provider_id = provider_list

        response = request.hugoserve_post_request(
            data=end_customer_dto.get_dict(),
            headers=investment_helper.__get_default_investment_headers(
                customer_profile_id
            ),
            path="/investment/v1/end-customer-profile",
        )

        assert response["headers"]["status_code"] == status, f"{response}"


@then(
    "I wait until max time to verify Investment End Customer-Profile ([^']*) of Customer-Profile ([^']*) onboard status as ([^']*)"
)
def verifyEndCustomerOnboard_success(
    context, end_customer_identifier: str, customer_profile_identifier: str, status: str
):
    request = context.request
    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id

    end_customer_profile_id = context.data[
        end_customer_identifier
    ].end_customer_profile_id

    @retry(exceptions=AssertionError, tries=40, delay=10, logger=None)
    def retry_for_onboard_status():
        response = request.hugoserve_get_request(
            path="/investment/v1/end-customer-profile/" + end_customer_profile_id,
            headers=investment_helper.__get_default_investment_headers(
                customer_profile_id
            ),
        )
        assert "data" in response and len(response["data"]["providers"]) == len(
            context.data["end-customer-provider-list"]
        ), f"{response}"
        for each_provider in response["data"]["providers"]:
            assert each_provider["onboard_status"] == status

    retry_for_onboard_status()


@given(
    "I onboard End Customer-Profile of Customer-Profile ([^']*) to incorrect Provider and verify ([^']*)"
)
def onboardEndCustomerProfile_incorrectProvider_failure(
    context, customer_profile_identifier: str, status: str
):
    request = context.request
    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id
    end_customer_dto_list = DataClassParser.parse_rows(
        context.table.rows, EndCustomerOnboardRequestDTO
    )
    for end_customer_dto in end_customer_dto_list:
        end_customer_dto.end_customer_profile_id = context.data[
            end_customer_dto.end_customer_identifier
        ].end_customer_profile_id
        end_customer_dto.provider_id = [end_customer_dto.provider_id]
        response = request.hugoserve_post_request(
            data=end_customer_dto.get_dict(),
            headers=investment_helper.__get_default_investment_headers(
                customer_profile_id
            ),
            path="/investment/v1/end-customer-profile",
        )

        assert response["headers"]["status_code"] == status, f"{response}"


@given(
    "I delete End Customer-Profile of Customer-Profile ([^']*) on Investment Service and verify ([^']*)"
)
def deleteEndCustomer_success(context, customer_profile_identifier: str, status: str):
    request = context.request
    for row in context.table:
        customer_profile_id = context.data[
            customer_profile_identifier
        ].customer_profile_id
        end_customer_profile_id = context.data[row[1]].end_customer_profile_id
        provider_id = context.data["provider_id_list"][0]
        data = {"provider-id": provider_id}
        response = request.hugoserve_delete_request(
            path="/investment/v1/end-customer-profile/" + end_customer_profile_id,
            headers=investment_helper.__get_default_investment_headers(
                customer_profile_id
            ),
            params=data,
        )
        assert response["headers"]["status_code"] == status, f"Expected :{response}"


@given(
    "I delete End Customer-Profile of Customer-Profile ([^']*) on Investment Service with nonZero Portfolio and verify ([^']*)"
)
def deleteEndCustomer_nonZeroPortfolio_failure(
    context, customer_profile_identifier: str, status: str
):
    request = context.request
    for row in context.table:
        customer_profile_id = context.data[
            customer_profile_identifier
        ].customer_profile_id
        end_customer_profile_id = context.data[row[1]].end_customer_profile_id
        provider_id = context.data["provider_id_list"][0]
        data = {"provider-id": provider_id}
        response = request.hugoserve_delete_request(
            path="/investment/v1/end-customer-profile/" + end_customer_profile_id,
            headers=investment_helper.__get_default_investment_headers(
                customer_profile_id
            ),
            params=data,
        )
        time.sleep(10)
        assert response["headers"]["status_code"] == status, f"Expected :{response}"
