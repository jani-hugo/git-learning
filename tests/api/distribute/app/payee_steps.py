from behave import *
from hugoutils.utilities.dataclass_util import DataClassParser

from tests.api.distribute.app.app_dataclass import SubmitOTPDTO
from retry import retry
import tests.api.distribute.app.app_helper as ah
from tests.util.common_util import check_status_distribute

use_step_matcher("re")


@Step(
    "I add the account subtype ([^']*) of user ([^']*) to user ([^']*) as payee ([^']*) with ([^']*)"
)
def add_payee(
    context,
    acc_subtype: str,
    payee_profile_identifier,
    user_profile_identifier: str,
    payee_identifier: str,
    case: str,
):
    request = context.request
    user_prof_id = ah.get_user_profile_id(user_profile_identifier, context)
    payee_details = context.data["users"][payee_profile_identifier][
        "user_details_response"
    ]

    payee_name = payee_details["name"]
    payee_email = payee_details["email"]
    payee_acc_no = payee_details["accountNumber"]
    payee_phone_no = payee_details["phoneNumber"]

    payee_data = ah.get_add_payee_data(
        payee_name, payee_acc_no, payee_email, payee_phone_no, case
    )
    user_authorisation_token = context.data["users"][user_profile_identifier][
        "user_authorisation_token"
    ]

    headers = ah.get_user_header(user_prof_id, context)

    headers["x-final-user-authorisation-token"] = user_authorisation_token

    response = request.hugosave_post_request(ah.payee_urls["root"], payee_data, headers)
    if case == "invalid_currency":
        passed = check_status_distribute(response, "HSA_9116")
    else:
        passed = check_status_distribute(response, "200")
    if not passed:
        print(
            f"Error adding payee to user : {user_prof_id}, with payee user : {payee_profile_identifier['user_profile_id']}"
        )
    else:
        context.data["users"][user_profile_identifier][payee_identifier] = response[
            "data"
        ]


@Step("I submit otp of user ([^']*) for payee ([^']*)")
def submit_otp_success(context, user_profile_identifier: str, payee_identifier: str):
    request = context.request
    user_prof_id = ah.get_user_profile_id(user_profile_identifier, context)
    otp_dto_list = DataClassParser.parse_rows(
        context.table.rows, data_class=SubmitOTPDTO
    )
    payee_id = context.data["users"][user_profile_identifier][payee_identifier][
        "payeeId"
    ]
    for otp_dto in otp_dto_list:
        response = request.hugosave_post_request(
            ah.payee_urls["submit-otp"].replace("payee-id", payee_id),
            otp_dto.get_dict(),
            headers=ah.get_user_header(user_prof_id, context),
        )
        assert check_status_distribute(
            response, "200"
        ), f"Payee submit otp not success.\nReceived : {response}"


@Step(
    "I check if the account subtype ([^']*) of user ([^']*) is ([^']*) as payee to user ([^']*)"
)
def check_add_payee(
    context, acc_subtype: str, payee: str, case: str, user_profile_identifier: str
):
    request = context.request
    payee_identifier = payee
    user_prof_id = ah.get_user_profile_id(user_profile_identifier, context)
    payee = context.data["users"][payee_identifier]["user_details_response"]

    response = request.hugosave_get_request(
        ah.user_profile_urls["payees-list"],
        headers=ah.get_user_header(user_prof_id, context),
    )

    found = False
    payee_id = None
    payee_acc_no = payee["accountNumber"]

    for payee in response["data"]["payees"]:
        if (
            payee["transferOutAccountDetails"]["codeDetails"]["sgBankDetails"][
                "accountNumber"
            ]
            == payee_acc_no
        ):
            found = True
            payee_id = payee["payeeId"]
            break

    if not found:
        if case != "not_added":
            assert False, f"Payee with account number {payee_acc_no} not added"
        else:
            assert True
    elif found:
        if case == "not_added":
            assert False, f"Payee should not be added"

        response = request.hugosave_get_request(
            ah.payee_urls["payee"].replace("payee-id", payee_id),
            headers=ah.get_user_header(user_prof_id, context),
        )

        if (
            response["data"]["transferOutAccountDetails"]["codeDetails"][
                "sgBankDetails"
            ]["accountNumber"]
            != payee_acc_no
        ):
            assert (
                False
            ), f"Failed getting payee details at /payee/payee-id.\nReceived : {response}"

        context.data["users"][user_profile_identifier]["payees"] = (
            {}
            if context.data["users"][user_profile_identifier].get("payees", None)
            is None
            else context.data["users"][user_profile_identifier]["payees"]
        )
        context.data["users"][user_profile_identifier]["payees"][
            payee_identifier
        ] = payee_id


@Step("I deposit ([^']*) SGD into account subtype ([^']*) of user ([^']*)")
def deposit_test_money(context, amount, acc_subtype, user_profile_identifier):
    global acc_id
    request = context.request
    user_prof_id = ah.get_user_profile_id(user_profile_identifier, context)

    if acc_subtype == "HUGO_CASH":
        acc_id = ah.get_cash_account_id(context, user_profile_identifier)
        response = request.hugosave_put_request(
            ah.dev_urls["deposit"],
            data={"amount": amount},
            headers=ah.get_user_header(user_prof_id, context),
        )
    elif acc_subtype == "HUGO_CARD":
        acc_id = ah.get_card_account_id(context, user_profile_identifier)
        url = ah.card_urls["transfer"].replace("card-account-id", acc_id)
        headers = ah.get_user_header(user_prof_id, context)
        response = request.hugosave_put_request(
            url, data={"amount": amount, "is_cash_to_card": True}, headers=headers
        )

    if not check_status_distribute(response, "200"):
        assert False, f"Dev Deposit request failed.\nReceived : {response}"


@Step(
    "I transfer ([^']*) SGD from user ([^']*) to user ([^']*) with ([^']*) reference and ([^']*) payee id"
)
def transfer_hugo_payee(context, amount, from_user, to_user, reference, case):
    request = context.request

    user_prof_id = ah.get_user_profile_id(from_user, context)
    user_details = context.data["users"][from_user]
    payee_id = user_details["payees"][to_user]
    if case == "invalid":
        payee_id = payee_id + "11"
    data = {"amount": amount, "description": "test txn"}
    if reference == "description":
        data["special_character_description"] = "@#$"

    user_authentication_token = context.data["users"][from_user][
        "user_authorisation_token"
    ]
    headers = ah.get_user_header(user_prof_id, context)
    headers["x-final-user-authorisation-token"] = user_authentication_token

    response = request.hugosave_post_request(
        ah.payee_urls["pay_payee"].replace("payee-id", payee_id),
        data=data,
        headers=headers,
    )

    if case == "invalid":
        passed = check_status_distribute(response, "HSA_9104")
    else:
        passed = check_status_distribute(response, "200")
    if not passed:
        assert False, f"Pay payee failed.\nReceived : {response}"


@Step("I delete the payee ([^']*) added to user ([^']*)")
def delete_payee(context, payee, user_profile_identifier):
    request = context.request

    user_prof_id = ah.get_user_profile_id(user_profile_identifier, context)
    payee_id = context.data["users"][user_profile_identifier]["payees"][payee]

    response = request.hugosave_delete_request(
        ah.payee_urls["payee"].replace("payee-id", payee_id),
        headers=ah.get_user_header(user_prof_id, context),
    )

    passed = check_status_distribute(response, "200")
    if not passed:
        assert False, f"Delete payee failed.\nReceived : {response}"


@Step(
    "I check the balance of account subtype ([^']*) of user ([^']*) is ([^']*) SGD ([^']*)"
)
def step_impl(context, account_type, user_profile_identifier, amount, precision):

    request = context.request
    user_prof_id = ah.get_user_profile_id(user_profile_identifier, context)

    @retry(AssertionError, tries=30, delay=10, logger=None)
    def retry_for_acc_balance():
        response = request.hugosave_get_request(
            ah.balance_urls["balances"],
            headers=ah.get_user_header(user_prof_id, context),
        )

        b1 = ah.get_balance(response, account_type)
        if precision == "approx":
            if float(amount) - 1 <= b1 <= float(amount) + 1:
                assert True
            else:
                assert False, f"Transaction went wrong"
        elif precision == "exact":
            if b1 == float(amount):
                assert True
            else:
                assert False, f"Balances does not match"

    retry_for_acc_balance()
