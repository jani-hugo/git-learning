Feature: Device Tokens

  Scenario: Device Tokens - Push, List, Delete

    Given I open user account
      | user_profile_identifier | phone_number | email          | legal_name     | status              |
      | UID1                    | random       | test@gmail.com | John Doe | PROFILE_IN_PROGRESS |

    Then I check account status
      | user_profile_identifier | status         |
      | UID1                    | PROFILE_ACTIVE |

    Then I push device tokens for user UID1 and check if saved

    Then I delete all device tokens for user UID1
