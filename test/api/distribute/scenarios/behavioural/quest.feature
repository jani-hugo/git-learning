Feature: Quest Progress Scenarios

  Background: Onboard User to Cognito
    Given I open user account
      | user_profile_identifier | phone_number | email           | legal_name    | status              |
      | UID1                    | random       | indra@gmail.com | Indra Karanam | PROFILE_IN_PROGRESS |
    Then I check account status
      | user_profile_identifier | status         |
      | UID1                    | PROFILE_ACTIVE |
    Then Verify Quest List Shown to User
      | user_profile_identifier | quest_list                                                                                                                             |
      | UID1                    | { "quest_list" : ["v2-lite-open-100", "va-progress-to-premium","v2-first-gold-buy-300","v2-activate-card-400","v2-gold-roundups-500"]} |
    Then Verify Cohort Mapping
      | user_profile_identifier | cohort_list                                                                                        |
      | UID1                    | { "cohort_list" : ["all-cohort", "behavioural-era-standard-cohort","behavioural-era-lite-cohort"]} |

  Scenario: User progress all the Quests Successfully
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id         | user_quest_stage |
      | UID1                    | v2-lite-open-100 | COMPLETED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id         | step_id                  | user_step_stage |
      | UID1                    | v2-lite-open-100 | v2-lite-open-s1-open-acc | COMPLETED       |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | ACTIVATED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | LOCKED          |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | LOCKED          |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type                  | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | TRUST_COMPLIANCE_SUCCESSFUL | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-27T09:11:23.100Z | true                | false         | false             |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | ACTIVATED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | LOCKED          |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type     | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | ACCT_KYC_START | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-28T09:11:23.100Z | true                | false         | false             |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | ACTIVATED       |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type        | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | ACCT_KYC_COMPLETE | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-29T09:12:23.100Z | true                | false         | false             |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | COMPLETED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | COMPLETED       |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type      | event_sub_type | event_source | generic_fields | event_ts                 | secure_fields                                                      | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | ACCT_LOAD_MONEY | random_event   | EVENT_MOBILE | {}             | 2025-04-28T09:12:23.100Z | { "meta_data" : [{ "event_key" : "amount", "float_value" : 50.0}]} | true                | false         | false             |
    Then Verify User Quest Progress
      | user_profile_identifier | quest_id              | user_quest_stage |
      | UID1                    | v2-first-gold-buy-300 | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id              | step_id                       | user_step_stage |
      | UID1                    | v2-first-gold-buy-300 | v2-first-gold-buy-s1-add50    | COMPLETED       |
      | UID1                    | v2-first-gold-buy-300 | v2-first-gold-buy-s2-buy-gold | ACTIVATED       |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type | event_sub_type | event_source | generic_fields                                                                  | secure_fields                                                      | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | MAP_INVEST | random_event   | EVENT_MOBILE | { "meta_data" : [{"event_key" : "map_type", "string_value" : "PM_GOLD_VAULT"}]} | { "meta_data" : [{ "event_key" : "amount", "float_value" : 50.0}]} | 2025-04-28T09:15:23.100Z | true                | false         | false             |
    Then Verify User Quest Progress
      | user_profile_identifier | quest_id              | user_quest_stage |
      | UID1                    | v2-first-gold-buy-300 | COMPLETED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id              | step_id                       | user_step_stage |
      | UID1                    | v2-first-gold-buy-300 | v2-first-gold-buy-s1-add50    | COMPLETED       |
      | UID1                    | v2-first-gold-buy-300 | v2-first-gold-buy-s2-buy-gold | COMPLETED       |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type  | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | CARD_ISSUED | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-29T09:15:23.100Z | true                | false         | false             |
    Then Verify User Quest Progress
      | user_profile_identifier | quest_id             | user_quest_stage |
      | UID1                    | v2-activate-card-400 | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id             | step_id                           | user_step_stage |
      | UID1                    | v2-activate-card-400 | v2-activate-card-s1-order-card    | COMPLETED       |
      | UID1                    | v2-activate-card-400 | v2-activate-card-s2-activate-card | ACTIVATED       |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type      | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | CARD_ACTIVATION | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-29T09:16:23.100Z | true                | false         | false             |
    Then Verify User Quest Progress
      | user_profile_identifier | quest_id             | user_quest_stage |
      | UID1                    | v2-activate-card-400 | COMPLETED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id             | step_id                           | user_step_stage |
      | UID1                    | v2-activate-card-400 | v2-activate-card-s1-order-card    | COMPLETED       |
      | UID1                    | v2-activate-card-400 | v2-activate-card-s2-activate-card | COMPLETED       |
    Then Change User State
      | user_profile_identifier | roundups_enabled |
      | UID1                    | true             |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type    | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | CARD_TXN_AUTH | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-29T09:17:23.100Z | true                | false         | false             |
    Then Verify User Quest Progress
      | user_profile_identifier | quest_id             | user_quest_stage |
      | UID1                    | v2-gold-roundups-500 | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id             | step_id                             | user_step_stage |
      | UID1                    | v2-gold-roundups-500 | v2-gold-roundups-s1-trigger-roundup | ACTIVATED       |
    Then Verify User Streak
      | user_profile_identifier | quest_id             | step_id                             | streak | streak_ts            |
      | UID1                    | v2-gold-roundups-500 | v2-gold-roundups-s1-trigger-roundup | 1      | 2025-04-29T09:17:23Z |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type    | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | CARD_TXN_AUTH | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-30T09:17:23.100Z | true                | false         | false             |
    Then Verify User Streak
      | user_profile_identifier | quest_id             | step_id                             | streak | streak_ts            |
      | UID1                    | v2-gold-roundups-500 | v2-gold-roundups-s1-trigger-roundup | 2      | 2025-04-30T09:17:23Z |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type    | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | CARD_TXN_AUTH | random_event   | EVENT_MOBILE | {}             | {}            | 2025-05-01T09:17:23.100Z | true                | false         | false             |
    Then Verify User Streak
      | user_profile_identifier | quest_id             | step_id                             | streak | streak_ts           |
      | UID1                    | v2-gold-roundups-500 | v2-gold-roundups-s1-trigger-roundup | 3      | 2025-05-01T09:17:23Z |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type    | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | CARD_TXN_AUTH | random_event   | EVENT_MOBILE | {}             | {}            | 2025-05-02T09:17:23.100Z | true                | false         | false             |
    Then Verify User Streak
      | user_profile_identifier | quest_id             | step_id                             | streak | streak_ts           |
      | UID1                    | v2-gold-roundups-500 | v2-gold-roundups-s1-trigger-roundup | 4      | 2025-05-02T09:17:23Z |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type    | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | CARD_TXN_AUTH | random_event   | EVENT_MOBILE | {}             | {}            | 2025-05-03T09:17:23.100Z | true                | false         | false             |
    Then Verify User Streak
      | user_profile_identifier | quest_id             | step_id                             | streak | streak_ts           |
      | UID1                    | v2-gold-roundups-500 | v2-gold-roundups-s1-trigger-roundup | 5      | 2025-05-03T09:17:23Z |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type    | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | CARD_TXN_AUTH | random_event   | EVENT_MOBILE | {}             | {}            | 2025-05-04T09:17:23.100Z | true                | false         | false             |
    Then Verify User Streak
      | user_profile_identifier | quest_id             | step_id                             | streak | streak_ts           |
      | UID1                    | v2-gold-roundups-500 | v2-gold-roundups-s1-trigger-roundup | 6      | 2025-05-04T09:17:23Z |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type    | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | CARD_TXN_AUTH | random_event   | EVENT_MOBILE | {}             | {}            | 2025-05-05T09:17:23.100Z | true                | false         | false             |
    Then Verify User Streak
      | user_profile_identifier | quest_id             | step_id                             | streak | streak_ts           |
      | UID1                    | v2-gold-roundups-500 | v2-gold-roundups-s1-trigger-roundup | 7      | 2025-05-05T09:17:23Z |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type    | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | CARD_TXN_AUTH | random_event   | EVENT_MOBILE | {}             | {}            | 2025-05-06T09:17:23.100Z | true                | false         | false             |
    Then Verify User Streak
      | user_profile_identifier | quest_id             | step_id                             | streak | streak_ts           |
      | UID1                    | v2-gold-roundups-500 | v2-gold-roundups-s1-trigger-roundup | 8      | 2025-05-06T09:17:23Z |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type    | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | CARD_TXN_AUTH | random_event   | EVENT_MOBILE | {}             | {}            | 2025-05-07T09:17:23.100Z | true                | false         | false             |
    Then Verify User Streak
      | user_profile_identifier | quest_id             | step_id                             | streak | streak_ts           |
      | UID1                    | v2-gold-roundups-500 | v2-gold-roundups-s1-trigger-roundup | 9      | 2025-05-07T09:17:23Z |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type    | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | CARD_TXN_AUTH | random_event   | EVENT_MOBILE | {}             | {}            | 2025-05-08T09:17:23.100Z | true                | false         | false             |
    Then Verify User Streak
      | user_profile_identifier | quest_id             | step_id                             | streak | streak_ts            |
      | UID1                    | v2-gold-roundups-500 | v2-gold-roundups-s1-trigger-roundup | 10     | 2025-05-08T09:17:23Z |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type    | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | CARD_TXN_AUTH | random_event   | EVENT_MOBILE | {}             | {}            | 2025-05-09T09:17:23.100Z | true                | false         | false             |
    Then Verify User Streak
      | user_profile_identifier | quest_id             | step_id                             | streak | streak_ts           |
      | UID1                    | v2-gold-roundups-500 | v2-gold-roundups-s1-trigger-roundup | 11     | 2025-05-09T09:17:23Z |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type    | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | CARD_TXN_AUTH | random_event   | EVENT_MOBILE | {}             | {}            | 2025-05-10T09:17:23.100Z | true                | false         | false             |
    Then Verify User Streak
      | user_profile_identifier | quest_id             | step_id                             | streak | streak_ts            |
      | UID1                    | v2-gold-roundups-500 | v2-gold-roundups-s1-trigger-roundup | 12     | 2025-05-10T09:17:23Z |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type    | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | CARD_TXN_AUTH | random_event   | EVENT_MOBILE | {}             | {}            | 2025-05-11T09:17:23.100Z | true                | false         | false             |
    Then Verify User Streak
      | user_profile_identifier | quest_id             | step_id                             | streak | streak_ts            |
      | UID1                    | v2-gold-roundups-500 | v2-gold-roundups-s1-trigger-roundup | 13     | 2025-05-11T09:17:23Z |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type    | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | CARD_TXN_AUTH | random_event   | EVENT_MOBILE | {}             | {}            | 2025-05-12T09:17:23.100Z | true                | false         | false             |
    Then Verify User Quest Progress
      | user_profile_identifier | quest_id             | user_quest_stage |
      | UID1                    | v2-gold-roundups-500 | COMPLETED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id             | step_id                             | user_step_stage |
      | UID1                    | v2-gold-roundups-500 | v2-gold-roundups-s1-trigger-roundup | COMPLETED       |
    Then Verify User Streak
      | user_profile_identifier | quest_id             | step_id                             | streak | streak_ts            |
      | UID1                    | v2-gold-roundups-500 | v2-gold-roundups-s1-trigger-roundup | 14     | 2025-05-12T09:17:23Z |

  Scenario: User Dont Turn On Round Ups so Streak Quest gets Paused
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id         | user_quest_stage |
      | UID1                    | v2-lite-open-100 | COMPLETED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id         | step_id                  | user_step_stage |
      | UID1                    | v2-lite-open-100 | v2-lite-open-s1-open-acc | COMPLETED       |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | ACTIVATED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | LOCKED          |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | LOCKED          |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type                  | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | TRUST_COMPLIANCE_SUCCESSFUL | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-27T09:11:23.100Z | true                | false         | false             |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | ACTIVATED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | LOCKED          |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type     | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | ACCT_KYC_START | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-28T09:11:23.100Z | true                | false         | false             |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | ACTIVATED       |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type        | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | ACCT_KYC_COMPLETE | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-29T09:12:23.100Z | true                | false         | false             |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | COMPLETED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | COMPLETED       |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type      | event_sub_type | event_source | generic_fields | event_ts                 | secure_fields                                                      | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | ACCT_LOAD_MONEY | random_event   | EVENT_MOBILE | {}             | 2025-04-28T09:12:23.100Z | { "meta_data" : [{ "event_key" : "amount", "float_value" : 50.0}]} | true                | false         | false             |
    Then Verify User Quest Progress
      | user_profile_identifier | quest_id              | user_quest_stage |
      | UID1                    | v2-first-gold-buy-300 | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id              | step_id                       | user_step_stage |
      | UID1                    | v2-first-gold-buy-300 | v2-first-gold-buy-s1-add50    | COMPLETED       |
      | UID1                    | v2-first-gold-buy-300 | v2-first-gold-buy-s2-buy-gold | ACTIVATED       |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type | event_sub_type | event_source | generic_fields                                                                  | secure_fields                                                      | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | MAP_INVEST | random_event   | EVENT_MOBILE | { "meta_data" : [{"event_key" : "map_type", "string_value" : "PM_GOLD_VAULT"}]} | { "meta_data" : [{ "event_key" : "amount", "float_value" : 50.0}]} | 2025-04-28T09:15:23.100Z | true                | false         | false             |
    Then Verify User Quest Progress
      | user_profile_identifier | quest_id              | user_quest_stage |
      | UID1                    | v2-first-gold-buy-300 | COMPLETED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id              | step_id                       | user_step_stage |
      | UID1                    | v2-first-gold-buy-300 | v2-first-gold-buy-s1-add50    | COMPLETED       |
      | UID1                    | v2-first-gold-buy-300 | v2-first-gold-buy-s2-buy-gold | COMPLETED       |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type  | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | CARD_ISSUED | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-29T09:15:23.100Z | true                | false         | false             |
    Then Verify User Quest Progress
      | user_profile_identifier | quest_id             | user_quest_stage |
      | UID1                    | v2-activate-card-400 | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id             | step_id                           | user_step_stage |
      | UID1                    | v2-activate-card-400 | v2-activate-card-s1-order-card    | COMPLETED       |
      | UID1                    | v2-activate-card-400 | v2-activate-card-s2-activate-card | ACTIVATED       |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type      | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | CARD_ACTIVATION | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-29T09:16:23.100Z | true                | false         | false             |
    Then Verify User Quest Progress
      | user_profile_identifier | quest_id             | user_quest_stage |
      | UID1                    | v2-activate-card-400 | COMPLETED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id             | step_id                           | user_step_stage |
      | UID1                    | v2-activate-card-400 | v2-activate-card-s1-order-card    | COMPLETED       |
      | UID1                    | v2-activate-card-400 | v2-activate-card-s2-activate-card | COMPLETED       |
    Then Change User State
      | user_profile_identifier | roundups_enabled |
      | UID1                    | false            |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type    | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | CARD_TXN_AUTH | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-29T09:17:23.100Z | true                | false         | false             |
    Then Verify User Quest Progress
      | user_profile_identifier | quest_id             | user_quest_stage |
      | UID1                    | v2-gold-roundups-500 | PAUSED           |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id             | step_id                             | user_step_stage |
      | UID1                    | v2-gold-roundups-500 | v2-gold-roundups-s1-trigger-roundup | PAUSED          |

  Scenario: User Don't Complete KYC and hence Cannot progress to PLUS
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id         | user_quest_stage |
      | UID1                    | v2-lite-open-100 | COMPLETED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id         | step_id                  | user_step_stage |
      | UID1                    | v2-lite-open-100 | v2-lite-open-s1-open-acc | COMPLETED       |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | ACTIVATED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | LOCKED          |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | LOCKED          |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type                  | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | TRUST_COMPLIANCE_SUCCESSFUL | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-27T09:11:23.100Z | true                | false         | false             |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | ACTIVATED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | LOCKED          |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type        | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | ACCT_KYC_COMPLETE | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-29T09:12:23.100Z | true                | false         | false             |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | ACTIVATED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | LOCKED          |

  Scenario: User Opens Lite account so dependent Quests gets Activated
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id         | user_quest_stage |
      | UID1                    | v2-lite-open-100 | COMPLETED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id         | step_id                  | user_step_stage |
      | UID1                    | v2-lite-open-100 | v2-lite-open-s1-open-acc | COMPLETED       |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | ACTIVATED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | LOCKED          |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | LOCKED          |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id              | step_id                       | user_step_stage |
      | UID1                    | v2-first-gold-buy-300 | v2-first-gold-buy-s1-add50    | ACTIVATED       |
      | UID1                    | v2-first-gold-buy-300 | v2-first-gold-buy-s2-buy-gold | LOCKED          |

  Scenario: User progress to Plus so dependent Quests gets activated Successfully
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id         | user_quest_stage |
      | UID1                    | v2-lite-open-100 | COMPLETED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id         | step_id                  | user_step_stage |
      | UID1                    | v2-lite-open-100 | v2-lite-open-s1-open-acc | COMPLETED       |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type     | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | ACCT_KYC_START | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-27T09:11:23.100Z | true                | false         | false             |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | ACTIVATED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | LOCKED          |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | LOCKED          |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type                  | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | TRUST_COMPLIANCE_SUCCESSFUL | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-27T09:11:23.100Z | true                | false         | false             |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | ACTIVATED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | LOCKED          |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type     | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | ACCT_KYC_START | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-28T09:11:23.100Z | true                | false         | false             |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | ACTIVATED       |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type        | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | ACCT_KYC_COMPLETE | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-29T09:12:23.100Z | true                | false         | false             |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | COMPLETED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | COMPLETED       |
    Then Verify User Quest Progress
      | user_profile_identifier | quest_id             | user_quest_stage |
      | UID1                    | v2-activate-card-400 | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id             | step_id                           | user_step_stage |
      | UID1                    | v2-activate-card-400 | v2-activate-card-s1-order-card    | ACTIVATED       |
      | UID1                    | v2-activate-card-400 | v2-activate-card-s2-activate-card | LOCKED          |

  Scenario: User Activates card so dependent Quests gets activated Successfully
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id         | user_quest_stage |
      | UID1                    | v2-lite-open-100 | COMPLETED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id         | step_id                  | user_step_stage |
      | UID1                    | v2-lite-open-100 | v2-lite-open-s1-open-acc | COMPLETED       |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | ACTIVATED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | LOCKED          |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | LOCKED          |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type                  | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | TRUST_COMPLIANCE_SUCCESSFUL | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-27T09:11:23.100Z | true                | false         | false             |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | ACTIVATED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | LOCKED          |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type     | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | ACCT_KYC_START | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-28T09:11:23.100Z | true                | false         | false             |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | ACTIVATED       |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type        | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | ACCT_KYC_COMPLETE | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-29T09:12:23.100Z | true                | false         | false             |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | COMPLETED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | COMPLETED       |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type  | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | CARD_ISSUED | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-29T09:15:23.100Z | true                | false         | false             |
    Then Verify User Quest Progress
      | user_profile_identifier | quest_id             | user_quest_stage |
      | UID1                    | v2-activate-card-400 | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id             | step_id                           | user_step_stage |
      | UID1                    | v2-activate-card-400 | v2-activate-card-s1-order-card    | COMPLETED       |
      | UID1                    | v2-activate-card-400 | v2-activate-card-s2-activate-card | ACTIVATED       |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type      | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | CARD_ACTIVATION | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-29T09:16:23.100Z | true                | false         | false             |
    Then Verify User Quest Progress
      | user_profile_identifier | quest_id             | user_quest_stage |
      | UID1                    | v2-activate-card-400 | COMPLETED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id             | step_id                           | user_step_stage |
      | UID1                    | v2-activate-card-400 | v2-activate-card-s1-order-card    | COMPLETED       |
      | UID1                    | v2-activate-card-400 | v2-activate-card-s2-activate-card | COMPLETED       |
    Then Change User State
      | user_profile_identifier | roundups_enabled |
      | UID1                    | true             |
    Then Verify User Quest Progress
      | user_profile_identifier | quest_id             | user_quest_stage |
      | UID1                    | v2-gold-roundups-500 | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id             | step_id                             | user_step_stage |
      | UID1                    | v2-gold-roundups-500 | v2-gold-roundups-s1-trigger-roundup | ACTIVATED       |

  Scenario: User Misses Streak so streak gets reset to 1
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id         | user_quest_stage |
      | UID1                    | v2-lite-open-100 | COMPLETED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id         | step_id                  | user_step_stage |
      | UID1                    | v2-lite-open-100 | v2-lite-open-s1-open-acc | COMPLETED       |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | ACTIVATED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | LOCKED          |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | LOCKED          |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type                  | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | TRUST_COMPLIANCE_SUCCESSFUL | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-27T09:11:23.100Z | true                | false         | false             |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | ACTIVATED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | LOCKED          |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type     | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | ACCT_KYC_START | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-28T09:11:23.100Z | true                | false         | false             |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | ACTIVATED       |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type        | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | ACCT_KYC_COMPLETE | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-29T09:12:23.100Z | true                | false         | false             |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | COMPLETED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | COMPLETED       |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type  | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | CARD_ISSUED | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-29T09:15:23.100Z | true                | false         | false             |
    Then Verify User Quest Progress
      | user_profile_identifier | quest_id             | user_quest_stage |
      | UID1                    | v2-activate-card-400 | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id             | step_id                           | user_step_stage |
      | UID1                    | v2-activate-card-400 | v2-activate-card-s1-order-card    | COMPLETED       |
      | UID1                    | v2-activate-card-400 | v2-activate-card-s2-activate-card | ACTIVATED       |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type      | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | CARD_ACTIVATION | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-29T09:16:23.100Z | true                | false         | false             |
    Then Verify User Quest Progress
      | user_profile_identifier | quest_id             | user_quest_stage |
      | UID1                    | v2-activate-card-400 | COMPLETED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id             | step_id                           | user_step_stage |
      | UID1                    | v2-activate-card-400 | v2-activate-card-s1-order-card    | COMPLETED       |
      | UID1                    | v2-activate-card-400 | v2-activate-card-s2-activate-card | COMPLETED       |
    Then Change User State
      | user_profile_identifier | roundups_enabled |
      | UID1                    | true             |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type    | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | CARD_TXN_AUTH | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-29T09:17:23.100Z | true                | false         | false             |
    Then Verify User Quest Progress
      | user_profile_identifier | quest_id             | user_quest_stage |
      | UID1                    | v2-gold-roundups-500 | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id             | step_id                             | user_step_stage |
      | UID1                    | v2-gold-roundups-500 | v2-gold-roundups-s1-trigger-roundup | ACTIVATED       |
    Then Verify User Streak
      | user_profile_identifier | quest_id             | step_id                             | streak | streak_ts           |
      | UID1                    | v2-gold-roundups-500 | v2-gold-roundups-s1-trigger-roundup | 1      | 2025-04-29T09:17:23Z |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type    | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | CARD_TXN_AUTH | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-30T09:17:23.100Z | true                | false         | false             |
    Then Verify User Streak
      | user_profile_identifier | quest_id             | step_id                             | streak | streak_ts            |
      | UID1                    | v2-gold-roundups-500 | v2-gold-roundups-s1-trigger-roundup | 2      | 2025-04-30T09:17:23Z |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type    | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | CARD_TXN_AUTH | random_event   | EVENT_MOBILE | {}             | {}            | 2025-05-02T09:17:23.100Z | true                | false         | false             |
    Then Verify User Streak
      | user_profile_identifier | quest_id             | step_id                             | streak | missed_streak | missed_reset_ts      | streak_ts            | is_streak_missed |
      | UID1                    | v2-gold-roundups-500 | v2-gold-roundups-s1-trigger-roundup | 1      | 2             | 2025-05-01T09:17:23Z | 2025-05-02T09:17:23Z | True             |

  Scenario: Double value support for Gold Buy and Add Money
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id         | user_quest_stage |
      | UID1                    | v2-lite-open-100 | COMPLETED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id         | step_id                  | user_step_stage |
      | UID1                    | v2-lite-open-100 | v2-lite-open-s1-open-acc | COMPLETED       |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | ACTIVATED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | LOCKED          |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | LOCKED          |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type                  | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | TRUST_COMPLIANCE_SUCCESSFUL | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-27T09:11:23.100Z | true                | false         | false             |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | ACTIVATED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | LOCKED          |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type     | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | ACCT_KYC_START | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-28T09:11:23.100Z | true                | false         | false             |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | ACTIVATED       |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type        | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | ACCT_KYC_COMPLETE | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-29T09:12:23.100Z | true                | false         | false             |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | COMPLETED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | COMPLETED       |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type      | event_sub_type | event_source | generic_fields | event_ts                 | secure_fields                                                       | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | ACCT_LOAD_MONEY | random_event   | EVENT_MOBILE | {}             | 2025-04-28T09:12:23.100Z | { "meta_data" : [{ "event_key" : "amount", "double_value" : 50.0}]} | true                | false         | false             |
    Then Verify User Quest Progress
      | user_profile_identifier | quest_id              | user_quest_stage |
      | UID1                    | v2-first-gold-buy-300 | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id              | step_id                       | user_step_stage |
      | UID1                    | v2-first-gold-buy-300 | v2-first-gold-buy-s1-add50    | COMPLETED       |
      | UID1                    | v2-first-gold-buy-300 | v2-first-gold-buy-s2-buy-gold | ACTIVATED       |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type | event_sub_type | event_source | generic_fields                                                                  | secure_fields                                                       | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | MAP_INVEST | random_event   | EVENT_MOBILE | { "meta_data" : [{"event_key" : "map_type", "string_value" : "PM_GOLD_VAULT"}]} | { "meta_data" : [{ "event_key" : "amount", "double_value" : 50.0}]} | 2025-04-28T09:15:23.100Z | true                | false         | false             |
    Then Verify User Quest Progress
      | user_profile_identifier | quest_id              | user_quest_stage |
      | UID1                    | v2-first-gold-buy-300 | COMPLETED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id              | step_id                       | user_step_stage |
      | UID1                    | v2-first-gold-buy-300 | v2-first-gold-buy-s1-add50    | COMPLETED       |
      | UID1                    | v2-first-gold-buy-300 | v2-first-gold-buy-s2-buy-gold | COMPLETED       |

  Scenario: If Value is less than 50, Gold Quest Wont Progress
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id         | user_quest_stage |
      | UID1                    | v2-lite-open-100 | COMPLETED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id         | step_id                  | user_step_stage |
      | UID1                    | v2-lite-open-100 | v2-lite-open-s1-open-acc | COMPLETED       |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | ACTIVATED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | LOCKED          |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | LOCKED          |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type                  | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | TRUST_COMPLIANCE_SUCCESSFUL | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-27T09:11:23.100Z | true                | false         | false             |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | ACTIVATED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | LOCKED          |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type     | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | ACCT_KYC_START | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-28T09:11:23.100Z | true                | false         | false             |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | ACTIVATED       |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type        | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | ACCT_KYC_COMPLETE | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-29T09:12:23.100Z | true                | false         | false             |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | COMPLETED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | COMPLETED       |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type      | event_sub_type | event_source | generic_fields | event_ts                 | secure_fields                                                       | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | ACCT_LOAD_MONEY | random_event   | EVENT_MOBILE | {}             | 2025-04-28T09:12:23.100Z | { "meta_data" : [{ "event_key" : "amount", "double_value" : 51.0}]} | true                | false         | false             |
    Then Verify User Quest Progress
      | user_profile_identifier | quest_id              | user_quest_stage |
      | UID1                    | v2-first-gold-buy-300 | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id              | step_id                       | user_step_stage |
      | UID1                    | v2-first-gold-buy-300 | v2-first-gold-buy-s1-add50    | COMPLETED       |
      | UID1                    | v2-first-gold-buy-300 | v2-first-gold-buy-s2-buy-gold | ACTIVATED       |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type | event_sub_type | event_source | generic_fields                                                                  | secure_fields                                                       | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | MAP_INVEST | random_event   | EVENT_MOBILE | { "meta_data" : [{"event_key" : "map_type", "string_value" : "PM_GOLD_VAULT"}]} | { "meta_data" : [{ "event_key" : "amount", "double_value" : 49.0}]} | 2025-04-28T09:15:23.100Z | true                | false         | false             |
    Then Verify User Quest Progress
      | user_profile_identifier | quest_id              | user_quest_stage |
      | UID1                    | v2-first-gold-buy-300 | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id              | step_id                       | user_step_stage |
      | UID1                    | v2-first-gold-buy-300 | v2-first-gold-buy-s1-add50    | COMPLETED       |
      | UID1                    | v2-first-gold-buy-300 | v2-first-gold-buy-s2-buy-gold | ACTIVATED       |

  Scenario: User Claim the Reward after Opening Lite Account
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id         | user_quest_stage |
      | UID1                    | v2-lite-open-100 | COMPLETED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id         | step_id                  | user_step_stage |
      | UID1                    | v2-lite-open-100 | v2-lite-open-s1-open-acc | COMPLETED       |
    Then Claim User Reward
      | user_profile_identifier | quest_id         |
      | UID1                    | v2-lite-open-100 |
    Then Verify User Quest Progress
      | user_profile_identifier | quest_id         | user_quest_stage |
      | UID1                    | v2-lite-open-100 | REWARDED         |


  Scenario: User Missed the Streak Twice
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id         | user_quest_stage |
      | UID1                    | v2-lite-open-100 | COMPLETED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id         | step_id                  | user_step_stage |
      | UID1                    | v2-lite-open-100 | v2-lite-open-s1-open-acc | COMPLETED       |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | ACTIVATED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | LOCKED          |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | LOCKED          |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type                  | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | TRUST_COMPLIANCE_SUCCESSFUL | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-27T09:11:23.100Z | true                | false         | false             |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | ACTIVATED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | LOCKED          |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type     | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | ACCT_KYC_START | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-28T09:11:23.100Z | true                | false         | false             |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | ACTIVATED       |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type        | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | ACCT_KYC_COMPLETE | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-29T09:12:23.100Z | true                | false         | false             |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | COMPLETED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | COMPLETED       |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type  | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | CARD_ISSUED | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-29T09:15:23.100Z | true                | false         | false             |
    Then Verify User Quest Progress
      | user_profile_identifier | quest_id             | user_quest_stage |
      | UID1                    | v2-activate-card-400 | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id             | step_id                           | user_step_stage |
      | UID1                    | v2-activate-card-400 | v2-activate-card-s1-order-card    | COMPLETED       |
      | UID1                    | v2-activate-card-400 | v2-activate-card-s2-activate-card | ACTIVATED       |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type      | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | CARD_ACTIVATION | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-29T09:16:23.100Z | true                | false         | false             |
    Then Verify User Quest Progress
      | user_profile_identifier | quest_id             | user_quest_stage |
      | UID1                    | v2-activate-card-400 | COMPLETED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id             | step_id                           | user_step_stage |
      | UID1                    | v2-activate-card-400 | v2-activate-card-s1-order-card    | COMPLETED       |
      | UID1                    | v2-activate-card-400 | v2-activate-card-s2-activate-card | COMPLETED       |
    Then Change User State
      | user_profile_identifier | roundups_enabled |
      | UID1                    | true             |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type    | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | CARD_TXN_AUTH | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-29T09:17:23.100Z | true                | false         | false             |
    Then Verify User Streak
      | user_profile_identifier | quest_id             | step_id                             | streak | streak_ts            |
      | UID1                    | v2-gold-roundups-500 | v2-gold-roundups-s1-trigger-roundup | 1      | 2025-04-29T09:17:23Z |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type    | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | CARD_TXN_AUTH | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-30T09:17:23.100Z | true                | false         | false             |
    Then Verify User Streak
      | user_profile_identifier | quest_id             | step_id                             | streak | streak_ts            |
      | UID1                    | v2-gold-roundups-500 | v2-gold-roundups-s1-trigger-roundup | 2      | 2025-04-30T09:17:23Z |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type    | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | CARD_TXN_AUTH | random_event   | EVENT_MOBILE | {}             | {}            | 2025-05-02T09:17:23.100Z | true                | false         | false             |
    Then Verify User Streak
      | user_profile_identifier | quest_id             | step_id                             | streak | missed_streak | missed_reset_ts      | streak_ts            | is_streak_missed |
      | UID1                    | v2-gold-roundups-500 | v2-gold-roundups-s1-trigger-roundup | 1      | 2             | 2025-05-01T09:17:23Z | 2025-05-02T09:17:23Z | True             |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type    | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | CARD_TXN_AUTH | random_event   | EVENT_MOBILE | {}             | {}            | 2025-05-03T09:17:23.100Z | true                | false         | false             |
    Then Verify User Streak
      | user_profile_identifier | quest_id             | step_id                             | streak | missed_streak | missed_reset_ts      | streak_ts            | is_streak_missed |
      | UID1                    | v2-gold-roundups-500 | v2-gold-roundups-s1-trigger-roundup | 2      | 2             | 2025-05-01T09:17:23Z | 2025-05-03T09:17:23Z | True             |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type    | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | CARD_TXN_AUTH | random_event   | EVENT_MOBILE | {}             | {}            | 2025-05-04T09:17:23.100Z | true                | false         | false             |
    Then Verify User Streak
      | user_profile_identifier | quest_id             | step_id                             | streak | missed_streak | missed_reset_ts      | streak_ts            | is_streak_missed |
      | UID1                    | v2-gold-roundups-500 | v2-gold-roundups-s1-trigger-roundup | 3      | 2             | 2025-05-01T09:17:23Z | 2025-05-04T09:17:23Z | True             |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type    | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | CARD_TXN_AUTH | random_event   | EVENT_MOBILE | {}             | {}            | 2025-05-06T09:17:23.100Z | true                | false         | false             |
    Then Verify User Streak
      | user_profile_identifier | quest_id             | step_id                             | streak | missed_streak | missed_reset_ts      | streak_ts            | is_streak_missed |
      | UID1                    | v2-gold-roundups-500 | v2-gold-roundups-s1-trigger-roundup | 1      | 3             | 2025-05-05T09:17:23Z | 2025-05-06T09:17:23Z | True             |

  Scenario: User UID1 gives Referral to user UID2 and user UID2 opens account and progress to PLUS
    Given I open user account
      | user_profile_identifier | phone_number | email           | name  | last_name | status              | legal_name    |
      | UID2                    | random       | indra@gmail.com | Indra | Karanam   | PROFILE_IN_PROGRESS | Indra Karanam |
    Then I check account status
      | user_profile_identifier | status         |
      | UID2                    | PROFILE_ACTIVE |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type         | event_sub_type | event_source  | generic_fields                                                          | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  | is_referral_event | referred_user_identifier | acct_type |
      | 1  | UID1                    | ACCT_USER_REFERRED | random_event   | EVENT_BACKEND | { "meta_data" : [{"event_key" : "acct_type", "string_value" : "LITE"}]} | {}            | 2025-04-28T09:15:23.100Z | true                | false         | false             | True              | UID2                     | LITE      |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id         | user_quest_stage |
      | UID1                    | v2-lite-open-100 | COMPLETED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id         | step_id                  | user_step_stage |
      | UID1                    | v2-lite-open-100 | v2-lite-open-s1-open-acc | COMPLETED       |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id         | user_quest_stage |
      | UID2                    | v2-lite-open-100 | COMPLETED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id         | step_id                  | user_step_stage |
      | UID2                    | v2-lite-open-100 | v2-lite-open-s1-open-acc | COMPLETED       |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID2                    | va-progress-to-premium | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID2                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | ACTIVATED       |
      | UID2                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | LOCKED          |
      | UID2                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | LOCKED          |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type                  | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID2                    | TRUST_COMPLIANCE_SUCCESSFUL | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-27T09:11:23.100Z | true                | false         | false            |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID2                    | va-progress-to-premium | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID2                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | COMPLETED       |
      | UID2                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | ACTIVATED       |
      | UID2                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | LOCKED          |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type     | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID2                    | ACCT_KYC_START | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-28T09:11:23.100Z | true                | false         | false             |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID2                    | va-progress-to-premium | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID2                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | COMPLETED       |
      | UID2                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | COMPLETED       |
      | UID2                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | ACTIVATED       |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type        | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID2                    | ACCT_KYC_COMPLETE | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-29T09:12:23.100Z | true                | false         | false             |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID2                    | va-progress-to-premium | COMPLETED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID2                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | COMPLETED       |
      | UID2                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | COMPLETED       |
      | UID2                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | COMPLETED       |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type         | event_sub_type | event_source  | generic_fields                                                          | secure_fields | event_ts                  | push_to_behavioural | push_to_braze | push_to_mixpanel  | is_referral_event | referred_user_identifier | acct_type |
      | 1  | UID1                    | ACCT_USER_REFERRED | random_event   | EVENT_BACKEND | { "meta_data" : [{"event_key" : "acct_type", "string_value" : "PLUS"}]} | {}            | 2025-04-300T10:15:23.100Z | true                | false         | false             | True              | UID2                     | PLUS      |
    Given Verify User Quest Referral Progress
      | user_profile_identifier | quest_id        | user_quest_stage |
      | UID1                    | invite-plus-102 | COMPLETED        |

  Scenario: Create and Successfully Progress Cumulative Quest
    Given Create New Quest
      | user_profile_identifier | quest_id                          | quest_name                      | cohort_id                              | depends_on_quest_id               | sequence | required_user_state  | steps                                                                                                                                                                                                                                                                                                                                                                      |
      | UID1                    | v2-gold-roundups-cumulate-500     | Invest-as-you-Spend Challenge   | pre-behavioural-era-standard-cohort    | {"id": ["v2-activate-card-400"]}  | 500      | ROUNDUPS_ACTIVE      | [{"step_id":"v2-gold-roundups-s1","step_name":"Transaction","quest_id":"v2-gold-roundups-cumulate-500","sequence":1,"step_event":"CARD_TRANSACTION_SUCCESS","step_detail":{"cumulative_step":{"step_event":{"event_type":"CARD_TRANSACTION_SUCCESS"},"total_value":{"key":"amount","operator":"GREATER_THAN_EQUALS","int_value":200},"completion_duration_hours":72000}}}] |
    Given Add cohort pre-behavioural-era-standard-cohort to User UID1
    Then Verify Cohort Mapping
      | user_profile_identifier | cohort_list                                                                                        |
      | UID1                    | { "cohort_list" : ["all-cohort", "behavioural-era-standard-cohort","behavioural-era-lite-cohort", "pre-behavioural-era-standard-cohort"]} |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id         | user_quest_stage |
      | UID1                    | v2-lite-open-100 | COMPLETED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id         | step_id                  | user_step_stage |
      | UID1                    | v2-lite-open-100 | v2-lite-open-s1-open-acc | COMPLETED       |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | ACTIVATED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | LOCKED          |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | LOCKED          |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type                  | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | TRUST_COMPLIANCE_SUCCESSFUL | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-27T09:11:23.100Z | true                | false         | false             |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | ACTIVATED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | LOCKED          |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type     | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | ACCT_KYC_START | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-28T09:11:23.100Z | true                | false         | false             |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | ACTIVATED       |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type        | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | ACCT_KYC_COMPLETE | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-29T09:12:23.100Z | true                | false         | false             |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | COMPLETED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | COMPLETED       |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type  | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | CARD_ISSUED | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-29T09:15:23.100Z | true                | false         | false             |
    Then Verify User Quest Progress
      | user_profile_identifier | quest_id             | user_quest_stage |
      | UID1                    | v2-activate-card-400 | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id             | step_id                           | user_step_stage |
      | UID1                    | v2-activate-card-400 | v2-activate-card-s1-order-card    | COMPLETED       |
      | UID1                    | v2-activate-card-400 | v2-activate-card-s2-activate-card | ACTIVATED       |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type      | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | CARD_ACTIVATION | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-29T09:16:23.100Z | true                | false         | false             |
    Then Verify User Quest Progress
      | user_profile_identifier | quest_id             | user_quest_stage |
      | UID1                    | v2-activate-card-400 | COMPLETED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id             | step_id                           | user_step_stage |
      | UID1                    | v2-activate-card-400 | v2-activate-card-s1-order-card    | COMPLETED       |
      | UID1                    | v2-activate-card-400 | v2-activate-card-s2-activate-card | COMPLETED       |
    Then Change User State
      | user_profile_identifier | roundups_enabled |
      | UID1                    | true             |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type    | event_sub_type | event_source | generic_fields | secure_fields                                            | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | CARD_TXN_AUTH | random_event   | EVENT_MOBILE | {}             | {"meta_data":[{"event_key":"amount","int_value":20}]}  | 2025-04-30T09:17:23.100Z | true                | false         | false             |
    Then Verify User Quest Progress
      | user_profile_identifier | quest_id                      | user_quest_stage |
      | UID1                    | v2-gold-roundups-cumulate-500 | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id                      | step_id                | user_step_stage |
      | UID1                    | v2-gold-roundups-cumulate-500 | v2-gold-roundups-s1    | ACTIVATED       |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type    | event_sub_type | event_source | generic_fields | secure_fields                                            | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | CARD_TXN_AUTH | random_event   | EVENT_MOBILE | {}             | {"meta_data":[{"event_key":"amount","int_value":20}]}  | 2025-04-30T09:17:24.100Z | true                | false         | false             |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id                      | step_id                | user_step_stage |
      | UID1                    | v2-gold-roundups-cumulate-500 | v2-gold-roundups-s1    | ACTIVATED       |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type    | event_sub_type | event_source | generic_fields | secure_fields                                             | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | CARD_TXN_AUTH | random_event   | EVENT_MOBILE | {}             | {"meta_data":[{"event_key":"amount","int_value":180}]}  | 2025-04-30T09:17:25.100Z | true                | false         | false             |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id                      | step_id                | user_step_stage |
      | UID1                    | v2-gold-roundups-cumulate-500 | v2-gold-roundups-s1    | COMPLETED       |
    Then Verify User Quest Progress
      | user_profile_identifier | quest_id                      | user_quest_stage |
      | UID1                    | v2-gold-roundups-cumulate-500 | COMPLETED        |

  Scenario: Create and Successfully Progress Repeater Cumulative Quest
    Given Create New Quest
      | user_profile_identifier | quest_id                 | quest_name                      | cohort_id                              | depends_on_quest_id               | sequence | required_user_state  | steps                                                                                                                                                                                                                                                                                                                                                                                                                                              |
      | UID1                    | v2-gold-roundups-rep-500 | Invest-as-you-Spend Challenge   | pre-behavioural-era-standard-cohort    | {"id": ["v2-activate-card-400"]}  | 500      | ROUNDUPS_ACTIVE      | [{"step_id":"v2-gold-roundups-rep-s1","step_name":"Transaction","quest_id":"v2-gold-roundups-rep-500","sequence":1,"step_event":"CARD_TRANSACTION_SUCCESS","step_detail":{"repeater_cumulative_step":{"step_event":{"event_type":"CARD_TRANSACTION_SUCCESS"},"total_value":{"key":"amount","operator":"GREATER_THAN_EQUALS","float_value":50},"frequency":"ONCE_A_DAY","repeatable_count":3,"gaps_allowed":true,"reset_when_gaps_allowed":true}}}] |
    Given Add cohort pre-behavioural-era-standard-cohort to User UID1
    Then Verify Cohort Mapping
      | user_profile_identifier | cohort_list                                                                                                                               |
      | UID1                    | { "cohort_list" : ["all-cohort", "behavioural-era-standard-cohort","behavioural-era-lite-cohort", "pre-behavioural-era-standard-cohort"]} |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id         | user_quest_stage |
      | UID1                    | v2-lite-open-100 | COMPLETED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id         | step_id                  | user_step_stage |
      | UID1                    | v2-lite-open-100 | v2-lite-open-s1-open-acc | COMPLETED       |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | ACTIVATED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | LOCKED          |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | LOCKED          |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type                  | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | TRUST_COMPLIANCE_SUCCESSFUL | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-27T09:11:23.100Z | true                | false         | false             |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | ACTIVATED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | LOCKED          |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type     | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | ACCT_KYC_START | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-28T09:11:23.100Z | true                | false         | false             |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | ACTIVATED       |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type        | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | ACCT_KYC_COMPLETE | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-29T09:12:23.100Z | true                | false         | false             |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | COMPLETED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | COMPLETED       |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type  | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | CARD_ISSUED | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-29T09:15:23.100Z | true                | false         | false             |
    Then Verify User Quest Progress
      | user_profile_identifier | quest_id             | user_quest_stage |
      | UID1                    | v2-activate-card-400 | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id             | step_id                           | user_step_stage |
      | UID1                    | v2-activate-card-400 | v2-activate-card-s1-order-card    | COMPLETED       |
      | UID1                    | v2-activate-card-400 | v2-activate-card-s2-activate-card | ACTIVATED       |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type      | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | CARD_ACTIVATION | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-29T09:16:23.100Z | true                | false         | false             |
    Then Verify User Quest Progress
      | user_profile_identifier | quest_id             | user_quest_stage |
      | UID1                    | v2-activate-card-400 | COMPLETED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id             | step_id                           | user_step_stage |
      | UID1                    | v2-activate-card-400 | v2-activate-card-s1-order-card    | COMPLETED       |
      | UID1                    | v2-activate-card-400 | v2-activate-card-s2-activate-card | COMPLETED       |
    Then Change User State
      | user_profile_identifier | roundups_enabled |
      | UID1                    | true             |
    Then Verify User Quest Progress
      | user_profile_identifier | quest_id                 | user_quest_stage |
      | UID1                    | v2-gold-roundups-rep-500 | ACTIVATED        |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type    | event_sub_type | event_source | generic_fields | secure_fields                                            | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | CARD_TXN_AUTH | random_event   | EVENT_MOBILE | {}             | {"meta_data":[{"event_key":"amount","float_value":20}]}  | 2025-05-25T09:17:23.100Z | true                | false         | false             |
    Then Verify User Streak
      | user_profile_identifier | quest_id                 | step_id                 | streak | streak_ts            |
      | UID1                    | v2-gold-roundups-rep-500 | v2-gold-roundups-rep-s1 | 0      | 2025-05-25T09:17:23Z |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type    | event_sub_type | event_source | generic_fields | secure_fields                                             | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | CARD_TXN_AUTH | random_event   | EVENT_MOBILE | {}             | {"meta_data":[{"event_key":"amount","float_value":30}]}   | 2025-05-25T09:17:23.100Z | true                | false         | false             |
    Then Verify User Streak
      | user_profile_identifier | quest_id                 | step_id                 | streak | streak_ts            |
      | UID1                    | v2-gold-roundups-rep-500 | v2-gold-roundups-rep-s1 | 1      | 2025-05-25T09:17:23Z |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type    | event_sub_type | event_source | generic_fields | secure_fields                                             | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | CARD_TXN_AUTH | random_event   | EVENT_MOBILE | {}             | {"meta_data":[{"event_key":"amount","float_value":50}]}   | 2025-05-26T09:17:23.100Z | true                | false         | false             |
    Then Verify User Streak
      | user_profile_identifier | quest_id                 | step_id                 | streak | streak_ts            |
      | UID1                    | v2-gold-roundups-rep-500 | v2-gold-roundups-rep-s1 | 2      | 2025-05-26T09:17:23Z |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id                 | step_id                    | user_step_stage |
      | UID1                    | v2-gold-roundups-rep-500 | v2-gold-roundups-rep-s1    | ACTIVATED       |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type    | event_sub_type | event_source | generic_fields | secure_fields                                             | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | CARD_TXN_AUTH | random_event   | EVENT_MOBILE | {}             | {"meta_data":[{"event_key":"amount","float_value":50}]}   | 2025-05-27T09:17:23.100Z | true                | false         | false             |
    Then Verify User Streak
      | user_profile_identifier | quest_id                 | step_id                 | streak | streak_ts            |
      | UID1                    | v2-gold-roundups-rep-500 | v2-gold-roundups-rep-s1 | 3      | 2025-05-27T09:17:23Z |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id                 | step_id                    | user_step_stage |
      | UID1                    | v2-gold-roundups-rep-500 | v2-gold-roundups-rep-s1    | COMPLETED       |
    Then Verify User Quest Progress
      | user_profile_identifier | quest_id                 | user_quest_stage |
      | UID1                    | v2-gold-roundups-rep-500 | COMPLETED        |

  Scenario: User Miss Streak for Repeater Cumulative Quest
    Given Create New Quest
      | user_profile_identifier | quest_id                 | quest_name                      | cohort_id                              | depends_on_quest_id               | sequence | required_user_state  | steps                                                                                                                                                                                                                                                                                                                                                                                                                                              |
      | UID1                    | v2-gold-roundups-rep-500 | Invest-as-you-Spend Challenge   | pre-behavioural-era-standard-cohort    | {"id": ["v2-activate-card-400"]}  | 500      | ROUNDUPS_ACTIVE      | [{"step_id":"v2-gold-roundups-rep-s1","step_name":"Transaction","quest_id":"v2-gold-roundups-rep-500","sequence":1,"step_event":"CARD_TRANSACTION_SUCCESS","step_detail":{"repeater_cumulative_step":{"step_event":{"event_type":"CARD_TRANSACTION_SUCCESS"},"total_value":{"key":"amount","operator":"GREATER_THAN_EQUALS","float_value":50},"frequency":"ONCE_A_DAY","repeatable_count":3,"gaps_allowed":true,"reset_when_gaps_allowed":true}}}] |
    Given Add cohort pre-behavioural-era-standard-cohort to User UID1
    Then Verify Cohort Mapping
      | user_profile_identifier | cohort_list                                                                                                                               |
      | UID1                    | { "cohort_list" : ["all-cohort", "behavioural-era-standard-cohort","behavioural-era-lite-cohort", "pre-behavioural-era-standard-cohort"]} |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id         | user_quest_stage |
      | UID1                    | v2-lite-open-100 | COMPLETED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id         | step_id                  | user_step_stage |
      | UID1                    | v2-lite-open-100 | v2-lite-open-s1-open-acc | COMPLETED       |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | ACTIVATED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | LOCKED          |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | LOCKED          |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type                  | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | TRUST_COMPLIANCE_SUCCESSFUL | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-27T09:11:23.100Z | true                | false         | false             |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | ACTIVATED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | LOCKED          |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type     | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | ACCT_KYC_START | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-28T09:11:23.100Z | true                | false         | false             |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | ACTIVATED       |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type        | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | ACCT_KYC_COMPLETE | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-29T09:12:23.100Z | true                | false         | false             |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | COMPLETED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | COMPLETED       |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type  | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | CARD_ISSUED | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-29T09:15:23.100Z | true                | false         | false             |
    Then Verify User Quest Progress
      | user_profile_identifier | quest_id             | user_quest_stage |
      | UID1                    | v2-activate-card-400 | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id             | step_id                           | user_step_stage |
      | UID1                    | v2-activate-card-400 | v2-activate-card-s1-order-card    | COMPLETED       |
      | UID1                    | v2-activate-card-400 | v2-activate-card-s2-activate-card | ACTIVATED       |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type      | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | CARD_ACTIVATION | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-29T09:16:23.100Z | true                | false         | false             |
    Then Verify User Quest Progress
      | user_profile_identifier | quest_id             | user_quest_stage |
      | UID1                    | v2-activate-card-400 | COMPLETED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id             | step_id                           | user_step_stage |
      | UID1                    | v2-activate-card-400 | v2-activate-card-s1-order-card    | COMPLETED       |
      | UID1                    | v2-activate-card-400 | v2-activate-card-s2-activate-card | COMPLETED       |
    Then Change User State
      | user_profile_identifier | roundups_enabled |
      | UID1                    | true             |
    Then Verify User Quest Progress
      | user_profile_identifier | quest_id                 | user_quest_stage |
      | UID1                    | v2-gold-roundups-rep-500 | ACTIVATED        |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type    | event_sub_type | event_source | generic_fields | secure_fields                                                     | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | CARD_TXN_AUTH | random_event   | EVENT_MOBILE | {}             | {"meta_data" : [{ "event_key" : "amount", "float_value" : 50.0}]} | 2025-06-20T09:17:23.100Z | true                | false         | false             |
    Then Verify User Streak
      | user_profile_identifier | quest_id                 | step_id                 | streak | streak_ts           |
      | UID1                    | v2-gold-roundups-rep-500 | v2-gold-roundups-rep-s1 | 1      | 2025-06-20T09:17:23Z |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type    | event_sub_type | event_source | generic_fields | secure_fields                                                     | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | CARD_TXN_AUTH | random_event   | EVENT_MOBILE | {}             | {"meta_data" : [{ "event_key" : "amount", "float_value" : 50.0}]} | 2025-06-21T09:17:23.100Z | true                | false         | false             |
    Then Verify User Streak
      | user_profile_identifier | quest_id                 | step_id                 | streak | streak_ts            |
      | UID1                    | v2-gold-roundups-rep-500 | v2-gold-roundups-rep-s1 | 2      | 2025-06-21T09:17:23Z |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type    | event_sub_type | event_source | generic_fields | secure_fields                                                     | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | CARD_TXN_AUTH | random_event   | EVENT_MOBILE | {}             | {"meta_data" : [{ "event_key" : "amount", "float_value" : 50.0}]} | 2025-06-24T09:17:23.100Z | true                | false         | false             |
    Then Verify User Streak
      | user_profile_identifier | quest_id                 | step_id                 | streak | missed_streak | missed_reset_ts      | streak_ts            | is_streak_missed |
      | UID1                    | v2-gold-roundups-rep-500 | v2-gold-roundups-rep-s1 | 1      | 2             | 2025-06-21T09:17:23Z | 2025-06-24T09:17:23Z | True             |

  Scenario: Special Quests with Activation Details
    Given Create New Quest
      | user_profile_identifier | quest_id             | quest_name         | cohort_id                              | depends_on_quest_id                | sequence | steps                                                                                                                                                                                                                                              | activation_details               |
      | UID1                    | v2-second-gold-buy   | Gold Buy Challenge | pre-behavioural-era-standard-cohort    | {"id": ["v2-first-gold-buy-300"]}  | 250      | [{"step_id":"v2-second-buy-gold-s1","step_name":"Gold","quest_id":"v2-second-gold-buy","sequence":1,"step_event":"GOLD_PURCHASED","step_detail":{"single_step":{"step_event":{"event_type":"GOLD_PURCHASED"},"completion_duration_hours":72000}}}] | {"activation_allowed_count": 2}  |
    Given User UID1 reset Stats for the quest v2-second-gold-buy
    Given Add cohort pre-behavioural-era-standard-cohort to User UID1
    Then Verify Cohort Mapping
      | user_profile_identifier | cohort_list                                                                                                                               |
      | UID1                    | { "cohort_list" : ["all-cohort", "behavioural-era-standard-cohort","behavioural-era-lite-cohort", "pre-behavioural-era-standard-cohort"]} |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id         | user_quest_stage |
      | UID1                    | v2-lite-open-100 | COMPLETED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id         | step_id                  | user_step_stage |
      | UID1                    | v2-lite-open-100 | v2-lite-open-s1-open-acc | COMPLETED       |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type      | event_sub_type | event_source | generic_fields | event_ts                 | secure_fields                                                      | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | ACCT_LOAD_MONEY | random_event   | EVENT_MOBILE | {}             | 2025-04-28T09:12:23.100Z | { "meta_data" : [{ "event_key" : "amount", "float_value" : 50.0}]} | true                | false         | false             |
    Then Verify User Quest Progress
      | user_profile_identifier | quest_id              | user_quest_stage |
      | UID1                    | v2-first-gold-buy-300 | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id              | step_id                       | user_step_stage |
      | UID1                    | v2-first-gold-buy-300 | v2-first-gold-buy-s1-add50    | COMPLETED       |
      | UID1                    | v2-first-gold-buy-300 | v2-first-gold-buy-s2-buy-gold | ACTIVATED       |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type | event_sub_type | event_source | generic_fields                                                                  | secure_fields                                                      | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID1                    | MAP_INVEST | random_event   | EVENT_MOBILE | { "meta_data" : [{"event_key" : "map_type", "string_value" : "PM_GOLD_VAULT"}]} | { "meta_data" : [{ "event_key" : "amount", "float_value" : 50.0}]} | 2025-04-28T09:15:23.100Z | true                | false         | false             |
    Then Verify User Quest Progress
      | user_profile_identifier | quest_id              | user_quest_stage |
      | UID1                    | v2-second-gold-buy    | ACTIVATED        |
    Given I open user account
      | user_profile_identifier | phone_number | email           | legal_name    | status              |
      | UID2                    | random       | indra@gmail.com | Indra Karanam | PROFILE_IN_PROGRESS |
    Then I check account status
      | user_profile_identifier | status         |
      | UID2                    | PROFILE_ACTIVE |
    Given Add cohort pre-behavioural-era-standard-cohort to User UID2
    Then Verify Cohort Mapping
      | user_profile_identifier | cohort_list                                                                                                                               |
      | UID2                    | { "cohort_list" : ["all-cohort", "behavioural-era-standard-cohort","behavioural-era-lite-cohort", "pre-behavioural-era-standard-cohort"]} |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id         | user_quest_stage |
      | UID2                    | v2-lite-open-100 | COMPLETED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id         | step_id                  | user_step_stage |
      | UID2                    | v2-lite-open-100 | v2-lite-open-s1-open-acc | COMPLETED       |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type      | event_sub_type | event_source | generic_fields | event_ts                 | secure_fields                                                      | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID2                    | ACCT_LOAD_MONEY | random_event   | EVENT_MOBILE | {}             | 2025-04-28T09:12:23.100Z | { "meta_data" : [{ "event_key" : "amount", "float_value" : 50.0}]} | true                | false         | false             |
    Then Verify User Quest Progress
      | user_profile_identifier | quest_id              | user_quest_stage |
      | UID2                    | v2-first-gold-buy-300 | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id              | step_id                       | user_step_stage |
      | UID2                    | v2-first-gold-buy-300 | v2-first-gold-buy-s1-add50    | COMPLETED       |
      | UID2                    | v2-first-gold-buy-300 | v2-first-gold-buy-s2-buy-gold | ACTIVATED       |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type | event_sub_type | event_source | generic_fields                                                                  | secure_fields                                                      | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID2                    | MAP_INVEST | random_event   | EVENT_MOBILE | { "meta_data" : [{"event_key" : "map_type", "string_value" : "PM_GOLD_VAULT"}]} | { "meta_data" : [{ "event_key" : "amount", "float_value" : 50.0}]} | 2025-04-28T09:15:23.100Z | true                | false         | false             |
    Then Verify User Quest Progress
      | user_profile_identifier | quest_id              | user_quest_stage |
      | UID2                    | v2-second-gold-buy    | ACTIVATED        |
    Given I open user account
      | user_profile_identifier | phone_number | email           | legal_name    | status              |
      | UID3                    | random       | indra@gmail.com | Indra Karanam | PROFILE_IN_PROGRESS |
    Then I check account status
      | user_profile_identifier | status         |
      | UID3                    | PROFILE_ACTIVE |
    Given Add cohort pre-behavioural-era-standard-cohort to User UID3
    Then Verify Cohort Mapping
      | user_profile_identifier | cohort_list                                                                                                                               |
      | UID3                    | { "cohort_list" : ["all-cohort", "behavioural-era-standard-cohort","behavioural-era-lite-cohort", "pre-behavioural-era-standard-cohort"]} |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id         | user_quest_stage |
      | UID3                    | v2-lite-open-100 | COMPLETED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id         | step_id                  | user_step_stage |
      | UID3                    | v2-lite-open-100 | v2-lite-open-s1-open-acc | COMPLETED       |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type      | event_sub_type | event_source | generic_fields | event_ts                 | secure_fields                                                      | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID3                    | ACCT_LOAD_MONEY | random_event   | EVENT_MOBILE | {}             | 2025-04-28T09:12:23.100Z | { "meta_data" : [{ "event_key" : "amount", "float_value" : 50.0}]} | true                | false         | false             |
    Then Verify User Quest Progress
      | user_profile_identifier | quest_id              | user_quest_stage |
      | UID3                    | v2-first-gold-buy-300 | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id              | step_id                       | user_step_stage |
      | UID3                    | v2-first-gold-buy-300 | v2-first-gold-buy-s1-add50    | COMPLETED       |
      | UID3                    | v2-first-gold-buy-300 | v2-first-gold-buy-s2-buy-gold | ACTIVATED       |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type | event_sub_type | event_source | generic_fields                                                                  | secure_fields                                                      | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel  |
      | 1  | UID3                    | MAP_INVEST | random_event   | EVENT_MOBILE | { "meta_data" : [{"event_key" : "map_type", "string_value" : "PM_GOLD_VAULT"}]} | { "meta_data" : [{ "event_key" : "amount", "float_value" : 50.0}]} | 2025-04-28T09:15:23.100Z | true                | false         | false             |
    Then Verify User Quest Progress
      | user_profile_identifier | quest_id              | user_quest_stage |
      | UID3                    | v2-second-gold-buy    | BLOCKED          |
