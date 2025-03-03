from behave import *
import test.api.distribute.app.app_helper as ah
from test.util.common_util import check_status

use_step_matcher("re")


@Step("I push device tokens for user ([^']*) and check if saved")
def push_device_token(context, user):
    request = context.request
    user_prof_id = ah.get_user_prof_id(context, user)

    tokens = ["abcd", "efgh", "ijkl"]

    for token in tokens:
        print(token)
        response = request.hugosave_post_request(
            path=ah.device_urls["root"],
            data={"token": token},
            headers=ah.get_user_header(user_prof_id, context),
        )

        passed = check_status(response, "200")
        if not passed:
            print(f"Failed to push device token\nReceived : {response}")

    response = request.hugosave_get_request(
        path=ah.device_urls["list"],
        headers=ah.get_user_header(user_prof_id, context),
    )
    check_status(response, "200")
    saved_tokens = response['data']['device']

    for t in saved_tokens:
        print(t, t['token'], tokens, t['token'] in tokens)
        assert t['token'] in tokens, "Token missing"


@Step("I delete all device tokens for user ([^']*)")
def remove_token(context, user):
    request = context.request
    user_prof_id = ah.get_user_prof_id(context, user)
    tokens = ["abcd", "efgh", "ijkl"]
    for token in tokens:
        response = request.hugosave_delete_request(
            path=ah.device_urls["delete"].replace("token", token),
            headers=ah.get_user_header(user_prof_id, context),
        )
        assert check_status(response, "200")

    response = request.hugosave_get_request(
        path=ah.device_urls["list"],
        headers=ah.get_user_header(user_prof_id, context),
    )
    check_status(response, "200")
    saved_tokens = response['data']['device']

    assert len(saved_tokens) == 0, "Failed deleting tokens"
