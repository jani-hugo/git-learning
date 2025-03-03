Feature: Banking Service Settle transactions various cases

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


   ####LENT RECOVERY TESTS####
  Scenario Outline: Lent recovery scenario when lent_amount == deposit_amount, full recovery.

    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier    | product_type   | profile_type | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type    |
      | ProductID1    | WALLET         | CUSTOMER     |  SHARIAH      | <currency> | <country> | SAVINGS      | 0                       | STRICT                 |

    Then I approve the product ProductID1 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Given I create account for CustomerProfile with id BCPID1 with product id as ProductID1 with bank account type as Payments Account with provider DBS Bank Ltd and expect the header status 200
      | identifier         | customer_profile_id | currency | country | in_trust | is_overdraft_allowed | on_behalf_of | metadata              | kyc_completed | trust_verification_completed |
      | CustomerProfileBA1 | IntegrationTest1    | SGD      | SGP     | false    | false                | CUSTOMER     | {"key": "MyMetaData"} | false         | false                        |

    Then I wait until max time to verify the bank account CustomerProfileBA1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier    | product_type   | profile_type | product_class | currency   | country   | account_type | balance_policy_type    | balance_policy_limit  |
      | ProductID2    | WALLET         | END_CUSTOMER |  SHARIAH      | <currency> | <country> | SAVINGS      | <balance_policy_type>  | <balance_policy_limit> |

    Then I approve the product ProductID2 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Given I create account for EndCustomerProfile with id ECPID1 for CustomerProfile BCPID1 with product id ProductID2 with bank account type as <account_type> with provider <bank_name> and expect the header status 200
      | identifier | customer_profile_id | end_customer_profile_id          | currency   | country | in_trust | on_behalf_of | metadata                           |
      | BankAccId1 | BCPID1              | 36974646-3489-47aa-b6c2-w232d543 | <currency> | SGP     | false    | CUSTOMER     | {"key": "TransactionIntegration1"} |

    Then I wait until max time to verify the bank account BankAccId1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    Given I deposit an amount of 1000 into CustomerProfileBA1 using cash DevDeposit and expect the header status 200
      | identifier           | customer_profile_id             | purpose  | currency | transaction_rail |
      | DevDepositIdentifier | BCPID1                          | TRANSFER | SGD      | FAST             |

    Then I wait until max time to verify bank account CustomerProfileBA1 with an increased balance of 1000 for customerProfileId BCPID1

    When I add External Bank Account as beneficiary to bank account BankAccId1 of CustomerProfile BCPID1 for provider <bank_name> and expect status 200
      | identifier     | beneficiary_name | address                                                                                                                                                                    | beneficiary_email     | is_hidden | metadata              | is_overdraft_allowed                  | beneficiary_account_details                                                                                                                                   | overdraft_funding_account_id |
      | BeneficiaryId1 | Beneficiary1     | {"address_line_1":"line1","address_line_2":"line2","address_line_3":"line3","address_line_4":"line4","city":"Tokyo","state":"Tokyo","country_code":"JP","local_code":"JP"} | beneficiary1@test.com | false     | {"key": "MyMetaData"} | <is_overdraft_allowed> | {"bank_name":"SBI","currency":"SGD", "account_number": "1123344455","country":"SGP","code_details":{"sg_code_details":{"swift_bic":"DBSSSGSGXXX"}}} | CustomerProfileBA1           |

    Then I wait until max time to verify beneficiary BeneficiaryId1 create status as BENEFICIARY_CREATED with provider <bank_name> for customerProfileId BCPID1

    Given I deposit an amount of <deposit_amount> into BankAccId1 using cash DevDeposit and expect the header status 200
      | identifier           | customer_profile_id             | purpose  | currency | transaction_rail |
      | DevDepositIdentifier | BCPID1                          | TRANSFER | SGD      | FAST             |

    Then I wait until max time to verify bank account BankAccId1 with an increased balance of <deposit_amount> for customerProfileId BCPID1

    Then I initiate transaction to transfer funds with below details and expect the header statuscode <status_code> and transaction status as TRANSACTION_AMOUNT_BLOCKED
      | identifier | customer_profile_id | account_id | beneficiary_id | amount                        | purpose          | is_overdraft_allowed        | metadata              | currency | sub_txn_type |
      | TxId1      | BCPID1              | BankAccId1 | BeneficiaryId1 | <initiate_transaction_amount> | Integration Test | <is_overdraft_allowed> | {"key": "MyMetaData"} | SGD      | CARD_TXN     |

    Then I verify for bank account BankAccId1 total balance is <initial_total_balance> and available balance is <initial_available_balance> for customerProfileId BCPID1

    Then I settle transaction to transfer funds with below details and expect the header statuscode <status_code> and transaction_status as <txn_status>
      | transaction_id | customer_profile_id | amount             | transaction_rail   | is_overdraft_allowed        | metadata              | overdraft_funding_account_id |
      | TxId1          | BCPID1              | <requested_amount> | <transaction_rail> | <is_overdraft_allowed> | {"key": "MyMetaData"} | CustomerProfileBA1           |

    Then I wait until max time to verify the transaction TxId1 status as <txn_status> for customerProfileId BCPID1

    Given I deposit an amount of <external_deposit_amount> into BankAccId1 using cash DevDeposit and expect the header status 200
      | identifier           | customer_profile_id             | purpose  | currency | transaction_rail |
      | DevDepositIdentifier | BCPID1                          | TRANSFER | SGD      | FAST             |

    Then I wait until max time to verify bank account BankAccId1 with an available balance of <available_balance> and total balance of <total_balance> for customerProfileId BCPID1

    Then I wait until max time to verify bank account CustomerProfileBA1 with lent recovery available balance of <recovered_available_balance> and total balance of <recovered_total_balance> for customerProfileId BCPID1

    Examples:
      | deposit_amount | initiate_transaction_amount | requested_amount | external_deposit_amount | currency | bank_name    | account_type | is_overdraft_allowed | is_overdraft_allowed | is_overdraft_allowed | initial_total_balance | initial_available_balance | transaction_rail | status_code | txn_status          | available_balance | total_balance | recovered_total_balance | recovered_available_balance |  country   | balance_policy_limit | balance_policy_type |
      | 80             | 100                         | 100              | 50                      | SGD      | DBS Bank Ltd | e-money      | true                 | true                 | true                 | 80                    | -20                       | FAST             | 200         | TRANSACTION_SETTLED | 30                | 30            | 1000                    | 1000                        |  SGP       | 0                    | LENIENT             |

  Scenario Outline: Lent recovery scenario when lent_amount > deposit_amount, partial recovery.

    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier    | product_type   | profile_type | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type    |
      | ProductID1    | WALLET         | CUSTOMER     |  SHARIAH      | <currency> | <country> | SAVINGS      | 0                       | STRICT                 |

    Then I approve the product ProductID1 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Given I create account for CustomerProfile with id BCPID1 with product id as ProductID1 with bank account type as Payments Account with provider DBS Bank Ltd and expect the header status 200
      | identifier         | customer_profile_id | currency | country | in_trust | is_overdraft_allowed | on_behalf_of | metadata              | kyc_completed | trust_verification_completed |
      | CustomerProfileBA1 | IntegrationTest1    | SGD      | SGP     | false    | false                | CUSTOMER     | {"key": "MyMetaData"} | false         | false                        |

    Then I wait until max time to verify the bank account CustomerProfileBA1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier    | product_type   | profile_type | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type    |
      | ProductID2    | WALLET         | END_CUSTOMER |  SHARIAH      | <currency> | <country> | SAVINGS      | <balance_policy_limit>  | <balance_policy_type>  |

    Then I approve the product ProductID2 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Given I create account for EndCustomerProfile with id ECPID1 for CustomerProfile BCPID1 with product id ProductID2 with bank account type as <account_type> with provider <bank_name> and expect the header status 200
      | identifier | customer_profile_id | end_customer_profile_id          | currency   | country | in_trust    | on_behalf_of | metadata                           |
      | BankAccId1 | BCPID1              | 36974646-3489-47aa-b6c2-w232d543 | <currency> | SGP     | false       | CUSTOMER     | {"key": "TransactionIntegration1"} |

    Then I wait until max time to verify the bank account BankAccId1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    Given I deposit an amount of 1000 into CustomerProfileBA1 using cash DevDeposit and expect the header status 200
      | identifier           | customer_profile_id             | purpose  | currency | transaction_rail |
      | DevDepositIdentifier | BCPID1                          | TRANSFER | SGD      | FAST             |

    Then I wait until max time to verify bank account CustomerProfileBA1 with an increased balance of 1000 for customerProfileId BCPID1

    When I add External Bank Account as beneficiary to bank account BankAccId1 of CustomerProfile BCPID1 for provider <bank_name> and expect status 200
      | identifier     | beneficiary_name | address                                                                                                                                                                    | beneficiary_email     | is_hidden | metadata              | is_overdraft_allowed   | beneficiary_account_details                                                                                                                                   | overdraft_funding_account_id |
      | BeneficiaryId1 | Beneficiary1     | {"address_line_1":"line1","address_line_2":"line2","address_line_3":"line3","address_line_4":"line4","city":"Tokyo","state":"Tokyo","country_code":"JP","local_code":"JP"} | beneficiary1@test.com | false     | {"key": "MyMetaData"} | <is_overdraft_allowed> | {"bank_name":"SBI","currency":"SGD", "account_number": "1123344455","country":"SGP","code_details":{"sg_code_details":{"swift_bic":"DBSSSGSGXXX"}}} | CustomerProfileBA1           |

    Then I wait until max time to verify beneficiary BeneficiaryId1 create status as BENEFICIARY_CREATED with provider <bank_name> for customerProfileId BCPID1

    Given I deposit an amount of <deposit_amount> into BankAccId1 using cash DevDeposit and expect the header status 200
      | identifier           | customer_profile_id             | purpose  | currency | transaction_rail |
      | DevDepositIdentifier | BCPID1                          | TRANSFER | SGD      | FAST             |

    Then I wait until max time to verify bank account BankAccId1 with an increased balance of <deposit_amount> for customerProfileId BCPID1

    Then I initiate transaction to transfer funds with below details and expect the header statuscode <status_code> and transaction status as TRANSACTION_AMOUNT_BLOCKED
      | identifier | customer_profile_id | account_id | beneficiary_id | amount                        | purpose          | is_overdraft_allowed        | metadata              | currency | sub_txn_type |
      | TxId1      | BCPID1              | BankAccId1 | BeneficiaryId1 | <initiate_transaction_amount> | Integration Test | <is_overdraft_allowed> | {"key": "MyMetaData"} | SGD      | CARD_TXN     |

    Then I verify for bank account BankAccId1 total balance is <initial_total_balance> and available balance is <initial_available_balance> for customerProfileId BCPID1

    Then I settle transaction to transfer funds with below details and expect the header statuscode <status_code> and transaction_status as <txn_status>
      | transaction_id | customer_profile_id | amount             | transaction_rail   | is_overdraft_allowed   | metadata              | overdraft_funding_account_id |
      | TxId1          | BCPID1              | <requested_amount> | <transaction_rail> | <is_overdraft_allowed> | {"key": "MyMetaData"} | CustomerProfileBA1           |

    Then I wait until max time to verify the transaction TxId1 status as <txn_status> for customerProfileId BCPID1

    Given I deposit an amount of <external_deposit_amount> into BankAccId1 using cash DevDeposit and expect the header status 200
      | identifier           | customer_profile_id             | purpose  | currency | transaction_rail |
      | DevDepositIdentifier | BCPID1                          | TRANSFER | SGD      | FAST             |

    Then I wait until max time to verify bank account BankAccId1 with an available balance of <available_balance> and total balance of <total_balance> for customerProfileId BCPID1

#    Then I wait until max time to verify bank account CustomerProfileBA1 with lent recovery available balance of <recovered_available_balance> and total balance of <recovered_total_balance> for customerProfileId BCPID1

    Examples:
      | deposit_amount | initiate_transaction_amount | requested_amount | external_deposit_amount | currency | bank_name          | account_type | is_overdraft_allowed | is_overdraft_allowed                | is_overdraft_allowed | initial_total_balance | initial_available_balance | transaction_rail | status_code | txn_status          | available_balance | total_balance | recovered_total_balance | recovered_available_balance | country | balance_policy_type | balance_policy_limit |
      | 80             | 100                         | 100              | 10                      | SGD      | DBS Bank Ltd       | e-money      | true                 | true                                | true                 | 80                    | -20                       | FAST             | 200         | TRANSACTION_SETTLED | -10               | -10           | 990                     | 990                         | SGP     | LENIENT             | 0                    |

  Scenario Outline: Settle transaction for Internal beneficiary with 0 balance and lent required --- deposit matching test case.

    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier    | product_type   | profile_type | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type    |
      | ProductID1    | WALLET         | CUSTOMER     |  SHARIAH      | <currency> | <country> | SAVINGS      | 0                       | STRICT                 |

    Then I approve the product ProductID1 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier    | product_type   | profile_type | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type    |
      | ProductID1    | WALLET         | CUSTOMER     |  SHARIAH      | <currency> | <country> | SAVINGS      | 0                       | STRICT                 |

    Then I approve the product ProductID1 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Given I create account for CustomerProfile with id BCPID1 with product id as ProductID1 with bank account type as Payments Account with provider DBS Bank Ltd and expect the header status 200
      | identifier         | customer_profile_id | currency | country | in_trust  | on_behalf_of | metadata              | kyc_completed | trust_verification_completed |
      | CustomerProfileBA1 | IntegrationTest1    | SGD      | SGP     | false     | CUSTOMER     | {"key": "MyMetaData"} | false         | false                        |

    Then I wait until max time to verify the bank account CustomerProfileBA1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    Given I deposit an amount of 1000 into CustomerProfileBA1 using cash DevDeposit and expect the header status 200
      | identifier           | customer_profile_id             | purpose  | currency | transaction_rail |
      | DevDepositIdentifier | BCPID1                          | TRANSFER | SGD      | FAST             |

    Then I wait until max time to verify bank account CustomerProfileBA1 with an increased balance of 1000 for customerProfileId BCPID1

    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier    | product_type   | profile_type | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type |
      | ProductID2    | WALLET         | END_CUSTOMER |  SHARIAH      | <currency> | <country> | SAVINGS      | 0                       | LENIENT             |

    Then I approve the product ProductID2 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Given I create account for EndCustomerProfile with id ECPID1 for CustomerProfile BCPID1 with product id ProductID2 with bank account type as e-money with provider <bank_name> and expect the header status 200
      | identifier | customer_profile_id | end_customer_profile_id | currency | country | in_trust  | on_behalf_of | metadata                           |
      | BankAccId1 | BCPID1              | ECPID1                  | SGD      | SGP     | false     | CUSTOMER     | {"key": "TransactionIntegration1"} |

    Then I wait until max time to verify the bank account BankAccId1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    Then I verify for bank account BankAccId1 total balance is <initial_total_balance> and available balance is <initial_available_balance> for customerProfileId BCPID1

    Given I create account for CustomerProfile with id BCPID1 with product id as ProductID1 with bank account type as Payments Account with provider <bank_name> and expect the header status 200
      | identifier | customer_profile_id | currency | country | in_trust  | on_behalf_of | metadata                           |
      | BankAccId2 | BCPID1              | SGD      | SGP     | false     | CUSTOMER     | {"key": "TransactionIntegration1"} |

    Then I wait until max time to verify the bank account BankAccId2 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    Then I verify CustomerProfile with id BCPID1 has bank account BankAccId2 of account type Payments Account exists with provider <bank_name> with values
      | identifier | profile_id | currency | profile_type | account_status  | account_details                                              | in_trust | is_overdraft_allowed | in_trust | currency | on_behalf_of | metadata                           |
      | BankAccId2 | BCPID1     | SGD      | CUSTOMER     | ACCOUNT_CREATED | {"bank_name":"<bank_name>","currency":"SGD","country":"SGP"} | false    | false                | false    | SGD      | CUSTOMER     | {"key": "TransactionIntegration1"} |

    Then I verify for bank account BankAccId2 total balance is <initial_total_balance> and available balance is <initial_available_balance> for customerProfileId BCPID1

    When I add bank account BankAccId2 as beneficiary to bank account BankAccId1 of CustomerProfile BCPID1 for provider <bank_name> and expect status 200
      | identifier     | beneficiary_name | address                                                                                                                                                                    | beneficiary_email     | is_hidden | metadata              | is_overdraft_allowed | overdraft_funding_account_id |
      | BeneficiaryId1 | Beneficiary1     | {"address_line_1":"line1","address_line_2":"line2","address_line_3":"line3","address_line_4":"line4","city":"Tokyo","state":"Tokyo","country_code":"JP","local_code":"JP"} | beneficiary1@test.com | false     | {"key": "MyMetaData"} | true                                | CustomerProfileBA1           |

    Then I wait until max time to verify beneficiary BeneficiaryId1 create status as BENEFICIARY_CREATED with provider <bank_name> for customerProfileId BCPID1

    Then I verify bank account BankAccId1 has bank account BankAccId2 as beneficiary on provider <bank_name> with values for customerProfileId BCPID1
      | identifier     | beneficiary_name | address                                                                                                                                                                    | beneficiary_email     | is_hidden | metadata              | is_overdraft_allowed |
      | BeneficiaryId1 | Beneficiary1     | {"address_line_1":"line1","address_line_2":"line2","address_line_3":"line3","address_line_4":"line4","city":"Tokyo","state":"Tokyo","country_code":"JP","local_code":"JP"} | beneficiary1@test.com | false     | {"key": "MyMetaData"} | true                                |

    Then I initiate transaction to transfer funds with below details and expect the header statuscode <status_code> and transaction status as TRANSACTION_AMOUNT_BLOCKED
      | identifier | customer_profile_id | account_id | beneficiary_id | amount                        | purpose          | is_overdraft_allowed   | metadata              | currency | sub_txn_type |
      | TxId1      | BCPID1              | BankAccId1 | BeneficiaryId1 | <initiate_transaction_amount> | Integration Test | <is_overdraft_allowed> | {"key": "MyMetaData"} | SGD      | CARD_TXN     |

    Then I settle transaction to transfer funds with below details for requested amount less than blocked amount and expect the header statuscode <status_code> and transaction_status as <txn_status>
      | transaction_id | customer_profile_id | amount             | transaction_rail   | is_overdraft_allowed   | metadata              |
      | TxId1          | BCPID1              | <requested_amount> | <transaction_rail> | <is_overdraft_allowed> | {"key": "MyMetaData"} |

    Then I wait until max time to verify the transaction TxId2 status as <txn_status> for customerProfileId BCPID1

    Then I wait until max time to verify bank account BankAccId2 with an available balance of <updated_available_balance-1> and total balance of <updated_total_balance-1> for customerProfileId BCPID1

    Then I wait until max time to verify bank account BankAccId1 with an available balance of <updated_available_balance-2> and total balance of <updated_total_balance-2> for customerProfileId BCPID1

    Examples:
      | initiate_transaction_amount | initial_total_balance | initial_available_balance | requested_amount | updated_available_balance-1 | updated_total_balance-1 | updated_available_balance-2 | updated_total_balance-2 | bank_name | is_overdraft_allowed          | transaction_rail     | status_code | txn_status          | country | currency |
      | 80                          | 0                     | 0                         | 80               | 80                          | 80                      | -80                         | -80                     | DBS Bank Ltd       | true                 | FAST                 | 200         | TRANSACTION_SETTLED | SGP     | SGD      |
