Feature: Change Passcode

  Background: Create a new User Account

    Given The user UID1 provides a valid mobile number
      | mobile_number | ph_prefix |
      | random        | +373      |

    Then The user UID1 submits OTP to proceed with verification

    Given I open a new user account
      | user_profile_identifier | email          | legal_name  | name   | account_type |
      | UID1                    | test@gmail.com |  John Doe   | Johnny | PERSONAL     |

    When I initiate the initial onboarding for the user UID1

    Then I submit the initial onboarding for UID1

    And I check the status of initial onboarding for UID1

  Scenario: Change Passcode

    Then I Initiate forgot passcode for user UID1

    And I start a passcode reset OTP Journey for UID1

    And I submit a passcode reset OTP Journey for UID1

    And I submit the forgot passcode of user UID1

    And I get the forgot password token of user UID1

    And I update the password for user UID1
