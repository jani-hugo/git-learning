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

    Then I approve following products and verify product status to be PRODUCT_SUCCESS and status code is 200
      | product_id |
      | Pid1       |

    Then I deposit funds into the following funding account for Customer Profile
      | account_type | amount | currency | txn_mode |
      | FLOAT        | 1000   | SGD      | FAST     |

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
      | CAid1             | 96     | SGD      | SECRET1  | create_receiver_group |
      | CAid1             | 200    | SGD      | SECRET2  | create_receiver_group |
      | CAid1             | 300    | SGD      | SECRET3  | create_receiver_group |

    Then I verify the credit account balance after the transaction and status code as 200
      | credit_account_id |
      | CAid1             |

  Scenario: Transaction Amount Greater than Approved Limit for RC Debit Transaction Creation

    Then I create below transaction and verify the transaction status as TRANSACTION_INVALID and status code as CMSM_9643
      | credit_account_id | amount | currency | txn_code | receiver              |
      | CAid1             | 1001   | SGD      | SECRET1  | create_receiver_group |

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
      | CAid1             | 96     | SGD      | SECRET1  | <receiver_group> |

    Examples:
      | receiver_group         | status_code |
      | empty_receiver_details | E9400       |
      | empty_code_details     | E9400       |
