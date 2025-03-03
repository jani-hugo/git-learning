Feature: Update User Details

  Background:
    Given I open user account
      | user_profile_identifier | phone_number | email          | legal_name | status              |
      | UID1                    | random       | test@gmail.com | John Doe   | PROFILE_IN_PROGRESS |

    Then I check account status
      | user_profile_identifier | status         |
      | UID1                    | PROFILE_ACTIVE |

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
