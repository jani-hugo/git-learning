Feature: Schedule Map scenarios

  Background:
    Given The user UID1 provides a valid mobile number
      | mobile_number | ph_prefix |
      | random        | +65       |
    Then The user UID1 submits OTP to proceed with verification

    Given I open a new user account
      | user_profile_identifier | email          | legal_name  | name   | account_type |
      | UID1                    | test@gmail.com |  John Doe   | Johnny | PERSONAL     |

    When I initiate the initial onboarding for the user UID1

    Then I submit the initial onboarding for UID1

    And I check the status of initial onboarding for UID1

    When I initiate progress onboarding for the user UID1 to upgrade account to PREMIUM

    When I initiate HUGOSAVE_TRUST for the user UID1 and expect a status code of 200

    And I submit HUGOSAVE_TRUST for the user UID1 and expect a status code of 200

    Then I check status of HUGOSAVE_TRUST for the user UID1

    When I initiate HUGOSAVE_SELFIE_AND_SCAN_ID for the user UID1 and expect a status code of 200

    And I upload document FRONT for the user UID1

    And I upload document BACK for the user UID1

    And I upload document SELFIE for the user UID1

    Then I submit HUGOSAVE_SELFIE_AND_SCAN_ID for the user UID1 so we can convert the account to PREMIUM

    And I check the status of HUGOSAVE_SELFIE_AND_SCAN_ID for the user UID1

    Then I submit the progress onboarding for user UID1

    And I check progress onboarding status for the user UID1

    Then I upgrade the user UID1 account level to L3

    And I check the user details to confirm if user UID1 is premium

  Scenario: Create Schedule, Trigger Schedule

    Given I deposit 50 SGD into account subtype HUGO_CASH of user UID1

    And I check the balance of account subtype HUGO_CASH of user UID1 is 50 SGD exact

    Given I create a Map MPID1
      | user_profile_identifier | name   | asset_allocation_details                  | allocation_type | goal_date  | goal_amount |
      | UID1                    | Kerala | [{"asset_id": "CASH" ,"percentage": 100}] | FIXED           | 03-06-2024 | 100         |

    Then I check if the map MPID1 status is MAP_CREATED for user UID1

    Then I create a schedule for map MPID1 and expect status 200
      | user_profile_identifier | schedule_identifier | frequency | schedule_type       | target_weekdays | target_week | amount |
      | UID1                    | SID1                | DAILY     | SCHEDULE_MAP_INVEST |                 | 1           | 4.56   |

    Then I check if the schedule SID1 status 200 for user UID1

    Then I trigger schedule SID1 for user UID1

    And I check the balance of account subtype HUGO_CASH of user UID1 is 45.44 SGD approx

    Then I check the balance of map MPID1 of user UID1 to be 4.56 SGD

    Then I check intent type SCHEDULE_CASH_MAP_INVEST with status SETTLED and total 1 intents exist in map_intent_view,MPID1 view for user UID1

    Then I delete schedule SID1 for user UID1

    Then I check if the schedule SID1 status HSA_9108 for user UID1

    Given I create a Map MPID2
      | user_profile_identifier | name        | asset_allocation_details                  | allocation_type | goal_date  | goal_amount |
      | UID1                    | Itachi-Book | [{"asset_id": "CASH" ,"percentage": 100}] | FIXED           | 03-06-2024 | 100         |

    Then I check if the map MPID2 status is MAP_CREATED for user UID1

    Then I create a schedule for map MPID2 and expect status 200
      | user_profile_identifier | schedule_identifier | frequency | schedule_type       | target_weekdays | target_week | amount |
      | UID1                    | SID2                | WEEKLY    | SCHEDULE_MAP_INVEST |                 | 1           | 3.22   |

    Then I check if the schedule SID2 status 200 for user UID1

    Then I trigger schedule SID2 for user UID1

    And I check the balance of account subtype HUGO_CASH of user UID1 is 42.22 SGD approx

    Then I check the balance of map MPID2 of user UID1 to be 3.22 SGD

    Then I check intent type SCHEDULE_CASH_MAP_INVEST with status SETTLED and total 1 intents exist in map_intent_view,MPID2 view for user UID1

    Then I delete schedule SID2 for user UID1

    Then I check if the schedule SID2 status HSA_9108 for user UID1



