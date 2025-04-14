Feature: Card Order, Block-Unblock-Disabled, Transactions

  Background: Create a new User Account

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

  Scenario: Order Card -> Activate -> Block/Unblock -> Disable

    Then I order card for UID1 with card name as random_valid_choice with status 200

    Then I wait for 10 seconds

    Then I wait for card status as CARD_STATUS_INACTIVE for user UID1, activate with valid token, with status 200

    Then I check card status is CARD_STATUS_ACTIVE for user UID1

    Then I fetch secure card details for user UID1

    Then I update card status to BLOCK for user UID1 with status 200

    Then I check card status is CARD_STATUS_BLOCKED for user UID1

    Then I update card status to UNBLOCK for user UID1 with status 200

    Then I check card status is CARD_STATUS_ACTIVE for user UID1

    Then I update card status to DISABLE for user UID1 with status 200

    Then I check card status is CARD_STATUS_DISABLED for user UID1

  Scenario: Replace Card

    And I order card for UID1 with card name as random_valid_choice with status 200

    Then I wait for card status as CARD_STATUS_INACTIVE for user UID1, activate with valid token, with status 200

    Then I check card status is CARD_STATUS_ACTIVE for user UID1

    Then I replace card for user UID1

    Then I check old card status is CARD_STATUS_DISABLED for user UID1 and get new card id

    Then I wait for card status as CARD_STATUS_INACTIVE for user UID1, activate with valid token, with status 200

    Then I check card status is CARD_STATUS_ACTIVE for user UID1

    Then I fetch secure card details for user UID1

  Scenario: Card Auto-top-up, top-up, withdraw
    And I order card for UID1 with card name as random_valid_choice with status 200

    Then I wait for card status as CARD_STATUS_INACTIVE for user UID1, activate with valid token, with status 200

    Then I check card status is CARD_STATUS_ACTIVE for user UID1

    Given I deposit 200 SGD into account subtype HUGO_CASH of user UID1

    And I check the balance of account subtype HUGO_CASH of user UID1 is 200 SGD exact

    Given I deposit 50 SGD into account subtype HUGO_CARD of user UID1

    And I check the balance of account subtype HUGO_CARD of user UID1 is 50 SGD exact

    Then I enable auto-top-up of 50 SGD for user UID1 with trigger amount 20 SGD

    Given I create below transaction for user profile id and verify 200
      | user_profile_identifier | transaction_permutation_name | billing_amount | is_foreign_txn |
      | UID1                    | AUTH_CLEAR                   | 40             | false          |

    And I check the balance of account subtype HUGO_CARD of user UID1 is 60 SGD exact

    And I check the balance of account subtype HUGO_CASH of user UID1 is 100 SGD exact

    Given I create below transaction for user profile id and verify 200
      | user_profile_identifier | transaction_permutation_name | billing_amount | is_foreign_txn |
      | UID1                    | AUTH_MULTI_CLEAR             | 50.0           | false          |

    And I check the balance of account subtype HUGO_CARD of user UID1 is 60 SGD exact

    And I check the balance of account subtype HUGO_CASH of user UID1 is 50 SGD exact

    Then I disable auto-top-up for user UID1

    Given I create below transaction for user profile id and verify 200
      | user_profile_identifier | transaction_permutation_name | billing_amount | is_foreign_txn |
      | UID1                    | AUTH_CLEAR                   | 50.0           | false          |

    And I check the balance of account subtype HUGO_CARD of user UID1 is 10 SGD exact

    And I withdraw 10 SGD from card account of user UID1

  Scenario: Card negative balance claim
    Then I order card for UID1 with card name as random_valid_choice with status 200

    Then I wait for 10 seconds

    Then I wait for card status as CARD_STATUS_INACTIVE for user UID1, activate with valid token, with status 200

    Then I check card status is CARD_STATUS_ACTIVE for user UID1

    Given I deposit 50 SGD into account subtype HUGO_CASH of user UID1

    Given I deposit 50 SGD into account subtype HUGO_CARD of user UID1

    Given I create below transaction for user profile id and verify 200
      | user_profile_identifier | transaction_permutation_name | billing_amount | is_foreign_txn |
      | UID1                    | CLEAR                        | 60             | false          |
    And I check the balance of account subtype HUGO_CARD of user UID1 is -10 SGD exact

    Given I deposit 200 SGD into account subtype HUGO_CASH of user UID1

    And I check the balance of account subtype HUGO_CASH of user UID1 is 190 SGD exact

    And I check the balance of account subtype HUGO_CARD of user UID1 is 0 SGD approx

  Scenario: Local Transactions - AUTH Cases - Roundups DISABLED
    Then I order card for UID1 with card name as random_valid_choice with status 200

    Then I wait for 10 seconds

    Then I wait for card status as CARD_STATUS_INACTIVE for user UID1, activate with valid token, with status 200

    Then I check card status is CARD_STATUS_ACTIVE for user UID1

    Given I deposit 50 SGD into account subtype HUGO_CASH of user UID1

    Given I deposit 50 SGD into account subtype HUGO_CARD of user UID1

    And I check the balance of account subtype HUGO_CARD of user UID1 is 50 SGD exact
#    1. auth
    Given I create below transaction for user profile id and verify 200
      | user_profile_identifier | transaction_permutation_name | billing_amount | is_foreign_txn |
      | UID1                    | AUTH                         | 10.3           | false          |
    And I check the balance of account subtype HUGO_CARD of user UID1 is 39 SGD approx
# 2. AUTH_CLEAR
    Given I create below transaction for user profile id and verify 200
      | user_profile_identifier | transaction_permutation_name | billing_amount | is_foreign_txn |
      | UID1                    | AUTH_CLEAR                   | 5.5            | false          |
    And I check the balance of account subtype HUGO_CARD of user UID1 is 34 SGD approx
# 3. AUTH_PARTIAL_CLEARING
    Given I create below transaction for user profile id and verify 200
      | user_profile_identifier | transaction_permutation_name | billing_amount | is_foreign_txn |
      | UID1                    | AUTH_PARTIAL_CLEARING        | 1.3            | false          |
    And I check the balance of account subtype HUGO_CARD of user UID1 is 32 SGD approx
#4. AUTH_MULTI_CLEARING
    Given I create below transaction for user profile id and verify 200
      | user_profile_identifier | transaction_permutation_name | billing_amount | is_foreign_txn |
      | UID1                    | AUTH_MULTI_CLEAR             | 12.47          | false          |
    And I check the balance of account subtype HUGO_CARD of user UID1 is 20 SGD approx
# 5. AUTH_FR
    Given I create below transaction for user profile id and verify 200
      | user_profile_identifier | transaction_permutation_name | billing_amount | is_foreign_txn |
      | UID1                    | AUTH_FR                      | 3.37           | false          |
    And I check the balance of account subtype HUGO_CARD of user UID1 is 20 SGD approx
#    6. AUTH_PR
    Given I create below transaction for user profile id and verify 200
      | user_profile_identifier | transaction_permutation_name | billing_amount | is_foreign_txn |
      | UID1                    | AUTH_PR                      | 1.94           | false          |
    And I check the balance of account subtype HUGO_CARD of user UID1 is 20 SGD approx
#    7.AUTH_PR_FR ---- balance becomes [balance: 19.46]
    Given I create below transaction for user profile id and verify 200
      | user_profile_identifier | transaction_permutation_name | billing_amount | is_foreign_txn |
      | UID1                    | AUTH_PR_FR                   | 3.33           | false          |
    And I check the balance of account subtype HUGO_CARD of user UID1 is 20 SGD approx
#8. AUTH_PR_CLEAR
    Given I create below transaction for user profile id and verify 200
      | user_profile_identifier | transaction_permutation_name | billing_amount | is_foreign_txn |
      | UID1                    | AUTH_PR_CLEAR                | 8.19           | false          |
    And I check the balance of account subtype HUGO_CARD of user UID1 is 15 SGD approx
# 9. AUTH_PR_MULTI_CLEAR
    Given I create below transaction for user profile id and verify 200
      | user_profile_identifier | transaction_permutation_name | billing_amount | is_foreign_txn |
      | UID1                    | AUTH_PR_MULTI_CLEAR          | 1.44           | false          |
    And I check the balance of account subtype HUGO_CARD of user UID1 is 14 SGD approx
#    9.1
    Given I create below transaction for user profile id and verify 200
      | user_profile_identifier | transaction_permutation_name | billing_amount | is_foreign_txn |
      | UID1                    | AUTH_PR_MULTI_CLEAR          | 6.99           | false          |
    And I check the balance of account subtype HUGO_CARD of user UID1 is 10 SGD approx


  Scenario: Local Transactions - Incremental Auth - Roundups DISABLED
    Then I order card for UID1 with card name as random_valid_choice with status 200

    Then I wait for 10 seconds

    Then I wait for card status as CARD_STATUS_INACTIVE for user UID1, activate with valid token, with status 200

    Then I check card status is CARD_STATUS_ACTIVE for user UID1

    Given I deposit 50 SGD into account subtype HUGO_CASH of user UID1

    Given I deposit 50 SGD into account subtype HUGO_CARD of user UID1

    And I check the balance of account subtype HUGO_CARD of user UID1 is 50 SGD exact

    And I DISABLE roundups for user UID1

    And I wait for 10 seconds
  #   10 INC_AUTH
    Given I create below transaction for user profile id and verify 200
      | user_profile_identifier | transaction_permutation_name | billing_amount | is_foreign_txn |
      | UID1                    | INC_AUTH                     | 0.937          | false          |
    And I check the balance of account subtype HUGO_CARD of user UID1 is 49 SGD approx
#    11 INC_AUTH_CLEAR
    Given I create below transaction for user profile id and verify 200
      | user_profile_identifier | transaction_permutation_name | billing_amount | is_foreign_txn |
      | UID1                    | INC_AUTH_CLEAR               | 0.209          | false          |
    And I check the balance of account subtype HUGO_CARD of user UID1 is 48 SGD approx
#  12 INC_AUTH_PARTIAL_CLEARING
    Given I create below transaction for user profile id and verify 200
      | user_profile_identifier | transaction_permutation_name | billing_amount | is_foreign_txn |
      | UID1                    | INC_AUTH_PARTIAL_CLEARING    | 2.51           | false          |
    And I check the balance of account subtype HUGO_CARD of user UID1 is 46 SGD approx
# 13 INC_AUTH_MULTI_CLEAR
    Given I create below transaction for user profile id and verify 200
      | user_profile_identifier | transaction_permutation_name | billing_amount | is_foreign_txn |
      | UID1                    | INC_AUTH_MULTI_CLEAR         | 23.86          | false          |
    And I check the balance of account subtype HUGO_CARD of user UID1 is 22 SGD approx
#  14 INC_AUTH_FR
    Given I create below transaction for user profile id and verify 200
      | user_profile_identifier | transaction_permutation_name | billing_amount | is_foreign_txn |
      | UID1                    | INC_AUTH_FR                  | 3.83           | false          |
    And I check the balance of account subtype HUGO_CARD of user UID1 is 22 SGD approx
#  15 INC_AUTH_PR
    Given I create below transaction for user profile id and verify 200
      | user_profile_identifier | transaction_permutation_name | billing_amount | is_foreign_txn |
      | UID1                    | INC_AUTH_PR                  | 4.83           | false          |
    And I check the balance of account subtype HUGO_CARD of user UID1 is 22 SGD approx
  #  15 INC_AUTH_PR_FR
    Given I create below transaction for user profile id and verify 200
      | user_profile_identifier | transaction_permutation_name | billing_amount | is_foreign_txn |
      | UID1                    | INC_AUTH_PR_FR               | 6.19           | false          |
    And I check the balance of account subtype HUGO_CARD of user UID1 is 22 SGD approx
#  16 INC_AUTH_PR_CLEAR - not working
    Given I create below transaction for user profile id and verify 200
      | user_profile_identifier | transaction_permutation_name | billing_amount | is_foreign_txn |
      | UID1                    | INC_AUTH_PR_CLEAR            | 5.67           | false          |
    And I check the balance of account subtype HUGO_CARD of user UID1 is 19 SGD approx
#  17 INC_AUTH_PR_MULTI_CLEAR
    Given I create below transaction for user profile id and verify 200
      | user_profile_identifier | transaction_permutation_name | billing_amount | is_foreign_txn |
      | UID1                    | INC_AUTH_PR_MULTI_CLEAR      | 4.07           | false          |
    And I check the balance of account subtype HUGO_CARD of user UID1 is 17 SGD approx


  Scenario: Local Transactions - Roundups ENABLED
    Then I order card for UID1 with card name as random_valid_choice with status 200

    Then I wait for 10 seconds

    Then I wait for card status as CARD_STATUS_INACTIVE for user UID1, activate with valid token, with status 200

    Then I check card status is CARD_STATUS_ACTIVE for user UID1

    Then I deposit 50 SGD into account subtype HUGO_CASH of user UID1

    Then I deposit 50 SGD into account subtype HUGO_CARD of user UID1

    And I check the balance of account subtype HUGO_CARD of user UID1 is 50 SGD exact

    And I ENABLE roundups for user UID1

# 1. INC_AUTH WITH RU
    Given I create below transaction for user profile id and verify 200
      | user_profile_identifier | transaction_permutation_name | billing_amount | is_foreign_txn |
      | UID1                    | INC_AUTH                     | 0.937            | false          |
    Then I check the balance of account subtype HUGO_CARD of user UID1 is 49.06 SGD approx
    Then I check the balance of account subtype HUGO_ROUNDUP of user UID1 is 0 SGD approx
# 2. AUTH_CLEAR with RU
    Given I create below transaction for user profile id and verify 200
      | user_profile_identifier | transaction_permutation_name | billing_amount | is_foreign_txn |
      | UID1                    | AUTH_CLEAR                   | 5.5            | false          |
    Then I check intent type CARD_TRANSACTION with status SETTLED and total 1 intents exist in card view for user UID1
    And I check the balance of account subtype HUGO_CARD of user UID1 is 43.06 SGD approx
    And I check the balance of account subtype HUGO_ROUNDUP of user UID1 is 0.5 SGD approx
# 3. AUTH_PARTIAL_CLEARING with RU
    Given I create below transaction for user profile id and verify 200
      | user_profile_identifier | transaction_permutation_name | billing_amount | is_foreign_txn |
      | UID1                    | AUTH_PARTIAL_CLEARING        | 1.3            | false          |
    And I check the balance of account subtype HUGO_CARD of user UID1 is 41.28 SGD approx
    And I check the balance of account subtype HUGO_ROUNDUP of user UID1 is 0.98 SGD approx
  #4. AUTH_MULTI_CLEARING
    Given I create below transaction for user profile id and verify 200
      | user_profile_identifier | transaction_permutation_name | billing_amount | is_foreign_txn |
      | UID1                    | AUTH_MULTI_CLEAR             | 12.47          | false          |
    Then I check intent type CARD_TRANSACTION with status SETTLED and total 4 intents exist in card view for user UID1
    And I check the balance of account subtype HUGO_CARD of user UID1 is 29.25 SGD approx
    And I check the balance of account subtype HUGO_ROUNDUP of user UID1 is 1.24 SGD approx
# 5. AUTH_FR
    Given I create below transaction for user profile id and verify 200
      | user_profile_identifier | transaction_permutation_name | billing_amount | is_foreign_txn |
      | UID1                    | AUTH_FR                      | 3.37           | false          |
    Then I check intent type CARD_TRANSACTION with status REVERTED and total 1 intents exist in card view for user UID1
    And I check the balance of account subtype HUGO_CARD of user UID1 is 29.25 SGD approx
    And I check the balance of account subtype HUGO_ROUNDUP of user UID1 is 1.51 SGD approx
#    6. AUTH_PR
    Given I create below transaction for user profile id and verify 200
      | user_profile_identifier | transaction_permutation_name | billing_amount | is_foreign_txn |
      | UID1                    | AUTH_PR                      | 1.94           | false          |
    Then I check intent type CARD_TRANSACTION with status REVERTED and total 1 intents exist in card view for user UID1
    Then I check intent type CARD_TRANSACTION with status SETTLED and total 4 intents exist in card view for user UID1
    And I check the balance of account subtype HUGO_CARD of user UID1 is 27.82 SGD approx
    And I check the balance of account subtype HUGO_ROUNDUP of user UID1 is 1.51 SGD approx
#    7.AUTH_PR_FR ---- balance becomes [balance: 19.46]
    Given I create below transaction for user profile id and verify 200
      | user_profile_identifier | transaction_permutation_name | billing_amount | is_foreign_txn |
      | UID1                    | AUTH_PR_FR                   | 3.33           | false          |
    Then I check intent type CARD_TRANSACTION with status REVERTED and total 2 intents exist in card view for user UID1
    Then I check intent type CARD_TRANSACTION with status SETTLED and total 4 intents exist in card view for user UID1
    And I check the balance of account subtype HUGO_CARD of user UID1 is 27.82 SGD approx
    And I check the balance of account subtype HUGO_ROUNDUP of user UID1 is 1.51 SGD approx
# 8. AUTH_PR_CLEAR  -
    Given I create below transaction for user profile id and verify 200
      | user_profile_identifier | transaction_permutation_name | billing_amount | is_foreign_txn |
      | UID1                    | AUTH_PR_CLEAR                | 8.19           | false          |
    Then I check intent type CARD_TRANSACTION with status SETTLED and total 5 intents exist in card view for user UID1
    And I check the balance of account subtype HUGO_CARD of user UID1 is 22.91 SGD approx
    And I check the balance of account subtype HUGO_ROUNDUP of user UID1 is 1.6 SGD approx
#  9 INC_AUTH_PR_MULTI_CLEAR
    Given I create below transaction for user profile id and verify 200
      | user_profile_identifier | transaction_permutation_name | billing_amount | is_foreign_txn |
      | UID1                    | INC_AUTH_PR_MULTI_CLEAR      | 4.07           | false          |
    Then I check intent type CARD_TRANSACTION with status SETTLED and total 5 intents exist in card view for user UID1
    And I check the balance of account subtype HUGO_CARD of user UID1 is 19.3 SGD approx
    And I check the balance of account subtype HUGO_ROUNDUP of user UID1 is 2.98 SGD approx

    Then I DISABLE roundups for user UID1

    Then I wait for 10 seconds

    And I check the balance of account subtype HUGO_CASH of user UID1 is 2.98 SGD approx
    #  9 auth_clear with full balance
    Given I create below transaction for user profile id and verify 200
      | user_profile_identifier | transaction_permutation_name | billing_amount | is_foreign_txn |
      | UID1                    | AUTH_CLEAR                   | 22.28          | false          |
    Then I check intent type CARD_TRANSACTION with status SETTLED and total 6 intents exist in card view for user UID1
    And I check the balance of account subtype HUGO_CARD of user UID1 is 0 SGD approx
#  10 refund without round-up
    Given I create below transaction for user profile id and verify 200
      | user_profile_identifier | transaction_permutation_name | billing_amount | is_foreign_txn |
      | UID1                    | REFUND_CLEAR                 | 22.28          | false          |
    And I check the balance of account subtype HUGO_CARD of user UID1 is 22.28 SGD approx
    #  11 refund without round-up
    Given I create below transaction for user profile id and verify 200
      | user_profile_identifier | transaction_permutation_name | billing_amount | is_foreign_txn |
      | UID1                    | REFUND_AUTH_REFUND_CLEAR     | 22.28          | false          |
    And I check the balance of account subtype HUGO_CARD of user UID1 is 44.56 SGD approx
        #  12 refund without round-up
    Given I create below transaction for user profile id and verify 200
      | user_profile_identifier | transaction_permutation_name | billing_amount | is_foreign_txn |
      | UID1                    | REFUND_AUTH                  | 2.1            | false          |
    And I check the balance of account subtype HUGO_CARD of user UID1 is 44.56 SGD approx

    Then I ENABLE roundups for user UID1

        #  13 refund without round-up
    Given I create below transaction for user profile id and verify 200
      | user_profile_identifier | transaction_permutation_name | billing_amount | is_foreign_txn |
      | UID1                    | REFUND_AUTH                  | 2.1            | false          |
    And I check the balance of account subtype HUGO_CARD of user UID1 is 44.56 SGD approx
    And I check the balance of account subtype HUGO_ROUNDUP of user UID1 is 0 SGD approx
#  14 refund without round-up
    Given I create below transaction for user profile id and verify 200
      | user_profile_identifier | transaction_permutation_name | billing_amount | is_foreign_txn |
      | UID1                    | REFUND_CLEAR                 | 22.28          | false          |
    And I check the balance of account subtype HUGO_CARD of user UID1 is 66.84 SGD approx
    And I check the balance of account subtype HUGO_ROUNDUP of user UID1 is 0 SGD approx

    #  15 refund without round-up
    Given I create below transaction for user profile id and verify 200
      | user_profile_identifier | transaction_permutation_name | billing_amount | is_foreign_txn |
      | UID1                    | REFUND_AUTH_REFUND_CLEAR     | 0              | false          |
    And I check the balance of account subtype HUGO_CARD of user UID1 is 66.84 SGD approx
    And I check the balance of account subtype HUGO_ROUNDUP of user UID1 is 0 SGD approx


  Scenario: Foreign Transactions - Roundups ENABLED
    Then I order card for UID1 with card name as random_valid_choice with status 200

    Then I wait for 10 seconds
#
    Then I wait for card status as CARD_STATUS_INACTIVE for user UID1, activate with valid token, with status 200

    Then I check card status is CARD_STATUS_ACTIVE for user UID1

    Then I deposit 750 SGD into account subtype HUGO_CASH of user UID1

    Given I deposit 750 SGD into account subtype HUGO_CARD of user UID1

    And I check the balance of account subtype HUGO_CARD of user UID1 is 750 SGD exact

    And I ENABLE roundups for user UID1
#    1. auth
    Given I create below transaction for user profile id and verify 200
      | user_profile_identifier | transaction_permutation_name | billing_amount | is_foreign_txn |
      | UID1                    | AUTH                         | 9.86           | true           |
    And I check the balance of account subtype HUGO_CARD of user UID1 is 740.04 SGD approx
      #0.1 is txn fee for foreign
    And I check the balance of account subtype HUGO_ROUNDUP of user UID1 is 0 SGD approx
# 2. AUTH_CLEAR with RU
    Given I create below transaction for user profile id and verify 200
      | user_profile_identifier | transaction_permutation_name | billing_amount | is_foreign_txn |
      | UID1                    | AUTH_CLEAR                   | 5.5            | true           |
    Then I check intent type CARD_TRANSACTION with status SETTLED and total 1 intents exist in card view for user UID1
    And I check the balance of account subtype HUGO_CARD of user UID1 is 734.04 SGD approx
    And I check the balance of account subtype HUGO_ROUNDUP of user UID1 is 0.5 SGD approx
# 3. AUTH_PARTIAL_CLEARING with RU
    Given I create below transaction for user profile id and verify 200
      | user_profile_identifier | transaction_permutation_name | billing_amount | is_foreign_txn |
      | UID1                    | AUTH_PARTIAL_CLEARING        | 1.3            | true           |
    Then I check intent type CARD_TRANSACTION with status SETTLED and total 2 intents exist in card view for user UID1
    And I check the balance of account subtype HUGO_CARD of user UID1 is 732.25 SGD approx
    And I check the balance of account subtype HUGO_ROUNDUP of user UID1 is 0.98 SGD approx
  #4. AUTH_MULTI_CLEARING
    Given I create below transaction for user profile id and verify 200
      | user_profile_identifier | transaction_permutation_name | billing_amount | is_foreign_txn |
      | UID1                    | AUTH_MULTI_CLEAR             | 12.47          | true           |
    Then I check intent type CARD_TRANSACTION with status SETTLED and total 4 intents exist in card view for user UID1
    And I check the balance of account subtype HUGO_CARD of user UID1 is 720.76 SGD approx
    And I check the balance of account subtype HUGO_ROUNDUP of user UID1 is 1.24 SGD approx
# 5. AUTH_FR
    Given I create below transaction for user profile id and verify 200
      | user_profile_identifier | transaction_permutation_name | billing_amount | is_foreign_txn |
      | UID1                    | AUTH_FR                      | 3.37           | true           |
    Then I check intent type CARD_TRANSACTION with status REVERTED and total 1 intents exist in card view for user UID1
    And I check the balance of account subtype HUGO_CARD of user UID1 is 720.76 SGD approx
    And I check the balance of account subtype HUGO_ROUNDUP of user UID1 is 1.51 SGD approx
#    6. AUTH_PR
    Given I create below transaction for user profile id and verify 200
      | user_profile_identifier | transaction_permutation_name | billing_amount | is_foreign_txn |
      | UID1                    | AUTH_PR                      | 1.94           | true           |
    Then I check intent type CARD_TRANSACTION with status SETTLED and total 4 intents exist in card view for user UID1
    Then I check intent type CARD_TRANSACTION with status REVERTED and total 2 intents exist in card view for user UID1

    And I check the balance of account subtype HUGO_CARD of user UID1 is 719.14 SGD approx
    And I check the balance of account subtype HUGO_ROUNDUP of user UID1 is 1.51 SGD approx
#    7.AUTH_PR_FR
    Given I create below transaction for user profile id and verify 200
      | user_profile_identifier | transaction_permutation_name | billing_amount | is_foreign_txn |
      | UID1                    | AUTH_PR_FR                   | 3.33           | true           |
    Then I check intent type CARD_TRANSACTION with status SETTLED and total 4 intents exist in card view for user UID1
    Then I check intent type CARD_TRANSACTION with status REVERTED and total 3 intents exist in card view for user UID1

    And I check the balance of account subtype HUGO_CARD of user UID1 is 718.14 SGD approx
    And I check the balance of account subtype HUGO_ROUNDUP of user UID1 is 1.51 SGD approx
# 8. AUTH_PR_CLEAR  -
    Given I create below transaction for user profile id and verify 200
      | user_profile_identifier | transaction_permutation_name | billing_amount | is_foreign_txn |
      | UID1                    | AUTH_PR_CLEAR                | 8.19           | true           |
    Then I check intent type CARD_TRANSACTION with status SETTLED and total 5 intents exist in card view for user UID1
    Then I check intent type CARD_TRANSACTION with status REVERTED and total 4 intents exist in card view for user UID1

    And I check the balance of account subtype HUGO_CARD of user UID1 is 713.14 SGD approx
    And I check the balance of account subtype HUGO_ROUNDUP of user UID1 is 1.59 SGD approx
#  9 INC_AUTH_PR_MULTI_CLEAR
    Given I create below transaction for user profile id and verify 200
      | user_profile_identifier | transaction_permutation_name | billing_amount | is_foreign_txn |
      | UID1                    | INC_AUTH_PR_MULTI_CLEAR      | 4.07           | true           |
    Then I check intent type CARD_TRANSACTION with status SETTLED and total 7 intents exist in card view for user UID1
    Then I check intent type CARD_TRANSACTION with status REVERTED and total 5 intents exist in card view for user UID1

    And I check the balance of account subtype HUGO_CARD of user UID1 is 710.12 SGD approx
    And I check the balance of account subtype HUGO_ROUNDUP of user UID1 is 2.97 SGD approx
        #  13 refund_AUTH round-up
    Given I create below transaction for user profile id and verify 200
      | user_profile_identifier | transaction_permutation_name | billing_amount | is_foreign_txn |
      | UID1                    | REFUND_AUTH                  | 2.1            | true           |
    And I check the balance of account subtype HUGO_CARD of user UID1 is 710.12 SGD approx
    And I check the balance of account subtype HUGO_ROUNDUP of user UID1 is 2.97 SGD approx
#  14 refund_CLEAR  round-up
    Given I create below transaction for user profile id and verify 200
      | user_profile_identifier | transaction_permutation_name | billing_amount | is_foreign_txn |
      | UID1                    | REFUND_CLEAR                 | 22.28          | true           |
    Then I check intent type CARD_TRANSACTION with status SETTLED and total 8 intents exist in card view for user UID1
    Then I check intent type CARD_TRANSACTION with status REVERTED and total 6 intents exist in card view for user UID1

    And I check the balance of account subtype HUGO_CARD of user UID1 is 732.4 SGD approx
    And I check the balance of account subtype HUGO_ROUNDUP of user UID1 is 2.97 SGD approx

    #  15 REFUND_AUTH_REFUND_CLEAR  round-up
    Given I create below transaction for user profile id and verify 200
      | user_profile_identifier | transaction_permutation_name | billing_amount | is_foreign_txn |
      | UID1                    | REFUND_AUTH_REFUND_CLEAR     | 22.28          | true           |
    Then I check intent type CARD_TRANSACTION with status SETTLED and total 9 intents exist in card view for user UID1
    Then I check intent type CARD_TRANSACTION with status REVERTED and total 7 intents exist in card view for user UID1

    And I check the balance of account subtype HUGO_CARD of user UID1 is 754.68 SGD approx
    And I check the balance of account subtype HUGO_ROUNDUP of user UID1 is 2.97 SGD approx

    And I DISABLE roundups for user UID1

    And I check the balance of account subtype HUGO_CARD of user UID1 is 757.65 SGD approx
    Given I create below transaction for user profile id and verify 200
      | user_profile_identifier | transaction_permutation_name | billing_amount | is_foreign_txn |
      | UID1                    | AUTH_CLEAR                   | 657.65         | true           |
    Then I check intent type CARD_TRANSACTION with status SETTLED and total 10 intents exist in card view for user UID1
    And I check the balance of account subtype HUGO_CARD of user UID1 is 100 SGD approx

  Scenario: Negative Scenarios - Invalid Billing Amounts - Balance should not be deducted for user
    Then I order card for UID1 with card name as random_valid_choice with status 200

    Then I wait for 10 seconds

    Then I wait for card status as CARD_STATUS_INACTIVE for user UID1, activate with valid token, with status 200

    Then I check card status is CARD_STATUS_ACTIVE for user UID1

    Then I deposit 100 SGD into account subtype HUGO_CASH of user UID1

    Then I deposit 100 SGD into account subtype HUGO_CARD of user UID1

    And I check the balance of account subtype HUGO_CARD of user UID1 is 100 SGD exact

#    1. auth
    Given I create below transaction for user profile id and verify HSA_9000
      | user_profile_identifier | transaction_permutation_name | billing_amount | is_foreign_txn |
      | UID1                    | AUTH                         | 0              | false          |
    And I check the balance of account subtype HUGO_CARD of user UID1 is 100 SGD approx
# 2. AUTH_CLEAR with RU
    Given I create below transaction for user profile id and verify HSA_9000
      | user_profile_identifier | transaction_permutation_name | billing_amount   | is_foreign_txn |
      | UID1                    | AUTH_CLEAR                   | 0                | true           |
      | UID1                    | AUTH_CLEAR                   | -2948.2          | true           |
      | UID1                    | AUTH_CLEAR                   | someGarbageValue | false          |
    And I check the balance of account subtype HUGO_CARD of user UID1 is 100 SGD approx
# 3. AUTH_PARTIAL_CLEARING with RU
    Given I create below transaction for user profile id and verify HSA_9000
      | user_profile_identifier | transaction_permutation_name | billing_amount   | is_foreign_txn |
      | UID1                    | AUTH_PARTIAL_CLEARING        | 0                | false          |
      | UID1                    | AUTH_PARTIAL_CLEARING        | -2948.2          | true           |
      | UID1                    | AUTH_PARTIAL_CLEARING        | someGarbageValue | false          |
    And I check the balance of account subtype HUGO_CARD of user UID1 is 100 SGD approx
  #4. AUTH_MULTI_CLEARING
    Given I create below transaction for user profile id and verify HSA_9000
      | user_profile_identifier | transaction_permutation_name | billing_amount   | is_foreign_txn |
      | UID1                    | AUTH_MULTI_CLEAR             | 0                | true           |
      | UID1                    | AUTH_MULTI_CLEAR             | -2948.2          | true           |
      | UID1                    | AUTH_MULTI_CLEAR             | someGarbageValue | false          |
    And I check the balance of account subtype HUGO_CARD of user UID1 is 100 SGD approx
# 5. AUTH_FR
    Given I create below transaction for user profile id and verify HSA_9000
      | user_profile_identifier | transaction_permutation_name | billing_amount   | is_foreign_txn |
      | UID1                    | AUTH_FR                      | 0                | false          |
      | UID1                    | AUTH_FR                      | -2948.2          | true           |
      | UID1                    | AUTH_FR                      | someGarbageValue | false          |
    And I check the balance of account subtype HUGO_CARD of user UID1 is 100 SGD approx
#    6. AUTH_PR
    Given I create below transaction for user profile id and verify HSA_9000
      | user_profile_identifier | transaction_permutation_name | billing_amount   | is_foreign_txn |
      | UID1                    | AUTH_PR                      | 0                | false          |
      | UID1                    | AUTH_PR                      | -0.2             | true           |
      | UID1                    | AUTH_PR                      | someGarbageValue | false          |
    And I check the balance of account subtype HUGO_CARD of user UID1 is 100 SGD approx
      #    7.AUTH_PR_FR
    Given I create below transaction for user profile id and verify HSA_9000
      | user_profile_identifier | transaction_permutation_name | billing_amount   | is_foreign_txn |
      | UID1                    | AUTH_PR_FR                   | 0                | false          |
      | UID1                    | AUTH_PR_FR                   | -2948.2          | true           |
      | UID1                    | AUTH_PR_FR                   | someGarbageValue | false          |
    And I check the balance of account subtype HUGO_CARD of user UID1 is 100 SGD approx
      # 8. AUTH_PR_CLEAR  -
    Given I create below transaction for user profile id and verify HSA_9000
      | user_profile_identifier | transaction_permutation_name | billing_amount   | is_foreign_txn |
      | UID1                    | AUTH_PR_CLEAR                | 0                | false          |
      | UID1                    | AUTH_PR_CLEAR                | -282141124.2     | true           |
      | UID1                    | AUTH_PR_CLEAR                | someGarbageValue | false          |
    And I check the balance of account subtype HUGO_CARD of user UID1 is 100 SGD approx
      #  9 INC_AUTH_PR_MULTI_CLEAR
    Given I create below transaction for user profile id and verify HSA_9000
      | user_profile_identifier | transaction_permutation_name | billing_amount   | is_foreign_txn |
      | UID1                    | INC_AUTH_PR_MULTI_CLEAR      | 0                | false          |
      | UID1                    | INC_AUTH_PR_MULTI_CLEAR      | -28.2            | true           |
      | UID1                    | INC_AUTH_PR_MULTI_CLEAR      | someGarbageValue | false          |
    And I check the balance of account subtype HUGO_CARD of user UID1 is 100 SGD approx
      #  13 refund_AUTH
    Given I create below transaction for user profile id and verify HSA_9000
      | user_profile_identifier | transaction_permutation_name | billing_amount   | is_foreign_txn |
      | UID1                    | REFUND_AUTH                  | 0                | false          |
      | UID1                    | REFUND_AUTH                  | -02              | true           |
      | UID1                    | REFUND_AUTH                  | someGarbageValue | false          |
    And I check the balance of account subtype HUGO_CARD of user UID1 is 100 SGD approx
      #  14 refund_CLEAR
    Given I create below transaction for user profile id and verify HSA_9000
      | user_profile_identifier | transaction_permutation_name | billing_amount   | is_foreign_txn |
      | UID1                    | REFUND_CLEAR                 | 0                | false          |
      | UID1                    | REFUND_CLEAR                 | -48.2            | true           |
      | UID1                    | REFUND_CLEAR                 | someGarbageValue | false          |
    And I check the balance of account subtype HUGO_CARD of user UID1 is 100 SGD approx
    Given I create below transaction for user profile id and verify HSA_9000
      | user_profile_identifier | transaction_permutation_name | billing_amount   | is_foreign_txn |
#      | UID1                    | REFUND_AUTH_REFUND_CLEAR     | -21.48.2         | true           |
      | UID1                    | REFUND_AUTH_REFUND_CLEAR     | 0                | false          |
      | UID1                    | REFUND_AUTH_REFUND_CLEAR     | someGarbageValue | false          |
    And I check the balance of account subtype HUGO_CARD of user UID1 is 100 SGD approx
    Given I create below transaction for user profile id and verify E9409
      | user_profile_identifier | transaction_permutation_name | billing_amount   | is_foreign_txn |
      | UID1                    | REFUND_AUTH_REFUND_CLEAR     | -21.48.2         | true           |
    And I check the balance of account subtype HUGO_CARD of user UID1 is 100 SGD approx

  Scenario: Card - Failure Scenarios
    And I order card for UID1 with card name as invalidName with status HSA_9129

    Then I order card for UID1 with card name as random_valid_choice with status 200

    Then I wait for 10 seconds

    Then I wait for card status as CARD_STATUS_INACTIVE for user UID1, activate with invalid token, with status HSA_9102

    Then Invalid card scenario, activate_invalid_card_id, for user UID1 with status HSA_9105

    Then I check card status is CARD_STATUS_INACTIVE for user UID1

    Then I check card status is CARD_STATUS_INACTIVE for user UID1

    Then I wait for card status as CARD_STATUS_INACTIVE for user UID1, activate with valid token, with status 200

    Then I check card status is CARD_STATUS_ACTIVE for user UID1

    Then I update card status to INVALID_ACTION for user UID1 with status HSA_9179

    Then Invalid card scenario, get_details_invalid_card_id, for user UID1 with status HSA_9105

    Then Invalid card scenario, get_secure_invalid_card_id, for user UID1 with status HSA_9105

    Then Invalid card scenario, update_status_invalid_card_id, for user UID1 with status HSA_9105
