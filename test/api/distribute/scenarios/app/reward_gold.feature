Feature: Reward Gold

  Scenario: Reward gold for user

    Given I open user account
      | user_profile_identifier | phone_number | email          | legal_name     | status              |
      | UID1                    | random       | test@gmail.com | John Doe | PROFILE_IN_PROGRESS |

    Then I check account status
      | user_profile_identifier | status         |
      | UID1                    | PROFILE_ACTIVE |

    And I check if GOLD_VAULT is created for user UID1

    And I deposit 25 SGD in hugosave account type HUGOSAVE_TREASURY

    Then I reward gold worth 20 SGD for user UID1

    Then I check the balance of GOLD Map of user UID1 to be 20
