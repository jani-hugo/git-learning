behavioural_base_url = "/behavioural/v2"
reward_base_url = "/reward/v2"

behavioural_urls = {
    "onboarding": behavioural_base_url + "/internal/onboarding",
    "push_event": behavioural_base_url + "/event/server",
    "user_quests_dto": behavioural_base_url + "/quests/user-quests",
    "user_state": behavioural_base_url + "/quests/user-state-changed",
    "claim_reward": reward_base_url + "/user-reward/user-reward-id/claim",
    "fetch_claimed_reward": reward_base_url + "/user-reward/claimed",
    "fetch_onboard_dto": behavioural_base_url + "/dev/user",
    "user_quest_profile": behavioural_base_url + "/dev/user-quest-profile",
    "user_referrals": behavioural_base_url + "/quests/user-referrals/unlocked",
    "user_quests": behavioural_base_url + "/dev/user-quests",
    "quests": behavioural_base_url + "/quests",
    "migrate": behavioural_base_url + "/internal/migrate",
    "create_quest": behavioural_base_url + "/internal/create/quest",
    "add_cohort": behavioural_base_url + "/internal/cohort",
    "reset_quest_stats": behavioural_base_url + "/dev/reset-quest-stats/quest-id",
}


def get_user_header(uid, context):
    return {
        "x-user-profile-id": uid,
        "app-build-version": context.data["config_data"]["app-build-version"],
    }


onboarding_fields = [
    "email",
    "first_name",
    "account_type",
    "time_zone",
    "roundups_enabled",
    "profile_status",
]

quest_user_profile_entity_fields = [
    "account_type",
    "time_zone",
    "roundups_enabled",
    "profile_status",
]
