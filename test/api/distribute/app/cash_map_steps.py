from behave import *
from hugoutils.utilities.dataclass_util import DataClassParser

from test.api.distribute.app.app_dataclass import (
    CreateMapDTO,
    InvestMapDTO,
    UpdateMapDTO,
    WithdrawMapDTO,
)
from retry import retry
import test.api.distribute.app.app_helper as ah
from test.util.common_util import check_status_distribute

use_step_matcher("re")


def get_maps(request, user_prof_id, context):
    response = request.hugosave_get_request(
        ah.user_profile_urls["map-list"], headers=ah.get_user_header(user_prof_id, context)
    )

    if not check_status_distribute(response, "200"):
        print("Error getting maps")

    return response["data"]["maps"]


@Step("I create a Map ([^']*)")
def create_map(context, map_identifier: str):
    request = context.request
    create_map_list_dto = DataClassParser.parse_rows(
        context.table.rows, data_class=CreateMapDTO
    )

    for create_map_dto in create_map_list_dto:
        create_map_dto_data = create_map_dto.get_dict()
        user_profile_identifier = create_map_dto.user_profile_identifier
        user = context.data["users"].get(user_profile_identifier)
        user_prof_id = user["userProfileId"]
        response = request.hugosave_post_request(
            ah.map_urls["root"],
            data=create_map_dto_data,
            headers=ah.get_user_header(user_prof_id, context),
        )

        passed = check_status_distribute(response, "200")
        if not passed:
            print(f"Creating map failed with the given details.\nReceived : {response}")

        context.data["users"][user_profile_identifier][map_identifier] = create_map_dto_data


@Step("I check if the map ([^']*) status is ([^']*) for user ([^']*)")
def check_map_status(context, map_identifier: str, status, user):
    request = context.request

    user_profile_identifier = user
    user = context.data["users"].get(user)
    user_prof_id = user["userProfileId"]
    user_map_name = context.data["users"][user_profile_identifier][map_identifier]['name']

    @retry(AssertionError, tries=10, delay=10, logger=None)
    def retry_for_map_status():
        user_maps = get_maps(request, user_prof_id, context)
        for map in user_maps:
            if map['mapName'] == user_map_name:
                assert map['status'] == status, "Map status not created"
                context.data["users"][user_profile_identifier][map_identifier] = map

    retry_for_map_status()


@Step("I invest in map ([^']*)")
def invest_map(context, map_identifier: str):
    request = context.request
    invest_map_dto = DataClassParser.parse_row(context.table.rows[0], data_class=InvestMapDTO)

    user_profile_identifier = invest_map_dto.user_profile_identifier
    user = context.data["users"].get(user_profile_identifier)
    user_prof_id = user["userProfileId"]

    map_id = context.data["users"][user_profile_identifier][map_identifier]['userMapId']
    if invest_map_dto.invalid_map == "Y":
        map_id = ah.get_uuid()

    response = request.hugosave_post_request(
        ah.map_urls["invest"].replace("map-id", map_id),
        data=invest_map_dto.get_dict(),
        headers=ah.get_user_header(user_prof_id, context),
    )

    assert check_status_distribute(
        response, invest_map_dto.status_code
    ), f"""
        \nExpected Status: {invest_map_dto.status_code}\n
        Actual Status: {response["headers"]["statusCode"]}
        """


@Step("I check the balance of map ([^']*) of user ([^']*) to be ([^']*) SGD")
def check_map_invest_status(context, map_identifier, user, expected_balance):
    request = context.request

    user_profile_identifier = user
    user = context.data["users"].get(user_profile_identifier)
    user_prof_id = user["userProfileId"]
    expected_balance = float(expected_balance)

    user_map_id = ah.get_user_map_id(context, map_identifier, user_profile_identifier)

    @retry(AssertionError, tries=30, delay=10, logger=None)
    def retry_for_asset_balance():
        response = request.hugosave_get_request(
            ah.balance_urls["map"].replace("map-id", user_map_id),
            headers=ah.get_user_header(user_prof_id, context),
        )

        assert check_status_distribute(response, "200"), "Error getting map balance"
        actual_balance = response["data"]["currentValue"]

        if actual_balance != expected_balance:
            assert (
                False
            ), f"\nExpected balance: {expected_balance}\nActual balance: {actual_balance}"

    retry_for_asset_balance()


@Step("I withdraw from map ([^']*)")
def withdraw_map(context, map_identifier: str):
    request = context.request
    withdraw_map_dto = DataClassParser.parse_row(
        context.table.rows[0], data_class=WithdrawMapDTO
    )

    user_profile_identifier = withdraw_map_dto.user_profile_identifier
    user = context.data["users"].get(user_profile_identifier)
    user_prof_id = user["userProfileId"]

    map_id = context.data["users"][user_profile_identifier][map_identifier]['userMapId']
    if withdraw_map_dto.invalid_map == "Y":
        map_id = ah.get_uuid()
    response = request.hugosave_post_request(
        ah.map_urls["withdraw"].replace("map-id", map_id),
        data=withdraw_map_dto.get_dict(),
        headers=ah.get_user_header(user_prof_id, context),
    )

    assert check_status_distribute(
        response, withdraw_map_dto.status_code
    ), f"""
        \nExpected Status: {withdraw_map_dto.status_code}\n
        Actual Status: {response["headers"]["statusCode"]}
        """


@Step("I update the map ([^']*) and check if update was successful")
def update_map(context, map_identifier):
    request = context.request
    update_map_dto = DataClassParser.parse_row(context.table.rows[0], data_class=UpdateMapDTO)

    user_profile_identifier = update_map_dto.user_profile_identifier
    user = context.data["users"].get(user_profile_identifier)
    user_prof_id = user["userProfileId"]

    update_map_id = context.data["users"][user_profile_identifier][map_identifier]['userMapId']
    if update_map_dto.invalid_map == "Y":
        update_map_id = ah.get_uuid()

    response = request.hugosave_put_request(
        ah.map_urls["update"].replace("map-id", update_map_id),
        data=update_map_dto.get_dict(),
        headers=ah.get_user_header(user_prof_id, context),
    )

    assert check_status_distribute(
        response, update_map_dto.status_code
    ), f"""
        \nExpected Status: {update_map_dto.status_code}\n
        Actual Status: {response["headers"]["statusCode"]}
        """

    if update_map_dto.status_code == "HSA_9107":
        return

    # get map details and check if updated values are reflected
    updated_map = None
    returned_maps = get_maps(request, user_prof_id, context)
    for m in returned_maps:
        if m["userMapId"] == update_map_id:
            updated_map = m
            break

    context.data["users"][user_profile_identifier][map_identifier] = updated_map
    if update_map_dto.name != updated_map["mapName"]:
        assert False, "Name not updated"
    if update_map_dto.goal_date != updated_map["metadata"]["data"][0]["stringValue"]:
        assert False, "Goal Date not updated"
    if update_map_dto.goal_amount != updated_map["metadata"]["data"][1]["doubleValue"]:
        assert False, "Goal Amount not updated"


@Step("I delete the map ([^']*) of user ([^']*)")
def delete_map(context, map_identifier: str, user_identifier):
    request = context.request

    user = context.data["users"].get(user_identifier)
    user_prof_id = user["userProfileId"]
    map_id = context.data["users"][user_identifier][map_identifier]["userMapId"]

    response = request.hugosave_delete_request(
        ah.map_urls["update"].replace("map-id", map_id),
        headers=ah.get_user_header(user_prof_id, context),
    )

    if not check_status_distribute(response, "200"):
        print(f"Error deleting map.\nReceived : {response}")


@then("I check if the cash map ([^']*) is deleted successfully for user ([^']*)")
def step_impl(context, map_identifier: str, user_identifier: str):
    request = context.request

    user = context.data["users"].get(user_identifier)
    user_prof_id = user["userProfileId"]
    map_id = context.data["users"][user_identifier][map_identifier]['userMapId']

    response = request.hugosave_get_request(
        ah.map_urls["update"].replace("map-id", map_id),
        headers=ah.get_user_header(user_prof_id, context),
    )

    assert (
        response['headers']['statusCode'] == 'HSA_9107'
    ), f"Expected map to be deleted. Response : {response}"
