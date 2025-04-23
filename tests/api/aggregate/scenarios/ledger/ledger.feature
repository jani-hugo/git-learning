Feature: Ledger service's ledger scenarios

  Scenario Outline: Create ledger and verify it's created successfully
    Given I create below ledgers
      | identifier | profile_id   | profile_type   | holding_type   | initial_units   | can_be_negative   | metadata   |
      | LId1       | <profile_id> | <profile_type> | <holding_type> | <initial_units> | <can_be_negative> | <metadata> |

    Then I verify ledgers exist with values
      | identifier | profile_id   | profile_type   | holding_type   | total_units     | available_units | avg_source_rate_per_unit | avg_destination_rate_per_unit | can_be_negative   | metadata   |
      | LId1       | <profile_id> | <profile_type> | <holding_type> | <initial_units> | <initial_units> | 1                        | 1                             | <can_be_negative> | <metadata> |

    Examples:
      | profile_id | profile_type | holding_type | initial_units | can_be_negative | metadata           |
      | profile1   | CUSTOMER     | CASH-SGD     | 2             | true            | {"key1": "value1"} |
      | profile2   | CUSTOMER     | CASH-SGD     | 0             | false           | {"key2": "value2"} |
      | profile2   | END_CUSTOMER | CASH-SGD     | 100           | false           | {"key3": "value3"} |


  Scenario Outline: Create ledger and delete it
    Given I create below ledgers
      | identifier | profile_id   | profile_type   | holding_type   | initial_units   | can_be_negative   | metadata   |
      | LId1       | <profile_id> | <profile_type> | <holding_type> | <initial_units> | <can_be_negative> | <metadata> |
      | LId2       | <profile_id> | <profile_type> | <holding_type> | <initial_units> | <can_be_negative> | <metadata> |

    And I delete the above created ledger
      | identifier |
      | LId1       |

    And I verify ledger doesn't exist
      | identifier |
      | LId1       |

    Then I verify ledgers exist with values
      | identifier | profile_id   | profile_type   | holding_type   | total_units     | available_units | avg_source_rate_per_unit | avg_destination_rate_per_unit | can_be_negative   | metadata   |
      | LId2       | <profile_id> | <profile_type> | <holding_type> | <initial_units> | <initial_units> | 1                        | 1                             | <can_be_negative> | <metadata> |

    Examples:
      | profile_id | profile_type | holding_type | initial_units | can_be_negative | metadata           |
      | profile1   | CUSTOMER     | CASH-SGD     | 0             | true            | {"key1": "value1"} |
      | profile2   | END_CUSTOMER | CASH-SGD     | 0             | true            | {"key2": "value2"} |
      | profile1   | CUSTOMER     | CASH-SGD     | -100.0        | true            | {"key3": "value3"} |
      | profile2   | END_CUSTOMER | CASH-SGD     | 100           | false           | {"key4": "value4"} |


  Scenario Outline: Create ledger with invalid datatype and verify failure
    Given I attempt to create ledger with invalid datatype and verify create failed
      | identifier | profile_id   | profile_type   | holding_type   | initial_units   | can_be_negative   | metadata   |
      | LId1       | <profile_id> | <profile_type> | <holding_type> | <initial_units> | <can_be_negative> | <metadata> |

    Examples:
      | profile_id | profile_type     | holding_type     | initial_units | can_be_negative | metadata |
      |            |                  |                  |               |                 |          |
      | profile2   | someGarbageValue | SomeGarbageValue | String        | Yesn't          | true     |


  Scenario Outline: Create ledger with incorrect data and verify failure
    Given I attempt to create ledger with incorrect data and verify create failed
      | identifier | profile_id   | profile_type   | holding_type   | initial_units   | can_be_negative   | metadata   |
      | LId1       | <profile_id> | <profile_type> | <holding_type> | <initial_units> | <can_be_negative> | <metadata> |

    Examples:
      | profile_id | profile_type | holding_type | initial_units | can_be_negative | metadata           |
      | profile1   | CUSTOMER     | CASH-SGD     | -100.0        | false           | {"key1": "value1"} |
