Feature: Repayment less than Minimum Amount Due

  Scenario: Create Credit Account

    Then Create a credit account

  Scenario: Get Balance

    Then Get balance for accountId 4a8e55e5-10aa-441c-9159-67fb0e2af88b

  Scenario: Get Transactions

    Then Get transactions for accountId 4a8e55e5-10aa-441c-9159-67fb0e2af88b

  Scenario: Get Bill for account

    Then Get Bill for accountId 4a8e55e5-10aa-441c-9159-67fb0e2af88b

  Scenario: Transaction for 1st Month

    Then Initiate following transactions for accountId 4a8e55e5-10aa-441c-9159-67fb0e2af88b
      | txn_time   | txn_type | amount |
      | 2024-03-04 | DEBIT    | 250    |
      | 2024-03-10 | DEBIT    | 150    |
      | 2024-03-15 | DEBIT    | 100    |

  Scenario: Generate bill for 1st month

    Then Generate bill for accountId 4a8e55e5-10aa-441c-9159-67fb0e2af88b for bill date 2024-04-01

  Scenario: Transaction for 2nd Month

    Then Initiate following transactions for accountId 4a8e55e5-10aa-441c-9159-67fb0e2af88b
      | txn_time   | txn_type | amount |
      | 2024-04-05 | DEBIT    | 150    |
      | 2024-04-08 | CREDIT   | 20    |
      | 2024-04-12 | DEBIT    | 50     |
      | 2024-04-20 | DEBIT    | 10     |

  Scenario: Generate bill for 2nd month

    Then Generate bill for accountId 4a8e55e5-10aa-441c-9159-67fb0e2af88b for bill date 2024-05-01

#-----------------------------------------------------------------------------------------------------------------------
