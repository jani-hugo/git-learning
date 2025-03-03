Feature: Schedule Map scenarios

  Background:
    Given I open user account
      | user_profile_identifier | phone_number | email          | legal_name | status              |
      | UID1                    | random       | test@gmail.com | John Doe   | PROFILE_IN_PROGRESS |

    Then I check account status
      | user_profile_identifier | status         |
      | UID1                    | PROFILE_ACTIVE |

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

    Given I create a Map MPID2
      | user_profile_identifier | name        | asset_allocation_details                  | allocation_type | goal_date  | goal_amount |
      | UID1                    | Itachi-Book | [{"asset_id": "CASH" ,"percentage": 100}] | FIXED           | 03-06-2024 | 100         |

    Then I check if the map MPID2 status is MAP_CREATED for user UID1

    Given I create a Map MPID3
      | user_profile_identifier | name  | asset_allocation_details                  | allocation_type | goal_date  | goal_amount |
      | UID1                    | Shoes | [{"asset_id": "CASH" ,"percentage": 100}] | FIXED           | 03-06-2024 | 100         |

    Then I check if the map MPID3 status is MAP_CREATED for user UID1

    Then I create a schedule for map MPID2 and expect status 200
      | user_profile_identifier | schedule_identifier | frequency | schedule_type       | target_weekdays | target_week | amount |
      | UID1                    | SID2                | WEEKLY    | SCHEDULE_MAP_INVEST |                 | 1           | 3.22   |

    Then I check if the schedule SID2 status 200 for user UID1

    Then I create a schedule for map MPID3 and expect status 200
      | user_profile_identifier | schedule_identifier | frequency | schedule_type       | target_weekdays | target_week | amount |
      | UID1                    | SID3                | MONTHLY   | SCHEDULE_MAP_INVEST |                 | 1           | 9.87   |

    Then I check if the schedule SID3 status 200 for user UID1

    Then I trigger schedule SID1 for user UID1
    Then I trigger schedule SID2 for user UID1
    Then I trigger schedule SID3 for user UID1

    And I check the balance of account subtype HUGO_CASH of user UID1 is 32.35 SGD exact

    Then I check the balance of map MPID1 of user UID1 to be 4.56 SGD
    Then I check the balance of map MPID2 of user UID1 to be 3.22 SGD
    Then I check the balance of map MPID3 of user UID1 to be 9.87 SGD

    Then I check intent type SCHEDULE_CASH_MAP_INVEST with status SETTLED and total 3 intents exist in map_intent_view,MPID1 view for user UID1

    Then I delete schedule SID1 for user UID1

    Then I check if the schedule SID1 status HSA_9108 for user UID1

#    to-do 1. update schedule 2. schedule for silver and platinum