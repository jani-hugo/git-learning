from behave import *
from hugoutils.utilities.dataclass_util import DataClassParser

import tests.api.distribute.behavioural.behavioural_helper as bh
from tests.api.distribute.behavioural.behavioural_dataclass import (
    OnboardDTO,
    QuestUserProfileEntity,
)


@Step("Onboard the User to Behavioural and User Engaging Platforms")
def onboard_user(context):
    request = context.request

    onboard_dto_list = DataClassParser.parse_rows(
        context.table.rows, data_class=OnboardDTO
    )

    user_profile_id = context.data["users"][
        onboard_dto_list[0].user_profile_identifier
    ]["userProfileId"]
    response = request.hugosave_post_request(
        bh.behavioural_urls["onboarding"],
        data=onboard_dto_list[0].get_dict(user_profile_id),
        headers=bh.get_user_header(user_profile_id, context),
    )

    assert int(response["headers"]["statusCode"]) == 200


@Step("Verify Onboard Details")
def verify_onboard_user(context):
    request = context.request

    onboard_dto_list = DataClassParser.parse_rows(
        context.table.rows, data_class=OnboardDTO
    )
    user_profile_id = context.data["users"][
        onboard_dto_list[0].user_profile_identifier
    ]["userProfileId"]
    onboard_dto = onboard_dto_list[0].get_dict(user_profile_id)

    response = request.hugosave_get_request(
        bh.behavioural_urls["fetch_onboard_dto"],
        headers=bh.get_user_header(user_profile_id, context),
    )

    onboard_dto_db = response["data"]
    onboard_dto["email"] = (
        "testaccounts" + onboard_dto_db["phoneNumber"] + "@hugosave.com"
    )

    for onboarding_field in bh.onboarding_fields:
        if onboarding_field in onboard_dto_db:
            if onboard_dto_db[onboarding_field] != onboard_dto[onboarding_field]:
                assert False, (
                    f"Values mismatch for {onboarding_field}. "
                    f"Expected - {onboard_dto_db[onboarding_field]}. "
                    f"Provided - {onboard_dto[onboarding_field]}"
                )


@Step("Verify User Quest Profile Details")
def verify_user_quest_profile(context):
    request = context.request

    quest_user_profile_entity_list = DataClassParser.parse_rows(
        context.table.rows, data_class=QuestUserProfileEntity
    )
    user_profile_id = context.data["users"][
        quest_user_profile_entity_list[0].user_profile_identifier
    ]["userProfileId"]
    quest_user_profile_entity = quest_user_profile_entity_list[0].get_dict(
        user_profile_id
    )

    response = request.hugosave_get_request(
        bh.behavioural_urls["user_quest_profile"],
        headers=bh.get_user_header(user_profile_id, context),
    )

    quest_user_profile_entity_db = response["data"]

    for quest_user_profile_entity_field in bh.quest_user_profile_entity_fields:
        if quest_user_profile_entity_field in quest_user_profile_entity_db:
            assert (
                quest_user_profile_entity_db[quest_user_profile_entity_field]
                == quest_user_profile_entity[quest_user_profile_entity_field]
            )


@Step("Onboard Users with Spaces in Fields")
def onboard_users_with_spaces(context):
    request = context.request

    onboard_dto_list = DataClassParser.parse_rows(
        context.table.rows, data_class=OnboardDTO
    )

    user_profile_id = context.data["users"][
        onboard_dto_list[0].user_profile_identifier
    ]["userProfileId"]
    onboard_dto = onboard_dto_list[0].get_dict(user_profile_id)

    for onboarding_field in bh.onboarding_fields:
        if onboarding_field in onboard_dto:
            onboard_dto[onboarding_field] = "  " + onboard_dto[onboarding_field] + "  "

    response = request.hugosave_post_request(
        bh.behavioural_urls["onboarding"],
        data=onboard_dto,
        headers=bh.get_user_header(user_profile_id, context),
    )

    assert int(response["headers"]["statusCode"]) == 200
