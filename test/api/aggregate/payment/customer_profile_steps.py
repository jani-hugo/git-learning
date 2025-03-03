from hugoutils.utilities.dataclass_util import DataClassParser

from test.api.aggregate.payment import helper as payment_helper
from test.api.aggregate.profile.profile_dataclass import CustomerProfileDTO
from behave import *
from retry import retry

use_step_matcher("re")


@Given(
    "In Payment Service, I set and verify customer ([^']*), customer profile ([^']*) on below providers from ([^']*) on behalf of ([^']*) and expect status ([^']*) in the context"
)
def setup_customer_profile(
    context,
    customer_identifier: str,
    customer_profile_identifier: str,
    request_origin: str,
    on_behalf_of: str,
    status_code: str,
):
    request = context.request
    customer_profile_dict = {
        "customer_identifier": customer_identifier,
        "customer_profile_identifier": customer_profile_identifier,
        "customer_id": context.data["config_data"]["customer_id"],
        "customer_profile_id": context.data["config_data"]["customer_profile_id"],
        "region": None,
        "name": "Payment Integration Test",
        "email": "admin@hugosave.com",
        "phone_number": "+65 1234567890",
        "status": "Success",
    }

    customer_id = context.data["config_data"]["customer_id"]
    customer_profile_id = context.data["config_data"]["customer_profile_id"]
    provider_name_id_list = []
    provider_id_list = []
    provider_name_list = DataClassParser.row_to_dict(context.table.rows)

    customer_profile_dto = DataClassParser.dict_to_object(
        data=customer_profile_dict, data_class=CustomerProfileDTO
    )
    context.data[customer_identifier] = customer_profile_dto
    context.data[customer_profile_identifier] = customer_profile_dto

    for each_provider in provider_name_list:
        provider_name = each_provider["provider_name"]
        payment_helper.__validate_provider(provider_name)

        # Set the region based on the provider name
        if provider_name == "DBS Bank Ltd":
            customer_profile_dict["region"] = "SG"
        elif provider_name == "PAYSYS":
            customer_profile_dict["region"] = "PK"

        provider_id = payment_helper.__get_payment_provider_id(
            context=context,
            provider_name=provider_name,
            customer_profile_id=customer_profile_id,
            request_origin=request_origin,
        )
        provider_id_list.append(provider_id)
        provider_name_id_list.append(
            {"provider_name": provider_name, "provider_id": provider_id}
        )

    response = request.hugoserve_post_request(
        path="/payment/v1/admin/customer-profile",
        data={
            "customer_id": customer_id,
            "customer_profile_id": customer_profile_id,
            "provider_id": provider_id_list,
            "on_behalf_of": on_behalf_of,
        },
        headers=payment_helper.__get_default_payment_headers(customer_profile_id, request_origin),
    )

    assert response["headers"]["status_code"] == status_code
    context.data["status_code"] = status_code

    if response["headers"]["status_code"] == "200":
        for each_provider_response in response["data"]["provider_onboard_status"]:
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
    elif response["headers"]["status_code"] == "PSM_1100":
        assert (
            response["headers"]["message"]
            == "CustomerProfile not found or Invalid CustomerProfile is passed"
        )
    elif response["headers"]["status_code"] == "PSM_1111":
        assert response["headers"]["message"] == "CustomerProfile not onboarded onto provider"


@Then(
    "I wait until max time to verify CustomerProfile ([^']*) on behalf of ([^']*) onboard status as ([^']*) onto Payment Service"
)
def wait_to_onboard_customer_profile(
    context, customer_profile_identifier: str, on_behalf_of: str, onboard_status: str
):
    request = context.request
    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id
    if context.data["status_code"] == "200":
        max_wait_time = 0
        for provider in context.data[customer_profile_id]:
            max_wait_time = max(
                payment_helper.payment_providers_config[provider["provider_name"]][
                    "max_wait_time"
                ],
                max_wait_time,
            )

        @retry(exceptions=AssertionError, tries=max_wait_time / 5, delay=5, logger=None)
        def retry_for_onboard_status():
            response = request.hugoserve_get_request(
                f"/payment/v1/customer-profile",
                headers=payment_helper.__get_default_payment_headers(
                    customer_profile_id, on_behalf_of
                ),
            )

            for each_provider_onboard_status in response["data"]["status_details"]:
                assert each_provider_onboard_status["onboard_status"] == onboard_status, print(
                    f"\nExpect data.account_status: {onboard_status}"
                    f"\nActual data.account_status: {each_provider_onboard_status['onboard_status']}"
                )

        retry_for_onboard_status()


@Then(
    "I wait until max time to verify the master account ([^']*) with master account status ([^']*) for the customer profile ([^']*) on behalf of ([^']*) status as ([^']*) with provider ([^']*)"
)
def wait_to_create_payment_account(
    context,
    identifier: str,
    master_account_status: str,
    customer_profile_identifier: str,
    on_behalf_of: str,
    onboard_status: str,
    provider_name: str,
):
    request = context.request
    payment_helper.__validate_provider(provider_name)
    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id

    @retry(
        AssertionError,
        tries=10,
        delay=20,
        logger=None,
    )
    def retry_for_creation_status():
        response = request.hugoserve_get_request(
            f"/payment/v1/customer-profile",
            headers=payment_helper.__get_default_payment_headers(
                customer_profile_id, on_behalf_of
            ),
        )
        assert response["headers"]["status_code"] == "200"
        if 'master_account_details' in response["data"]["status_details"][0].keys():
            assert (
                response["data"]["status_details"][0]["master_account_details"][
                    "master_account_status"
                ]
                == "MASTER_ACCOUNT_CREATED"
            )
            assert (
                response["data"]["status_details"][0]["master_account_details"][
                    "master_account_status"
                ]
                == master_account_status
            ), print(
                f"\nExpect data.status_details.master_account_details.master_account_status: {master_account_status}"
                f"\nActual data.status_details.master_account_details.master_account_status: {response['data']['status_details'][0]['master_account_details']['master_account_status']}, data: {response['data']}"
            )
        assert response["data"]["status_details"][0]["onboard_status"] == "ONBOARD_SUCCESS"
        assert response["data"]["status_details"][0]["onboard_status"] == onboard_status, print(
            f"\nExpect data.onboard_status: {onboard_status}"
            f"\nActual data.onboard_status: {response['data']['status_details'][0]['onboard_status']}, data: {response['data']}"
        )

    retry_for_creation_status()


@Given(
    "I onboard CustomerProfile ([^']*) with customerId ([^']*) on payment service from ([^']*) on behalf of ([^']*) on below providers and expect status ([^']*) for different customer"
)
def onboard_customer_profile_on_payment(
    context,
    customer_profile_identifier: str,
    customer_identifier: str,
    request_origin: str,
    on_behalf_of: str,
    status_code: str,
):
    request = context.request
    customer_profile_dict = {
        "customer_identifier": customer_identifier,
        "customer_profile_identifier": customer_profile_identifier,
        "customer_id": context.data["config_data"]["customer_id_2"],
        "customer_profile_id": context.data["config_data"]["customer_profile_id_2"],
        "region": None,
        "name": "Payment Integration Test",
        "email": "admin@hugosave.com",
        "phone_number": "+65 1234567890",
        "status": "Success",
    }
    provider_name_list = DataClassParser.row_to_dict(context.table.rows)
    customer_id = context.data["config_data"]["customer_id_2"]
    customer_profile_id = context.data["config_data"]["customer_profile_id_2"]
    provider_name_id_list = []
    provider_id_list = []

    customer_profile_dto = DataClassParser.dict_to_object(
        data=customer_profile_dict, data_class=CustomerProfileDTO
    )

    context.data[customer_identifier] = customer_profile_dto
    context.data[customer_profile_identifier] = customer_profile_dto

    for each_provider in provider_name_list:
        provider_name = each_provider["provider_name"]
        payment_helper.__validate_provider(provider_name)

        # Set the region based on the provider name
        if provider_name == "DBS Bank Ltd":
            customer_profile_dict["region"] = "SG"
        elif provider_name == "PAYSYS":
            customer_profile_dict["region"] = "PK"

        provider_id = payment_helper.__get_payment_provider_id(
            context=context,
            provider_name=provider_name,
            customer_profile_id=customer_profile_id,
            request_origin=request_origin,
        )
        provider_id_list.append(provider_id)
        provider_name_id_list.append(
            {"provider_name": provider_name, "provider_id": provider_id}
        )

    response = request.hugoserve_post_request(
        path="/payment/v1/admin/customer-profile",
        data={
            "customer_id": customer_id,
            "customer_profile_id": customer_profile_id,
            "provider_id": provider_id_list,
            "on_behalf_of": on_behalf_of,
        },
        headers=payment_helper.__get_default_payment_headers(
            customer_profile_id, request_origin
        ),
    )
    assert response["headers"]["status_code"] == status_code
    context.data["status_code"] = status_code

    if response["headers"]["status_code"] == "200":
        for each_provider_response in response["data"]["provider_onboard_status"]:
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
    elif response["headers"]["status_code"] == "PSM_1100":
        assert (
            response["headers"]["message"]
            == "CustomerProfile not found or Invalid CustomerProfile is passed"
        )
    elif response["headers"]["status_code"] == "PSM_1111":
        assert response["headers"]["message"] == "CustomerProfile not onboarded onto provider"


@Given(
    "I onboard CustomerProfile ([^']*) with customerId ([^']*) on payment service from ([^']*) on behalf of ([^']*) on below providers and expect status ([^']*)"
)
def onboard_customer_profile_on_payment(
    context,
    customer_profile_identifier: str,
    customer_identifier: str,
    request_origin: str,
    on_behalf_of: str,
    status_code: str,
):
    request = context.request
    provider_name_list = DataClassParser.row_to_dict(context.table.rows)
    customer_id = context.data[customer_identifier].customer_id
    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id
    provider_name_id_list = []
    provider_id_list = []

    for each_provider in provider_name_list:
        provider_name = each_provider["provider_name"]
        payment_helper.__validate_provider(provider_name)
        provider_id = payment_helper.__get_payment_provider_id(
            context=context,
            provider_name=provider_name,
            customer_profile_id=customer_profile_id,
            request_origin=request_origin,
        )
        provider_id_list.append(provider_id)
        provider_name_id_list.append(
            {"provider_name": provider_name, "provider_id": provider_id}
        )

    response = request.hugoserve_post_request(
        path="/payment/v1/admin/customer-profile",
        data={
            "customer_id": customer_id,
            "customer_profile_id": customer_profile_id,
            "provider_id": provider_id_list,
            "on_behalf_of": on_behalf_of,
        },
        headers=payment_helper.__get_default_payment_headers(
            customer_profile_id, request_origin
        ),
    )
    assert response["headers"]["status_code"] == status_code
    context.data["status_code"] = status_code

    if response["headers"]["status_code"] == "200":
        for each_provider_response in response["data"]["provider_onboard_status"]:
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
    elif response["headers"]["status_code"] == "PSM_1100":
        assert (
            response["headers"]["message"]
            == "CustomerProfile not found or Invalid CustomerProfile is passed"
        )
    elif response["headers"]["status_code"] == "PSM_1111":
        assert response["headers"]["message"] == "CustomerProfile not onboarded onto provider"


@Given(
    "I onboard CustomerProfile ([^']*) with customerId ([^']*) on payment service from ([^']*) on behalf of ([^']*) on below wrong providers"
)
def onboard_customer_profile_on_payment(
    context,
    customer_profile_identifier: str,
    customer_identifier: str,
    request_origin: str,
    on_behalf_of: str,
):
    provider_name_list = DataClassParser.row_to_dict(context.table.rows)

    for each_provider in provider_name_list:
        provider_name = each_provider["provider_name"]
        payment_helper.__validate_payment_provider(provider_name)


@Then(
    "I retrieve CustomerProfile ([^']*) from ([^']*) onboard status as ([^']*) onto Payment Service"
)
def wait_to_onboard_customer_profile(
    context, customer_profile_identifier: str, request_origin: str, onboard_status: str
):
    request = context.request
    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id

    response = request.hugoserve_get_request(
        f"/payment/v1/customer-profile",
        headers=payment_helper.__get_default_payment_headers(
            customer_profile_id, request_origin
        ),
    )

    context.data[customer_profile_identifier].master_account_id = response['data'][
        "status_details"
    ][0]["master_account_details"]['account_id']


@Then(
    "I check if we are getting same master_account_id for two requests for MASAccId1 ([^']*) and MASAccId2 ([^']*)"
)
def idempotency_and_verify_status(context, masaccId1, masaccId2):
    assert context.data[masaccId1] == context.data[masaccId2]
