Feature: Cash Maps

  Scenario Outline: Invest, Withdraw

    Given The user UID1 provides a valid mobile number
      | mobile_number | ph_prefix |  |
      | random        | +65       |  |
    Then The user UID1 submits OTP to proceed with verification

    Given I open a new user account
      | user_profile_identifier | email          |  | legal_name | name   | account_type |
      | UID1                    | test@gmail.com |  | John Doe   | Johnny | PERSONAL     |

    When I initiate the initial onboarding for the user UID1

    Then I submit the initial onboarding for UID1

    And I check the status of initial onboarding for UID1

    Given  Get user details for user UID1

    Given I create a Map MPID1
      | user_profile_identifier | name   | asset_allocation_details                  | allocation_type | goal_date  | goal_amount |
      | UID1                    | random | [{"asset_id": "CASH" ,"percentage": 100}] | FIXED           | 03-06-2024 | 100         |

    Then I check if the map MPID1 status is MAP_CREATED for user UID1

    Given I withdraw from map MPID1
      | user_profile_identifier | transaction_amount | withdraw_amount | fee_amount | status_code |
      | UID1                    | 7                  | 7               | 0          | HSA_9136    |

    And I check the balance of account subtype HUGO_CASH of user UID1 is 0 SGD exact

    Given I deposit 50 SGD into account subtype HUGO_CASH of user UID1

    And I check the balance of account subtype HUGO_CASH of user UID1 is 50 SGD exact

    Then I check intent type EXTERNAL_DEPOSIT with status SETTLED and total 1 intents exist in cash view for user UID1

    Given I invest in map MPID1
      | user_profile_identifier | transaction_amount | investment_amount | fee_amount | status_code |
      | UID1                    | 20                 | 20                | 0          | 200         |

    Then I check the balance of map MPID1 of user UID1 to be 20 SGD

    And I check the balance of account subtype HUGO_CASH of user UID1 is 30 SGD exact

    Then I check intent type CASH_MAP_INVEST with status SETTLED and total 1 intents exist in cash view for user UID1

    Then I check intent type CASH_MAP_INVEST with status SETTLED and total 1 intents exist in map_intent_view,MPID1 view for user UID1

    Given I withdraw from map MPID1
      | user_profile_identifier | transaction_amount | withdraw_amount | fee_amount | status_code |
      | UID1                    | 7                  | 7               | 0          | 200         |

    Then I check the balance of map MPID1 of user UID1 to be 13 SGD

    Then I check intent type CASH_MAP_WITHDRAW with status SETTLED and total 1 intents exist in cash view for user UID1

    Then I check intent type CASH_MAP_WITHDRAW with status SETTLED and total 1 intents exist in map_intent_view,MPID1 view for user UID1

    Then I update the map MPID1 and check if update was successful
      | user_profile_identifier | name       | goal_date  | goal_amount | status_code |
      | UID1                    | Investment | 30-04-2024 | 500.0       | 200         |

    Given I invest in map MPID1
      | user_profile_identifier | transaction_amount | investment_amount | fee_amount | status_code |
      | UID1                    | 111180             | 111180            | 0          | HSA_9145    |

    Given I withdraw from map MPID1
      | user_profile_identifier | transaction_amount | withdraw_amount | fee_amount | status_code |
      | UID1                    | 20                 | 20              | 0          | HSA_9136    |

    Given I invest in map MPID1
      | user_profile_identifier | transaction_amount | investment_amount | fee_amount | status_code | invalid_map |
      | UID1                    | 20                 | 20                | 0          | HSA_9107    | Y           |

    Given I withdraw from map MPID1
      | user_profile_identifier | transaction_amount | withdraw_amount | fee_amount | status_code | invalid_map |
      | UID1                    | 30                 | 30              | 0          | HSA_9107    | Y           |

    Then I update the map MPID1 and check if update was successful
      | user_profile_identifier | name       | goal_date  | goal_amount | status_code | invalid_map |
      | UID1                    | Investment | 30-04-2024 | 200.7       | HSA_9107    | Y           |

    Then I delete the map MPID1 of user UID1

    Then I check if the cash map MPID1 is deleted successfully for user UID1

    And I check the balance of account subtype HUGO_CASH of user UID1 is 50 SGD exact

    Then I check intent type DELETE_CASH_MAP with status SETTLED and total 1 intents exist in cash view for user UID1
    Examples:
      | org-id      |
      | HUGOBANK_PK |


