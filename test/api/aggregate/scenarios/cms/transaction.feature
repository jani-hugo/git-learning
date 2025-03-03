Feature: CMS service's Card Transactions Scenarios

  Background: Set Customer Profile
    Given I set and verify customer Cid1, customer profile CPid1 in the context

    Then I create below End-Customer-Profile
      | customer_identifier | customer_profile_identifier | end_customer_profile_identifier | first_name | last_name | region | email         | phone_number   |
      | Cid1                | CPid1                       | ECPid1                          | John       | Snow      | SG     | john@snow.com | +63 1234567890 |

    Then I verify End-Customer-Profile exist with values
      | customer_profile_identifier | end_customer_profile_identifier | first_name | last_name | email         | phone_number   | status |
      | CPid1                       | ECPid1                          | John       | Snow      | john@snow.com | +63 1234567890 | ACTIVE |

    Given I onboard HUGOHUB Customer Profile for CMS with DBS and verify onboard status as ONBOARD_SUCCESS

    Then I onboard Customer Profile to CMS with DBS and verify onboard status as ONBOARD_SUCCESS

    Then I create following products and verify product status to be PRODUCT_APPROVAL_PENDING
      | product_id | product_name   | product_type             | description                               | product_class | profile_type | product_category |
      | Pid1       | My Credit Card | CREDIT_ACCOUNT_REVOLVING | Premium Credit Card for Premium Customers | STANDARD      | CUSTOMER     | category1        |

    Then I approve following products and verify product status to be PRODUCT_SUCCESS
      | product_id |
      | Pid1       |

    # Check how to reuse this step for other currencies
    # How to use Background with Examples
    Then I deposit funds into the following funding account for Customer Profile
      | account_type | amount | currency | txn_mode |
      | FLOAT        | 1000   | SGD      | FAST     |

    Then I onboard End Customer Profile ECPid1 to CMS with DBS and verify onboard status as ONBOARD_SUCCESS

    Then I create below credit accounts and verify account status is ACCOUNT_CREATED
      | end_customer_profile_id | account_id | product_id | country | currency | approved_limit |
      | ECPid1                  | CAid1      | Pid1       | SGP     | SGD      | 1000           |

    Then I attach card to below credit accounts
      | end_customer_profile_id | account_id |
      | ECPid1                  | CAid1      |

  Scenario: Auth -> Clear Same Amount

    Then I create below auth transactions and verify balances
      | transaction_id | account_id | message_type | currency | amount | status_code | status               | metadata         |
      | Tid11          | CAid1      | REQUEST      | SGD      | 56.23  | 200         | AUTHORIZATION_APPROVED | {"Category":"1"} |
      | Tid12          | CAid1      | REQUEST      | SGD      | 45.86  | 200         | AUTHORIZATION_APPROVED | {"Category":"2"} |
      | Tid13          | CAid1      | REQUEST      | SGD      | 96.25  | 200         | AUTHORIZATION_APPROVED | {"Category":"3"} |

    Then I clear below transactions
      | transaction_id | clearing_group_id | amount | status_code | status              |
      | Tid11          | ClearingGrp1      | 56.23  | 200         | TRANSACTION_SETTLED |
      | Tid12          | ClearingGrp1      | 45.86  | 200         | TRANSACTION_SETTLED |
      | Tid13          | ClearingGrp1      | 96.25  | 200         | TRANSACTION_SETTLED |

  Scenario: Auth -> Clear Partial Amount -> Clear Remaining Amount

    Then I create below auth transactions and verify balances
      | transaction_id | account_id | message_type | currency | amount | status_code | status               | metadata         |
      | Tid21          | CAid1      | REQUEST      | SGD      | 67.34  | 200         | TRANSACTION_APPROVED | {"Category":"1"} |
      | Tid22          | CAid1      | REQUEST      | SGD      | 67.34  | 200         | TRANSACTION_APPROVED | {"Category":"2"} |

    Then I clear below transactions
      # here status is for original transaction when partially cleared
      | transaction_id | clearing_group_id | amount | status_code | status               |
      | Tid21          | ClearingGrp1      | 37.12  | 200         | TRANSACTION_APPROVED |
      | Tid21          | ClearingGrp1      | 30.22  | 200         | TRANSACTION_SETTLED  |
      | Tid22          | ClearingGrp1      | 37.12  | 200         | TRANSACTION_APPROVED |
      | Tid22          | ClearingGrp1      | 30.22  | 200         | TRANSACTION_SETTLED  |

  Scenario: Auth -> Clear Higher Amount

    Then I create below auth transactions and verify balances
      | transaction_id | account_id | message_type | currency | amount | status_code | status               | metadata         |
      | Tid31          | CAid1      | REQUEST      | SGD      | 259.48 | 200         | TRANSACTION_APPROVED | {"Category":"1"} |
      | Tid32          | CAid1      | REQUEST      | SGD      | 259.48 | 200         | TRANSACTION_APPROVED | {"Category":"2"} |

    Then I clear below transactions
      | transaction_id | clearing_group_id | amount | status_code | status              |
      | Tid31          | ClearingGrp1      | 262.07 | 200         | TRANSACTION_SETTLED |
      | Tid32          | ClearingGrp1      | 262.07 | 200         | TRANSACTION_SETTLED |

  Scenario: Auth Txn rejected for Insufficient credit limit

    Then I create below auth transactions and verify balances
      | transaction_id | account_id | message_type | currency | amount | status_code | status | metadata         |
      | Tid41          | CAid1      | REQUEST      | SGD      | 12000  | CMSM_9801   | -      | {"Category":"1"} |
      | Tid42          | CAid1      | REQUEST      | SGD      | 12000  | CMSM_9801   | -      | {"Category":"2"} |

  Scenario: Auth -> Update to Same Amount -> Clear Same Amount

    Then I create below auth transactions and verify balances
      | transaction_id | account_id | message_type | currency | amount | status_code | status               | metadata         |
      | Tid11          | CAid1      | REQUEST      | SGD      | 45.37  | 200         | TRANSACTION_APPROVED | {"Category":"1"} |
      | Tid12          | CAid1      | REQUEST      | SGD      | 45.37  | 200         | TRANSACTION_APPROVED | {"Category":"2"} |

    Then I update below auth transactions and verify balances
      | transaction_id | account_id | message_type | amount | status_code | status               | metadata         |
      | Tid11          | CAid1      | REQUEST      | 45.37  | 200         | TRANSACTION_APPROVED | {"Category":"1"} |
      | Tid12          | CAid1      | REQUEST      | 45.37  | 200         | TRANSACTION_APPROVED | {"Category":"2"} |

    Then I clear below transactions
      | transaction_id | clearing_group_id | amount | status_code | status              |
      | Tid11          | ClearingGrp1      | 45.37  | 200         | TRANSACTION_SETTLED |
      | Tid12          | ClearingGrp1      | 45.37  | 200         | TRANSACTION_SETTLED |

  Scenario: Auth -> Update to Lower Amount -> Clear Updated Amount

    Then I create below auth transactions and verify balances
      | transaction_id | account_id | message_type | currency | amount | status_code | status               | metadata         |
      | Tid21          | CAid1      | REQUEST      | SGD      | 153.24 | 200         | TRANSACTION_APPROVED | {"Category":"1"} |
      | Tid22          | CAid1      | REQUEST      | SGD      | 153.24 | 200         | TRANSACTION_APPROVED | {"Category":"2"} |

    Then I update below auth transactions and verify balances
      | transaction_id | account_id | message_type | amount | status_code | status               | metadata         |
      | Tid21          | CAid1      | REQUEST      | 124.56 | 200         | TRANSACTION_APPROVED | {"Category":"1"} |
      | Tid22          | CAid1      | REQUEST      | 124.56 | 200         | TRANSACTION_APPROVED | {"Category":"2"} |

    Then I clear below transactions
      | transaction_id | clearing_group_id | amount | status_code | status              |
      | Tid21          | ClearingGrp1      | 124.56 | 200         | TRANSACTION_SETTLED |
      | Tid22          | ClearingGrp1      | 124.56 | 200         | TRANSACTION_SETTLED |

  Scenario: Auth -> Update to Higher Amount -> Clear Updated Amount

    Then I create below auth transactions and verify balances
      | transaction_id | account_id | message_type | currency | amount | status_code | status               | metadata         |
      | Tid31          | CAid1      | REQUEST      | SGD      | 78.58  | 200         | TRANSACTION_APPROVED | {"Category":"1"} |
      | Tid32          | CAid1      | REQUEST      | SGD      | 78.58  | 200         | TRANSACTION_APPROVED | {"Category":"2"} |

    Then I update below auth transactions and verify balances
      | transaction_id | account_id | message_type | amount | status_code | status               | metadata         |
      | Tid31          | CAid1      | REQUEST      | 85.4   | 200         | TRANSACTION_APPROVED | {"Category":"1"} |
      | Tid32          | CAid1      | REQUEST      | 85.4   | 200         | TRANSACTION_APPROVED | {"Category":"1"} |

    Then I clear below transactions
      | transaction_id | clearing_group_id | amount | status_code | status              |
      | Tid31          | ClearingGrp1      | 85.4   | 200         | TRANSACTION_SETTLED |
      | Tid32          | ClearingGrp1      | 85.4   | 200         | TRANSACTION_SETTLED |

  Scenario: Auth -> Update Txn rejected for Insufficient credit limit

    Then I create below auth transactions and verify balances
      | transaction_id | account_id | message_type | currency | amount | status_code | status               | metadata         |
      | Tid41          | CAid1      | REQUEST      | SGD      | 62.34  | 200         | TRANSACTION_APPROVED | {"Category":"1"} |
      | Tid42          | CAid1      | REQUEST      | SGD      | 62.34  | 200         | TRANSACTION_APPROVED | {"Category":"2"} |

    Then I update below auth transactions and verify balances
      | transaction_id | account_id | message_type | amount | status_code | status | metadata         |
      | Tid41          | CAid1      | REQUEST      | 1100   | CMSM_9801   | NA     | {"Category":"1"} |
      | Tid42          | CAid1      | REQUEST      | 1100   | CMSM_9801   | NA     | {"Category":"2"} |

  Scenario: Auth Advice (insufficient credit) -> Clear Same Amount

    Then I create below auth transactions and verify balances
      | transaction_id | account_id | message_type | currency | amount  | status_code | status               | metadata         |
      | Tid11          | CAid1      | ADVICE       | SGD      | 1176.34 | 200         | TRANSACTION_APPROVED | {"Category":"1"} |
      | Tid12          | CAid1      | ADVICE       | SGD      | 1176.34 | 200         | TRANSACTION_APPROVED | {"Category":"2"} |

    Then I clear below transactions
      | transaction_id | clearing_group_id | amount  | status_code | status              |
      | Tid11          | ClearingGrp1      | 1176.34 | 200         | TRANSACTION_SETTLED |
      | Tid12          | ClearingGrp1      | 1176.34 | 200         | TRANSACTION_SETTLED |

  Scenario: Auth Advice (insufficient credit) -> Update Advice (higher amount) -> Clear Updated Amount

    Then I create below auth transactions and verify balances
      | transaction_id | account_id | message_type | currency | amount  | status_code | status               | metadata         |
      | Tid21          | CAid1      | ADVICE       | SGD      | 1040.65 | 200         | TRANSACTION_APPROVED | {"Category":"1"} |
      | Tid22          | CAid1      | ADVICE       | SGD      | 1040.65 | 200         | TRANSACTION_APPROVED | {"Category":"2"} |

    Then I update below auth transactions and verify balances
      | transaction_id | account_id | message_type | amount  | status_code | status               | metadata         |
      | Tid21          | CAid1      | ADVICE       | 1080.78 | 200         | TRANSACTION_APPROVED | {"Category":"1"} |
      | Tid22          | CAid1      | ADVICE       | 1080.78 | 200         | TRANSACTION_APPROVED | {"Category":"2"} |

    Then I clear below transactions
      | transaction_id | clearing_group_id | amount  | status_code | status               |
      | Tid21          | ClearingGrp1      | 1080.78 | 200         | TRANSACTION_APPROVED |
      | Tid22          | ClearingGrp1      | 1080.78 | 200         | TRANSACTION_APPROVED |

  Scenario: Auth Advice (insufficient credit for L1 Ledger) -> Update No Advice (lower amount) -> Clear updated amount

    Then I create below auth transactions and verify balances
      | transaction_id | account_id | message_type | currency | amount  | status_code | status               | metadata         |
      | Tid41          | CAid1      | ADVICE       | SGD      | 1020.56 | 200         | TRANSACTION_APPROVED | {"Category":"1"} |

    Then I update below auth transactions and verify balances
      | transaction_id | account_id | message_type | amount | status_code | status               | metadata         |
      | Tid41          | CAid1      | REQUEST      | 998.45 | 200         | TRANSACTION_APPROVED | {"Category":"1"} |

    Then I clear below transactions
      | transaction_id | clearing_group_id | amount | status_code | status              |
      | Tid41          | ClearingGrp1      | 998.45 | 200         | TRANSACTION_SETTLED |

  Scenario: Auth Advice (insufficient credit for L2 Ledger) -> Update No Advice (lower amount) -> Clear updated amount

    Then I create below auth transactions and verify balances
      | transaction_id | account_id | message_type | currency | amount  | status_code | status               | metadata         |
      | Tid41          | CAid1      | ADVICE       | SGD      | 1020.56 | 200         | TRANSACTION_APPROVED | {"Category":"2"} |

    Then I update below auth transactions and verify balances
      | transaction_id | account_id | message_type | amount | status_code | status               | metadata         |
      | Tid41          | CAid1      | REQUEST      | 998.45 | 200         | TRANSACTION_APPROVED | {"Category":"2"} |

    Then I clear below transactions
      | transaction_id | clearing_group_id | amount | status_code | status              |
      | Tid41          | ClearingGrp1      | 998.45 | 200         | TRANSACTION_SETTLED |

  Scenario: Auth Advice (insufficient credit) -> Update No Advice (higher amount, update should fail) -> Clear original amount

    Then I create below auth transactions and verify balances
      | transaction_id | account_id | message_type | currency | amount  | status_code | status               | metadata         |
      | Tid51          | CAid1      | ADVICE       | SGD      | 1020.56 | 200         | TRANSACTION_APPROVED | {"Category":"1"} |
      | Tid52          | CAid1      | ADVICE       | SGD      | 1020.56 | 200         | TRANSACTION_APPROVED | {"Category":"2"} |

    Then I update below auth transactions and verify balances
      | transaction_id | account_id | message_type | amount  | status_code | status               | metadata         |
      | Tid51          | CAid1      | REQUEST      | 1060.63 | CMSM_9801   | TRANSACTION_APPROVED | {"Category":"1"} |
      | Tid52          | CAid1      | REQUEST      | 1060.63 | CMSM_9801   | TRANSACTION_APPROVED | {"Category":"2"} |

    Then I clear below transactions
      | transaction_id | clearing_group_id | amount  | status_code | status              |
      | Tid51          | ClearingGrp1      | 1020.56 | 200         | TRANSACTION_SETTLED |
      | Tid52          | ClearingGrp1      | 1020.56 | 200         | TRANSACTION_SETTLED |

  Scenario: Auth -> Revert
    Then I create below auth transactions and verify balances
      | transaction_id | account_id | message_type | currency | amount | status_code | status               | metadata         |
      | Tid51          | CAid1      | REQUEST      | SGD      | 30.56  | 200         | TRANSACTION_APPROVED | {"Category":"1"} |
      | Tid52          | CAid1      | REQUEST      | SGD      | 30.56  | 200         | TRANSACTION_APPROVED | {"Category":"2"} |

    Then I revert the following transactions
      | transaction_id | status_code | status               | refund |
      | Tid51          | 200         | TRANSACTION_REVERTED | False  |
      | Tid52          | 200         | TRANSACTION_REVERTED | False  |

  Scenario: Auth -> Clear -> Revert (should fail)

    Then I create below auth transactions and verify balances
      | transaction_id | account_id | advice | currency | transaction_amount | status_code | status                     | metadata         |
      | Tid61          | CAid1      | False  | SGD      | 15.23              | 200         | TRANSACTION_AMOUNT_BLOCKED | {"Category":"1"} |
      | Tid62          | CAid1      | False  | SGD      | 15.23              | 200         | TRANSACTION_AMOUNT_BLOCKED | {"Category":"2"} |

    Then I clear below transactions
      | transaction_id | clearing_group_id | clearing_amount | status_code | status              |
      | Tid61          | ClearingGrp1      | 15.23           | 200         | TRANSACTION_SETTLED |
      | Tid62          | ClearingGrp1      | 15.23           | 200         | TRANSACTION_SETTLED |

    Then I revert the following transactions
      | transaction_id | status_code | status              | refund |
      | Tid61          | CMSM_9803   | TRANSACTION_SETTLED | False  |
      | Tid62          | CMSM_9803   | TRANSACTION_SETTLED | False  |

  Scenario: Refund Auth -> Refund Clear

    Then I create below refund auth transactions
      | transaction_id | account_id | advice | currency | transaction_amount | status_code | status                | metadata         |
      | Tid6           | CAid1      | False  | SGD      | 15.23              | 200         | TRANSACTION_INITIATED | {"Category":"1"} |

    Then I clear below refund auth transactions
      | transaction_id | group_id     | clearing_amount | status_code | status              |
      | Tid6           | ClearingGrp1 | 15.23           | 200         | TRANSACTION_SETTLED |

  Scenario: Refund Auth -> Refund Revert

    Then I create below refund auth transactions
      | transaction_id | account_id | advice | currency | transaction_amount | status_code | status                | metadata         |
      | Tid6           | CAid1      | False  | SGD      | 15.23              | 200         | TRANSACTION_INITIATED | {"Category":"1"} |

    Then I revert the following transactions
      | transaction_id | status_code | status               | refund |
      | Tid6           | 200         | TRANSACTION_REVERTED | True   |

  Scenario: Auth -> Multiple Clear -> Reconcile -> Send

    Then I create below auth transactions and verify balances
      | transaction_id | account_id | advice | currency | transaction_amount | status_code | status                     | metadata         |
      | Tid1           | CAid1      | False  | SGD      | 10                 | 200         | TRANSACTION_AMOUNT_BLOCKED | {"Category":"1"} |
      | Tid2           | CAid1      | False  | SGD      | 20                 | 200         | TRANSACTION_AMOUNT_BLOCKED | {"Category":"1"} |
      | Tid3           | CAid1      | False  | SGD      | 30                 | 200         | TRANSACTION_AMOUNT_BLOCKED | {"Category":"1"} |

    Then I clear below transactions
      | transaction_id | group_id     | clearing_amount | status_code | status              |
      | Tid1           | ClearingGrp1 | 10              | 200         | TRANSACTION_SETTLED |
      | Tid2           | ClearingGrp2 | 20              | 200         | TRANSACTION_SETTLED |
      | Tid3           | ClearingGrp2 | 30              | 200         | TRANSACTION_SETTLED |

    Then I reconcile clearing group and verify amount and transaction count
      | group_id     | total_amount | txn_count |
      | ClearingGrp1 | 10           | 1         |
      | ClearingGrp2 | 50           | 2         |

    Then I send total amount for clearing groups and verify transaction status
      | group_id     | total_amount | currency | status_code | transaction_status  |
      | ClearingGrp1 | 10           | SGD      | 200         | TRANSACTION_SETTLED |
      | ClearingGrp2 | 50           | SGD      | 200         | TRANSACTION_SETTLED |


  Scenario: Auth -> Clear -> Reconcile -> Send -> Auth -> Clear with used group id (Should Fail)

    Then I create below auth transactions and verify balances
      | transaction_id | account_id | advice | currency | transaction_amount | status_code | status                     | metadata         |
      | Tid6           | CAid1      | False  | SGD      | 15.23              | 200         | TRANSACTION_AMOUNT_BLOCKED | {"Category":"1"} |

    Then I clear below transactions
      | transaction_id | group_id     | clearing_amount | status_code | status              |
      | Tid6           | ClearingGrp2 | 15.23           | 200         | TRANSACTION_SETTLED |

    Then I reconcile clearing group and verify amount and transaction count
      | group_id     | total_amount | txn_count |
      | ClearingGrp2 | 15.23        | 1         |

    Then I send total amount for clearing groups and verify transaction status
      | group_id     | total_amount | currency | status_code | transaction_status  |
      | ClearingGrp2 | 15.23        | SGD      | 200         | TRANSACTION_SETTLED |

    Then I create below auth transactions and verify balances
      | transaction_id | account_id | advice | currency | transaction_amount | status_code | status                     | metadata         |
      | Tid6           | CAid1      | False  | SGD      | 15.23              | 200         | TRANSACTION_AMOUNT_BLOCKED | {"Category":"1"} |

    Then I clear below transactions
      | transaction_id | group_id     | clearing_amount | status_code | status |
      | Tid6           | ClearingGrp2 | 15.23           | E9400       | -      |


  Scenario: Auth -> Multiple Clear -> Reconcile -> Send with wrong amount (Should Fail)

    Then I create below auth transactions and verify balances
      | transaction_id | account_id | advice | currency | transaction_amount | status_code | status                     | metadata         |
      | Tid6           | CAid1      | False  | SGD      | 15.23              | 200         | TRANSACTION_AMOUNT_BLOCKED | {"Category":"1"} |
      | Tid7           | CAid1      | False  | SGD      | 20.27              | 200         | TRANSACTION_AMOUNT_BLOCKED | {"Category":"1"} |

    Then I clear below transactions
      | transaction_id | group_id     | clearing_amount | status_code | status              |
      | Tid6           | ClearingGrp3 | 15.23           | 200         | TRANSACTION_SETTLED |
      | Tid7           | ClearingGrp3 | 20.27           | 200         | TRANSACTION_SETTLED |

    Then I reconcile clearing group and verify amount and transaction count
      | group_id     | total_amount | txn_count |
      | ClearingGrp3 | 35.50        | 2         |

    Then I send total amount for clearing groups and verify transaction status
      | group_id     | total_amount | currency | status_code | transaction_status  |
      | ClearingGrp3 | 46           | SGD      | E9400       | TRANSACTION_SETTLED |

