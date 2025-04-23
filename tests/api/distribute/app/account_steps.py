from behave import *
from hugoutils.utilities.dataclass_util import DataClassParser

from tests.api.distribute.app.app_dataclass import OpenAccountDTO, UserStatusDTO
from retry import retry
import tests.api.distribute.app.app_helper as ah
from tests.util.common_util import check_status_distribute

use_step_matcher("re")


@Step("I open user account(.*)")
def open_account(context, case: str):
    request = context.request

    open_account_dto_list = DataClassParser.parse_rows(
        context.table.rows, data_class=OpenAccountDTO
    )

    context.data = {} if context.data is None else context.data
    context.data["users"] = (
        {} if context.data.get("users", None) is None else context.data["users"]
    )

    for open_account_dto in open_account_dto_list:
        data = open_account_dto.get_dict()

        if data["phone_number"] == "random":
            data["phone_number"] = ah.get_rand_number(10)

        referral_code = open_account_dto.referral_code
        if referral_code:
            if referral_code.startswith("UID"):
                referee_user = context.data["users"].get(
                    open_account_dto.referral_code, {}
                )
                referral_code = referee_user["referralCode"]
            else:
                referral_code = "invalid-code"

        phone_number_prefix = "+65"
        if data["prefix_ph_num"] is not None:
            phone_number_prefix = data["prefix_ph_num"]
        auth_create_user = {
            "legal_name": data["legal_name"],
            "phone_number": phone_number_prefix + data["phone_number"],
            "email": data["email"],
            "password": ah.get_rand_number(6),
            "referral_code": referral_code,
        }

        auth_response = request.hugosave_post_request(
            ah.auth_user_urls["create"],
            data=auth_create_user,
            headers=ah.get_header(context),
        )
        if not check_status_distribute(auth_response, "200"):
            assert False, f"User Creation Failed.\nReceived : {auth_response}"

        user_profile_id = auth_response["data"]["userProfileId"]
        app_headers = ah.get_user_header(user_profile_id, context)
        if open_account_dto.org_id:
            app_headers["x-org-id"] = open_account_dto.org_id

        @retry(AssertionError, tries=10, delay=5, logger=None)
        def retry_account_status():
            response = request.hugosave_post_request(
                ah.user_profile_urls["root"],
                headers=app_headers,
            )
            if not check_status_distribute(response, "200"):
                assert False, f"Open account Failed.\nReceived : {response}"

            context.data["users"][
                open_account_dto.user_profile_identifier
            ] = user_profile_id
            assert (
                response["data"]["status"] == open_account_dto.status
            ), f"Error Opening Account for user {user_profile_id}\n Expected status: {open_account_dto.status}"

        retry_account_status()


@Step("I check account status")
def check_account_status(context):
    request = context.request

    users = DataClassParser.parse_rows(context.table.rows, data_class=UserStatusDTO)

    @retry(AssertionError, tries=40, delay=5, logger=None)
    def retry_account_status():
        active_users = 0
        for user in users:
            user_profile_id = context.data["users"].get(user.user_profile_identifier)
            if isinstance(user_profile_id, dict):
                active_users += 1
                continue
            response = request.hugosave_get_request(
                ah.user_profile_urls["status"],
                headers=ah.get_user_header(user_profile_id, context),
            )
            if not check_status_distribute(response, "200"):
                assert False, f"Fetch User status Failed.\nReceived : {response}"
            assert response["data"]["status"] == user.status

            response = request.hugosave_get_request(
                ah.user_profile_urls["details"],
                headers=ah.get_user_header(user_profile_id, context),
            )
            if not check_status_distribute(response, "200"):
                assert (
                    False
                ), f"Error getting user details for user profile id {user_profile_id}"

            context.data["users"][user.user_profile_identifier] = response["data"]
            user_state = response["data"]["userState"]["accountStage"]
            for map in response["data"]["userMaps"]:
                if map["mapType"] == "PM_GOLD_VAULT":
                    context.data["users"][user.user_profile_identifier][
                        "gold-map"
                    ] = map
                elif map["mapType"] == "PM_SILVER_VAULT":
                    context.data["users"][user.user_profile_identifier][
                        "silver-map"
                    ] = map
                elif map["mapType"] == "PM_PLATINUM_VAULT":
                    context.data["users"][user.user_profile_identifier][
                        "platinum-map"
                    ] = map
                elif map["mapType"] == "ETF_BALANCED_VAULT":
                    context.data["users"][user.user_profile_identifier][
                        "etf-balanced-map"
                    ] = map
                elif map["mapType"] == "ETF_GROWTH_VAULT":
                    context.data["users"][user.user_profile_identifier][
                        "etf-growth-map"
                    ] = map
                elif map["mapType"] == "ETF_CAUTIOUS_VAULT":
                    context.data["users"][user.user_profile_identifier][
                        "etf-cautious-map"
                    ] = map

            active_users += 1

        assert len(users) == active_users

    retry_account_status()


@Step("I check the referral status of user ([^']*) with referee user as ([^']*)")
def check_referral_status(context, referred: str, referee: str):
    referred_user = context.data["users"].get(referred)

    if referee != "invalid":
        referee_user_profile_id = ah.get_user_prof_id(context, referee)

        assert (
            referred_user["refereeUserProfileId"] == referee_user_profile_id
        ), "User was not referred correctly (or) user referral did not work"
    else:
        # referee_user_profile_id key should not be there
        assert "refereeUserProfileId" not in referred_user.keys()
