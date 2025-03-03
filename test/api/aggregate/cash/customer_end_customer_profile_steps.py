from aggregate.cash import helper as cash_helper
from aggregate.profile.profile_dataclass import CustomerProfileDTO
from behave import *
from common.utils import DataClassParser, parse_rows_as_dict
from retry import retry

use_step_matcher("re")


@Given(
    "I set and verify customer ([^']*), customer profile ([^']*) on cash service on below providers and expect status ([^']*) in the context"
)
def setup_customer_profile(
    context, customer_identifier: str, customer_profile_identifier: str, status_code: str
):
    request = context.request
    customer_profile_dict = {
        "customer_identifier": customer_identifier,
        "customer_profile_identifier": customer_profile_identifier,
        "customer_id": context.data["config_data"]["customer_id"],
        "customer_profile_id": context.data["config_data"]["customer_profile_id"],
        "region": "SGP",
        "name": "Integration test",
        "email": "admin@hugosave.com",
        "phone_number": "+65 1234567890",
        "status": "Success",
    }

    customer_id = context.data["config_data"]["customer_id"]
    customer_profile_id = context.data["config_data"]["customer_profile_id"]
    provider_name_id_list = []
    provider_id_list = []
    provider_name_list = parse_rows_as_dict(context.table.rows)

    customer_profile_dto = DataClassParser.dict_to_object(
        data=customer_profile_dict, data_class=CustomerProfileDTO
    )
    context.data[customer_identifier] = customer_profile_dto
    context.data[customer_profile_identifier] = customer_profile_dto

    for each_provider in provider_name_list:
        provider_name = each_provider["provider_name"]
        cash_helper.__validate_provider(provider_name)
        provider_id = cash_helper.__get_provider_id(
            context=context,
            provider_name=provider_name,
            customer_profile_id=customer_profile_id,
        )
        provider_id_list.append(provider_id)
        provider_name_id_list.append(
            {"provider_name": provider_name, "provider_id": provider_id}
        )

    response = request.hugoserve_post_request(
        path="/cash/v1/admin/customer-profile",
        data={
            "customer_id": customer_id,
            "customer_profile_id": customer_profile_id,
            "provider_id": provider_id_list,
        },
        headers=cash_helper.__get_default_cash_headers(customer_profile_id),
    )

    assert response["headers"]["status_code"] == status_code
    context.data["status_code"] = status_code

    if response["headers"]["status_code"] == "200":
        for each_provider_response in response["data"]["providers"]:
            provider_id = each_provider_response["provider_id"]
            assert provider_id in provider_id_list
            assert "provider_id" in each_provider_response, (
                f"\nExpected data object contains provider_id" f"\nActual data: {provider_id}"
            )
            actual_onboard_status = each_provider_response["onboard_status"]
            assert (
                actual_onboard_status == "ONBOARD_PENDING"
                or actual_onboard_status == "ONBOARD_SUCCESS"
            ), (
                f"\nExpect data.onboard_status.status: ONBOARD_PENDING or ONBOARD_SUCCESS"
                f"\nActual data.onboard_status.status: {each_provider_response['status']}, data: {response['data']}"
            )
        context.data[customer_profile_id] = provider_name_id_list
    elif response["headers"]["status_code"] == "BSM_9511":
        assert (
            response["headers"]["message"]
            == "CustomerProfile not found or Invalid CustomerProfile is passed"
        )


@Given(
    "I onboard CustomerProfile ([^']*) with customerId ([^']*) on cash service on below providers and expect status ([^']*)"
)
def onboard_customer_profile_on_cash(
    context,
    customer_profile_identifier: str,
    customer_identifier: str,
    status_code: str,
):
    request = context.request
    provider_name_list = parse_rows_as_dict(context.table.rows)
    customer_id = context.data[customer_identifier].customer_id
    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id
    provider_name_id_list = []
    provider_id_list = []

    for each_provider in provider_name_list:
        provider_name = each_provider["provider_name"]
        cash_helper.__validate_provider(provider_name)
        provider_id = cash_helper.__get_provider_id(
            context=context,
            provider_name=provider_name,
            customer_profile_id=customer_profile_id,
        )
        provider_id_list.append(provider_id)
        provider_name_id_list.append(
            {"provider_name": provider_name, "provider_id": provider_id}
        )

    response = request.hugoserve_post_request(
        path="/cash/v1/admin/customer-profile",
        data={
            "customer_id": customer_id,
            "customer_profile_id": customer_profile_id,
            "provider_id": provider_id_list,
        },
        headers=cash_helper.__get_default_cash_headers(customer_profile_id),
    )
    assert response["headers"]["status_code"] == status_code,  (
        f"[TraceId: {response['headers']['trace_id']}]\n"
        f"Expect status_code: {status_code}\n"
        f"Actual status_code: {response['headers']['status_code']}"
    )
    context.data["status_code"] = status_code

    if response["headers"]["status_code"] == "200":
        for each_provider_response in response["data"]["providers"]:
            provider_id = each_provider_response["provider_id"]
            assert provider_id in provider_id_list
            assert "provider_id" in each_provider_response, (
                f"\nExpected data object contains provider_id" f"\nActual data: {provider_id}"
            )
            actual_onboard_status = each_provider_response["onboard_status"]
            assert (
                actual_onboard_status == "ONBOARD_PENDING"
                or actual_onboard_status == "ONBOARD_SUCCESS"
            ), (
                f"\nExpect data.onboard_status.status: ONBOARD_PENDING or ONBOARD_SUCCESS"
                f"\nActual data.onboard_status.status: {each_provider_response['status']}, data: {response['data']}"
            )
        context.data[customer_profile_id] = provider_name_id_list
    elif response["headers"]["status_code"] == "BSM_9511":
        assert (
            response["headers"]["message"]
            == "CustomerProfile not found or Invalid CustomerProfile is passed"
        )


@Then("I wait until max time to verify CustomerProfile ([^']*) onboard status as ([^']*)")
def wait_to_onboard_customer_profile(
    context, customer_profile_identifier: str, onboard_status: str
):
    request = context.request
    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id
    if context.data["status_code"] == "200":
        max_wait_time = 0
        for provider in context.data[customer_profile_id]:
            max_wait_time = max(
                cash_helper.cash_providers_config[provider["provider_name"]]["max_wait_time"],
                max_wait_time,
            )

        @retry(exceptions=AssertionError, tries=max_wait_time / 5, delay=5, logger=None)
        def retry_for_onboard_status():
            response = request.hugoserve_get_request(
                f"/cash/v1/customer-profile",
                headers=cash_helper.__get_default_cash_headers(customer_profile_id),
            )

            for each_provider_onboard_status in response["data"]["providers"]:
                assert each_provider_onboard_status["onboard_status"] == onboard_status, print(
                    f"\nExpect data.account_status: {onboard_status}"
                    f"\nActual data.account_status: {each_provider_onboard_status['onboard_status']}"
                )

        retry_for_onboard_status()


@Step(
    "I onboard EndCustomerProfile ([^']*) of CustomerProfile ([^']*) on cash service on below providers and expect status ([^']*)"
)
def onboard_end_customer_profile_on_cash(
    context,
    end_customer_profile_identifier: str,
    customer_profile_identifier: str,
    status_code: str,
):
    request = context.request
    end_customer_profile_id = context.data[
        end_customer_profile_identifier
    ].end_customer_profile_id
    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id
    provider_name_list = parse_rows_as_dict(context.table.rows)
    provider_name_id_list = []
    provider_id_list = []
    for each_provider in provider_name_list:
        provider_name = each_provider["provider_name"]
        cash_helper.__validate_provider(provider_name)
        provider_id = cash_helper.__get_provider_id(
            context=context,
            provider_name=provider_name,
            customer_profile_id=customer_profile_id,
        )
        provider_id_list.append(provider_id)
        provider_name_id_list.append(
            {"provider_name": provider_name, "provider_id": provider_id}
        )

    response = request.hugoserve_post_request(
        path="/cash/v1/end-customer-profile",
        data={
            "end_customer_profile_id": end_customer_profile_id,
            "provider_id": provider_id_list,
        },
        headers=cash_helper.__get_default_cash_headers(customer_profile_id),
    )

    assert response["headers"]["status_code"] == status_code, (
        f"[TraceId: {response['headers']['trace_id']}]\n"
        f"Expect status_code: {status_code}\n"
        f"Actual status_code: {response['headers']['status_code']}"
    )
    context.data["status_code"] = status_code

    if response["headers"]["status_code"] == "200":
        for each_provider_response in response["data"]["providers"]:
            provider_id = each_provider_response["provider_id"]
            assert provider_id in provider_id_list
            assert "provider_id" in each_provider_response, (
                f"\nExpected data object contains provider_id" f"\nActual data: {provider_id}"
            )
            actual_onboard_status = each_provider_response["onboard_status"]
            assert (
                actual_onboard_status == "ONBOARD_PENDING"
                or actual_onboard_status == "ONBOARD_SUCCESS"
            ), (
                f"\nExpect data.onboard_status.status: ONBOARD_PENDING or ONBOARD_SUCCESS"
                f"\nActual data.onboard_status.status: {each_provider_response['onboard_status']}"
            )

        context.data[end_customer_profile_id] = provider_name_id_list

    elif response["headers"]["status_code"] == "BSM_9521":
        assert (
            response["headers"]["message"]
            == "EndCustomerProfile not found or Invalid EndCustomerProfile is passed"
        )


@Then(
    "I wait until max time to verify EndCustomerProfile ([^']*) of CustomerProfile ([^']*) onboard status as ([^']*)"
)
def wait_to_onboard_end_customer_profile(
    context,
    end_customer_profile_identifier: str,
    customer_profile_identifier: str,
    expected_onboard_status: str,
):
    request = context.request
    end_customer_profile_id = context.data[
        end_customer_profile_identifier
    ].end_customer_profile_id

    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id
    if context.data["status_code"] == "200":
        max_wait_time = 0
        for provider in context.data[end_customer_profile_id]:
            max_wait_time = max(
                cash_helper.cash_providers_config[provider["provider_name"]]["max_wait_time"],
                max_wait_time,
            )

        @retry(exceptions=AssertionError, tries=max_wait_time / 5, delay=3, logger=None)
        def retry_for_onboard_status():
            response = request.hugoserve_get_request(
                f"/cash/v1/end-customer-profile/{end_customer_profile_id}",
                headers=cash_helper.__get_default_cash_headers(customer_profile_id),
            )
            # Below assertion fails because cash aren't creating db entries right away and so api call returns
            # 'EndCustomerProfile not found.'
            assert "data" in response, print(
                f"\nExpect response.data but no data found: {response}"
            )
            for each_provider_onboard_status in response["data"]["providers"]:
                actual_onboard_status = each_provider_onboard_status["onboard_status"]
                assert actual_onboard_status == expected_onboard_status, print(
                    f"\nExpect data.account_status: {expected_onboard_status}"
                    f"\nActual data.account_status: {each_provider_onboard_status['onboard_status']}"
                )

        retry_for_onboard_status()
