from behave import *
from hugoutils.utilities.dataclass_util import DataClassParser

from tests.api.distribute.behavioural.behavioural_dataclass import (
    EventDTO,
    OnboardDTO,
    QuestsDisplay,
    CohortMapping,
    UserReward,
    UserStreak,
    VerifyUserQuest,
    VerifyUserStep,
    Quest,
)
from retry import retry
import tests.api.distribute.behavioural.behavioural_helper as bh

use_step_matcher("re")


@Step("Push Event to Queue")
def emit_event(context):
    request = context.request

    event_dto_list = DataClassParser.parse_rows(context.table.rows, data_class=EventDTO)

    for event_dto in event_dto_list:
        user_profile_id = context.data["users"][event_dto.user_profile_identifier][
            "userProfileId"
        ]
        data = event_dto.get_dict(user_profile_id)
        if (
            hasattr(event_dto, "is_referral_event")
            and event_dto.is_referral_event is True
        ):
            referrer_user_profile_id = context.data["users"][
                event_dto.referred_user_identifier
            ]["userProfileId"]
            acct_type = event_dto.acct_type
            data = event_dto.get_referral_dict(
                user_profile_id, referrer_user_profile_id, acct_type
            )
        response = request.hugosave_post_request(
            bh.behavioural_urls["push_event"],
            data=data,
            headers=bh.get_user_header(user_profile_id, context),
        )

        assert int(response["headers"]["statusCode"]) == 200


@Step("Verify User Quest Progress")
def verify_user_quest_progress(context):
    request = context.request

    verify_user_quest_list = DataClassParser.parse_rows(
        context.table.rows, data_class=VerifyUserQuest
    )

    user_profile_id = context.data["users"][
        verify_user_quest_list[0].user_profile_identifier
    ]["userProfileId"]

    @retry(AssertionError, tries=10, delay=60, logger=None)
    def retry_fetching_user_progress(verify_user_quest_obj):
        response = request.hugosave_get_request(
            bh.behavioural_urls["user_quests_dto"],
            headers=bh.get_user_header(user_profile_id, context),
        )
        user_quest_progress_list = response["data"]["userQuest"]
        quest_identified_in_loop = False
        expected_quest_identified_in_loop = True
        for user_quest_progress in user_quest_progress_list:
            if user_quest_progress["questId"] == verify_user_quest_obj.quest_id:
                quest_identified_in_loop = True
                assert (
                    user_quest_progress["userQuestStage"]
                    == verify_user_quest_obj.user_quest_stage
                )

        assert quest_identified_in_loop == expected_quest_identified_in_loop

    for verify_user_quest in verify_user_quest_list:
        retry_fetching_user_progress(verify_user_quest)


@Step("Verify User Step Progress")
def verify_user_step_progress(context):
    request = context.request

    verify_user_step_list = DataClassParser.parse_rows(
        context.table.rows, data_class=VerifyUserStep
    )

    user_profile_id = context.data["users"][
        verify_user_step_list[0].user_profile_identifier
    ]["userProfileId"]

    @retry(AssertionError, tries=10, delay=30, logger=None)
    def retry_fetching_user_step_progress(verify_user_ste_obj):
        response = request.hugosave_get_request(
            bh.behavioural_urls["user_quests_dto"],
            headers=bh.get_user_header(user_profile_id, context),
        )
        user_quest_progress_list = response["data"]["userQuest"]
        quest_step_identified_in_loop = False
        expected_quest_step_identified_in_loop = True
        for user_quest_progress in user_quest_progress_list:
            if user_quest_progress["questId"] == verify_user_ste_obj.quest_id:
                user_step_progress_list = user_quest_progress["userStep"]
                for user_step_progress in user_step_progress_list:
                    if user_step_progress["stepId"] == verify_user_ste_obj.step_id:
                        quest_step_identified_in_loop = True
                        assert (
                            user_step_progress["stage"]
                            == verify_user_ste_obj.user_step_stage
                        )

        assert quest_step_identified_in_loop == expected_quest_step_identified_in_loop

    for verify_user_step in verify_user_step_list:
        retry_fetching_user_step_progress(verify_user_step)


@Step("Change User State")
def change_user_state(context):
    request = context.request

    onboard_dto = DataClassParser.parse_rows(context.table.rows, data_class=OnboardDTO)[
        0
    ]

    user_profile_id = context.data["users"][onboard_dto.user_profile_identifier][
        "userProfileId"
    ]
    response = request.hugosave_post_request(
        bh.behavioural_urls["onboarding"],
        data=onboard_dto.get_dict(user_profile_id),
        headers=bh.get_user_header(user_profile_id, context),
    )

    assert int(response["headers"]["statusCode"]) == 200


@Step("Verify User Streak")
def verify_user_streak(context):
    request = context.request

    user_streak = DataClassParser.parse_rows(context.table.rows, data_class=UserStreak)[
        0
    ]

    user_profile_id = context.data["users"][user_streak.user_profile_identifier][
        "userProfileId"
    ]

    @retry(AssertionError, tries=10, delay=30, logger=None)
    def retry_verifying_user_streak():
        response = request.hugosave_get_request(
            bh.behavioural_urls["user_quests_dto"],
            headers=bh.get_user_header(user_profile_id, context),
        )
        user_quest_progress_list = response["data"]["userQuest"]
        quest_step_identified_in_loop = False
        expected_quest_step_identified_in_loop = True
        for user_quest_progress in user_quest_progress_list:
            if user_quest_progress["questId"] == user_streak.quest_id:
                user_step_progress_list = user_quest_progress["userStep"]
                for user_step_progress in user_step_progress_list:
                    if user_step_progress["stepId"] == user_streak.step_id:
                        if "streak" in user_step_progress["metaData"]:
                            quest_step_identified_in_loop = True
                            assert (
                                user_step_progress["metaData"]["streak"]
                                == user_streak.streak
                            )
                        if "streak_ts" in user_step_progress["metaData"]:
                            assert (
                                user_step_progress["metaData"]["streak_ts"]
                                == user_streak.streak_ts
                            ), (
                                f"response from db : {user_quest_progress_list}",
                                f"feature file input : {user_quest_progress_list}",
                            )
                        if (
                            hasattr(user_streak, "isStreakMissed")
                            and user_streak.is_streak_missed == True
                            and "missedStreak" in user_step_progress["metaData"]
                        ):
                            assert (
                                user_step_progress["metaData"]["missedStreak"]
                                == user_streak.missed_streak
                            )
                            assert (
                                user_step_progress["metaData"]["missedResetTs"]
                                == user_streak.missed_reset_ts
                            )

        assert quest_step_identified_in_loop == expected_quest_step_identified_in_loop

    retry_verifying_user_streak()


@Step("Claim User Reward")
def claim_user_reward(context):
    request = context.request

    user_reward = DataClassParser.parse_rows(context.table.rows, data_class=UserReward)[
        0
    ]

    user_profile_id = context.data["users"][user_reward.user_profile_identifier][
        "userProfileId"
    ]

    @retry(AssertionError, tries=10, delay=30, logger=None)
    def retry_fetching_user_reward():
        response = request.hugosave_get_request(
            bh.behavioural_urls["user_quests_dto"],
            headers=bh.get_user_header(user_profile_id, context),
        )
        user_quest_progress_list = response["data"]["userQuest"]
        for user_quest_progress in user_quest_progress_list:
            if user_quest_progress["questId"] == user_reward.quest_id:
                user_reward_ide = user_quest_progress["userRewardId"]
                assert user_quest_progress["userQuestStage"] != ""
                return user_reward_ide

    user_reward_id = retry_fetching_user_reward()

    response = request.hugosave_post_request(
        bh.behavioural_urls["claim_reward"].replace("user-reward-id", user_reward_id),
        headers=bh.get_user_header(user_profile_id, context),
    )

    assert int(response["headers"]["statusCode"]) == 200

    valid_statuses = ["CLAIMED", "REWARD_INITIATED", "REWARDED"]

    @retry(AssertionError, tries=10, delay=30, logger=None)
    def validate_user_reward_status():
        claimed_response = request.hugosave_get_request(
            bh.behavioural_urls["fetch_claimed_reward"],
            headers=bh.get_user_header(user_profile_id, context),
        )
        reward_identified_in_loop = False
        expected_reward_identified_in_loop = True
        reward_response_list = claimed_response["data"]["userRewards"]
        for reward_response in reward_response_list:
            if reward_response["userRewardId"] == user_reward_id:
                reward_identified_in_loop = True
                assert reward_response["rewardStage"] in valid_statuses

        assert reward_identified_in_loop == expected_reward_identified_in_loop


@Step("Verify User Quest Referral Progress")
def verify_user_referral_progress(context):
    request = context.request

    verify_user_referral_quest_list = DataClassParser.parse_rows(
        context.table.rows, data_class=VerifyUserQuest
    )

    user_profile_id = context.data["users"][
        verify_user_referral_quest_list[0].user_profile_identifier
    ]["userProfileId"]

    @retry(AssertionError, tries=10, delay=30, logger=None)
    def retry_fetching_user_referral_progress(verify_user_quest_obj):
        response = request.hugosave_get_request(
            bh.behavioural_urls["user_referrals"],
            headers=bh.get_user_header(user_profile_id, context),
        )
        user_referral_quest_progress_list = response["data"]["userReferral"]
        quest_identified_in_loop = False
        expected_quest_identified_in_loop = True
        for user_referral_quest_progress in user_referral_quest_progress_list:
            if (
                user_referral_quest_progress["questId"]
                == verify_user_quest_obj.quest_id
            ):
                quest_identified_in_loop = True
                assert (
                    user_referral_quest_progress["userReferralStage"]
                    == verify_user_quest_obj.user_quest_stage
                )

        assert quest_identified_in_loop == expected_quest_identified_in_loop

    for verify_user_quest in verify_user_referral_quest_list:
        retry_fetching_user_referral_progress(verify_user_quest)


@Step("Verify Quest List Shown to User")
def verify_quest_list_shown_to_user(context):
    request = context.request
    quest_display_dto = DataClassParser.parse_rows(
        context.table.rows, data_class=QuestsDisplay
    )[0]

    user_profile_id = context.data["users"][quest_display_dto.user_profile_identifier][
        "userProfileId"
    ]

    response = request.hugosave_get_request(
        bh.behavioural_urls["quests"],
        headers=bh.get_user_header(user_profile_id, context),
    )

    quest_list = response["data"]["quests"]
    quest_expected_display_list = quest_display_dto.get_display_list()
    for quest in quest_list:
        expected_result = True
        is_quest_available = False
        if quest["questId"] in quest_expected_display_list:
            is_quest_available = True

        assert expected_result == is_quest_available, (
            f"DB Quests List : {quest_list}",
            f"Expected quests list : {quest_expected_display_list}",
        )


@Step("Verify Cohort Mapping")
def verify_cohort_mapping(context):
    request = context.request
    cohort_mapping = DataClassParser.parse_rows(
        context.table.rows, data_class=CohortMapping
    )[0]

    user_profile_id = context.data["users"][cohort_mapping.user_profile_identifier][
        "userProfileId"
    ]

    response = request.hugosave_get_request(
        bh.behavioural_urls["user_quest_profile"],
        headers=bh.get_user_header(user_profile_id, context),
    )

    cohort_list = response["data"]["cohortMappings"]
    expected_cohort_list = cohort_mapping.get_display_list()
    for expected_cohort in expected_cohort_list:
        expected_result = True
        is_cohort_available = False
        if expected_cohort in cohort_list:
            is_cohort_available = True

        assert expected_result == is_cohort_available


@Step("Add cohort ([^']*) to User ([^']*)")
def add_cohort(context, cohort: str, user: str):
    request = context.request
    user_profile_id = context.data["users"][user]["userProfileId"]
    response = request.hugosave_post_request(
        bh.behavioural_urls["add_cohort"] + f"?cohort-id={cohort}",
        headers=bh.get_user_header(user_profile_id, context),
    )

    assert response["headers"]["statusCode"] == "200", (
        f"Received response : {int(response['headers']['statusCode'])}",
    )


@Step("User ([^']*) reset Stats for the quest ([^']*)")
def reset_stats(context, user: str, quest_id: str):
    request = context.request
    user_profile_id = context.data["users"][user]["userProfileId"]
    response = request.hugosave_post_request(
        bh.behavioural_urls["reset_quest_stats"].replace("quest-id", quest_id),
        headers=bh.get_user_header(user_profile_id, context),
    )

    assert response["headers"]["statusCode"] == "200", (
        f"Received response : {int(response['headers']['statusCode'])}",
    )


@Step("Create New Quest")
def create_quest(context):
    request = context.request
    quest_data_list = DataClassParser.parse_rows(context.table.rows, data_class=Quest)
    user_profile_id = context.data["users"][quest_data_list[0].user_profile_identifier][
        "userProfileId"
    ]

    for quest_data in quest_data_list:
        data = quest_data.get_dict(user_profile_id)
        step_state_key = data["quest_id"]

        create_quest = {
            "quest_id": data["quest_id"],
            "quest_name": data["quest_name"],
            "depends_on_quest_id": quest_data.get_display_list(),
            "sequence": data["sequence"],
            "steps": data["steps"],
            "cohort_id": data["cohort_id"],
            "reward_id": "mega-wheel-01",
            "status": "ENABLED",
            "frequency": "ONCE",
            "shariah_compliant": "true",
            "theme": "standard",
        }

        if data.get("activation_details") is not None:
            create_quest["activation_details"] = data["activation_details"]

        if data.get("required_user_state") is not None:
            required_user_state = {
                "quest_state": {
                    step_state_key: {
                        "states": [
                            {
                                "state_name": data["required_user_state"],
                                "active_display_text": "Roundups",
                                "inactive_display_text": "Roundups",
                            }
                        ]
                    }
                }
            }
            create_quest["required_user_state"] = required_user_state

        response = request.hugosave_post_request(
            bh.behavioural_urls["create_quest"],
            data=create_quest,
            headers=bh.get_user_header(user_profile_id, context),
        )

        assert (
            response["headers"]["statusCode"] == "200"
            or response["headers"]["statusCode"] == "E9601"
        ), (f"Received response : {int(response['headers']['statusCode'])}",)
