Feature: COS service's customer profile scenarios

  Scenario Outline: Create and delete Customer-Profile in cos
    Given I onboard below Customer-Profile onto COS
      | customer_id | customer_profile_id |  status_code |
      | Cid1        | CPid1               |  200         |
    Examples:
      |   |
      |   |
