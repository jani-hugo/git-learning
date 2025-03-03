Feature: Admin

  Scenario: Deposits - Block and Unblock

    Given I open user account
      | user_profile_identifier | phone_number | email          | legal_name  | name  | status              | prefix_ph_num |
      | UID1                    | random       | test@gmail.com | Irwin Trott | Matty | PROFILE_IN_PROGRESS | +37           |

    Then I check account status
      | user_profile_identifier | status         |
      | UID1                    | PROFILE_ACTIVE |

    Given I open user account
      | user_profile_identifier | phone_number | email           | legal_name     | status              | prefix_ph_num |
      | UID2                    | random       | test2@gmail.com | John Doe       | PROFILE_IN_PROGRESS | +37           |

    Then I check account status
      | user_profile_identifier | status         |
      | UID2                    | PROFILE_ACTIVE |

    Given I deposit 50 SGD into account subtype HUGO_CASH of user UID1

    And I check the balance of account subtype HUGO_CASH of user UID1 is 50 SGD exact

    Then I add the account subtype HUGO_MAIN of user UID2 to user UID1 as payee PID1 with valid_swift_bic

    Then I submit otp of user UID1 for payee PID1
      | otp    |
      | 123456 |

    And I check if the account subtype HUGO_MAIN of user UID2 is added as payee to user UID1

    And I block deposits for UID2

    Then I transfer 20 SGD from user UID1 to user UID2 with no reference and valid payee id

    Then I wait for 10 seconds

    And I check the balance of account subtype HUGO_CASH of user UID2 is 0 SGD exact

    And I check the balance of account subtype HUGO_CASH of user UID1 is 50 SGD exact

    Then I unblock deposits for UID2

    Then I transfer 20 SGD from user UID1 to user UID2 with no reference and valid payee id

    And I check the balance of account subtype HUGO_CASH of user UID2 is 20 SGD exact

    And I check the balance of account subtype HUGO_CASH of user UID1 is 30 SGD exact

  Scenario: Merchant Trxns - Block and Unblock

    Given I open user account
      | user_profile_identifier | phone_number | email          | legal_name | status              |
      | UID1                    | random       | test@gmail.com | John Doe   | PROFILE_IN_PROGRESS |

    Then I check account status
      | user_profile_identifier | status         |
      | UID1                    | PROFILE_ACTIVE |

    Given I deposit 50 SGD into account subtype HUGO_CASH of user UID1

    Then I wait for 5 seconds

    And I check the balance of account subtype HUGO_CASH of user UID1 is 50 SGD exact

    Then I block merchant transactions for UID1

    Given I invest in GOLD vault map without rate
      | user_profile_identifier | transaction_amount | investment_amount | fee_amount | status_code |
      | UID1                    | 10                 | 10                | 0          | 200         |

    Then I wait for 40 seconds

    Then I check the balance of GOLD Map of user UID1 to be 0

    And I check the balance of account subtype HUGO_CASH of user UID1 is 50 SGD exact

    Then I unblock merchant transactions for UID1

    Given I invest in GOLD vault map without rate
      | user_profile_identifier | transaction_amount | investment_amount | fee_amount | status_code |
      | UID1                    | 10                 | 10                | 0          | 200         |

    And I check the balance of account subtype HUGO_CASH of user UID1 is 40 SGD exact

    Then I check the balance of GOLD Map of user UID1 to be 10

    Given I withdraw from the GOLD map without rate
      | user_profile_identifier | transaction_amount | withdraw_amount | fee_amount | status_code |
      | UID1                    | 7                  | 7               | 0          | 200         |

    Then I check the balance of GOLD Map of user UID1 to be 2.5

    Then I manually settle the sell transaction of user UID1

    #And I check the balance of account subtype HUGO_CARD of user UID1 is 47 SGD approx