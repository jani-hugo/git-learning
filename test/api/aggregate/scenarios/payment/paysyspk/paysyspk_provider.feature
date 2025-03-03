Feature: Payment Service Provider APIs for PaysysPK

  Scenario Outline: To fetch providers list in PK
    Then I retrieve providers supporting for region <region> from <request_origin> and expect the header status <status_code> and fetch provider <provider_id>
    Examples:
      | region | request_origin | status_code | provider_id |
      | PK     | CASH_SERVICE   | 200         | PAYSYS-PK   |

  Scenario Outline: To fetch transaction modes supported by provider
    Then I retrieve transaction modes supported by provider <provider_id> from <request_origin> and expect the header status <status_code> and check if txn mode <txn_mode> supported by provider
    Examples:
      | request_origin | status_code | provider_id | txn_mode  |
      | CASH_SERVICE   | 200         | PAYSYS-PK   | RAASTP2P  |
      | CASH_SERVICE   | 200         | PAYSYS-PK   | 1LINKIBFT |
      | CASH_SERVICE   | 200         | PAYSYS-PK   | PRISM     |
