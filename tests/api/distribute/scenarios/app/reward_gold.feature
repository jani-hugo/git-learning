Feature: Reward Gold

  Scenario: Reward gold for user

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

    And I check if GOLD_VAULT is created for user UID1

    And I deposit 25 SGD in hugosave account type TREASURY

    Then I reward gold worth 20 SGD for user UID1

    Then I check the balance of GOLD Map of user UID1 to be 20
