Feature: Banking service negative balance transactions - initiate, update and settle scenario's

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

  Scenario Outline: Initiate transaction with amount which is less than the available balance and verify the amount is blocked successfully.
    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier | product_type | profile_type | product_class | currency   | country   | account_type | balance_policy_limit   | balance_policy_type    |
      | ProductID1 | WALLET       | CUSTOMER     | SHARIAH       | <currency> | <country> | SAVINGS      | <balance_policy_limit> | <balance_policy_type>  |

    Then I approve the product ProductID1 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Given I create account for CustomerProfile with id BCPID1 with product id as ProductID1 with bank account type as Payments Account with provider DBS Bank Ltd and expect the header status 200
      | identifier         | customer_profile_id | currency   | country   | in_trust | on_behalf_of | metadata              | kyc_completed | trust_verification_completed |
      | CustomerProfileBA1 | BCPID1              | <currency> | <country> | false    | CUSTOMER     | {"key": "MyMetaData"} | false         | false                        |

    Then I wait until max time to verify the bank account CustomerProfileBA1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1
    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier    | product_type   | profile_type     | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type    |
      | ProductID2    | WALLET         | END_CUSTOMER     |  SHARIAH      | <currency> | <country> | SAVINGS      | <balance_policy_limit>  | <balance_policy_type>  |

    Then I approve the product ProductID2 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Given I create account for EndCustomerProfile with id ECPID1 for CustomerProfile BCPID1 with product id ProductID2 with bank account type as <account_type> with provider <bank_name> and expect the header status 200
      | identifier | customer_profile_id | end_customer_profile_id          | currency   | country | in_trust | is_overdraft_allowed   | on_behalf_of | metadata                           |
      | BankAccId1 | BCPID1              | 36974646-3489-47aa-b6c2-w232d543 | <currency> | SGP     | false    | <is_overdraft_allowed> | CUSTOMER     | {"key": "TransactionIntegration1"} |

    Then I wait until max time to verify the bank account BankAccId1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    When I add External Bank Account as beneficiary to bank account BankAccId1 of CustomerProfile BCPID1 for provider <bank_name> and expect status 200
      | identifier     | beneficiary_name | address                                                                                                                                                                    | beneficiary_email     | is_hidden | metadata              | is_overdraft_allowed   | beneficiary_account_details                                                                                                                         | overdraft_funding_account_id   |
      | BeneficiaryId1 | Beneficiary1     | {"address_line_1":"line1","address_line_2":"line2","address_line_3":"line3","address_line_4":"line4","city":"Tokyo","state":"Tokyo","country_code":"JP","local_code":"JP"} | beneficiary1@test.com | false     | {"key": "MyMetaData"} | <is_overdraft_allowed> | {"bank_name":"SBI","currency":"SGD", "account_number": "1123344455","country":"SGP","code_details":{"sg_code_details":{"swift_bic":"DBSSSGSGXXX"}}} | <overdraft_funding_account_id> |

    Then I wait until max time to verify beneficiary BeneficiaryId1 create status as BENEFICIARY_CREATED with provider <bank_name> for customerProfileId BCPID1

    Given I deposit an amount of <deposit_amount> into BankAccId1 using cash DevDeposit and expect the header status 200
      | identifier           | customer_profile_id | purpose  | currency | transaction_rail |
      | DevDepositIdentifier | BCPID1              | TRANSFER | SGD      | FAST             |

    Then I wait until max time to verify bank account BankAccId1 with an increased balance of <deposit_amount> for customerProfileId BCPID1

    Then I initiate transaction to transfer funds with below details and expect the header statuscode <status_code> and transaction status as <txn_status>
      | identifier | customer_profile_id | account_id | beneficiary_id | amount   | purpose          | is_overdraft_allowed   | metadata              | currency | sub_txn_type |
      | TxId1      | BCPID1              | BankAccId1 | BeneficiaryId1 | <amount> | Integration Test | <is_overdraft_allowed> | {"key": "MyMetaData"} | SGD      | CARD_TXN     |

    Then I verify for bank account BankAccId1 total balance is <total_balance> and available balance is <available_balance> for customerProfileId BCPID1

    Examples:
      | deposit_amount | amount | currency | bank_name    | account_type | is_overdraft_allowed | is_overdraft_allowed | is_overdraft_allowed | status_code | txn_status                 | overdraft_funding_account_id | total_balance | available_balance | country | balance_policy_limit | balance_policy_type |
      | 1000           | 100    | SGD      | DBS Bank Ltd | e-money      | false                | false                | false                | 200         | TRANSACTION_AMOUNT_BLOCKED | CustomerProfileBA1           | 1000          | 900               | SGP     | 0                    | STRICT              |

  Scenario Outline: Initiate transaction with amount which is greater than the available balance and negative is not allowed and verify the Transaction fails with Insufficient Exception.

    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier | product_type | profile_type | product_class | currency   | country   | account_type | balance_policy_limit   | balance_policy_type    |
      | ProductID1 | WALLET       | CUSTOMER     | SHARIAH       | <currency> | <country> | SAVINGS      | <balance_policy_limit> | <balance_policy_type> |

    Then I approve the product ProductID1 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Given I create account for CustomerProfile with id BCPID1 with product id as ProductID1 with bank account type as Payments Account with provider DBS Bank Ltd and expect the header status 200
      | identifier         | customer_profile_id | currency | country | in_trust  | on_behalf_of | metadata              | kyc_completed | trust_verification_completed |
      | CustomerProfileBA1 | BCPID1              | SGD      | SGP     | false     | CUSTOMER     | {"key": "MyMetaData"} | false         | false                        |

    Then I wait until max time to verify the bank account CustomerProfileBA1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier    | product_type   | profile_type     | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type    |
      | ProductID2    | WALLET         | END_CUSTOMER     |  SHARIAH      | <currency> | <country> | SAVINGS      | <balance_policy_limit>  | <balance_policy_type>  |

    Then I approve the product ProductID2 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Given I create account for EndCustomerProfile with id ECPID1 for CustomerProfile BCPID1 with product id ProductID2 with bank account type as <account_type> with provider <bank_name> and expect the header status 200
      | identifier | customer_profile_id | end_customer_profile_id          | currency   | country | in_trust | is_overdraft_allowed   | on_behalf_of | metadata                           |
      | BankAccId1 | BCPID1              | 36974646-3489-47aa-b6c2-w232d543 | <currency> | SGP     | false    | <is_overdraft_allowed> | CUSTOMER     | {"key": "TransactionIntegration1"} |

    Then I wait until max time to verify the bank account BankAccId1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    When I add External Bank Account as beneficiary to bank account BankAccId1 of CustomerProfile BCPID1 for provider <bank_name> and expect status 200
      | identifier     | beneficiary_name | address                                                                                                                                                                    | beneficiary_email     | is_hidden | metadata              | is_overdraft_allowed   | beneficiary_account_details                                                                                                                         | overdraft_funding_account_id   |
      | BeneficiaryId1 | Beneficiary1     | {"address_line_1":"line1","address_line_2":"line2","address_line_3":"line3","address_line_4":"line4","city":"Tokyo","state":"Tokyo","country_code":"JP","local_code":"JP"} | beneficiary1@test.com | false     | {"key": "MyMetaData"} | <is_overdraft_allowed> | {"bank_name":"SBI","currency":"SGD", "account_number": "1123344455","country":"SGP","code_details":{"sg_code_details":{"swift_bic":"DBSSSGSGXXX"}}} | <overdraft_funding_account_id> |

    Then I wait until max time to verify beneficiary BeneficiaryId1 create status as BENEFICIARY_CREATED with provider <bank_name> for customerProfileId BCPID1

    Given I deposit an amount of <deposit_amount> into BankAccId1 using cash DevDeposit and expect the header status 200
      | identifier           | customer_profile_id | purpose  | currency | transaction_rail |
      | DevDepositIdentifier | BCPID1              | TRANSFER | SGD      | FAST             |

    Then I wait until max time to verify bank account BankAccId1 with an increased balance of <deposit_amount> for customerProfileId BCPID1

    Then I initiate transaction to transfer funds with below details and expect the header statuscode <status_code> and transaction status as <txn_status>
      | identifier | customer_profile_id | account_id | beneficiary_id | amount   | purpose          | is_overdraft_allowed   | metadata              | currency | sub_txn_type |
      | TxId1      | BCPID1              | BankAccId1 | BeneficiaryId1 | <amount> | Integration Test | <is_overdraft_allowed> | {"key": "MyMetaData"} | SGD      | CARD_TXN     |

    Then I verify for bank account BankAccId1 total balance is <total_balance> and available balance is <available_balance> for customerProfileId BCPID1

    Examples:
      | deposit_amount | amount | currency | bank_name    | account_type | is_overdraft_allowed | is_overdraft_allowed | is_overdraft_allowed | status_code | txn_status         | overdraft_funding_account_id | total_balance | available_balance | country | balance_policy_limit | balance_policy_type |
      | 80             | 90     | SGD      | DBS Bank Ltd | e-money      | false                | false                | false                | CSSM_9801   | TRANSACTION_FAILED | CustomerProfileBA1           | 80            | 80                | SGP     | 0                    | STRICT              |

  Scenario Outline: Initiate transaction with amount which is less than the available balance and negative txn allowed and verify the amount is blocked successfully.

    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier | product_type | profile_type | product_class | currency   | country   | account_type | balance_policy_limit | balance_policy_type |
      | ProductID1 | WALLET       | CUSTOMER     | SHARIAH       | <currency> | <country> | SAVINGS      | 0                    | STRICT              |

    Then I approve the product ProductID1 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Given I create account for CustomerProfile with id BCPID1 with product id as ProductID1 with bank account type as Payments Account with provider DBS Bank Ltd and expect the header status 200
      | identifier         | customer_profile_id | currency | country | in_trust | is_overdraft_allowed | on_behalf_of | metadata              | kyc_completed | trust_verification_completed |
      | CustomerProfileBA1 | IntegrationTest1    | SGD      | SGP     | false    | false                | CUSTOMER     | {"key": "MyMetaData"} | false         | false                        |

    Then I wait until max time to verify the bank account CustomerProfileBA1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier    | product_type   | profile_type     | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type    |
      | ProductID2    | WALLET         | END_CUSTOMER     |  SHARIAH      | <currency> | <country> | SAVINGS      | <balance_policy_limit>  | <balance_policy_type>  |

    Then I approve the product ProductID2 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Given I create account for EndCustomerProfile with id ECPID1 for CustomerProfile BCPID1 with product id ProductID2 with bank account type as <account_type> with provider <bank_name> and expect the header status 200
      | identifier | customer_profile_id | end_customer_profile_id          | currency   | country | in_trust | is_overdraft_allowed   | on_behalf_of | metadata                           |
      | BankAccId1 | BCPID1              | 36974646-3489-47aa-b6c2-w232d543 | <currency> | SGP     | false    | <is_overdraft_allowed> | CUSTOMER     | {"key": "TransactionIntegration1"} |

    Then I wait until max time to verify the bank account BankAccId1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    When I add External Bank Account as beneficiary to bank account BankAccId1 of CustomerProfile BCPID1 for provider <bank_name> and expect status 200
      | identifier     | beneficiary_name | address                                                                                                                                                                    | beneficiary_email     | is_hidden | metadata              | is_overdraft_allowed   | beneficiary_account_details                                                                                                                         | overdraft_funding_account_id   |
      | BeneficiaryId1 | Beneficiary1     | {"address_line_1":"line1","address_line_2":"line2","address_line_3":"line3","address_line_4":"line4","city":"Tokyo","state":"Tokyo","country_code":"JP","local_code":"JP"} | beneficiary1@test.com | false     | {"key": "MyMetaData"} | <is_overdraft_allowed> | {"bank_name":"SBI","currency":"SGD", "account_number": "1123344455","country":"SGP","code_details":{"sg_code_details":{"swift_bic":"DBSSSGSGXXX"}}} | <overdraft_funding_account_id> |

    Then I wait until max time to verify beneficiary BeneficiaryId1 create status as BENEFICIARY_CREATED with provider <bank_name> for customerProfileId BCPID1

    Given I deposit an amount of <deposit_amount> into BankAccId1 using cash DevDeposit and expect the header status 200
      | identifier           | customer_profile_id | purpose  | currency | transaction_rail |
      | DevDepositIdentifier | BCPID1              | TRANSFER | SGD      | FAST             |

    Then I wait until max time to verify bank account BankAccId1 with an increased balance of <deposit_amount> for customerProfileId BCPID1

    Then I initiate transaction to transfer funds with below details and expect the header statuscode <status_code> and transaction status as <txn_status>
      | identifier | customer_profile_id | account_id | beneficiary_id | amount   | purpose          | is_overdraft_allowed   | metadata              | currency | sub_txn_type |
      | TxId1      | BCPID1              | BankAccId1 | BeneficiaryId1 | <amount> | Integration Test | <is_overdraft_allowed> | {"key": "MyMetaData"} | SGD      | CARD_TXN     |

    Then I verify for bank account BankAccId1 total balance is <total_balance> and available balance is <available_balance> for customerProfileId BCPID1

    Examples:
      | deposit_amount | amount | currency | bank_name    | account_type | is_overdraft_allowed | status_code | txn_status                 | overdraft_funding_account_id | total_balance | available_balance | country | balance_policy_limit | balance_policy_type |
      | 80             | 90     | SGD      | DBS Bank Ltd | e-money      | true                 | 200         | TRANSACTION_AMOUNT_BLOCKED | CustomerProfileBA1           | 80            | -10               | SGP     | 0                    | LENIENT             |

  Scenario Outline: Initiate transaction with amount where available balance is 0 and negative txn allowed and verify the amount is blocked successfully.
    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier | product_type | profile_type | product_class | currency   | country   | account_type | balance_policy_limit | balance_policy_type |
      | ProductID1 | WALLET       | CUSTOMER     | SHARIAH       | <currency> | <country> | SAVINGS      | 0                    | STRICT              |

    Then I approve the product ProductID1 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Given I create account for CustomerProfile with id BCPID1 with product id as ProductID1 with bank account type as Payments Account with provider DBS Bank Ltd and expect the header status 200
      | identifier         | customer_profile_id | currency | country | in_trust | is_overdraft_allowed | on_behalf_of | metadata              | kyc_completed | trust_verification_completed |
      | CustomerProfileBA1 | IntegrationTest1    | SGD      | SGP     | false    | false                | CUSTOMER     | {"key": "MyMetaData"} | false         | false                        |

    Then I wait until max time to verify the bank account CustomerProfileBA1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier    | product_type   | profile_type     | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type    |
      | ProductID2    | WALLET         | END_CUSTOMER     |  SHARIAH      | <currency> | <country> | SAVINGS      | <balance_policy_limit>  | <balance_policy_type>  |
    
    Then I approve the product ProductID2 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Given I create account for EndCustomerProfile with id ECPID1 for CustomerProfile BCPID1 with product id ProductID2 with bank account type as <account_type> with provider <bank_name> and expect the header status 200
      | identifier | customer_profile_id | end_customer_profile_id          | currency   | country | in_trust | is_overdraft_allowed   | on_behalf_of | metadata                           |
      | BankAccId1 | BCPID1              | 36974646-3489-47aa-b6c2-w232d543 | <currency> | SGP     | false    | <is_overdraft_allowed> | CUSTOMER     | {"key": "TransactionIntegration1"} |

    Then I wait until max time to verify the bank account BankAccId1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    When I add External Bank Account as beneficiary to bank account BankAccId1 of CustomerProfile BCPID1 for provider <bank_name> and expect status 200
      | identifier     | beneficiary_name | address                                                                                                                                                                    | beneficiary_email     | is_hidden | metadata              | is_overdraft_allowed   | beneficiary_account_details                                                                                                                         | overdraft_funding_account_id   |
      | BeneficiaryId1 | Beneficiary1     | {"address_line_1":"line1","address_line_2":"line2","address_line_3":"line3","address_line_4":"line4","city":"Tokyo","state":"Tokyo","country_code":"JP","local_code":"JP"} | beneficiary1@test.com | false     | {"key": "MyMetaData"} | <is_overdraft_allowed> | {"bank_name":"SBI","currency":"SGD", "account_number": "1123344455","country":"SGP","code_details":{"sg_code_details":{"swift_bic":"DBSSSGSGXXX"}}} | <overdraft_funding_account_id> |

    Then I wait until max time to verify beneficiary BeneficiaryId1 create status as BENEFICIARY_CREATED with provider <bank_name> for customerProfileId BCPID1

    Then I verify for bank account BankAccId1 total balance is 0 and available balance is 0 for customerProfileId BCPID1

    Then I initiate transaction to transfer funds with below details and expect the header statuscode <status_code> and transaction status as <txn_status>
      | identifier | customer_profile_id | account_id | beneficiary_id | amount   | purpose          | is_overdraft_allowed   | metadata              | currency | sub_txn_type |
      | TxId1      | BCPID1              | BankAccId1 | BeneficiaryId1 | <amount> | Integration Test | <is_overdraft_allowed> | {"key": "MyMetaData"} | SGD      | CARD_TXN     |

    Then I verify for bank account BankAccId1 total balance is <total_balance> and available balance is <available_balance> for customerProfileId BCPID1

    Examples:
      | amount | currency | bank_name    | account_type | is_overdraft_allowed | is_overdraft_allowed | is_overdraft_allowed | balance_policy_limit | balance_policy_type  | status_code | txn_status                 | overdraft_funding_account_id | total_balance | available_balance | country |
      | 90     | SGD      | DBS Bank Ltd | e-money      | true                 | true                 | true                 | 0                    |  LENIENT             | 200         | TRANSACTION_AMOUNT_BLOCKED | CustomerProfileBA1           | 0             | -90               | SGP     |
      | 10.98  | SGD      | DBS Bank Ltd | e-money      | true                 | true                 | true                 | 0                    |  LENIENT             | 200         | TRANSACTION_AMOUNT_BLOCKED | CustomerProfileBA1           | 0             | -10.98            | SGP     |

  Scenario Outline: Initiate transaction with amount having decimal digits greater than permitted for requested currency
    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier | product_type | profile_type | product_class | currency   | country   | account_type | balance_policy_limit | balance_policy_type |
      | ProductID1 | WALLET       | CUSTOMER     | SHARIAH       | <currency> | <country> | SAVINGS      | 0                    | STRICT              |

    Then I approve the product ProductID1 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Given I create account for CustomerProfile with id BCPID1 with product id as ProductID1 with bank account type as Payments Account with provider DBS Bank Ltd and expect the header status 200
      | identifier         | customer_profile_id | currency | country | in_trust | is_overdraft_allowed | on_behalf_of | metadata              | kyc_completed | trust_verification_completed |
      | CustomerProfileBA1 | IntegrationTest1    | SGD      | SGP     | false    | false                | CUSTOMER     | {"key": "MyMetaData"} | false         | false                        |

    Then I wait until max time to verify the bank account CustomerProfileBA1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier    | product_type   | profile_type     | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type    |
      | ProductID2    | WALLET         | END_CUSTOMER     |  SHARIAH      | <currency> | <country> | SAVINGS      | <balance_policy_limit>  | <balance_policy_type>  |
    
    Then I approve the product ProductID2 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Given I create account for EndCustomerProfile with id ECPID1 for CustomerProfile BCPID1 with product id ProductID2 with bank account type as <account_type> with provider <bank_name> and expect the header status 200
      | identifier | customer_profile_id | end_customer_profile_id          | currency   | country | in_trust | is_overdraft_allowed   | on_behalf_of | metadata                           |
      | BankAccId1 | BCPID1              | 36974646-3489-47aa-b6c2-w232d543 | <currency> | SGP     | false    | <is_overdraft_allowed> | CUSTOMER     | {"key": "TransactionIntegration1"} |

    Then I wait until max time to verify the bank account BankAccId1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    When I add External Bank Account as beneficiary to bank account BankAccId1 of CustomerProfile BCPID1 for provider <bank_name> and expect status 200
      | identifier     | beneficiary_name | address                                                                                                                                                                    | beneficiary_email     | is_hidden | metadata              | is_overdraft_allowed   | beneficiary_account_details                                                                                                                         | overdraft_funding_account_id   |
      | BeneficiaryId1 | Beneficiary1     | {"address_line_1":"line1","address_line_2":"line2","address_line_3":"line3","address_line_4":"line4","city":"Tokyo","state":"Tokyo","country_code":"JP","local_code":"JP"} | beneficiary1@test.com | false     | {"key": "MyMetaData"} | <is_overdraft_allowed> | {"bank_name":"SBI","currency":"SGD", "account_number": "1123344455","country":"SGP","code_details":{"sg_code_details":{"swift_bic":"DBSSSGSGXXX"}}} | <overdraft_funding_account_id> |

    Then I wait until max time to verify beneficiary BeneficiaryId1 create status as BENEFICIARY_CREATED with provider <bank_name> for customerProfileId BCPID1

    Then I verify for bank account BankAccId1 total balance is 0 and available balance is 0 for customerProfileId BCPID1

    Then I initiate transaction to transfer funds with below details and expect the header statuscode <status_code>
      | identifier | customer_profile_id | account_id | beneficiary_id | amount   | purpose          | is_overdraft_allowed   | metadata              | currency | sub_txn_type |
      | TxId1      | BCPID1              | BankAccId1 | BeneficiaryId1 | <amount> | Integration Test | <is_overdraft_allowed> | {"key": "MyMetaData"} | SGD      | CARD_TXN     |

    Examples:
      | amount | currency | bank_name    | account_type | is_overdraft_allowed | is_overdraft_allowed | is_overdraft_allowed | status_code | overdraft_funding_account_id | country | balance_policy_limit | balance_policy_type |
      | 10.098 | SGD      | DBS Bank Ltd | e-money      | true                 | true                 | true                 | E9400       | CustomerProfileBA1           | SGP     | 0                    | LENIENT             |

  Scenario Outline: User initiated a txn T1 with the amount 20 out of which 10 is from main ledger and 10 is from lending and then user deposits 10 again and now user tries to initiate a txn T2 for 10 with negative txn not allowed which should fail as the available balance is 0
    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier | product_type | profile_type | product_class | currency   | country   | account_type | balance_policy_limit | balance_policy_type  |
      | ProductID1 | WALLET       | CUSTOMER     | SHARIAH       | <currency> | <country> | SAVINGS      | 0                    | STRICT               |

    Then I approve the product ProductID1 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Given I create account for CustomerProfile with id BCPID1 with product id as ProductID1 with bank account type as Payments Account with provider DBS Bank Ltd and expect the header status 200
      | identifier         | customer_profile_id | currency | country | in_trust | is_overdraft_allowed | on_behalf_of | metadata              | kyc_completed | trust_verification_completed |
      | CustomerProfileBA1 | IntegrationTest1    | SGD      | SGP     | false    | false                | CUSTOMER     | {"key": "MyMetaData"} | false         | false                        |

    Then I wait until max time to verify the bank account CustomerProfileBA1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier    | product_type   | profile_type     | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type    |
      | ProductID2    | WALLET         | END_CUSTOMER     |  SHARIAH      | <currency> | <country> | SAVINGS      | <balance_policy_limit>  | <balance_policy_type>  |

    Then I approve the product ProductID2 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Given I create account for EndCustomerProfile with id ECPID1 for CustomerProfile BCPID1 with product id ProductID2 with bank account type as <account_type> with provider <bank_name> and expect the header status 200
      | identifier | customer_profile_id | end_customer_profile_id          | currency   | country | in_trust    | on_behalf_of | metadata                           |
      | BankAccId1 | BCPID1              | 36974646-3489-47aa-b6c2-w232d543 | <currency> | SGP     | false       | CUSTOMER     | {"key": "TransactionIntegration1"} |

    Then I wait until max time to verify the bank account BankAccId1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    When I add External Bank Account as beneficiary to bank account BankAccId1 of CustomerProfile BCPID1 for provider <bank_name> and expect status 200
      | identifier     | beneficiary_name | address                                                                                                                                                                    | beneficiary_email     | is_hidden | metadata              | is_overdraft_allowed   | beneficiary_account_details                                                                                                                         | overdraft_funding_account_id   |
      | BeneficiaryId1 | Beneficiary1     | {"address_line_1":"line1","address_line_2":"line2","address_line_3":"line3","address_line_4":"line4","city":"Tokyo","state":"Tokyo","country_code":"JP","local_code":"JP"} | beneficiary1@test.com | false     | {"key": "MyMetaData"} | <is_overdraft_allowed> | {"bank_name":"SBI","currency":"SGD", "account_number": "1123344455","country":"SGP","code_details":{"sg_code_details":{"swift_bic":"DBSSSGSGXXX"}}} | <overdraft_funding_account_id> |

    Then I wait until max time to verify beneficiary BeneficiaryId1 create status as BENEFICIARY_CREATED with provider <bank_name> for customerProfileId BCPID1

    Given I deposit an amount of <deposit_amount> into BankAccId1 using cash DevDeposit and expect the header status 200
      | identifier           | customer_profile_id | purpose  | currency | transaction_rail |
      | DevDepositIdentifier | BCPID1              | TRANSFER | SGD      | FAST             |

    Then I wait until max time to verify bank account BankAccId1 with an increased balance of <deposit_amount> for customerProfileId BCPID1

    Then I initiate transaction to transfer funds with below details and expect the header statuscode <status_code> and transaction status as <txn_status>
      | identifier | customer_profile_id | account_id | beneficiary_id | amount   | purpose          | is_overdraft_allowed | metadata              | currency | sub_txn_type |
      | TxId1      | BCPID1              | BankAccId1 | BeneficiaryId1 | <amount> | Integration Test | true                 | {"key": "MyMetaData"} | SGD      | CARD_TXN     |

    Then I verify for bank account BankAccId1 total balance is 10 and available balance is -10 for customerProfileId BCPID1

    Given I deposit an amount of <deposit_amount> into BankAccId1 using cash DevDeposit and expect the header status 200
      | identifier           | customer_profile_id | purpose  | currency | transaction_rail |
      | DevDepositIdentifier | BCPID1              | TRANSFER | SGD      | FAST             |

    Then I wait until max time to verify bank account BankAccId1 with an increased balance of <deposit_amount> for customerProfileId BCPID1

    Then I verify for bank account BankAccId1 total balance is 20 and available balance is 0 for customerProfileId BCPID1

    Then I initiate transaction to transfer funds with below details and expect the header statuscode CSSM_9801 and transaction status as <txn_status>
      | identifier | customer_profile_id | account_id | beneficiary_id | amount | purpose          | is_overdraft_allowed | metadata              | currency | sub_txn_type |
      | TxId2      | BCPID1              | BankAccId1 | BeneficiaryId1 | 10     | Integration Test | false                | {"key": "MyMetaData"} | SGD      | CARD_TXN     |

    Examples:
      | deposit_amount | amount | currency | bank_name    | account_type | is_overdraft_allowed | is_overdraft_allowed | status_code | txn_status                 | overdraft_funding_account_id | country | balance_policy_limit | balance_policy_type |
      | 10             | 20     | SGD      | DBS Bank Ltd | e-money      | true                 | true                 | 200         | TRANSACTION_AMOUNT_BLOCKED | CustomerProfileBA1           | SGP     | 0                    | LENIENT             |


  Scenario Outline: Initiate transaction with overdraft for account as false and true for transaction should give CSSM_9806

    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier    | product_type   | profile_type | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type    |
      | ProductID1    | WALLET         | CUSTOMER     |  SHARIAH      | <currency> | <country> | SAVINGS      | 0                       | STRICT                 |

    Then I approve the product ProductID1 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Given I create account for CustomerProfile with id BCPID1 with product id as ProductID1 with bank account type as Payments Account with provider DBS Bank Ltd and expect the header status 200
      | identifier         | customer_profile_id | currency | country | in_trust | is_overdraft_allowed | on_behalf_of | metadata              | kyc_completed | trust_verification_completed |
      | CustomerProfileBA1 | IntegrationTest1    | SGD      | SGP     | false    | false                | CUSTOMER     | {"key": "MyMetaData"} | false         | false                        |

    Then I wait until max time to verify the bank account CustomerProfileBA1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier    | product_type   | profile_type     | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type    |
      | ProductID2    | WALLET         | END_CUSTOMER     |  SHARIAH      | <currency> | <country> | SAVINGS      | 0                       | STRICT                 |

    Then I approve the product ProductID2 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Given I create account for EndCustomerProfile with id ECPID1 for CustomerProfile BCPID1 with product id ProductID2 with bank account type as <account_type> with provider <bank_name> and expect the header status 200
      | identifier | customer_profile_id | end_customer_profile_id          | currency   | country | in_trust | is_overdraft_allowed | on_behalf_of | metadata                           |
      | BankAccId1 | BCPID1              | 36974646-3489-47aa-b6c2-w232d543 | <currency> | SGP     | false    | false                | CUSTOMER     | {"key": "TransactionIntegration1"} |

    Then I wait until max time to verify the bank account BankAccId1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    When I add External Bank Account as beneficiary to bank account BankAccId1 of CustomerProfile BCPID1 for provider <bank_name> and expect status 200
      | identifier     | beneficiary_name | address                                                                                                                                                                    | beneficiary_email     | is_hidden | metadata              | is_overdraft_allowed | beneficiary_account_details                                                                                                                         | overdraft_funding_account_id   |
      | BeneficiaryId1 | Beneficiary1     | {"address_line_1":"line1","address_line_2":"line2","address_line_3":"line3","address_line_4":"line4","city":"Tokyo","state":"Tokyo","country_code":"JP","local_code":"JP"} | beneficiary1@test.com | false     | {"key": "MyMetaData"} | false                | {"bank_name":"SBI","currency":"SGD", "account_number": "1123344455","country":"SGP","code_details":{"sg_code_details":{"swift_bic":"DBSSSGSGXXX"}}} | <overdraft_funding_account_id> |

    Then I wait until max time to verify beneficiary BeneficiaryId1 create status as BENEFICIARY_CREATED with provider <bank_name> for customerProfileId BCPID1

    Given I deposit an amount of <deposit_amount> into BankAccId1 using cash DevDeposit and expect the header status 200
      | identifier           | customer_profile_id | purpose  | currency | transaction_rail |
      | DevDepositIdentifier | BCPID1              | TRANSFER | SGD      | FAST             |

    Then I wait until max time to verify bank account BankAccId1 with an increased balance of <deposit_amount> for customerProfileId BCPID1

    Then I initiate transaction to transfer funds with below details and expect the header statuscode <status_code>
      | identifier | customer_profile_id | account_id | beneficiary_id | amount   | purpose          | is_overdraft_allowed | metadata              | currency | sub_txn_type |
      | TxId1      | BCPID1              | BankAccId1 | BeneficiaryId1 | <amount> | Integration Test | true                 | {"key": "MyMetaData"} | SGD      | CARD_TXN     |


    Examples:
      | deposit_amount | amount | currency | bank_name    | account_type | status_code | overdraft_funding_account_id | country |
      | 80             | 90     | SGD      | DBS Bank Ltd | e-money      | CSSM_9806   | CustomerProfileBA1           | SGP     |

  Scenario Outline: Update already initiated transaction T1 to a different amount

    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier    | product_type   | profile_type | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type    |
      | ProductID1    | WALLET         | CUSTOMER     |  SHARIAH      | <currency> | <country> | SAVINGS      | 0                       | STRICT                 |

    Then I approve the product ProductID1 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Given I create account for CustomerProfile with id BCPID1 with product id as ProductID1 with bank account type as Payments Account with provider DBS Bank Ltd and expect the header status 200
      | identifier         | customer_profile_id | currency | country | in_trust | is_overdraft_allowed | on_behalf_of | metadata              | kyc_completed | trust_verification_completed |
      | CustomerProfileBA1 | IntegrationTest1    | SGD      | SGP     | false    | false                | CUSTOMER     | {"key": "MyMetaData"} | false         | false                        |

    Then I wait until max time to verify the bank account CustomerProfileBA1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier | product_type | profile_type | product_class | currency   | country   | account_type | balance_policy_limit   |  balance_policy_type   |
      | ProductID2 | WALLET       | END_CUSTOMER | SHARIAH       | <currency> | <country> | SAVINGS      | <balance_policy_limit> |  <balance_policy_type> |

    Then I approve the product ProductID2 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Given I create account for EndCustomerProfile with id ECPID1 for CustomerProfile BCPID1 with product id ProductID2 with bank account type as <account_type> with provider <bank_name> and expect the header status 200
      | identifier | customer_profile_id | end_customer_profile_id          | currency   | country | in_trust   | on_behalf_of | metadata                           |
      | BankAccId1 | BCPID1              | 36974646-3489-47aa-b6c2-w232d543 | <currency> | SGP     | false      | CUSTOMER     | {"key": "TransactionIntegration1"} |

    Then I wait until max time to verify the bank account BankAccId1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    When I add External Bank Account as beneficiary to bank account BankAccId1 of CustomerProfile BCPID1 for provider <bank_name> and expect status 200
      | identifier     | beneficiary_name | address                                                                                                                                                                    | beneficiary_email     | is_hidden | metadata              | is_overdraft_allowed  | beneficiary_account_details                                                                                                                         | overdraft_funding_account_id   |
      | BeneficiaryId1 | Beneficiary1     | {"address_line_1":"line1","address_line_2":"line2","address_line_3":"line3","address_line_4":"line4","city":"Tokyo","state":"Tokyo","country_code":"JP","local_code":"JP"} | beneficiary1@test.com | false     | {"key": "MyMetaData"} | <is_Account_negative> | {"bank_name":"SBI","currency":"SGD", "account_number": "1123344455","country":"SGP","code_details":{"sg_code_details":{"swift_bic":"DBSSSGSGXXX"}}} | <overdraft_funding_account_id> |

    Then I wait until max time to verify beneficiary BeneficiaryId1 create status as BENEFICIARY_CREATED with provider <bank_name> for customerProfileId BCPID1

    Given I deposit an amount of <deposit_amount> into BankAccId1 using cash DevDeposit and expect the header status 200
      | identifier           | customer_profile_id | purpose  | currency | transaction_rail |
      | DevDepositIdentifier | BCPID1              | TRANSFER | SGD      | FAST             |

    Then I wait until max time to verify bank account BankAccId1 with an increased balance of <deposit_amount> for customerProfileId BCPID1

    Then I initiate transaction to transfer funds with below details and expect the header statuscode 200 and transaction status as TRANSACTION_AMOUNT_BLOCKED
      | identifier | customer_profile_id | account_id | beneficiary_id | amount                        | purpose          | is_overdraft_allowed   | metadata              | currency | sub_txn_type |
      | TxId1      | BCPID1              | BankAccId1 | BeneficiaryId1 | <initiate_transaction_amount> | Integration Test | <is_overdraft_allowed> | {"key": "MyMetaData"} | SGD      | CARD_TXN     |

    Then I verify for bank account BankAccId1 total balance is <initial_total_balance> and available balance is <initial_available_balance> for customerProfileId BCPID1

    Then I update transaction with transaction_id TxId1 with the negative_transfer_allowed as <updated_is_overdraft_allowed> and expect the header statuscode <status_code> and transaction status as <txn_status>
      | transaction_id | customer_profile_id | amount           | is_overdraft_allowed           | metadata              |
      | TxId1          | BCPID1              | <updated_amount> | <updated_is_overdraft_allowed> | {"key": "MyMetaData"} |

    Then I verify for bank account BankAccId1 total balance is <total_balance> and available balance is <available_balance> for customerProfileId BCPID1

    Examples:
      | deposit_amount | initiate_transaction_amount | updated_amount | currency | country | bank_name    | account_type | is_Account_negative | balance_policy_limit | balance_policy_type | is_overdraft_allowed | updated_is_overdraft_allowed | status_code | txn_status                 | overdraft_funding_account_id | initial_total_balance | initial_available_balance | total_balance | available_balance |
      | 150            | 100                         | 120            | SGD      | SGP     | DBS Bank Ltd | e-money      | true                | 0                    | LENIENT             | true                 | true                         | 200         | TRANSACTION_AMOUNT_BLOCKED | CustomerProfileBA1           | 150                   | 50                        | 150           | 30                |
      | 150            | 100                         | 180            | SGD      | SGP     | DBS Bank Ltd | e-money      | true                | 0                    | LENIENT             |true                 | true                         | 200         | TRANSACTION_AMOUNT_BLOCKED | CustomerProfileBA1           | 150                   | 50                        | 150           | -30               |
      | 100            | 80                          | 90             | SGD      | SGP     | DBS Bank Ltd | e-money      | true                | 0                    | LENIENT             |false                | false                        | 200         | TRANSACTION_AMOUNT_BLOCKED | CustomerProfileBA1           | 100                   | 20                        | 100           | 10                |
      | 100            | 80                          | 90             | SGD      | SGP     | DBS Bank Ltd | e-money      | true                | 0                    | LENIENT             |false                | true                         | 200         | TRANSACTION_AMOUNT_BLOCKED | CustomerProfileBA1           | 100                   | 20                        | 100           | 10                |

  Scenario Outline: Update already initiated transaction T1 to a different amount with decimal digits greater than permitted for a currency
    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier    | product_type   | profile_type | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type    |
      | ProductID1    | WALLET         | CUSTOMER     |  SHARIAH      | <currency> | <country> | SAVINGS      | 0                       | STRICT                 |

    Then I approve the product ProductID1 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Given I create account for CustomerProfile with id BCPID1 with product id as ProductID1 with bank account type as Payments Account with provider DBS Bank Ltd and expect the header status 200
      | identifier         | customer_profile_id | currency | country | in_trust | is_overdraft_allowed | on_behalf_of | metadata              | kyc_completed | trust_verification_completed |
      | CustomerProfileBA1 | IntegrationTest1    | SGD      | SGP     | false    | false                | CUSTOMER     | {"key": "MyMetaData"} | false         | false                        |

    Then I wait until max time to verify the bank account CustomerProfileBA1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier | product_type | profile_type | product_class | currency   | country   | account_type | balance_policy_limit   | balance_policy_type   |
      | ProductID2 | WALLET       | END_CUSTOMER | SHARIAH       | <currency> | <country> | SAVINGS      | <balance_policy_limit> | <balance_policy_type> |

    Then I approve the product ProductID2 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Given I create account for EndCustomerProfile with id ECPID1 for CustomerProfile BCPID1 with product id ProductID2 with bank account type as <account_type> with provider <bank_name> and expect the header status 200
      | identifier | customer_profile_id | end_customer_profile_id          | currency   | country | in_trust | on_behalf_of | metadata                           |
      | BankAccId1 | BCPID1              | 36974646-3489-47aa-b6c2-w232d543 | <currency> | SGP     | false    | CUSTOMER     | {"key": "TransactionIntegration1"} |

    Then I wait until max time to verify the bank account BankAccId1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    When I add External Bank Account as beneficiary to bank account BankAccId1 of CustomerProfile BCPID1 for provider <bank_name> and expect status 200
      | identifier     | beneficiary_name | address                                                                                                                                                                    | beneficiary_email     | is_hidden | metadata              | is_overdraft_allowed  | beneficiary_account_details                                                                                                                         | overdraft_funding_account_id   |
      | BeneficiaryId1 | Beneficiary1     | {"address_line_1":"line1","address_line_2":"line2","address_line_3":"line3","address_line_4":"line4","city":"Tokyo","state":"Tokyo","country_code":"JP","local_code":"JP"} | beneficiary1@test.com | false     | {"key": "MyMetaData"} | <is_Account_negative> | {"bank_name":"SBI","currency":"SGD", "account_number": "1123344455","country":"SGP","code_details":{"sg_code_details":{"swift_bic":"DBSSSGSGXXX"}}} | <overdraft_funding_account_id> |

    Then I wait until max time to verify beneficiary BeneficiaryId1 create status as BENEFICIARY_CREATED with provider <bank_name> for customerProfileId BCPID1

    Given I deposit an amount of <deposit_amount> into BankAccId1 using cash DevDeposit and expect the header status 200
      | identifier           | customer_profile_id | purpose  | currency | transaction_rail |
      | DevDepositIdentifier | BCPID1              | TRANSFER | SGD      | FAST             |

    Then I wait until max time to verify bank account BankAccId1 with an increased balance of <deposit_amount> for customerProfileId BCPID1

    Then I initiate transaction to transfer funds with below details and expect the header statuscode 200 and transaction status as TRANSACTION_AMOUNT_BLOCKED
      | identifier | customer_profile_id | account_id | beneficiary_id | amount                        | purpose          | is_overdraft_allowed   | metadata              | currency | sub_txn_type |
      | TxId1      | BCPID1              | BankAccId1 | BeneficiaryId1 | <initiate_transaction_amount> | Integration Test | <is_overdraft_allowed> | {"key": "MyMetaData"} | SGD      | CARD_TXN     |

    Then I verify for bank account BankAccId1 total balance is <initial_total_balance> and available balance is <initial_available_balance> for customerProfileId BCPID1

    Then I update transaction with transaction_id TxId1 with the negative_transfer_allowed as <updated_is_overdraft_allowed> and expect the header statuscode <status_code>
      | transaction_id | customer_profile_id | amount           | is_overdraft_allowed           | metadata              |
      | TxId1          | BCPID1              | <updated_amount> | <updated_is_overdraft_allowed> | {"key": "MyMetaData"} |

    Examples:
      | deposit_amount | initiate_transaction_amount | updated_amount | currency | bank_name    | account_type | is_Account_negative | is_overdraft_allowed | updated_is_overdraft_allowed | status_code | overdraft_funding_account_id | initial_total_balance | initial_available_balance | country | balance_policy_type | balance_policy_limit |
      | 150            | 100                         | 120.2345       | SGD      | DBS Bank Ltd | e-money      | true                | true                 | true                         | E9400       | CustomerProfileBA1           | 150                   | 50                        | SGP     | LENIENT             |  0                   |

  Scenario Outline: Update transaction where the balance is 0 while initiating but account got some deposit before updating and verify the amount is blocked successfully.

    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier    | product_type   | profile_type | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type    |
      | ProductID1    | WALLET         | CUSTOMER     |  SHARIAH      | <currency> | <country> | SAVINGS      | 0                       | STRICT                 |

    Then I approve the product ProductID1 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Given I create account for CustomerProfile with id BCPID1 with product id as ProductID1 with bank account type as Payments Account with provider DBS Bank Ltd and expect the header status 200
      | identifier         | customer_profile_id | currency | country | in_trust | is_overdraft_allowed | on_behalf_of | metadata              | kyc_completed | trust_verification_completed |
      | CustomerProfileBA1 | IntegrationTest1    | SGD      | SGP     | false    | false                | CUSTOMER     | {"key": "MyMetaData"} | false         | false                        |

    Then I wait until max time to verify the bank account CustomerProfileBA1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier | product_type | profile_type | product_class | currency   | country   | account_type | balance_policy_limit   | balance_policy_type    |
      | ProductID2 | WALLET       | END_CUSTOMER | SHARIAH       | <currency> | <country> | SAVINGS      | <balance_policy_limit> | <balance_policy_type>  |

    Then I approve the product ProductID2 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Given I create account for EndCustomerProfile with id ECPID1 for CustomerProfile BCPID1 with product id ProductID2 with bank account type as <account_type> with provider <bank_name> and expect the header status 200
      | identifier | customer_profile_id | end_customer_profile_id          | currency   | country | in_trust | on_behalf_of | metadata                           |
      | BankAccId1 | BCPID1              | 36974646-3489-47aa-b6c2-w232d543 | <currency> | SGP     | false    | CUSTOMER     | {"key": "TransactionIntegration1"} |

    Then I wait until max time to verify the bank account BankAccId1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    Then I wait until max time to verify bank account BankAccId1 with an available balance of 0 and total balance of 0 for customerProfileId BCPID1

    When I add External Bank Account as beneficiary to bank account BankAccId1 of CustomerProfile BCPID1 for provider <bank_name> and expect status 200
      | identifier     | beneficiary_name | address                                                                                                                                                                    | beneficiary_email     | is_hidden | metadata              | is_overdraft_allowed   | beneficiary_account_details                                                                                                                         | overdraft_funding_account_id   |
      | BeneficiaryId1 | Beneficiary1     | {"address_line_1":"line1","address_line_2":"line2","address_line_3":"line3","address_line_4":"line4","city":"Tokyo","state":"Tokyo","country_code":"JP","local_code":"JP"} | beneficiary1@test.com | false     | {"key": "MyMetaData"} | <is_overdraft_allowed> | {"bank_name":"SBI","currency":"SGD", "account_number": "1123344455","country":"SGP","code_details":{"sg_code_details":{"swift_bic":"DBSSSGSGXXX"}}} | <overdraft_funding_account_id> |

    Then I wait until max time to verify beneficiary BeneficiaryId1 create status as BENEFICIARY_CREATED with provider <bank_name> for customerProfileId BCPID1

    Then I initiate transaction to transfer funds with below details and expect the header statuscode 200 and transaction status as TRANSACTION_AMOUNT_BLOCKED
      | identifier | customer_profile_id | account_id | beneficiary_id | amount                        | purpose          | is_overdraft_allowed   | metadata              | currency | sub_txn_type |
      | TxId1      | BCPID1              | BankAccId1 | BeneficiaryId1 | <initiate_transaction_amount> | Integration Test | <is_overdraft_allowed> | {"key": "MyMetaData"} | SGD      | CARD_TXN     |

    Then I verify for bank account BankAccId1 total balance is <initial_total_balance> and available balance is <initial_available_balance> for customerProfileId BCPID1

    Given I deposit an amount of <deposit_amount> into BankAccId1 using cash DevDeposit and expect the header status 200
      | identifier           | customer_profile_id | purpose  | currency | transaction_rail |
      | DevDepositIdentifier | BCPID1              | TRANSFER | SGD      | FAST             |

    Then I wait until max time to verify bank account BankAccId1 with an available balance of <available_balance> and total balance of <total_balance> for customerProfileId BCPID1
    # available balance will be 50 even though the deposit is 150 because 100 is lent in above initiate transaction.

    Then I update transaction with transaction_id TxId1 with the negative_transfer_allowed as <is_overdraft_allowed> and expect the header statuscode <status_code> and transaction status as <txn_status>
      | transaction_id | customer_profile_id | amount           | is_overdraft_allowed   | metadata              |
      | TxId1          | BCPID1              | <updated_amount> | <is_overdraft_allowed> | {"key": "MyMetaData"} |

    Then I verify for bank account BankAccId1 total balance is <updated_total_balance> and available balance is <updated_available_balance> for customerProfileId BCPID1

    Examples:
      | deposit_amount | initiate_transaction_amount | updated_amount | currency | bank_name    | account_type | is_Account_negative | is_overdraft_allowed | status_code | txn_status                 | overdraft_funding_account_id | initial_total_balance | initial_available_balance | available_balance | total_balance | updated_total_balance | updated_available_balance | country | balance_policy_limit | balance_policy_type |
      | 150            | 100                         | 120            | SGD      | DBS Bank Ltd | e-money      | true                | true                 | 200         | TRANSACTION_AMOUNT_BLOCKED | CustomerProfileBA1           | 0                     | -100                      | 50                | 150           | 150                   | 30                        | SGP     | 0                    | LENIENT             |

  Scenario Outline: Update transaction where user has initial balance of 200, then a transaction T1 is initiated for 100, then a transaction T2 is initiated for 100. now user asked for update of T1 to 80 with negative false and verify the amount is blocked successfully
    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier    | product_type   | profile_type | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type    |
      | ProductID1    | WALLET         | CUSTOMER     |  SHARIAH      | <currency> | <country> | SAVINGS      | 0                       | STRICT                 |

    Then I approve the product ProductID1 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Given I create account for CustomerProfile with id BCPID1 with product id as ProductID1 with bank account type as Payments Account with provider DBS Bank Ltd and expect the header status 200
      | identifier         | customer_profile_id | currency | country | in_trust | is_overdraft_allowed | on_behalf_of | metadata              | kyc_completed | trust_verification_completed |
      | CustomerProfileBA1 | IntegrationTest1    | SGD      | SGP     | false    | false                | CUSTOMER     | {"key": "MyMetaData"} | false         | false                        |

    Then I wait until max time to verify the bank account CustomerProfileBA1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier | product_type | profile_type | product_class | currency   | country   | account_type | balance_policy_limit   | balance_policy_type   |
      | ProductID2 | WALLET       | END_CUSTOMER | SHARIAH       | <currency> | <country> | SAVINGS      | <balance_policy_limit> | <balance_policy_type> |

    Then I approve the product ProductID2 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Given I create account for EndCustomerProfile with id ECPID1 for CustomerProfile BCPID1 with product id ProductID2 with bank account type as <account_type> with provider <bank_name> and expect the header status 200
      | identifier | customer_profile_id | end_customer_profile_id          | currency   | country | in_trust | on_behalf_of | metadata                           |
      | BankAccId1 | BCPID1              | 36974646-3489-47aa-b6c2-w232d543 | <currency> | SGP     | false    | CUSTOMER     | {"key": "TransactionIntegration1"} |

    Then I wait until max time to verify the bank account BankAccId1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    When I add External Bank Account as beneficiary to bank account BankAccId1 of CustomerProfile BCPID1 for provider <bank_name> and expect status 200
      | identifier     | beneficiary_name | address                                                                                                                                                                    | beneficiary_email     | is_hidden | metadata              | is_overdraft_allowed | beneficiary_account_details                                                                                                                         | overdraft_funding_account_id   |
      | BeneficiaryId1 | Beneficiary1     | {"address_line_1":"line1","address_line_2":"line2","address_line_3":"line3","address_line_4":"line4","city":"Tokyo","state":"Tokyo","country_code":"JP","local_code":"JP"} | beneficiary1@test.com | false     | {"key": "MyMetaData"} | true                 | {"bank_name":"SBI","currency":"SGD", "account_number": "1123344455","country":"SGP","code_details":{"sg_code_details":{"swift_bic":"DBSSSGSGXXX"}}} | <overdraft_funding_account_id> |

    Then I wait until max time to verify beneficiary BeneficiaryId1 create status as BENEFICIARY_CREATED with provider <bank_name> for customerProfileId BCPID1

    Given I deposit an amount of <deposit_amount> into BankAccId1 using cash DevDeposit and expect the header status 200
      | identifier           | customer_profile_id | purpose  | currency | transaction_rail |
      | DevDepositIdentifier | BCPID1              | TRANSFER | SGD      | FAST             |

    Then I wait until max time to verify bank account BankAccId1 with an available balance of 200 and total balance of 200 for customerProfileId BCPID1

    Then I initiate transaction to transfer funds with below details and expect the header statuscode 200 and transaction status as TRANSACTION_AMOUNT_BLOCKED
      | identifier | customer_profile_id | account_id | beneficiary_id | amount                        | purpose          | is_overdraft_allowed   | metadata              | currency | sub_txn_type |
      | TxId1      | BCPID1              | BankAccId1 | BeneficiaryId1 | <initiate_transaction_amount> | Integration Test | <is_overdraft_allowed> | {"key": "MyMetaData"} | SGD      | CARD_TXN     |

    Then I verify for bank account BankAccId1 total balance is <total_balance> and available balance is <available_balance> for customerProfileId BCPID1

    Then I initiate transaction to transfer funds with below details and expect the header statuscode 200 and transaction status as TRANSACTION_AMOUNT_BLOCKED
      | identifier | customer_profile_id | account_id | beneficiary_id | amount                        | purpose          | is_overdraft_allowed   | metadata              | currency | sub_txn_type |
      | TxId2      | BCPID1              | BankAccId1 | BeneficiaryId1 | <initiate_transaction_amount> | Integration Test | <is_overdraft_allowed> | {"key": "MyMetaData"} | SGD      | CARD_TXN     |

    Then I verify for bank account BankAccId1 total balance is <initial_total_balance> and available balance is <initial_available_balance> for customerProfileId BCPID1

    Then I update transaction with transaction_id TxId1 with the negative_transfer_allowed as <is_overdraft_allowed> and expect the header statuscode <status_code> and transaction status as <txn_status>
      | transaction_id | customer_profile_id | amount           | is_overdraft_allowed   | metadata              |
      | TxId1          | BCPID1              | <updated_amount> | <is_overdraft_allowed> | {"key": "MyMetaData"} |

    Then I verify for bank account BankAccId1 total balance is <updated_total_balance> and available balance is <updated_available_balance> for customerProfileId BCPID1

    Examples:
      | deposit_amount | initiate_transaction_amount | updated_amount | currency | bank_name    | account_type | is_Account_negative | is_overdraft_allowed | status_code | txn_status                 | overdraft_funding_account_id | total_balance | available_balance | initial_total_balance | initial_available_balance | updated_total_balance | updated_available_balance | country | balance_policy_limit | balance_policy_type |
      | 200            | 100                         | 80             | SGD      | DBS Bank Ltd | e-money      | true                | false                | 200         | TRANSACTION_AMOUNT_BLOCKED | CustomerProfileBA1           | 200           | 100               | 200                   | 0                         | 200                   | 20                        | SGP     | 0                    | LENIENT             |

  Scenario Outline: Update transaction case where user has initiated a transaction T1. but trying to update the transaction to an amount of 0 should throw an exception

    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier    | product_type   | profile_type | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type    |
      | ProductID1    | WALLET         | CUSTOMER     |  SHARIAH      | <currency> | <country> | SAVINGS      | 0                       | STRICT                 |

    Then I approve the product ProductID1 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Given I create account for CustomerProfile with id BCPID1 with product id as ProductID1 with bank account type as Payments Account with provider DBS Bank Ltd and expect the header status 200
      | identifier         | customer_profile_id | currency | country | in_trust | is_overdraft_allowed | on_behalf_of | metadata              | kyc_completed | trust_verification_completed |
      | CustomerProfileBA1 | IntegrationTest1    | SGD      | SGP     | false    | false                | CUSTOMER     | {"key": "MyMetaData"} | false         | false                        |

    Then I wait until max time to verify the bank account CustomerProfileBA1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier | product_type | profile_type | product_class | currency   | country   | account_type | balance_policy_limit   | balance_policy_type    |
      | ProductID2 | WALLET       | END_CUSTOMER | SHARIAH       | <currency> | <country> | SAVINGS      | <balance_policy_limit> | <balance_policy_type>  |

    Then I approve the product ProductID2 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Given I create account for EndCustomerProfile with id ECPID1 for CustomerProfile BCPID1 with product id ProductID2 with bank account type as <account_type> with provider <bank_name> and expect the header status 200
      | identifier | customer_profile_id | end_customer_profile_id          | currency   | country | in_trust | is_overdraft_allowed  | on_behalf_of | metadata                           |
      | BankAccId1 | BCPID1              | 36974646-3489-47aa-b6c2-w232d543 | <currency> | SGP     | false    | <is_Account_negative> | CUSTOMER     | {"key": "TransactionIntegration1"} |

    Then I wait until max time to verify the bank account BankAccId1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    When I add External Bank Account as beneficiary to bank account BankAccId1 of CustomerProfile BCPID1 for provider <bank_name> and expect status 200
      | identifier     | beneficiary_name | address                                                                                                                                                                    | beneficiary_email     | is_hidden | metadata              | is_overdraft_allowed   | beneficiary_account_details                                                                                                                         | overdraft_funding_account_id   |
      | BeneficiaryId1 | Beneficiary1     | {"address_line_1":"line1","address_line_2":"line2","address_line_3":"line3","address_line_4":"line4","city":"Tokyo","state":"Tokyo","country_code":"JP","local_code":"JP"} | beneficiary1@test.com | false     | {"key": "MyMetaData"} | <is_overdraft_allowed> | {"bank_name":"SBI","currency":"SGD", "account_number": "1123344455","country":"SGP","code_details":{"sg_code_details":{"swift_bic":"DBSSSGSGXXX"}}} | <overdraft_funding_account_id> |

    Then I wait until max time to verify beneficiary BeneficiaryId1 create status as BENEFICIARY_CREATED with provider <bank_name> for customerProfileId BCPID1

    Given I deposit an amount of <deposit_amount> into BankAccId1 using cash DevDeposit and expect the header status 200
      | identifier           | customer_profile_id | purpose  | currency | transaction_rail |
      | DevDepositIdentifier | BCPID1              | TRANSFER | SGD      | FAST             |

    Then I wait until max time to verify bank account BankAccId1 with an increased balance of <deposit_amount> for customerProfileId BCPID1

    Then I initiate transaction to transfer funds with below details and expect the header statuscode 200 and transaction status as TRANSACTION_AMOUNT_BLOCKED
      | identifier | customer_profile_id | account_id | beneficiary_id | amount                        | purpose          | is_overdraft_allowed   | metadata              | currency | sub_txn_type |
      | TxId1      | BCPID1              | BankAccId1 | BeneficiaryId1 | <initiate_transaction_amount> | Integration Test | <is_overdraft_allowed> | {"key": "MyMetaData"} | SGD      | CARD_TXN     |

    Then I verify for bank account BankAccId1 total balance is <initial_total_balance> and available balance is <initial_available_balance> for customerProfileId BCPID1

    Then I update transaction with transaction_id TxId1 with the negative_transfer_allowed as <is_overdraft_allowed> and expect the header statuscode <status_code>
      | transaction_id | customer_profile_id | amount           | is_overdraft_allowed   | metadata              |
      | TxId1          | BCPID1              | <updated_amount> | <is_overdraft_allowed> | {"key": "MyMetaData"} |

    Examples:
      | deposit_amount | initiate_transaction_amount | updated_amount | currency | bank_name    | account_type | is_Account_negative | is_overdraft_allowed | status_code | overdraft_funding_account_id | initial_total_balance | initial_available_balance | country | balance_policy_limit | balance_policy_type |
      | 150            | 100                         | 0              | SGD      | DBS Bank Ltd | e-money      | true                | true                 | E9400       | CustomerProfileBA1           | 150                   | 50                        | SGP     | 0                    | LENIENT             |

    ## Cancel transaction scenarios###
  Scenario Outline: User trying to cancel a transaction which has been initiated and is in TRANSACTION_AMOUNT_BLOCKED state
    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier    | product_type   | profile_type | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type    |
      | ProductID1    | WALLET         | CUSTOMER     |  SHARIAH      | <currency> | <country> | SAVINGS      | 0                       | STRICT                 |

    Then I approve the product ProductID1 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Given I create account for CustomerProfile with id BCPID1 with product id as ProductID1 with bank account type as Payments Account with provider DBS Bank Ltd and expect the header status 200
      | identifier         | customer_profile_id | currency | country | in_trust | is_overdraft_allowed | on_behalf_of | metadata              | kyc_completed | trust_verification_completed |
      | CustomerProfileBA1 | IntegrationTest1    | SGD      | SGP     | false    | false                | CUSTOMER     | {"key": "MyMetaData"} | false         | false                        |

    Then I wait until max time to verify the bank account CustomerProfileBA1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier | product_type | profile_type | product_class | currency   | country   | account_type | balance_policy_limit   | balance_policy_type   |
      | ProductID2 | WALLET       | END_CUSTOMER | SHARIAH       | <currency> | <country> | SAVINGS      | <balance_policy_limit> | <balance_policy_type> |

    Then I approve the product ProductID2 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Given I create account for EndCustomerProfile with id ECPID1 for CustomerProfile BCPID1 with product id ProductID2 with bank account type as <account_type> with provider <bank_name> and expect the header status 200
      | identifier | customer_profile_id | end_customer_profile_id          | currency   | country | in_trust | is_overdraft_allowed  | on_behalf_of | metadata                           |
      | BankAccId1 | BCPID1              | 36974646-3489-47aa-b6c2-w232d543 | <currency> | SGP     | false    | <is_Account_negative> | CUSTOMER     | {"key": "TransactionIntegration1"} |

    Then I wait until max time to verify the bank account BankAccId1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    When I add External Bank Account as beneficiary to bank account BankAccId1 of CustomerProfile BCPID1 for provider <bank_name> and expect status 200
      | identifier     | beneficiary_name | address                                                                                                                                                                    | beneficiary_email     | is_hidden | metadata              | is_overdraft_allowed   | beneficiary_account_details                                                                                                                         | overdraft_funding_account_id   |
      | BeneficiaryId1 | Beneficiary1     | {"address_line_1":"line1","address_line_2":"line2","address_line_3":"line3","address_line_4":"line4","city":"Tokyo","state":"Tokyo","country_code":"JP","local_code":"JP"} | beneficiary1@test.com | false     | {"key": "MyMetaData"} | <is_overdraft_allowed> | {"bank_name":"SBI","currency":"SGD", "account_number": "1123344455","country":"SGP","code_details":{"sg_code_details":{"swift_bic":"DBSSSGSGXXX"}}} | <overdraft_funding_account_id> |

    Then I wait until max time to verify beneficiary BeneficiaryId1 create status as BENEFICIARY_CREATED with provider <bank_name> for customerProfileId BCPID1

    Given I deposit an amount of <deposit_amount> into BankAccId1 using cash DevDeposit and expect the header status 200
      | identifier           | customer_profile_id | purpose  | currency | transaction_rail |
      | DevDepositIdentifier | BCPID1              | TRANSFER | SGD      | FAST             |

    Then I wait until max time to verify bank account BankAccId1 with an increased balance of <deposit_amount> for customerProfileId BCPID1

    Then I initiate transaction to transfer funds with below details and expect the header statuscode <status_code> and transaction status as TRANSACTION_AMOUNT_BLOCKED
      | identifier | customer_profile_id | account_id | beneficiary_id | amount                        | purpose          | is_overdraft_allowed   | metadata              | currency | sub_txn_type |
      | TxId1      | BCPID1              | BankAccId1 | BeneficiaryId1 | <initiate_transaction_amount> | Integration Test | <is_overdraft_allowed> | {"key": "MyMetaData"} | SGD      | CARD_TXN     |

    Then I verify for bank account BankAccId1 total balance is <initial_total_balance> and available balance is <initial_available_balance> for customerProfileId BCPID1

    Then I cancel transaction with transaction_id TxId1 with the negative_transfer_allowed as <is_overdraft_allowed> and expect the header statuscode <status_code> and transaction status as <txn_status>
      | transaction_id | metadata              | purpose | customer_profile_id |
      | TxId1          | {"key": "MyMetaData"} | cancel  | BCPID1              |

    Then I verify for bank account BankAccId1 total balance is <updated_total_balance> and available balance is <updated_available_balance> for customerProfileId BCPID1

    Examples:
      | deposit_amount | initiate_transaction_amount | currency | bank_name    | account_type | is_Account_negative | is_overdraft_allowed | status_code | txn_status           | overdraft_funding_account_id | initial_total_balance | initial_available_balance | updated_total_balance | updated_available_balance | country | balance_policy_limit | balance_policy_type |
      | 150            | 100                         | SGD      | DBS Bank Ltd | e-money      | true                | true                 | 200         | TRANSACTION_REVERTED | CustomerProfileBA1           | 150                   | 50                        | 150                   | 150                       | SGP     | 0                    | LENIENT             |

  Scenario Outline: User trying to cancel a transaction which is already cancelled should be successful
    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier    | product_type   | profile_type | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type    |
      | ProductID1    | WALLET         | CUSTOMER     |  SHARIAH      | <currency> | <country> | SAVINGS      | 0                       | STRICT                 |

    Then I approve the product ProductID1 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Given I create account for CustomerProfile with id BCPID1 with product id as ProductID1 with bank account type as Payments Account with provider DBS Bank Ltd and expect the header status 200
      | identifier         | customer_profile_id | currency | country | in_trust | is_overdraft_allowed | on_behalf_of | metadata              | kyc_completed | trust_verification_completed |
      | CustomerProfileBA1 | IntegrationTest1    | SGD      | SGP     | false    | false                | CUSTOMER     | {"key": "MyMetaData"} | false         | false                        |

    Then I wait until max time to verify the bank account CustomerProfileBA1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier    | product_type   | profile_type     | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type    |
      | ProductID2    | WALLET         | END_CUSTOMER     |  SHARIAH      | <currency> | <country> | SAVINGS      | <balance_policy_limit>  | <balance_policy_type>  |

    Then I approve the product ProductID2 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Given I create account for EndCustomerProfile with id ECPID1 for CustomerProfile BCPID1 with product id ProductID2 with bank account type as <account_type> with provider <bank_name> and expect the header status 200
      | identifier | customer_profile_id | end_customer_profile_id          | currency   | country | in_trust | is_overdraft_allowed  | on_behalf_of | metadata                           |
      | BankAccId1 | BCPID1              | 36974646-3489-47aa-b6c2-w232d543 | <currency> | SGP     | false    | <is_Account_negative> | CUSTOMER     | {"key": "TransactionIntegration1"} |

    Then I wait until max time to verify the bank account BankAccId1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    When I add External Bank Account as beneficiary to bank account BankAccId1 of CustomerProfile BCPID1 for provider <bank_name> and expect status 200
      | identifier     | beneficiary_name | address                                                                                                                                                                    | beneficiary_email     | is_hidden | metadata              | is_overdraft_allowed   | beneficiary_account_details                                                                                                                         | overdraft_funding_account_id   |
      | BeneficiaryId1 | Beneficiary1     | {"address_line_1":"line1","address_line_2":"line2","address_line_3":"line3","address_line_4":"line4","city":"Tokyo","state":"Tokyo","country_code":"JP","local_code":"JP"} | beneficiary1@test.com | false     | {"key": "MyMetaData"} | <is_overdraft_allowed> | {"bank_name":"SBI","currency":"SGD", "account_number": "1123344455","country":"SGP","code_details":{"sg_code_details":{"swift_bic":"DBSSSGSGXXX"}}} | <overdraft_funding_account_id> |

    Then I wait until max time to verify beneficiary BeneficiaryId1 create status as BENEFICIARY_CREATED with provider <bank_name> for customerProfileId BCPID1

    Given I deposit an amount of <deposit_amount> into BankAccId1 using cash DevDeposit and expect the header status 200
      | identifier           | customer_profile_id | purpose  | currency | transaction_rail |
      | DevDepositIdentifier | BCPID1              | TRANSFER | SGD      | FAST             |

    Then I wait until max time to verify bank account BankAccId1 with an increased balance of <deposit_amount> for customerProfileId BCPID1

    Then I initiate transaction to transfer funds with below details and expect the header statuscode <status_code> and transaction status as TRANSACTION_AMOUNT_BLOCKED
      | identifier | customer_profile_id | account_id | beneficiary_id | amount                        | purpose          | is_overdraft_allowed   | metadata              | currency | sub_txn_type |
      | TxId1      | BCPID1              | BankAccId1 | BeneficiaryId1 | <initiate_transaction_amount> | Integration Test | <is_overdraft_allowed> | {"key": "MyMetaData"} | SGD      | CARD_TXN     |

    Then I verify for bank account BankAccId1 total balance is <initial_total_balance> and available balance is <initial_available_balance> for customerProfileId BCPID1

    Then I cancel transaction with transaction_id TxId1 with the negative_transfer_allowed as <is_overdraft_allowed> and expect the header statuscode <status_code> and transaction status as <txn_status>
      | transaction_id | metadata              | purpose | customer_profile_id |
      | TxId1          | {"key": "MyMetaData"} | cancel  | BCPID1              |
    Then I cancel transaction with transaction_id TxId1 with the negative_transfer_allowed as <is_overdraft_allowed> and expect the header statuscode <status_code> and transaction status as <txn_status>
      | transaction_id | metadata              | purpose | customer_profile_id |
      | TxId1          | {"key": "MyMetaData"} | cancel  | BCPID1              |

    Then I verify for bank account BankAccId1 total balance is <updated_total_balance> and available balance is <updated_available_balance> for customerProfileId BCPID1

    Examples:
      | deposit_amount | initiate_transaction_amount | currency | bank_name    | account_type | is_Account_negative | is_overdraft_allowed | status_code | txn_status           | overdraft_funding_account_id | initial_total_balance | initial_available_balance | updated_total_balance | updated_available_balance | country | balance_policy_limit | balance_policy_type |
      | 150            | 100                         | SGD      | DBS Bank Ltd | e-money      | true                | true                 | 200         | TRANSACTION_REVERTED | CustomerProfileBA1           | 150                   | 50                        | 150                   | 150                       | SGP     | 0                    | LENIENT             |

  Scenario Outline: User trying to cancel a transaction which has been initiated and is not in TRANSACTION_AMOUNT_BLOCKED state
    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier    | product_type   | profile_type | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type    |
      | ProductID1    | WALLET         | CUSTOMER     |  SHARIAH      | <currency> | <country> | SAVINGS      | 0                       | STRICT                 |

    Then I approve the product ProductID1 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Given I create account for CustomerProfile with id BCPID1 with product id as ProductID1 with bank account type as Payments Account with provider DBS Bank Ltd and expect the header status 200
      | identifier         | customer_profile_id | currency | country | in_trust | is_overdraft_allowed | on_behalf_of | metadata              | kyc_completed | trust_verification_completed |
      | CustomerProfileBA1 | IntegrationTest1    | SGD      | SGP     | false    | false                | CUSTOMER     | {"key": "MyMetaData"} | false         | false                        |

    Then I wait until max time to verify the bank account CustomerProfileBA1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier | product_type | profile_type | product_class | currency   | country   | account_type | balance_policy_limit   | balance_policy_type   |
      | ProductID2 | WALLET       | END_CUSTOMER | SHARIAH       | <currency> | <country> | SAVINGS      | <balance_policy_limit> | <balance_policy_type> |

    Then I approve the product ProductID2 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Given I create account for EndCustomerProfile with id ECPID1 for CustomerProfile BCPID1 with product id ProductID2 with bank account type as <account_type> with provider <bank_name> and expect the header status 200
      | identifier | customer_profile_id | end_customer_profile_id          | currency   | country | in_trust   | on_behalf_of | metadata                           |
      | BankAccId1 | BCPID1              | 36974646-3489-47aa-b6c2-w232d543 | <currency> | SGP     | false      | CUSTOMER     | {"key": "TransactionIntegration1"} |

    Then I wait until max time to verify the bank account BankAccId1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    When I add External Bank Account as beneficiary to bank account BankAccId1 of CustomerProfile BCPID1 for provider <bank_name> and expect status 200
      | identifier     | beneficiary_name | address                                                                                                                                                                    | beneficiary_email     | is_hidden | metadata              | is_overdraft_allowed   | beneficiary_account_details                                                                                                                         | overdraft_funding_account_id   |
      | BeneficiaryId1 | Beneficiary1     | {"address_line_1":"line1","address_line_2":"line2","address_line_3":"line3","address_line_4":"line4","city":"Tokyo","state":"Tokyo","country_code":"JP","local_code":"JP"} | beneficiary1@test.com | false     | {"key": "MyMetaData"} | <is_overdraft_allowed> | {"bank_name":"SBI","currency":"SGD", "account_number": "1123344455","country":"SGP","code_details":{"sg_code_details":{"swift_bic":"DBSSSGSGXXX"}}} | <overdraft_funding_account_id> |

    Then I wait until max time to verify beneficiary BeneficiaryId1 create status as BENEFICIARY_CREATED with provider <bank_name> for customerProfileId BCPID1

    Given I deposit an amount of <deposit_amount> into BankAccId1 using cash DevDeposit and expect the header status 200
      | identifier           | customer_profile_id | purpose  | currency | transaction_rail |
      | DevDepositIdentifier | BCPID1              | TRANSFER | SGD      | FAST             |

    Then I wait until max time to verify bank account BankAccId1 with an increased balance of <deposit_amount> for customerProfileId BCPID1

    Then I initiate transaction to transfer funds with below details and expect the header statuscode 200 and transaction status as TRANSACTION_AMOUNT_BLOCKED
      | identifier | customer_profile_id | account_id | beneficiary_id | amount                        | purpose          | is_overdraft_allowed   | metadata              | currency | sub_txn_type |
      | TxId1      | BCPID1              | BankAccId1 | BeneficiaryId1 | <initiate_transaction_amount> | Integration Test | <is_overdraft_allowed> | {"key": "MyMetaData"} | SGD      | CARD_TXN     |

    Then I verify for bank account BankAccId1 total balance is <initial_total_balance> and available balance is <initial_available_balance> for customerProfileId BCPID1

    Then I settle transaction to transfer funds with below details and expect the header statuscode 200 and transaction_status as <txn_status>
      | transaction_id | customer_profile_id | amount             | transaction_rail   | is_overdraft_allowed | metadata              | overdraft_funding_account_id |
      | TxId1          | BCPID1              | <requested_amount> | <transaction_rail> | true                 | {"key": "MyMetaData"} | CustomerProfileBA1           |

    Then I wait until max time to verify the transaction TxId1 status as TRANSACTION_SETTLED for customerProfileId BCPID1

    Then I cancel transaction with transaction_id TxId1 with the negative_transfer_allowed as <is_overdraft_allowed> and expect the header statuscode <status_code> and transaction status as <txn_status>
      | transaction_id | metadata              | customer_profile_id | purpose |
      | TxId1          | {"key": "MyMetaData"} | BCPID1              | invalid |

    Examples:
      | deposit_amount | initiate_transaction_amount | requested_amount | currency | bank_name    | account_type  | balance_policy_limit | balance_policy_type  | is_overdraft_allowed | status_code | overdraft_funding_account_id | initial_total_balance | initial_available_balance | transaction_rail | country |
      | 150            | 100                         | 100              | SGD      | DBS Bank Ltd | e-money       | 0                    | LENIENT              | true                 | CSSM_9804   | CustomerProfileBA1           | 150                   | 50                        | FAST             | SGP     |

      ## Close transaction scenarios###
  Scenario Outline: User trying to close a transaction case where  has been initiated and is in TRANSACTION_AMOUNT_BLOCKED state

    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier    | product_type   | profile_type | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type    |
      | ProductID1    | WALLET         | CUSTOMER     |  SHARIAH      | <currency> | <country> | SAVINGS      | 0                       | STRICT                 |

    Then I approve the product ProductID1 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Given I create account for CustomerProfile with id BCPID1 with product id as ProductID1 with bank account type as Payments Account with provider DBS Bank Ltd and expect the header status 200
      | identifier         | customer_profile_id | currency | country | in_trust  | on_behalf_of | metadata              | kyc_completed | trust_verification_completed |
      | CustomerProfileBA1 | IntegrationTest1    | SGD      | SGP     | false     | CUSTOMER     | {"key": "MyMetaData"} | false         | false                        |

    Then I wait until max time to verify the bank account CustomerProfileBA1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier | product_type | profile_type | product_class | currency   | country   | account_type | balance_policy_limit   | balance_policy_type    |
      | ProductID2 | WALLET       | END_CUSTOMER | SHARIAH       | <currency> | <country> | SAVINGS      | <balance_policy_limit> | <balance_policy_type>  |

    Then I approve the product ProductID2 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Given I create account for EndCustomerProfile with id ECPID1 for CustomerProfile BCPID1 with product id ProductID2 with bank account type as <account_type> with provider <bank_name> and expect the header status 200
      | identifier | customer_profile_id | end_customer_profile_id          | currency   | country | in_trust   | on_behalf_of | metadata                           |
      | BankAccId1 | BCPID1              | 36974646-3489-47aa-b6c2-w232d543 | <currency> | SGP     | false      | CUSTOMER     | {"key": "TransactionIntegration1"} |

    Then I wait until max time to verify the bank account BankAccId1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    When I add External Bank Account as beneficiary to bank account BankAccId1 of CustomerProfile BCPID1 for provider <bank_name> and expect status 200
      | identifier     | beneficiary_name | address                                                                                                                                                                    | beneficiary_email     | is_hidden | metadata              | is_overdraft_allowed   | beneficiary_account_details                                                                                                                         | overdraft_funding_account_id   |
      | BeneficiaryId1 | Beneficiary1     | {"address_line_1":"line1","address_line_2":"line2","address_line_3":"line3","address_line_4":"line4","city":"Tokyo","state":"Tokyo","country_code":"JP","local_code":"JP"} | beneficiary1@test.com | false     | {"key": "MyMetaData"} | <is_overdraft_allowed> | {"bank_name":"SBI","currency":"SGD", "account_number": "1123344455","country":"SGP","code_details":{"sg_code_details":{"swift_bic":"DBSSSGSGXXX"}}} | <overdraft_funding_account_id> |

    Then I wait until max time to verify beneficiary BeneficiaryId1 create status as BENEFICIARY_CREATED with provider <bank_name> for customerProfileId BCPID1

    Given I deposit an amount of <deposit_amount> into BankAccId1 using cash DevDeposit and expect the header status 200
      | identifier           | customer_profile_id | purpose  | currency | transaction_rail |
      | DevDepositIdentifier | BCPID1              | TRANSFER | SGD      | FAST             |

    Then I wait until max time to verify bank account BankAccId1 with an increased balance of <deposit_amount> for customerProfileId BCPID1

    Then I initiate transaction to transfer funds with below details and expect the header statuscode <status_code> and transaction status as TRANSACTION_AMOUNT_BLOCKED
      | identifier | customer_profile_id | account_id | beneficiary_id | amount                        | purpose          | is_overdraft_allowed   | metadata              | currency | sub_txn_type |
      | TxId1      | BCPID1              | BankAccId1 | BeneficiaryId1 | <initiate_transaction_amount> | Integration Test | <is_overdraft_allowed> | {"key": "MyMetaData"} | SGD      | CARD_TXN     |

    Then I verify for bank account BankAccId1 total balance is <initial_total_balance> and available balance is <initial_available_balance> for customerProfileId BCPID1

    Then I close transaction with transaction_id TxId1 with the negative_transfer_allowed as <is_overdraft_allowed> and expect the header statuscode <status_code> and transaction status as <txn_status>
      | transaction_id | metadata              | purpose | customer_profile_id |
      | TxId1          | {"key": "MyMetaData"} | close   | BCPID1              |

    Then I verify for bank account BankAccId1 total balance is <updated_total_balance> and available balance is <updated_available_balance> for customerProfileId BCPID1

    Examples:
      | deposit_amount | initiate_transaction_amount | currency | bank_name    | account_type | balance_policy_limit | balance_policy_type | is_overdraft_allowed | status_code | txn_status           | overdraft_funding_account_id | initial_total_balance | initial_available_balance | updated_total_balance | updated_available_balance | country |
      | 150            | 100                         | SGD      | DBS Bank Ltd | e-money      | 0                    | LENIENT             | true                 | 200         | TRANSACTION_REVERTED | CustomerProfileBA1           | 150                   | 50                        | 150                   | 150                       | SGP     |

  Scenario Outline: User trying to close a transaction already closed transaction should be successful.
    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier    | product_type   | profile_type | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type    |
      | ProductID1    | WALLET         | CUSTOMER     |  SHARIAH      | <currency> | <country> | SAVINGS      | 0                       | STRICT                 |

    Then I approve the product ProductID1 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Given I create account for CustomerProfile with id BCPID1 with product id as ProductID1 with bank account type as Payments Account with provider DBS Bank Ltd and expect the header status 200
      | identifier         | customer_profile_id | currency | country | in_trust  | on_behalf_of | metadata              | kyc_completed | trust_verification_completed |
      | CustomerProfileBA1 | IntegrationTest1    | SGD      | SGP     | false     | CUSTOMER     | {"key": "MyMetaData"} | false         | false                        |

    Then I wait until max time to verify the bank account CustomerProfileBA1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier | product_type | profile_type | product_class | currency   | country   | account_type | balance_policy_limit   | balance_policy_type   |
      | ProductID2 | WALLET       | END_CUSTOMER | SHARIAH       | <currency> | <country> | SAVINGS      | <balance_policy_limit> | <balance_policy_type> |

    Then I approve the product ProductID2 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Given I create account for EndCustomerProfile with id ECPID1 for CustomerProfile BCPID1 with product id ProductID2 with bank account type as <account_type> with provider <bank_name> and expect the header status 200
      | identifier | customer_profile_id | end_customer_profile_id          | currency   | country | in_trust   | on_behalf_of | metadata                           |
      | BankAccId1 | BCPID1              | 36974646-3489-47aa-b6c2-w232d543 | <currency> | SGP     | false      | CUSTOMER     | {"key": "TransactionIntegration1"} |

    Then I wait until max time to verify the bank account BankAccId1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    When I add External Bank Account as beneficiary to bank account BankAccId1 of CustomerProfile BCPID1 for provider <bank_name> and expect status 200
      | identifier     | beneficiary_name | address                                                                                                                                                                    | beneficiary_email     | is_hidden | metadata              | is_overdraft_allowed   | beneficiary_account_details                                                                                                                         | overdraft_funding_account_id   |
      | BeneficiaryId1 | Beneficiary1     | {"address_line_1":"line1","address_line_2":"line2","address_line_3":"line3","address_line_4":"line4","city":"Tokyo","state":"Tokyo","country_code":"JP","local_code":"JP"} | beneficiary1@test.com | false     | {"key": "MyMetaData"} | <is_overdraft_allowed> | {"bank_name":"SBI","currency":"SGD", "account_number": "1123344455","country":"SGP","code_details":{"sg_code_details":{"swift_bic":"DBSSSGSGXXX"}}} | <overdraft_funding_account_id> |

    Then I wait until max time to verify beneficiary BeneficiaryId1 create status as BENEFICIARY_CREATED with provider <bank_name> for customerProfileId BCPID1

    Given I deposit an amount of <deposit_amount> into BankAccId1 using cash DevDeposit and expect the header status 200
      | identifier           | customer_profile_id | purpose  | currency | transaction_rail |
      | DevDepositIdentifier | BCPID1              | TRANSFER | SGD      | FAST             |

    Then I wait until max time to verify bank account BankAccId1 with an increased balance of <deposit_amount> for customerProfileId BCPID1

    Then I initiate transaction to transfer funds with below details and expect the header statuscode <status_code> and transaction status as TRANSACTION_AMOUNT_BLOCKED
      | identifier | customer_profile_id | account_id | beneficiary_id | amount                        | purpose          | is_overdraft_allowed   | metadata              | currency | sub_txn_type |
      | TxId1      | BCPID1              | BankAccId1 | BeneficiaryId1 | <initiate_transaction_amount> | Integration Test | <is_overdraft_allowed> | {"key": "MyMetaData"} | SGD      | CARD_TXN     |

    Then I verify for bank account BankAccId1 total balance is <initial_total_balance> and available balance is <initial_available_balance> for customerProfileId BCPID1

    Then I close transaction with transaction_id TxId1 with the negative_transfer_allowed as <is_overdraft_allowed> and expect the header statuscode <status_code> and transaction status as <txn_status>
      | transaction_id | metadata              | purpose | customer_profile_id |
      | TxId1          | {"key": "MyMetaData"} | close   | BCPID1              |
    Then I close transaction with transaction_id TxId1 with the negative_transfer_allowed as <is_overdraft_allowed> and expect the header statuscode <status_code> and transaction status as <txn_status>
      | transaction_id | metadata              | purpose | customer_profile_id |
      | TxId1          | {"key": "MyMetaData"} | close   | BCPID1              |

    Then I verify for bank account BankAccId1 total balance is <updated_total_balance> and available balance is <updated_available_balance> for customerProfileId BCPID1

    Examples:
      | deposit_amount | initiate_transaction_amount | currency | bank_name    | account_type  | balance_policy_limit | balance_policy_type | is_overdraft_allowed | status_code | txn_status           | overdraft_funding_account_id | initial_total_balance | initial_available_balance | updated_total_balance | updated_available_balance | country |
      | 150            | 100                         | SGD      | DBS Bank Ltd | e-money       | 0                    | LENIENT             | true                 | 200         | TRANSACTION_REVERTED | CustomerProfileBA1           | 150                   | 50                        | 150                   | 150                       | SGP     |

  Scenario Outline: User trying to close a transaction which has been initiated and is not in TRANSACTION_AMOUNT_BLOCKED state

    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier    | product_type   | profile_type | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type    |
      | ProductID1    | WALLET         | CUSTOMER     |  SHARIAH      | <currency> | <country> | SAVINGS      | 0                       | STRICT                 |

    Then I approve the product ProductID1 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Given I create account for CustomerProfile with id BCPID1 with product id as ProductID1 with bank account type as Payments Account with provider DBS Bank Ltd and expect the header status 200
      | identifier         | customer_profile_id | currency | country | in_trust  | on_behalf_of | metadata              | kyc_completed | trust_verification_completed |
      | CustomerProfileBA1 | IntegrationTest1    | SGD      | SGP     | false     | CUSTOMER     | {"key": "MyMetaData"} | false         | false                        |

    Then I wait until max time to verify the bank account CustomerProfileBA1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier | product_type | profile_type | product_class | currency   | country   | account_type | balance_policy_limit   | balance_policy_type    |
      | ProductID2 | WALLET       | END_CUSTOMER | SHARIAH       | <currency> | <country> | SAVINGS      | <balance_policy_limit> | <balance_policy_type> |

    Then I approve the product ProductID2 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Given I create account for EndCustomerProfile with id ECPID1 for CustomerProfile BCPID1 with product id ProductID2 with bank account type as <account_type> with provider <bank_name> and expect the header status 200
      | identifier | customer_profile_id | end_customer_profile_id          | currency   | country | in_trust   | on_behalf_of | metadata                           |
      | BankAccId1 | BCPID1              | 36974646-3489-47aa-b6c2-w232d543 | <currency> | SGP     | false      | CUSTOMER     | {"key": "TransactionIntegration1"} |

    Then I wait until max time to verify the bank account BankAccId1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    When I add External Bank Account as beneficiary to bank account BankAccId1 of CustomerProfile BCPID1 for provider <bank_name> and expect status 200
      | identifier     | beneficiary_name | address                                                                                                                                                                    | beneficiary_email     | is_hidden | metadata              | is_overdraft_allowed   | beneficiary_account_details                                                                                                                         | overdraft_funding_account_id   |
      | BeneficiaryId1 | Beneficiary1     | {"address_line_1":"line1","address_line_2":"line2","address_line_3":"line3","address_line_4":"line4","city":"Tokyo","state":"Tokyo","country_code":"JP","local_code":"JP"} | beneficiary1@test.com | false     | {"key": "MyMetaData"} | <is_overdraft_allowed> | {"bank_name":"SBI","currency":"SGD", "account_number": "1123344455","country":"SGP","code_details":{"sg_code_details":{"swift_bic":"DBSSSGSGXXX"}}} | <overdraft_funding_account_id> |

    Then I wait until max time to verify beneficiary BeneficiaryId1 create status as BENEFICIARY_CREATED with provider <bank_name> for customerProfileId BCPID1

    Given I deposit an amount of <deposit_amount> into BankAccId1 using cash DevDeposit and expect the header status 200
      | identifier           | customer_profile_id | purpose  | currency | transaction_rail |
      | DevDepositIdentifier | BCPID1              | TRANSFER | SGD      | FAST             |

    Then I wait until max time to verify bank account BankAccId1 with an increased balance of <deposit_amount> for customerProfileId BCPID1

    Then I initiate transaction to transfer funds with below details and expect the header statuscode 200 and transaction status as TRANSACTION_AMOUNT_BLOCKED
      | identifier | customer_profile_id | account_id | beneficiary_id | amount                        | purpose          | is_overdraft_allowed   | metadata              | currency | sub_txn_type |
      | TxId1      | BCPID1              | BankAccId1 | BeneficiaryId1 | <initiate_transaction_amount> | Integration Test | <is_overdraft_allowed> | {"key": "MyMetaData"} | SGD      | CARD_TXN     |

    Then I verify for bank account BankAccId1 total balance is <initial_total_balance> and available balance is <initial_available_balance> for customerProfileId BCPID1

    Then I settle transaction to transfer funds with below details and expect the header statuscode 200 and transaction_status as <txn_status>
      | transaction_id | customer_profile_id | amount             | transaction_rail   | is_overdraft_allowed | metadata              | overdraft_funding_account_id |
      | TxId1          | BCPID1              | <requested_amount> | <transaction_rail> | true                 | {"key": "MyMetaData"} | CustomerProfileBA1           |

    Then I wait until max time to verify the transaction TxId1 status as TRANSACTION_SETTLED for customerProfileId BCPID1

    Then I close transaction with transaction_id TxId1 with the negative_transfer_allowed as <is_overdraft_allowed> and expect the header statuscode <status_code> and transaction status as <txn_status>
      | transaction_id | metadata              | customer_profile_id | purpose |
      | TxId1          | {"key": "MyMetaData"} | BCPID1              | invalid |

    Examples:
      | deposit_amount | initiate_transaction_amount | requested_amount | currency | bank_name    | account_type | balance_policy_limit | balance_policy_type | is_overdraft_allowed | status_code | overdraft_funding_account_id | initial_total_balance | initial_available_balance | transaction_rail | country |
      | 150            | 100                         | 100              | SGD      | DBS Bank Ltd | e-money      | 0                    | LENIENT             | true                 | CSSM_9804   | CustomerProfileBA1           | 150                   | 50                        | FAST             | SGP     |

      ############## Idempotency Tests. #################
  Scenario Outline: Idempotency Tests for Initiate Transactions.

    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier    | product_type   | profile_type | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type    |
      | ProductID1    | WALLET         | CUSTOMER     |  SHARIAH      | <currency> | <country> | SAVINGS      | 0                       | STRICT                 |

    Then I approve the product ProductID1 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Given I create account for CustomerProfile with id BCPID1 with product id as ProductID1 with bank account type as Payments Account with provider DBS Bank Ltd and expect the header status 200
      | identifier         | customer_profile_id | currency | country | in_trust | is_overdraft_allowed | on_behalf_of | metadata              | kyc_completed | trust_verification_completed |
      | CustomerProfileBA1 | IntegrationTest1    | SGD      | SGP     | false    | false                | CUSTOMER     | {"key": "MyMetaData"} | false         | false                        |

    Then I wait until max time to verify the bank account CustomerProfileBA1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier    | product_type   | profile_type     | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type    |
      | ProductID2    | WALLET         | END_CUSTOMER     |  SHARIAH      | <currency> | <country> | SAVINGS      | <balance_policy_limit>  | <balance_policy_type>  |

    Then I approve the product ProductID2 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Given I create account for EndCustomerProfile with id ECPID1 for CustomerProfile BCPID1 with product id ProductID2 with bank account type as <account_type> with provider <bank_name> and expect the header status 200
      | identifier | customer_profile_id | end_customer_profile_id          | currency   | country | in_trust | is_overdraft_allowed   | on_behalf_of | metadata                           |
      | BankAccId1 | BCPID1              | 36974646-3489-47aa-b6c2-w232d543 | <currency> | SGP     | false    | <is_overdraft_allowed> | CUSTOMER     | {"key": "TransactionIntegration1"} |

    Then I wait until max time to verify the bank account BankAccId1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    When I add External Bank Account as beneficiary to bank account BankAccId1 of CustomerProfile BCPID1 for provider <bank_name> and expect status 200
      | identifier     | beneficiary_name | address                                                                                                                                                                    | beneficiary_email     | is_hidden | metadata              | is_overdraft_allowed   | beneficiary_account_details                                                                                                                         | overdraft_funding_account_id   |
      | BeneficiaryId1 | Beneficiary1     | {"address_line_1":"line1","address_line_2":"line2","address_line_3":"line3","address_line_4":"line4","city":"Tokyo","state":"Tokyo","country_code":"JP","local_code":"JP"} | beneficiary1@test.com | false     | {"key": "MyMetaData"} | <is_overdraft_allowed> | {"bank_name":"SBI","currency":"SGD", "account_number": "1123344455","country":"SGP","code_details":{"sg_code_details":{"swift_bic":"DBSSSGSGXXX"}}} | <overdraft_funding_account_id> |

    Then I wait until max time to verify beneficiary BeneficiaryId1 create status as BENEFICIARY_CREATED with provider <bank_name> for customerProfileId BCPID1

    Given I deposit an amount of <deposit_amount> into BankAccId1 using cash DevDeposit and expect the header status 200
      | identifier           | customer_profile_id | purpose  | currency | transaction_rail |
      | DevDepositIdentifier | BCPID1              | TRANSFER | SGD      | FAST             |

    Then I wait until max time to verify bank account BankAccId1 with an increased balance of <deposit_amount> for customerProfileId BCPID1

    Then I initiate transaction to transfer funds with below details and expect the header statuscode <status_code> and transaction status as <txn_status>
      | identifier | customer_profile_id | account_id | beneficiary_id | amount   | purpose          | is_overdraft_allowed   | metadata              | currency | sub_txn_type | idempotency_key |
      | TxId1      | BCPID1              | BankAccId1 | BeneficiaryId1 | <amount> | Integration Test | <is_overdraft_allowed> | {"key": "MyMetaData"} | SGD      | CARD_TXN     | IDMPTKey5       |

    Then I verify for bank account BankAccId1 total balance is <total_balance> and available balance is <available_balance> for customerProfileId BCPID1

    Then I initiate transaction to transfer funds with below details and expect the header statuscode <status_code> and transaction status as <txn_status>
      | identifier | customer_profile_id | account_id | beneficiary_id | amount   | purpose          | is_overdraft_allowed   | metadata              | currency | sub_txn_type | idempotency_key |
      | TxId2      | BCPID1              | BankAccId1 | BeneficiaryId1 | <amount> | Integration Test | <is_overdraft_allowed> | {"key": "MyMetaData"} | SGD      | CARD_TXN     | IDMPTKey5       |

    Then I verify for bank account BankAccId1 total balance is <total_balance> and available balance is <available_balance_final> for customerProfileId BCPID1

    Then I check if we are getting same transaction_id for two requests for TxId1 TxId1 and TxId2 TxId2

    Examples:
      | deposit_amount | amount | currency | bank_name    | account_type | is_overdraft_allowed | status_code | txn_status                 | overdraft_funding_account_id | total_balance | available_balance | available_balance_final | country | balance_policy_limit | balance_policy_type |
      | 1000           | 100    | SGD      | DBS Bank Ltd | e-money      | false                | 200         | TRANSACTION_AMOUNT_BLOCKED | CustomerProfileBA1           | 1000          | 900               | 900                     | SGP     | 0                    | STRICT              |

  Scenario Outline: Idempotency Key check for Settle Transactions.

    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier    | product_type   | profile_type | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type    |
      | ProductID1    | WALLET         | CUSTOMER     |  SHARIAH      | <currency> | <country> | SAVINGS      | 0                       | STRICT                 |

    Then I approve the product ProductID1 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Given I create account for CustomerProfile with id BCPID1 with product id as ProductID1 with bank account type as Payments Account with provider DBS Bank Ltd and expect the header status 200
      | identifier         | customer_profile_id | currency | country | in_trust | is_overdraft_allowed | on_behalf_of | metadata              | kyc_completed | trust_verification_completed |
      | CustomerProfileBA1 | IntegrationTest1    | SGD      | SGP     | false    | false                | CUSTOMER     | {"key": "MyMetaData"} | false         | false                        |

    Then I wait until max time to verify the bank account CustomerProfileBA1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier    | product_type   | profile_type     | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type    |
      | ProductID2    | WALLET         | END_CUSTOMER     |  SHARIAH      | <currency> | <country> | SAVINGS      | <balance_policy_limit>  | <balance_policy_type>  |

    Then I approve the product ProductID2 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Given I create account for EndCustomerProfile with id ECPID1 for CustomerProfile BCPID1 with product id ProductID2 with bank account type as <account_type> with provider <bank_name> and expect the header status 200
      | identifier | customer_profile_id | end_customer_profile_id          | currency   | country | in_trust | is_overdraft_allowed   | on_behalf_of | metadata                           |
      | BankAccId1 | BCPID1              | 36974646-3489-47aa-b6c2-w232d543 | <currency> | SGP     | false    | <is_overdraft_allowed> | CUSTOMER     | {"key": "TransactionIntegration1"} |

    Then I wait until max time to verify the bank account BankAccId1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    When I add External Bank Account as beneficiary to bank account BankAccId1 of CustomerProfile BCPID1 for provider <bank_name> and expect status 200
      | identifier     | beneficiary_name | address                                                                                                                                                                    | beneficiary_email     | is_hidden | metadata              | is_overdraft_allowed   | beneficiary_account_details                                                                                                                         | overdraft_funding_account_id   |
      | BeneficiaryId1 | Beneficiary1     | {"address_line_1":"line1","address_line_2":"line2","address_line_3":"line3","address_line_4":"line4","city":"Tokyo","state":"Tokyo","country_code":"JP","local_code":"JP"} | beneficiary1@test.com | false     | {"key": "MyMetaData"} | <is_overdraft_allowed> | {"bank_name":"SBI","currency":"SGD", "account_number": "1123344455","country":"SGP","code_details":{"sg_code_details":{"swift_bic":"DBSSSGSGXXX"}}} | <overdraft_funding_account_id> |

    Then I wait until max time to verify beneficiary BeneficiaryId1 create status as BENEFICIARY_CREATED with provider <bank_name> for customerProfileId BCPID1

    Given I deposit an amount of <deposit_amount> into BankAccId1 using cash DevDeposit and expect the header status 200
      | identifier           | customer_profile_id | purpose  | currency | transaction_rail |
      | DevDepositIdentifier | BCPID1              | TRANSFER | SGD      | FAST             |

    Then I wait until max time to verify bank account BankAccId1 with an increased balance of <deposit_amount> for customerProfileId BCPID1

    Then I initiate transaction to transfer funds with below details and expect the header statuscode <status_code> and transaction status as TRANSACTION_AMOUNT_BLOCKED
      | identifier | customer_profile_id | account_id | beneficiary_id | amount                        | purpose          | is_overdraft_allowed   | metadata              | currency | sub_txn_type | idempotency_key |
      | TxId1      | BCPID1              | BankAccId1 | BeneficiaryId1 | <initiate_transaction_amount> | Integration Test | <is_overdraft_allowed> | {"key": "MyMetaData"} | SGD      | CARD_TXN     | IDMPTKey1       |

    Then I initiate transaction to transfer funds with below details and expect the header statuscode <status_code> and transaction status as TRANSACTION_AMOUNT_BLOCKED
      | identifier | customer_profile_id | account_id | beneficiary_id | amount                        | purpose          | is_overdraft_allowed   | metadata              | currency | sub_txn_type | idempotency_key |
      | TxId2      | BCPID1              | BankAccId1 | BeneficiaryId1 | <initiate_transaction_amount> | Integration Test | <is_overdraft_allowed> | {"key": "MyMetaData"} | SGD      | CARD_TXN     | IDMPTKey1       |

    Then  I settle transaction to transfer funds with below details and expect the header statuscode <status_code>
      | transaction_id | customer_profile_id | amount             | transaction_rail   | is_overdraft_allowed   | metadata              | idempotency_key |
      | TxId1          | BCPID1              | <requested_amount> | <transaction_rail> | <is_overdraft_allowed> | {"key": "MyMetaData"} | IDMPTKey2       |

    Then  I settle transaction to transfer funds with below details and expect the header statuscode <status_code>
      | transaction_id | customer_profile_id | amount             | transaction_rail   | is_overdraft_allowed   | metadata              | idempotency_key |
      | TxId2          | BCPID1              | <requested_amount> | <transaction_rail> | <is_overdraft_allowed> | {"key": "MyMetaData"} | IDMPTKey2       |

    Then I check if we are getting same transaction_id for two requests for TxId1 TxId1 and TxId2 TxId2

    Examples:
      | deposit_amount | initiate_transaction_amount | requested_amount | currency | bank_name    | account_type | is_overdraft_allowed | transaction_rail | status_code | overdraft_funding_account_id | country | balance_policy_limit | balance_policy_type |
      | 150            | 100                         | 100              | SGD      | DBS Bank Ltd | e-money      | true                 | FAST             | 200         | CustomerProfileBA1           | SGP     | 0                    | LENIENT             |
