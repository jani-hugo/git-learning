Feature: Credit Account Scenarios

  Scenario: Create Transactions for 1st month
    Then I initiate transactions on the credit account for user profile id d6e5e155-2190-4313-8a19-37189nonprod
      | amount | txn_type | txn_time   |
      | 250    | DEBIT    | 2024-03-04 |
      | 150    | DEBIT    | 2024-03-10 |
      | 100    | DEBIT    | 2024-03-15 |

  Scenario:
    Then I request to generate bill for d6e5e155-2190-4313-8a19-37189nonprod for date 2024-02-01

  Scenario: Create Transactions for 2nd month
    Then I initiate transactions on the credit account for user profile id d6e5e155-2190-4313-8a19-37189nonprod
      | amount | txn_type | txn_time   |
      | 150    | DEBIT    | 2024-04-05 |
      # Scenario 1: Repayment > TAD
      | 500     | CREDIT   | 2024-04-08 |
      # Scenario 1: MAD < Repayment < TAD
      | 250     | CREDIT   | 2024-04-08 |
      # Scenario 1: Repayment < MAD
      | 20     | CREDIT   | 2024-04-08 |
      | 50     | DEBIT    | 2024-04-12 |
      | 10     | DEBIT    | 2024-04-20 |

    Then I request to generate bill for d6e5e155-2190-4313-8a19-37189nonprod for date 2024-03-01

