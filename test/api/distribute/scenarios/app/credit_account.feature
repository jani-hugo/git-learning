Feature: Credit Account Scenarios

  Scenario: Create Transactions for 1st month
    Then I initiate transactions on the credit account for user profile id 6a3cbc87-5bc0-4859-b22f-37182nonprod
      | amount | txn_type | txn_time   |
      | 250    | DEBIT    | 2024-05-04 |
      | 150    | DEBIT    | 2024-05-10 |
      | 100    | DEBIT    | 2024-05-18 |

    Then I request to generate bill for 6a3cbc87-5bc0-4859-b22f-37182nonprod for date 2024-05-01


  Scenario: Create Transactions for 2nd month
    Then I initiate transactions on the credit account for user profile id 6a3cbc87-5bc0-4859-b22f-37182nonprod
      | amount | txn_type | txn_time   |
      | 150    | DEBIT    | 2024-04-05 |
      | 20     | CREDIT   | 2024-04-08 |
      | 50     | DEBIT    | 2024-04-12 |
      | 10     | DEBIT    | 2024-04-20 |

    Then I request to generate bill for 6a3cbc87-5bc0-4859-b22f-37182nonprod for date 2024-05-01

