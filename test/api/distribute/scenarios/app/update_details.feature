Feature: Update User Details

  Background:
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

    And I get user details for user UID1

  Scenario: Update Details

    Then I update first_name of user UID1 and check if updated correctly

    Then I update last_name of user UID1 and check if updated correctly

    Then I update nationality of user UID1 and check if updated correctly

    Then I update address of user UID1 and check if updated correctly

    Then I update dob of user UID1 and check if updated correctly

    Then I update dob,nationality of user UID1 and check if updated correctly

    Then I update first_name,last_name of user UID1 and check if updated correctly

    Then I update first_name,last_name,dob,nationality,address of user UID1 and check if updated correctly

    Then I update client_flags of user UID1 and check if updated correctly
