from typing import Optional
import dataclasses
import json

from hugoutils.utilities.utilities import DictUtils


@dataclasses.dataclass
class OnboardDTO:
    user_profile_identifier: str
    email: Optional[str]
    first_name: Optional[str]
    last_name: Optional[str]
    phone_number: Optional[str]
    account_type: Optional[str]
    time_zone: Optional[str]
    roundups_enabled: Optional[bool]
    profile_status: Optional[str]

    def get_dict(self, user_profile_id):
        return DictUtils.strip_null(
            {
                "user_profile_id": user_profile_id,
                "email": self.email,
                "first_name": self.first_name,
                "last_name": self.last_name,
                "phone_number": self.phone_number,
                "account_type": self.account_type,
                "time_zone": self.time_zone,
                "roundups_enabled": self.roundups_enabled,
                "profile_status": self.profile_status,
            }
        )


@dataclasses.dataclass
class EventDTO:
    id: str
    user_profile_identifier: str
    event_type: str
    event_sub_type: Optional[str]
    event_source: str
    generic_fields: str
    secure_fields: str
    event_ts: str
    push_to_behavioural: Optional[bool]
    push_to_braze: Optional[bool]
    push_to_mixpanel: Optional[bool]
    is_referral_event: Optional[bool]
    referred_user_identifier: Optional[str]
    acct_type: Optional[str]

    def get_dict(self, user_profile_id):
        generic_fields = json.loads(self.generic_fields)
        secure_fields = json.loads(self.secure_fields)
        return {
            "user_profile_id": user_profile_id,
            "event_type": self.event_type,
            "event_sub_type": self.event_sub_type,
            "event_source": self.event_source,
            "generic_fields": generic_fields,
            "secure_fields": secure_fields,
            "event_ts": self.event_ts,
            "push_to_behavioural": self.push_to_behavioural,
            "push_to_braze": self.push_to_braze,
            "push_to_mixpanel": self.push_to_mixpanel,
        }

    def get_referral_dict(self, user_profile_id, referrer_user_profile_id, acct_type):
        secure_fields = json.loads(self.secure_fields)
        return {
            "user_profile_id": user_profile_id,
            "event_type": self.event_type,
            "event_sub_type": self.event_sub_type,
            "event_source": self.event_source,
            "generic_fields": {
                "meta_data": [
                    {
                        "event_key": "invited_user",
                        "string_value": referrer_user_profile_id,
                    },
                    {"event_key": "acct_type", "string_value": acct_type},
                ]
            },
            "secure_fields": secure_fields,
            "event_ts": self.event_ts,
            "push_to_behavioural": self.push_to_behavioural,
            "push_to_braze": self.push_to_braze,
            "push_to_mixpanel": self.push_to_mixpanel,
        }


@dataclasses.dataclass
class Quest:
    user_profile_identifier: str
    quest_id: str
    quest_name: str
    cohort_id: str
    depends_on_quest_id: str
    sequence: int
    activation_details: Optional[str]
    required_user_state: Optional[str]
    steps: str

    def get_dict(self, user_profile_id):
        steps = json.loads(self.steps)
        activation_details = json.loads(self.activation_details)
        return {
            "user_profile_id": user_profile_id,
            "quest_id": self.quest_id,
            "quest_name": self.quest_name,
            "cohort_id": self.cohort_id,
            "depends_on_quest_id": self.depends_on_quest_id,
            "sequence": self.sequence,
            "required_user_state": self.required_user_state,
            "activation_details": activation_details,
            "steps": steps,
        }

    def get_display_list(self):
        display_list = json.loads(self.depends_on_quest_id)["id"]
        return display_list


@dataclasses.dataclass
class VerifyUserQuest:
    user_profile_identifier: str
    quest_id: str
    user_quest_stage: str

    def get_dict(self):
        return {
            "user_profile_identifier": self.user_profile_identifier,
            "quest_id": self.quest_id,
            "user_quest_stage": self.user_quest_stage,
        }


@dataclasses.dataclass
class VerifyUserStep:
    user_profile_identifier: str
    quest_id: str
    step_id: str
    user_step_stage: str

    def get_dict(self):
        return {
            "user_profile_identifier": self.user_profile_identifier,
            "quest_id": self.quest_id,
            "step_id": self.step_id,
            "user_step_stage": self.user_step_stage,
        }


@dataclasses.dataclass
class UserStreak:
    user_profile_identifier: str
    quest_id: str
    step_id: str
    streak: str
    streak_ts: str
    is_streak_missed: Optional[bool]
    missed_streak: Optional[str]
    missed_reset_ts: Optional[str]


@dataclasses.dataclass
class UserReward:
    user_profile_identifier: str
    quest_id: str


@dataclasses.dataclass
class DailyTaskScheduler:
    user_profile_identifier: str
    quest_id: str
    valid_until_ts: str


@dataclasses.dataclass
class QuestsDisplay:
    user_profile_identifier: str
    quest_list: str

    def get_display_list(self):
        display_list = json.loads(self.quest_list)["quest_list"]
        return display_list


@dataclasses.dataclass
class CohortMapping:
    user_profile_identifier: str
    cohort_list: str

    def get_display_list(self):
        display_list = json.loads(self.cohort_list)["cohort_list"]
        return display_list


@dataclasses.dataclass
class UID:
    user_profile_identifier: str


@dataclasses.dataclass
class QuestUserProfileEntity:
    user_profile_identifier: str
    account_type: str
    time_zone: str
    roundups_enabled: bool
    profile_status: str

    def get_dict(self, user_profile_id):
        return Dict.strip_null(
            {
                "user_profile_id": user_profile_id,
                "account_type": self.account_type,
                "time_zone": self.time_zone,
                "roundups_enabled": self.roundups_enabled,
                "profile_status": self.profile_status,
            }
        )
