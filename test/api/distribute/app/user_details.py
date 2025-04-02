from behave import *
import test.api.distribute.app.app_helper as ah

use_step_matcher("re")


@Step("Get user details for user ([^']*)")
def step_impl(context, user_profile_identifier):
    request = context.request

    uid = ah.get_user_profile_id(user_profile_identifier, context)
    headers = ah.get_user_header(uid, context)
    response = request.hugosave_get_request(
        path=ah.user_profile_urls["details"], headers=headers
    )
    if user_profile_identifier not in context.data["users"]:
        context.data["users"][user_profile_identifier] = {}

    context.data["users"][user_profile_identifier]["user_details_response"] = response[
        "data"
    ]
    assert True
