Feature: CMS service's Transactions Scenarios

  Background: Set Up Customer Profile

    Given I set and verify customer Cid1, customer profile CPid1 in the context

    Then I create below End-Customer-Profile
      | customer_identifier | customer_profile_identifier | end_customer_profile_identifier | first_name | last_name | region | email         | phone_number   |
      | Cid1                | CPid1                       | ECPid1                          | John       | Snow      | SG     | john@snow.com | +63 1234567890 |

    Then I verify End-Customer-Profile exist with values
      | customer_profile_identifier | end_customer_profile_identifier | first_name | last_name | email         | phone_number   | status |
      | CPid1                       | ECPid1                          | John       | Snow      | john@snow.com | +63 1234567890 | ACTIVE |

    Given I onboard HUGOHUB Customer Profile for CMS and verify onboard status as ONBOARD_SUCCESS

    Then I onboard Customer Profile Cid1 to CMS and verify onboard status as ONBOARD_SUCCESS

    Then I create following products and verify product status to be PRODUCT_DRAFT and status code is 200
      | product_id | product_name   | product_type   | description                               | product_class | profile_type | product_category | param_group              |
      | Pid1       | My Credit Card | CREDIT_ACCOUNT | Premium Credit Card for Premium Customers | STANDARD      | CUSTOMER     | GEN              | normal_case_params_group |

    Then I create the following transaction codes and verify status code is 200
      | transaction_code | iso_code | description            |
      | TXN1             | ISO1     | First transaction code |
      | TXN2             | ISO2     | Second one             |
      | TXN3             | ISO3     | Third transaction code |
      | TXN4             | ISO4     | Fourth one             |

    Then I create bucket config for product Pid1 and verify status code is 200
      | bucket_name               | bucket_code | txn_codes  | interest_type      | repayment_priority | limit_percentage | apr  |
      | Standard Interest Bucket  | STD_001     | TXN1, TXN2 | STANDARD_INTEREST  | 1                  | 50.0             | 10.5 |
      | Immediate Interest Bucket | IMD_002     | TXN3, TXN4 | IMMEDIATE_INTEREST | 2                  | 30.0             | 12.0 |

    Then I approve following products and verify product status to be PRODUCT_SUCCESS and status code is 200
      | product_id |
      | Pid1       |

    Then I onboard End Customer Profile ECPid1 to CMS and verify onboard status as ONBOARD_SUCCESS and status code as 200

    Then I create below credit accounts and verify account status is ACCOUNT_CREATED and status code is 200
      | end_customer_profile_id | account_id | product_id | country | currency | approved_limit |
      | ECPid1                  | CAid1      | Pid1       | SGP     | SGD      | 1000           |

  Scenario: Successful RC Debit Transaction Creation

    Given I fetch and set approved limit for the below credit account
      | credit_account_id |
      | CAid1             |

    Then I create below transaction and verify the transaction status as TRANSACTION_SETTLED and status code as 200
      | credit_account_id | amount | currency | txn_code | receiver              |
      | CAid1             | 96     | SGD      | TXN1     | create_receiver_group |
      | CAid1             | 200    | SGD      | TXN2     | create_receiver_group |
      | CAid1             | 300    | SGD      | TXN3     | create_receiver_group |

    Then I verify the credit account balance after the transaction and status code as 200
      | credit_account_id |
      | CAid1             |

  Scenario: Successful Transaction Limit Creation

    Then I create below transaction limit and verify the transaction status code as 200
      | product_id | limit_code | limit_description | rule_group |
      | Pid1       | 5          | XYZ               | rule_group |
      | Pid1       | 111        | ABC               | rule_group |

  Scenario: Transaction Limit Code Already Exits for Product

    Then I create below transaction limit and verify the transaction status code as 200
      | product_id | limit_code | limit_description | rule_group |
      | Pid1       | 5          | XYZ               | rule_group |

    Then I create below transaction limit and verify the transaction status code as CMSM_9761
      | product_id | limit_code | limit_description | rule_group |
      | Pid1       | 5          | XYZ               | rule_group |

  Scenario Outline: ProductId Not Found For Customer

    Then I create below transaction limit and verify the transaction status code as <status_code>
      | product_id   | limit_code | limit_description | rule_group |
      | <product_id> | 5          | XYZ               | rule_group |

    Examples:
      | product_id | status_code |
      | EMPTY      | E9400       |
      | CAid2      | CMSM_9681   |

  Scenario: Transaction Amount Greater than Approved Limit for RC Debit Transaction Creation

    Then I create below transaction and verify the transaction status as TRANSACTION_INVALID and status code as CMSM_9643
      | credit_account_id | amount | currency | txn_code | receiver              |
      | CAid1             | 1001   | SGD      | TXN1     | create_receiver_group |

  Scenario Outline: Credit Account Not Found for RC Debit Transaction Creation

    Then I create below transaction and verify the transaction status as TRANSACTION_INVALID and status code as <status_code>
      | credit_account_id | amount | currency | txn_code | receiver              |
      | <account_id>      | 96     | SGD      | SECRET1  | create_receiver_group |

    Examples:
      | account_id | status_code |
      | EMPTY      | E9400       |
      | CAid2      | CMSM_9641   |

  Scenario Outline: Receiver Details Not Found for RC Debit Transaction Creation

    Then I create below transaction and verify the transaction status as TRANSACTION_INVALID and status code as <status_code>
      | credit_account_id | amount | currency | txn_code | receiver         |
      | CAid1             | 96     | SGD      | TXN1     | <receiver_group> |

    Examples:
      | receiver_group         | status_code |
      | empty_receiver_details | E9400       |
      | empty_code_details     | E9400       |

  #Credit Repayment Scenarios

  Scenario: No dues at all -> Credit Repayment -> Top Repayment Priority Ledger -> -ve balance

    Given I fetch the original ledgers balances for credit account and verify status code as 200
      | credit_account_id |
      | CAid1             |

    Then I Initiate Dev CA Repayment and verify transaction status as TRANSACTION_SETTLED and status code as 200
      | credit_account_id | amount | currency | customer_profile_id |
      | CAid1             | 15     | SGD      | Cid1                |

    Then I fetch and verify the service transaction from fund transaction and verify status code as 200

    Then I fetch the credit repayment transaction and verify transaction status as TRANSACTION_SETTLED and status code as 200

    Then I fetch and verify the latest ledgers balances for credit account and verify status code as 200
      | credit_account_id | case    |
      | CAid1             | no_dues |

  Scenario: RC_DEBIT_TXN -> Available Ledger Balance Deduction -> Credit Repayment -> Due Deducted for Highest Priority

    Given I fetch and set approved limit for the below credit account
      | credit_account_id |
      | CAid1             |

    Then I create below transaction and verify the transaction status as TRANSACTION_SETTLED and status code as 200
      | credit_account_id | amount | currency | txn_code | receiver              |
      | CAid1             | 300    | SGD      | TXN1     | create_receiver_group |
      | CAid1             | 200    | SGD      | TXN2     | create_receiver_group |
      | CAid1             | 100    | SGD      | TXN3     | create_receiver_group |

    Given I fetch the original ledgers balances for credit account and verify status code as 200
      | credit_account_id |
      | CAid1             |

    Then I Initiate Dev CA Repayment and verify transaction status as TRANSACTION_SETTLED and status code as 200
      | credit_account_id | amount | currency | customer_profile_id |
      | CAid1             | 50     | SGD      | Cid1                |

    Then I fetch and verify the service transaction from fund transaction and verify status code as 200

    Then I fetch the credit repayment transaction and verify transaction status as TRANSACTION_SETTLED and status code as 200

    Then I fetch and verify the latest ledgers balances for credit account and verify status code as 200
      | credit_account_id | case             |
      | CAid1             | highest_priority |

  Scenario: RC_DEBIT_TXN -> Available Ledger Balance Deduction -> Credit Repayment -> Dues Deducted Priority Wise

    Given I fetch and set approved limit for the below credit account
      | credit_account_id |
      | CAid1             |

    Then I create below transaction and verify the transaction status as TRANSACTION_SETTLED and status code as 200
      | credit_account_id | amount | currency | txn_code | receiver              |
      | CAid1             | 300    | SGD      | TXN1     | create_receiver_group |
      | CAid1             | 200    | SGD      | TXN2     | create_receiver_group |
      | CAid1             | 100    | SGD      | TXN3     | create_receiver_group |

    Given I fetch the original ledgers balances for credit account and verify status code as 200
      | credit_account_id |
      | CAid1             |

    Then I Initiate Dev CA Repayment and verify transaction status as TRANSACTION_SETTLED and status code as 200
      | credit_account_id | amount | currency | customer_profile_id |
      | CAid1             | 550    | SGD      | Cid1                |

    Then I fetch and verify the service transaction from fund transaction and verify status code as 200

    Then I fetch the credit repayment transaction and verify transaction status as TRANSACTION_SETTLED and status code as 200

    Then I fetch and verify the latest ledgers balances for credit account and verify status code as 200
      | credit_account_id | case                       |
      | CAid1             | dues_spread_across_buckets |

  Scenario: RC_DEBIT_TXN -> Available Ledger Balance Deduction -> Credit Repayment -> Excess Amount -> Deducted from Topmost Priority to -ve balance

    Given I fetch and set approved limit for the below credit account
      | credit_account_id |
      | CAid1             |

    Then I create below transaction and verify the transaction status as TRANSACTION_SETTLED and status code as 200
      | credit_account_id | amount | currency | txn_code | receiver              |
      | CAid1             | 300    | SGD      | TXN1     | create_receiver_group |
      | CAid1             | 200    | SGD      | TXN2     | create_receiver_group |
      | CAid1             | 100    | SGD      | TXN3     | create_receiver_group |

    Given I fetch the original ledgers balances for credit account and verify status code as 200
      | credit_account_id |
      | CAid1             |

    Then I Initiate Dev CA Repayment and verify transaction status as TRANSACTION_SETTLED and status code as 200
      | credit_account_id | amount | currency | customer_profile_id |
      | CAid1             | 700    | SGD      | Cid1                |

    Then I fetch and verify the service transaction from fund transaction and verify status code as 200

    Then I fetch the credit repayment transaction and verify transaction status as TRANSACTION_SETTLED and status code as 200

    Then I fetch and verify the latest ledgers balances for credit account and verify status code as 200
      | credit_account_id | case             |
      | CAid1             | excess_repayment |

  Scenario: Credit Repayment -> Empty Credit Account ID

    Then I Initiate Dev CA Repayment and verify transaction status as TRANSACTION_SETTLED and status code as E9400
      | credit_account_id | amount | currency | customer_profile_id |
      | EMPTY             | 100    | SGD      | Cid1                |

  Scenario: Credit Repayment -> Empty Customer Profile ID

    Then I Initiate Dev CA Repayment and verify transaction status as TRANSACTION_SETTLED and status code as E9400
      | credit_account_id | amount | currency | customer_profile_id |
      | CAid1             | 100    | SGD      | EMPTY               |

  Scenario: Credit Repayment -> Invalid Currency

    Then I Initiate Dev CA Repayment and verify transaction status as TRANSACTION_SETTLED and status code as E9400
      | credit_account_id | amount | currency | customer_profile_id |
      | CAid1             | 100    | SGDA     | Cid1                |
