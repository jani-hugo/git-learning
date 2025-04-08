Feature: Update Passcode

  Background: Open Hugosave Account
    Given The user UID1 provides a valid mobile number
      | mobile_number | ph_prefix |
      | random        | +65       |
    Then The user UID1 submits OTP to proceed with verification

    Given I open a new user account
      | user_profile_identifier | email          | legal_name  | name   | account_type |
      | UID1                    | test@gmail.com |  John Doe   | Johnny | PERSONAL     |

    When I initiate the initial onboarding for the user UID1

    Then I submit the initial onboarding for UID1

    And I check the status of initial onboarding for UID1

    When I initiate progress onboarding for the user UID1 to upgrade account to PREMIUM

    When I initiate HUGOSAVE_TRUST for the user UID1 and expect a status code of 200

    And I submit HUGOSAVE_TRUST for the user UID1 and expect a status code of 200

    Then I check status of HUGOSAVE_TRUST for the user UID1

    When I initiate HUGOSAVE_SELFIE_AND_SCAN_ID for the user UID1 and expect a status code of 200

    And I upload document FRONT for the user UID1

    And I upload document BACK for the user UID1

    And I upload document SELFIE for the user UID1

    Then I submit HUGOSAVE_SELFIE_AND_SCAN_ID for the user UID1 so we can convert the account to PREMIUM

    And I check the status of HUGOSAVE_SELFIE_AND_SCAN_ID for the user UID1

    Then I submit the progress onboarding for user UID1

    And I check progress onboarding status for the user UID1

    Then I upgrade the user UID1 account level to L3

    And I check the user details to confirm if user UID1 is premium

    Then I initiate the initial user authorisation token for UPDATE_PASSCODE of user UID1

    Then I initiate the final user authorisation token for UPDATE_PASSCODE of user UID1

    And I submit the final user authorisation for UPDATE_PASSCODE of user UID1

    And I get the final user authorisation token for UPDATE_PASSCODE of user UID1

    Scenario: Update Passcode

      Then I update passcode of user UID1
