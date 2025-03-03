Feature: Ledger service's transaction scenarios

  Scenario Outline: Create ledgers and initiate transaction between them
    Given I create below ledgers
      | identifier | profile_id | profile_type | holding_type | initial_units   | can_be_negative   | metadata           |
      | LId1       | profile1   | END_CUSTOMER | CASH-SGD     | <initial_units> | <can_be_negative> | {"key1": "value1"} |
      | LId2       | profile2   | END_CUSTOMER | CASH-SGD     | <initial_units> | <can_be_negative> | {"key2": "value2"} |

    And I initiate ledger transaction
      | identifier | from_ledger_id   | to_ledger_id   | units   | source_rate_per_unit | destination_rate_per_unit | status   | external_transaction_id | reference_data        |
      | TxId1      | <from_ledger_id> | <to_ledger_id> | <units> | <units>              | <units>                   | <status> | ExternalTxId            | Sample reference data |

    Then I verify transaction entry exist for transaction TxId1
      | from_ledger_id   | to_ledger_id   | units   | source_rate_per_unit | destination_rate_per_unit | transaction_status | external_transaction_id | reference_data        |
      | <from_ledger_id> | <to_ledger_id> | <units> | <units>              | <units>                   | <status>           | ExternalTxId            | Sample reference data |

    Then I verify for ledger LId1 total balance is <total_bal1> and available balance is <avail_bal1>

    Then I verify for ledger LId2 total balance is <total_bal2> and available balance is <avail_bal2>

    Examples:
      | initial_units | can_be_negative | from_ledger_id | to_ledger_id | units  | status  | total_bal1 | avail_bal1 | total_bal2 | avail_bal2 |
      | 100           | false           | LId1           | LId2         | 100    | CREATED | 100        | 0          | 200        | 100        |
      | 100           | false           | LId1           | LId2         | 40.5   | CREATED | 100        | 59.5       | 140.5      | 100        |
      | 100           | false           | LId1           | LId2         | 0.001  | CREATED | 100        | 99.999     | 100.001    | 100        |
      | 100           | false           | LId1           | LId2         | 99.999 | CREATED | 100        | 0.001      | 199.999    | 100        |
      | 100           | true            | LId1           | LId2         | 40.5   | CREATED | 100        | 59.5       | 140.5      | 100        |
      | 100           | true            | LId1           | LId2         | 100    | CREATED | 100        | 0          | 200        | 100        |
      | 0             | true            | LId1           | LId2         | 40.5   | CREATED | 0          | -40.5      | 40.5       | 0          |
      | 20            | true            | LId1           | LId2         | 40.5   | CREATED | 20         | -20.5      | 60.5       | 20         |
      | 100           | false           | LId1           | LId2         | 100    | PENDING | 100        | 0          | 200        | 100        |
      | 100           | false           | LId1           | LId2         | 40.5   | PENDING | 100        | 59.5       | 140.5      | 100        |
      | 100           | false           | LId1           | LId2         | 0.001  | PENDING | 100        | 99.999     | 100.001    | 100        |
      | 100           | false           | LId1           | LId2         | 99.999 | PENDING | 100        | 0.001      | 199.999    | 100        |
      | 100           | true            | LId1           | LId2         | 40.5   | PENDING | 100        | 59.5       | 140.5      | 100        |
      | 100           | true            | LId1           | LId2         | 100    | PENDING | 100        | 0          | 200        | 100        |
      | 0             | true            | LId1           | LId2         | 40.5   | PENDING | 0          | -40.5      | 40.5       | 0          |
      | 20            | true            | LId1           | LId2         | 40.5   | PENDING | 20         | -20.5      | 60.5       | 20         |
      | 100           | false           | LId1           | LId2         | 40.5   | SETTLED | 59.5       | 59.5       | 140.5      | 140.5      |
      | 100           | false           | LId1           | LId2         | 0.001  | SETTLED | 99.999     | 99.999     | 100.001    | 100.001    |
      | 100           | false           | LId1           | LId2         | 99.999 | SETTLED | 0.001      | 0.001      | 199.999    | 199.999    |


  Scenario Outline: Create ledgers, initiate and settle transaction
    Given I create below ledgers
      | identifier | profile_id | profile_type | holding_type | initial_units   | can_be_negative   | metadata           |
      | LId1       | profile1   | END_CUSTOMER | CASH-SGD     | <initial_units> | <can_be_negative> | {"key1": "value1"} |
      | LId2       | profile2   | END_CUSTOMER | CASH-SGD     | <initial_units> | <can_be_negative> | {"key2": "value2"} |

    And I initiate ledger transaction
      | identifier | from_ledger_id   | to_ledger_id   | units   | source_rate_per_unit | destination_rate_per_unit | status   | external_transaction_id | reference_data        |
      | TxId1      | <from_ledger_id> | <to_ledger_id> | <units> | <units>              | <units>                   | <status> | ExternalTxId            | Sample reference data |

    And I verify transaction entry exist for transaction TxId1
      | from_ledger_id   | to_ledger_id   | units   | source_rate_per_unit | destination_rate_per_unit | transaction_status | external_transaction_id | reference_data        |
      | <from_ledger_id> | <to_ledger_id> | <units> | <units>              | <units>                   | <status>           | ExternalTxId            | Sample reference data |

    And I verify for ledger LId1 total balance is <t_bal1> and available balance is <a_bal1>

    And I verify for ledger LId2 total balance is <t_bal2> and available balance is <a_bal2>

    Then I update ledger transaction status as SETTLED for TxId1

    And I verify transaction entry exist for transaction TxId1
      | from_ledger_id   | to_ledger_id   | units   | source_rate_per_unit | destination_rate_per_unit | transaction_status | external_transaction_id | reference_data        |
      | <from_ledger_id> | <to_ledger_id> | <units> | <units>              | <units>                   | SETTLED            | ExternalTxId            | Sample reference data |

    And I verify for ledger LId1 total balance is <t_bal3> and available balance is <a_bal3>

    And I verify for ledger LId2 total balance is <t_bal4> and available balance is <a_bal4>

    Examples:
      | initial_units | can_be_negative | from_ledger_id | to_ledger_id | units  | status  | t_bal1 | a_bal1  | t_bal2   | a_bal2 | t_bal3  | a_bal3  | t_bal4   | a_bal4   |
      | 100           | false           | LId1           | LId2         | 100    | CREATED | 100    | 0       | 200      | 100    | 0       | 0       | 200      | 200      |
      | 100           | false           | LId1           | LId2         | 100    | PENDING | 100    | 0       | 200      | 100    | 0       | 0       | 200      | 200      |
      | 1000          | false           | LId1           | LId2         | 40.242 | PENDING | 1000   | 959.758 | 1040.242 | 1000   | 959.758 | 959.758 | 1040.242 | 1040.242 |
      | 10            | false           | LId1           | LId2         | 9.793  | CREATED | 10     | 0.207   | 19.793   | 10     | 0.207   | 0.207   | 19.793   | 19.793   |
      | 3.391         | true            | LId1           | LId2         | 0.019  | PENDING | 3.391  | 3.372   | 3.41     | 3.391  | 3.372   | 3.372   | 3.41     | 3.41     |
      | 3.391         | true            | LId1           | LId2         | 12.32  | CREATED | 3.391  | -8.929  | 15.711   | 3.391  | -8.929  | -8.929  | 15.711   | 15.711   |
      #| 100           | false           | LId1           | LId2         | 100   | PENDING_SETTLEMENT | 100    | 0      | 200    | 100    | 0      | 0      | 200    | 200    |


  Scenario Outline: Attempt to transfer negative units of ledger and verify fail
    Given I create below ledgers
      | identifier | profile_id | profile_type | holding_type | initial_units | can_be_negative | metadata           |
      | LId1       | profile1   | END_CUSTOMER | CASH-SGD     | 100           | true            | {"key1": "value1"} |
      | LId2       | profile2   | END_CUSTOMER | CASH-SGD     | 100           | true            | {"key2": "value2"} |

    Then I initiate ledger transaction with incorrect data and verify transaction failed
      | identifier | from_ledger_id | to_ledger_id | units | source_rate_per_unit | destination_rate_per_unit | status   | external_transaction_id | reference_data        |
      | TxId1      | LId1           | LId2         | -100  | -100                 | -100                      | <status> | ExternalTxId            | Sample reference data |

    Examples:
      | status  |
      | CREATED |
      | PENDING |
#      | PENDING_SETTLEMENT |
#      | REVERT             |
#      | SETTLED            |


  Scenario: Create two pending transactions
    Given I create below ledgers
      | identifier | profile_id | profile_type | holding_type | initial_units | can_be_negative | metadata           |
      | LId1       | profile1   | END_CUSTOMER | CASH-SGD     | 100           | false           | {"key1": "value1"} |
      | LId2       | profile2   | END_CUSTOMER | CASH-SGD     | 0             | true            | {"key2": "value2"} |

    And I initiate ledger transaction
      | identifier | from_ledger_id | to_ledger_id | units | source_rate_per_unit | destination_rate_per_unit | status  | external_transaction_id | reference_data        |
      | TxId1      | LId1           | LId2         | 50    | 50                   | 50                        | CREATED | ExternalTxId            | Sample reference data |

    And I verify transaction entry exist for transaction TxId1
      | from_ledger_id | to_ledger_id | units | source_rate_per_unit | destination_rate_per_unit | transaction_status | external_transaction_id | reference_data        |
      | LId1           | LId2         | 50    | 50                   | 50                        | CREATED            | ExternalTxId            | Sample reference data |

    And I verify for ledger LId1 total balance is 100 and available balance is 50

    And I verify for ledger LId2 total balance is 50 and available balance is 0

    Then I initiate ledger transaction
      | identifier | from_ledger_id | to_ledger_id | units | source_rate_per_unit | destination_rate_per_unit | status  | external_transaction_id | reference_data        |
      | TxId1      | LId1           | LId2         | 50    | 50                   | 50                        | CREATED | ExternalTxId            | Sample reference data |

    And I verify transaction entry exist for transaction TxId1
      | from_ledger_id | to_ledger_id | units | source_rate_per_unit | destination_rate_per_unit | transaction_status | external_transaction_id | reference_data        |
      | LId1           | LId2         | 50    | 50                   | 50                        | CREATED            | ExternalTxId            | Sample reference data |

    And I verify for ledger LId1 total balance is 100 and available balance is 0

    And I verify for ledger LId2 total balance is 100 and available balance is 0


  Scenario Outline: Attempt to transfer more than available balance for a non negative ledger
    Given I create below ledgers
      | identifier | profile_id | profile_type | holding_type | initial_units | can_be_negative | metadata           |
      | LId1       | profile1   | END_CUSTOMER | CASH-SGD     | 100           | false           | {"key1": "value1"} |
      | LId2       | profile2   | END_CUSTOMER | CASH-SGD     | 0             | true            | {"key2": "value2"} |

    Then I initiate ledger transaction with incorrect data and verify transaction failed
      | identifier | from_ledger_id | to_ledger_id | units | source_rate_per_unit | destination_rate_per_unit | status   | external_transaction_id | reference_data        |
      | TxId1      | LId1           | LId2         | 200   | 200                  | 200                       | <status> | ExternalTxId            | Sample reference data |

    Examples:
      | status  |
      | CREATED |
      | PENDING |
#      | PENDING_SETTLEMENT |
#      | REVERT             |
#      | SETTLED            |


  Scenario: Create a pending transaction and initiate another transfer of total balance worth of funds
    Given I create below ledgers
      | identifier | profile_id | profile_type | holding_type | initial_units | can_be_negative | metadata           |
      | LId1       | profile1   | END_CUSTOMER | CASH-SGD     | 100           | false           | {"key1": "value1"} |
      | LId2       | profile2   | END_CUSTOMER | CASH-SGD     | 0             | true            | {"key2": "value2"} |

    And I initiate ledger transaction
      | identifier | from_ledger_id | to_ledger_id | units | source_rate_per_unit | destination_rate_per_unit | status  | external_transaction_id | reference_data        |
      | TxId1      | LId1           | LId2         | 50    | 50                   | 50                        | CREATED | ExternalTxId            | Sample reference data |

    And I verify transaction entry exist for transaction TxId1
      | from_ledger_id | to_ledger_id | units | source_rate_per_unit | destination_rate_per_unit | transaction_status | external_transaction_id | reference_data        |
      | LId1           | LId2         | 50    | 50                   | 50                        | CREATED            | ExternalTxId            | Sample reference data |

    And I verify for ledger LId1 total balance is 100 and available balance is 50

    And I verify for ledger LId2 total balance is 50 and available balance is 0

    Then I initiate ledger transaction with incorrect data and verify transaction failed
      | identifier | from_ledger_id | to_ledger_id | units | source_rate_per_unit | destination_rate_per_unit | status  | external_transaction_id | reference_data        |
      | TxId1      | LId1           | LId2         | 60    | 60                   | 60                        | CREATED | ExternalTxId            | Sample reference data |


  Scenario Outline: Attempt to initiate transaction with same ledger IDs
    Given I create below ledgers
      | identifier | profile_id | profile_type | holding_type | initial_units | can_be_negative | metadata           |
      | LId1       | profile1   | END_CUSTOMER | CASH-SGD     | 100           | true            | {"key1": "value1"} |
      | LId2       | profile2   | END_CUSTOMER | CASH-SGD     | 100           | true            | {"key2": "value2"} |

    Then I initiate ledger transaction with incorrect data and verify transaction failed
      | identifier | from_ledger_id   | to_ledger_id   | units | source_rate_per_unit | destination_rate_per_unit | status   | external_transaction_id | reference_data        |
      | TxId1      | <from_ledger_id> | <to_ledger_id> | 2     | 1                    | 1                         | <status> | ExternalTxId            | Sample reference data |

    Examples:
      | from_ledger_id | to_ledger_id | status  |
      | LId1           | LId1         | CREATED |
      | LId2           | LId2         | CREATED |


  Scenario Outline: Initiate transaction with pending status and update with revert transaction
    Given I create below ledgers
      | identifier | profile_id | profile_type | holding_type | initial_units   | can_be_negative   | metadata           |
      | LId1       | profile1   | END_CUSTOMER | CASH-SGD     | <initial_units> | <can_be_negative> | {"key1": "value1"} |
      | LId2       | profile2   | END_CUSTOMER | CASH-SGD     | <initial_units> | <can_be_negative> | {"key2": "value2"} |

    And I initiate ledger transaction
      | identifier | from_ledger_id   | to_ledger_id   | units   | source_rate_per_unit | destination_rate_per_unit | status   | external_transaction_id | reference_data        |
      | TxId1      | <from_ledger_id> | <to_ledger_id> | <units> | <units>              | <units>                   | <status> | ExternalTxId            | Sample reference data |

    And I verify transaction entry exist for transaction TxId1
      | from_ledger_id   | to_ledger_id   | units   | source_rate_per_unit | destination_rate_per_unit | transaction_status | external_transaction_id | reference_data        |
      | <from_ledger_id> | <to_ledger_id> | <units> | <units>              | <units>                   | <status>           | ExternalTxId            | Sample reference data |

    And I verify for ledger LId1 total balance is <t_bal1> and available balance is <a_bal1>

    And I verify for ledger LId2 total balance is <t_bal2> and available balance is <a_bal2>

    Then I update ledger transaction status as REVERT for TxId1

    And I verify transaction entry exist for transaction TxId1
      | from_ledger_id   | to_ledger_id   | units   | source_rate_per_unit | destination_rate_per_unit | transaction_status | external_transaction_id | reference_data        |
      | <from_ledger_id> | <to_ledger_id> | <units> | <units>              | <units>                   | REVERT             | ExternalTxId            | Sample reference data |

    And I verify for ledger LId1 total balance is <t_bal3> and available balance is <a_bal3>

    And I verify for ledger LId2 total balance is <t_bal4> and available balance is <a_bal4>

    Examples:
      | initial_units | can_be_negative | from_ledger_id | to_ledger_id | units  | status  | t_bal1 | a_bal1  | t_bal2   | a_bal2 | t_bal3 | a_bal3 | t_bal4 | a_bal4 |
      | 100           | false           | LId1           | LId2         | 100    | CREATED | 100    | 0       | 200      | 100    | 100    | 100    | 100    | 100    |
      | 100           | false           | LId1           | LId2         | 100    | PENDING | 100    | 0       | 200      | 100    | 100    | 100    | 100    | 100    |
      | 1000          | false           | LId1           | LId2         | 40.242 | PENDING | 1000   | 959.758 | 1040.242 | 1000   | 1000   | 1000   | 1000   | 1000   |
      | 10            | false           | LId1           | LId2         | 9.793  | CREATED | 10     | 0.207   | 19.793   | 10     | 10     | 10     | 10     | 10     |
      | 3.391         | true            | LId1           | LId2         | 0.019  | PENDING | 3.391  | 3.372   | 3.41     | 3.391  | 3.391  | 3.391  | 3.391  | 3.391  |
      | 3.391         | true            | LId1           | LId2         | 12.32  | CREATED | 3.391  | -8.929  | 15.711   | 3.391  | 3.391  | 3.391  | 3.391  | 3.391  |
      #| 100           | false           | LId1           | LId2         | 100   | PENDING_SETTLEMENT | 100    | 0      | 200    | 100    | 100    | 100    | 100    | 100    |


  Scenario Outline: Initiate transaction and update status to pending settlement then revert the transaction
    Given I create below ledgers
      | identifier | profile_id | profile_type | holding_type | initial_units   | can_be_negative   | metadata           |
      | LId1       | profile1   | END_CUSTOMER | CASH-SGD     | <initial_units> | <can_be_negative> | {"key1": "value1"} |
      | LId2       | profile2   | END_CUSTOMER | CASH-SGD     | <initial_units> | <can_be_negative> | {"key2": "value2"} |

    And I initiate ledger transaction
      | identifier | from_ledger_id   | to_ledger_id   | units   | source_rate_per_unit | destination_rate_per_unit | status   | external_transaction_id | reference_data        |
      | TxId1      | <from_ledger_id> | <to_ledger_id> | <units> | <units>              | <units>                   | <status> | ExternalTxId            | Sample reference data |

    And I verify transaction entry exist for transaction TxId1
      | from_ledger_id   | to_ledger_id   | units   | source_rate_per_unit | destination_rate_per_unit | transaction_status | external_transaction_id | reference_data        |
      | <from_ledger_id> | <to_ledger_id> | <units> | <units>              | <units>                   | <status>           | ExternalTxId            | Sample reference data |

    And I verify for ledger LId1 total balance is <t_bal1> and available balance is <a_bal1>

    And I verify for ledger LId2 total balance is <t_bal2> and available balance is <a_bal2>

    Then I update ledger transaction status as PENDING_SETTLEMENT for TxId1

    And I verify transaction entry exist for transaction TxId1
      | from_ledger_id   | to_ledger_id   | units   | source_rate_per_unit | destination_rate_per_unit | transaction_status | external_transaction_id | reference_data        |
      | <from_ledger_id> | <to_ledger_id> | <units> | <units>              | <units>                   | PENDING_SETTLEMENT | ExternalTxId            | Sample reference data |

    And I verify for ledger LId1 total balance is <t_bal3> and available balance is <a_bal3>

    And I verify for ledger LId2 total balance is <t_bal4> and available balance is <a_bal4>

    Then I update ledger transaction status as REVERT for TxId1

    And I verify transaction entry exist for transaction TxId1
      | from_ledger_id   | to_ledger_id   | units   | source_rate_per_unit | destination_rate_per_unit | transaction_status | external_transaction_id | reference_data        |
      | <from_ledger_id> | <to_ledger_id> | <units> | <units>              | <units>                   | REVERT             | ExternalTxId            | Sample reference data |

    And I verify for ledger LId1 total balance is <t_bal5> and available balance is <a_bal5>

    And I verify for ledger LId2 total balance is <t_bal6> and available balance is <a_bal6>

    Examples:
      | initial_units | can_be_negative | from_ledger_id | to_ledger_id | units  | status  | t_bal1 | a_bal1  | t_bal2   | a_bal2 | t_bal3  | a_bal3  | t_bal4   | a_bal4   | t_bal5 | a_bal5 | t_bal6 | a_bal6 |
      | 100           | false           | LId1           | LId2         | 100    | CREATED | 100    | 0       | 200      | 100    | 0       | 0       | 200      | 200      | 100    | 100    | 100    | 100    |
      | 100           | false           | LId1           | LId2         | 100    | PENDING | 100    | 0       | 200      | 100    | 0       | 0       | 200      | 200      | 100    | 100    | 100    | 100    |
      | 1000          | false           | LId1           | LId2         | 40.242 | PENDING | 1000   | 959.758 | 1040.242 | 1000   | 959.758 | 959.758 | 1040.242 | 1040.242 | 1000   | 1000   | 1000   | 1000   |
      | 10            | false           | LId1           | LId2         | 9.793  | CREATED | 10     | 0.207   | 19.793   | 10     | 0.207   | 0.207   | 19.793   | 19.793   | 10     | 10     | 10     | 10     |
      | 3.391         | true            | LId1           | LId2         | 0.019  | PENDING | 3.391  | 3.372   | 3.41     | 3.391  | 3.372   | 3.372   | 3.41     | 3.41     | 3.391  | 3.391  | 3.391  | 3.391  |
      | 3.391         | true            | LId1           | LId2         | 12.32  | CREATED | 3.391  | -8.929  | 15.711   | 3.391  | -8.929  | -8.929  | 15.711   | 15.711   | 3.391  | 3.391  | 3.391  | 3.391  |
      #| 100           | false           | LId1           | LId2         | 100   | PENDING_SETTLEMENT | 100    | 0      | 200    | 100    | 0      | 0      | 200    | 200    |


  Scenario Outline: Initiate transaction and update status to pending settlement then settle the transaction
    Given I create below ledgers
      | identifier | profile_id | profile_type | holding_type | initial_units   | can_be_negative   | metadata           |
      | LId1       | profile1   | END_CUSTOMER | CASH-SGD     | <initial_units> | <can_be_negative> | {"key1": "value1"} |
      | LId2       | profile2   | END_CUSTOMER | CASH-SGD     | <initial_units> | <can_be_negative> | {"key2": "value2"} |

    And I initiate ledger transaction
      | identifier | from_ledger_id   | to_ledger_id   | units   | source_rate_per_unit | destination_rate_per_unit | status   | external_transaction_id | reference_data        |
      | TxId1      | <from_ledger_id> | <to_ledger_id> | <units> | <units>              | <units>                   | <status> | ExternalTxId            | Sample reference data |

    And I verify transaction entry exist for transaction TxId1
      | from_ledger_id   | to_ledger_id   | units   | source_rate_per_unit | destination_rate_per_unit | transaction_status | external_transaction_id | reference_data        |
      | <from_ledger_id> | <to_ledger_id> | <units> | <units>              | <units>                   | <status>           | ExternalTxId            | Sample reference data |

    And I verify for ledger LId1 total balance is <t_bal1> and available balance is <a_bal1>

    And I verify for ledger LId2 total balance is <t_bal2> and available balance is <a_bal2>

    Then I update ledger transaction status as PENDING_SETTLEMENT for TxId1

    And I verify transaction entry exist for transaction TxId1
      | from_ledger_id   | to_ledger_id   | units   | source_rate_per_unit | destination_rate_per_unit | transaction_status | external_transaction_id | reference_data        |
      | <from_ledger_id> | <to_ledger_id> | <units> | <units>              | <units>                   | PENDING_SETTLEMENT | ExternalTxId            | Sample reference data |

    And I verify for ledger LId1 total balance is <t_bal3> and available balance is <a_bal3>

    And I verify for ledger LId2 total balance is <t_bal4> and available balance is <a_bal4>

    Then I update ledger transaction status as SETTLED for TxId1

    And I verify transaction entry exist for transaction TxId1
      | from_ledger_id   | to_ledger_id   | units   | source_rate_per_unit | destination_rate_per_unit | transaction_status | external_transaction_id | reference_data        |
      | <from_ledger_id> | <to_ledger_id> | <units> | <units>              | <units>                   | SETTLED            | ExternalTxId            | Sample reference data |

    And I verify for ledger LId1 total balance is <t_bal5> and available balance is <a_bal5>

    And I verify for ledger LId2 total balance is <t_bal6> and available balance is <a_bal6>

    Examples:
      | initial_units | can_be_negative | from_ledger_id | to_ledger_id | units  | status  | t_bal1 | a_bal1  | t_bal2   | a_bal2 | t_bal3  | a_bal3  | t_bal4   | a_bal4   | t_bal5  | a_bal5  | t_bal6   | a_bal6   |
      | 1000          | false           | LId1           | LId2         | 40.242 | PENDING | 1000   | 959.758 | 1040.242 | 1000   | 959.758 | 959.758 | 1040.242 | 1040.242 | 959.758 | 959.758 | 1040.242 | 1040.242 |
      | 10            | false           | LId1           | LId2         | 9.793  | CREATED | 10     | 0.207   | 19.793   | 10     | 0.207   | 0.207   | 19.793   | 19.793   | 0.207   | 0.207   | 19.793   | 19.793   |
      | 3.391         | true            | LId1           | LId2         | 0.019  | PENDING | 3.391  | 3.372   | 3.41     | 3.391  | 3.372   | 3.372   | 3.41     | 3.41     | 3.372   | 3.372   | 3.41     | 3.41     |
      | 3.391         | true            | LId1           | LId2         | 12.32  | CREATED | 3.391  | -8.929  | 15.711   | 3.391  | -8.929  | -8.929  | 15.711   | 15.711   | -8.929  | -8.929  | 15.711   | 15.711   |


  Scenario Outline: Initiate transaction and settle it then attempt to revert the transaction and verify failure
    Given I create below ledgers
      | identifier | profile_id | profile_type | holding_type | initial_units   | can_be_negative   | metadata           |
      | LId1       | profile1   | END_CUSTOMER | CASH-SGD     | <initial_units> | <can_be_negative> | {"key1": "value1"} |
      | LId2       | profile2   | END_CUSTOMER | CASH-SGD     | <initial_units> | <can_be_negative> | {"key2": "value2"} |

    And I initiate ledger transaction
      | identifier | from_ledger_id   | to_ledger_id   | units   | source_rate_per_unit | destination_rate_per_unit | status   | external_transaction_id | reference_data        |
      | TxId1      | <from_ledger_id> | <to_ledger_id> | <units> | <units>              | <units>                   | <status> | ExternalTxId            | Sample reference data |

    And I verify transaction entry exist for transaction TxId1
      | from_ledger_id   | to_ledger_id   | units   | source_rate_per_unit | destination_rate_per_unit | transaction_status | external_transaction_id | reference_data        |
      | <from_ledger_id> | <to_ledger_id> | <units> | <units>              | <units>                   | <status>           | ExternalTxId            | Sample reference data |

    And I verify for ledger LId1 total balance is <t_bal1> and available balance is <a_bal1>

    And I verify for ledger LId2 total balance is <t_bal2> and available balance is <a_bal2>

    Then I update ledger transaction status as PENDING_SETTLEMENT for TxId1

    And I verify transaction entry exist for transaction TxId1
      | from_ledger_id   | to_ledger_id   | units   | source_rate_per_unit | destination_rate_per_unit | transaction_status | external_transaction_id | reference_data        |
      | <from_ledger_id> | <to_ledger_id> | <units> | <units>              | <units>                   | PENDING_SETTLEMENT | ExternalTxId            | Sample reference data |

    And I verify for ledger LId1 total balance is <t_bal3> and available balance is <a_bal3>

    And I verify for ledger LId2 total balance is <t_bal4> and available balance is <a_bal4>

    Then I update ledger transaction status as SETTLED for TxId1

    And I verify transaction entry exist for transaction TxId1
      | from_ledger_id   | to_ledger_id   | units   | source_rate_per_unit | destination_rate_per_unit | transaction_status | external_transaction_id | reference_data        |
      | <from_ledger_id> | <to_ledger_id> | <units> | <units>              | <units>                   | SETTLED            | ExternalTxId            | Sample reference data |

    And I verify for ledger LId1 total balance is <t_bal5> and available balance is <a_bal5>

    And I verify for ledger LId2 total balance is <t_bal6> and available balance is <a_bal6>

    Then I Update Settled ledger transaction status as REVERT for TxId1 and verify transaction failed

    Examples:
      | initial_units | can_be_negative | from_ledger_id | to_ledger_id | units  | status  | t_bal1 | a_bal1  | t_bal2   | a_bal2 | t_bal3  | a_bal3  | t_bal4   | a_bal4   | t_bal5  | a_bal5  | t_bal6   | a_bal6   |
      | 1000          | false           | LId1           | LId2         | 40.242 | PENDING | 1000   | 959.758 | 1040.242 | 1000   | 959.758 | 959.758 | 1040.242 | 1040.242 | 959.758 | 959.758 | 1040.242 | 1040.242 |
      | 10            | false           | LId1           | LId2         | 9.793  | CREATED | 10     | 0.207   | 19.793   | 10     | 0.207   | 0.207   | 19.793   | 19.793   | 0.207   | 0.207   | 19.793   | 19.793   |
      | 3.391         | true            | LId1           | LId2         | 0.019  | PENDING | 3.391  | 3.372   | 3.41     | 3.391  | 3.372   | 3.372   | 3.41     | 3.41     | 3.372   | 3.372   | 3.41     | 3.41     |
      | 3.391         | true            | LId1           | LId2         | 12.32  | CREATED | 3.391  | -8.929  | 15.711   | 3.391  | -8.929  | -8.929  | 15.711   | 15.711   | -8.929  | -8.929  | 15.711   | 15.711   |

  Scenario Outline: Initiate transaction between Customer and End-Customer ledgers and settle it
    Given I create below ledgers
      | identifier | profile_id | profile_type | holding_type | initial_units   | can_be_negative   | metadata           |
      | LId1       | profile1   | CUSTOMER     | CASH-SGD     | <initial_units> | <can_be_negative> | {"key1": "value1"} |
      | LId2       | profile2   | END_CUSTOMER | CASH-SGD     | <initial_units> | <can_be_negative> | {"key2": "value2"} |

    And I initiate ledger transaction
      | identifier | from_ledger_id   | to_ledger_id   | units   | source_rate_per_unit | destination_rate_per_unit | status   | external_transaction_id | reference_data        |
      | TxId1      | <from_ledger_id> | <to_ledger_id> | <units> | <units>              | <units>                   | <status> | ExternalTxId            | Sample reference data |

    And I verify transaction entry exist for transaction TxId1
      | from_ledger_id   | to_ledger_id   | units   | source_rate_per_unit | destination_rate_per_unit | transaction_status | external_transaction_id | reference_data        |
      | <from_ledger_id> | <to_ledger_id> | <units> | <units>              | <units>                   | <status>           | ExternalTxId            | Sample reference data |

    And I verify for ledger LId1 total balance is <t_bal1> and available balance is <a_bal1>

    And I verify for ledger LId2 total balance is <t_bal2> and available balance is <a_bal2>

    Then I update ledger transaction status as SETTLED for TxId1

    And I verify transaction entry exist for transaction TxId1
      | from_ledger_id   | to_ledger_id   | units   | source_rate_per_unit | destination_rate_per_unit | transaction_status | external_transaction_id | reference_data        |
      | <from_ledger_id> | <to_ledger_id> | <units> | <units>              | <units>                   | SETTLED            | ExternalTxId            | Sample reference data |

    And I verify for ledger LId1 total balance is <t_bal3> and available balance is <a_bal3>

    And I verify for ledger LId2 total balance is <t_bal4> and available balance is <a_bal4>

    Examples:
      | initial_units | can_be_negative | from_ledger_id | to_ledger_id | units  | status  | t_bal1 | a_bal1  | t_bal2   | a_bal2 | t_bal3  | a_bal3  | t_bal4   | a_bal4   |
      | 100           | false           | LId1           | LId2         | 100    | PENDING | 100    | 0       | 200      | 100    | 0       | 0       | 200      | 200      |
      | 1000          | false           | LId1           | LId2         | 40.242 | PENDING | 1000   | 959.758 | 1040.242 | 1000   | 959.758 | 959.758 | 1040.242 | 1040.242 |
      | 10            | false           | LId1           | LId2         | 9.793  | CREATED | 10     | 0.207   | 19.793   | 10     | 0.207   | 0.207   | 19.793   | 19.793   |
      | 3.391         | true            | LId1           | LId2         | 0.019  | PENDING | 3.391  | 3.372   | 3.41     | 3.391  | 3.372   | 3.372   | 3.41     | 3.41     |
      | 3.391         | true            | LId1           | LId2         | 12.32  | CREATED | 3.391  | -8.929  | 15.711   | 3.391  | -8.929  | -8.929  | 15.711   | 15.711   |


  Scenario Outline: Initiate transaction and verify Avg Source and Destination rates are updated with some initial units
    Given I create below ledgers
      | identifier | profile_id | profile_type | holding_type | initial_units   | can_be_negative   | metadata           |
      | LId1       | profile1   | CUSTOMER     | CASH-SGD     | <initial_units> | <can_be_negative> | {"key1": "value1"} |
      | LId2       | profile2   | END_CUSTOMER | CASH-SGD     | <initial_units> | <can_be_negative> | {"key2": "value2"} |

    And I initiate ledger transaction
      | identifier | from_ledger_id   | to_ledger_id   | units | source_rate_per_unit | destination_rate_per_unit | status   | external_transaction_id | reference_data        |
      | TxId1      | <from_ledger_id> | <to_ledger_id> | 25    | 2                    | 4                         | <status> | ExternalTxId            | Sample reference data |

    And I verify transaction entry exist for transaction TxId1
      | from_ledger_id   | to_ledger_id   | units | source_rate_per_unit | destination_rate_per_unit | transaction_status | external_transaction_id | reference_data        |
      | <from_ledger_id> | <to_ledger_id> | 25    | 2                    | 4                         | <status>           | ExternalTxId            | Sample reference data |

    And I verify ledger LId1 total balance is <t_bal1> and available balance is <a_bal1> and avg source rate per unit is <a_src1> and avg destination rate per unit is <a_des1>

    And I verify ledger LId2 total balance is <t_bal2> and available balance is <a_bal2> and avg source rate per unit is <a_src2> and avg destination rate per unit is <a_des2>

    And I initiate ledger transaction
      | identifier | from_ledger_id   | to_ledger_id   | units | source_rate_per_unit | destination_rate_per_unit | status   | external_transaction_id | reference_data        |
      | TxId2      | <from_ledger_id> | <to_ledger_id> | 50    | 4                    | 16                        | <status> | ExternalTxId            | Sample reference data |

    And I verify transaction entry exist for transaction TxId2
      | from_ledger_id   | to_ledger_id   | units | source_rate_per_unit | destination_rate_per_unit | transaction_status | external_transaction_id | reference_data        |
      | <from_ledger_id> | <to_ledger_id> | 50    | 4                    | 16                        | <status>           | ExternalTxId            | Sample reference data |

    And I verify ledger LId1 total balance is <t_bal3> and available balance is <a_bal3> and avg source rate per unit is <a_src3> and avg destination rate per unit is <a_des3>

    And I verify ledger LId2 total balance is <t_bal4> and available balance is <a_bal4> and avg source rate per unit is <a_src4> and avg destination rate per unit is <a_des4>

    And I initiate ledger transaction
      | identifier | from_ledger_id | to_ledger_id     | units | source_rate_per_unit | destination_rate_per_unit | status   | external_transaction_id | reference_data        |
      | TxId3      | <to_ledger_id> | <from_ledger_id> | 60    | 5                    | 5                         | <status> | ExternalTxId            | Sample reference data |

    And I verify transaction entry exist for transaction TxId3
      | from_ledger_id | to_ledger_id     | units | source_rate_per_unit | destination_rate_per_unit | transaction_status | external_transaction_id | reference_data        |
      | <to_ledger_id> | <from_ledger_id> | 60    | 5                    | 5                         | <status>           | ExternalTxId            | Sample reference data |

    And I verify ledger LId1 total balance is <t_bal5> and available balance is <a_bal5> and avg source rate per unit is <a_src5> and avg destination rate per unit is <a_des5>

    And I verify ledger LId2 total balance is <t_bal6> and available balance is <a_bal6> and avg source rate per unit is <a_src6> and avg destination rate per unit is <a_des6>

    Examples:
      | initial_units | can_be_negative | from_ledger_id | to_ledger_id | status  | t_bal1  | a_bal1  | t_bal2  | a_bal2  | t_bal3  | a_bal3  | t_bal4  | a_bal4  | t_bal5  | a_bal5  | t_bal6  | a_bal6  | a_src1 | a_des1 | a_src2 | a_des2 | a_src3 | a_des3 | a_src4 | a_des4 | a_src5 | a_des5 | a_src6 | a_des6 |
      | 150           | true            | LId1           | LId2         | SETTLED | 125     | 125     | 175     | 175     | 75      | 75      | 225     | 225     | 135     | 135     | 165     | 165     | 1      | 1      | 1.1429 | 1.4286 | 1      | 1      | 1.7778 | 4.6667 | 2.7778 | 2.7778 | 1.7778 | 4.6667 |
      | 435.619       | false           | LId1           | LId2         | SETTLED | 410.619 | 410.619 | 460.619 | 460.619 | 360.619 | 360.619 | 510.619 | 510.619 | 420.619 | 420.619 | 450.619 | 450.619 | 1      | 1      | 1.0543 | 1.1628 | 1      | 1      | 1.3427 | 2.6157 | 1.5706 | 1.5706 | 1.3427 | 2.6157 |

  Scenario Outline: Initiate transaction and verify Avg Source and Destination rates are updated with initial units are Zero
    Given I create below ledgers
      | identifier | profile_id | profile_type | holding_type | initial_units | can_be_negative   | metadata           |
      | LId1       | profile1   | CUSTOMER     | CASH-SGD     | 0             | <can_be_negative> | {"key1": "value1"} |
      | LId2       | profile2   | END_CUSTOMER | CASH-SGD     | 0             | <can_be_negative> | {"key2": "value2"} |

    And I initiate ledger transaction
      | identifier | from_ledger_id   | to_ledger_id   | units | source_rate_per_unit | destination_rate_per_unit | status   | external_transaction_id | reference_data        |
      | TxId1      | <from_ledger_id> | <to_ledger_id> | 25    | 2                    | 4                         | <status> | ExternalTxId            | Sample reference data |

    And I verify transaction entry exist for transaction TxId1
      | from_ledger_id   | to_ledger_id   | units | source_rate_per_unit | destination_rate_per_unit | transaction_status | external_transaction_id | reference_data        |
      | <from_ledger_id> | <to_ledger_id> | 25    | 2                    | 4                         | <status>           | ExternalTxId            | Sample reference data |

    And I verify ledger LId1 total balance is <t_bal1> and available balance is <a_bal1> and avg source rate per unit is <a_src1> and avg destination rate per unit is <a_des1>

    And I verify ledger LId2 total balance is <t_bal2> and available balance is <a_bal2> and avg source rate per unit is <a_src2> and avg destination rate per unit is <a_des2>

    And I initiate ledger transaction
      | identifier | from_ledger_id   | to_ledger_id   | units | source_rate_per_unit | destination_rate_per_unit | status   | external_transaction_id | reference_data        |
      | TxId2      | <from_ledger_id> | <to_ledger_id> | 50    | 4                    | 16                        | <status> | ExternalTxId            | Sample reference data |

    And I verify transaction entry exist for transaction TxId2
      | from_ledger_id   | to_ledger_id   | units | source_rate_per_unit | destination_rate_per_unit | transaction_status | external_transaction_id | reference_data        |
      | <from_ledger_id> | <to_ledger_id> | 50    | 4                    | 16                        | <status>           | ExternalTxId            | Sample reference data |

    And I verify ledger LId1 total balance is <t_bal3> and available balance is <a_bal3> and avg source rate per unit is <a_src3> and avg destination rate per unit is <a_des3>

    And I verify ledger LId2 total balance is <t_bal4> and available balance is <a_bal4> and avg source rate per unit is <a_src4> and avg destination rate per unit is <a_des4>

    And I initiate ledger transaction
      | identifier | from_ledger_id | to_ledger_id     | units | source_rate_per_unit | destination_rate_per_unit | status   | external_transaction_id | reference_data        |
      | TxId3      | <to_ledger_id> | <from_ledger_id> | 60    | 5                    | 5                         | <status> | ExternalTxId            | Sample reference data |

    And I verify transaction entry exist for transaction TxId3
      | from_ledger_id | to_ledger_id     | units | source_rate_per_unit | destination_rate_per_unit | transaction_status | external_transaction_id | reference_data        |
      | <to_ledger_id> | <from_ledger_id> | 60    | 5                    | 5                         | <status>           | ExternalTxId            | Sample reference data |

    And I verify ledger LId1 total balance is <t_bal5> and available balance is <a_bal5> and avg source rate per unit is <a_src5> and avg destination rate per unit is <a_des5>

    And I verify ledger LId2 total balance is <t_bal6> and available balance is <a_bal6> and avg source rate per unit is <a_src6> and avg destination rate per unit is <a_des6>

    Examples:
      | can_be_negative | from_ledger_id | to_ledger_id | status  | t_bal1 | a_bal1 | t_bal2 | a_bal2 | t_bal3 | a_bal3 | t_bal4 | a_bal4 | t_bal5 | a_bal5 | t_bal6 | a_bal6 | a_src1 | a_des1 | a_src2 | a_des2 | a_src3 | a_des3 | a_src4 | a_des4 | a_src5 | a_des5 | a_src6 | a_des6 |
      | true            | LId1           | LId2         | SETTLED | -25    | -25    | 25     | 25     | -75    | -75    | 75     | 75     | -15    | -15    | 15     | 15     | 2      | 4      | 2      | 4      | 3.3333 | 12     | 3.3333 | 12     | 3.3333 | 12     | 3.3333 | 12     |

  Scenario Outline: Create ledgers and initiate transaction between them and verify the default reference data
    Given I create below ledgers
      | identifier | profile_id | profile_type | holding_type | initial_units   | can_be_negative   | metadata           |
      | LId1       | profile1   | END_CUSTOMER | CASH-SGD     | <initial_units> | <can_be_negative> | {"key1": "value1"} |
      | LId2       | profile2   | END_CUSTOMER | CASH-SGD     | <initial_units> | <can_be_negative> | {"key2": "value2"} |

    And I initiate ledger transaction
      | identifier | from_ledger_id   | to_ledger_id   | units   | source_rate_per_unit | destination_rate_per_unit | status   | external_transaction_id |
      | TxId1      | <from_ledger_id> | <to_ledger_id> | <units> | <units>              | <units>                   | <status> | ExternalTxId            |

    Then I verify transaction entry exist for transaction TxId1
      | from_ledger_id   | to_ledger_id   | units   | source_rate_per_unit | destination_rate_per_unit | transaction_status | external_transaction_id | reference_data |
      | <from_ledger_id> | <to_ledger_id> | <units> | <units>              | <units>                   | <status>           | ExternalTxId            |                |

    Examples:
      | initial_units | can_be_negative | from_ledger_id | to_ledger_id | units | status  |
      | 100           | false           | LId1           | LId2         | 100   | SETTLED |

  Scenario Outline: Create ledgers and initiate transaction between them and split transaction and verify if it is split successfully
    Given I create below ledgers
      | identifier | profile_id | profile_type | holding_type | initial_units   | can_be_negative   | metadata           |
      | LId1       | profile1   | END_CUSTOMER | CASH-SGD     | <initial_units> | <can_be_negative> | {"key1": "value1"} |
      | LId2       | profile2   | END_CUSTOMER | CASH-SGD     | <initial_units> | <can_be_negative> | {"key2": "value2"} |

    And I initiate ledger transaction
      | identifier | from_ledger_id   | to_ledger_id   | units   | source_rate_per_unit | destination_rate_per_unit | status   | external_transaction_id |
      | TxId1      | <from_ledger_id> | <to_ledger_id> | <units> | <units>              | <units>                   | <status> | ExternalTxId            |

    Then I verify transaction entry exist for transaction TxId1
      | from_ledger_id   | to_ledger_id   | units   | source_rate_per_unit | destination_rate_per_unit | transaction_status | external_transaction_id | reference_data |
      | <from_ledger_id> | <to_ledger_id> | <units> | <units>              | <units>                   | <status>           | ExternalTxId            |                |

    And I split transaction for TxId1 and verify it is split successfully
      | transaction_id | original_amount | split_txn                                   | idempotency |
      | TxId           | <units>         | {"amount": "<amount>", "status": "CREATED"} |             |
    # Sending Dummy transaction_id which will be replaced by actual ones later

    Examples:
      | initial_units | can_be_negative | from_ledger_id | to_ledger_id | units  | amount | status  |
      | 100           | true            | LId1           | LId2         | 50     | 15.0   | CREATED |
      | 100           | false           | LId1           | LId2         | 100    | 25.0   | CREATED |
      | 47.28         | true            | LId1           | LId2         | 1.321  | 1.320  | CREATED |
      | 214.113       | false           | LId1           | LId2         | 23.219 | 4.249  | CREATED |

  Scenario Outline: Create ledgers and initiate transaction between them and update transaction and verify if it is updated successfully
    Given I create below ledgers
      | identifier | profile_id | profile_type | holding_type | initial_units   | can_be_negative   | metadata           |
      | LId1       | profile1   | END_CUSTOMER | CASH-SGD     | <initial_units> | <can_be_negative> | {"key1": "value1"} |
      | LId2       | profile2   | END_CUSTOMER | CASH-SGD     | <initial_units> | <can_be_negative> | {"key2": "value2"} |

    And I initiate ledger transaction
      | identifier | from_ledger_id   | to_ledger_id   | units   | source_rate_per_unit | destination_rate_per_unit | status   | external_transaction_id |
      | TxId1      | <from_ledger_id> | <to_ledger_id> | <units> | <units>              | <units>                   | <status> | ExternalTxId            |

    Then I verify transaction entry exist for transaction TxId1
      | from_ledger_id   | to_ledger_id   | units   | source_rate_per_unit | destination_rate_per_unit | transaction_status | external_transaction_id | reference_data |
      | <from_ledger_id> | <to_ledger_id> | <units> | <units>              | <units>                   | <status>           | ExternalTxId            |                |

    And I update transaction for TxId1 and verify it is updated successfully
      | transaction_id | update_amount   | external_transaction_id | acquire_available_balance   | status   |
      | TxId1          | <update_amount> | ExternalTxId            | <acquire_available_balance> | <status> |

    Examples:
      | initial_units | can_be_negative | from_ledger_id | to_ledger_id | units  | update_amount | status  | acquire_available_balance |
      | 100           | true            | LId1           | LId2         | 100    | 120.0         | CREATED | true                      |
      | 100           | false           | LId1           | LId2         | 100    | 80.0          | CREATED | true                      |
      | 0.22          | false           | LId1           | LId2         | 0.009  | 0.199         | PENDING | true                      |
      | 31.253        | false           | LId1           | LId2         | 8.75   | 31.250        | CREATED | true                      |
      | 989.34        | false           | LId1           | LId2         | 21.549 | 609.34        | PENDING | true                      |
      | 4.21          | false           | LId1           | LId2         | 2.924  | 0             | CREATED | true                      |

  Scenario Outline: Create ledgers and initiate transaction between them and update transaction and verify failure
    Given I create below ledgers
      | identifier | profile_id | profile_type | holding_type | initial_units   | can_be_negative   | metadata           |
      | LId1       | profile1   | END_CUSTOMER | CASH-SGD     | <initial_units> | <can_be_negative> | {"key1": "value1"} |
      | LId2       | profile2   | END_CUSTOMER | CASH-SGD     | <initial_units> | <can_be_negative> | {"key2": "value2"} |

    And I initiate ledger transaction
      | identifier | from_ledger_id   | to_ledger_id   | units   | source_rate_per_unit | destination_rate_per_unit | status   | external_transaction_id |
      | TxId1      | <from_ledger_id> | <to_ledger_id> | <units> | 1.00                 | 1.00                      | <status> | ExternalTxId            |

    Then I verify transaction entry exist for transaction TxId1
      | from_ledger_id   | to_ledger_id   | units   | source_rate_per_unit | destination_rate_per_unit | transaction_status | external_transaction_id | reference_data |
      | <from_ledger_id> | <to_ledger_id> | <units> | 1.00                 | 1.00                      | <status>           | ExternalTxId            |                |

    And I update transaction for TxId1 and verify failure
      | transaction_id | update_amount   | external_transaction_id | acquire_available_balance   | status   |
      | TxId1          | <update_amount> | ExternalTxId            | <acquire_available_balance> | <status> |

    Examples:
      | initial_units | can_be_negative | from_ledger_id | to_ledger_id | units | update_amount | status  | acquire_available_balance |
      | 100           | false           | LId1           | LId2         | 100   | 120.0         | CREATED | false                     |

  Scenario Outline: Create ledgers and initiate transaction between them and merge transaction and verify if it is merge successfully
    Given I create below ledgers
      | identifier | profile_id | profile_type | holding_type | initial_units   | can_be_negative   | metadata           |
      | LId1       | profile1   | END_CUSTOMER | CASH-SGD     | <initial_units> | <can_be_negative> | {"key1": "value1"} |
      | LId2       | profile2   | END_CUSTOMER | CASH-SGD     | <initial_units> | <can_be_negative> | {"key2": "value2"} |

    And I initiate ledger transaction
      | identifier | from_ledger_id   | to_ledger_id   | units       | source_rate_per_unit | destination_rate_per_unit | status   | external_transaction_id |
      | TxId1      | <from_ledger_id> | <to_ledger_id> | <units_tx1> | <units_tx1>          | <units_tx1>               | <status> | ExternalTxId            |

    Then I verify transaction entry exist for transaction TxId1
      | from_ledger_id   | to_ledger_id   | units       | source_rate_per_unit | destination_rate_per_unit | transaction_status | external_transaction_id | reference_data |
      | <from_ledger_id> | <to_ledger_id> | <units_tx1> | <units_tx1>          | <units_tx1>               | <status>           | ExternalTxId            |                |

    And I initiate ledger transaction
      | identifier | from_ledger_id   | to_ledger_id   | units       | source_rate_per_unit | destination_rate_per_unit | status   | external_transaction_id |
      | TxId2      | <from_ledger_id> | <to_ledger_id> | <units_tx2> | <units_tx2>          | <units_tx2>               | <status> | ExternalTxId            |

    Then I verify transaction entry exist for transaction TxId2
      | from_ledger_id   | to_ledger_id   | units       | source_rate_per_unit | destination_rate_per_unit | transaction_status | external_transaction_id | reference_data |
      | <from_ledger_id> | <to_ledger_id> | <units_tx2> | <units_tx2>          | <units_tx2>               | <status>           | ExternalTxId            |                |

    And I merge transactions TxId1 and TxId2 and verify new merged transaction status as CREATED
      | transaction_id | external_transaction_id |
      |                | ExternalTxId            |

    Then I verify transaction entry exist for transaction TxId1
      | from_ledger_id   | to_ledger_id   | units       | source_rate_per_unit | destination_rate_per_unit | transaction_status | external_transaction_id | reference_data |
      | <from_ledger_id> | <to_ledger_id> | <units_tx1> | <units_tx1>          | <units_tx1>               | REVERT_MERGE       | ExternalTxId            |                |
    Then I verify transaction entry exist for transaction TxId2
      | from_ledger_id   | to_ledger_id   | units       | source_rate_per_unit | destination_rate_per_unit | transaction_status | external_transaction_id | reference_data |
      | <from_ledger_id> | <to_ledger_id> | <units_tx2> | <units_tx2>          | <units_tx2>               | REVERT_MERGE       | ExternalTxId            |                |

    Examples:
      | initial_units | can_be_negative | from_ledger_id | to_ledger_id | units_tx1 | status             | units_tx2 |
      | 100           | true            | LId1           | LId2         | 50.223    | CREATED            | 32        |
      | 113           | false           | LId1           | LId2         | 100       | PENDING            | 13        |
      | 100           | true            | LId2           | LId1         | 13.41     | PENDING_SETTLEMENT | 1.432     |
      | 235           | false           | LId1           | LId2         | 0.203     | CREATED            | 231.243   |

  Scenario Outline: Create ledgers and initiate transaction and merge with incorrect status and verify failure
    Given I create below ledgers
      | identifier | profile_id | profile_type | holding_type | initial_units   | can_be_negative   | metadata           |
      | LId1       | profile1   | END_CUSTOMER | CASH-SGD     | <initial_units> | <can_be_negative> | {"key1": "value1"} |
      | LId2       | profile2   | END_CUSTOMER | CASH-SGD     | <initial_units> | <can_be_negative> | {"key2": "value2"} |

    And I initiate ledger transaction
      | identifier | from_ledger_id   | to_ledger_id   | units       | source_rate_per_unit | destination_rate_per_unit | status   | external_transaction_id |
      | TxId1      | <from_ledger_id> | <to_ledger_id> | <units_tx1> | <units_tx1>          | <units_tx1>               | <status> | ExternalTxId            |

    Then I verify transaction entry exist for transaction TxId1
      | from_ledger_id   | to_ledger_id   | units       | source_rate_per_unit | destination_rate_per_unit | transaction_status | external_transaction_id | reference_data |
      | <from_ledger_id> | <to_ledger_id> | <units_tx1> | <units_tx1>          | <units_tx1>               | <status>           | ExternalTxId            |                |

    And I initiate ledger transaction
      | identifier | from_ledger_id   | to_ledger_id   | units       | source_rate_per_unit | destination_rate_per_unit | status   | external_transaction_id |
      | TxId2      | <from_ledger_id> | <to_ledger_id> | <units_tx2> | <units_tx2>          | <units_tx2>               | <status> | ExternalTxId            |

    Then I verify transaction entry exist for transaction TxId2
      | from_ledger_id   | to_ledger_id   | units       | source_rate_per_unit | destination_rate_per_unit | transaction_status | external_transaction_id | reference_data |
      | <from_ledger_id> | <to_ledger_id> | <units_tx2> | <units_tx2>          | <units_tx2>               | <status>           | ExternalTxId            |                |

    And I merge transactions TxId1 and TxId2 and verify status as E9400
      | transaction_id | external_transaction_id |
      |                | ExternalTxId            |
    Examples:
      | initial_units | can_be_negative | from_ledger_id | to_ledger_id | units_tx1 | status        | units_tx2 |
      | 100           | true            | LId1           | LId2         | 50.223    | SETTLED       | 32        |
      | 115           | false           | LId1           | LId2         | 97        | SETTLED       | 16        |
      | 100           | true            | LId2           | LId1         | 13.41     | REVERT_SPLIT  | 1.432     |
      | 235           | false           | LId1           | LId2         | 0.203     | REVERT_UPDATE | 231.243   |
      | 265           | false           | LId1           | LId2         | 24.239    | REVERT_MERGE  | 231.243   |
