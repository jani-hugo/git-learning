from datetime import datetime

from behave import *
from retry import retry

from test.util.common_util import check_status

date_format = '%Y-%m-%dT%H:%M:%S.%fZ'
import test.api.distribute.app.app_helper as ah

use_step_matcher("re")


@Step(
    "I check intent type ([^']*) with status ([^']*) and total ([^']*) intents exist in ([^']*) view for user ([^']*)"
)
def check_intents(
    context, intent_type, intent_status, total_intents: int, view_type: str, user_identifier
):
    request = context.request
    user_prof_id = ah.get_user_prof_id(context, user_identifier)
    url = ah.intent_urls["list_intents_for_account"].replace('account-type', view_type)
    if view_type.__contains__("map_intent_view"):
        map_identifier = view_type.split(',')[1]
        map_id = ah.get_user_map_id(context, map_identifier, user_identifier)
        url = ah.intent_urls["list_intents_for_map"].replace("map-id", map_id)

    @retry(AssertionError, tries=20, delay=5, logger=None)
    def retry_for_intent_status():
        response = request.hugosave_get_request(
            url,
            headers=ah.get_user_header(user_prof_id, context),
        )
        check_status(response, "200")

        intent_views = response['data']['intentViews']
        intent_status_count = 0
        for intent in intent_views:
            if intent["status"] == intent_status and intent["type"] == intent_type:
                intent_status_count += 1

        if intent_status_count != int(total_intents):
            assert False, "Total intents does not match"

    retry_for_intent_status()
