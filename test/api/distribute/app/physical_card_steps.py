import random

from behave import *
from hugoutils.utilities.dataclass_util import DataClassParser

from test.api.distribute.app.app_dataclass import MockTransactionRequestDTO
from retry import retry
import test.api.distribute.app.app_helper as ah
from test.util.common_util import check_status_distribute

use_step_matcher("re")


@Step("I order card for ([^']*) with card name as ([^']*) with status ([^']*)")
def order_card(context, user_identifier: str, card_name: str, status_code: str):
    request = context.request
    user_prof_id = ah.get_user_prof_id(context, user_identifier)

    card_account_id = context.data["users"][user_identifier]["userCardAccounts"][0][
        "cardAccountId"
    ]

    order_card_req = {}
    # get card names for user and select random
    if card_name == "random_valid_choice":
        response = request.hugosave_get_request(
            path=ah.user_profile_urls["card_name"],
            headers=ah.get_user_header(user_prof_id, context),
        )
        order_card_req["name_on_card"] = response["data"]["names"][0]
    elif card_name == "empty":
        pass
    else:
        order_card_req["name_on_card"] = card_name

    # order card with requested name
    response = request.hugosave_post_request(
        path=ah.card_urls["order_card"].replace("card-ac-id", card_account_id),
        headers=ah.get_user_header(user_prof_id, context),
        data=order_card_req,
    )
    check_status_distribute(response, status_code)

    print(response)


@Step(
    "I wait for card status as ([^']*) for user ([^']*), activate with ([^']*) token, with status ([^']*)"
)
def get_card_id(context, card_status: str, user_identifier: str, token_case: str, status_code):
    request = context.request
    user_prof_id = ah.get_user_prof_id(context, user_identifier)

    @retry(AssertionError, delay=20, tries=5, logger=None)
    def wait_for_card_status():
        response = request.hugosave_get_request(
            path=ah.user_profile_urls["cards"],
            headers=ah.get_user_header(user_prof_id, context),
        )
        check_status_distribute(response, "200")

        assert (
            len(response["data"]["cards"]) > 0
            and response["data"]["cards"][0]["cardStatus"] == card_status
        ), f"No cards or card status not found"

        context.data["users"][user_identifier]["cards"] = response["data"]["cards"]

    wait_for_card_status()

    card_id = context.data["users"][user_identifier]["cards"][0]["cardId"]

    response = request.hugosave_get_request(
        path=ah.dev_urls["card_activation_token"].replace("card-id", card_id),
        headers=ah.get_user_header(user_prof_id, context),
    )
    check_status_distribute(response, "200")
    activation_token = response["data"]["activationToken"]

    if token_case == "invalid":
        activation_token = "abcdefgh"
    elif token_case == "empty":
        activation_token = None

    response = request.hugosave_put_request(
        path=ah.card_urls["activate_card"].replace("card-id", card_id),
        headers=ah.get_user_header(user_prof_id, context),
        data={"card_id": card_id, "card_token": activation_token},
    )
    check_status_distribute(response, status_code)


@Step("I check card status is ([^']*) for user ([^']*)")
def check_card_status(context, card_status, user_identifier):
    request = context.request
    user_prof_id = ah.get_user_prof_id(context, user_identifier)
    card_id = context.data["users"][user_identifier]["cards"][0]["cardId"]

    response = request.hugosave_get_request(
        path=ah.card_urls["card_details"].replace("card-id", card_id),
        headers=ah.get_user_header(user_prof_id, context),
    )
    check_status_distribute(response, "200")
    assert (
        response["data"]["cardStatus"] == card_status
    ), f"Expected Card status: {card_status}\nActual Card status: {response['data']['cardStatus']}"


@Step("I fetch secure card details for user ([^']*)")
def get_secure_card_details(context, user_identifier):
    request = context.request
    user_prof_id = ah.get_user_prof_id(context, user_identifier)
    card_id = context.data["users"][user_identifier]["cards"][0]["cardId"]

    response = request.hugosave_get_request(
        path=ah.card_urls["secure_card_details"].replace("card-id", card_id),
        headers=ah.get_user_header(user_prof_id, context),
    )
    check_status_distribute(response, "200")
    assert card_id == response["data"]["cardId"]


@Step("I update card status to ([^']*) for user ([^']*) with status ([^']*)")
def update_card_status(context, card_status_action, user_identifier, status_code):
    request = context.request
    user_prof_id = ah.get_user_prof_id(context, user_identifier)
    card_id = context.data["users"][user_identifier]["cards"][0]["cardId"]
    response = request.hugosave_put_request(
        path=ah.card_urls["update_status"].replace("card-id", card_id),
        headers=ah.get_user_header(user_prof_id, context),
        data={"card_id": card_id, "card_status_action": card_status_action},
    )
    check_status_distribute(response, status_code)


@Step("Invalid card scenario, ([^']*), status ([^']*)")
def invalid_card_cases(context, case, status_code):
    request = context.request
    user_identifier = "UID1"
    user_prof_id = ah.get_user_prof_id(context, user_identifier)
    if len(user_prof_id) == 0:
        assert False
    card_id = context.data["users"][user_identifier]["cards"][0]["cardId"]

    if case == "activate_missing_card_id":
        response = request.hugosave_get_request(
            path=ah.dev_urls["card_activation_token"].replace("card-id", card_id),
            headers=ah.get_user_header(user_prof_id, context),
        )
        check_status_distribute(response, "200")
        activation_token = response["data"]["activationToken"]
        response = request.hugosave_put_request(
            path=ah.card_urls["activate_card"],
            headers=ah.get_user_header(user_prof_id, context),
            data={"card_id": None, "card_token": activation_token},
        )
        check_status_distribute(response, status_code)

    elif case == "activate_invalid_card_id":
        response = request.hugosave_get_request(
            path=ah.dev_urls["card_activation_token"].replace("card-id", card_id),
            headers=ah.get_user_header(user_prof_id, context),
        )
        check_status_distribute(response, "200")
        activation_token = response["data"]["activationToken"]
        response = request.hugosave_put_request(
            path=ah.card_urls["activate_card"],
            headers=ah.get_user_header(user_prof_id, context),
            data={"card_id": "abcdefgh", "card_token": activation_token},
        )
        check_status_distribute(response, status_code)

    elif case == "get_details_invalid_card_id":
        card_id = "abcdefgh"
        response = request.hugosave_get_request(
            path=ah.card_urls["card_details"].replace("card-id", card_id),
            headers=ah.get_user_header(user_prof_id, context),
        )
        check_status_distribute(response, status_code)

    elif case == "get_secure_invalid_card_id":
        card_id = "abcdefgh"
        response = request.hugosave_get_request(
            path=ah.card_urls["secure_card_details"].replace("card-id", card_id),
            headers=ah.get_user_header(user_prof_id, context),
        )
        check_status_distribute(response, status_code)

    elif case == "update_status_missing_card_id":
        response = request.hugosave_put_request(
            path=ah.card_urls["update_status"],
            headers=ah.get_user_header(user_prof_id, context),
            data={"card_id": None, "card_status_action": "BLOCK"},
        )
        check_status_distribute(response, status_code)

    elif case == "update_status_invalid_card_id":
        response = request.hugosave_put_request(
            path=ah.card_urls["update_status"],
            headers=ah.get_user_header(user_prof_id, context),
            data={"card_id": "abcdefgh", "card_status_action": "BLOCK"},
        )
        check_status_distribute(response, status_code)


@Step("I replace card for user ([^']*)")
def replace_card(context, user_identifier):
    request = context.request
    user_prof_id = ah.get_user_prof_id(context, user_identifier)

    response = request.hugosave_get_request(
        path=ah.card_urls["card_name"], headers=ah.get_user_header(user_prof_id, context)
    )

    response = request.hugosave_post_request(
        path=ah.card_urls["replace_card"],
        data={
            "name_on_card": response["data"]["names"][random.randint(0, 5)],
            "address": {
                "address_line_1": "line186569",
                "address_line_2": "line286569",
                "address_line_3": "line386569",
                "address_line_4": "line486569",
                "city": "city86569",
                "state": "state86569",
                "country_code": "SGP",
                "local_code": "86569",
            },
            "reason": "Replace card testing",
            "card_id": context.data["users"][user_identifier]["cards"][0]["cardId"],
        },
        headers=ah.get_user_header(user_prof_id, context),
    )
    check_status_distribute(response, "200")


@Step("I check old card status is ([^']*) and get new card id")
def get_replaced_card_dets(context, old_card_status):
    user_identifier = "UID1"
    request = context.request
    user_prof_id = ah.get_user_prof_id(context, user_identifier)
    card_id = context.data["users"][user_identifier]["cards"][0]["cardId"]

    response = request.hugosave_get_request(
        path=ah.card_urls["card_details"].replace("card-id", card_id),
        headers=ah.get_user_header(user_prof_id, context),
    )
    check_status_distribute(response, "200")
    assert (
        response["data"]["cardStatus"] == old_card_status
    ), f"Expected Card status: {old_card_status}\nActual Card status: {response['data']['cardStatus']}"

    response = request.hugosave_get_request(
        path=ah.card_urls["root"], headers=ah.get_user_header(user_prof_id, context)
    )
    check_status_distribute(response, "200")
    assert len(response["data"]["cards"]) > 0, f"No cards or card status not found"

    context.data["users"][user_identifier]["cards"] = response["data"]["cards"]


@given("I create below transaction for user profile id and verify ([^']*)")
def create_transaction_auth_success(context, status: str):
    request = context.request
    card_request_dto_list = DataClassParser.parse_rows(context.table, MockTransactionRequestDTO)
    for card_request_dto in card_request_dto_list:
        user_profile_id = ah.get_user_prof_id(context, card_request_dto.user_profile_identifier)

        @retry(AssertionError, tries=10, delay=15, logger=None)
        def retry_for_transaction_creation_success():
            response = request.hugosave_post_request(
                path=ah.dev_urls["mock_card_transaction"],
                data=card_request_dto.get_dict(),
                headers=ah.get_user_header(user_profile_id, context),
            )
            assert (
                response["headers"]["statusCode"] == status
            ), f"Expected transaction success: {status}.\nReceived : {response}"

        retry_for_transaction_creation_success()


@Step("I enable auto-top-up of ([^']*) SGD for user ([^']*) with trigger amount ([^']*) SGD")
def enable_auto_top_up(context, top_up_amount, user_identifier, top_up_trigger_amount):
    request = context.request
    card_account_id = context.data["users"][user_identifier]["userCardAccounts"][0][
        "cardAccountId"
    ]
    user_prof_id = ah.get_user_prof_id(context, user_identifier)
    response = request.hugosave_put_request(
        path=ah.card_urls["auto_top_up"].replace("card-account-id", card_account_id),
        headers=ah.get_user_header(user_prof_id, context),
        data={
            "top_up_trigger_amount": top_up_trigger_amount,
            "is_auto_top_up_enabled": True,
            "top_up_amount": top_up_amount,
        },
    )
    check_status_distribute(response, "200")


@Step("I disable auto-top-up for user ([^']*)")
def enable_auto_top_up(context, user_identifier):
    request = context.request
    card_account_id = context.data["users"][user_identifier]["userCardAccounts"][0][
        "cardAccountId"
    ]
    user_prof_id = ah.get_user_prof_id(context, user_identifier)
    response = request.hugosave_put_request(
        path=ah.card_urls["auto_top_up"].replace("card-account-id", card_account_id),
        headers=ah.get_user_header(user_prof_id, context),
        data={"is_auto_top_up_enabled": False},
    )
    check_status_distribute(response, "200")
