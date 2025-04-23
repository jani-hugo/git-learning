Feature: Cash Service Settle transactions of various cases on wallets with Cash Accounts

  Background: Setup customer and end-customer profile on banking

     #CustomerProfile verifying and Onboarding on to banking service on given providers
    Given I set and verify customer BCID1, customer profile BCPID1 on cash service on below providers and expect status 200 in the context
      | provider_name |
      | DBS Bank Ltd  |

    Then I wait until max time to verify CustomerProfile BCPID1 onboard status as ONBOARD_SUCCESS

    Then I create below End-Customer-Profile
      | customer_identifier | customer_profile_identifier | end_customer_profile_identifier | first_name | last_name | region | email   | phone_number |
      | BCID1               | BCPID1                      | ECPID1                          | banking    | service   | SG     | x@y.com | 00000000     |

    Then I verify End-Customer-Profile exist with values
      | customer_profile_identifier | end_customer_profile_identifier | customer_profile_id | first_name | last_name | email   | phone_number | status |
      | BCPID1                      | ECPID1                          | BCPID1              | banking    | service   | x@y.com | 00000000     | ACTIVE |

    # EndCustomerProfile Onboarding
    Given I onboard EndCustomerProfile ECPID1 of CustomerProfile BCPID1 on cash service on below providers and expect status 200
      | provider_name |
      | DBS Bank Ltd  |

    Then I wait until max time to verify EndCustomerProfile ECPID1 of CustomerProfile BCPID1 onboard status as ONBOARD_SUCCESS

    Given I create a cash account product with customer profile BCPID1 provider as DBS Bank Ltd and expect product_status PRODUCT_DRAFT
      | identifier           | product_type         | profile_type | product_class | num_of_active_account |
      | CashAccProductId1    | CASH_ACCOUNT         | CUSTOMER     |  SHARIAH      | 1                     |

    Then I approve the product CashAccProductId1 and verify status as PRODUCT_SUCCESS with provider DBS Bank Ltd for customerProfileId BCPID1

    Given I create a cash account product with customer profile BCPID1 provider as DBS Bank Ltd and expect product_status PRODUCT_DRAFT
      | identifier          | product_type         | profile_type     | product_class | num_of_active_account |
      | CashAccProductId2   | CASH_ACCOUNT         | END_CUSTOMER     |  SHARIAH      | 1                     |

    Then I approve the product CashAccProductId2 and verify status as PRODUCT_SUCCESS with provider DBS Bank Ltd for customerProfileId BCPID1


    ############## Settle Transactions with user having adequate balances#################
  Scenario Outline: User has available balance, then user initiate a transaction with an amount less than the available balance. now user Settle transaction with settle amount is equal to initial blocked amount.

    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier    | product_type   | profile_type | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type    |
      | ProductID1    | WALLET         | CUSTOMER     |  SHARIAH      | <currency> | <country> | SAVINGS      | 0                       | STRICT                 |

    Then I approve the product ProductID1 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Then I create a cash account with id CashAccId1 customerProfileId BCPID1 with product id CashAccProductId1 and expect status as CASH_ACCOUNT_CREATED

    Given I create account for CustomerProfile with id BCPID1 with product id as ProductID1 with bank account type as Payments Account with provider DBS Bank Ltd and expect the header status 200
      | identifier         | customer_profile_id | currency | country | in_trust  | on_behalf_of | metadata              | kyc_completed | trust_verification_completed | cash_account_id |
      | CustomerProfileBA1 | IntegrationTest1    | SGD      | SGP     | false     | CUSTOMER     | {"key": "MyMetaData"} | false         | false                        | CashAccId1      |

    Then I wait until max time to verify the bank account CustomerProfileBA1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    Then I create a end customer cash account with id CashAccId2 customerProfileID BCPID1 with product id CashAccProductId2 and endCustomerProfileId ECPID1 and expect status as CASH_ACCOUNT_CREATED

    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier    | product_type  | profile_type     | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type    |
      | ProductID2    | WALLET        | END_CUSTOMER     |  SHARIAH      | <currency> | <country> | SAVINGS      | <balance_policy_limit>  | <balance_policy_type>  |

    Then I approve the product ProductID2 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Given I create account for EndCustomerProfile with id ECPID1 for CustomerProfile BCPID1 with product id ProductID2 with bank account type as <account_type> with provider <bank_name> and expect the header status 200
      | identifier | customer_profile_id | end_customer_profile_id          | currency   | country | in_trust    | on_behalf_of | metadata                           | cash_account_id |
      | BankAccId1 | BCPID1              | 36974646-3489-47aa-b6c2-w232d543 | <currency> | SGP     | false       | CUSTOMER     | {"key": "TransactionIntegration1"} | CashAccId2      |

    Then I wait until max time to verify the bank account BankAccId1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    Given I deposit an amount of <deposit_amount> into BankAccId1 using cash DevDeposit and expect the header status 200
      | identifier           | customer_profile_id             | purpose  | currency | transaction_rail |
      | DevDepositIdentifier | BCPID1                          | TRANSFER | SGD      | FAST             |

    Then I wait until max time to verify bank account BankAccId1 with an increased balance of <deposit_amount> for customerProfileId BCPID1

    Then I initiate transaction to transfer funds with below details and expect the header statuscode <status_code> and transaction status as TRANSACTION_AMOUNT_BLOCKED
      | identifier | customer_profile_id | account_id | amount                        | purpose          | is_overdraft_allowed | metadata              | currency | sub_txn_type | receiver_account_id |
      | TxId1      | BCPID1              | BankAccId1 | <initiate_transaction_amount> | Integration Test | false                | {"key": "MyMetaData"} | SGD      | CARD_TXN     |                     |

    Then I verify for bank account BankAccId1 total balance is <initial_total_balance> and available balance is <initial_available_balance> for customerProfileId BCPID1

    Then I settle transaction to transfer funds with below details and expect the header statuscode <status_code> and transaction_status as <txn_status>
      | transaction_id | customer_profile_id | amount             | transaction_rail   | is_overdraft_allowed | metadata              |
      | TxId1          | BCPID1              | <requested_amount> | <transaction_rail> | false                | {"key": "MyMetaData"} |

    Then I wait until max time to verify the transaction TxId1 status as <txn_status> for customerProfileId BCPID1

    Then I wait until max time to verify bank account BankAccId1 with an available balance of <updated_available_balance> and total balance of <updated_total_balance> for customerProfileId BCPID1

    Examples:
      | deposit_amount | initiate_transaction_amount | requested_amount | currency | bank_name    | account_type | transaction_rail | initial_total_balance | initial_available_balance | updated_total_balance | updated_available_balance | status_code | txn_status          | country | balance_policy_limit | balance_policy_type | cash_provider_id | payment_provider_id |
      | 150            | 100                         | 100              | SGD      | DBS Bank Ltd | e-money      | FAST             | 150                   | 50                        | 50                    | 50                        | 200         | TRANSACTION_SETTLED | SGP     | 0                    | LENIENT             |                  |                     |

  Scenario Outline: User has available balance, then user initiates a transaction with an amount, less than the available balance. now user settles the transaction with settle amount greater than the initial blocked amount but less than the user available balance.

    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier    | product_type   | profile_type | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type    |
      | ProductID1    | WALLET         | CUSTOMER     |  SHARIAH      | <currency> | <country> | SAVINGS      | 0                       | STRICT                 |

    Then I approve the product ProductID1 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Then I create a cash account with id CashAccId1 customerProfileId BCPID1 with product id CashAccProductId1 and expect status as CASH_ACCOUNT_CREATED

    Given I create account for CustomerProfile with id BCPID1 with product id as ProductID1 with bank account type as Payments Account with provider DBS Bank Ltd and expect the header status 200
      | identifier         | customer_profile_id | currency | country | in_trust | is_overdraft_allowed | on_behalf_of | metadata              | kyc_completed | trust_verification_completed | cash_account_id |
      | CustomerProfileBA1 | IntegrationTest1    | SGD      | SGP     | false    | false                | CUSTOMER     | {"key": "MyMetaData"} | false         | false                        | CashAccId1      |

    Then I wait until max time to verify the bank account CustomerProfileBA1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier    | product_type   | profile_type     | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type    |
      | ProductID2    | WALLET         | END_CUSTOMER     |  SHARIAH      | <currency> | <country> | SAVINGS      | <balance_policy_limit>  | <balance_policy_type>  |

    Then I approve the product ProductID2 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Then I create a end customer cash account with id CashAccId2 customerProfileID BCPID1 with product id CashAccProductId2 and endCustomerProfileId ECPID1 and expect status as CASH_ACCOUNT_CREATED

    Given I create account for EndCustomerProfile with id ECPID1 for CustomerProfile BCPID1 with product id ProductID2 with bank account type as <account_type> with provider <bank_name> and expect the header status 200
      | identifier | customer_profile_id | end_customer_profile_id          | currency   | country | in_trust    | on_behalf_of | metadata                           | cash_account_id |
      | BankAccId1 | BCPID1              | 36974646-3489-47aa-b6c2-w232d543 | <currency> | SGP     | false       | CUSTOMER     | {"key": "TransactionIntegration1"} | CashAccId2      |

    Then I wait until max time to verify the bank account BankAccId1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    Given I deposit an amount of <deposit_amount> into BankAccId1 using cash DevDeposit and expect the header status 200
      | identifier           | customer_profile_id             | purpose  | currency | transaction_rail |
      | DevDepositIdentifier | BCPID1                          | TRANSFER | SGD      | FAST             |

    Then I wait until max time to verify bank account BankAccId1 with an increased balance of <deposit_amount> for customerProfileId BCPID1

    Then I initiate transaction to transfer funds with below details and expect the header statuscode <status_code> and transaction status as TRANSACTION_AMOUNT_BLOCKED
      | identifier | customer_profile_id | account_id | amount                        | purpose          | is_overdraft_allowed | metadata              | currency | sub_txn_type | receiver_account_id |
      | TxId1      | BCPID1              | BankAccId1 | <initiate_transaction_amount> | Integration Test | false                | {"key": "MyMetaData"} | SGD      | CARD_TXN     |                     |

    Then I verify for bank account BankAccId1 total balance is <initial_total_balance> and available balance is <initial_available_balance> for customerProfileId BCPID1

    Then I settle transaction to transfer funds with below details and expect the header statuscode <status_code> and transaction_status as <txn_status>
      | transaction_id | customer_profile_id | amount             | transaction_rail   | is_overdraft_allowed | metadata              |
      | TxId1          | BCPID1              | <requested_amount> | <transaction_rail> | false                | {"key": "MyMetaData"} |

    Then I wait until max time to verify the transaction TxId1 status as <txn_status> for customerProfileId BCPID1

    Then I wait until max time to verify bank account BankAccId1 with an available balance of <updated_available_balance> and total balance of <updated_total_balance> for customerProfileId BCPID1

    Examples:
      | deposit_amount | initiate_transaction_amount | requested_amount | currency | bank_name    | account_type | transaction_rail | initial_total_balance | initial_available_balance | updated_total_balance | updated_available_balance | status_code | txn_status          | country | balance_policy_limit | balance_policy_type |
      | 150            | 100                         | 120              | SGD      | DBS Bank Ltd | e-money      | FAST             | 150                   | 50                        | 30                    | 30                        | 200         | TRANSACTION_SETTLED | SGP     | 0                    | LENIENT             |

  Scenario Outline: Settle transaction with decimal digits greater than permitted for given currency should fail

    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier    | product_type   | profile_type | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type    |
      | ProductID1    | WALLET         | CUSTOMER     |  SHARIAH      | <currency> | <country> | SAVINGS      | 0                       | STRICT                 |

    Then I approve the product ProductID1 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Then I create a cash account with id CashAccId1 customerProfileId BCPID1 with product id CashAccProductId1 and expect status as CASH_ACCOUNT_CREATED

    Given I create account for CustomerProfile with id BCPID1 with product id as ProductID1 with bank account type as Payments Account with provider DBS Bank Ltd and expect the header status 200
      | identifier         | customer_profile_id | currency | country | in_trust | is_overdraft_allowed | on_behalf_of | metadata              | kyc_completed | trust_verification_completed | cash_account_id |
      | CustomerProfileBA1 | IntegrationTest1    | SGD      | SGP     | false    | false                | CUSTOMER     | {"key": "MyMetaData"} | false         | false                        | CashAccId1      |

    Then I wait until max time to verify the bank account CustomerProfileBA1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier    | product_type   | profile_type     | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type    |
      | ProductID2    | WALLET         | END_CUSTOMER     |  SHARIAH      | <currency> | <country> | SAVINGS      | <balance_policy_limit>  | <balance_policy_type>  |

    Then I approve the product ProductID2 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Then I create a end customer cash account with id CashAccId2 customerProfileID BCPID1 with product id CashAccProductId2 and endCustomerProfileId ECPID1 and expect status as CASH_ACCOUNT_CREATED

    Given I create account for EndCustomerProfile with id ECPID1 for CustomerProfile BCPID1 with product id ProductID2 with bank account type as <account_type> with provider <bank_name> and expect the header status 200
      | identifier | customer_profile_id | end_customer_profile_id          | currency   | country | in_trust    | on_behalf_of | metadata                           | cash_account_id |
      | BankAccId1 | BCPID1              | 36974646-3489-47aa-b6c2-w232d543 | <currency> | SGP     | false       | CUSTOMER     | {"key": "TransactionIntegration1"} | CashAccId2      |

    Then I wait until max time to verify the bank account BankAccId1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    Given I deposit an amount of <deposit_amount> into BankAccId1 using cash DevDeposit and expect the header status 200
      | identifier           | customer_profile_id             | purpose  | currency | transaction_rail |
      | DevDepositIdentifier | BCPID1                          | TRANSFER | SGD      | FAST             |

    Then I wait until max time to verify bank account BankAccId1 with an increased balance of <deposit_amount> for customerProfileId BCPID1

    Then I initiate transaction to transfer funds with below details and expect the header statuscode 200 and transaction status as TRANSACTION_AMOUNT_BLOCKED
      | identifier | customer_profile_id | account_id | amount                        | purpose          | is_overdraft_allowed   | metadata              | currency | sub_txn_type | receiver_account_id |
      | TxId1      | BCPID1              | BankAccId1 | <initiate_transaction_amount> | Integration Test | <is_overdraft_allowed> | {"key": "MyMetaData"} | SGD      | CARD_TXN     |                     |

    Then I verify for bank account BankAccId1 total balance is <initial_total_balance> and available balance is <initial_available_balance> for customerProfileId BCPID1

    Then I settle transaction to transfer funds with below details and expect the header statuscode <status_code>
      | transaction_id | customer_profile_id | amount             | transaction_rail   | is_overdraft_allowed   | metadata              |
      | TxId1          | BCPID1              | <requested_amount> | <transaction_rail> | <is_overdraft_allowed> | {"key": "MyMetaData"} |

    Examples:
      | deposit_amount | initiate_transaction_amount | requested_amount | currency | bank_name    | account_type | is_overdraft_allowed | is_overdraft_allowed | is_overdraft_allowed | transaction_rail | initial_total_balance | initial_available_balance | status_code | country  | balance_policy_limit | balance_policy_type |
      | 150            | 100                         | 120.2345         | SGD      | DBS Bank Ltd | e-money      | true                 | true                 | true                 | FAST             | 150                   | 50                        | E9400       | SGP      | 0                    | LENIENT             |

  Scenario Outline: User has a balance then user Initiates a transaction for an amount of less than the user balance, now i settle an amount of which is less than the initial blocked amount

    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier    | product_type   | profile_type | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type    |
      | ProductID1    | WALLET         | CUSTOMER     |  SHARIAH      | <currency> | <country> | SAVINGS      | 0                       | STRICT                 |

    Then I approve the product ProductID1 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Then I create a cash account with id CashAccId1 customerProfileId BCPID1 with product id CashAccProductId1 and expect status as CASH_ACCOUNT_CREATED

    Given I create account for CustomerProfile with id BCPID1 with product id as ProductID1 with bank account type as Payments Account with provider DBS Bank Ltd and expect the header status 200
      | identifier         | customer_profile_id | currency | country | in_trust | is_overdraft_allowed | on_behalf_of | metadata              | kyc_completed | trust_verification_completed | cash_account_id |
      | CustomerProfileBA1 | IntegrationTest1    | SGD      | SGP     | false    | false                | CUSTOMER     | {"key": "MyMetaData"} | false         | false                        | CashAccId1      |

    Then I wait until max time to verify the bank account CustomerProfileBA1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier    | product_type   | profile_type     | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type    |
      | ProductID2    | WALLET         | END_CUSTOMER     |  SHARIAH      | <currency> | <country> | SAVINGS      | <balance_policy_limit>  | <balance_policy_type>  |

    Then I approve the product ProductID2 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Then I create a end customer cash account with id CashAccId2 customerProfileID BCPID1 with product id CashAccProductId2 and endCustomerProfileId ECPID1 and expect status as CASH_ACCOUNT_CREATED

    Given I create account for EndCustomerProfile with id ECPID1 for CustomerProfile BCPID1 with product id ProductID2 with bank account type as <account_type> with provider <bank_name> and expect the header status 200
      | identifier | customer_profile_id | end_customer_profile_id          | currency   | country | in_trust    | on_behalf_of | metadata                           | cash_account_id |
      | BankAccId1 | BCPID1              | 36974646-3489-47aa-b6c2-w232d543 | <currency> | SGP     | false       | CUSTOMER     | {"key": "TransactionIntegration1"} | CashAccId2      |

    Then I wait until max time to verify the bank account BankAccId1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    Given I deposit an amount of <deposit_amount> into BankAccId1 using cash DevDeposit and expect the header status 200
      | identifier           | customer_profile_id             | purpose  | currency | transaction_rail |
      | DevDepositIdentifier | BCPID1                          | TRANSFER | SGD      | FAST             |

    Then I wait until max time to verify bank account BankAccId1 with an increased balance of <deposit_amount> for customerProfileId BCPID1

    Then I initiate transaction to transfer funds with below details and expect the header statuscode <status_code> and transaction status as TRANSACTION_AMOUNT_BLOCKED
      | identifier | customer_profile_id | account_id | amount                        | purpose          | is_overdraft_allowed | metadata              | currency | sub_txn_type | receiver_account_id |
      | TxId1      | BCPID1              | BankAccId1 | <initiate_transaction_amount> | Integration Test | false                | {"key": "MyMetaData"} | SGD      | CARD_TXN     |                     |

    Then I verify for bank account BankAccId1 total balance is <initial_total_balance> and available balance is <initial_available_balance> for customerProfileId BCPID1

    Then I settle transaction to transfer funds with below details for requested amount less than blocked amount and expect the header statuscode <status_code> and transaction_status as <txn_status>
      | transaction_id | customer_profile_id | amount             | transaction_rail   | is_overdraft_allowed | metadata              |
      | TxId1          | BCPID1              | <requested_amount> | <transaction_rail> | false                | {"key": "MyMetaData"} |

    Then I wait until max time to verify the transaction TxId2 status as <txn_status> for customerProfileId BCPID1

    Then I wait until max time to verify bank account BankAccId1 with an available balance of <updated_available_balance> and total balance of <updated_total_balance> for customerProfileId BCPID1

    Then I wait until max time to verify the transaction TxId1 status as TRANSACTION_AMOUNT_BLOCKED for customerProfileId BCPID1

    Examples:
      | deposit_amount | initiate_transaction_amount | requested_amount | currency | bank_name    | account_type | transaction_rail | initial_total_balance | initial_available_balance | updated_total_balance | updated_available_balance | status_code | txn_status          | country | balance_policy_limit | balance_policy_type |
      | 150            | 100                         | 80               | SGD      | DBS Bank Ltd | e-money      | FAST             | 150                   | 50                        | 70                    | 50                        | 200         | TRANSACTION_SETTLED | SGP     | 0                    | LENIENT             |

      ############## Settle Transactions with user not having requested balances where lent transaction may be required. #################
  Scenario Outline: Settle transaction scenario with insufficient balance and negative transfer allowed is false should give Insufficient balance.

    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier    | product_type   | profile_type | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type    |
      | ProductID1    | WALLET         | CUSTOMER     |  SHARIAH      | <currency> | <country> | SAVINGS      | 0                       | STRICT                 |

    Then I approve the product ProductID1 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Then I create a cash account with id CashAccId1 customerProfileId BCPID1 with product id CashAccProductId1 and expect status as CASH_ACCOUNT_CREATED

    Given I create account for CustomerProfile with id BCPID1 with product id as ProductID1 with bank account type as Payments Account with provider DBS Bank Ltd and expect the header status 200
      | identifier         | customer_profile_id | currency | country | in_trust  | on_behalf_of | metadata              | kyc_completed | trust_verification_completed | cash_account_id |
      | CustomerProfileBA1 | IntegrationTest1    | SGD      | SGP     | false     | CUSTOMER     | {"key": "MyMetaData"} | false         | false                        | CashAccId1      |

    Then I wait until max time to verify the bank account CustomerProfileBA1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier    | product_type   | profile_type     | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type    |
      | ProductID2    | WALLET         | END_CUSTOMER     |  SHARIAH      | <currency> | <country> | SAVINGS      | <balance_policy_limit>  | <balance_policy_type>  |

    Then I approve the product ProductID2 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Then I create a end customer cash account with id CashAccId2 customerProfileID BCPID1 with product id CashAccProductId2 and endCustomerProfileId ECPID1 and expect status as CASH_ACCOUNT_CREATED

    Given I create account for EndCustomerProfile with id ECPID1 for CustomerProfile BCPID1 with product id ProductID2 with bank account type as <account_type> with provider <bank_name> and expect the header status 200
      | identifier | customer_profile_id | end_customer_profile_id          | currency   | country | in_trust    | on_behalf_of | metadata                           | cash_account_id |
      | BankAccId1 | BCPID1              | 36974646-3489-47aa-b6c2-w232d543 | <currency> | SGP     | false       | CUSTOMER     | {"key": "TransactionIntegration1"} | CashAccId2      |

    Then I wait until max time to verify the bank account BankAccId1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    Given I deposit an amount of <deposit_amount> into BankAccId1 using cash DevDeposit and expect the header status 200
      | identifier           | customer_profile_id             | purpose  | currency | transaction_rail |
      | DevDepositIdentifier | BCPID1                          | TRANSFER | SGD      | FAST             |

    Then I wait until max time to verify bank account BankAccId1 with an increased balance of <deposit_amount> for customerProfileId BCPID1

    Then I initiate transaction to transfer funds with below details and expect the header statuscode 200 and transaction status as TRANSACTION_AMOUNT_BLOCKED
      | identifier | customer_profile_id | account_id | amount                        | purpose          | is_overdraft_allowed | metadata              | currency | sub_txn_type | receiver_account_id |
      | TxId1      | BCPID1              | BankAccId1 | <initiate_transaction_amount> | Integration Test | false                | {"key": "MyMetaData"} | SGD      | CARD_TXN     |                     |

    Then I settle transaction to transfer funds with below details and expect the header statuscode <status_code> and transaction_status as <message>
      | transaction_id | customer_profile_id | amount             | transaction_rail   | is_overdraft_allowed | metadata              |
      | TxId1          | BCPID1              | <requested_amount> | <transaction_rail> | false                | {"key": "MyMetaData"} |

    Examples:
      | deposit_amount | initiate_transaction_amount | requested_amount | currency | bank_name    | account_type | transaction_rail | status_code | message              | country | balance_policy_limit | balance_policy_type |
      | 100            | 100                         | 120              | SGD      | DBS Bank Ltd | e-money      | FAST             | CSSM_9801   | Insufficient balance | SGP     | 0                    | STRICT              |

  Scenario Outline: Settle transaction with balance < requested amount and negative txn allowed, for requested amount == blocked amount, lent required.

    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier    | product_type   | profile_type | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type    |
      | ProductID1    | WALLET         | CUSTOMER     |  SHARIAH      | <currency> | <country> | SAVINGS      | 0                       | STRICT                 |

    Then I approve the product ProductID1 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Then I create a cash account with id CashAccId1 customerProfileId BCPID1 with product id CashAccProductId1 and expect status as CASH_ACCOUNT_CREATED

    Given I create account for CustomerProfile with id BCPID1 with product id as ProductID1 with bank account type as Payments Account with provider DBS Bank Ltd and expect the header status 200
      | identifier         | customer_profile_id | currency | country | in_trust  | on_behalf_of | metadata              | kyc_completed | trust_verification_completed | cash_account_id |
      | CustomerProfileBA1 | IntegrationTest1    | SGD      | SGP     | false     | CUSTOMER     | {"key": "MyMetaData"} | false         | false                        | CashAccId1      |

    Then I wait until max time to verify the bank account CustomerProfileBA1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier    | product_type   | profile_type     | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type    |
      | ProductID2    | WALLET         | END_CUSTOMER     |  SHARIAH      | <currency> | <country> | SAVINGS      | <balance_policy_limit>  | <balance_policy_type>  |

    Then I approve the product ProductID2 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Then I create a end customer cash account with id CashAccId2 customerProfileID BCPID1 with product id CashAccProductId2 and endCustomerProfileId ECPID1 and expect status as CASH_ACCOUNT_CREATED

    Given I create account for EndCustomerProfile with id ECPID1 for CustomerProfile BCPID1 with product id ProductID2 with bank account type as <account_type> with provider <bank_name> and expect the header status 200
      | identifier | customer_profile_id | end_customer_profile_id          | currency   | country | in_trust    | on_behalf_of | metadata                           | cash_account_id |
      | BankAccId1 | BCPID1              | 36974646-3489-47aa-b6c2-w232d543 | <currency> | SGP     | false       | CUSTOMER     | {"key": "TransactionIntegration1"} | CashAccId2      |

    Then I wait until max time to verify the bank account BankAccId1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    Given I deposit an amount of 1000 into CustomerProfileBA1 using cash DevDeposit and expect the header status 200
      | identifier           | customer_profile_id             | purpose  | currency | transaction_rail |
      | DevDepositIdentifier | BCPID1                          | TRANSFER | SGD      | FAST             |

    Then I wait until max time to verify bank account CustomerProfileBA1 with an increased balance of 1000 for customerProfileId BCPID1

    Given I deposit an amount of <deposit_amount> into BankAccId1 using cash DevDeposit and expect the header status 200
      | identifier           | customer_profile_id             | purpose  | currency | transaction_rail |
      | DevDepositIdentifier | BCPID1                          | TRANSFER | SGD      | FAST             |

    Then I wait until max time to verify bank account BankAccId1 with an increased balance of <deposit_amount> for customerProfileId BCPID1

    Then I initiate transaction to transfer funds with below details and expect the header statuscode <status_code> and transaction status as TRANSACTION_AMOUNT_BLOCKED
      | identifier | customer_profile_id | account_id | amount                        | purpose          | is_overdraft_allowed   | metadata              | currency | sub_txn_type | receiver_account_id |
      | TxId1      | BCPID1              | BankAccId1 | <initiate_transaction_amount> | Integration Test | <is_overdraft_allowed> | {"key": "MyMetaData"} | SGD      | CARD_TXN     |                     |

    Then I verify for bank account BankAccId1 total balance is <initial_total_balance> and available balance is <initial_available_balance> for customerProfileId BCPID1

    Then I settle transaction to transfer funds with below details and expect the header statuscode <status_code> and transaction_status as <txn_status>
      | transaction_id | customer_profile_id | amount             | transaction_rail   | is_overdraft_allowed   | metadata              | overdraft_funding_account_id |
      | TxId1          | BCPID1              | <requested_amount> | <transaction_rail> | <is_overdraft_allowed> | {"key": "MyMetaData"} | CustomerProfileBA1           |

    Then I wait until max time to verify the transaction TxId1 status as <txn_status> for customerProfileId BCPID1

    Then I wait until max time to verify bank account BankAccId1 with an available balance of <updated_available_balance> and total balance of <updated_total_balance> for customerProfileId BCPID1

    Then I wait until max time to verify bank account CustomerProfileBA1 with an available balance of <treasury_available_balance> and total balance of <treasury_total_balance> for customerProfileId BCPID1

    Examples:
      | deposit_amount | initiate_transaction_amount | requested_amount | currency | bank_name    | account_type | is_overdraft_allowed | is_overdraft_allowed | is_overdraft_allowed | transaction_rail | initial_total_balance | initial_available_balance | updated_total_balance | updated_available_balance | treasury_total_balance | treasury_available_balance | status_code | txn_status          | country | balance_policy_limit | balance_policy_type   |
      | 80             | 100                         | 100              | SGD      | DBS Bank Ltd | e-money      | true                 | true                 | true                 | FAST             | 80                    | -20                       | -20                   | -20                       | 980                    | 980                        | 200         | TRANSACTION_SETTLED | SGP     | 0                    | LENIENT               |

  Scenario Outline: Settle transaction with balance < requested amount and negative txn allowed for requested amount greater than blocked amount, lent required.

    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier    | product_type   | profile_type | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type    |
      | ProductID1    | WALLET         | CUSTOMER     |  SHARIAH      | <currency> | <country> | SAVINGS      | 0                       | STRICT                 |

    Then I approve the product ProductID1 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Then I create a cash account with id CashAccId1 customerProfileId BCPID1 with product id CashAccProductId1 and expect status as CASH_ACCOUNT_CREATED

    Given I create account for CustomerProfile with id BCPID1 with product id as ProductID1 with bank account type as Payments Account with provider DBS Bank Ltd and expect the header status 200
      | identifier         | customer_profile_id | currency | country | in_trust | is_overdraft_allowed | on_behalf_of | metadata              | kyc_completed | trust_verification_completed | cash_account_id |
      | CustomerProfileBA1 | IntegrationTest1    | SGD      | SGP     | false    | false                | CUSTOMER     | {"key": "MyMetaData"} | false         | false                        | CashAccId1      |

    Then I wait until max time to verify the bank account CustomerProfileBA1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier    | product_type   | profile_type     | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type    |
      | ProductID2    | WALLET         | END_CUSTOMER     |  SHARIAH      | <currency> | <country> | SAVINGS      | <balance_policy_limit>  | <balance_policy_type>  |

    Then I approve the product ProductID2 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Then I create a end customer cash account with id CashAccId2 customerProfileID BCPID1 with product id CashAccProductId2 and endCustomerProfileId ECPID1 and expect status as CASH_ACCOUNT_CREATED

    Given I create account for EndCustomerProfile with id ECPID1 for CustomerProfile BCPID1 with product id ProductID2 with bank account type as <account_type> with provider <bank_name> and expect the header status 200
      | identifier | customer_profile_id | end_customer_profile_id          | currency   | country | in_trust    | on_behalf_of | metadata                           | cash_account_id |
      | BankAccId1 | BCPID1              | 36974646-3489-47aa-b6c2-w232d543 | <currency> | SGP     | false       | CUSTOMER     | {"key": "TransactionIntegration1"} | CashAccId2      |

    Then I wait until max time to verify the bank account BankAccId1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    Given I deposit an amount of 1000 into CustomerProfileBA1 using cash DevDeposit and expect the header status 200
      | identifier           | customer_profile_id             | purpose  | currency | transaction_rail |
      | DevDepositIdentifier | BCPID1                          | TRANSFER | SGD      | FAST             |

    Then I wait until max time to verify bank account CustomerProfileBA1 with an increased balance of 1000 for customerProfileId BCPID1

    Given I deposit an amount of <deposit_amount> into BankAccId1 using cash DevDeposit and expect the header status 200
      | identifier           | customer_profile_id             | purpose  | currency | transaction_rail |
      | DevDepositIdentifier | BCPID1                          | TRANSFER | SGD      | FAST             |

    Then I wait until max time to verify bank account BankAccId1 with an increased balance of <deposit_amount> for customerProfileId BCPID1

    Then I initiate transaction to transfer funds with below details and expect the header statuscode <status_code> and transaction status as TRANSACTION_AMOUNT_BLOCKED
      | identifier | customer_profile_id | account_id | amount                        | purpose          | is_overdraft_allowed   | metadata              | currency | sub_txn_type | receiver_account_id |
      | TxId1      | BCPID1              | BankAccId1 | <initiate_transaction_amount> | Integration Test | <is_overdraft_allowed> | {"key": "MyMetaData"} | SGD      | CARD_TXN     |                     |

    Then I verify for bank account BankAccId1 total balance is <initial_total_balance> and available balance is <initial_available_balance> for customerProfileId BCPID1

    Then I settle transaction to transfer funds with below details and expect the header statuscode <status_code> and transaction_status as <txn_status>
      | transaction_id | customer_profile_id | amount             | transaction_rail   | is_overdraft_allowed   | metadata              | overdraft_funding_account_id |
      | TxId1          | BCPID1              | <requested_amount> | <transaction_rail> | <is_overdraft_allowed> | {"key": "MyMetaData"} | CustomerProfileBA1           |

    Then I wait until max time to verify the transaction TxId1 status as <txn_status> for customerProfileId BCPID1

    Then I wait until max time to verify bank account BankAccId1 with an available balance of <updated_available_balance> and total balance of <updated_total_balance> for customerProfileId BCPID1

    Then I wait until max time to verify bank account CustomerProfileBA1 with an available balance of <treasury_available_balance> and total balance of <treasury_total_balance> for customerProfileId BCPID1

    Examples:
      | deposit_amount | initiate_transaction_amount | requested_amount | currency | bank_name    | account_type | is_overdraft_allowed | is_overdraft_allowed | is_overdraft_allowed | transaction_rail | initial_total_balance | initial_available_balance | updated_total_balance | updated_available_balance | treasury_total_balance | treasury_available_balance | status_code | txn_status          | country | balance_policy_limit | balance_policy_type  |
      | 80             | 100                         | 120              | SGD      | DBS Bank Ltd | e-money      | true                 | true                 | true                 | FAST             | 80                    | -20                       | -40                   | -40                       | 960                    | 960                        | 200         | TRANSACTION_SETTLED | SGP     | 0                    | LENIENT               |

  Scenario Outline: Settle transaction with 0 balance and requesting amount for negative txn allowed, lent required.

    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier    | product_type   | profile_type | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type    |
      | ProductID1    | WALLET         | CUSTOMER     |  SHARIAH      | <currency> | <country> | SAVINGS      | 0                       | STRICT                 |

    Then I approve the product ProductID1 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Then I create a cash account with id CashAccId1 customerProfileId BCPID1 with product id CashAccProductId1 and expect status as CASH_ACCOUNT_CREATED

    Given I create account for CustomerProfile with id BCPID1 with product id as ProductID1 with bank account type as Payments Account with provider DBS Bank Ltd and expect the header status 200
      | identifier         | customer_profile_id | currency | country | in_trust | is_overdraft_allowed | on_behalf_of | metadata              | kyc_completed | trust_verification_completed | cash_account_id |
      | CustomerProfileBA1 | IntegrationTest1    | SGD      | SGP     | false    | false                | CUSTOMER     | {"key": "MyMetaData"} | false         | false                        | CashAccId1      |

    Then I wait until max time to verify the bank account CustomerProfileBA1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier    | product_type   | profile_type     | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type    |
      | ProductID2    | WALLET         | END_CUSTOMER     |  SHARIAH      | <currency> | <country> | SAVINGS      | <balance_policy_limit>  | <balance_policy_type>  |

    Then I approve the product ProductID2 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Then I create a end customer cash account with id CashAccId2 customerProfileID BCPID1 with product id CashAccProductId2 and endCustomerProfileId ECPID1 and expect status as CASH_ACCOUNT_CREATED

    Given I create account for EndCustomerProfile with id ECPID1 for CustomerProfile BCPID1 with product id ProductID2 with bank account type as <account_type> with provider <bank_name> and expect the header status 200
      | identifier | customer_profile_id | end_customer_profile_id          | currency   | country | in_trust    | on_behalf_of | metadata                           | cash_account_id |
      | BankAccId1 | BCPID1              | 36974646-3489-47aa-b6c2-w232d543 | <currency> | SGP     | false       | CUSTOMER     | {"key": "TransactionIntegration1"} | CashAccId2      |

    Then I wait until max time to verify the bank account BankAccId1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    Given I deposit an amount of 1000 into CustomerProfileBA1 using cash DevDeposit and expect the header status 200
      | identifier           | customer_profile_id             | purpose  | currency | transaction_rail |
      | DevDepositIdentifier | BCPID1                          | TRANSFER | SGD      | FAST             |

    Then I wait until max time to verify bank account CustomerProfileBA1 with an increased balance of 1000 for customerProfileId BCPID1

    Then I verify for bank account BankAccId1 total balance is 0 and available balance is 0 for customerProfileId BCPID1

    Then I initiate transaction to transfer funds with below details and expect the header statuscode <status_code> and transaction status as TRANSACTION_AMOUNT_BLOCKED
      | identifier | customer_profile_id | account_id | amount                        | purpose          | is_overdraft_allowed   | metadata              | currency | sub_txn_type | receiver_account_id |
      | TxId1      | BCPID1              | BankAccId1 | <initiate_transaction_amount> | Integration Test | <is_overdraft_allowed> | {"key": "MyMetaData"} | SGD      | CARD_TXN     |                     |

    Then I verify for bank account BankAccId1 total balance is <initial_total_balance> and available balance is <initial_available_balance> for customerProfileId BCPID1

    Then I settle transaction to transfer funds with below details and expect the header statuscode <status_code> and transaction_status as <txn_status>
      | transaction_id | customer_profile_id | amount             | transaction_rail   | is_overdraft_allowed   | metadata              | overdraft_funding_account_id |
      | TxId1          | BCPID1              | <requested_amount> | <transaction_rail> | <is_overdraft_allowed> | {"key": "MyMetaData"} | CustomerProfileBA1           |

    Then I wait until max time to verify the transaction TxId1 status as <txn_status> for customerProfileId BCPID1

    Then I wait until max time to verify bank account BankAccId1 with an available balance of <updated_available_balance> and total balance of <updated_total_balance> for customerProfileId BCPID1

    Then I wait until max time to verify bank account CustomerProfileBA1 with an available balance of <treasury_available_balance> and total balance of <treasury_total_balance> for customerProfileId BCPID1

    Examples:
      | initiate_transaction_amount | requested_amount | currency | bank_name    | account_type | is_overdraft_allowed | is_overdraft_allowed | is_overdraft_allowed | transaction_rail | initial_total_balance | initial_available_balance | updated_total_balance | updated_available_balance | treasury_total_balance | treasury_available_balance | status_code | txn_status          | country | balance_policy_limit | balance_policy_type |
      | 100                         | 120              | SGD      | DBS Bank Ltd | e-money      | true                 | true                 | true                 | FAST             | 0                     | -100                      | -120                  | -120                      | 880                    | 880                        | 200         | TRANSACTION_SETTLED | SGP     | 0                    | LENIENT             |

  Scenario Outline: Settle transaction with balance < requested amount and negative txn allowed for requested amount less than blocked amount, lent required.

    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier    | product_type   | profile_type | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type    |
      | ProductID1    | WALLET         | CUSTOMER     |  SHARIAH      | <currency> | <country> | SAVINGS      | 0                       | STRICT                 |

    Then I approve the product ProductID1 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Then I create a cash account with id CashAccId1 customerProfileId BCPID1 with product id CashAccProductId1 and expect status as CASH_ACCOUNT_CREATED

    Given I create account for CustomerProfile with id BCPID1 with product id as ProductID1 with bank account type as Payments Account with provider DBS Bank Ltd and expect the header status 200
      | identifier         | customer_profile_id | currency | country | in_trust  | on_behalf_of | metadata              | kyc_completed | trust_verification_completed | cash_account_id |
      | CustomerProfileBA1 | IntegrationTest1    | SGD      | SGP     | false     | CUSTOMER     | {"key": "MyMetaData"} | false         | false                        | CashAccId1      |

    Then I wait until max time to verify the bank account CustomerProfileBA1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier    | product_type   | profile_type     | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type    |
      | ProductID2    | WALLET         | END_CUSTOMER     |  SHARIAH      | <currency> | <country> | SAVINGS      | <balance_policy_limit>  | <balance_policy_type>  |

    Then I approve the product ProductID2 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Then I create a end customer cash account with id CashAccId2 customerProfileID BCPID1 with product id CashAccProductId2 and endCustomerProfileId ECPID1 and expect status as CASH_ACCOUNT_CREATED

    Given I create account for EndCustomerProfile with id ECPID1 for CustomerProfile BCPID1 with product id ProductID2 with bank account type as <account_type> with provider <bank_name> and expect the header status 200
      | identifier | customer_profile_id | end_customer_profile_id          | currency   | country | in_trust  | on_behalf_of | metadata                           | cash_account_id |
      | BankAccId1 | BCPID1              | 36974646-3489-47aa-b6c2-w232d543 | <currency> | SGP     | false     | CUSTOMER     | {"key": "TransactionIntegration1"} | CashAccId2      |

    Then I wait until max time to verify the bank account BankAccId1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    Given I deposit an amount of 1000 into CustomerProfileBA1 using cash DevDeposit and expect the header status 200
      | identifier           | customer_profile_id             | purpose  | currency | transaction_rail |
      | DevDepositIdentifier | BCPID1                          | TRANSFER | SGD      | FAST             |

    Then I wait until max time to verify bank account CustomerProfileBA1 with an increased balance of 1000 for customerProfileId BCPID1

    Given I deposit an amount of <deposit_amount> into BankAccId1 using cash DevDeposit and expect the header status 200
      | identifier           | customer_profile_id             | purpose  | currency | transaction_rail |
      | DevDepositIdentifier | BCPID1                          | TRANSFER | SGD      | FAST             |

    Then I wait until max time to verify bank account BankAccId1 with an increased balance of <deposit_amount> for customerProfileId BCPID1

    Then I initiate transaction to transfer funds with below details and expect the header statuscode <status_code> and transaction status as TRANSACTION_AMOUNT_BLOCKED
      | identifier | customer_profile_id | account_id | amount                        | purpose          | is_overdraft_allowed   | metadata              | currency | sub_txn_type | receiver_account_id |
      | TxId1      | BCPID1              | BankAccId1 | <initiate_transaction_amount> | Integration Test | <is_overdraft_allowed> | {"key": "MyMetaData"} | SGD      | CARD_TXN     |                     |

    Then I verify for bank account BankAccId1 total balance is <initial_total_balance> and available balance is <initial_available_balance> for customerProfileId BCPID1

    Then I settle transaction to transfer funds with below details for requested amount less than blocked amount and expect the header statuscode <status_code> and transaction_status as <txn_status>
      | transaction_id | customer_profile_id | amount             | transaction_rail   | is_overdraft_allowed   | metadata              | overdraft_funding_account_id   |
      | TxId1          | BCPID1              | <requested_amount> | <transaction_rail> | <is_overdraft_allowed> | {"key": "MyMetaData"} | <overdraft_funding_account_id> |

    Then I wait until max time to verify the transaction TxId2 status as <txn_status> for customerProfileId BCPID1

    Then I wait until max time to verify bank account BankAccId1 with an available balance of <updated_available_balance> and total balance of <updated_total_balance> for customerProfileId BCPID1

    Then I wait until max time to verify the transaction TxId1 status as TRANSACTION_AMOUNT_BLOCKED for customerProfileId BCPID1

    Then I wait until max time to verify bank account CustomerProfileBA1 with an available balance of <treasury_available_balance> and total balance of <treasury_total_balance> for customerProfileId BCPID1

    Examples:
      | deposit_amount | initiate_transaction_amount | requested_amount | currency | bank_name    | account_type | is_overdraft_allowed | is_overdraft_allowed | is_overdraft_allowed | transaction_rail | initial_total_balance | initial_available_balance | updated_total_balance | updated_available_balance | treasury_total_balance | treasury_available_balance | status_code | txn_status          | overdraft_funding_account_id | country | balance_policy_limit | balance_policy_type |
      | 80             | 120                         | 100              | SGD      | DBS Bank Ltd | e-money      | true                 | true                 | true                 | FAST             | 80                    | -40                       | -20                   | -40                       | 980                    | 980                        | 200         | TRANSACTION_SETTLED | CustomerProfileBA1           | SGP     | 0                    | LENIENT             |
