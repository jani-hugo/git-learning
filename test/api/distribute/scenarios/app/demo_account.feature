Feature: Demo Account Features

  Scenario: Open Demo User Account for PK
    Given I open user account
      | user_profile_identifier | phone_number | email          | legal_name | status              | org_id      |
      | UID1                    | random       | test@gmail.com | John Doe   | PROFILE_IN_PROGRESS | HUGOBANK_PK |

    Then I check account status
      | user_profile_identifier | status         |
      | UID1                    | PROFILE_ACTIVE |

    Then I check if demo user UID1 account type is PREMIUM

  Scenario: Order Card Demo User Account for PK
    Given I open user account
      | user_profile_identifier | phone_number | email          | legal_name | status              | org_id      |
      | UID1                    | random       | test@gmail.com | John Doe   | PROFILE_IN_PROGRESS | HUGOBANK_PK |

    Then I check account status
      | user_profile_identifier | status         |
      | UID1                    | PROFILE_ACTIVE |

    Then I check if demo user UID1 account type is PREMIUM
    Given I deposit 50 SGD into account subtype HUGO_CASH of user UID1

    Then I order card for UID1 with card name as random_valid_choice with status 200

    Then I wait for card status as CARD_STATUS_INACTIVE for user UID1, activate with valid token, with status 200

    Then I check card status is CARD_STATUS_ACTIVE for user UID1

    And I check the balance of account subtype HUGO_CASH of user UID1 is 50 SGD exact

    And I ENABLE roundups for user UID1

# 1. INC_AUTH WITH RU
    Given I create below transaction for user profile id and verify 200
      | user_profile_identifier | transaction_permutation_name | billing_amount | is_foreign_txn |
      | UID1                    | INC_AUTH                     | 0.937          | false          |
    Then I check the balance of account subtype HUGO_CASH of user UID1 is 49.06 SGD approx
    Then I check the balance of account subtype HUGO_ROUNDUP of user UID1 is 0 SGD approx
# 2. AUTH_CLEAR with RU
    Given I create below transaction for user profile id and verify 200
      | user_profile_identifier | transaction_permutation_name | billing_amount | is_foreign_txn |
      | UID1                    | AUTH_CLEAR                   | 5.5            | false          |
    Then I check intent type CARD_TRANSACTION with status SETTLED and total 2 intents exist in card view for user UID1
    And I check the balance of account subtype HUGO_CASH of user UID1 is 43.06 SGD approx
    And I check the balance of account subtype HUGO_ROUNDUP of user UID1 is 0.5 SGD approx
