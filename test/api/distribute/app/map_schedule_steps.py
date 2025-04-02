import random

from behave import *
from hugoutils.utilities.dataclass_util import DataClassParser

from test.api.distribute.app.app_dataclass import (
    CreateMapScheduleDTO,
    Frequency,
    ScheduleMapInvest,
    WeekDay,
)
import test.api.distribute.app.app_helper as ah
from test.util.common_util import check_status_distribute

use_step_matcher("re")


def get_schedule_map_invest_data(
    context, user_map_id, user_profile_id, user_main_account_id, amount
):
    request = context.request
    print(user_map_id)
    response = request.hugosave_get_request(
        path=ah.map_urls["update"].replace("map-id", user_map_id),
        headers=ah.get_user_header(user_profile_id, context),
    )

    if not check_status_distribute(response, "200"):
        assert False, f"Unable to fetch map details.\nReceived : {response}"

    return ScheduleMapInvest(
        map_id=user_map_id,
        map_name=response["data"]["mapName"],
        map_type=response["data"]["mapType"],
        amount=amount,
        units=random.randrange(2),
        payee_account_id=user_main_account_id,
        map_category=response["data"]["mapCategory"],
        map_goal_amount=random.randrange(5, 15),
        map_invested_amount=response["data"]["amountInvested"],
    )


def get_account_id_by_subtype(
    context, user_profile_identifier: str, account_subtype: str
):
    for account in context.data["users"][user_profile_identifier]["userAccounts"]:
        if account["accountSubtype"] == account_subtype:
            return account["accountId"]

    assert (
        False
    ), f"User {user_profile_identifier} account not found for subtype : {account_subtype}"


def get_account_field(user_details, account_type):
    account = None
    for acc in user_details["user_details_response"][
        "userCashAccounts"
    ]:  # changed userAccounts to userCashAccounts
        if account_type == "cash":
            account = acc["accountId"]
            print(account)
        else:
            if "userCardAccounts" in acc and acc["userCardAccounts"]:
                print(acc["userCardAccounts"][0]["cardAccountId"])
                account = acc["userCardAccounts"][0]["cardAccountId"]
            else:
                print("Card ID not found.")
    return account


@Step("I create a schedule for map ([^']*) and expect status ([^']*)")
def create_map_schedule(context, map_identifier: str, status: str):
    request = context.request
    schedule_map_dto = DataClassParser.parse_row(
        context.table.rows[0], data_class=CreateMapScheduleDTO
    )
    user_profile_identifier = schedule_map_dto.user_profile_identifier

    user_prof_id = ah.get_user_profile_id(user_profile_identifier, context)

    user_map_id = ah.get_user_map_id(context, map_identifier, user_profile_identifier)
    amount = schedule_map_dto.amount
    user_details = context.data["users"].get(user_profile_identifier)

    user_main_account_id = get_account_field(user_details, "cash")
    schedule_map_dto.schedule_map_invest = get_schedule_map_invest_data(
        context, user_map_id, user_prof_id, user_main_account_id, amount
    )

    schedule_map_dto.target_week = 0
    schedule_map_dto.frequency = list(Frequency)[random.randrange(0, 3)].name
    if schedule_map_dto.frequency == "MONTHLY":
        schedule_map_dto.target_weekdays = list(WeekDay)[random.randrange(1, 6)].name
        schedule_map_dto.target_week = random.randrange(1, 5)
    elif schedule_map_dto.frequency == "WEEKLY":
        schedule_map_dto.target_weekdays = list(WeekDay)[random.randrange(1, 6)].name

    response = request.hugosave_post_request(
        ah.map_schedule_urls["root"],
        data=schedule_map_dto.get_dict(),
        headers=ah.get_user_header(user_prof_id, context),
    )

    if not check_status_distribute(response, status):
        assert False, f"Map Schedule creation failed.\nReceived : {response}"
    if "data" in response:
        context.data[schedule_map_dto.schedule_identifier] = response["data"]


@Step("I trigger schedule ([^']*) for user ([^']*)")
def trigger_schedule(context, schedule_identifier: str, user_identifier: str):
    request = context.request
    user_prof_id = ah.get_user_profile_id(user_identifier, context)

    if "SCHEDULE_ROUNDUP" in schedule_identifier:
        round_up_schedule_repsonse = request.hugosave_post_request(
            path=ah.dev_urls["clear_roundup_schedule"],
            headers=ah.get_user_header(user_prof_id, context),
        )
        check_status_distribute(round_up_schedule_repsonse, "200")
    else:
        schedule_id = context.data[schedule_identifier]["scheduleId"]
        response = request.hugosave_put_request(
            ah.dev_urls["schedule_trigger"].replace("schedule-id", schedule_id),
            headers=ah.get_user_header(user_prof_id, context),
        )
        check_status_distribute(response, "200")


@then("I check if the schedule ([^']*) status ([^']*) for user ([^']*)")
def step_impl(context, schedule_identifier: str, status: str, user_identifier: str):
    request = context.request
    user_prof_id = ah.get_user_profile_id(user_identifier, context)
    schedule_id = context.data[schedule_identifier]["scheduleId"]

    response = request.hugosave_get_request(
        ah.map_schedule_urls["detail"].replace("schedule-id", schedule_id),
        headers=ah.get_user_header(user_prof_id, context),
    )
    check_status_distribute(response, status)


@then("I delete schedule ([^']*) for user ([^']*)")
def step_impl(context, schedule_identifier: str, user_identifier: str):
    request = context.request
    user_prof_id = ah.get_user_profile_id(user_identifier, context)
    schedule_id = context.data[schedule_identifier]["scheduleId"]

    response = request.hugosave_delete_request(
        ah.map_schedule_urls["root"] + "/" + schedule_id,
        headers=ah.get_user_header(user_prof_id, context),
    )
    check_status_distribute(response, "200")


@then("I check schedule status as ([^']*) for schedule ([^']*) for user ([^']*)")
def step_impl(
    context, status: str, schedule_identifier: str, user_profile_identifier: str
):
    request = context.request
    user_prof_id = ah.get_user_profile_id(user_profile_identifier, context)
    schedule_id = context.data[schedule_identifier]["scheduleId"]

    response = request.hugosave_get_request(
        ah.map_schedule_urls["detail"].replace("schedule-id", schedule_id),
        headers=ah.get_user_header(user_prof_id, context),
    )
    check_status_distribute(response, "200")
    assert (
        response["data"]["scheduleStatus"] == status
    ), f'Schedule status expected to be {status}. But received: {response["data"]}'
