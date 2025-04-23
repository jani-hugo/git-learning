Feature: Repayment greater than Total Amount Due

  Scenario: Create Credit Account

    Then Create a credit account

  Scenario: Get Balance

    Then Get balance for accountId 4b964760-ff9a-4f84-839c-6dedd9e24f0a

  Scenario: Get Transactions

    Then Get transactions for accountId 4b964760-ff9a-4f84-839c-6dedd9e24f0a

  Scenario: Get Bill for account

    Then Get Bill for accountId 4b964760-ff9a-4f84-839c-6dedd9e24f0a

  Scenario: Transaction for 1st Month

    Then Initiate following transactions for accountId 4b964760-ff9a-4f84-839c-6dedd9e24f0a
      | txn_time   | txn_type | amount | txn_code |
      | 2024-03-04 | DEBIT    | 250    | ABC1     |
      | 2024-03-10 | DEBIT    | 150    | ABC2     |
      | 2024-03-15 | DEBIT    | 100    | ABC3     |

  Scenario: Generate bill for 1st month

    Then Generate bill for accountId 4b964760-ff9a-4f84-839c-6dedd9e24f0a for bill date 2024-04-01

  Scenario: Transaction for 2nd Month

    Then Initiate following transactions for accountId 4b964760-ff9a-4f84-839c-6dedd9e24f0a
      | txn_time   | txn_type | amount | txn_code |
      | 2024-04-05 | DEBIT    | 150    | ABC1     |
      | 2024-04-08 | CREDIT   | 5    |          |
      | 2024-04-12 | DEBIT    | 50     | ABC2     |
      | 2024-04-20 | DEBIT    | 10     | ABC4     |

  Scenario: Generate bill for 2nd month

    Then Generate bill for accountId 4b964760-ff9a-4f84-839c-6dedd9e24f0a for bill date 2024-05-01

#-----------------------------------------------------------------------------------------------------------------------
