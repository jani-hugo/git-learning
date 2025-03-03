from behave import *
import test.api.distribute.app.app_helper as ah
from test.util.common_util import check_status

use_step_matcher("re")


@Step("I ([^']*) deposits for ([^']*)")
def block_deposits(context, case, user):
    request = context.request
    user_prof_id = ah.get_user_prof_id(context, user)

    url = None
    response = None
    if case == "block":
        url = ah.dev_urls["block_deposits"]
        response = request.hugosave_put_request(
            url,
            headers=ah.get_user_header(user_prof_id, context),
        )
    elif case == "unblock":
        url = ah.dev_urls["unblock_deposits"]
        response = request.hugosave_delete_request(
            url,
            headers=ah.get_user_header(user_prof_id, context),
        )

    if not check_status(response, "200"):
        assert False, f"Failed to {case} deposits.\nReceived : {response}"


@Step("I ([^']*) merchant transactions for ([^']*)")
def block_merchant_transactions(context, case, user):
    request = context.request
    user_prof_id = ah.get_user_prof_id(context, user)

    response = None
    if case == "block":
        url = ah.dev_urls["block_merchant_transactions"]
        response = request.hugosave_put_request(
            url,
            headers=ah.get_user_header(user_prof_id, context),
        )
    elif case == "unblock":
        url = ah.dev_urls["unblock_merchant_transactions"]
        response = request.hugosave_delete_request(
            url,
            headers=ah.get_user_header(user_prof_id, context),
        )

    if not check_status(response, "200"):
        assert False, f"Failed to {case} merchant transactions.\nReceived : {response}"
