Feature: Confirmation of Deposits by Cash Service

  Background: Setup customerProfile and EndCustomerProfile and add Accounts.

     #CustomerProfile verifying and Onboarding on to banking service on given providers
    Given I set and verify customer BCID1, customer profile BCPID1 on cash service on below providers and expect status 200 in the context
      | provider_name |
      | DBS Bank Ltd  |

    Then I wait until max time to verify CustomerProfile BCPID1 onboard status as ONBOARD_SUCCESS

    Then I create below End-Customer-Profile
      | customer_identifier | customer_profile_identifier | end_customer_profile_identifier | first_name | last_name | region | email   | phone_number |
      | BCID1               | BCPID1                      | ECPID1                          | banking    | service   | SG     | x@y.com | 00000000     |

    Then I verify End-Customer-Profile exist with values
      | customer_profile_identifier | end_customer_profile_identifier | customer_profile_id   | first_name | last_name | email   | phone_number | status |
      | BCPID1                      | ECPID1                          | <customer_profile_id> | banking    | service   | x@y.com | 00000000     | ACTIVE |

    Then I wait until max time to verify CustomerProfile BCPID1 onboard status as ONBOARD_SUCCESS

    # EndCustomerProfile Onboarding
    Given I onboard EndCustomerProfile ECPID1 of CustomerProfile BCPID1 on cash service on below providers and expect status 200
      | provider_name |
      | DBS Bank Ltd  |

    Then I wait until max time to verify EndCustomerProfile ECPID1 of CustomerProfile BCPID1 onboard status as ONBOARD_SUCCESS

    # Cash Wallet Product with Deposit Mode set to Notify instead of the default Accept
    Given I create a product with customer profile BCPID1 provider as DBS Bank Ltd and expect product_status PRODUCT_DRAFT
      | identifier | product_type | profile_type | product_class | currency | country | account_type | balance_policy_limit | balance_policy_type | deposit_mode |
      | ProductID1 | WALLET       | END_CUSTOMER | SHARIAH       | SGD      | SGP     | SAVINGS      | 0                    | STRICT              | NOTIFY       |

    Then I approve the product ProductID1 and verify status as PRODUCT_SUCCESS with provider DBS Bank Ltd for customerProfileId BCPID1

    Given I create account for EndCustomerProfile with id ECPID1 for CustomerProfile BCPID1 with product id ProductID1 with bank account type as PPA with provider DBS Bank Ltd and expect the header status 200
      | identifier    | customer_profile_id | end_customer_profile_id | currency | country | in_trust | is_overdraft_allowed | on_behalf_of | metadata                            |
      | CashWalletId1 | IntegrationTest1    | IntegrationEndCustomer  | SGD      | SGP     | false    | false                | CUSTOMER     | {"keyref":"M030126179534319754275"} |

    Then I wait until max time to verify the bank account CashWalletId1 status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId BCPID1

  Scenario: I deposit an amount of 100 into End Customer Wallet and later accept the deposit

    Given I deposit an amount of 100 into CashWalletId1 using cash DevDeposit and expect the header status 200
      | identifier           | customer_profile_id | purpose  | currency | transaction_rail | amount |
      | DevDepositIdentifier | BCPID1              | TRANSFER | SGD      | FAST             | 100    |

    Then I wait until max time to verify bank account CashWalletId1 with an available balance of 0 and total balance of 100 for customerProfileId BCPID1

    Then I get the deposit transaction TxId1 details for cash wallet CashWalletId1 for customerProfileId BCPID1

    Then I confirm the deposit transaction TxId1 for customerProfileId BCPID1 and expect the header status as 200 transaction status as TRANSACTION_SETTLED
      | accept |
      | true   |

    Then I verify for bank account CashWalletId1 total balance is 100 and available balance is 100 for customerProfileId BCPID1


  Scenario: I deposit an amount of 100 into End Customer Wallet and later reject the deposit

    Given I deposit an amount of 100 into CashWalletId1 using cash DevDeposit and expect the header status 200
      | identifier           | customer_profile_id | purpose  | currency | transaction_rail | amount |
      | DevDepositIdentifier | BCPID1              | TRANSFER | SGD      | FAST             | 100    |

    Then I wait until max time to verify bank account CashWalletId1 with an available balance of 0 and total balance of 100 for customerProfileId BCPID1

    Then I get the deposit transaction TxId1 details for cash wallet CashWalletId1 for customerProfileId BCPID1

    Then I confirm the deposit transaction TxId1 for customerProfileId BCPID1 and expect the header status as 200 transaction status as TRANSACTION_PENDING
      | accept |
      | false  |

    Then I wait until max time to verify the transaction TxId1 status as TRANSACTION_REJECTED for customerProfileId BCPID1

    Then I verify for bank account CashWalletId1 total balance is 0 and available balance is 0 for customerProfileId BCPID1


  Scenario: I transfer an amount of 100 from CashWalletId2 to CashWalletId1 with partial overdraft and accept the multi deposit on CashWalletId1

    Given I create a product with customer profile BCPID1 provider as DBS Bank Ltd and expect product_status PRODUCT_DRAFT
      | identifier | product_type | profile_type | product_class | currency | country | account_type | balance_policy_limit | balance_policy_type |
      | ProductID  | WALLET       | CUSTOMER     | SHARIAH       | SGD      | SGP     | SAVINGS      | 0                    | STRICT              |

    Then I approve the product ProductID and verify status as PRODUCT_SUCCESS with provider DBS Bank Ltd for customerProfileId BCPID1

    Given I create account for CustomerProfile with id BCPID1 with product id as ProductID with bank account type as Payments Account with provider DBS Bank Ltd and expect the header status 200
      | identifier         | customer_profile_id | currency | country | in_trust | is_overdraft_allowed | on_behalf_of | metadata              | kyc_completed | trust_verification_completed |
      | CustomerCashWallet | IntegrationTest1    | SGD      | SGP     | false    | false                | CUSTOMER     | {"key": "MyMetaData"} | false         | false                        |

    Then I wait until max time to verify the bank account CustomerCashWallet status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId BCPID1

    Given I deposit an amount of 1000 into CustomerCashWallet using cash DevDeposit and expect the header status 200
      | identifier           | customer_profile_id | purpose  | currency | transaction_rail |
      | DevDepositIdentifier | BCPID1              | TRANSFER | SGD      | FAST             |

    Then I wait until max time to verify bank account CustomerCashWallet with an increased balance of 1000 for customerProfileId BCPID1

    Given I create a product with customer profile BCPID1 provider as DBS Bank Ltd and expect product_status PRODUCT_DRAFT
      | identifier | product_type | profile_type | product_class | currency | country | account_type | balance_policy_limit | balance_policy_type |
      | ProductID1 | WALLET       | END_CUSTOMER | SHARIAH       | SGD      | SGP     | SAVINGS      | 0                    | LENIENT             |

    Then I approve the product ProductID1 and verify status as PRODUCT_SUCCESS with provider DBS Bank Ltd for customerProfileId BCPID1

    Given I create account for EndCustomerProfile with id ECPID1 for CustomerProfile BCPID1 with product id ProductID1 with bank account type as PPA with provider DBS Bank Ltd and expect the header status 200
      | identifier    | customer_profile_id | end_customer_profile_id | currency | country | in_trust | is_overdraft_allowed | on_behalf_of | metadata                            |
      | CashWalletId2 | IntegrationTest1    | IntegrationEndCustomer  | SGD      | SGP     | false    | false                | CUSTOMER     | {"keyref":"M030126179534319754275"} |

    Then I wait until max time to verify the bank account CashWalletId2 status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId BCPID1

    Given I deposit an amount of 50 into CashWalletId2 using cash DevDeposit and expect the header status 200
      | identifier           | customer_profile_id | purpose  | currency | transaction_rail | amount |
      | DevDepositIdentifier | BCPID1              | TRANSFER | SGD      | FAST             | 100    |

    Then I wait until max time to verify bank account CashWalletId2 with an available balance of 50 and total balance of 50 for customerProfileId BCPID1

    Then I initiate transaction to transfer funds with below details and expect the header statuscode 200 and transaction status as TRANSACTION_AMOUNT_BLOCKED
      | identifier | customer_profile_id | account_id    | amount | purpose          | is_overdraft_allowed | metadata              | currency | sub_txn_type | receiver_account_id |
      | TxId1      | BCPID1              | CashWalletId2 | 100    | Integration Test | true                 | {"key": "MyMetaData"} | SGD      | CARD_TXN     | CashWalletId1       |

    Then I verify for bank account CashWalletId2 total balance is 50 and available balance is -50 for customerProfileId BCPID1

    Then I settle transaction to transfer funds with below details and expect the header statuscode 200 and transaction_status as TRANSACTION_SETTLED
      | transaction_id | customer_profile_id | amount | transaction_rail | is_overdraft_allowed | metadata              | overdraft_funding_account_id |
      | TxId1          | BCPID1              | 100    | FAST             | true                 | {"key": "MyMetaData"} | CustomerCashWallet           |

    Then I wait until max time to verify the transaction TxId1 status as TRANSACTION_SETTLED for customerProfileId BCPID1

    Then I verify for bank account CashWalletId2 total balance is -50 and available balance is -50 for customerProfileId BCPID1

    Then I get the deposit transaction TxId2 details for cash wallet CashWalletId1 for customerProfileId BCPID1

    Then I wait until max time to verify bank account CashWalletId1 with an available balance of 0 and total balance of 100 for customerProfileId BCPID1

    Then I confirm the deposit transaction TxId2 for customerProfileId BCPID1 and expect the header status as 200 transaction status as TRANSACTION_SETTLED
      | accept |
      | true   |

    Then I verify for bank account CashWalletId1 total balance is 100 and available balance is 100 for customerProfileId BCPID1


  Scenario: I transfer an amount of 100 from CashWalletId2 to CashWalletId1 with partial overdraft and reject the multi deposit on CashWalletId1

    Given I create a product with customer profile BCPID1 provider as DBS Bank Ltd and expect product_status PRODUCT_DRAFT
      | identifier | product_type | profile_type | product_class | currency | country | account_type | balance_policy_limit | balance_policy_type |
      | ProductID  | WALLET       | CUSTOMER     | SHARIAH       | SGD      | SGP     | SAVINGS      | 0                    | STRICT              |

    Then I approve the product ProductID and verify status as PRODUCT_SUCCESS with provider DBS Bank Ltd for customerProfileId BCPID1

    Given I create account for CustomerProfile with id BCPID1 with product id as ProductID with bank account type as Payments Account with provider DBS Bank Ltd and expect the header status 200
      | identifier         | customer_profile_id | currency | country | in_trust | is_overdraft_allowed | on_behalf_of | metadata              | kyc_completed | trust_verification_completed |
      | CustomerCashWallet | IntegrationTest1    | SGD      | SGP     | false    | false                | CUSTOMER     | {"key": "MyMetaData"} | false         | false                        |

    Then I wait until max time to verify the bank account CustomerCashWallet status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId BCPID1

    Given I deposit an amount of 1000 into CustomerCashWallet using cash DevDeposit and expect the header status 200
      | identifier           | customer_profile_id | purpose  | currency | transaction_rail |
      | DevDepositIdentifier | BCPID1              | TRANSFER | SGD      | FAST             |

    Then I wait until max time to verify bank account CustomerCashWallet with an increased balance of 1000 for customerProfileId BCPID1

    Given I create a product with customer profile BCPID1 provider as DBS Bank Ltd and expect product_status PRODUCT_DRAFT
      | identifier | product_type | profile_type | product_class | currency | country | account_type | balance_policy_limit | balance_policy_type |
      | ProductID2 | WALLET       | END_CUSTOMER | SHARIAH       | SGD      | SGP     | SAVINGS      | 0                    | LENIENT             |

    Then I approve the product ProductID2 and verify status as PRODUCT_SUCCESS with provider DBS Bank Ltd for customerProfileId BCPID1

    Given I create account for EndCustomerProfile with id ECPID1 for CustomerProfile BCPID1 with product id ProductID2 with bank account type as PPA with provider DBS Bank Ltd and expect the header status 200
      | identifier    | customer_profile_id | end_customer_profile_id | currency | country | in_trust | is_overdraft_allowed | on_behalf_of | metadata                            |
      | CashWalletId2 | IntegrationTest1    | IntegrationEndCustomer  | SGD      | SGP     | false    | false                | CUSTOMER     | {"keyref":"M030126179534319754275"} |

    Then I wait until max time to verify the bank account CashWalletId2 status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId BCPID1

    Given I deposit an amount of 50 into CashWalletId2 using cash DevDeposit and expect the header status 200
      | identifier           | customer_profile_id | purpose  | currency | transaction_rail | amount |
      | DevDepositIdentifier | BCPID1              | TRANSFER | SGD      | FAST             | 100    |

    Then I wait until max time to verify bank account CashWalletId2 with an available balance of 50 and total balance of 50 for customerProfileId BCPID1

    Then I initiate transaction to transfer funds with below details and expect the header statuscode 200 and transaction status as TRANSACTION_AMOUNT_BLOCKED
      | identifier | customer_profile_id | account_id    | amount | purpose          | is_overdraft_allowed | metadata              | currency | sub_txn_type | receiver_account_id |
      | TxId1      | BCPID1              | CashWalletId2 | 100    | Integration Test | true                 | {"key": "MyMetaData"} | SGD      | CARD_TXN     | CashWalletId1       |

    Then I verify for bank account CashWalletId2 total balance is 50 and available balance is -50 for customerProfileId BCPID1

    Then I settle transaction to transfer funds with below details and expect the header statuscode 200 and transaction_status as TRANSACTION_SETTLED
      | transaction_id | customer_profile_id | amount | transaction_rail | is_overdraft_allowed | metadata              | overdraft_funding_account_id |
      | TxId1          | BCPID1              | 100    | FAST             | true                 | {"key": "MyMetaData"} | CustomerCashWallet           |

    Then I wait until max time to verify the transaction TxId1 status as TRANSACTION_SETTLED for customerProfileId BCPID1

    Then I verify for bank account CashWalletId2 total balance is -50 and available balance is -50 for customerProfileId BCPID1

    Then I get the deposit transaction TxId2 details for cash wallet CashWalletId1 for customerProfileId BCPID1

    Then I wait until max time to verify bank account CashWalletId1 with an available balance of 0 and total balance of 100 for customerProfileId BCPID1

    Then I confirm the deposit transaction TxId2 for customerProfileId BCPID1 and expect the header status as CSSM_9657 transaction status as Cannot Reject transaction
      | accept |
      | false  |
