from behave import *
from hugoutils.utilities.dataclass_util import DataClassParser
from retry import retry

import tests.api.distribute.behavioural.behavioural_helper as bh
from tests.api.distribute.behavioural.behavioural_dataclass import DailyTaskScheduler


@Step("Verify valid until timestamp")
def verify_valid_until_ts(context):
    request = context.request

    expected_user_quest = DataClassParser.parse_rows(
        context.table.rows, data_class=DailyTaskScheduler
    )[0]

    user_profile_id = context.data["users"][
        expected_user_quest.user_profile_identifier
    ]["userProfileId"]

    @retry(AssertionError, tries=10, delay=60, logger=None)
    def retry_fetching_user_quests():
        user_quest_list = request.hugosave_get_request(
            bh.behavioural_urls["user_quests"],
            headers=bh.get_user_header(user_profile_id, context),
        )

        quest_identified_in_loop = False
        expected_quest_identified_in_loop = True

        for user_quest in user_quest_list:
            if user_quest["questId"] == expected_user_quest.quest_id:
                quest_identified_in_loop = True
                assert user_quest["validUntilTs"] == expected_user_quest.valid_until_ts
        assert quest_identified_in_loop == expected_quest_identified_in_loop

    retry_fetching_user_quests()
