import uuid
from behave import *
from hugoutils.utilities.dataclass_util import DataClassParser
from retry import retry

from tests.api.aggregate.card import card_helper
from tests.api.aggregate.card.card_dataclass import CardAccountCreateRequestDTO

use_step_matcher("re")


@Given("I create below Card Account")
def create_card_account(context):
    request = context.request
    card_account_requests = DataClassParser.parse_rows(
        context.table.rows, data_class=CardAccountCreateRequestDTO
    )

    for each_card_account_dto in card_account_requests:
        card_helper.validate_provider(each_card_account_dto.provider_name)

        end_customer_profile_identifier = (
            each_card_account_dto.end_customer_profile_identifier
        )
        customer_profile_identifier = context.data[
            end_customer_profile_identifier
        ].customer_profile_identifier
        customer_profile_id = context.data[
            customer_profile_identifier
        ].customer_profile_id

        end_customer_profile_id = context.data[
            end_customer_profile_identifier
        ].end_customer_profile_id
        provider_id = next(
            filter(
                lambda provider: provider["provider_name"]
                == each_card_account_dto.provider_name,
                context.data[end_customer_profile_id],
            ),
            None,
        )["provider_id"]
        bank_account_id = context.data[
            each_card_account_dto.bank_account_identifier
        ].account_id

        each_card_account_dto.end_customer_profile_id = end_customer_profile_id
        each_card_account_dto.card_account_product_id = context.data["config_data"][
            f"{provider_id.lower()}_card_account_product_id"
        ]
        each_card_account_dto.provider_id = provider_id
        each_card_account_dto.bank_account_id = bank_account_id

        response = request.hugoserve_post_request(
            path="/card/v1/card-account",
            data=each_card_account_dto.get_dict(),
            headers=card_helper.get_default_card_headers(
                customer_profile_id, idempotency_key=str(uuid.uuid4())
            ),
        )

        assert int(response["headers"]["status_code"]) == 200, (
            f"[TraceId: {response['headers']['trace_id']}]\n"
            f"Expect status code: 200\n"
            f"Actual status code: {response['headers']['status_code']}"
        )
        assert response["data"]["card_account_id"] is not None

        assert response["data"]["status"] == "CARD_ACCOUNT_PENDING", (
            f"[TraceId: {response['headers']['trace_id']}]\n"
            f"Expect status: CARD_ACCOUNT_PENDING\n"
            f"Actual status code: {response['data']['status']}"
        )

        context.data[each_card_account_dto.card_account_identifier] = {
            "customer_profile_id": customer_profile_id,
            "end_customer_profile_id": end_customer_profile_id,
            "card_account_id": response["data"]["card_account_id"],
        }


@Then(
    "I wait until max time to verify Card Account ([^']*) onboard status on card service provider ([^']*) as ([^']*)"
)
def wait_to_create_card_account(
    context, card_account_identifier: str, provider_name: str, onboard_status: str
):
    request = context.request
    card_helper.validate_provider(provider_name)

    customer_profile_id = context.data[card_account_identifier]["customer_profile_id"]
    end_customer_profile_id = context.data[card_account_identifier][
        "end_customer_profile_id"
    ]
    card_account_id = context.data[card_account_identifier]["card_account_id"]

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
            f"/card/v1/card-account/{card_account_id}",
            headers=card_helper.get_default_card_headers(customer_profile_id),
        )

        assert int(response["headers"]["status_code"]) == 200, (
            f"[TraceId: {response['headers']['trace_id']}]\n"
            f"Expect status code: 200\n"
            f"Actual status code: {response['headers']['status_code']}"
        )
        assert response["data"]["card_account_id"] == card_account_id
        assert response["data"]["status"] == onboard_status, (
            f"[TraceId: {response['headers']['trace_id']}]\n"
            f"Expect data.account_status: {onboard_status}\n"
            f"Actual data.account_status: {response['data']['status']}\n"
            f"data: {response['data']}"
        )

    retry_for_creation_status()


@Given("I delete card account with id ([^']*)")
def delete_card_account(context, card_account_identifier: str):
    request = context.request

    card_account_id = context.data[card_account_identifier]["card_account_id"]
    customer_profile_id = context.data[card_account_identifier]["customer_profile_id"]

    response = request.hugoserve_delete_request(
        path=f"/card/v1/card-account/{card_account_id}",
        headers=card_helper.get_default_card_headers(customer_profile_id),
    )

    assert int(response["headers"]["status_code"]) == 200, (
        f"[TraceId: {response['headers']['trace_id']}]\n"
        f"Expect status code: 200\n"
        f"Actual status code: {response['headers']['status_code']}"
    )
