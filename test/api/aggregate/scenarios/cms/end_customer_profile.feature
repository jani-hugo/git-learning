Feature: CMS service's End Customer Profile scenarios

  Background: Set Customer Profile and Create End Customer Profile

    Given I set and verify customer Cid1, customer profile CPid1 in the context

    Then I create below End-Customer-Profile
      | customer_identifier | customer_profile_identifier | end_customer_profile_identifier | first_name   | last_name   | region   | email         | phone_number   |
      | Cid1                | CPid1                       | ECPid1                          | John         | Snow        | SG       | john@snow.com | +63 1234567890 |

    Then I verify End-Customer-Profile exist with values
      | customer_profile_identifier | end_customer_profile_identifier | first_name   | last_name   | email         | phone_number   | status |
      | CPid1                       | ECPid1                          |  John        | Snow        | john@snow.com | +63 1234567890 | ACTIVE |

  Scenario Outline: Onboard End Customer Profile

    Given I onboard HUGOHUB Customer Profile for CMS with <payment_provider> and verify onboard status as ONBOARD_SUCCESS

    Then I onboard Customer Profile to CMS with <payment_provider> and verify onboard status as ONBOARD_SUCCESS

    Then I onboard End Customer Profile ECPid1 to CMS with <payment_provider> and verify onboard status as ONBOARD_SUCCESS

    Examples:
      | payment_provider |
      | DBS              |
