Feature: ETF Vault Feature

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

    Given I fetch list of questionnaire
    Given I check if questionnaire exists with name SUITABILITY_ASSESSMENT else create new questionnaire
    Given I create questionnaire UQID1 for user UID1 - questionnaire SUITABILITY_ASSESSMENT
    Then I request to get user questionnaire UQID1 for user UID1
    Then I request to update and verify user questionnaire answer UQID1 for user UID1 - questionnaire SUITABILITY_ASSESSMENT
    Then I request to submit user questionnaire UQID1 for user UID1

  Scenario Outline: Verify ETF vaults created for Premium Users
    And I check if <map_name> is created for user UID1

    Given I deposit 100 SGD into account subtype HUGO_CASH of user UID1

    And I check the balance of account subtype HUGO_CASH of user UID1 is 100 SGD exact

    # invest without rate token
    Given I invest in <map_type> vault map without rate
      | user_profile_identifier | transaction_amount | investment_amount | fee_amount | status_code |
      | UID1                    | 10                 | 10                | 0          | 200         |

#    Then I check the balance of <map_type> Map of user UID1 to be 10

    And I check the balance of account subtype HUGO_CASH of user UID1 is 90 SGD exact

    Given I invest in <map_type> vault map without rate
      | user_profile_identifier | transaction_amount | investment_amount | fee_amount | status_code |
      | UID1                    | 10                 | 10                | 0          | 200         |

    And I check the balance of account subtype HUGO_CASH of user UID1 is 80 SGD exact

    Examples:
      | map_type               | map_name           |
      | ETF_BALANCED_VAULT     | BALANCED_VAULT     |
      | ETF_GROWTH_VAULT       | GROWTH_VAULT       |
      | ETF_CAUTIOUS_VAULT     | CAUTIOUS_VAULT     |
      | ETF_MONEY_MARKET_VAULT | MONEY_MARKET_VAULT |


  Scenario Outline: Schedule scenario for etf maps
    And I check if <vault_name> is created for user UID1

    Given I deposit 20 SGD into account subtype HUGO_CASH of user UID1

    And I check the balance of account subtype HUGO_CASH of user UID1 is 20 SGD exact
#    invalid schedule data
    Then I create a schedule for map <asset_name> and expect status HSA_9130
      | user_profile_identifier | schedule_identifier | frequency | schedule_type       | target_weekdays | target_week | amount |
      | UID1                    | SID2                | DAILY     | SCHEDULE_MAP_INVEST |                 | 1           | 0.01   |

    Then I create a schedule for map <asset_name> and expect status HSA_9130
      | user_profile_identifier | schedule_identifier | frequency | schedule_type       | target_weekdays | target_week | amount |
      | UID1                    | SID3                | DAILY     | SCHEDULE_MAP_INVEST |                 | 1           | 0      |

    Then I create a schedule for map <asset_name> and expect status HSA_9125
      | user_profile_identifier | schedule_identifier | frequency | schedule_type    | target_weekdays | target_week | amount |
      | UID1                    | SID4                | DAILY     | someGarbageValue |                 | 1           | 0      |

    Then I create a schedule for map <asset_name> and expect status 200
      | user_profile_identifier | schedule_identifier | frequency | schedule_type       | target_weekdays | target_week | amount |
      | UID1                    | SID1                | DAILY     | SCHEDULE_MAP_INVEST |                 | 1           | 3.26   |

    Then I check if the schedule SID1 status 200 for user UID1
    Then I trigger schedule SID1 for user UID1

    And I check the balance of account subtype HUGO_CASH of user UID1 is 16.74 SGD exact

#    Then I check the balance of <asset_name> Map of user UID1 to be 3.26
#    Then I check intent type SCHEDULE_MAP_INVEST with status SETTLED and total 1 intents exist in map_intent_view,<asset_name> view for user UID1

    Then I update the schedule status of SID1 with action PAUSE for user UID1
    Then I check schedule status as SCHEDULE_STATUS_PAUSED for schedule SID1 for user UID1

    Then I trigger schedule SID1 for user UID1
    And I check the balance of account subtype HUGO_CASH of user UID1 is 16.74 SGD exact

#    Then I check the balance of <asset_name> Map of user UID1 to be 3.26
#    Then I check intent type SCHEDULE_MAP_INVEST with status SETTLED and total 1 intents exist in map_intent_view,<asset_name> view for user UID1

    Then I update the schedule status of SID1 with action RESUME for user UID1
    Then I check schedule status as SCHEDULE_STATUS_ACTIVE for schedule SID1 for user UID1
    Examples:
      | asset_name             | vault_name         |
      | ETF_BALANCED_VAULT     | BALANCED_VAULT     |
      | ETF_GROWTH_VAULT       | GROWTH_VAULT       |
      | ETF_CAUTIOUS_VAULT     | CAUTIOUS_VAULT     |
      | ETF_MONEY_MARKET_VAULT | MONEY_MARKET_VAULT |

