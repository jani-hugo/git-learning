Feature: # Compliance Providers Scenarios

  Scenario Outline: # To get compliance provider by id
    Given I fetch provider with a provider id and check status
      | provider_id   | status_code   |
      | <provider_id> | <status_code> |
    Examples:
      | provider_id                          | status_code |
      | TRU-NARRATIVE                        | 200         |
      | qwrqe54                              | CSM_9100    |
      | 890e079a-rqw3r5-48d1-b285-d464       | CSM_9100    |


  Scenario Outline: # To get compliance provider be region
    Given I get providers with a provider region and check status
      | region   | status_code   |
      | <region> | <status_code> |
    Examples:
      | region | status_code |
      | SG     | 200         |
