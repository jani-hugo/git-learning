import uuid

from hugoutils.utilities.dataclass_util import DataClassParser

from test.api.aggregate.card import card_helper
from behave import *
from retry import retry

use_step_matcher("re")


@Given(
    "I onboard End-Customer Profile ([^']*) of Customer Profile ([^']*) on fund provider ([^']*) and on card service on below providers"
)
def onboard_end_customer_profile(
    context,
    end_customer_profile_identifier: str,
    customer_profile_identifier: str,
    fund_provider: str,
):
    request = context.request
    provider_name_list = DataClassParser.row_to_dict(context.table.rows)

    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id
    end_customer_profile_id = context.data[
        end_customer_profile_identifier
    ].end_customer_profile_id

    provider_name_id_list = []

    for each_provider in provider_name_list:
        provider_name = each_provider["provider_name"]
        card_helper.validate_provider(provider_name)

        provider_id = card_helper.fetch_card_provider_id(
            context=context,
            provider_name=provider_name,
            customer_profile_id=customer_profile_id,
        )

        provider_name_id_list.append(
            {"provider_name": provider_name, "provider_id": provider_id}
        )
        response = request.hugoserve_post_request(
            path="/card/v1/end-customer-profile",
            data={
                "end_customer_profile_id": end_customer_profile_id,
                "provider_id": [provider_id],
                "fund_provider_id": fund_provider,
            },
            headers=card_helper.get_default_card_headers(
                customer_profile_id, idempotency_key=str(uuid.uuid4())
            ),
        )

        assert int(response["headers"]["status_code"]) == 200, print(
            f"[TraceId: {response['headers']['trace_id']}]\n"
            f"Expect status code: 200\n"
            f"Actual status code: {response['headers']['status_code']}"
        )
        assert response["data"]["end_customer_profile_id"] == end_customer_profile_id
        assert response["data"]["providers"][0]["provider_id"] == provider_id
        assert response["data"]["providers"][0]["onboard_status"] == "ONBOARD_PENDING"

    context.data[end_customer_profile_id] = provider_name_id_list


@Then(
    "I wait until max time to verify End-Customer Profile ([^']*) onboard status on card service provider ([^']*) as ([^']*)"
)
def wait_to_onboard_end_customer_profile(
    context,
    end_customer_profile_identifier: str,
    provider_name: str,
    onboard_status: str,
):
    request = context.request
    card_helper.validate_provider(provider_name)
    customer_profile_identifier = context.data[
        end_customer_profile_identifier
    ].customer_profile_identifier
    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id
    end_customer_profile_id = context.data[
        end_customer_profile_identifier
    ].end_customer_profile_id

    max_wait_time = 0
    for provider in context.data[end_customer_profile_id]:
        max_wait_time = max(
            card_helper.card_providers_config[provider["provider_name"]][
                "max_wait_time"
            ],
            max_wait_time,
        )

    @retry(AssertionError, tries=max_wait_time / 5, delay=5, logger=None)
    def retry_for_creation_status():
        response = request.hugoserve_get_request(
            f"/card/v1/end-customer-profile/{end_customer_profile_id}",
            headers=card_helper.get_default_card_headers(customer_profile_id),
        )

        assert int(response["headers"]["status_code"]) == 200, print(
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
