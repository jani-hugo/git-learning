Feature: ETF Vault Feature

  Scenario: Open Hugosave Premium account
    Given I open user account
      | user_profile_identifier | phone_number | email          | legal_name | name   | status              | prefix_ph_num |
      | UID1                    | random       | test@gmail.com | John Doe   | Johnny | PROFILE_IN_PROGRESS | +3731         |

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
