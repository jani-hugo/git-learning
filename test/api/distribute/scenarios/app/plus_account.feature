Feature: Upgrade to PLUS Hugosave account

  Scenario: Verify User - Compliance status - Pass - Upgrade to PREMIUM

    Given I open user account
      | user_profile_identifier | phone_number | email          | legal_name | status              |
      | UID1                    | random       | test@gmail.com | John Doe   | PROFILE_IN_PROGRESS |

    Then I check account status
      | user_profile_identifier | status         |
      | UID1                    | PROFILE_ACTIVE |

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

  Scenario: Verify User - Compliance status - Fail - Stay at LITE

    Given I open user account
      | user_profile_identifier | phone_number | email          | legal_name | status              |
      | UID1                    | random       | test@gmail.com | John Doe   | PROFILE_IN_PROGRESS |

    Then I check account status
      | user_profile_identifier | status         |
      | UID1                    | PROFILE_ACTIVE |

    Then I update first_name,last_name,dob,nationality,address,document_number,document_expiry_date,tax_id_number of user UID1 and check if updated correctly

    Then I initiate STANDARD_COMPLIANCE for user UID1 with content type as image/png and expect status 200

    Then I upload document SELFIE using presigned URL for user UID1 and expect status 200
    Then I upload document FRONT using presigned URL for user UID1 and expect status 200
    Then I upload document BACK using presigned URL for user UID1 and expect status 200

    Then I submit NRIC document for STANDARD_COMPLIANCE for user UID1
    Then I update STANDARD_COMPLIANCE status of UID1 as fail

    Then I wait for 10 seconds

    Then I check if user UID1 account type is LITE

  Scenario: Verify User - Compliance status - Referred - Stay at LITE

    Given I open user account
      | user_profile_identifier | phone_number | email          | legal_name | status              |
      | UID1                    | random       | test@gmail.com | John Doe   | PROFILE_IN_PROGRESS |

    Then I check account status
      | user_profile_identifier | status         |
      | UID1                    | PROFILE_ACTIVE |

    Then I update first_name,last_name,dob,nationality,address,document_number,document_expiry_date,tax_id_number of user UID1 and check if updated correctly

    Then I initiate STANDARD_COMPLIANCE for user UID1 with content type as image/png and expect status 200

    Then I upload document SELFIE using presigned URL for user UID1 and expect status 200
    Then I upload document FRONT using presigned URL for user UID1 and expect status 200
    Then I upload document BACK using presigned URL for user UID1 and expect status 200
    Then I submit NRIC document for STANDARD_COMPLIANCE for user UID1

    Then I update STANDARD_COMPLIANCE status of UID1 as referred

    Then I wait for 10 seconds

    Then I check if user UID1 account type is LITE

    Then I initiate TRUST_COMPLIANCE for user UID1 with content type as  and expect status 200
    Then I submit  document for TRUST_COMPLIANCE for user UID1

    Then I check if user UID1 account type is LITE_TRUST

  Scenario: Verify without updating required data for PREMIUM account should fail

    Given I open user account
      | user_profile_identifier | phone_number | email          | legal_name | status              |
      | UID1                    | random       | test@gmail.com | John Doe   | PROFILE_IN_PROGRESS |

    Then I check account status
      | user_profile_identifier | status         |
      | UID1                    | PROFILE_ACTIVE |

    Then I initiate STANDARD_COMPLIANCE for user UID1 with content type as image/png and expect status HSA_9134

  Scenario: Order Card with LITE account should fail

    Given I open user account
      | user_profile_identifier | phone_number | email          | legal_name | status              |
      | UID1                    | random       | test@gmail.com | John Doe   | PROFILE_IN_PROGRESS |

    Then I check account status
      | user_profile_identifier | status         |
      | UID1                    | PROFILE_ACTIVE |

    Then I order card for UID1 with card name as random_valid_choice with status HSA_9101


  Scenario Outline: INVEST/WITHDRAW in premium maps without Premium should fail

    Given I open user account
      | user_profile_identifier | phone_number | email          | legal_name | status              |
      | UID1                    | random       | test@gmail.com | John Doe   | PROFILE_IN_PROGRESS |

    Then I check account status
      | user_profile_identifier | status         |
      | UID1                    | PROFILE_ACTIVE |

    Given I deposit 20 SGD into account subtype HUGO_CASH of user UID1

    And I check the balance of account subtype HUGO_CASH of user UID1 is 20 SGD exact

    # invest without rate token in premium maps should fail
    Given I invest in <map_type> vault map without rate
      | user_profile_identifier | transaction_amount | investment_amount | fee_amount | status_code |
      | UID1                    | 10                 | 10                | 0          | HSA_9107    |

    Examples:
      | map_type |
      | SILVER   |
      | PLATINUM |
