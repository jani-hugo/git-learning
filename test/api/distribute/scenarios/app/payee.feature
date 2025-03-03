Feature: Payee

  Scenario Outline: Add, Pay, Delete Payee, Add Note

    Given I open user account
      | user_profile_identifier | phone_number | email          | legal_name | status              | prefix_ph_num | org_id   |
      | UID1                    | random       | test@gmail.com | John Doe   | PROFILE_IN_PROGRESS | +37           | <org-id> |

    Then I check account status
      | user_profile_identifier | status         |
      | UID1                    | PROFILE_ACTIVE |

    Then I open user account with referral code of user with identifier UID1
      | user_profile_identifier | phone_number | email        | legal_name | status              | referral_code | prefix_ph_num | org_id   |
      | UID2                    | random       | test@def.com | Penn Glenn | PROFILE_IN_PROGRESS | UID1          | +37           | <org-id> |

    Then I check account status
      | user_profile_identifier | status         |
      | UID2                    | PROFILE_ACTIVE |

    # add payee
    Then I add the account subtype HUGO_MAIN of user UID2 to user UID1 as payee PID1 with valid_swift_bic

    Then I submit otp of user UID1 for payee PID1
      | otp    |
      | 123456 |

    And I check if the account subtype HUGO_MAIN of user UID2 is added as payee to user UID1

    # pay payee
    Given I deposit 50 SGD into account subtype HUGO_CASH of user UID1

    And I check the balance of account subtype HUGO_CASH of user UID1 is 50 SGD exact

    Then I transfer 20 SGD from user UID1 to user UID2 with no reference and valid payee id

    And I check the balance of account subtype HUGO_CASH of user UID1 is 30 SGD exact

    And I check the balance of account subtype HUGO_CASH of user UID2 is 20 SGD exact

    # add note
    Then I add a random note to the latest intent of user UID1 and check if note is saved

    # pay payee with invalid payee id
    Then I transfer 20 SGD from user UID1 to user UID2 with no reference and invalid payee id

    # pay payee with insufficient balance
    Then I transfer 100 SGD from user UID1 to user UID2 with no reference and valid payee id

    And I check the balance of account subtype HUGO_CASH of user UID1 is 30 SGD exact

    And I check the balance of account subtype HUGO_CASH of user UID2 is 20 SGD exact

    Given I delete the payee UID2 added to user UID1

    And I check if the account subtype HUGO_MAIN of user UID2 is not_added as payee to user UID1
    Examples:
      | org-id      |
      |             |
      | HUGOBANK_PK |

  Scenario Outline: Deposits - LITE/PLUS - Limit checks
    Given I open user account
      | user_profile_identifier | phone_number | email          | legal_name | status              | prefix_ph_num | org-id   |
      | UID1                    | random       | test@gmail.com | John Doe   | PROFILE_IN_PROGRESS | +37           | <org-id> |

    Then I check account status
      | user_profile_identifier | status         |
      | UID1                    | PROFILE_ACTIVE |

    Then I open user account with referral code of user with identifier UID1
      | user_profile_identifier | phone_number | email        | legal_name | status              | referral_code | prefix_ph_num | org_id   |
      | UID2                    | random       | test@def.com | John Glenn | PROFILE_IN_PROGRESS | UID1          | +37           | <org-id> |

    Then I check account status
      | user_profile_identifier | status         |
      | UID2                    | PROFILE_ACTIVE |

    # add payee
    Then I add the account subtype HUGO_MAIN of user UID1 to user UID2 as payee PID1 with valid_swift_bic

    Then I wait for 10 seconds
    Then I submit otp of user UID2 for payee PID1
      | otp    |
      | 123456 |

    And I check if the account subtype HUGO_MAIN of user UID1 is added as payee to user UID2

    # deposits more than 750 in multiple trnxs for lite user should fail
    Given I deposit 750 SGD into account subtype HUGO_CASH of user UID1

    And I check the balance of account subtype HUGO_CASH of user UID1 is 750 SGD exact

    Given I deposit 20 SGD into account subtype HUGO_CASH of user UID2

    And I check the balance of account subtype HUGO_CASH of user UID2 is 20 SGD exact

    Then I transfer 10 SGD from user UID2 to user UID1 with no reference and valid payee id

    And I check the balance of account subtype HUGO_CASH of user UID1 is 750 SGD exact

    And I check the balance of account subtype HUGO_CASH of user UID2 is 20 SGD exact

    # upgrade to plus and check limit
    Then I update first_name,last_name,dob,nationality,address,document_number,document_expiry_date,tax_id_number of user UID1 and check if updated correctly

    Then I initiate STANDARD_COMPLIANCE for user UID1 with content type as image/png and expect status 200

    Then I upload document SELFIE using presigned URL for user UID1 and expect status 200
    Then I upload document FRONT using presigned URL for user UID1 and expect status 200
    Then I upload document BACK using presigned URL for user UID1 and expect status 200

    Then I submit NRIC document for STANDARD_COMPLIANCE for user UID1

    Then I initiate TRUST_COMPLIANCE for user UID1 with content type as  and expect status 200
    Then I submit  document for TRUST_COMPLIANCE for user UID1

    Then I update STANDARD_COMPLIANCE status of UID1 as pass
    Then I check if user UID1 account type is PREMIUM

    Given I deposit 1000 SGD into account subtype HUGO_CASH of user UID2

    And I check the balance of account subtype HUGO_CASH of user UID2 is 1020 SGD exact

    # deposit more than 750 in single trxn for LITE should fail
    Given I open user account
      | user_profile_identifier | phone_number | email          | legal_name | status              | prefix_ph_num |
      | UID3                    | random       | test@gmail.com | John Doe   | PROFILE_IN_PROGRESS | +37           |

    Then I check account status
      | user_profile_identifier | status         |
      | UID3                    | PROFILE_ACTIVE |

    Given I deposit 1200 SGD into account subtype HUGO_CASH of user UID3

    And I check the balance of account subtype HUGO_CASH of user UID3 is 0 SGD exact
    Examples:
      | org-id      |
      |             |
      | HUGOBANK_PK |

#  Scenario: Pay Payee - Failure Scenarios
#    Given I open user account
#      | user_profile_identifier | phone_number | email          | first_name | last_name | status              |
#      | UID1                    | random       | test@gmail.com | John       | Doe       | PROFILE_IN_PROGRESS |
#
#    Then I check account status
#      | user_profile_identifier | status         |
#      | UID1                    | PROFILE_ACTIVE |
#
#    Then I open user account with referral code of user with identifier UID1
#      | user_profile_identifier | phone_number | email        | first_name | last_name | status              | referral_code |
#      | UID2                    | random       | test@def.com | John       | Glenn     | PROFILE_IN_PROGRESS | UID1          |
#
#    Then I check account status
#      | user_profile_identifier | status         |
#      | UID2                    | PROFILE_ACTIVE |
#
#    # add payee with invalid currency
#    Then I add the account subtype HUGO_MAIN of user UID2 to user UID1 as payee with invalid_currency
#
#    And I check if the account subtype HUGO_MAIN of user UID2 is not_added as payee to user UID1
#
#    # add payee with invalid_swift_bic
#    Then I add the account subtype HUGO_MAIN of user UID2 to user UID1 as payee with invalid_swift_bic
#
#    And I check if the account subtype HUGO_MAIN of user UID2 is added as payee to user UID1
#
#    # pay payee with special character description
#    Then I add the account subtype HUGO_MAIN of user UID2 to user UID1 as payee with valid_swift_bic
#
#    And I check if the account subtype HUGO_MAIN of user UID2 is added as payee to user UID1
#
#    Given I deposit 100 SGD into account subtype HUGO_MAIN of user UID1
#
#    And I check the balance of account subtype HUGO_CARD of user UID1 is 100 SGD exact
#
#    Then I transfer 50 SGD from user UID1 to user UID2 with special_character_description reference and valid payee id
#
#    Then I wait for 60 seconds
#
#    And I check the balance of account subtype HUGO_CARD of user UID1 is 100 SGD exact
