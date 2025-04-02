from behave import *
import test.api.distribute.app.app_helper as ah
from api.distribute.app.app_dataclass import CreateNewAccountDTO
from test.util.common_util import check_status_distribute
from hugoutils.utilities.dataclass_util import DataClassParser
from retry import retry

use_step_matcher("re")


@Step(r"I open a new user account")
def create_new_user(context):
    request = context.request
    open_new_account_dto_list = DataClassParser.parse_rows(
        context.table.rows, data_class=CreateNewAccountDTO
    )
    for open_new_account_dto in open_new_account_dto_list:
        user_info = open_new_account_dto.get_dict()

    account_type = "PERSONAL"
    if user_info["account_type"] is not None:
        account_type = user_info["account_type"]

    referral_code = user_info["referral_code"]
    if referral_code:
        if referral_code.startswith("UID"):
            referee_user = context.data["users"].get(user_info["referral_code"], {})
            referral_code = referee_user["referralCode"]
        else:
            referral_code = "invalid-code"
    phone_number = context.data["users"][user_info["user_profile_identifier"]][
        "mobile_number"
    ]

    create_user = {
        "legal_name": user_info["legal_name"],
        "phone_number": phone_number,
        "email": user_info["email"],
        "password": ah.get_rand_number(6),
        "referral_code": referral_code,
        "account_type": account_type,
        "name": user_info["name"],
        "security_answers": {},
    }
    create_new_user_response = request.hugosave_post_request(
        path=ah.auth_user_urls["create"],
        headers=ah.get_create_account_header(
            context, user_info["user_profile_identifier"]
        ),
        data=create_user,
    )
    if not check_status_distribute(create_new_user_response, 200):
        assert (
            False
        ), f"failed to create user account and received response {create_new_user_response}"
    context.data["users"][user_info["user_profile_identifier"]][
        "create_new_user_response"
    ] = create_new_user_response["data"]


@Step("I check the current account status")
def check_account_status(context):
    request = context.request
    user_profile_id = context.data["users"]["create_new_user_response"]["userProfileId"]
    account_status_response = request.hugosave_get_request(
        path=ah.user_profile_urls["status"],
        headers=ah.get_user_header(user_profile_id, context),
    )
    if not (check_status_distribute(account_status_response, 200)):
        assert (
            False
        ), f"account is not created yet the response received is:{account_status_response}"


@Step("I initiate the initial onboarding for the user ([^']*)")
def initiate_initial_onboarding(context, uid):
    request = context.request
    user_profile_id = ah.get_user_profile_id(uid, context)
    initiate_onboarding_initial_onboarding_response = request.hugosave_post_request(
        path=ah.initial_onboarding_urls["initiate-initial-onboarding"],
        headers=ah.get_initial_onboarding_headers(user_profile_id, context, uid),
    )
    if not (
        check_status_distribute(initiate_onboarding_initial_onboarding_response, 200)
    ):
        assert (
            False
        ), f"Failed to initiate Initial Onboarding, the returned response is: {initiate_onboarding_initial_onboarding_response}"
    context.data["users"][uid]["initiate_onboarding_initial_onboarding_response"] = (
        initiate_onboarding_initial_onboarding_response["data"]
    )


@Step("I check the status of initial onboarding for ([^']*)")
def check_initial_onboarding_status(context, uid):
    request = context.request
    user_profile_id = ah.get_user_profile_id(uid, context)

    @retry(AssertionError, tries=40, delay=5, logger=None)
    def retry_initial_onboarding_status():
        initial_onboarding_status_response = request.hugosave_get_request(
            path=ah.initial_onboarding_urls["initial-onboarding-status"],
            headers=ah.get_initial_onboarding_headers(user_profile_id, context, uid),
        )
        if not check_status_distribute(initial_onboarding_status_response, 200):
            assert (
                False
            ), f"Failed to fetch initial onboarding status. \nReceived{initial_onboarding_status_response}"

        assert (
            initial_onboarding_status_response["data"]["onboardingStatus"]
            == "COMPLETED"
        )

    retry_initial_onboarding_status()


@Step("I submit the initial onboarding for ([^']*)")
def submit_initial_onboarding_status(context, uid):
    request = context.request
    onboarding_id = ah.get_initial_onboarding_id(uid, context)
    user_profile_id = ah.get_user_profile_id(uid, context)
    submit_initial_onboarding_response = request.hugosave_post_request(
        path=ah.initial_onboarding_urls["submit-initial-onboarding"],
        headers=ah.get_initial_onboarding_headers(user_profile_id, context, uid),
        data={"onboarding_id": onboarding_id},
    )
    if not check_status_distribute(submit_initial_onboarding_response, 200):
        assert (
            False
        ), f"Failed to submit Initial onboarding, the returned response is: {submit_initial_onboarding_response}"
    context.data["users"][uid]["submit_initial_onboarding_response"] = (
        submit_initial_onboarding_response["data"]
    )
