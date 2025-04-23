Feature: CMS service's Loan Account scenarios

  Background: Set Customer Profile

    Given I set and verify customer Cid1, customer profile CPid1 in the context

    Given I onboard HUGOHUB Customer Profile for CMS and verify onboard status as ONBOARD_SUCCESS

    Then I onboard Customer Profile Cid1 to CMS and verify onboard status as ONBOARD_SUCCESS

    Then I create below End-Customer-Profile
      | customer_identifier | customer_profile_identifier | end_customer_profile_identifier | first_name   | last_name   | region   | email         | phone_number   |
      | Cid1                | CPid1                       | ECPid1                          | John         | Snow        | SG       | john@snow.com | +63 1234567890 |

    Then I verify End-Customer-Profile exist with values
      | customer_profile_identifier | end_customer_profile_identifier | first_name | last_name | email         | phone_number   | status |
      | CPid1                       | ECPid1                          | John       | Snow      | john@snow.com | +63 1234567890 | ACTIVE |

    Then I onboard End Customer Profile ECPid1 to CMS and verify onboard status as ONBOARD_SUCCESS and status code as 200

    Then I create following products and verify product status to be PRODUCT_DRAFT and status code is 200
      | product_id | product_name    | product_type | description             | product_class | profile_type | product_category | param_group                     |
      | Pid1       | My Loan Account | LOAN_ACCOUNT | LOAN ACCOUNT FOR MYSELF | STANDARD      | CUSTOMER     | GEN              | normal_case_loan_account_params |

    Then I approve following products and verify product status to be PRODUCT_SUCCESS and status code is 200
      | product_id |
      | Pid1       |
  Scenario: Successful Loan Account Creation
    Then I create below loan accounts and verify account status is ACCOUNT_CREATED and status code is 200
      | end_customer_profile_id | account_id | product_id | approved_amount | tenure | interest_rate |
      | ECPid1                  | LAid1      | Pid1       | 100000          | 24     | 7.5           |
  Scenario: Attempt to Create Loan Account for Unknown Product

    Then I create below loan accounts and verify account status is ACCOUNT_CREATED and status code is CMSM_9681
      | end_customer_profile_id | account_id | product_id | approved_amount | tenure | interest_rate |
      | ECPid1                  | LAid1      | dummyPid   | 100000           | 24     | 6.5           |

  Scenario: Failed Loan Account Creation due to Inactive Product

    Then I create following products and verify product status to be PRODUCT_DRAFT and status code is 200
      | product_id | product_name | product_type | description                     | product_class | profile_type | product_category | param_group                     |
      | Pid2       | My Loan      | LOAN_ACCOUNT | Personal Loan for End Customers | STANDARD      | CUSTOMER     | GEN              | normal_case_loan_account_params |

    Then I create below loan accounts and verify account status is ACCOUNT_CREATION_FAILED and status code is CMSM_9683
      | end_customer_profile_id | account_id | product_id | approved_amount | tenure | interest_rate |
      | ECPid1                  | LAid1      | Pid2        | 100000          | 24     | 6.5           |
