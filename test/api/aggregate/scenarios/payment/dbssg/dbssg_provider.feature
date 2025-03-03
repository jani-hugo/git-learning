Feature: Payment Service Provider APIs for DBSSG

  Scenario Outline: To fetch providers list in SG
    Then I retrieve providers supporting for region <region> from <request_origin> and expect the header status <status_code> and fetch provider <provider_id>
    Examples:
      | region | request_origin | status_code | provider_id |
      | SG     | CASH_SERVICE   | 200         | DBS-SG      |

  Scenario Outline: To fetch transaction modes supported by provider
    Then I retrieve transaction modes supported by provider <provider_id> from <request_origin> and expect the header status <status_code> and check if txn mode <txn_mode> supported by provider
    Examples:
      | request_origin | status_code | provider_id | txn_mode |
      | CASH_SERVICE   | 200         | DBS-SG      | FAST     |
