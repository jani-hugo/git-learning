Feature: CMS service's End Customer Profile scenarios


  Background: Set Customer Profile and Create End Customer Profile

    Given I set and verify customer Cid1, customer profile CPid1 in the context

    Given I onboard HUGOHUB Customer Profile for CMS and verify onboard status as ONBOARD_SUCCESS

    Then I onboard Customer Profile Cid1 to CMS and verify onboard status as ONBOARD_SUCCESS

    Then I create below End-Customer-Profile
      | customer_identifier | customer_profile_identifier | end_customer_profile_identifier | first_name | last_name | region | email         | phone_number   |
      | Cid1                | CPid1                       | ECPid1                          | John       | Snow      | SG     | john@snow.com | +63 1234567890 |

    Then I verify End-Customer-Profile exist with values
      | customer_profile_identifier | end_customer_profile_identifier | first_name | last_name | email         | phone_number   | status |
      | CPid1                       | ECPid1                          | John       | Snow      | john@snow.com | +63 1234567890 | ACTIVE |

  Scenario: Successful Onboarding of End Customer Profile

    Then I onboard End Customer Profile ECPid1 to CMS and verify onboard status as ONBOARD_SUCCESS and status code as 200

  Scenario: Attempting to onboard an invalid end customer

    Then I onboard End Customer Profile ECPid2 to CMS and verify onboard status as ONBOARD_FAILED and status code as CMSM_9622
