from behave import *
from hugoutils.utilities.dataclass_util import DataClassParser
from retry import retry

from tests.api.aggregate.card import card_helper
from tests.api.aggregate.profile.profile_dataclass import CustomerProfileDTO

use_step_matcher("re")


@Given(
    "I set and verify customer ([^']*), customer profile ([^']*) of ([^']*) region in the context"
)
def setup_customer_profile(
    context, customer_identifier: str, customer_profile_identifier: str, region: str
):
    request = context.request
    customer_profile_dict = {
        "customer_identifier": customer_identifier,
        "customer_id": context.data["config_data"]["customer_id"],
        "phone_number": "+65 1234567890",
        "status": "SUCCESS",
    }

    customer_profile_info = {}
    if region == "PK":
        customer_profile_info = {
            "customer_profile_id": context.data["config_data"][
                "pk_customer_profile_id"
            ],
            "region": "PAK",
            "name": "HUGOBANK_PK",
            "email": "admin@hugobank.com",
        }
    elif region == "SG":
        customer_profile_info = {
            "customer_profile_id": context.data["config_data"][
                "sg_customer_profile_id"
            ],
            "region": "SGP",
            "name": "HUGOSAVE_SG",
            "email": "admin@hugosave.com",
        }

    customer_profile_dict.update(customer_profile_info)

    customer_profile_dto = DataClassParser.dict_to_object(
        data=customer_profile_dict, data_class=CustomerProfileDTO
    )
    context.data[customer_identifier] = customer_profile_dto
    context.data[customer_profile_identifier] = customer_profile_dto

    response = request.hugoserve_get_request(
        path="/card/v1/customer-profile",
        headers=card_helper.get_default_card_headers(
            customer_profile_dict["customer_profile_id"]
        ),
    )

    assert response["headers"]["status_code"] == "200"
    for each_provider in response["data"]["providers"]:
        assert each_provider["onboard_status"] == "ONBOARD_SUCCESS", print(
            f"\n[TraceId: {response['headers']['trace_id']}]"
            f"\nExpect data.account_status: ONBOARD_SUCCESS"
            f"\nActual data.account_status: {each_provider['onboard_status']}, data: {response['data']}"
        )


@Given("I onboard CustomerProfile ([^']*) on Card Service on below providers")
def onboard_customer_profile(context, customer_profile_identifier: str):
    request = context.request
    provider_name_list = DataClassParser.row_to_dict(context.table.rows)

    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id
    provider_name_id_list = []

    for each_provider in provider_name_list:
        provider_name = each_provider["provider_name"]
        has_bank_accounts = each_provider["has_bank_accounts"]
        card_helper.validate_provider(provider_name)

        provider_id = card_helper.fetch_card_provider_id(
            context=context,
            provider_name=provider_name,
            customer_profile_id=customer_profile_id,
        )

        provider_name_id_list.append(
            {
                "provider_name": provider_name,
                "provider_id": provider_id,
                "has_bank_accounts": has_bank_accounts,
            }
        )

        response = request.hugoserve_post_request(
            path="/card/v1/admin/customer-profile",
            data={
                "customer_profile_id": customer_profile_id,
                "provider_id": provider_id,
                "has_bank_accounts": has_bank_accounts,
            },
            headers=card_helper.get_default_card_headers(customer_profile_id),
        )

        assert int(response["headers"]["status_code"]) == 200, print(
            f"[TraceId: {response['headers']['trace_id']}]\n"
            f"Expect status code: 200\n"
            f"Actual status code: {response['headers']['status_code']}"
        )
        assert response["data"]["customer_profile_id"] == customer_profile_id
        assert response["data"]["provider_id"] == provider_id
        assert response["data"]["onboard_status"] == "ONBOARD_SUCCESS"

    context.data[customer_profile_id] = provider_name_id_list


@Then(
    "I wait until max time to verify CustomerProfile ([^']*) onboard status on card service provider ([^']*) as ([^']*)"
)
def wait_to_onboard_customer_profile(
    context, customer_profile_identifier: str, provider_name: str, onboard_status: str
):
    request = context.request
    card_helper.validate_provider(provider_name)

    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id

    max_wait_time = 0
    for provider in context.data[customer_profile_id]:
        max_wait_time = max(
            card_helper.card_providers_config[provider["provider_name"]][
                "max_wait_time"
            ],
            max_wait_time,
        )

    @retry(AssertionError, tries=max_wait_time / 5, delay=5, logger=None)
    def retry_for_creation_status():
        response = request.hugoserve_get_request(
            f"/card/v1/customer-profile/{customer_profile_id}"
        )

        assert response["headers"]["status_code"] == "200", print(
            f"[TraceId: {response['headers']['trace_id']}]\n"
            f"Expect status code: 200\n"
            f"Actual status code: {response['headers']['status_code']}"
        )
        for each_provider in response["data"]["providers"]:
            assert each_provider["onboard_status"] == onboard_status, print(
                f"\n[TraceId: {response['headers']['trace_id']}]"
                f"\nExpect data.account_status: {onboard_status}"
                f"\nActual data.account_status: {each_provider['onboard_status']}, data: {response['data']}"
            )

    retry_for_creation_status()
