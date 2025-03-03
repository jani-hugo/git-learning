Feature: Precious Metal Scenarios

  Background: Open Hugosave account
    Given I open user account
      | user_profile_identifier | phone_number | email          | legal_name     | status              |
      | UID1                    | random       | test@gmail.com | John Doe | PROFILE_IN_PROGRESS |

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

  Scenario Outline: Gold,Silver,Platinum Vault - Invest, Withdraw

    And I check if <vault_name> is created for user UID1

    Given I deposit 100 SGD into account subtype HUGO_CASH of user UID1

    And I check the balance of account subtype HUGO_CASH of user UID1 is 100 SGD exact

    # invest without rate token
    Given I invest in <asset_name> vault map without rate
      | user_profile_identifier | transaction_amount | investment_amount | fee_amount | status_code |
      | UID1                    | 10                 | 10                | 0          | 200         |

    Then I check the balance of <asset_name> Map of user UID1 to be 10

    And I check the balance of account subtype HUGO_CASH of user UID1 is 90 SGD exact

    # invest with rate token
    Given I invest in <asset_name> vault map with rate
      | user_profile_identifier | transaction_amount | investment_amount | fee_amount | status_code |
      | UID1                    | 20                 | 20                | 0          | 200         |

    Then I check the balance of <asset_name> Map of user UID1 to be 30

    And I check the balance of account subtype HUGO_CASH of user UID1 is 70 SGD exact

    # withdraw without rate token
    Given I withdraw from the <asset_name> map without rate
      | user_profile_identifier | transaction_amount | withdraw_amount | fee_amount | status_code |
      | UID1                    | 10                 | 10              | 0          | 200         |

    Then I manually settle the sell transaction of user UID1

    Then I check the balance of <asset_name> Map of user UID1 to be 17

    And I check the balance of account subtype HUGO_CASH of user UID1 is 80 SGD approx

    # withdraw with rate token
    Given I withdraw from the <asset_name> map with rate
      | user_profile_identifier | transaction_amount | withdraw_amount | fee_amount | status_code |
      | UID1                    | 10                 | 10              | 0          | 200         |

    Then I manually settle the sell transaction of user UID1

    Then I check the balance of <asset_name> Map of user UID1 to be 10

    And I check the balance of account subtype HUGO_CASH of user UID1 is 90 SGD approx

    # invest with invalid rate token
    Given I invest in <asset_name> vault map invalid rate
      | user_profile_identifier | transaction_amount | investment_amount | fee_amount | status_code |
      | UID1                    | 10                 | 10                | 0          | HSA_9135    |

    Then I check the balance of <asset_name> Map of user UID1 to be 10

    Then I check the balance of account subtype HUGO_CASH of user UID1 is 90 SGD approx

    # withdraw with invalid rate token
    Given I withdraw from the <asset_name> map invalid rate
      | user_profile_identifier | transaction_amount | withdraw_amount | fee_amount | status_code |
      | UID1                    | 7                  | 7               | 0          | HSA_9135    |

    Then I check the balance of <asset_name> Map of user UID1 to be 10

    Then I check the balance of account subtype HUGO_CASH of user UID1 is 90 SGD approx

    # invest with insufficient spend acc balance
    Given I invest in <asset_name> vault map without rate
      | user_profile_identifier | transaction_amount | investment_amount | fee_amount | status_code |
      | UID1                    | 110                | 110               | 0          | HSA_9145    |

    Then I check the balance of <asset_name> Map of user UID1 to be 10

    Then I check the balance of account subtype HUGO_CASH of user UID1 is 90 SGD approx

    # withdraw without sufficient balance in gold vault
    Given I withdraw from the <asset_name> map with rate
      | user_profile_identifier | transaction_amount | withdraw_amount | fee_amount | status_code |
      | UID1                    | 20                 | 20              | 0          | 200         |

    Then I check the balance of <asset_name> Map of user UID1 to be 10

    Then I check the balance of account subtype HUGO_CASH of user UID1 is 90 SGD approx

    # invest with transaction amount less than fee amount
    Given I invest in <asset_name> vault map without rate
      | user_profile_identifier | transaction_amount | investment_amount | fee_amount | status_code |
      | UID1                    | 0.01               | 0                 | 0.01       | HSA_9136    |
    Examples:
      | asset_name | vault_name     |
      | GOLD       | GOLD_VAULT     |
      | SILVER     | SILVER_VAULT   |
      | PLATINUM   | PLATINUM_VAULT |

  Scenario Outline: Schedule scenario for precious metals
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

    Then I check the balance of <asset_name> Map of user UID1 to be 3.26
    Then I check intent type SCHEDULE_MAP_INVEST with status SETTLED and total 1 intents exist in map_intent_view,<asset_name> view for user UID1

    Then I update the schedule status of SID1 with action PAUSE for user UID1
    Then I check schedule status as SCHEDULE_STATUS_PAUSED for schedule SID1 for user UID1

    Then I trigger schedule SID1 for user UID1
    And I check the balance of account subtype HUGO_CASH of user UID1 is 16.74 SGD exact

    Then I check the balance of <asset_name> Map of user UID1 to be 3.26
    Then I check intent type SCHEDULE_MAP_INVEST with status SETTLED and total 1 intents exist in map_intent_view,<asset_name> view for user UID1

    Then I update the schedule status of SID1 with action RESUME for user UID1
    Then I check schedule status as SCHEDULE_STATUS_ACTIVE for schedule SID1 for user UID1
    Examples:
      | asset_name | vault_name     |
      | GOLD       | GOLD_VAULT     |
      | SILVER     | SILVER_VAULT   |
      | PLATINUM   | PLATINUM_VAULT |