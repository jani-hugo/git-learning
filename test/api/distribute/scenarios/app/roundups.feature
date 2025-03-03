Feature: Roundups

  Scenario: Enable Roundups, Check Schedule, Trigger Roundup Schedule
    Given I open user account
      | user_profile_identifier | phone_number | email          | legal_name | status              |
      | UID1                    | random       | test@gmail.com | John Doe   | PROFILE_IN_PROGRESS |

    Then I check account status
      | user_profile_identifier | status         |
      | UID1                    | PROFILE_ACTIVE |

    # enable roundup
    Given I ENABLE roundups for user UID1

    # deposit in roundup
    Given I deposit 20 SGD into account subtype HUGO_ROUNDUP of user UID1

    And I check the balance of account subtype HUGO_ROUNDUP of user UID1 is 20 SGD exact

    # trigger roundup schedule and check gold vault balance
    Then I trigger schedule SCHEDULE_ROUNDUP for user UID1

    Then I check the balance of GOLD Map of user UID1 to be 20

    # trigger roundup schedule with 0
    And I check the balance of account subtype HUGO_ROUNDUP of user UID1 is 0 SGD exact

    Then I trigger schedule SCHEDULE_ROUNDUP for user UID1

    Then I check the balance of GOLD Map of user UID1 to be 20

    # deposit in roundup again, disable roundup, check balance in hugo_card
    Given I deposit 6.32 SGD into account subtype HUGO_ROUNDUP of user UID1

    And I check the balance of account subtype HUGO_ROUNDUP of user UID1 is 6.32 SGD exact

    Given I DISABLE roundups for user UID1

    And I check the balance of account subtype HUGO_CASH of user UID1 is 10 SGD exact
