Feature: Payee

  Scenario Outline: Add, Pay, Delete Payee, Add Note

    Given The user UID1 provides a valid mobile number
      | mobile_number | ph_prefix |  |
      | random        | +65       |  |
    Then The user UID1 submits OTP to proceed with verification

    Given I open a new user account
      | user_profile_identifier | email          |  | legal_name | name | account_type |
      | UID1                    | test@gmail.com |  | Kate Doe   | Kate | PERSONAL     |

    When I initiate the initial onboarding for the user UID1

    Then I submit the initial onboarding for UID1

    And I check the status of initial onboarding for UID1

    And I wait for 5 seconds

    Given The user UID2 provides a valid mobile number
      | mobile_number | ph_prefix |  |
      | random        | +65       |  |
    Then The user UID2 submits OTP to proceed with verification

    Given I open a new user account
      | user_profile_identifier | email          |  | legal_name | name | account_type |
      | UID2                    | test@gmail.com |  | Kate Doe   | Kate | PERSONAL     |

    When I initiate the initial onboarding for the user UID2

    Then I submit the initial onboarding for UID2

    And I check the status of initial onboarding for UID2

    Given Get user details for user UID1

    Given Get user details for user UID2

    Then I initiate the initial user authorisation token for ADD_PAYEE of user UID1

    Then I initiate the final user authorisation token for ADD_PAYEE of user UID1

    And I initiate otp journey for user UID1

    And I submit otp journey for user UID1

    And I submit the final user authorisation for ADD_PAYEE of user UID1

    And I get the final user authorisation token for ADD_PAYEE of user UID1

    And I wait for 5 seconds

    Then I add the account subtype HUGO_CASH of user UID2 to user UID1 as payee PID1 with valid_swift_bic

    And I check if the account subtype HUGO_CASH of user UID2 is added as payee to user UID1

    And I check the balance of account subtype HUGO_CASH of user UID1 is 0 SGD exact

    Given I deposit 50 SGD into account subtype HUGO_CASH of user UID1

    And I check the balance of account subtype HUGO_CASH of user UID1 is 50 SGD exact

    Then I initiate the initial user authorisation token for PAY_PAYEE of user UID1

    And I wait for 5 seconds

    Then I transfer 20 SGD from user UID1 to user UID2 with no reference and valid payee id

    And I check the balance of account subtype HUGO_CASH of user UID1 is 30 SGD exact

    And I check the balance of account subtype HUGO_CASH of user UID2 is 20 SGD exact

    Then I add a random note to the latest intent of user UID1 and check if note is saved

    Then I transfer 20 SGD from user UID1 to user UID2 with no reference and invalid payee id

    Then I transfer 100 SGD from user UID1 to user UID2 with no reference and valid payee id

    And I check the balance of account subtype HUGO_CASH of user UID1 is 30 SGD exact

    And I check the balance of account subtype HUGO_CASH of user UID2 is 20 SGD exact

    Given I delete the payee UID2 added to user UID1

    Then I wait for 10 seconds

    And I check if the account subtype HUGO_CASH of user UID2 is not_added as payee to user UID1
    Examples:
      | org-id   |
      |          |
      | HUGOSAVE |

  Scenario Outline: Deposits - LITE/PLUS - Limit checks

    Given The user UID1 provides a valid mobile number
      | mobile_number | ph_prefix |  |
      | random        | +65       |  |

    Then The user UID1 submits OTP to proceed with verification

    Given I open a new user account
      | user_profile_identifier | email          |  | legal_name | name | account_type |
      | UID1                    | test@gmail.com |  | Kate Doe   | Kate | PERSONAL     |

    When I initiate the initial onboarding for the user UID1

    Then I submit the initial onboarding for UID1

    And I check the status of initial onboarding for UID1

    And I wait for 5 seconds

    Given The user UID2 provides a valid mobile number
      | mobile_number | ph_prefix |  |
      | random        | +65       |  |
    Then The user UID2 submits OTP to proceed with verification

    Given I open a new user account
      | user_profile_identifier | email          |  | legal_name | name | account_type |
      | UID2                    | test@gmail.com |  | Kate Doe   | Kate | PERSONAL     |

    When I initiate the initial onboarding for the user UID2

    Then I submit the initial onboarding for UID2

    And I check the status of initial onboarding for UID2

    Given Get user details for user UID1

    Given Get user details for user UID2

    Then I initiate the initial user authorisation token for ADD_PAYEE of user UID1

    Then I initiate the final user authorisation token for ADD_PAYEE of user UID1

    And I initiate otp journey for user UID1

    And I submit otp journey for user UID1

    And I submit the final user authorisation for ADD_PAYEE of user UID1

    And I get the final user authorisation token for ADD_PAYEE of user UID1

    Then I add the account subtype HUGO_CASH of user UID2 to user UID1 as payee PID1 with valid_swift_bic

    And I wait for 5 seconds

    And I check if the account subtype HUGO_CASH of user UID2 is added as payee to user UID1

    And I check the balance of account subtype HUGO_CASH of user UID1 is 0 SGD exact

    Given I deposit 20 SGD into account subtype HUGO_CASH of user UID1

    And I check the balance of account subtype HUGO_CASH of user UID1 is 20 SGD exact

    Given I deposit 750 SGD into account subtype HUGO_CASH of user UID2

    And I check the balance of account subtype HUGO_CASH of user UID2 is 750 SGD exact

    Then I initiate the initial user authorisation token for PAY_PAYEE of user UID1

    And I wait for 10 seconds

    Then I transfer 20 SGD from user UID1 to user UID2 with no reference and valid payee id

    And I check the balance of account subtype HUGO_CASH of user UID1 is 20 SGD exact

    And I check the balance of account subtype HUGO_CASH of user UID2 is 750 SGD exact

    When I initiate progress onboarding for the user UID2 to upgrade account to PREMIUM

    When I initiate HUGOSAVE_TRUST for the user UID2 and expect a status code of 200

    And I submit HUGOSAVE_TRUST for the user UID2 and expect a status code of 200

    Then I check status of HUGOSAVE_TRUST for the user UID2

    When I initiate HUGOSAVE_SELFIE_AND_SCAN_ID for the user UID2 and expect a status code of 200

    And I upload document FRONT for the user UID2

    And I upload document BACK for the user UID2

    And I upload document SELFIE for the user UID2

    Then I submit HUGOSAVE_SELFIE_AND_SCAN_ID for the user UID2 so we can convert the account to PREMIUM

    And I check the status of HUGOSAVE_SELFIE_AND_SCAN_ID for the user UID2

    Then I submit the progress onboarding for user UID2

    And I check progress onboarding status for the user UID2

    Then I upgrade the user UID2 account level to L3

    And I check the user details to confirm if user UID2 is premium

    Then I initiate the initial user authorisation token for PAY_PAYEE of user UID1

    And I wait for 5 seconds

    Then I transfer 10 SGD from user UID1 to user UID2 with no reference and valid payee id

    And I check the balance of account subtype HUGO_CASH of user UID2 is 760 SGD exact

    And I check the balance of account subtype HUGO_CASH of user UID1 is 10 SGD exact

    Examples:
      | org-id   |
      |          |
      | HUGOSAVE |





