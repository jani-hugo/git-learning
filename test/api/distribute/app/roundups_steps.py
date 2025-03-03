from behave import *

import test.api.distribute.app.app_helper as ah
from test.util.common_util import check_status

use_step_matcher("re")


@Step("I ([^']*) roundups for user ([^']*)")
def toggle_roundups(context, case, user_identifier):
    request = context.request
    user_prof_id = ah.get_user_prof_id(context, user_identifier)

    response = request.hugosave_post_request(
        path=ah.roundup_urls["root"],
        data={"action": case},
        headers=ah.get_user_header(user_prof_id, context),
    )

    state = "True" if case == "ENABLE" else "False"
    response = request.hugosave_get_request(
        path=ah.user_profile_urls["details"],
        headers=ah.get_user_header(user_prof_id, context),
    )
    assert str(response["data"]["settings"]["wantsRoundup"]) == state


@Step("I update Roundup Sweep vault to ([^']*) for user ([^']*)")
def update_sweep_vault(context, sweep_vault: str, user_identifier):
    request = context.request
    user_prof_id = ah.get_user_prof_id(context, user_identifier)

    response = request.hugosave_put_request(
        path=ah.roundup_urls["update_sweep_vault"],
        data={"sweep_vault": sweep_vault},
        headers=ah.get_user_header(user_prof_id, context),
    )

    check_status(response, "200")
