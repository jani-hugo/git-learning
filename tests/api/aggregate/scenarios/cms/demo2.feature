Feature: Repayment less than Total Amount Due and greater than Minimum Amount Due

  Scenario: Create Credit Account

    Then Create a credit account

  Scenario: Get Balance

    Then Get balance for accountId f16a319b-73ca-4b47-9f62-507bc7b08c0f

  Scenario: Get Transactions

    Then Get transactions for accountId f16a319b-73ca-4b47-9f62-507bc7b08c0f

  Scenario: Get Bill for account

    Then Get Bill for accountId f16a319b-73ca-4b47-9f62-507bc7b08c0f

  Scenario: Transaction for 1st Month

    Then Initiate following transactions for accountId f16a319b-73ca-4b47-9f62-507bc7b08c0f
      | txn_time   | txn_type | amount |
      | 2024-03-04 | DEBIT    | 250    |
      | 2024-03-10 | DEBIT    | 150    |
      | 2024-03-15 | DEBIT    | 100    |

  Scenario: Generate bill for 1st month

    Then Generate bill for accountId f16a319b-73ca-4b47-9f62-507bc7b08c0f for bill date 2024-04-01

  Scenario: Transaction for 2nd Month

    Then Initiate following transactions for accountId f16a319b-73ca-4b47-9f62-507bc7b08c0f
      | txn_time   | txn_type | amount |
      | 2024-04-05 | DEBIT    | 150    |
      | 2024-04-08 | CREDIT   | 200    |
      | 2024-04-12 | DEBIT    | 50     |
      | 2024-04-20 | DEBIT    | 10     |

  Scenario: Generate bill for 2nd month

    Then Generate bill for accountId f16a319b-73ca-4b47-9f62-507bc7b08c0f for bill date 2024-05-01

#-----------------------------------------------------------------------------------------------------------------------
