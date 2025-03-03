Feature: ETF Vault Feature

  Background: Open Hugosave Premium account
    Given I open user account
      | user_profile_identifier | phone_number | email          | legal_name | name   | status              | prefix_ph_num |
      | UID1                    | random       | test@gmail.com | John Doe   | Johnny | PROFILE_IN_PROGRESS | +3731         |

    Then I check account status
      | user_profile_identifier | status         |
      | UID1                    | PROFILE_ACTIVE |

    Then I update first_name,last_name,dob,nationality,address,document_number,document_expiry_date,tax_id_number of user UID1 and check if updated correctly

    Then I initiate STANDARD_COMPLIANCE for user UID1 with content type as image/png and expect status 200

    Then I upload document SELFIE using presigned URL for user UID1 and expect status 200
    Then I upload document FRONT using presigned URL for user UID1 and expect status 200
    Then I upload document BACK using presigned URL for user UID1 and expect status 200

    Then I submit NRIC document for STANDARD_COMPLIANCE for user UID1

    Then I initiate TRUST_COMPLIANCE for user UID1 with content type as  and expect status 200
    Then I submit  document for TRUST_COMPLIANCE for user UID1

    Then I update STANDARD_COMPLIANCE status of UID1 as pass
    Then I check if user UID1 account type is PREMIUM

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


  Scenario Outline: Roundup to ETF vaults
    And I check if <map_name> is created for user UID1

    Given I deposit 1.82 SGD into account subtype HUGO_ROUNDUP of user UID1

    And I check the balance of account subtype HUGO_ROUNDUP of user UID1 is 1.82 SGD exact

    Given I update Roundup Sweep vault to <map_type> for user UID1

    Then I trigger schedule SCHEDULE_ROUNDUP for user UID1

    And I check the balance of account subtype HUGO_ROUNDUP of user UID1 is 0 SGD exact

    Examples:
      | map_type               | map_name           |
      | ETF_BALANCED_VAULT     | BALANCED_VAULT     |
      | ETF_GROWTH_VAULT       | GROWTH_VAULT       |
      | ETF_CAUTIOUS_VAULT     | CAUTIOUS_VAULT     |
      | ETF_MONEY_MARKET_VAULT | MONEY_MARKET_VAULT |
