from behave import *
import test.api.distribute.app.app_helper as ah
from test.util.common_util import check_status_distribute


use_step_matcher("re")


@Step("I update passcode of user ([^']*)")
def update_passcode(context, user_profile_identifier):
    request = context.request
    user_profile_id = ah.get_user_profile_id(user_profile_identifier, context)

    headers = ah.get_user_header(user_profile_id, context)
    user_authorisation_token = context.data["users"][user_profile_identifier][
        "user_authorisation_token"
    ]

    headers["x-final-user-authorisation-token"] = user_authorisation_token

    response = request.hugosave_put_request(
        path=ah.update_passcode_urls["root"],
        data={"passcode": "123456"},
        headers=ah.get_user_header(user_profile_id, context),
    )

    check_status_distribute(response, "200")
