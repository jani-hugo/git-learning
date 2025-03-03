Feature: CMS service's Credit Account scenarios

  Background: Set Customer Profile
    Given I set and verify customer Cid1, customer profile CPid1 in the context

    Then I create below End-Customer-Profile
      | customer_identifier | customer_profile_identifier | end_customer_profile_identifier | first_name   | last_name   | region   | email         | phone_number   |
      | Cid1                | CPid1                       | ECPid1                          | John         | Snow        | SG       | john@snow.com | +63 1234567890 |

    Then I verify End-Customer-Profile exist with values
      | customer_profile_identifier | end_customer_profile_identifier | first_name   | last_name   | email         | phone_number   | status |
      | CPid1                       | ECPid1                          |  John        | Snow        | john@snow.com | +63 1234567890 | ACTIVE |

  Scenario Outline: Create Credit Account

    Given I onboard HUGOHUB Customer Profile for CMS with <payment_provider> and verify onboard status as ONBOARD_SUCCESS

    Then I onboard Customer Profile to CMS with <payment_provider> and verify onboard status as ONBOARD_SUCCESS

    Then I create following products and verify product status to be PRODUCT_APPROVAL_PENDING
      | product_id | product_name   | product_type             | description                               | product_class | profile_type | product_category |
      | Pid1       | My Credit Card | CREDIT_ACCOUNT           | Premium Credit Card for Premium Customers | STANDARD      | CUSTOMER     | category1        |

    Then I approve following products and verify product status to be PRODUCT_SUCCESS
      | product_id |
      | Pid1       |

    Then I onboard End Customer Profile ECPid1 to CMS with <payment_provider> and verify onboard status as ONBOARD_SUCCESS

     Then I create below credit accounts and verify account status is ACCOUNT_CREATED
       | end_customer_profile_id | account_id | product_id | country | currency | approved_limit |
       | ECPid1                  | CAid1      | Pid1       | SGP     | SGD      | 100000         |
       | ECPid1                  | CAid2      | Pid1       | SGP     | SGD      | 50000          |
       | ECPid1                  | CAid3      | Pid1       | SGP     | SGD      | 30000          |

    Examples:
      | payment_provider |
      | DBS              |
