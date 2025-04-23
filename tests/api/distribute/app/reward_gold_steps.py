from behave import *
import tests.api.distribute.app.app_helper as ah
from tests.util.common_util import check_status_distribute

use_step_matcher("re")


@Step("I reward gold worth ([^']*) SGD for user ([^']*)")
def reward_gold_for_user(context, amount, user_profile_identifier):
    request = context.request
    user_prof_id = ah.get_user_profile_id(user_profile_identifier, context)

    data = {
        "amount": amount,
        "reward_id": ah.get_uuid(),
        "user_reward_id": ah.get_uuid(),
        "reward_source": "Hugosave",
        "source_id": ah.get_uuid(),
    }

    response = request.hugosave_post_request(
        ah.reward_urls["gold"],
        data=data,
        headers=ah.get_user_header(user_prof_id, context),
    )
    check_status_distribute(response, "200")


@Step("I deposit ([^']*) SGD in hugosave account type ([^']*)")
def deposit_hugosave_account(context, amount, acc_type):
    request = context.request

    response = request.hugosave_put_request(
        path=ah.dev_urls["deposit_hugosave_account"],
        data={"account_type": acc_type, "amount": float(amount)},
        headers=ah.get_user_header("HUGOSAVE_SG", context),
    )
    check_status_distribute(response, "200")
