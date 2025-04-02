from behave import *
import test.api.distribute.app.app_helper as ah
from test.util.common_util import check_status_distribute

use_step_matcher("re")


@Step("I push device tokens for user ([^']*) and check if saved")
def push_device_token(context, user_profile_identifier):
    request = context.request
    user_prof_id = ah.get_user_profile_id(user_profile_identifier, context)

    tokens = ["abcd", "efgh", "ijkl"]

    for token in tokens:
        print(token)
        response = request.hugosave_post_request(
            path=ah.device_urls["root"],
            data={"token": token},
            headers=ah.get_user_header(user_prof_id, context),
        )

        passed = check_status_distribute(response, "200")
        if not passed:
            print(f"Failed to push device token\nReceived : {response}")

    response = request.hugosave_get_request(
        path=ah.device_urls["list"],
        headers=ah.get_user_header(user_prof_id, context),
    )
    check_status_distribute(response, "200")
    saved_tokens = response['data']['pnToken']

    for t in saved_tokens:
        print(t, t['token'], tokens, t['token'] in tokens)
        assert t['token'] in tokens, "Token missing"


@Step("I delete all device tokens for user ([^']*)")
def remove_token(context, user_profile_identifier):
    request = context.request
    user_prof_id = ah.get_user_profile_id(user_profile_identifier, context)
    tokens = ["abcd", "efgh", "ijkl"]
    for token in tokens:
        response = request.hugosave_delete_request(
            path=ah.device_urls["delete"].replace("token", token),
            headers=ah.get_user_header(user_prof_id, context),
        )
        assert check_status_distribute(response, "200")

    response = request.hugosave_get_request(
        path=ah.device_urls["list"],
        headers=ah.get_user_header(user_prof_id, context),
    )
    check_status_distribute(response, "200")
    saved_tokens = response['data']['pnToken']

    assert len(saved_tokens) == 0, "Failed deleting tokens"
