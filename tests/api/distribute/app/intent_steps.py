from behave import *
from retry import retry
from tests.util.common_util import check_status_distribute

date_format = "%Y-%m-%dT%H:%M:%S.%fZ"
import tests.api.distribute.app.app_helper as ah

use_step_matcher("re")


@Step(
    "I check intent type ([^']*) with status ([^']*) and total ([^']*) intents exist in ([^']*) view for user ([^']*)"
)
def check_intents(
    context,
    intent_type,
    intent_status,
    total_intents: int,
    view_type: str,
    user_profile_identifier,
):
    request = context.request
    user_prof_id = ah.get_user_profile_id(user_profile_identifier, context)
    headers = ah.get_user_header(user_prof_id, context)

    response = request.hugosave_get_request(
        path=ah.user_profile_urls["details"], headers=headers
    )
    context.data["users"][user_profile_identifier]["user_details_response"] = response[
        "data"
    ]
    user_details = response["data"]
    if view_type == "cash":
        acc_id = ah.get_cash_account_id(context, user_profile_identifier)
        url = ah.intent_urls["list_intents_for_account"].replace(
            "cash-account-id", acc_id
        )
    elif view_type == "card":
        card_id = ah.get_card_id(context, user_profile_identifier)
        url = ah.intent_urls["list_intents_for_cards"].replace("card-id", card_id)

    if view_type.__contains__("map_intent_view"):
        map_identifier = view_type.split(",")[1]
        map_id = ah.get_user_map_id(context, map_identifier, user_profile_identifier)
        url = ah.intent_urls["list_intents_for_map"].replace("map-id", map_id)

    @retry(AssertionError, tries=20, delay=5, logger=None)
    def retry_for_intent_status():
        response = request.hugosave_get_request(
            url,
            headers=ah.get_user_header(user_prof_id, context),
        )

        check_status_distribute(response, 200)

        intent_views = response["data"]["intentViews"]
        intent_status_count = 0
        for intent in intent_views:
            if intent["status"] == intent_status and intent["type"] == intent_type:
                intent_status_count += 1

        if intent_status_count != int(total_intents):
            assert False, "Total intents does not match"

    retry_for_intent_status()
