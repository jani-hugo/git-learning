Feature: Daily Task Scheduler Features

  Background: Onboard User to Cognito
    Given I open user account
      | user_profile_identifier | phone_number | email           | legal_name    | status              |
      | UID1                    | random       | indra@gmail.com | Indra Karanam | PROFILE_IN_PROGRESS |
    Then I check account status
      | user_profile_identifier | status         |
      | UID1                    | PROFILE_ACTIVE |

  Scenario: User opens account and complete KYC
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id         | user_quest_stage |
      | UID1                    | v2-lite-open-100 | COMPLETED        |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | ACTIVATED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | LOCKED          |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | LOCKED          |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type                  | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel |
      | 1  | UID1                    | TRUST_COMPLIANCE_SUCCESSFUL | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-27T09:11:23.100Z | true                | false         | false            |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | ACTIVATED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | LOCKED          |
    Then Verify valid until timestamp
      | user_profile_identifier | quest_id               | valid_until_ts       |
      | UID1                    | va-progress-to-premium | 2038-01-01T00:00:00Z |

  Scenario: User opens account and progress to Plus
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id         | user_quest_stage |
      | UID1                    | v2-lite-open-100 | COMPLETED        |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | ACTIVATED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | LOCKED          |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | LOCKED          |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type                  | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel |
      | 1  | UID1                    | TRUST_COMPLIANCE_SUCCESSFUL | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-27T09:11:23.100Z | true                | false         | false            |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | ACTIVATED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | LOCKED          |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type     | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel |
      | 1  | UID1                    | ACCT_KYC_START | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-28T09:11:23.100Z | true                | false         | false            |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | ACTIVATED       |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type        | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel |
      | 1  | UID1                    | ACCT_KYC_COMPLETE | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-29T09:12:23.100Z | true                | false         | false            |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | COMPLETED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | COMPLETED       |
    Then Verify valid until timestamp
      | user_profile_identifier | quest_id               | valid_until_ts       |
      | UID1                    | va-progress-to-premium | 2038-01-01T00:00:00Z |

  Scenario: User opens account and Makes 1st card transaction
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id         | user_quest_stage |
      | UID1                    | v2-lite-open-100 | COMPLETED        |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | ACTIVATED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | LOCKED          |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | LOCKED          |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type                  | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel |
      | 1  | UID1                    | TRUST_COMPLIANCE_SUCCESSFUL | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-27T09:11:23.100Z | true                | false         | false            |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | ACTIVATED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | LOCKED          |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type     | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel |
      | 1  | UID1                    | ACCT_KYC_START | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-28T09:11:23.100Z | true                | false         | false            |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | ACTIVATED       |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type        | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel |
      | 1  | UID1                    | ACCT_KYC_COMPLETE | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-29T09:12:23.100Z | true                | false         | false            |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | COMPLETED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | COMPLETED       |
    Then Verify valid until timestamp
      | user_profile_identifier | quest_id               | valid_until_ts       |
      | UID1                    | va-progress-to-premium | 2038-01-01T00:00:00Z |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type  | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel |
      | 1  | UID1                    | CARD_ISSUED | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-30T09:15:23.100Z | true                | true          | true             |
    Then Verify User Quest Progress
      | user_profile_identifier | quest_id             | user_quest_stage |
      | UID1                    | v2-activate-card-400 | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id             | step_id                           | user_step_stage |
      | UID1                    | v2-activate-card-400 | v2-activate-card-s1-order-card    | COMPLETED       |
      | UID1                    | v2-activate-card-400 | v2-activate-card-s2-activate-card | ACTIVATED       |
    Then Verify valid until timestamp
      | user_profile_identifier | quest_id             | valid_until_ts       |
      | UID1                    | v2-activate-card-400 | 2038-01-01T00:00:00Z |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type      | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel |
      | 1  | UID1                    | CARD_ACTIVATION | random_event   | EVENT_MOBILE | {}             | {}            | 2025-05-01T09:16:23.100Z | true                | true          | true             |
    Then Verify User Quest Progress
      | user_profile_identifier | quest_id             | user_quest_stage |
      | UID1                    | v2-activate-card-400 | COMPLETED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id             | step_id                           | user_step_stage |
      | UID1                    | v2-activate-card-400 | v2-activate-card-s1-order-card    | COMPLETED       |
      | UID1                    | v2-activate-card-400 | v2-activate-card-s2-activate-card | COMPLETED       |
    Then Verify valid until timestamp
      | user_profile_identifier | quest_id             | valid_until_ts       |
      | UID1                    | v2-activate-card-400 | 2038-01-01T00:00:00Z |
    Then Change User State
      | user_profile_identifier | roundups_enabled |
      | UID1                    | true             |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type    | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel |
      | 1  | UID1                    | CARD_TXN_AUTH | random_event   | EVENT_MOBILE | {}             | {}            | 2025-05-02T09:17:23.100Z | true                | true          | true             |
    Then Verify User Quest Progress
      | user_profile_identifier | quest_id             | user_quest_stage |
      | UID1                    | v2-gold-roundups-500 | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id             | step_id                             | user_step_stage |
      | UID1                    | v2-gold-roundups-500 | v2-gold-roundups-s1-trigger-roundup | ACTIVATED       |
    Then Verify valid until timestamp
      | user_profile_identifier | quest_id             | valid_until_ts       |
      | UID1                    | v2-gold-roundups-500 | 2025-05-03T16:00:00Z |

  Scenario: User opens account and misses streak but still valid until remains same
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id         | user_quest_stage |
      | UID1                    | v2-lite-open-100 | COMPLETED        |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | ACTIVATED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | LOCKED          |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | LOCKED          |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type                  | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel |
      | 1  | UID1                    | TRUST_COMPLIANCE_SUCCESSFUL | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-27T09:11:23.100Z | true                | false         | false            |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | ACTIVATED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | LOCKED          |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type     | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel |
      | 1  | UID1                    | ACCT_KYC_START | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-28T09:11:23.100Z | true                | false         | false            |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | ACTIVATED       |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type        | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel |
      | 1  | UID1                    | ACCT_KYC_COMPLETE | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-29T09:12:23.100Z | true                | false         | false            |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | COMPLETED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | COMPLETED       |
    Then Verify valid until timestamp
      | user_profile_identifier | quest_id               | valid_until_ts       |
      | UID1                    | va-progress-to-premium | 2038-01-01T00:00:00Z |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type  | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel |
      | 1  | UID1                    | CARD_ISSUED | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-30T09:15:23.100Z | true                | true          | true             |
    Then Verify User Quest Progress
      | user_profile_identifier | quest_id             | user_quest_stage |
      | UID1                    | v2-activate-card-400 | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id             | step_id                           | user_step_stage |
      | UID1                    | v2-activate-card-400 | v2-activate-card-s1-order-card    | COMPLETED       |
      | UID1                    | v2-activate-card-400 | v2-activate-card-s2-activate-card | ACTIVATED       |
    Then Verify valid until timestamp
      | user_profile_identifier | quest_id             | valid_until_ts       |
      | UID1                    | v2-activate-card-400 | 2038-01-01T00:00:00Z |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type      | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel |
      | 1  | UID1                    | CARD_ACTIVATION | random_event   | EVENT_MOBILE | {}             | {}            | 2025-05-01T09:16:23.100Z | true                | true          | true             |
    Then Verify User Quest Progress
      | user_profile_identifier | quest_id             | user_quest_stage |
      | UID1                    | v2-activate-card-400 | COMPLETED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id             | step_id                           | user_step_stage |
      | UID1                    | v2-activate-card-400 | v2-activate-card-s1-order-card    | COMPLETED       |
      | UID1                    | v2-activate-card-400 | v2-activate-card-s2-activate-card | COMPLETED       |
    Then Verify valid until timestamp
      | user_profile_identifier | quest_id             | valid_until_ts       |
      | UID1                    | v2-activate-card-400 | 2038-01-01T00:00:00Z |
    Then Change User State
      | user_profile_identifier | roundups_enabled |
      | UID1                    | true             |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type    | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel |
      | 1  | UID1                    | CARD_TXN_AUTH | random_event   | EVENT_MOBILE | {}             | {}            | 2025-05-02T09:17:23.100Z | true                | true          | true             |
    Then Verify User Quest Progress
      | user_profile_identifier | quest_id             | user_quest_stage |
      | UID1                    | v2-gold-roundups-500 | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id             | step_id                             | user_step_stage |
      | UID1                    | v2-gold-roundups-500 | v2-gold-roundups-s1-trigger-roundup | ACTIVATED       |
    Then Verify valid until timestamp
      | user_profile_identifier | quest_id             | valid_until_ts       |
      | UID1                    | v2-gold-roundups-500 | 2025-05-03T16:00:00Z |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type    | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel |
      | 1  | UID1                    | CARD_TXN_AUTH | random_event   | EVENT_MOBILE | {}             | {}            | 2025-05-04T09:17:23.100Z | true                | true          | true             |
    Then Verify User Quest Progress
      | user_profile_identifier | quest_id             | user_quest_stage |
      | UID1                    | v2-gold-roundups-500 | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id             | step_id                             | user_step_stage |
      | UID1                    | v2-gold-roundups-500 | v2-gold-roundups-s1-trigger-roundup | ACTIVATED       |
    Then Verify valid until timestamp
      | user_profile_identifier | quest_id             | valid_until_ts       |
      | UID1                    | v2-gold-roundups-500 | 2025-05-03T16:00:00Z |

  Scenario: User completes 14 days streak and valid until gets updated to max
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id         | user_quest_stage |
      | UID1                    | v2-lite-open-100 | COMPLETED        |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | ACTIVATED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | LOCKED          |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | LOCKED          |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type                  | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel |
      | 1  | UID1                    | TRUST_COMPLIANCE_SUCCESSFUL | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-27T09:11:23.100Z | true                | false         | false            |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | ACTIVATED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | LOCKED          |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type     | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel |
      | 1  | UID1                    | ACCT_KYC_START | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-28T09:11:23.100Z | true                | false         | false            |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | ACTIVATED       |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type        | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel |
      | 1  | UID1                    | ACCT_KYC_COMPLETE | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-29T09:12:23.100Z | true                | false         | false            |
    Given Verify User Quest Progress
      | user_profile_identifier | quest_id               | user_quest_stage |
      | UID1                    | va-progress-to-premium | COMPLETED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id               | step_id                                    | user_step_stage |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s1-accept-trust     | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s2-upload-documents | COMPLETED       |
      | UID1                    | va-progress-to-premium | va-progress-to-premium-s3-progress-to-plus | COMPLETED       |
    Then Verify valid until timestamp
      | user_profile_identifier | quest_id               | valid_until_ts       |
      | UID1                    | va-progress-to-premium | 2038-01-01T00:00:00Z |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type  | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel |
      | 1  | UID1                    | CARD_ISSUED | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-29T09:15:23.100Z | true                | true          | true             |
    Then Verify User Quest Progress
      | user_profile_identifier | quest_id             | user_quest_stage |
      | UID1                    | v2-activate-card-400 | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id             | step_id                           | user_step_stage |
      | UID1                    | v2-activate-card-400 | v2-activate-card-s1-order-card    | COMPLETED       |
      | UID1                    | v2-activate-card-400 | v2-activate-card-s2-activate-card | ACTIVATED       |
    Then Verify valid until timestamp
      | user_profile_identifier | quest_id             | valid_until_ts       |
      | UID1                    | v2-activate-card-400 | 2038-01-01T00:00:00Z |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type      | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel |
      | 1  | UID1                    | CARD_ACTIVATION | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-29T09:16:23.100Z | true                | true          | true             |
    Then Verify User Quest Progress
      | user_profile_identifier | quest_id             | user_quest_stage |
      | UID1                    | v2-activate-card-400 | COMPLETED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id             | step_id                           | user_step_stage |
      | UID1                    | v2-activate-card-400 | v2-activate-card-s1-order-card    | COMPLETED       |
      | UID1                    | v2-activate-card-400 | v2-activate-card-s2-activate-card | COMPLETED       |
    Then Verify valid until timestamp
      | user_profile_identifier | quest_id             | valid_until_ts       |
      | UID1                    | v2-activate-card-400 | 2038-01-01T00:00:00Z |
    Then Change User State
      | user_profile_identifier | roundups_enabled |
      | UID1                    | true             |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type    | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel |
      | 1  | UID1                    | CARD_TXN_AUTH | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-29T09:17:23.100Z | true                | true          | true             |
    Then Verify User Quest Progress
      | user_profile_identifier | quest_id             | user_quest_stage |
      | UID1                    | v2-gold-roundups-500 | ACTIVATED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id             | step_id                             | user_step_stage |
      | UID1                    | v2-gold-roundups-500 | v2-gold-roundups-s1-trigger-roundup | ACTIVATED       |
    Then Verify User Streak
      | user_profile_identifier | quest_id             | step_id                             | streak | streak_ts            |
      | UID1                    | v2-gold-roundups-500 | v2-gold-roundups-s1-trigger-roundup | 1      | 2025-04-29T09:17:23Z |
    Then Verify valid until timestamp
      | user_profile_identifier | quest_id             | valid_until_ts       |
      | UID1                    | v2-gold-roundups-500 | 2025-04-30T16:00:00Z |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type    | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel |
      | 1  | UID1                    | CARD_TXN_AUTH | random_event   | EVENT_MOBILE | {}             | {}            | 2025-04-30T09:17:23.100Z | true                | true          | true             |
    Then Verify User Streak
      | user_profile_identifier | quest_id             | step_id                             | streak | streak_ts            |
      | UID1                    | v2-gold-roundups-500 | v2-gold-roundups-s1-trigger-roundup | 2      | 2025-04-30T09:17:23Z |
    Then Verify valid until timestamp
      | user_profile_identifier | quest_id             | valid_until_ts       |
      | UID1                    | v2-gold-roundups-500 | 2025-04-30T16:00:00Z |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type    | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel |
      | 1  | UID1                    | CARD_TXN_AUTH | random_event   | EVENT_MOBILE | {}             | {}            | 2025-05-01T09:17:23.100Z | true                | true          | true             |
    Then Verify User Streak
      | user_profile_identifier | quest_id             | step_id                             | streak | streak_ts            |
      | UID1                    | v2-gold-roundups-500 | v2-gold-roundups-s1-trigger-roundup | 3      | 2025-05-01T09:17:23Z |
    Then Verify valid until timestamp
      | user_profile_identifier | quest_id             | valid_until_ts       |
      | UID1                    | v2-gold-roundups-500 | 2025-04-30T16:00:00Z |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type    | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel |
      | 1  | UID1                    | CARD_TXN_AUTH | random_event   | EVENT_MOBILE | {}             | {}            | 2025-05-02T09:17:23.100Z | true                | true          | true             |
    Then Verify User Streak
      | user_profile_identifier | quest_id             | step_id                             | streak | streak_ts            |
      | UID1                    | v2-gold-roundups-500 | v2-gold-roundups-s1-trigger-roundup | 4      | 2025-05-02T09:17:23Z |
    Then Verify valid until timestamp
      | user_profile_identifier | quest_id             | valid_until_ts       |
      | UID1                    | v2-gold-roundups-500 | 2025-04-30T16:00:00Z |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type    | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel |
      | 1  | UID1                    | CARD_TXN_AUTH | random_event   | EVENT_MOBILE | {}             | {}            | 2025-05-03T09:17:23.100Z | true                | true          | true             |
    Then Verify User Streak
      | user_profile_identifier | quest_id             | step_id                             | streak | streak_ts            |
      | UID1                    | v2-gold-roundups-500 | v2-gold-roundups-s1-trigger-roundup | 5      | 2025-05-03T09:17:23Z |
    Then Verify valid until timestamp
      | user_profile_identifier | quest_id             | valid_until_ts       |
      | UID1                    | v2-gold-roundups-500 | 2025-04-30T16:00:00Z |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type    | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel |
      | 1  | UID1                    | CARD_TXN_AUTH | random_event   | EVENT_MOBILE | {}             | {}            | 2025-05-04T09:17:23.100Z | true                | true          | true             |
    Then Verify User Streak
      | user_profile_identifier | quest_id             | step_id                             | streak | streak_ts            |
      | UID1                    | v2-gold-roundups-500 | v2-gold-roundups-s1-trigger-roundup | 6      | 2025-05-04T09:17:23Z |
    Then Verify valid until timestamp
      | user_profile_identifier | quest_id             | valid_until_ts       |
      | UID1                    | v2-gold-roundups-500 | 2025-04-30T16:00:00Z |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type    | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel |
      | 1  | UID1                    | CARD_TXN_AUTH | random_event   | EVENT_MOBILE | {}             | {}            | 2025-05-05T09:17:23.100Z | true                | true          | true             |
    Then Verify User Streak
      | user_profile_identifier | quest_id             | step_id                             | streak | streak_ts            |
      | UID1                    | v2-gold-roundups-500 | v2-gold-roundups-s1-trigger-roundup | 7      | 2025-05-05T09:17:23Z |
    Then Verify valid until timestamp
      | user_profile_identifier | quest_id             | valid_until_ts       |
      | UID1                    | v2-gold-roundups-500 | 2025-04-30T16:00:00Z |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type    | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel |
      | 1  | UID1                    | CARD_TXN_AUTH | random_event   | EVENT_MOBILE | {}             | {}            | 2025-05-06T09:17:23.100Z | true                | true          | true             |
    Then Verify User Streak
      | user_profile_identifier | quest_id             | step_id                             | streak | streak_ts            |
      | UID1                    | v2-gold-roundups-500 | v2-gold-roundups-s1-trigger-roundup | 8      | 2025-05-06T09:17:23Z |
    Then Verify valid until timestamp
      | user_profile_identifier | quest_id             | valid_until_ts       |
      | UID1                    | v2-gold-roundups-500 | 2025-04-30T16:00:00Z |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type    | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel |
      | 1  | UID1                    | CARD_TXN_AUTH | random_event   | EVENT_MOBILE | {}             | {}            | 2025-05-07T09:17:23.100Z | true                | true          | true             |
    Then Verify User Streak
      | user_profile_identifier | quest_id             | step_id                             | streak | streak_ts            |
      | UID1                    | v2-gold-roundups-500 | v2-gold-roundups-s1-trigger-roundup | 9      | 2025-05-07T09:17:23Z |
    Then Verify valid until timestamp
      | user_profile_identifier | quest_id             | valid_until_ts       |
      | UID1                    | v2-gold-roundups-500 | 2025-04-30T16:00:00Z |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type    | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel |
      | 1  | UID1                    | CARD_TXN_AUTH | random_event   | EVENT_MOBILE | {}             | {}            | 2025-05-08T09:17:23.100Z | true                | true          | true             |
    Then Verify User Streak
      | user_profile_identifier | quest_id             | step_id                             | streak | streak_ts            |
      | UID1                    | v2-gold-roundups-500 | v2-gold-roundups-s1-trigger-roundup | 10     | 2025-05-08T09:17:23Z |
    Then Verify valid until timestamp
      | user_profile_identifier | quest_id             | valid_until_ts       |
      | UID1                    | v2-gold-roundups-500 | 2025-04-30T16:00:00Z |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type    | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel |
      | 1  | UID1                    | CARD_TXN_AUTH | random_event   | EVENT_MOBILE | {}             | {}            | 2025-05-09T09:17:23.100Z | true                | true          | true             |
    Then Verify User Streak
      | user_profile_identifier | quest_id             | step_id                             | streak | streak_ts            |
      | UID1                    | v2-gold-roundups-500 | v2-gold-roundups-s1-trigger-roundup | 11     | 2025-05-09T09:17:23Z |
    Then Verify valid until timestamp
      | user_profile_identifier | quest_id             | valid_until_ts       |
      | UID1                    | v2-gold-roundups-500 | 2025-04-30T16:00:00Z |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type    | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel |
      | 1  | UID1                    | CARD_TXN_AUTH | random_event   | EVENT_MOBILE | {}             | {}            | 2025-05-10T09:17:23.100Z | true                | true          | true             |
    Then Verify User Streak
      | user_profile_identifier | quest_id             | step_id                             | streak | streak_ts            |
      | UID1                    | v2-gold-roundups-500 | v2-gold-roundups-s1-trigger-roundup | 12     | 2025-05-10T09:17:23Z |
    Then Verify valid until timestamp
      | user_profile_identifier | quest_id             | valid_until_ts       |
      | UID1                    | v2-gold-roundups-500 | 2025-04-30T16:00:00Z |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type    | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel |
      | 1  | UID1                    | CARD_TXN_AUTH | random_event   | EVENT_MOBILE | {}             | {}            | 2025-05-11T09:17:23.100Z | true                | true          | true             |
    Then Verify User Streak
      | user_profile_identifier | quest_id             | step_id                             | streak | streak_ts            |
      | UID1                    | v2-gold-roundups-500 | v2-gold-roundups-s1-trigger-roundup | 13     | 2025-05-11T09:17:23Z |
    Then Verify valid until timestamp
      | user_profile_identifier | quest_id             | valid_until_ts       |
      | UID1                    | v2-gold-roundups-500 | 2025-04-30T16:00:00Z |
    Then Push Event to Queue
      | id | user_profile_identifier | event_type    | event_sub_type | event_source | generic_fields | secure_fields | event_ts                 | push_to_behavioural | push_to_braze | push_to_mixpanel |
      | 1  | UID1                    | CARD_TXN_AUTH | random_event   | EVENT_MOBILE | {}             | {}            | 2025-05-12T09:17:23.100Z | true                | true          | true             |
    Then Verify User Quest Progress
      | user_profile_identifier | quest_id             | user_quest_stage |
      | UID1                    | v2-gold-roundups-500 | COMPLETED        |
    Then Verify User Step Progress
      | user_profile_identifier | quest_id             | step_id                             | user_step_stage |
      | UID1                    | v2-gold-roundups-500 | v2-gold-roundups-s1-trigger-roundup | COMPLETED       |
    Then Verify User Streak
      | user_profile_identifier | quest_id             | step_id                             | streak | streak_ts            |
      | UID1                    | v2-gold-roundups-500 | v2-gold-roundups-s1-trigger-roundup | 14     | 2025-05-12T09:17:23Z |
    Then Verify valid until timestamp
      | user_profile_identifier | quest_id             | valid_until_ts       |
      | UID1                    | v2-gold-roundups-500 | 2038-01-01T00:00:00Z |