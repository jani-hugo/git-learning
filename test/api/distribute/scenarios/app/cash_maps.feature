Feature: Cash Maps

  Scenario Outline: Invest, Withdraw
    Given I open user account
      | user_profile_identifier | phone_number | email          | legal_name | status              | org_id   |
      | UID1                    | random       | test@gmail.com | John Doe   | PROFILE_IN_PROGRESS | <org-id> |

    Then I check account status
      | user_profile_identifier | status         |
      | UID1                    | PROFILE_ACTIVE |

    # Create
    Given I create a Map MPID1
      | user_profile_identifier | name   | asset_allocation_details                  | allocation_type | goal_date  | goal_amount |
      | UID1                    | random | [{"asset_id": "CASH" ,"percentage": 100}] | FIXED           | 03-06-2024 | 100         |

    Then I check if the map MPID1 status is MAP_CREATED for user UID1

    # Withdraw with 0 balance in map
    Given I withdraw from map MPID1
      | user_profile_identifier | transaction_amount | withdraw_amount | fee_amount | status_code |
      | UID1                    | 7                  | 7               | 0          | HSA_9136    |

    # Invest
    Given I deposit 50 SGD into account subtype HUGO_CASH of user UID1

    Then I wait for 5 seconds

    And I check the balance of account subtype HUGO_CASH of user UID1 is 50 SGD exact

    Then I check intent type EXTERNAL_DEPOSIT with status SETTLED and total 1 intents exist in cash view for user UID1

    Given I invest in map MPID1
      | user_profile_identifier | transaction_amount | investment_amount | fee_amount | status_code |
      | UID1                    | 20                 | 20                | 0          | 200         |

    Then I check the balance of map MPID1 of user UID1 to be 20 SGD

    And I check the balance of account subtype HUGO_CASH of user UID1 is 30 SGD exact

    Then I check intent type CASH_MAP_INVEST with status SETTLED and total 1 intents exist in cash view for user UID1

    Then I check intent type CASH_MAP_INVEST with status SETTLED and total 1 intents exist in map_intent_view,MPID1 view for user UID1


    # Withdraw
    Given I withdraw from map MPID1
      | user_profile_identifier | transaction_amount | withdraw_amount | fee_amount | status_code |
      | UID1                    | 7                  | 7               | 0          | 200         |

    Then I check the balance of map MPID1 of user UID1 to be 13 SGD

    Then I check intent type CASH_MAP_WITHDRAW with status SETTLED and total 1 intents exist in cash view for user UID1

    Then I check intent type CASH_MAP_WITHDRAW with status SETTLED and total 1 intents exist in map_intent_view,MPID1 view for user UID1


    # Update
    Then I update the map MPID1 and check if update was successful
      | user_profile_identifier | name       | goal_date  | goal_amount | status_code |
      | UID1                    | Investment | 30-04-2024 | 500.0       | 200         |


    # Invest without balance in spend account should fail
    Given I invest in map MPID1
      | user_profile_identifier | transaction_amount | investment_amount | fee_amount | status_code |
      | UID1                    | 80                 | 80                | 0          | HSA_9145    |


    # Withdraw more than available balance in map
    Given I withdraw from map MPID1
      | user_profile_identifier | transaction_amount | withdraw_amount | fee_amount | status_code |
      | UID1                    | 20                 | 20              | 0          | HSA_9136    |


    # Invalid maps Ids
    Given I invest in map MPID1
      | user_profile_identifier | transaction_amount | investment_amount | fee_amount | status_code | invalid_map |
      | UID1                    | 20                 | 20                | 0          | HSA_9107    | Y           |

    Given I withdraw from map MPID1
      | user_profile_identifier | transaction_amount | withdraw_amount | fee_amount | status_code | invalid_map |
      | UID1                    | 30                 | 30              | 0          | HSA_9107    | Y           |

    Then I update the map MPID1 and check if update was successful
      | user_profile_identifier | name       | goal_date  | goal_amount | status_code | invalid_map |
      | UID1                    | Investment | 30-04-2024 | 200.7       | HSA_9107    | Y           |

    # Delete map
    Then I delete the map MPID1 of user UID1
    Then I wait for 30 seconds

    Then I check if the cash map MPID1 is deleted successfully for user UID1

    And I check the balance of account subtype HUGO_CASH of user UID1 is 50 SGD exact

    Then I check intent type DELETE_CASH_MAP with status SETTLED and total 1 intents exist in cash view for user UID1
    Examples:
      | org-id      |
#      |             |
      | HUGOBANK_PK |