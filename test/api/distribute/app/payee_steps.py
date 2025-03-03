from behave import *
from hugoutils.utilities.dataclass_util import DataClassParser

from test.api.distribute.app.app_dataclass import SubmitOTPDTO
from retry import retry
import test.api.distribute.app.app_helper as ah
from test.util.common_util import check_status

use_step_matcher("re")


@Step(
    "I add the account subtype ([^']*) of user ([^']*) to user ([^']*) as payee ([^']*) with ([^']*)"
)
def add_payee(
    context, acc_subtype: str, payee: str, user: str, payee_identifier: str, case: str
):
    user_prof_id = ah.get_user_prof_id(context, user)
    payee = context.data["users"].get(payee)

    payee_name = payee["name"]
    payee_email = payee["email"]
    payee_acc_no = payee["accountNumber"]

    payee_data = ah.get_add_payee_data(payee_name, payee_acc_no, payee_email, case)

    request = context.request
    response = request.hugosave_post_request(
        ah.payee_urls["root"], payee_data, headers=ah.get_user_header(user_prof_id, context)
    )
    if case == "invalid_currency":
        passed = check_status(response, "HSA_9116")
    else:
        passed = check_status(response, "200")
    if not passed:
        print(
            f"Error adding payee to user : {user_prof_id}, with payee user : {payee['user_profile_id']}"
        )

    context.data["users"][user][payee_identifier] = response["data"]


@Step("I submit otp of user ([^']*) for payee ([^']*)")
def submit_otp_success(context, user: str, payee_identifier: str):
    request = context.request
    user_prof_id = ah.get_user_prof_id(context, user)
    otp_dto_list = DataClassParser.parse_rows(context.table.rows, data_class=SubmitOTPDTO)
    payee_id = context.data["users"][user][payee_identifier]['payeeId']
    for otp_dto in otp_dto_list:
        response = request.hugosave_post_request(
            ah.payee_urls["submit-otp"].replace("payee-id", payee_id),
            otp_dto.get_dict(),
            headers=ah.get_user_header(user_prof_id, context),
        )
        assert check_status(
            response, "200"
        ), f"Payee submit otp not success.\nReceived : {response}"


@Step(
    "I check if the account subtype ([^']*) of user ([^']*) is ([^']*) as payee to user ([^']*)"
)
def check_add_payee(context, acc_subtype: str, payee: str, case: str, user: str):
    request = context.request
    payee_identifier = payee
    user_prof_id = ah.get_user_prof_id(context, user)
    payee = context.data["users"].get(payee)

    response = request.hugosave_get_request(
        ah.payee_urls["list"], headers=ah.get_user_header(user_prof_id, context)
    )

    found = False
    payee_id = None
    payee_acc_no = payee["accountNumber"]
    while not found and len(response["data"]["payees"]) != 0:
        payee_filtered = list(
            filter(lambda p: p["accountNumber"] == payee_acc_no, response["data"]["payees"])
        )
        if len(payee_filtered) == 1:
            found = True
            payee_id = payee_filtered[0]["payeeId"]
        if not found:
            response = request.hugosave_get_request(
                ah.payee_urls["list"] + f"?page-token={response['pageToken']}",
                headers=ah.get_user_header(user_prof_id, context),
            )

    if not found:
        if case != "not_added":
            assert False, f"Payee with account number {payee_acc_no} not added"
    elif found:
        if case == "not_added":
            assert False, f"Payee should not be added"
        # checking /payee/payee-id path too
        response = request.hugosave_get_request(
            ah.payee_urls["payee"].replace("payee-id", payee_id),
            headers=ah.get_user_header(user_prof_id, context),
        )

        if response["data"]["accountNumber"] != payee_acc_no:
            assert (
                False
            ), f"Failed getting payee details at /payee/payee-id.\nReceived : {response}"

        context.data["users"][user]["payees"] = (
            {}
            if context.data["users"][user].get("payees", None) is None
            else context.data["users"][user]["payees"]
        )
        context.data["users"][user]["payees"][payee_identifier] = payee_id


@Step(
    "I check if the account subtype ([^']*) of user ([^']*) is not added as payee to user ([^']*)"
)
def check_add_payee(context, acc_subtype: str, payee: str, user: str):
    request = context.request
    payee_identifier = payee
    user_prof_id = ah.get_user_prof_id(context, user)
    payee = context.data["users"].get(payee)

    response = request.hugosave_get_request(
        ah.payee_urls["list"], headers=ah.get_user_header(user_prof_id, context)
    )

    found = False
    payee_id = None
    payee_acc_no = payee["account_number"]
    while not found and len(response["data"]["payees"]) != 0:
        payee_filtered = list(
            filter(lambda p: p["account_number"] == payee_acc_no, response["data"]["payees"])
        )
        if len(payee_filtered) == 1:
            found = True
            payee_id = payee_filtered[0]["payee_id"]
        if not found:
            response = request.hugosave_get_request(
                ah.payee_urls["list"] + f"?page-token={response['page_token']}",
                headers=ah.get_user_header(user_prof_id, context),
            )
    if found:
        assert False, f"Payee with account number {payee_acc_no} has got added"


@Step(
    "I check if the account subtype ([^']*) of user ([^']*) has been removed as payee to user ([^']*) successfully"
)
def check_delete_payee(context, acc_subtype, payee, user):
    request = context.request
    user_prof_id = ah.get_user_prof_id(context, user)
    user = context.data["users"].get(user)

    payee_id = user["payees"].get(payee)
    response = request.hugosave_get_request(
        ah.payee_urls["payee"].replace("payee-id", payee_id),
        headers=ah.get_user_header(user_prof_id, context),
    )

    assert check_status(
        response, "HSA_9104"
    ), f"Payee is not deleted successfully.\nReceived : {response}"


@Step("I deposit ([^']*) SGD into account subtype ([^']*) of user ([^']*)")
def deposit_test_money(context, amount: str, acc_subtype: str, user: str):
    request = context.request
    user_prof_id = ah.get_user_prof_id(context, user)

    # should add dev controller to app itself and not call hugoserve directly
    response = request.hugosave_put_request(
        ah.dev_urls["deposit"],
        data={"amount": amount, 'account_type': acc_subtype},
        headers=ah.get_user_header(user_prof_id, context),
    )

    if not check_status(response, "200"):
        assert False, f"Dev Deposit request failed.\nReceived : {response}"


@Step("I check the balance of account subtype ([^']*) of user ([^']*) is ([^']*) SGD ([^']*)")
def check_balance(context, acc_subtype, user, expected_balance, condition):
    request = context.request
    user_prof_id = ah.get_user_prof_id(context, user)
    user = context.data["users"].get(user)

    acc_id = ah.get_account_field("accountId", user, acc_subtype)
    expected_balance = float(expected_balance)

    @retry(AssertionError, tries=30, delay=10, logger=None)
    def retry_for_acc_balance():
        response = request.hugosave_get_request(
            ah.balance_urls["account"].replace("acc-id", acc_id),
            headers=ah.get_user_header(user_prof_id, context),
        )

        actual_balance = response["data"]["balance"]
        check_condition = False
        if condition == "exact":
            check_condition = actual_balance == expected_balance
        elif condition == "approx":
            check_condition = expected_balance - 1 <= actual_balance <= expected_balance + 1
        assert check_condition, f"Money was not deposited.\nReceived : {response}"

    retry_for_acc_balance()


@Step(
    "I transfer ([^']*) SGD from user ([^']*) to user ([^']*) with ([^']*) reference and ([^']*) payee id"
)
def transfer_hugo_payee(context, amount, from_user, to_user, reference, case):
    request = context.request

    user_prof_id = ah.get_user_prof_id(context, from_user)
    user = context.data["users"].get(from_user)
    payee_id = user["payees"][to_user]
    if case == "invalid":
        payee_id = payee_id + "11"
    data = {"user_profile_id": user_prof_id, "amount": amount, "description": "test txn"}
    if reference == 'description':
        data['special_character_description'] = '@#$'
    response = request.hugosave_post_request(
        ah.payee_urls["pay_payee"].replace("payee-id", payee_id),
        data=data,
        headers=ah.get_user_header(user_prof_id, context),
    )

    if case == "invalid":
        passed = check_status(response, "HSA_9104")
    else:
        passed = check_status(response, "200")
    if not passed:
        assert False, f"Pay payee failed.\nReceived : {response}"


@Step("I delete the payee ([^']*) added to user ([^']*)")
def delete_payee(context, payee, user):
    request = context.request

    user_prof_id = ah.get_user_prof_id(context, user)
    payee_id = context.data["users"][user]["payees"][payee]

    response = request.hugosave_delete_request(
        ah.payee_urls["payee"].replace("payee-id", payee_id),
        headers=ah.get_user_header(user_prof_id, context),
    )

    passed = check_status(response, "200")
    if not passed:
        assert False, f"Delete payee failed.\nReceived : {response}"
