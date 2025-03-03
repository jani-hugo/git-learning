import uuid

from hugoutils.utilities.dataclass_util import DataClassParser

from test.api.aggregate.card import card_helper
from test.api.aggregate.card.card_dataclass import (
    ActivateCardRequestDTO,
    CardIssueRequestDTO,
    UpdateCardStatusDTO,
)
from behave import *
from retry import retry

use_step_matcher("re")


@Given("I issue Card for Card Account on provider ([^']*)")
def issue_card(context, provider_name: str):
    request = context.request

    card_issue_requests = DataClassParser.parse_rows(
        context.table.rows, data_class=CardIssueRequestDTO
    )

    for each_card_issue_dto in card_issue_requests:
        card_account_identifier = each_card_issue_dto.card_account_identifier
        card_account_id = context.data[card_account_identifier]["card_account_id"]

        end_customer_profile_id = context.data[card_account_identifier][
            "end_customer_profile_id"
        ]

        customer_profile_id = context.data[card_account_identifier]["customer_profile_id"]

        provider_id = next(
            filter(
                lambda provider: provider["provider_name"] == provider_name,
                context.data[end_customer_profile_id],
            ),
            None,
        )["provider_id"]

        each_card_issue_dto.card_product_id = context.data["config_data"][
            f"{provider_id.lower()}_card_product_id"
        ]
        each_card_issue_dto.card_config_id = context.data["config_data"][
            f"{provider_id.lower()}_card_config_id"
        ]
        each_card_issue_dto.card_account_id = card_account_id

        response = request.hugoserve_post_request(
            path="/card/v1/debit/issue-card",
            data=each_card_issue_dto.get_dict(),
            headers=card_helper.get_default_card_headers(
                customer_profile_id, idempotency_key=str(uuid.uuid4())
            ),
        )
        assert response["headers"]["status_code"] == "200", (
            f"[TraceId: {response['headers']['trace_id']}]\n"
            f"Expect status code: 200\n"
            f"Actual status code: {response['headers']['status_code']}"
        )
        assert response["data"]["card_id"] is not None
        assert response["data"]["status"] == "PENDING", (
            f"[TraceId: {response['headers']['trace_id']}]\n"
            f"Expect status: PENDING\n"
            f"Actual status: {response['data']['status']}"
        )

        context.data[each_card_issue_dto.card_identifier] = {
            "customer_profile_id": customer_profile_id,
            "end_customer_profile_id": end_customer_profile_id,
            "card_id": response["data"]["card_id"],
        }


@Then(
    "I wait until max time to verify Card ([^']*) status on card service provider ([^']*) as ([^']*)"
)
def wait_to_issue_card(context, card_identifier: str, provider_name: str, card_status: str):
    request = context.request
    card_helper.validate_provider(provider_name)

    customer_profile_id = context.data[card_identifier]["customer_profile_id"]
    card_id = context.data[card_identifier]["card_id"]

    end_customer_profile_id = context.data[card_identifier]["end_customer_profile_id"]

    max_wait_time = 0
    for provider in context.data[end_customer_profile_id]:
        max_wait_time = max(
            card_helper.card_providers_config[provider["provider_name"]]["max_wait_time"],
            max_wait_time,
        )

    @retry(AssertionError, tries=max_wait_time / 5, delay=5, logger=None)
    def retry_for_creation_status():
        response = request.hugoserve_get_request(
            path=f"/card/v1/debit/{card_id}",
            headers=card_helper.get_default_card_headers(customer_profile_id),
        )

        assert response["headers"]["status_code"] == "200", (
            f"[TraceId: {response['headers']['trace_id']}]\n"
            f"Expect status code: 200\n"
            f"Actual status code: {response['headers']['status_code']}"
        )

        assert response["data"]["card_id"] == card_id, (
            f"[TraceId: {response['headers']['trace_id']}]\n"
            f"Expect card_id: {card_id}\n"
            f"Actual card_id: {response['data']['card_id']}"
        )

        assert response["data"]["card_status"] == card_status, print(
            f"[TraceId: {response['headers']['trace_id']}]\n"
            f"Expect data.account_status: {card_status}\n"
            f"Actual data.account_status: {response['data']['card_status']}\n"
            f"data: {response['data']}"
        )

    retry_for_creation_status()


@Then("I update the status of Card with id ([^']*)")
def update_card_status(context, card_identifier: str):
    request = context.request

    card_status_requests = DataClassParser.parse_rows(
        context.table.rows, data_class=UpdateCardStatusDTO
    )

    for each_update_card_status_dto in card_status_requests:
        card_id = context.data[card_identifier]["card_id"]

        customer_profile_id = context.data[card_identifier]["customer_profile_id"]

        response = request.hugoserve_put_request(
            path=f"/card/v1/debit/{card_id}/status",
            data=each_update_card_status_dto.get_dict(),
            headers=card_helper.get_default_card_headers(customer_profile_id),
        )
        assert response["headers"]["status_code"] == "200", (
            f"[TraceId: {response['headers']['trace_id']}]\n"
            f"Expect status code: 200\n"
            f"Actual status code: {response['headers']['status_code']}"
        )


@Then("To test the invalid scenario, I update the status of Card with id ([^']*)")
def update_card_status_for_invalid_permutations(context, card_identifier: str):
    request = context.request

    card_status_requests = DataClassParser.parse_rows(
        context.table.rows, data_class=UpdateCardStatusDTO
    )

    for each_update_card_status_dto in card_status_requests:
        card_id = context.data[card_identifier]["card_id"]

        customer_profile_id = context.data[card_identifier]["customer_profile_id"]

        response = request.hugoserve_put_request(
            path=f"/card/v1/debit/{card_id}/status",
            data=each_update_card_status_dto.get_dict(),
            headers=card_helper.get_default_card_headers(customer_profile_id),
        )
        assert response["headers"]["status_code"] != "200", (
            f"[TraceId: {response['headers']['trace_id']}]\n"
            f"Expect status code is not 200\n"
            f"Actual status code: {response['headers']['status_code']}"
        )


@Then("I activate the Card")
def activate_card(context):
    request = context.request

    card_activate_request = DataClassParser.parse_rows(
        context.table.rows, data_class=ActivateCardRequestDTO
    )

    for each_card_activate_dto in card_activate_request:
        card_identifier = each_card_activate_dto.card_identifier
        card_id = context.data[card_identifier]["card_id"]

        customer_profile_id = context.data[card_identifier]["customer_profile_id"]

        card_token_response = request.hugoserve_get_request(
            path=f'/card/v1/dev/debit/{card_id}/activation-token',
            headers=card_helper.get_default_card_headers(customer_profile_id),
        )
        card_token = card_token_response["data"]["value"]

        each_card_activate_dto.card_token = card_token

        response = request.hugoserve_put_request(
            path=f"/card/v1/debit/{card_id}/activate",
            data=each_card_activate_dto.get_dict(),
            headers=card_helper.get_default_card_headers(customer_profile_id),
        )

        assert response["headers"]["status_code"] == "200", (
            f"[TraceId: {response['headers']['trace_id']}]\n"
            f"Expect status code: 200\n"
            f"Actual status code: {response['headers']['status_code']}"
        )
        assert response["headers"]["message"] == 'Success', (
            f"[TraceId: {response['headers']['trace_id']}]\n"
            f"Expect message: Success\n"
            f"Actual message: {response['headers']['message']}"
        )


@Then(
    "I attempt to activate the card ([^']*) with token ([^']*) and verify activation failed with ([^']*)"
)
def activate_card_and_verify_fail(
    context, card_identifier: str, card_token: str, status_code: str
):
    request = context.request
    card_id = context.data[card_identifier]["card_id"]

    customer_profile_id = context.data[card_identifier]["customer_profile_id"]
    each_card_activate_dto = ActivateCardRequestDTO(card_identifier, card_token)

    response = request.hugoserve_put_request(
        path=f"/card/v1/debit/{card_id}/activate",
        data=each_card_activate_dto.get_dict(),
        headers=card_helper.get_default_card_headers(customer_profile_id),
    )

    assert response["headers"]["status_code"] == status_code, (
        f"[TraceId: {response['headers']['trace_id']}]\n"
        f"Expect status code: {status_code}\n"
        f"Actual status code: {response['headers']['status_code']}"
    )


@Then(
    "I validate card status by fetching card with id ([^']*) and checking card status as ([^']*)"
)
def validate_status_change(context, card_identifier: str, card_status: str):
    request = context.request

    card_id = context.data[card_identifier]["card_id"]
    customer_profile_id = context.data[card_identifier]["customer_profile_id"]

    response = request.hugoserve_get_request(
        path=f"/card/v1/debit/{card_id}",
        headers=card_helper.get_default_card_headers(customer_profile_id),
    )

    assert response["data"]["card_status"] == card_status, (
        f"[TraceId: {response['headers']['trace_id']}]\n"
        f"Expect card status: {card_status}\n"
        f"Actual card status: {response['data']['card_status']}"
    )

    if card_status == 'ACTIVE':
        assert len(response["data"]["activated_ts"]) != 0


@Given("I get Secure Card Detail with id ([^']*)")
def get_secure_card_detail(context, card_identifier: str):
    request = context.request

    card_id = context.data[card_identifier]["card_id"]
    customer_profile_id = context.data[card_identifier]["customer_profile_id"]

    response = request.hugoserve_get_request(
        path=f"/card/v1/debit/{card_id}/secure-detail",
        headers=card_helper.get_default_card_headers(customer_profile_id),
    )

    assert response["headers"]["status_code"] == "200", (
        f"[TraceId: {response['headers']['trace_id']}]\n"
        f"Expect status code: 200\n"
        f"Actual status code: {response['headers']['status_code']}"
    )
    assert "encrypted_pan" in response["data"], (
        f"[TraceId: {response['headers']['trace_id']}]\n"
        f"Expected 'encrypted_pan' in response\n"
        f"Actual 'encrypted_pan' not found in response"
    )
    assert "encrypted_pin" in response["data"], (
        f"[TraceId: {response}]\n"
        f"Expected 'encrypted_pin' in response\n"
        f"Actual 'encrypted_pin' not found in response"
    )
    assert "encrypted_cvv" in response["data"], (
        f"[TraceId: {response}]\n"
        f"Expected 'encrypted_cvv' in response\n"
        f"Actual 'encrypted_cvv' not found in response"
    )
    assert "encrypted_expiry" in response["data"], (
        f"[TraceId: {response}]\n"
        f"Expected 'encrypted_expiry' in response\n"
        f"Actual 'encrypted_expiry' not found in response"
    )
    assert "key" in response["data"], (
        f"[TraceId: {response}]\n"
        f"Expected 'key' in response\n"
        f"Actual 'key' not found in response"
    )
