from behave import *
import test.api.distribute.app.app_helper as ah
from test.util.common_util import check_status

use_step_matcher("re")


@Step("I reward gold worth ([^']*) SGD for user ([^']*)")
def reward_gold_for_user(context, amount, user):
    request = context.request
    user_prof_id = ah.get_user_prof_id(context, user)

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
    check_status(response, "200")


@Step("I deposit ([^']*) SGD in hugosave account type ([^']*)")
def deposit_hugosave_account(context, amount, acc_type):
    request = context.request

    response = request.hugosave_put_request(
        path=ah.dev_urls["deposit_hugosave_account"],
        data={"account_type": acc_type, "amount": float(amount)},
        headers=ah.get_user_header("HUGOSAVE_SG", context),
    )
    check_status(response, "200")
