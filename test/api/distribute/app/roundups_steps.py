from behave import *

import test.api.distribute.app.app_helper as ah
from test.util.common_util import check_status_distribute

use_step_matcher("re")


@Step("I ([^']*) roundups for user ([^']*)")
def toggle_roundups(context, case, user_identifier):
    request = context.request
    user_prof_id = ah.get_user_profile_id(user_identifier, context)

    response = request.hugosave_put_request(
        path=ah.roundup_urls["enable"],
        data={"action": case},
        headers=ah.get_user_header(user_prof_id, context),
    )

    state = "True" if case == "ENABLE" else "False"
    assert str(response["data"]["wantsRoundup"]) == state


@Step("I update Roundup Sweep vault to ([^']*) for user ([^']*)")
def update_sweep_vault(context, sweep_vault: str, user_identifier):
    request = context.request
    user_prof_id = ah.get_user_profile_id(user_identifier, context)

    response = request.hugosave_put_request(
        path=ah.roundup_urls["update_sweep_vault"],
        data={"sweep_vault": sweep_vault},
        headers=ah.get_user_header(user_prof_id, context),
    )

    check_status_distribute(response, "200")


