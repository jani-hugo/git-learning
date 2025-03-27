Feature: Roundups

  Scenario: Enable Roundups, Check Schedule, Trigger Roundup Schedule
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

    Then I order card for UID1 with card name as random_valid_choice with status 200

    Then I wait for 10 seconds

    Then I wait for card status as CARD_STATUS_INACTIVE for user UID1, activate with valid token, with status 200

    Then I check card status is CARD_STATUS_ACTIVE for user UID1

    Given I deposit 150 SGD into account subtype HUGO_CASH of user UID1

    And I check the balance of account subtype HUGO_CASH of user UID1 is 150 SGD exact

    And I deposit 50 SGD into account subtype HUGO_CARD of user UID1

    Given I ENABLE roundups for user UID1

    Given I create below transaction for user profile id and verify 200
      | user_profile_identifier | transaction_permutation_name | billing_amount | is_foreign_txn |
      | UID1                    | AUTH_CLEAR                   | 2.1            | false          |

    And I check the balance of account subtype roundup of user UID1 is 0.9 SGD exact

    And I check the balance of account subtype HUGO_CASH of user UID1 is 99.1 SGD exact

    Then I trigger schedule SCHEDULE_ROUNDUP for user UID1

    And I check the balance of account subtype roundup of user UID1 is 0 SGD exact

    Then I check the balance of GOLD Map of user UID1 to be 0.9

    Given I create below transaction for user profile id and verify 200
      | user_profile_identifier | transaction_permutation_name | billing_amount | is_foreign_txn |
      | UID1                    | AUTH_CLEAR                   | 2.1            | false          |

    And I check the balance of account subtype roundup of user UID1 is 0.9 SGD exact

    And I check the balance of account subtype HUGO_CASH of user UID1 is 98.2 SGD exact

    Given I DISABLE roundups for user UID1

    And I check the balance of account subtype HUGO_CASH of user UID1 is 99.1 SGD exact





