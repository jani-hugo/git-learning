Feature: Card transaction test scenarios for provider Nymcard

  Background: I setup end-customer profile, card account and card for transactions on provider Nymcard
    Given I set and verify customer PKCID1, customer profile PKCPID1 of PK region in the context

    Then I create below End-Customer-Profile
      | customer_profile_identifier | end_customer_profile_identifier | first_name | last_name | region | email                | phone_number  |
      | PKCPID1                     | ECPID1                          | Sanji      | Vinsmoke  | PK     | blackleg@germa66.com | +923211234567 |

    Then I verify End-Customer-Profile exist with values
      | customer_profile_identifier | end_customer_profile_identifier | first_name | last_name | email                | phone_number  | status |
      | PKCPID1                     | ECPID1                          | Sanji      | Vinsmoke  | blackleg@germa66.com | +923211234567 | ACTIVE |

    Given I onboard CustomerProfile PKCPID1 with customerId PKCID1 on cash service on below providers and expect status 200
      | provider_name    |
      | HugoBank Limited |

    Then I wait until max time to verify CustomerProfile PKCPID1 onboard status as ONBOARD_SUCCESS

    When I onboard EndCustomerProfile ECPID1 of CustomerProfile PKCPID1 on cash service on below providers and expect status 200
      | provider_name    |
      | HugoBank Limited |

    Then I wait until max time to verify EndCustomerProfile ECPID1 of CustomerProfile PKCPID1 onboard status as ONBOARD_SUCCESS

    Given I onboard End-Customer Profile ECPID1 of Customer Profile PKCPID1 on fund provider CASH and on card service on below providers
      | provider_name |
      | Nymcard       |

    Then I wait until max time to verify End-Customer Profile ECPID1 onboard status on card service provider Nymcard as ONBOARD_SUCCESS

    Given I create a product with customer profile PKCPID1 provider as HugoBank Limited and expect product_status PRODUCT_DRAFT
      | identifier | product_type | profile_type | product_class | currency | country | account_type | is_overdraft_allowed | balance_policy_limit | balance_policy_type |
      | ProductId1 | WALLET       | END_CUSTOMER | SHARIAH       | PKR      | PAK     | SAVINGS      | true                 | 0                    | LENIENT             |

    Then I approve the product ProductId1 and verify status as PRODUCT_SUCCESS with provider HugoBank Limited for customerProfileId PKCPID1

    Given I create account for EndCustomerProfile with id ECPID1 for CustomerProfile PKCPID1 with product id ProductId1 with bank account type as Savings with provider HugoBank Limited and expect the header status 200
      | identifier | currency | country | in_trust | is_overdraft_allowed | on_behalf_of | metadata                    |
      | BankAccId  | PKR      | PAK     | false    | true                 | CUSTOMER     | {"key": "IntegrationTest1"} |

    Then I wait until max time to verify the bank account BankAccId status as ACCOUNT_CREATED with provider HugoBank Limited for customerProfileId PKCPID1

    Given I deposit an amount of 1000 into BankAccId using cash DevDeposit and expect the header status 200
      | identifier           | customer_profile_id | purpose  | currency | transaction_rail |
      | DevDepositIdentifier | PKCPID1             | TRANSFER | PKR      | RAAST            |

    Then I wait until max time to verify bank account BankAccId with an increased balance of 1000 for customerProfileId PKCPID1

    Given I create below Card Account
      | card_account_identifier | end_customer_profile_identifier | provider_name | bank_account_identifier | customer_address                                                                                                                                                                                                                                      |
      | CardAccId1              | ECPID1                          | Nymcard       | BankAccId               | {"address_line_1":"Atlas Consolidated Labs", "address_line_2":"Mukunda Towers", "address_line_3":"Indian Airlines Colony", "address_line_4":"Begumpet", "city":"Hyderabad", "state":"", "country": "", "country_code": "SGP", "local_code": "800003"} |

    Then I wait until max time to verify Card Account CardAccId1 onboard status on card service provider Nymcard as CARD_ACCOUNT_CREATED

    Given I issue Card for Card Account on provider Nymcard
      | card_identifier | card_account_identifier | card_type | emboss_name | validity_in_months | three_d_secure_config                                                                | delivery_address                                                                                                                                                                                                                                      |
      | CardId1         | CardAccId1              | PHYSICAL  | Kurohashi   | 60                 | {"security_question": "What is your name?", "security_answer": "Kurohashi no Sanji"} | {"address_line_1":"Atlas Consolidated Labs", "address_line_2":"Mukunda Towers", "address_line_3":"Indian Airlines Colony", "address_line_4":"Begumpet", "city":"Hyderabad", "state":"", "country": "", "country_code": "PAK", "local_code": "800003"} |

    Then I wait until max time to verify Card CardId1 status on card service provider Nymcard as INACTIVE

    Then I activate the Card
      | card_identifier |
      | CardId1         |

  Scenario Outline: Nymcard Transaction - One debit authorization
    Given I set the following transaction information
      | transaction_identifier | network | message_type   | transaction_type   | transaction_description |
      | T1                     | VISA    | <message_type> | <transaction_type> | <transaction_type>      |

    Then I set card information in the transaction context
      | transaction_identifier | card_identifier | user_identifier |
      | T1                     | CardId1         | ECPID1          |

    Then I set merchant information in transaction context
      | transaction_identifier | acquirer_id | merchant_id | mcc  | merchant_name | merchant_city | merchant_country | terminal_id |
      | T1                     | 136200      | SCOTIABANK  | 5999 | CAIROO        | CHATTANOOG    | USA              | 99999999    |

    Then I set amount information in transaction context
      | transaction_identifier | transaction_amount | transaction_currency | billing_amount   | billing_currency   |
      | T1                     | <txn_amount>       | <txn_currency>       | <billing_amount> | <billing_currency> |

    Then I set the following required indicators in transaction context
      | transaction_identifier | card_entry   | pos_environment | pin_present | moto  | performed_operation_type | processing_code | three_DS_indicator |
      | T1                     | DATA_ON_FILE | E_COMMERCE      | false       | false | D                        | 000000          | true               |

    When I initiate below Nymcard Transaction requests
      | transaction_identifier | status_code   | status_description   |
      | T1                     | <status_code> | <status_description> |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance> and total balance of <total_balance> for customerProfileId PKCPID1

    Then I validate TransactionLog entries for the performed Nymcard Transactions
      | transaction_identifier | fp_transaction_id | transaction_amount | billing_amount   | transaction_currency | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T1                     | VALID_UUID        | <txn_amount>       | <billing_amount> | <txn_currency>       | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate TransactionLogDetail entries for the performed Nymcard Transactions
      | transaction_identifier | idempotency_key | transaction_amount | billing_amount   | transaction_currency | billing_currency   | transaction_type | transaction_status |
      | T1                     | T1              | <txn_amount>       | <billing_amount> | <txn_currency>       | <billing_currency> | DEBIT_INITIAL    | COMPLETED          |

    Examples:
      | message_type         | transaction_type | txn_amount | txn_currency | billing_amount | billing_currency | status_code | status_description   | available_balance | total_balance |
      | AUTHORIZATION        | PURCHASE         | 5.75       | USD          | 999.50         | PKR              | 0000        | TRANSACTION_APPROVED | 0.50              | 1000          |
      | AUTHORIZATION        | PURCHASE         | 2500.30    | JPY          | 999.99         | PKR              | 0000        | TRANSACTION_APPROVED | 0.01              | 1000          |
      | AUTHORIZATION        | CASH_WITHDRAWAL  | 20.25      | AED          | 500.75         | PKR              | 0000        | TRANSACTION_APPROVED | 499.25            | 1000          |
      | AUTHORIZATION        | CASH_WITHDRAWAL  | 12.99      | USD          | 1000.00        | PKR              | 0000        | TRANSACTION_APPROVED | 0                 | 1000          |
      | AUTHORIZATION_ADVICE | PURCHASE         | 100.40     | AED          | 270.50         | PKR              | 0000        | TRANSACTION_APPROVED | 729.50            | 1000          |
      | AUTHORIZATION_ADVICE | PURCHASE         | 10.15      | GBP          | 999.99         | PKR              | 0000        | TRANSACTION_APPROVED | 0.01              | 1000          |
      | AUTHORIZATION_ADVICE | PURCHASE         | 4000.99    | JPY          | 1001           | PKR              | 0000        | TRANSACTION_APPROVED | -1                | 1000          |
      | AUTHORIZATION_ADVICE | CASH_WITHDRAWAL  | 7.55       | AUD          | 375.75         | PKR              | 0000        | TRANSACTION_APPROVED | 624.25            | 1000          |

  Scenario Outline: Nymcard Transaction - Debit Authorization followed by one incremental authorization
    Given I set the following transaction information
      | transaction_identifier | parent_transaction_identifier | network | message_type        | transaction_type   | transaction_description | rrn_identifier |
      | T1                     |                               | VISA    | <auth_message_type> | <transaction_type> | <transaction_type>      | RRN1           |
      | T2                     | T1                            | VISA    | <incr_message_type> | <transaction_type> | <transaction_type>      | RRN1           |

    Then I set card information in the transaction context
      | transaction_identifier | card_identifier | user_identifier |
      | T1                     | CardId1         | ECPID1          |
      | T2                     | CardId1         | ECPID1          |

    Then I set merchant information in transaction context
      | transaction_identifier | acquirer_id | merchant_id | mcc  | merchant_name | merchant_city | merchant_country | terminal_id |
      | T1                     | 136200      | SCOTIABANK  | 5999 | CAIROO        | CHATTANOOG    | USA              | 99999999    |
      | T2                     | 136200      | SCOTIABANK  | 5999 | CAIROO        | CHATTANOOG    | USA              | 99999999    |

    Then I set amount information in transaction context
      | transaction_identifier | transaction_amount | transaction_currency | billing_amount        | billing_currency   |
      | T1                     | <auth_txn_amount>  | <txn_currency>       | <auth_billing_amount> | <billing_currency> |
      | T2                     | <incr_txn_amount>  | <txn_currency>       | <incr_billing_amount> | <billing_currency> |

    Then I set the following required indicators in transaction context
      | transaction_identifier | incremental_transaction | card_entry   | pos_environment | pin_present | moto  | performed_operation_type | processing_code | three_ds_indicator |
      | T1                     | false                   | DATA_ON_FILE | E_COMMERCE      | false       | false | D                        | 000000          | true               |
      | T2                     | true                    | DATA_ON_FILE | E_COMMERCE      | false       | false | D                        | 000000          | true               |

    When I initiate below Nymcard Transaction requests
      | transaction_identifier | status_code        | status_description        |
      | T1                     | <auth_status_code> | <auth_status_description> |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_after_auth> and total balance of <total_balance> for customerProfileId PKCPID1

    Then I validate TransactionLog entries for the performed Nymcard Transactions
      | transaction_identifier | fp_transaction_id | transaction_amount | billing_amount        | transaction_currency | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T1                     | VALID_UUID        | <auth_txn_amount>  | <auth_billing_amount> | <txn_currency>       | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate TransactionLogDetail entries for the performed Nymcard Transactions
      | transaction_identifier | idempotency_key | transaction_amount | billing_amount        | transaction_currency | billing_currency   | transaction_type | transaction_status |
      | T1                     | T1              | <auth_txn_amount>  | <auth_billing_amount> | <txn_currency>       | <billing_currency> | DEBIT_INITIAL    | COMPLETED          |

    When I initiate below Nymcard Transaction requests
      | transaction_identifier | status_code        | status_description        |
      | T2                     | <incr_status_code> | <incr_status_description> |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_after_incr> and total balance of <total_balance> for customerProfileId PKCPID1

    Then I validate TransactionLog entries for the performed Nymcard Transactions
      | transaction_identifier | fp_transaction_id | transaction_amount | billing_amount         | transaction_currency | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T2                     | VALID_UUID        | <total_txn_amount> | <total_billing_amount> | <txn_currency>       | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate TransactionLogDetail entries for the performed Nymcard Transactions
      | transaction_identifier | idempotency_key | transaction_amount | billing_amount         | transaction_currency | billing_currency   | transaction_type | transaction_status |
      | T2                     | T2              | <total_txn_amount> | <total_billing_amount> | <txn_currency>       | <billing_currency> | DEBIT_INCREMENT  | COMPLETED          |

    Examples:
      | auth_message_type    | incr_message_type    | transaction_type | auth_txn_amount | incr_txn_amount | total_txn_amount | txn_currency | auth_billing_amount | incr_billing_amount | total_billing_amount | billing_currency | auth_status_code | auth_status_description | incr_status_code | incr_status_description | available_balance_after_auth | available_balance_after_incr | total_balance |
      | AUTHORIZATION        | AUTHORIZATION        | PURCHASE         | 300             | 200             | 500              | USD          | 750                 | 250                 | 1000                 | PKR              | 0000             | TRANSACTION_APPROVED    | 0000             | TRANSACTION_APPROVED    | 250                          | 0                            | 1000          |
      | AUTHORIZATION        | AUTHORIZATION        | CASH_WITHDRAWAL  | 150.75          | 75.25           | 226              | EUR          | 600                 | 399.99              | 999.99               | PKR              | 0000             | TRANSACTION_APPROVED    | 0000             | TRANSACTION_APPROVED    | 400                          | 0.01                         | 1000          |
      | AUTHORIZATION        | AUTHORIZATION_ADVICE | PURCHASE         | 100.50          | 150.25          | 250.75           | GBP          | 650.45              | 350.55              | 1001                 | PKR              | 0000             | TRANSACTION_APPROVED    | 0000             | TRANSACTION_APPROVED    | 349.55                       | -1                           | 1000          |
      | AUTHORIZATION        | AUTHORIZATION_ADVICE | CASH_WITHDRAWAL  | 412             | 75              | 487              | JPY          | 530                 | 469.99              | 999.99               | PKR              | 0000             | TRANSACTION_APPROVED    | 0000             | TRANSACTION_APPROVED    | 470                          | 0.01                         | 1000          |
      | AUTHORIZATION_ADVICE | AUTHORIZATION        | PURCHASE         | 300             | 200             | 500              | CAD          | 600                 | 200                 | 800                  | PKR              | 0000             | TRANSACTION_APPROVED    | 0000             | TRANSACTION_APPROVED    | 400                          | 200                          | 1000          |
      | AUTHORIZATION_ADVICE | AUTHORIZATION        | CASH_WITHDRAWAL  | 100             | 80.50           | 180.50           | AUD          | 360.40              | 239.60              | 600                  | PKR              | 0000             | TRANSACTION_APPROVED    | 0000             | TRANSACTION_APPROVED    | 639.60                       | 400                          | 1000          |
      | AUTHORIZATION        | AUTHORIZATION        | PURCHASE         | 250.60          | 249.40          | 500              | SEK          | 400                 | 300                 | 700                  | PKR              | 0000             | TRANSACTION_APPROVED    | 0000             | TRANSACTION_APPROVED    | 600                          | 300                          | 1000          |
      | AUTHORIZATION        | AUTHORIZATION_ADVICE | PURCHASE         | 199.99          | 199.99          | 399.98           | NOK          | 500                 | 300                 | 800                  | PKR              | 0000             | TRANSACTION_APPROVED    | 0000             | TRANSACTION_APPROVED    | 500                          | 200                          | 1000          |
      | AUTHORIZATION        | AUTHORIZATION        | CASH_WITHDRAWAL  | 120.25          | 75.50           | 195.75           | CHF          | 499.99              | 500.01              | 1000                 | PKR              | 0000             | TRANSACTION_APPROVED    | 0000             | TRANSACTION_APPROVED    | 500.01                       | 0                            | 1000          |
      | AUTHORIZATION_ADVICE | AUTHORIZATION_ADVICE | CASH_WITHDRAWAL  | 400.15          | 100.10          | 500.25           | SGD          | 400                 | 600.06              | 1000.06              | PKR              | 0000             | TRANSACTION_APPROVED    | 0000             | TRANSACTION_APPROVED    | 600                          | -0.06                        | 1000          |

  Scenario Outline: Nymcard Transaction - Debit Authorization followed by multiple incremental authorization
    Given I set the following transaction information
      | transaction_identifier | parent_transaction_identifier | network | message_type          | transaction_type   | transaction_description | rrn_identifier |
      | T1                     |                               | VISA    | <auth_message_type>   | <transaction_type> | <transaction_type>      | RRN1           |
      | T2                     | T1                            | VISA    | <incr_1_message_type> | <transaction_type> | <transaction_type>      | RRN1           |
      | T3                     | T1                            | VISA    | <incr_2_message_type> | <transaction_type> | <transaction_type>      | RRN1           |

    Then I set card information in the transaction context
      | transaction_identifier | card_identifier | user_identifier |
      | T1                     | CardId1         | ECPID1          |
      | T2                     | CardId1         | ECPID1          |
      | T3                     | CardId1         | ECPID1          |

    Then I set merchant information in transaction context
      | transaction_identifier | acquirer_id | merchant_id | mcc  | merchant_name | merchant_city | merchant_country | terminal_id |
      | T1                     | 136200      | SCOTIABANK  | 5999 | CAIROO        | CHATTANOOG    | USA              | 99999999    |
      | T2                     | 136200      | SCOTIABANK  | 5999 | CAIROO        | CHATTANOOG    | USA              | 99999999    |
      | T3                     | 136200      | SCOTIABANK  | 5999 | CAIROO        | CHATTANOOG    | USA              | 99999999    |

    Then I set amount information in transaction context
      | transaction_identifier | transaction_amount  | transaction_currency | billing_amount          | billing_currency   |
      | T1                     | <auth_txn_amount>   | <txn_currency>       | <auth_billing_amount>   | <billing_currency> |
      | T2                     | <incr_txn_amount_1> | <txn_currency>       | <incr_billing_amount_1> | <billing_currency> |
      | T3                     | <incr_txn_amount_2> | <txn_currency>       | <incr_billing_amount_2> | <billing_currency> |

    Then I set the following required indicators in transaction context
      | transaction_identifier | incremental_transaction | card_entry   | pos_environment | pin_present | moto  | performed_operation_type | processing_code | three_ds_indicator |
      | T1                     | false                   | DATA_ON_FILE | E_COMMERCE      | false       | false | D                        | 000000          | true               |
      | T2                     | true                    | DATA_ON_FILE | E_COMMERCE      | false       | false | D                        | 000000          | true               |
      | T3                     | true                    | DATA_ON_FILE | E_COMMERCE      | false       | false | D                        | 000000          | true               |

    When I initiate below Nymcard Transaction requests
      | transaction_identifier | status_code        | status_description        |
      | T1                     | <auth_status_code> | <auth_status_description> |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_after_auth> and total balance of <total_balance> for customerProfileId PKCPID1

    Then I validate TransactionLog entries for the performed Nymcard Transactions
      | transaction_identifier | fp_transaction_id | transaction_amount | billing_amount        | transaction_currency | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T1                     | VALID_UUID        | <auth_txn_amount>  | <auth_billing_amount> | <txn_currency>       | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate TransactionLogDetail entries for the performed Nymcard Transactions
      | transaction_identifier | idempotency_key | transaction_amount | billing_amount        | transaction_currency | billing_currency   | transaction_type | transaction_status |
      | T1                     | T1              | <auth_txn_amount>  | <auth_billing_amount> | <txn_currency>       | <billing_currency> | DEBIT_INITIAL    | COMPLETED          |

    When I initiate below Nymcard Transaction requests
      | transaction_identifier | status_code          | status_description          |
      | T2                     | <incr_status_code_1> | <incr_status_description_1> |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_after_incr_1> and total balance of <total_balance> for customerProfileId PKCPID1

    Then I validate TransactionLog entries for the performed Nymcard Transactions
      | transaction_identifier | fp_transaction_id | transaction_amount              | billing_amount                      | transaction_currency | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T2                     | VALID_UUID        | <total_txn_amount_after_incr_1> | <total_billing_amount_after_incr_1> | <txn_currency>       | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate TransactionLogDetail entries for the performed Nymcard Transactions
      | transaction_identifier | idempotency_key | transaction_amount              | billing_amount                      | transaction_currency | billing_currency   | transaction_type | transaction_status |
      | T2                     | T2              | <total_txn_amount_after_incr_1> | <total_billing_amount_after_incr_1> | <txn_currency>       | <billing_currency> | DEBIT_INCREMENT  | COMPLETED          |

    When I initiate below Nymcard Transaction requests
      | transaction_identifier | status_code          | status_description          |
      | T3                     | <incr_status_code_2> | <incr_status_description_2> |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_after_incr_2> and total balance of <total_balance> for customerProfileId PKCPID1

    Then I validate TransactionLog entries for the performed Nymcard Transactions
      | transaction_identifier | fp_transaction_id | transaction_amount | billing_amount         | transaction_currency | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T3                     | VALID_UUID        | <total_txn_amount> | <total_billing_amount> | <txn_currency>       | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate TransactionLogDetail entries for the performed Nymcard Transactions
      | transaction_identifier | idempotency_key | transaction_amount | billing_amount         | transaction_currency | billing_currency   | transaction_type | transaction_status |
      | T3                     | T3              | <total_txn_amount> | <total_billing_amount> | <txn_currency>       | <billing_currency> | DEBIT_INCREMENT  | COMPLETED          |

    Examples:
      | auth_message_type    | incr_1_message_type  | incr_2_message_type  | transaction_type | auth_txn_amount | incr_txn_amount_1 | incr_txn_amount_2 | total_txn_amount_after_incr_1 | total_txn_amount | txn_currency | auth_billing_amount | incr_billing_amount_1 | incr_billing_amount_2 | total_billing_amount_after_incr_1 | total_billing_amount | billing_currency | auth_status_code | auth_status_description | incr_status_code_1 | incr_status_description_1 | incr_status_code_2 | incr_status_description_2 | available_balance_after_auth | available_balance_after_incr_1 | available_balance_after_incr_2 | total_balance |
      | AUTHORIZATION        | AUTHORIZATION        | AUTHORIZATION        | PURCHASE         | 100             | 300               | 600               | 400                           | 1000             | USD          | 200                 | 300                   | 500                   | 500                               | 1000                 | PKR              | 0000             | TRANSACTION_APPROVED    | 0000               | TRANSACTION_APPROVED      | 0000               | TRANSACTION_APPROVED      | 800                          | 500                            | 0                              | 1000          |
      | AUTHORIZATION_ADVICE | AUTHORIZATION_ADVICE | AUTHORIZATION_ADVICE | CASH_WITHDRAWAL  | 1100            | 50                | 50                | 1150                          | 1200             | JPY          | 1500                | 200                   | 200                   | 1700                              | 1900                 | PKR              | 0000             | TRANSACTION_APPROVED    | 0000               | TRANSACTION_APPROVED      | 0000               | TRANSACTION_APPROVED      | -500                         | -700                           | -900                           | 1000          |
      | AUTHORIZATION        | AUTHORIZATION        | AUTHORIZATION        | PURCHASE         | 463             | 54                | 2                 | 517                           | 519              | EUR          | 950                 | 5                     | 45                    | 955                               | 1000                 | PKR              | 0000             | TRANSACTION_APPROVED    | 0000               | TRANSACTION_APPROVED      | 0000               | TRANSACTION_APPROVED      | 50                           | 45                             | 0                              | 1000          |
      | AUTHORIZATION        | AUTHORIZATION        | AUTHORIZATION        | PURCHASE         | 50              | 50                | 10                | 100                           | 110              | SGD          | 50                  | 50                    | 10                    | 100                               | 110                  | PKR              | 0000             | TRANSACTION_APPROVED    | 0000               | TRANSACTION_APPROVED      | 0000               | TRANSACTION_APPROVED      | 950                          | 900                            | 890                            | 1000          |
      | AUTHORIZATION        | AUTHORIZATION        | AUTHORIZATION        | PURCHASE         | 0.01            | 0.02              | 0.03              | 0.03                          | 0.06             | CHF          | 0.01                | 0.02                  | 0.03                  | 0.03                              | 0.06                 | PKR              | 0000             | TRANSACTION_APPROVED    | 0000               | TRANSACTION_APPROVED      | 0000               | TRANSACTION_APPROVED      | 999.99                       | 999.97                         | 999.94                         | 1000          |
      | AUTHORIZATION        | AUTHORIZATION        | AUTHORIZATION        | CASH_WITHDRAWAL  | 500             | 200               | 200               | 700                           | 900              | GBP          | 500                 | 200                   | 200                   | 700                               | 900                  | PKR              | 0000             | TRANSACTION_APPROVED    | 0000               | TRANSACTION_APPROVED      | 0000               | TRANSACTION_APPROVED      | 500                          | 300                            | 100                            | 1000          |
      | AUTHORIZATION        | AUTHORIZATION_ADVICE | AUTHORIZATION_ADVICE | PURCHASE         | 999             | 999               | 999               | 1998                          | 2997             | ZAR          | 1000                | 1999                  | 999                   | 2999                              | 3998                 | PKR              | 0000             | TRANSACTION_APPROVED    | 0000               | TRANSACTION_APPROVED      | 0000               | TRANSACTION_APPROVED      | 0                            | -1999                          | -2998                          | 1000          |


  Scenario Outline: Nymcard Transaction - Authorization Balance Inquiry
    Given I set the following transaction information
      | transaction_identifier | network | message_type  | transaction_type   | transaction_description |
      | T1                     | VISA    | AUTHORIZATION | <transaction_type> | <transaction_type>      |

    Then I set card information in the transaction context
      | transaction_identifier | card_identifier | user_identifier |
      | T1                     | CardId1         | ECPID1          |

    Then I set merchant information in transaction context
      | transaction_identifier | acquirer_id | terminal_id |
      | T1                     | 136200      | 99999999    |

    Then I set the following required indicators in transaction context
      | transaction_identifier | card_entry   | pos_environment | pin_present | processing_code |
      | T1                     | DATA_ON_FILE | E_COMMERCE      | false       | 010000          |

    When I initiate below Nymcard Transaction requests
      | transaction_identifier | account_balance   | account_currency   | status_code   | status_description   |
      | T1                     | <account_balance> | <account_currency> | <status_code> | <status_description> |

    Examples:
      | transaction_type | account_balance | account_currency | status_code | status_description   |
      | BALANCE_INQUIRY  | 1000            | PKR              | 0000        | TRANSACTION_APPROVED |

  Scenario Outline: Nymcard Transaction - Single debit authorization followed by a balance inquiry request
    Given I set the following transaction information
      | transaction_identifier | network | message_type                   | transaction_type                   | transaction_description            |
      | T1                     | VISA    | <auth_message_type>            | <auth_transaction_type>            | <auth_transaction_type>            |
      | T2                     | VISA    | <balance_inquiry_message_type> | <balance_inquiry_transaction_type> | <balance_inquiry_transaction_type> |

    Then I set card information in the transaction context
      | transaction_identifier | card_identifier | user_identifier |
      | T1                     | CardId1         | ECPID1          |
      | T2                     | CardId1         | ECPID1          |

    Then I set merchant information in transaction context
      | transaction_identifier | acquirer_id | merchant_id | mcc  | merchant_name | merchant_city | merchant_country | terminal_id |
      | T1                     | 136200      | SCOTIABANK  | 5999 | CAIROO        | CHATTANOOG    | USA              | 99999999    |
      | T2                     | 136200      | SCOTIABANK  | 5999 | CAIROO        | CHATTANOOG    | USA              | 99999999    |

    Then I set amount information in transaction context
      | transaction_identifier | transaction_amount | transaction_currency | billing_amount   | billing_currency   |
      | T1                     | <txn_amount>       | <txn_currency>       | <billing_amount> | <billing_currency> |

    Then I set the following required indicators in transaction context
      | transaction_identifier | card_entry   | pos_environment | pin_present | moto  | performed_operation_type | processing_code | three_ds_indicator |
      | T1                     | DATA_ON_FILE | E_COMMERCE      | false       | false | D                        | 000000          | true               |
      | T2                     | DATA_ON_FILE | E_COMMERCE      | false       | false |                          | 010000          | false              |

    When I initiate below Nymcard Transaction requests
      | transaction_identifier | status_code        | status_description        |
      | T1                     | <auth_status_code> | <auth_status_description> |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance> and total balance of <total_balance> for customerProfileId PKCPID1

    Then I validate TransactionLog entries for the performed Nymcard Transactions
      | transaction_identifier | fp_transaction_id | transaction_amount | billing_amount   | transaction_currency | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T1                     | VALID_UUID        | <txn_amount>       | <billing_amount> | <txn_currency>       | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate TransactionLogDetail entries for the performed Nymcard Transactions
      | transaction_identifier | idempotency_key | transaction_amount | billing_amount   | transaction_currency | billing_currency   | transaction_type | transaction_status |
      | T1                     | T1              | <txn_amount>       | <billing_amount> | <txn_currency>       | <billing_currency> | DEBIT_INITIAL    | COMPLETED          |

    When I initiate below Nymcard Transaction requests
      | transaction_identifier | account_balance     | account_currency   | status_code                   | status_description                   |
      | T2                     | <available_balance> | <account_currency> | <balance_inquiry_status_code> | <balance_inquiry_status_description> |

    Examples:
      | auth_message_type    | balance_inquiry_message_type | auth_transaction_type | balance_inquiry_transaction_type | txn_amount | txn_currency | billing_amount | billing_currency | account_currency | auth_status_code | auth_status_description | balance_inquiry_status_code | balance_inquiry_status_description | available_balance | total_balance |
      | AUTHORIZATION        | AUTHORIZATION                | PURCHASE              | BALANCE_INQUIRY                  | 645        | USD          | 999.99         | PKR              | PKR              | 0000             | TRANSACTION_APPROVED    | 0000                        | TRANSACTION_APPROVED               | 0.01              | 1000          |
      | AUTHORIZATION        | AUTHORIZATION                | PURCHASE              | BALANCE_INQUIRY                  | 245        | INR          | 1000           | PKR              | PKR              | 0000             | TRANSACTION_APPROVED    | 0000                        | TRANSACTION_APPROVED               | 0                 | 1000          |
      | AUTHORIZATION_ADVICE | AUTHORIZATION                | CASH_WITHDRAWAL       | BALANCE_INQUIRY                  | 305        | SGD          | 1000.2         | PKR              | PKR              | 0000             | TRANSACTION_APPROVED    | 0000                        | TRANSACTION_APPROVED               | -0.2              | 1000          |

  Scenario Outline: Nymcard Transaction - Debit authorization that exceeds account funds
    Given I set the following transaction information
      | transaction_identifier | network | message_type  | transaction_type   | transaction_description |
      | T1                     | VISA    | AUTHORIZATION | <transaction_type> | <transaction_type>      |

    Then I set card information in the transaction context
      | transaction_identifier | card_identifier | user_identifier |
      | T1                     | CardId1         | ECPID1          |

    Then I set merchant information in transaction context
      | transaction_identifier | acquirer_id | merchant_id | mcc  | merchant_name | merchant_city | merchant_country | terminal_id |
      | T1                     | 136200      | SCOTIABANK  | 5999 | CAIROO        | CHATTANOOG    | USA              | 99999999    |

    Then I set amount information in transaction context
      | transaction_identifier | transaction_amount | transaction_currency | billing_amount   | billing_currency   |
      | T1                     | <txn_amount>       | <txn_currency>       | <billing_amount> | <billing_currency> |

    Then I set the following required indicators in transaction context
      | transaction_identifier | card_entry   | pos_environment | pin_present | moto  | performed_operation_type | processing_code | three_ds_indicator |
      | T1                     | DATA_ON_FILE | E_COMMERCE      | false       | false | D                        | 000000          | true               |

    When I initiate below Nymcard Transaction requests
      | transaction_identifier | status_code   | status_description   |
      | T1                     | <status_code> | <status_description> |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance> and total balance of <total_balance> for customerProfileId PKCPID1

    Then I validate TransactionLog entries for the performed Nymcard Transactions
      | transaction_identifier | fp_transaction_id | transaction_amount | billing_amount   | transaction_currency | billing_currency   | transaction_type | transaction_status |
      | T1                     | VALID_UUID        | <txn_amount>       | <billing_amount> | <txn_currency>       | <billing_currency> | DEBIT_CREATE     | AUTH_DECLINED      |

    Then I validate TransactionLogDetail entries for the performed Nymcard Transactions
      | transaction_identifier | idempotency_key | transaction_amount | billing_amount   | transaction_currency | billing_currency   | transaction_type | transaction_status |
      | T1                     | T1              | <txn_amount>       | <billing_amount> | <txn_currency>       | <billing_currency> | DEBIT_INITIAL    | FAILED             |

    Examples:
      | transaction_type | txn_amount | txn_currency | billing_amount | billing_currency | status_code | status_description   | available_balance | total_balance |
      | CASH_WITHDRAWAL  | 600        | AED          | 1200           | PKR              | 1016        | NOT_SUFFICIENT_FUNDS | 1000              | 1000          |

  Scenario Outline: Nymcard Transaction - Debit Authorization followed by incremental authorization that exceeds account funds
    Given I set the following transaction information
      | transaction_identifier | parent_transaction_identifier | network | message_type  | transaction_type   | transaction_description | rrn_identifier |
      | T1                     |                               | VISA    | AUTHORIZATION | <transaction_type> | <transaction_type>      | RRN1           |
      | T2                     | T1                            | VISA    | AUTHORIZATION | <transaction_type> | <transaction_type>      | RRN1           |

    Then I set card information in the transaction context
      | transaction_identifier | card_identifier | user_identifier |
      | T1                     | CardId1         | ECPID1          |
      | T2                     | CardId1         | ECPID1          |

    Then I set merchant information in transaction context
      | transaction_identifier | acquirer_id | merchant_id | mcc  | merchant_name | merchant_city | merchant_country | terminal_id |
      | T1                     | 136200      | SCOTIABANK  | 5999 | CAIROO        | CHATTANOOG    | USA              | 99999999    |
      | T2                     | 136200      | SCOTIABANK  | 5999 | CAIROO        | CHATTANOOG    | USA              | 99999999    |

    Then I set amount information in transaction context
      | transaction_identifier | transaction_amount | transaction_currency | billing_amount        | billing_currency   |
      | T1                     | <auth_txn_amount>  | <txn_currency>       | <auth_billing_amount> | <billing_currency> |
      | T2                     | <incr_txn_amount>  | <txn_currency>       | <incr_billing_amount> | <billing_currency> |

    Then I set the following required indicators in transaction context
      | transaction_identifier | incremental_transaction | card_entry   | pos_environment | pin_present | moto  | performed_operation_type | processing_code | three_ds_indicator |
      | T1                     | false                   | DATA_ON_FILE | E_COMMERCE      | false       | false | D                        | 000000          | true               |
      | T2                     | true                    | DATA_ON_FILE | E_COMMERCE      | false       | false | D                        | 000000          | true               |

    When I initiate below Nymcard Transaction requests
      | transaction_identifier | status_code        | status_description        |
      | T1                     | <auth_status_code> | <auth_status_description> |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_after_auth> and total balance of <total_balance> for customerProfileId PKCPID1

    Then I validate TransactionLog entries for the performed Nymcard Transactions
      | transaction_identifier | fp_transaction_id | transaction_amount | billing_amount        | transaction_currency | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T1                     | VALID_UUID        | <auth_txn_amount>  | <auth_billing_amount> | <txn_currency>       | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate TransactionLogDetail entries for the performed Nymcard Transactions
      | transaction_identifier | idempotency_key | transaction_amount | billing_amount        | transaction_currency | billing_currency   | transaction_type | transaction_status |
      | T1                     | T1              | <auth_txn_amount>  | <auth_billing_amount> | <txn_currency>       | <billing_currency> | DEBIT_INITIAL    | COMPLETED          |

    When I initiate below Nymcard Transaction requests
      | transaction_identifier | status_code        | status_description        |
      | T2                     | <incr_status_code> | <incr_status_description> |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_after_incr> and total balance of <total_balance> for customerProfileId PKCPID1

    Then I validate TransactionLog entries for the performed Nymcard Transactions
      | transaction_identifier | fp_transaction_id | transaction_amount | billing_amount        | transaction_currency | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T2                     | VALID_UUID        | <auth_txn_amount>  | <auth_billing_amount> | <txn_currency>       | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate TransactionLogDetail entries for the performed Nymcard Transactions
      | transaction_identifier | idempotency_key | transaction_amount | billing_amount         | transaction_currency | billing_currency   | transaction_type | transaction_status |
      | T2                     | T2              | <total_txn_amount> | <total_billing_amount> | <txn_currency>       | <billing_currency> | DEBIT_INCREMENT  | FAILED             |

    Examples:
      | transaction_type | auth_txn_amount | incr_txn_amount | total_txn_amount | txn_currency | auth_billing_amount | incr_billing_amount | total_billing_amount | billing_currency | auth_status_code | auth_status_description | incr_status_code | incr_status_description | available_balance_after_auth | available_balance_after_incr | total_balance |
      | PURCHASE         | 10              | 500             | 510              | USD          | 100                 | 1000                | 1100                 | PKR              | 0000             | TRANSACTION_APPROVED    | 1016             | NOT_SUFFICIENT_FUNDS    | 900                          | 900                          | 1000          |

  Scenario Outline: Nymcard Transaction - Debit authorization is approved and is later reverted by authorization advice
    Given I set the following transaction information
      | transaction_identifier | parent_transaction_identifier | network | message_type         | transaction_type   | transaction_description | rrn_identifier |
      | T1                     |                               | VISA    | AUTHORIZATION        | <transaction_type> | <transaction_type>      | RRN1           |
      | T2                     | T1                            | VISA    | AUTHORIZATION_ADVICE | <transaction_type> | <transaction_type>      | RRN1           |

    Then I set card information in the transaction context
      | transaction_identifier | card_identifier | user_identifier |
      | T1                     | CardId1         | ECPID1          |
      | T2                     | CardId1         | ECPID1          |

    Then I set merchant information in transaction context
      | transaction_identifier | acquirer_id | merchant_id | mcc  | merchant_name | merchant_city | merchant_country | terminal_id |
      | T1                     | 136200      | SCOTIABANK  | 5999 | CAIROO        | CHATTANOOG    | USA              | 99999999    |
      | T2                     | 136200      | SCOTIABANK  | 5999 | CAIROO        | CHATTANOOG    | USA              | 99999999    |

    Then I set amount information in transaction context
      | transaction_identifier | transaction_amount | transaction_currency | billing_amount   | billing_currency   |
      | T1                     | <txn_amount>       | <txn_currency>       | <billing_amount> | <billing_currency> |
      | T2                     | <txn_amount>       | <txn_currency>       | <billing_amount> | <billing_currency> |

    Then I set the following required indicators in transaction context
      | transaction_identifier | card_entry   | pos_environment | pin_present | moto  | performed_operation_type | processing_code | three_ds_indicator |
      | T1                     | DATA_ON_FILE | E_COMMERCE      | false       | false | D                        | 000000          | true               |
      | T2                     | DATA_ON_FILE | E_COMMERCE      | false       | false | C                        | 000000          | true               |

    When I initiate below Nymcard Transaction requests
      | transaction_identifier | status_code   | status_description   |
      | T1                     | <status_code> | <status_description> |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_after_auth> and total balance of <total_balance> for customerProfileId PKCPID1

    Then I validate TransactionLog entries for the performed Nymcard Transactions
      | transaction_identifier | fp_transaction_id | transaction_amount | billing_amount   | transaction_currency | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T1                     | VALID_UUID        | <txn_amount>       | <billing_amount> | <txn_currency>       | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate TransactionLogDetail entries for the performed Nymcard Transactions
      | transaction_identifier | idempotency_key | transaction_amount | billing_amount   | transaction_currency | billing_currency   | transaction_type | transaction_status |
      | T1                     | T1              | <txn_amount>       | <billing_amount> | <txn_currency>       | <billing_currency> | DEBIT_INITIAL    | COMPLETED          |

    When I initiate below Nymcard Transaction requests
      | transaction_identifier | status_code   | status_description   |
      | T2                     | <status_code> | <status_description> |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_after_stip_reversal> and total balance of <total_balance> for customerProfileId PKCPID1

    Then I validate TransactionLog entries for the performed Nymcard Transactions
      | transaction_identifier | fp_transaction_id | transaction_amount | billing_amount | transaction_currency | billing_currency   | transaction_type | transaction_status   | release_auth_ts | release_type     |
      | T2                     | VALID_UUID        | 0                  | 0              | <txn_currency>       | <billing_currency> | DEBIT_CREATE     | TRANSACTION_REVERTED | T+30            | SCHEDULED_EXPIRY |

    Then I validate TransactionLogDetail entries for the performed Nymcard Transactions
      | transaction_identifier | idempotency_key | transaction_amount | billing_amount | transaction_currency | billing_currency   | transaction_type | transaction_status |
      | T2                     | T2              | 0                  | 0              | <txn_currency>       | <billing_currency> | DEBIT_REVERSAL   | COMPLETED          |

    Examples:
      | transaction_type | txn_amount | txn_currency | billing_amount | billing_currency | status_code | status_description   | available_balance_after_auth | available_balance_after_stip_reversal | total_balance |
      | PURCHASE         | 10         | USD          | 100            | PKR              | 0000        | TRANSACTION_APPROVED | 900                          | 1000                                  | 1000          |
      | CASH_WITHDRAWAL  | 20         | AED          | 25.25          | PKR              | 0000        | TRANSACTION_APPROVED | 974.75                       | 1000                                  | 1000          |

  Scenario Outline: Nymcard Transaction - Debit authorization followed by one incremental transaction which is approved and the incremental transaction is later reverted by authorization advice
    Given I set the following transaction information
      | transaction_identifier | parent_transaction_identifier | network | message_type         | transaction_type   | transaction_description | rrn_identifier |
      | T1                     |                               | VISA    | AUTHORIZATION        | <transaction_type> | <transaction_type>      | RRN1           |
      | T2                     | T1                            | VISA    | AUTHORIZATION        | <transaction_type> | <transaction_type>      | RRN1           |
      | T3                     | T2                            | VISA    | AUTHORIZATION_ADVICE | <transaction_type> | <transaction_type>      | RRN1           |

    Then I set card information in the transaction context
      | transaction_identifier | card_identifier | user_identifier |
      | T1                     | CardId1         | ECPID1          |
      | T2                     | CardId1         | ECPID1          |
      | T3                     | CardId1         | ECPID1          |

    Then I set merchant information in transaction context
      | transaction_identifier | acquirer_id | merchant_id | mcc  | merchant_name | merchant_city | merchant_country | terminal_id |
      | T1                     | 136200      | SCOTIABANK  | 5999 | CAIROO        | CHATTANOOG    | USA              | 99999999    |
      | T2                     | 136200      | SCOTIABANK  | 5999 | CAIROO        | CHATTANOOG    | USA              | 99999999    |
      | T3                     | 136200      | SCOTIABANK  | 5999 | CAIROO        | CHATTANOOG    | USA              | 99999999    |

    Then I set amount information in transaction context
      | transaction_identifier | transaction_amount | transaction_currency | billing_amount        | billing_currency   |
      | T1                     | <auth_txn_amount>  | <txn_currency>       | <auth_billing_amount> | <billing_currency> |
      | T2                     | <incr_txn_amount>  | <txn_currency>       | <incr_billing_amount> | <billing_currency> |
      | T3                     | <incr_txn_amount>  | <txn_currency>       | <incr_billing_amount> | <billing_currency> |

    Then I set the following required indicators in transaction context
      | transaction_identifier | incremental_transaction | card_entry   | pos_environment | pin_present | moto  | performed_operation_type | processing_code | three_ds_indicator |
      | T1                     | false                   | DATA_ON_FILE | E_COMMERCE      | false       | false | D                        | 000000          | true               |
      | T2                     | true                    | DATA_ON_FILE | E_COMMERCE      | false       | false | D                        | 000000          | true               |
      | T3                     | true                    | DATA_ON_FILE | E_COMMERCE      | false       | false | C                        | 000000          | true               |

    When I initiate below Nymcard Transaction requests
      | transaction_identifier | status_code   | status_description   |
      | T1                     | <status_code> | <status_description> |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_after_auth> and total balance of <total_balance> for customerProfileId PKCPID1

    Then I validate TransactionLog entries for the performed Nymcard Transactions
      | transaction_identifier | fp_transaction_id | transaction_amount | billing_amount        | transaction_currency | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T1                     | VALID_UUID        | <auth_txn_amount>  | <auth_billing_amount> | <txn_currency>       | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate TransactionLogDetail entries for the performed Nymcard Transactions
      | transaction_identifier | idempotency_key | transaction_amount | billing_amount        | transaction_currency | billing_currency   | transaction_type | transaction_status |
      | T1                     | T1              | <auth_txn_amount>  | <auth_billing_amount> | <txn_currency>       | <billing_currency> | DEBIT_INITIAL    | COMPLETED          |

    When I initiate below Nymcard Transaction requests
      | transaction_identifier | status_code   | status_description   |
      | T2                     | <status_code> | <status_description> |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_after_incr> and total balance of <total_balance> for customerProfileId PKCPID1

    Then I validate TransactionLog entries for the performed Nymcard Transactions
      | transaction_identifier | fp_transaction_id | transaction_amount | billing_amount         | transaction_currency | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T2                     | VALID_UUID        | <total_txn_amount> | <total_billing_amount> | <txn_currency>       | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate TransactionLogDetail entries for the performed Nymcard Transactions
      | transaction_identifier | idempotency_key | transaction_amount | billing_amount         | transaction_currency | billing_currency   | transaction_type | transaction_status |
      | T2                     | T2              | <total_txn_amount> | <total_billing_amount> | <txn_currency>       | <billing_currency> | DEBIT_INCREMENT  | COMPLETED          |

    When I initiate below Nymcard Transaction requests
      | transaction_identifier | status_code   | status_description   |
      | T3                     | <status_code> | <status_description> |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_after_stip_reversal> and total balance of <total_balance> for customerProfileId PKCPID1

    Then I validate TransactionLog entries for the performed Nymcard Transactions
      | transaction_identifier | fp_transaction_id | transaction_amount | billing_amount        | transaction_currency | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T3                     | VALID_UUID        | <auth_txn_amount>  | <auth_billing_amount> | <txn_currency>       | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate TransactionLogDetail entries for the performed Nymcard Transactions
      | transaction_identifier | idempotency_key | transaction_amount | billing_amount        | transaction_currency | billing_currency   | transaction_type | transaction_status |
      | T3                     | T3              | <auth_txn_amount>  | <auth_billing_amount> | <txn_currency>       | <billing_currency> | DEBIT_REVERSAL   | COMPLETED          |

    Examples:
      | transaction_type | auth_txn_amount | incr_txn_amount | total_txn_amount | txn_currency | auth_billing_amount | incr_billing_amount | total_billing_amount | billing_currency | status_code | status_description   | available_balance_after_auth | available_balance_after_incr | available_balance_after_stip_reversal | total_balance |
      | PURCHASE         | 10              | 15              | 25               | USD          | 100                 | 150                 | 250                  | PKR              | 0000        | TRANSACTION_APPROVED | 900                          | 750                          | 900                                   | 1000          |
      | CASH_WITHDRAWAL  | 20              | 40              | 60               | AED          | 25.25               | 234.56              | 259.81               | PKR              | 0000        | TRANSACTION_APPROVED | 974.75                       | 740.19                       | 974.75                                | 1000          |

  Scenario Outline: Nymcard Transaction - Debit authorization rejected when billing currency is not PKR
    Given I set the following transaction information
      | transaction_identifier | network | message_type         | transaction_type   | transaction_description |
      | T1                     | VISA    | AUTHORIZATION_ADVICE | <transaction_type> | <transaction_type>      |

    Then I set card information in the transaction context
      | transaction_identifier | card_identifier | user_identifier |
      | T1                     | CardId1         | ECPID1          |

    Then I set merchant information in transaction context
      | transaction_identifier | acquirer_id | merchant_id | mcc  | merchant_name | merchant_city | merchant_country | terminal_id |
      | T1                     | 136200      | SCOTIABANK  | 5999 | CAIROO        | CHATTANOOG    | USA              | 99999999    |

    Then I set amount information in transaction context
      | transaction_identifier | transaction_amount | transaction_currency | billing_amount   | billing_currency   |
      | T1                     | <txn_amount>       | <txn_currency>       | <billing_amount> | <billing_currency> |

    Then I set the following required indicators in transaction context
      | transaction_identifier | card_entry   | pos_environment | pin_present | moto  | performed_operation_type | processing_code | three_ds_indicator |
      | T1                     | DATA_ON_FILE | E_COMMERCE      | false       | false | D                        | 000000          | true               |

    When I initiate below Nymcard Transaction requests
      | transaction_identifier | status_code   | status_description   |
      | T1                     | <status_code> | <status_description> |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance> and total balance of <total_balance> for customerProfileId PKCPID1

    Then I validate TransactionLog entries for the performed Nymcard Transactions
      | transaction_identifier | transaction_amount | billing_amount   | transaction_currency | billing_currency   | transaction_type | transaction_status |
      | T1                     | <txn_amount>       | <billing_amount> | <txn_currency>       | <billing_currency> | DEBIT_CREATE     | AUTH_DECLINED      |

    Then I validate TransactionLogDetail entries for the performed Nymcard Transactions
      | transaction_identifier | idempotency_key | transaction_amount | billing_amount   | transaction_currency | billing_currency   | transaction_type | transaction_status |
      | T1                     | T1              | <txn_amount>       | <billing_amount> | <txn_currency>       | <billing_currency> | DEBIT_INITIAL    | FAILED             |

    Examples:
      | transaction_type | txn_amount | txn_currency | billing_amount | billing_currency | status_code | status_description                      | available_balance | total_balance |
      | PURCHASE         | 10         | USD          | 100            | AED              | 1019        | TRANSACTION_NOT_PERMITTED_TO_CARDHOLDER | 1000              | 1000          |

  Scenario Outline: Nymcard Transaction - Debit authorization rejected due to invalid amounts and currencies
    Given I set the following transaction information
      | transaction_identifier | network | message_type  | transaction_type   | transaction_description |
      | T1                     | VISA    | AUTHORIZATION | <transaction_type> | <transaction_type>      |

    Then I set card information in the transaction context
      | transaction_identifier | card_identifier | user_identifier |
      | T1                     | CardId1         | ECPID1          |

    Then I set merchant information in transaction context
      | transaction_identifier | acquirer_id | merchant_id | mcc  | merchant_name | merchant_city | merchant_country | terminal_id |
      | T1                     | 136200      | SCOTIABANK  | 5999 | CAIROO        | CHATTANOOG    | USA              | 99999999    |

    Then I set amount information in transaction context
      | transaction_identifier | transaction_amount | transaction_currency | billing_amount   | billing_currency   |
      | T1                     | <txn_amount>       | <txn_currency>       | <billing_amount> | <billing_currency> |

    Then I set the following required indicators in transaction context
      | transaction_identifier | card_entry   | pos_environment | pin_present | moto  | performed_operation_type | processing_code | three_ds_indicator |
      | T1                     | DATA_ON_FILE | E_COMMERCE      | false       | false | D                        | 000000          | true               |

    When I initiate below Nymcard Transaction requests
      | transaction_identifier | status_code   | status_description   |
      | T1                     | <status_code> | <status_description> |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance> and total balance of <total_balance> for customerProfileId PKCPID1

    Examples:
      | transaction_type | txn_amount | txn_currency | billing_amount | billing_currency | status_code | status_description | available_balance | total_balance |
      | PURCHASE         | 0          | USD          | 100            | AED              | 1802        | MISSING_FIELDS     | 1000              | 1000          |
      | CASH_WITHDRAWAL  | 10         | USD          | -100           | PKR              | 1802        | MISSING_FIELDS     | 1000              | 1000          |
      | CASH_WITHDRAWAL  | 10         | USD          | 100            | PKS              | 1802        | MISSING_FIELDS     | 1000              | 1000          |

  Scenario Outline: Nymcard Transaction - Simple financial authorization
    Given I set the following transaction information
      | transaction_identifier | network | message_type   | transaction_type   | transaction_description |
      | T1                     | VISA    | <message_type> | <transaction_type> | <transaction_type>      |

    Then I set card information in the transaction context
      | transaction_identifier | card_identifier | user_identifier |
      | T1                     | CardId1         | ECPID1          |

    Then I set merchant information in transaction context
      | transaction_identifier | acquirer_id | merchant_id | mcc  | merchant_name | merchant_city | merchant_country | terminal_id |
      | T1                     | 136200      | SCOTIABANK  | 5999 | CAIROO        | CHATTANOOG    | USA              | 99999999    |

    Then I set amount information in transaction context
      | transaction_identifier | transaction_amount | transaction_currency | billing_amount   | billing_currency   |
      | T1                     | <txn_amount>       | <txn_currency>       | <billing_amount> | <billing_currency> |

    Then I set the following required indicators in transaction context
      | transaction_identifier | card_entry   | pos_environment | pin_present | moto  | performed_operation_type | processing_code | three_DS_indicator |
      | T1                     | DATA_ON_FILE | E_COMMERCE      | false       | false | D                        | 000000          | true               |

    When I initiate below Nymcard Transaction requests
      | transaction_identifier | clearing_ts | status_code   | status_description   |
      | T1                     | T+m30       | <status_code> | <status_description> |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance> and total balance of <total_balance> for customerProfileId PKCPID1

    Then I validate TransactionLog entries for the performed Nymcard Transactions
      | transaction_identifier | fp_transaction_id | transaction_amount | billing_amount   | transaction_currency | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T1                     | VALID_UUID        | <txn_amount>       | <billing_amount> | <txn_currency>       | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate TransactionLogDetail entries for the performed Nymcard Transactions
      | transaction_identifier | idempotency_key | transaction_amount | billing_amount   | transaction_currency | billing_currency   | transaction_type | transaction_status |
      | T1                     | T1              | <txn_amount>       | <billing_amount> | <txn_currency>       | <billing_currency> | DEBIT_INITIAL    | COMPLETED          |

    Examples:
      | message_type     | transaction_type | txn_amount | txn_currency | billing_amount | billing_currency | status_code | status_description   | available_balance | total_balance |
      | FINANCIAL        | PURCHASE         | 102.32     | USD          | 999.99         | PKR              | 0000        | TRANSACTION_APPROVED | 0.01              | 1000          |
      | FINANCIAL        | PURCHASE         | 422.96     | SGD          | 503.21         | PKR              | 0000        | TRANSACTION_APPROVED | 496.79            | 1000          |
      | FINANCIAL        | PURCHASE         | 3842.98    | AED          | 1000.00        | PKR              | 0000        | TRANSACTION_APPROVED | 0                 | 1000          |
      | FINANCIAL_ADVICE | PURCHASE         | 4321.23    | CHF          | 1000.00        | PKR              | 0000        | TRANSACTION_APPROVED | 0                 | 1000          |
      | FINANCIAL_ADVICE | PURCHASE         | 296.30     | GBP          | 1002.01        | PKR              | 0000        | TRANSACTION_APPROVED | -2.01             | 1000          |
      | FINANCIAL_ADVICE | PURCHASE         | 1296.29    | JPY          | 999.98         | PKR              | 0000        | TRANSACTION_APPROVED | 0.02              | 1000          |

  Scenario Outline: Nymcard Transaction - Debit authorization followed by one partial reversal
    Given I set the following transaction information
      | transaction_identifier | parent_transaction_identifier | network | message_type                    | transaction_type   | transaction_description | rrn_identifier |
      | T1                     |                               | VISA    | <auth_message_type>             | <transaction_type> | <transaction_type>      | RRN1           |
      | T2                     | T1                            | VISA    | <partial_reversal_message_type> | <transaction_type> | <transaction_type>      | RRN1           |

    Then I set card information in the transaction context
      | transaction_identifier | card_identifier | user_identifier |
      | T1                     | CardId1         | ECPID1          |
      | T2                     | CardId1         | ECPID1          |

    Then I set merchant information in transaction context
      | transaction_identifier | acquirer_id | merchant_id | mcc  | merchant_name | merchant_city | merchant_country | terminal_id |
      | T1                     | 136200      | SCOTIABANK  | 5999 | CAIROO        | CHATTANOOG    | USA              | 99999999    |
      | T2                     | 136200      | SCOTIABANK  | 5999 | CAIROO        | CHATTANOOG    | USA              | 99999999    |

    Then I set amount information in transaction context
      | transaction_identifier | transaction_amount | original_transaction_amount   | transaction_currency | billing_amount        | original_billing_amount           | billing_currency   |
      | T1                     | <auth_txn_amount>  | 0                             | <txn_currency>       | <auth_billing_amount> | 0                                 | <billing_currency> |
      | T2                     | <auth_txn_amount>  | <partial_reversal_txn_amount> | <txn_currency>       | <auth_billing_amount> | <partial_reversal_billing_amount> | <billing_currency> |

    Then I set the following required indicators in transaction context
      | transaction_identifier | card_entry   | pos_environment | pin_present | moto  | performed_operation_type | processing_code | three_ds_indicator |
      | T1                     | DATA_ON_FILE | E_COMMERCE      | false       | false | D                        | 000000          | true               |
      | T2                     | DATA_ON_FILE | E_COMMERCE      | false       | false | C                        | 000000          | true               |

    When I initiate below Nymcard Transaction requests
      | transaction_identifier | status_code        | status_description        |
      | T1                     | <auth_status_code> | <auth_status_description> |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_after_auth> and total balance of <total_balance> for customerProfileId PKCPID1

    Then I validate TransactionLog entries for the performed Nymcard Transactions
      | transaction_identifier | fp_transaction_id | transaction_amount | billing_amount        | transaction_currency | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T1                     | VALID_UUID        | <auth_txn_amount>  | <auth_billing_amount> | <txn_currency>       | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate TransactionLogDetail entries for the performed Nymcard Transactions
      | transaction_identifier | idempotency_key | transaction_amount | billing_amount        | transaction_currency | billing_currency   | transaction_type | transaction_status |
      | T1                     | T1              | <auth_txn_amount>  | <auth_billing_amount> | <txn_currency>       | <billing_currency> | DEBIT_INITIAL    | COMPLETED          |

    When I initiate below Nymcard Transaction requests
      | transaction_identifier | status_code                    | status_description                    |
      | T2                     | <partial_reversal_status_code> | <partial_reversal_status_description> |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_after_partial_reversal> and total balance of <total_balance> for customerProfileId PKCPID1

    Then I validate TransactionLog entries for the performed Nymcard Transactions
      | transaction_identifier | fp_transaction_id | transaction_amount | billing_amount         | transaction_currency | billing_currency   | transaction_type | transaction_status                            | release_auth_ts | release_type     |
      | T2                     | VALID_UUID        | <total_txn_amount> | <total_billing_amount> | <txn_currency>       | <billing_currency> | DEBIT_CREATE     | <partial_reversal_txn_log_transaction_status> | T+30            | SCHEDULED_EXPIRY |

    Then I validate TransactionLogDetail entries for the performed Nymcard Transactions
      | transaction_identifier | idempotency_key | transaction_amount | billing_amount         | transaction_currency | billing_currency   | transaction_type                                   | transaction_status |
      | T2                     | T2              | <total_txn_amount> | <total_billing_amount> | <txn_currency>       | <billing_currency> | <partial_reversal_txn_log_detail_transaction_type> | COMPLETED          |

    Examples:
      | auth_message_type    | partial_reversal_message_type | transaction_type | auth_txn_amount | partial_reversal_txn_amount | total_txn_amount | txn_currency | auth_billing_amount | partial_reversal_billing_amount | total_billing_amount | billing_currency | auth_status_code | auth_status_description | partial_reversal_status_code | partial_reversal_status_description | partial_reversal_txn_log_transaction_status | partial_reversal_txn_log_detail_transaction_type | available_balance_after_auth | available_balance_after_partial_reversal | total_balance |
      | AUTHORIZATION        | REVERSAL_ADVICE               | PURCHASE         | 876.54          | 702.95                      | 702.95           | SGD          | 529.65              | 361.67                          | 361.67               | PKR              | 0000             | TRANSACTION_APPROVED    | 0000                         | TRANSACTION_APPROVED                | AUTH_ACQUIRED                               | DEBIT_REVERSAL                                   | 470.35                       | 638.33                                   | 1000          |
      | AUTHORIZATION        | REVERSAL                      | PURCHASE         | 250             | 50                          | 50               | USD          | 1000                | 999.99                          | 999.99               | PKR              | 0000             | TRANSACTION_APPROVED    | 0000                         | TRANSACTION_APPROVED                | AUTH_ACQUIRED                               | DEBIT_REVERSAL                                   | 0                            | 0.01                                     | 1000          |
      | AUTHORIZATION        | REVERSAL_ADVICE               | CASH_WITHDRAWAL  | 700             | 200                         | 200              | EUR          | 1000                | 0.01                            | 0.01                 | PKR              | 0000             | TRANSACTION_APPROVED    | 0000                         | TRANSACTION_APPROVED                | AUTH_ACQUIRED                               | DEBIT_REVERSAL                                   | 0                            | 999.99                                   | 1000          |
      | AUTHORIZATION        | REVERSAL_ADVICE               | CASH_WITHDRAWAL  | 1000            | 100                         | 100              | GBP          | 1000                | 0                               | 0                    | PKR              | 0000             | TRANSACTION_APPROVED    | 0000                         | TRANSACTION_APPROVED                | TRANSACTION_REVERTED                        | DEBIT_REVERSAL                                   | 0                            | 1000                                     | 1000          |
      | AUTHORIZATION        | REVERSAL                      | PURCHASE         | 150             | 155                         | 155              | CHF          | 999.99              | 0                               | 0                    | PKR              | 0000             | TRANSACTION_APPROVED    | 0000                         | TRANSACTION_APPROVED                | TRANSACTION_REVERTED                        | DEBIT_REVERSAL                                   | 0.01                         | 1000                                     | 1000          |
      | AUTHORIZATION        | REVERSAL                      | PURCHASE         | 456             | 765                         | 765              | GBP          | 0.01                | 0                               | 0                    | PKR              | 0000             | TRANSACTION_APPROVED    | 0000                         | TRANSACTION_APPROVED                | TRANSACTION_REVERTED                        | DEBIT_REVERSAL                                   | 999.99                       | 1000                                     | 1000          |
      | AUTHORIZATION_ADVICE | REVERSAL                      | PURCHASE         | 830             | 782                         | 782              | AOA          | 1386                | 825.61                          | 825.61               | PKR              | 0000             | TRANSACTION_APPROVED    | 0000                         | TRANSACTION_APPROVED                | AUTH_ACQUIRED                               | DEBIT_REVERSAL                                   | -386                         | 174.39                                   | 1000          |
      | AUTHORIZATION        | REVERSAL                      | PURCHASE         | 5038.67         | 8259.53                     | 8259.53          | BBD          | 410.89              | 518.92                          | 518.92               | PKR              | 0000             | TRANSACTION_APPROVED    | 0000                         | TRANSACTION_APPROVED                | AUTH_ACQUIRED                               | DEBIT_INCREMENT                                  | 589.11                       | 481.08                                   | 1000          |
      | AUTHORIZATION        | REVERSAL_ADVICE               | PURCHASE         | 474.53          | 632.94                      | 632.94           | BMD          | 810.45              | 1076.24                         | 1076.24              | PKR              | 0000             | TRANSACTION_APPROVED    | 0000                         | TRANSACTION_APPROVED                | AUTH_ACQUIRED                               | DEBIT_INCREMENT                                  | 189.55                       | -76.24                                   | 1000          |
      | AUTHORIZATION_ADVICE | REVERSAL_ADVICE               | PURCHASE         | 2185.93         | 1849                        | 1849             | CUC          | 2943.42             | 1429.38                         | 1429.38              | PKR              | 0000             | TRANSACTION_APPROVED    | 0000                         | TRANSACTION_APPROVED                | AUTH_ACQUIRED                               | DEBIT_REVERSAL                                   | -1943.42                     | -429.38                                  | 1000          |
      | AUTHORIZATION_ADVICE | REVERSAL_ADVICE               | PURCHASE         | 904.18          | 4810.48                     | 4810.48          | ERN          | 4821.58             | 8918.38                         | 8918.38              | PKR              | 0000             | TRANSACTION_APPROVED    | 0000                         | TRANSACTION_APPROVED                | AUTH_ACQUIRED                               | DEBIT_INCREMENT                                  | -3821.58                     | -7918.38                                 | 1000          |

  Scenario Outline: Nymcard Transaction - Debit authorization followed by full reversal
    Given I set the following transaction information
      | transaction_identifier | parent_transaction_identifier | network | message_type                 | transaction_type   | transaction_description | rrn_identifier |
      | T1                     |                               | VISA    | <auth_message_type>          | <transaction_type> | <transaction_type>      | RRN1           |
      | T2                     | T1                            | VISA    | <full_reversal_message_type> | <transaction_type> | <transaction_type>      | RRN1           |

    Then I set card information in the transaction context
      | transaction_identifier | card_identifier | user_identifier |
      | T1                     | CardId1         | ECPID1          |
      | T2                     | CardId1         | ECPID1          |

    Then I set merchant information in transaction context
      | transaction_identifier | acquirer_id | merchant_id | mcc  | merchant_name | merchant_city | merchant_country | terminal_id |
      | T1                     | 136200      | SCOTIABANK  | 5999 | CAIROO        | CHATTANOOG    | USA              | 99999999    |
      | T2                     | 136200      | SCOTIABANK  | 5999 | CAIROO        | CHATTANOOG    | USA              | 99999999    |

    Then I set amount information in transaction context
      | transaction_identifier | transaction_amount         | transaction_currency | billing_amount                 | billing_currency   |
      | T1                     | <auth_txn_amount>          | <txn_currency>       | <auth_billing_amount>          | <billing_currency> |
      | T2                     | <full_reversal_txn_amount> | <txn_currency>       | <full_reversal_billing_amount> | <billing_currency> |

    Then I set the following required indicators in transaction context
      | transaction_identifier | card_entry   | pos_environment | pin_present | moto  | performed_operation_type | processing_code | three_ds_indicator |
      | T1                     | DATA_ON_FILE | E_COMMERCE      | false       | false | D                        | 000000          | true               |
      | T2                     | DATA_ON_FILE | E_COMMERCE      | false       | false | C                        | 000000          | true               |

    When I initiate below Nymcard Transaction requests
      | transaction_identifier | status_code        | status_description        |
      | T1                     | <auth_status_code> | <auth_status_description> |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_after_auth> and total balance of <total_balance> for customerProfileId PKCPID1

    Then I validate TransactionLog entries for the performed Nymcard Transactions
      | transaction_identifier | fp_transaction_id | transaction_amount | billing_amount        | transaction_currency | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T1                     | VALID_UUID        | <auth_txn_amount>  | <auth_billing_amount> | <txn_currency>       | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate TransactionLogDetail entries for the performed Nymcard Transactions
      | transaction_identifier | idempotency_key | transaction_amount | billing_amount        | transaction_currency | billing_currency   | transaction_type | transaction_status |
      | T1                     | T1              | <auth_txn_amount>  | <auth_billing_amount> | <txn_currency>       | <billing_currency> | DEBIT_INITIAL    | COMPLETED          |

    When I initiate below Nymcard Transaction requests
      | transaction_identifier | status_code                 | status_description                 |
      | T2                     | <full_reversal_status_code> | <full_reversal_status_description> |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_after_full_reversal> and total balance of <total_balance> for customerProfileId PKCPID1

    Then I validate TransactionLog entries for the performed Nymcard Transactions
      | transaction_identifier | fp_transaction_id | transaction_amount | billing_amount         | transaction_currency | billing_currency   | transaction_type | transaction_status   | release_auth_ts | release_type     |
      | T2                     | VALID_UUID        | <total_txn_amount> | <total_billing_amount> | <txn_currency>       | <billing_currency> | DEBIT_CREATE     | TRANSACTION_REVERTED | T+30            | SCHEDULED_EXPIRY |

    Then I validate TransactionLogDetail entries for the performed Nymcard Transactions
      | transaction_identifier | idempotency_key | transaction_amount | billing_amount         | transaction_currency | billing_currency   | transaction_type | transaction_status |
      | T2                     | T2              | <total_txn_amount> | <total_billing_amount> | <txn_currency>       | <billing_currency> | DEBIT_REVERSAL   | COMPLETED          |

    Examples:
      | auth_message_type    | full_reversal_message_type | transaction_type | auth_txn_amount | full_reversal_txn_amount | total_txn_amount | txn_currency | auth_billing_amount | full_reversal_billing_amount | total_billing_amount | billing_currency | auth_status_code | auth_status_description | full_reversal_status_code | full_reversal_status_description |  | available_balance_after_auth | available_balance_after_full_reversal | total_balance |
      | AUTHORIZATION        | REVERSAL_ADVICE            | PURCHASE         | 783.54          | 783.54                   | 0                | SGD          | 245.67              | 245.67                       | 0                    | PKR              | 0000             | TRANSACTION_APPROVED    | 0000                      | TRANSACTION_APPROVED             |  | 754.33                       | 1000                                  | 1000          |
      | AUTHORIZATION        | REVERSAL                   | PURCHASE         | 2495            | 2395                     | 0                | USD          | 1000                | 1000                         | 0                    | PKR              | 0000             | TRANSACTION_APPROVED    | 0000                      | TRANSACTION_APPROVED             |  | 0                            | 1000                                  | 1000          |
      | AUTHORIZATION        | REVERSAL_ADVICE            | CASH_WITHDRAWAL  | 398.12          | 1023.45                  | 0                | EUR          | 999.99              | 999.99                       | 0                    | PKR              | 0000             | TRANSACTION_APPROVED    | 0000                      | TRANSACTION_APPROVED             |  | 0.01                         | 1000                                  | 1000          |
      | AUTHORIZATION        | REVERSAL_ADVICE            | CASH_WITHDRAWAL  | 234.56          | 987.65                   | 0                | GBP          | 0.01                | 0.01                         | 0                    | PKR              | 0000             | TRANSACTION_APPROVED    | 0000                      | TRANSACTION_APPROVED             |  | 999.99                       | 1000                                  | 1000          |
      | AUTHORIZATION_ADVICE | REVERSAL                   | PURCHASE         | 4789.90         | 1067.33                  | 0                | CHF          | 1432.42             | 1432.42                      | 0                    | PKR              | 0000             | TRANSACTION_APPROVED    | 0000                      | TRANSACTION_APPROVED             |  | -432.42                      | 1000                                  | 1000          |
      | AUTHORIZATION_ADVICE | REVERSAL_ADVICE            | PURCHASE         | 820.48          | 540.60                   | 0                | ERN          | 5321.64             | 5321.64                      | 0                    | PKR              | 0000             | TRANSACTION_APPROVED    | 0000                      | TRANSACTION_APPROVED             |  | -4321.64                     | 1000                                  | 1000          |

  Scenario Outline: Nymcard Transaction - Debit authorization followed by an incremental and a partial reversal
    Given I set the following transaction information
      | transaction_identifier | parent_transaction_identifier | network | message_type                    | transaction_type   | transaction_description | rrn_identifier |
      | T1                     |                               | VISA    | <auth_message_type>             | <transaction_type> | <transaction_type>      | RRN1           |
      | T2                     | T1                            | VISA    | <incr_message_type>             | <transaction_type> | <transaction_type>      | RRN1           |
      | T3                     | T1                            | VISA    | <partial_reversal_message_type> | <transaction_type> | <transaction_type>      | RRN1           |

    Then I set card information in the transaction context
      | transaction_identifier | card_identifier | user_identifier |
      | T1                     | CardId1         | ECPID1          |
      | T2                     | CardId1         | ECPID1          |
      | T3                     | CardId1         | ECPID1          |

    Then I set merchant information in transaction context
      | transaction_identifier | acquirer_id | merchant_id | mcc  | merchant_name | merchant_city | merchant_country | terminal_id |
      | T1                     | 136200      | SCOTIABANK  | 5999 | CAIROO        | CHATTANOOG    | USA              | 99999999    |
      | T2                     | 136200      | SCOTIABANK  | 5999 | CAIROO        | CHATTANOOG    | USA              | 99999999    |
      | T3                     | 136200      | SCOTIABANK  | 5999 | CAIROO        | CHATTANOOG    | USA              | 99999999    |

    Then I set amount information in transaction context
      | transaction_identifier | transaction_amount      | original_transaction_amount   | transaction_currency | billing_amount              | original_billing_amount           | billing_currency   |
      | T1                     | <auth_txn_amount>       | 0                             | <txn_currency>       | <auth_billing_amount>       | 0                                 | <billing_currency> |
      | T2                     | <incr_txn_amount>       | 0                             | <txn_currency>       | <incr_billing_amount>       | 0                                 | <billing_currency> |
      | T3                     | <txn_amount_after_incr> | <partial_reversal_txn_amount> | <txn_currency>       | <billing_amount_after_incr> | <partial_reversal_billing_amount> | <billing_currency> |

    Then I set the following required indicators in transaction context
      | transaction_identifier | card_entry   | pos_environment | pin_present | moto  | performed_operation_type | incremental_transaction | processing_code | three_ds_indicator |
      | T1                     | DATA_ON_FILE | E_COMMERCE      | false       | false | D                        | false                   | 000000          | true               |
      | T2                     | DATA_ON_FILE | E_COMMERCE      | false       | false | D                        | true                    | 000000          | true               |
      | T3                     | DATA_ON_FILE | E_COMMERCE      | false       | false | C                        | false                   | 000000          | true               |

    When I initiate below Nymcard Transaction requests
      | transaction_identifier | status_code        | status_description        |
      | T1                     | <auth_status_code> | <auth_status_description> |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_after_auth> and total balance of <total_balance> for customerProfileId PKCPID1

    Then I validate TransactionLog entries for the performed Nymcard Transactions
      | transaction_identifier | fp_transaction_id | transaction_amount | billing_amount        | transaction_currency | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T1                     | VALID_UUID        | <auth_txn_amount>  | <auth_billing_amount> | <txn_currency>       | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate TransactionLogDetail entries for the performed Nymcard Transactions
      | transaction_identifier | idempotency_key | transaction_amount | billing_amount        | transaction_currency | billing_currency   | transaction_type | transaction_status |
      | T1                     | T1              | <auth_txn_amount>  | <auth_billing_amount> | <txn_currency>       | <billing_currency> | DEBIT_INITIAL    | COMPLETED          |

    When I initiate below Nymcard Transaction requests
      | transaction_identifier | status_code        | status_description        |
      | T2                     | <incr_status_code> | <incr_status_description> |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_after_incr> and total balance of <total_balance> for customerProfileId PKCPID1

    Then I validate TransactionLog entries for the performed Nymcard Transactions
      | transaction_identifier | fp_transaction_id | transaction_amount      | billing_amount              | transaction_currency | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T2                     | VALID_UUID        | <txn_amount_after_incr> | <billing_amount_after_incr> | <txn_currency>       | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate TransactionLogDetail entries for the performed Nymcard Transactions
      | transaction_identifier | idempotency_key | transaction_amount      | billing_amount              | transaction_currency | billing_currency   | transaction_type | transaction_status |
      | T2                     | T2              | <txn_amount_after_incr> | <billing_amount_after_incr> | <txn_currency>       | <billing_currency> | DEBIT_INCREMENT  | COMPLETED          |

    When I initiate below Nymcard Transaction requests
      | transaction_identifier | status_code                    | status_description                    |
      | T3                     | <partial_reversal_status_code> | <partial_reversal_status_description> |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_after_partial_reversal> and total balance of <total_balance> for customerProfileId PKCPID1

    Then I validate TransactionLog entries for the performed Nymcard Transactions
      | transaction_identifier | fp_transaction_id | transaction_amount | billing_amount         | transaction_currency | billing_currency   | transaction_type | transaction_status                            | release_auth_ts | release_type     |
      | T3                     | VALID_UUID        | <total_txn_amount> | <total_billing_amount> | <txn_currency>       | <billing_currency> | DEBIT_CREATE     | <partial_reversal_txn_log_transaction_status> | T+30            | SCHEDULED_EXPIRY |

    Then I validate TransactionLogDetail entries for the performed Nymcard Transactions
      | transaction_identifier | idempotency_key | transaction_amount | billing_amount         | transaction_currency | billing_currency   | transaction_type                                   | transaction_status |
      | T3                     | T3              | <total_txn_amount> | <total_billing_amount> | <txn_currency>       | <billing_currency> | <partial_reversal_txn_log_detail_transaction_type> | COMPLETED          |

    Examples:
      | auth_message_type    | incr_message_type    | partial_reversal_message_type | transaction_type | auth_txn_amount | incr_txn_amount | partial_reversal_txn_amount | txn_amount_after_incr | total_txn_amount | txn_currency | auth_billing_amount | incr_billing_amount | partial_reversal_billing_amount | billing_amount_after_incr | total_billing_amount | billing_currency | auth_status_code | auth_status_description | incr_status_code | incr_status_description | partial_reversal_status_code | partial_reversal_status_description | partial_reversal_txn_log_transaction_status | partial_reversal_txn_log_detail_transaction_type | available_balance_after_auth | available_balance_after_incr | available_balance_after_partial_reversal | total_balance |
      | AUTHORIZATION        | AUTHORIZATION        | REVERSAL                      | PURCHASE         | 820             | 340             | 540                         | 1160                  | 540              | ERN          | 575                 | 200                 | 650                             | 775                       | 650                  | PKR              | 0000             | TRANSACTION_APPROVED    | 0000             | TRANSACTION_APPROVED    | 0000                         | TRANSACTION_APPROVED                | AUTH_ACQUIRED                               | DEBIT_REVERSAL                                   | 425                          | 225                          | 350                                      | 1000          |
      | AUTHORIZATION        | AUTHORIZATION        | REVERSAL_ADVICE               | PURCHASE         | 820             | 340             | 540                         | 1160                  | 540              | ERN          | 250                 | 500                 | 1250                            | 750                       | 1250                 | PKR              | 0000             | TRANSACTION_APPROVED    | 0000             | TRANSACTION_APPROVED    | 0000                         | TRANSACTION_APPROVED                | AUTH_ACQUIRED                               | DEBIT_INCREMENT                                  | 750                          | 250                          | -250                                     | 1000          |
      | AUTHORIZATION        | AUTHORIZATION_ADVICE | REVERSAL_ADVICE               | PURCHASE         | 100             | 50              | 20                          | 150                   | 20               | USD          | 820                 | 220                 | 1500                            | 1040                      | 1500                 | PKR              | 0000             | TRANSACTION_APPROVED    | 0000             | TRANSACTION_APPROVED    | 0000                         | TRANSACTION_APPROVED                | AUTH_ACQUIRED                               | DEBIT_INCREMENT                                  | 180                          | -40                          | -500                                     | 1000          |
      | AUTHORIZATION_ADVICE | AUTHORIZATION_ADVICE | REVERSAL_ADVICE               | PURCHASE         | 500             | 400             | 700                         | 900                   | 700              | GBP          | 1450                | 1200                | 4000                            | 2650                      | 4000                 | PKR              | 0000             | TRANSACTION_APPROVED    | 0000             | TRANSACTION_APPROVED    | 0000                         | TRANSACTION_APPROVED                | AUTH_ACQUIRED                               | DEBIT_INCREMENT                                  | -450                         | -1650                        | -3000                                    | 1000          |
      | AUTHORIZATION_ADVICE | AUTHORIZATION_ADVICE | REVERSAL_ADVICE               | PURCHASE         | 1500            | 1000            | 500                         | 2500                  | 500              | JPY          | 1500                | 1000                | 2000                            | 2500                      | 2000                 | PKR              | 0000             | TRANSACTION_APPROVED    | 0000             | TRANSACTION_APPROVED    | 0000                         | TRANSACTION_APPROVED                | AUTH_ACQUIRED                               | DEBIT_REVERSAL                                   | -500                         | -1500                        | -1000                                    | 1000          |
      | AUTHORIZATION_ADVICE | AUTHORIZATION_ADVICE | REVERSAL                      | PURCHASE         | 1200            | 500             | 300                         | 1700                  | 300              | EUR          | 1200                | 500                 | 1000                            | 1700                      | 1000                 | PKR              | 0000             | TRANSACTION_APPROVED    | 0000             | TRANSACTION_APPROVED    | 0000                         | TRANSACTION_APPROVED                | AUTH_ACQUIRED                               | DEBIT_REVERSAL                                   | -200                         | -700                         | 0                                        | 1000          |
      | AUTHORIZATION        | AUTHORIZATION_ADVICE | REVERSAL                      | PURCHASE         | 500             | 800             | 300                         | 1300                  | 300              | USD          | 500                 | 800                 | 500                             | 1300                      | 500                  | PKR              | 0000             | TRANSACTION_APPROVED    | 0000             | TRANSACTION_APPROVED    | 0000                         | TRANSACTION_APPROVED                | AUTH_ACQUIRED                               | DEBIT_REVERSAL                                   | 500                          | -300                         | 500                                      | 1000          |
      | AUTHORIZATION_ADVICE | AUTHORIZATION_ADVICE | REVERSAL                      | PURCHASE         | 1500            | 500             | 1000                        | 2000                  | 1000             | GBP          | 1500                | 500                 | 500                             | 2000                      | 500                  | PKR              | 0000             | TRANSACTION_APPROVED    | 0000             | TRANSACTION_APPROVED    | 0000                         | TRANSACTION_APPROVED                | AUTH_ACQUIRED                               | DEBIT_REVERSAL                                   | -500                         | -1000                        | 500                                      | 1000          |
      | AUTHORIZATION_ADVICE | AUTHORIZATION_ADVICE | REVERSAL                      | PURCHASE         | 2000            | 300             | 0                           | 2300                  | 0                | USD          | 2000                | 300                 | 0                               | 2300                      | 0                    | PKR              | 0000             | TRANSACTION_APPROVED    | 0000             | TRANSACTION_APPROVED    | 0000                         | TRANSACTION_APPROVED                | TRANSACTION_REVERTED                        | DEBIT_REVERSAL                                   | -1000                        | -1300                        | 1000                                     | 1000          |
      | AUTHORIZATION        | AUTHORIZATION_ADVICE | REVERSAL_ADVICE               | PURCHASE         | 400             | 800             | 600                         | 1200                  | 600              | AUD          | 400                 | 800                 | 600                             | 1200                      | 600                  | PKR              | 0000             | TRANSACTION_APPROVED    | 0000             | TRANSACTION_APPROVED    | 0000                         | TRANSACTION_APPROVED                | AUTH_ACQUIRED                               | DEBIT_REVERSAL                                   | 600                          | -200                         | 400                                      | 1000          |

  Scenario Outline: Nymcard Transaction - Debit authorization followed by a partial reversal and then a full reversal
    Given I set the following transaction information
      | transaction_identifier | parent_transaction_identifier | network | message_type                    | transaction_type   | transaction_description | rrn_identifier |
      | T1                     |                               | VISA    | <auth_message_type>             | <transaction_type> | <transaction_type>      | RRN1           |
      | T2                     | T1                            | VISA    | <partial_reversal_message_type> | <transaction_type> | <transaction_type>      | RRN1           |
      | T3                     | T1                            | VISA    | <full_reversal_message_type>    | <transaction_type> | <transaction_type>      | RRN1           |

    Then I set card information in the transaction context
      | transaction_identifier | card_identifier | user_identifier |
      | T1                     | CardId1         | ECPID1          |
      | T2                     | CardId1         | ECPID1          |
      | T3                     | CardId1         | ECPID1          |

    Then I set merchant information in transaction context
      | transaction_identifier | acquirer_id | merchant_id | mcc  | merchant_name | merchant_city | merchant_country | terminal_id |
      | T1                     | 136200      | SCOTIABANK  | 5999 | CAIROO        | CHATTANOOG    | USA              | 99999999    |
      | T2                     | 136200      | SCOTIABANK  | 5999 | CAIROO        | CHATTANOOG    | USA              | 99999999    |
      | T3                     | 136200      | SCOTIABANK  | 5999 | CAIROO        | CHATTANOOG    | USA              | 99999999    |

    Then I set amount information in transaction context
      | transaction_identifier | transaction_amount                  | original_transaction_amount   | transaction_currency | billing_amount                          | original_billing_amount           | billing_currency   |
      | T1                     | <auth_txn_amount>                   | 0                             | <txn_currency>       | <auth_billing_amount>                   | 0                                 | <billing_currency> |
      | T2                     | <auth_txn_amount>                   | <partial_reversal_txn_amount> | <txn_currency>       | <auth_billing_amount>                   | <partial_reversal_billing_amount> | <billing_currency> |
      | T3                     | <txn_amount_after_partial_reversal> | 0                             | <txn_currency>       | <billing_amount_after_partial_reversal> | 0                                 | <billing_currency> |

    Then I set the following required indicators in transaction context
      | transaction_identifier | card_entry   | pos_environment | pin_present | moto  | performed_operation_type | processing_code | three_ds_indicator |
      | T1                     | DATA_ON_FILE | E_COMMERCE      | false       | false | D                        | 000000          | true               |
      | T2                     | DATA_ON_FILE | E_COMMERCE      | false       | false | C                        | 000000          | true               |
      | T3                     | DATA_ON_FILE | E_COMMERCE      | false       | false | C                        | 000000          | true               |

    When I initiate below Nymcard Transaction requests
      | transaction_identifier | status_code        | status_description        |
      | T1                     | <auth_status_code> | <auth_status_description> |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_after_auth> and total balance of <total_balance> for customerProfileId PKCPID1

    Then I validate TransactionLog entries for the performed Nymcard Transactions
      | transaction_identifier | fp_transaction_id | transaction_amount | billing_amount        | transaction_currency | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T1                     | VALID_UUID        | <auth_txn_amount>  | <auth_billing_amount> | <txn_currency>       | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate TransactionLogDetail entries for the performed Nymcard Transactions
      | transaction_identifier | idempotency_key | transaction_amount | billing_amount        | transaction_currency | billing_currency   | transaction_type | transaction_status |
      | T1                     | T1              | <auth_txn_amount>  | <auth_billing_amount> | <txn_currency>       | <billing_currency> | DEBIT_INITIAL    | COMPLETED          |

    When I initiate below Nymcard Transaction requests
      | transaction_identifier | status_code                    | status_description                    |
      | T2                     | <partial_reversal_status_code> | <partial_reversal_status_description> |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_after_partial_reversal> and total balance of <total_balance> for customerProfileId PKCPID1

    Then I validate TransactionLog entries for the performed Nymcard Transactions
      | transaction_identifier | fp_transaction_id | transaction_amount                  | billing_amount                          | transaction_currency | billing_currency   | transaction_type | transaction_status                            | release_auth_ts | release_type     |
      | T2                     | VALID_UUID        | <txn_amount_after_partial_reversal> | <billing_amount_after_partial_reversal> | <txn_currency>       | <billing_currency> | DEBIT_CREATE     | <partial_reversal_txn_log_transaction_status> | T+30            | SCHEDULED_EXPIRY |

    Then I validate TransactionLogDetail entries for the performed Nymcard Transactions
      | transaction_identifier | idempotency_key | transaction_amount                  | billing_amount                          | transaction_currency | billing_currency   | transaction_type                                   | transaction_status |
      | T2                     | T2              | <txn_amount_after_partial_reversal> | <billing_amount_after_partial_reversal> | <txn_currency>       | <billing_currency> | <partial_reversal_txn_log_detail_transaction_type> | COMPLETED          |

    When I initiate below Nymcard Transaction requests
      | transaction_identifier | status_code                 | status_description                 |
      | T3                     | <full_reversal_status_code> | <full_reversal_status_description> |

    Then I wait until max time to verify bank account BankAccId with an available balance of 1000 and total balance of <total_balance> for customerProfileId PKCPID1

    Then I validate TransactionLog entries for the performed Nymcard Transactions
      | transaction_identifier | fp_transaction_id | transaction_amount | billing_amount         | transaction_currency | billing_currency   | transaction_type | transaction_status   | release_auth_ts | release_type     |
      | T3                     | VALID_UUID        | <total_txn_amount> | <total_billing_amount> | <txn_currency>       | <billing_currency> | DEBIT_CREATE     | TRANSACTION_REVERTED | T+30            | SCHEDULED_EXPIRY |

    Then I validate TransactionLogDetail entries for the performed Nymcard Transactions
      | transaction_identifier | idempotency_key | transaction_amount | billing_amount         | transaction_currency | billing_currency   | transaction_type | transaction_status |
      | T3                     | T3              | <total_txn_amount> | <total_billing_amount> | <txn_currency>       | <billing_currency> | DEBIT_REVERSAL   | COMPLETED          |

    Examples:
      | auth_message_type    | partial_reversal_message_type | full_reversal_message_type | transaction_type | auth_txn_amount | partial_reversal_txn_amount | txn_amount_after_partial_reversal | total_txn_amount | txn_currency | auth_billing_amount | partial_reversal_billing_amount | billing_amount_after_partial_reversal | total_billing_amount | billing_currency | auth_status_code | auth_status_description | partial_reversal_status_code | partial_reversal_status_description | full_reversal_status_code | full_reversal_status_description | partial_reversal_txn_log_transaction_status | partial_reversal_txn_log_detail_transaction_type | available_balance_after_auth | available_balance_after_partial_reversal | total_balance |
      | AUTHORIZATION        | REVERSAL                      | REVERSAL                   | PURCHASE         | 823.27          | 533.19                      | 533.19                            | 0.00             | USD          | 576.82              | 447.53                          | 447.53                                | 0.00                 | PKR              | 0000             | TRANSACTION_APPROVED    | 0000                         | TRANSACTION_APPROVED                | 0000                      | TRANSACTION_APPROVED             | AUTH_ACQUIRED                               | DEBIT_REVERSAL                                   | 423.18                       | 552.47                                   | 1000          |
      | AUTHORIZATION        | REVERSAL                      | REVERSAL                   | PURCHASE         | 999.88          | 617.14                      | 617.14                            | 0.00             | EUR          | 1000                | 382.74                          | 382.74                                | 0.00                 | PKR              | 0000             | TRANSACTION_APPROVED    | 0000                         | TRANSACTION_APPROVED                | 0000                      | TRANSACTION_APPROVED             | AUTH_ACQUIRED                               | DEBIT_REVERSAL                                   | 0                            | 617.26                                   | 1000          |
      | AUTHORIZATION        | REVERSAL                      | REVERSAL                   | PURCHASE         | 725.67          | 812.48                      | 812.48                            | 0.00             | GBP          | 725.67              | 999.99                          | 999.99                                | 0.00                 | PKR              | 0000             | TRANSACTION_APPROVED    | 0000                         | TRANSACTION_APPROVED                | 0000                      | TRANSACTION_APPROVED             | AUTH_ACQUIRED                               | DEBIT_INCREMENT                                  | 274.33                       | 0.01                                     | 1000          |
      | AUTHORIZATION        | REVERSAL_ADVICE               | REVERSAL                   | PURCHASE         | 615.34          | 1127.23                     | 1127.23                           | 0.00             | JPY          | 615.34              | 1127.23                         | 1127.23                               | 0.00                 | PKR              | 0000             | TRANSACTION_APPROVED    | 0000                         | TRANSACTION_APPROVED                | 0000                      | TRANSACTION_APPROVED             | AUTH_ACQUIRED                               | DEBIT_INCREMENT                                  | 384.66                       | -127.23                                  | 1000          |
      | AUTHORIZATION        | REVERSAL                      | REVERSAL                   | PURCHASE         | 562.19          | 463.97                      | 1000.00                           | 0.00             | USD          | 562.19              | 1000                            | 1000.00                               | 0.00                 | PKR              | 0000             | TRANSACTION_APPROVED    | 0000                         | TRANSACTION_APPROVED                | 0000                      | TRANSACTION_APPROVED             | AUTH_ACQUIRED                               | DEBIT_INCREMENT                                  | 437.81                       | 0                                        | 1000          |
      | AUTHORIZATION        | REVERSAL                      | REVERSAL                   | PURCHASE         | 502.31          | 0.00                        | 0.00                              | 0.00             | EUR          | 502.31              | 0.00                            | 0.00                                  | 0.00                 | PKR              | 0000             | TRANSACTION_APPROVED    | 0000                         | TRANSACTION_APPROVED                | 0000                      | TRANSACTION_APPROVED             | TRANSACTION_REVERTED                        | DEBIT_REVERSAL                                   | 497.69                       | 1000                                     | 1000          |
      | AUTHORIZATION_ADVICE | REVERSAL                      | REVERSAL                   | PURCHASE         | 1210.83         | 803.91                      | 803.91                            | 0.00             | AUD          | 1210.83             | 406.92                          | 406.92                                | 0.00                 | PKR              | 0000             | TRANSACTION_APPROVED    | 0000                         | TRANSACTION_APPROVED                | 0000                      | TRANSACTION_APPROVED             | AUTH_ACQUIRED                               | DEBIT_REVERSAL                                   | -210.83                      | 593.08                                   | 1000          |
      | AUTHORIZATION_ADVICE | REVERSAL                      | REVERSAL                   | PURCHASE         | 1134.45         | 1010.57                     | 1010.57                           | 0.00             | CAD          | 1134.45             | 1000                            | 1000                                  | 0.00                 | PKR              | 0000             | TRANSACTION_APPROVED    | 0000                         | TRANSACTION_APPROVED                | 0000                      | TRANSACTION_APPROVED             | AUTH_ACQUIRED                               | DEBIT_REVERSAL                                   | -134.45                      | 0                                        | 1000          |
      | AUTHORIZATION_ADVICE | REVERSAL                      | REVERSAL                   | PURCHASE         | 910.56          | 1010.64                     | 1010.64                           | 0.00             | USD          | 1910.56             | 1012.73                         | 1012.73                               | 0.00                 | PKR              | 0000             | TRANSACTION_APPROVED    | 0000                         | TRANSACTION_APPROVED                | 0000                      | TRANSACTION_APPROVED             | AUTH_ACQUIRED                               | DEBIT_REVERSAL                                   | -910.56                      | -12.73                                   | 1000          |
      | AUTHORIZATION_ADVICE | REVERSAL                      | REVERSAL                   | PURCHASE         | 2023.67         | 2340.85                     | 2340.85                           | 0.00             | USD          | 2023.67             | 2317.18                         | 2317.18                               | 0.00                 | PKR              | 0000             | TRANSACTION_APPROVED    | 0000                         | TRANSACTION_APPROVED                | 0000                      | TRANSACTION_APPROVED             | AUTH_ACQUIRED                               | DEBIT_INCREMENT                                  | -1023.67                     | -1317.18                                 | 1000          |

  Scenario Outline: Nymcard Transaction - Debit authorization followed by a partial reversal and then an incremental
    Given I set the following transaction information
      | transaction_identifier | parent_transaction_identifier | network | message_type                    | transaction_type   | transaction_description | rrn_identifier |
      | T1                     |                               | VISA    | <auth_message_type>             | <transaction_type> | <transaction_type>      | RRN1           |
      | T2                     | T1                            | VISA    | <partial_reversal_message_type> | <transaction_type> | <transaction_type>      | RRN1           |
      | T3                     | T1                            | VISA    | <incr_message_type>             | <transaction_type> | <transaction_type>      | RRN1           |

    Then I set card information in the transaction context
      | transaction_identifier | card_identifier | user_identifier |
      | T1                     | CardId1         | ECPID1          |
      | T2                     | CardId1         | ECPID1          |
      | T3                     | CardId1         | ECPID1          |

    Then I set merchant information in transaction context
      | transaction_identifier | acquirer_id | merchant_id | mcc  | merchant_name | merchant_city | merchant_country | terminal_id |
      | T1                     | 136200      | SCOTIABANK  | 5999 | CAIROO        | CHATTANOOG    | USA              | 99999999    |
      | T2                     | 136200      | SCOTIABANK  | 5999 | CAIROO        | CHATTANOOG    | USA              | 99999999    |
      | T3                     | 136200      | SCOTIABANK  | 5999 | CAIROO        | CHATTANOOG    | USA              | 99999999    |

    Then I set amount information in transaction context
      | transaction_identifier | transaction_amount | original_transaction_amount   | transaction_currency | billing_amount        | original_billing_amount           | billing_currency   |
      | T1                     | <auth_txn_amount>  | 0                             | <txn_currency>       | <auth_billing_amount> | 0                                 | <billing_currency> |
      | T2                     | <auth_txn_amount>  | <partial_reversal_txn_amount> | <txn_currency>       | <auth_billing_amount> | <partial_reversal_billing_amount> | <billing_currency> |
      | T3                     | <incr_txn_amount>  | 0                             | <txn_currency>       | <incr_billing_amount> | 0                                 | <billing_currency> |

    Then I set the following required indicators in transaction context
      | transaction_identifier | card_entry   | pos_environment | pin_present | moto  | performed_operation_type | incremental_transaction | processing_code | three_ds_indicator |
      | T1                     | DATA_ON_FILE | E_COMMERCE      | false       | false | D                        | false                   | 000000          | true               |
      | T2                     | DATA_ON_FILE | E_COMMERCE      | false       | false | C                        | false                   | 000000          | true               |
      | T3                     | DATA_ON_FILE | E_COMMERCE      | false       | false | D                        | true                    | 000000          | true               |

    When I initiate below Nymcard Transaction requests
      | transaction_identifier | status_code        | status_description        |
      | T1                     | <auth_status_code> | <auth_status_description> |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_after_auth> and total balance of <total_balance> for customerProfileId PKCPID1

    Then I validate TransactionLog entries for the performed Nymcard Transactions
      | transaction_identifier | fp_transaction_id | transaction_amount | billing_amount        | transaction_currency | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T1                     | VALID_UUID        | <auth_txn_amount>  | <auth_billing_amount> | <txn_currency>       | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate TransactionLogDetail entries for the performed Nymcard Transactions
      | transaction_identifier | idempotency_key | transaction_amount | billing_amount        | transaction_currency | billing_currency   | transaction_type | transaction_status |
      | T1                     | T1              | <auth_txn_amount>  | <auth_billing_amount> | <txn_currency>       | <billing_currency> | DEBIT_INITIAL    | COMPLETED          |

    When I initiate below Nymcard Transaction requests
      | transaction_identifier | status_code                    | status_description                    |
      | T2                     | <partial_reversal_status_code> | <partial_reversal_status_description> |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_after_partial_reversal> and total balance of <total_balance> for customerProfileId PKCPID1

    Then I validate TransactionLog entries for the performed Nymcard Transactions
      | transaction_identifier | fp_transaction_id | transaction_amount                  | billing_amount                          | transaction_currency | billing_currency   | transaction_type | transaction_status                            | release_auth_ts | release_type     |
      | T2                     | VALID_UUID        | <txn_amount_after_partial_reversal> | <billing_amount_after_partial_reversal> | <txn_currency>       | <billing_currency> | DEBIT_CREATE     | <partial_reversal_txn_log_transaction_status> | T+30            | SCHEDULED_EXPIRY |

    Then I validate TransactionLogDetail entries for the performed Nymcard Transactions
      | transaction_identifier | idempotency_key | transaction_amount                  | billing_amount                          | transaction_currency | billing_currency   | transaction_type                                   | transaction_status |
      | T2                     | T2              | <txn_amount_after_partial_reversal> | <billing_amount_after_partial_reversal> | <txn_currency>       | <billing_currency> | <partial_reversal_txn_log_detail_transaction_type> | COMPLETED          |

    When I initiate below Nymcard Transaction requests
      | transaction_identifier | status_code        | status_description        |
      | T3                     | <incr_status_code> | <incr_status_description> |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_after_incr> and total balance of <total_balance> for customerProfileId PKCPID1

    Then I validate TransactionLog entries for the performed Nymcard Transactions
      | transaction_identifier | fp_transaction_id | transaction_amount | billing_amount         | transaction_currency | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T3                     | VALID_UUID        | <total_txn_amount> | <total_billing_amount> | <txn_currency>       | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate TransactionLogDetail entries for the performed Nymcard Transactions
      | transaction_identifier | idempotency_key | transaction_amount | billing_amount         | transaction_currency | billing_currency   | transaction_type | transaction_status |
      | T3                     | T3              | <total_txn_amount> | <total_billing_amount> | <txn_currency>       | <billing_currency> | DEBIT_INCREMENT  | COMPLETED          |

    Examples:
      | auth_message_type    | partial_reversal_message_type | incr_message_type    | transaction_type | auth_txn_amount | partial_reversal_txn_amount | incr_txn_amount | txn_amount_after_partial_reversal | total_txn_amount | txn_currency | auth_billing_amount | partial_reversal_billing_amount | incr_billing_amount | billing_amount_after_partial_reversal | total_billing_amount | billing_currency | auth_status_code | auth_status_description | partial_reversal_status_code | partial_reversal_status_description | incr_status_code | incr_status_description | partial_reversal_txn_log_transaction_status | partial_reversal_txn_log_detail_transaction_type | available_balance_after_auth | available_balance_after_partial_reversal | available_balance_after_incr | total_balance |
      | AUTHORIZATION        | REVERSAL                      | AUTHORIZATION        | PURCHASE         | 823.27          | 533.19                      | 101.43          | 533.19                            | 634.62           | USD          | 576.82              | 447.53                          | 232.84              | 447.53                                | 680.37               | PKR              | 0000             | TRANSACTION_APPROVED    | 0000                         | TRANSACTION_APPROVED                | 0000             | TRANSACTION_APPROVED    | AUTH_ACQUIRED                               | DEBIT_REVERSAL                                   | 423.18                       | 552.47                                   | 319.63                       | 1000          |
      | AUTHORIZATION        | REVERSAL                      | AUTHORIZATION        | PURCHASE         | 823.27          | 533.19                      | 101.43          | 533.19                            | 634.62           | USD          | 1000                | 447.53                          | 552.47              | 447.53                                | 1000                 | PKR              | 0000             | TRANSACTION_APPROVED    | 0000                         | TRANSACTION_APPROVED                | 0000             | TRANSACTION_APPROVED    | AUTH_ACQUIRED                               | DEBIT_REVERSAL                                   | 0.00                         | 552.47                                   | 0.00                         | 1000          |
      | AUTHORIZATION        | REVERSAL                      | AUTHORIZATION        | PURCHASE         | 1000.00         | 233.19                      | 313.27          | 233.19                            | 546.46           | EUR          | 382.74              | 276.81                          | 723.19              | 276.81                                | 1000                 | PKR              | 0000             | TRANSACTION_APPROVED    | 0000                         | TRANSACTION_APPROVED                | 0000             | TRANSACTION_APPROVED    | AUTH_ACQUIRED                               | DEBIT_REVERSAL                                   | 617.26                       | 723.19                                   | 0.00                         | 1000          |
      | AUTHORIZATION        | REVERSAL                      | AUTHORIZATION_ADVICE | CASH_WITHDRAWAL  | 725.67          | 213.18                      | 488.09          | 213.18                            | 701.27           | GBP          | 999.99              | 721.37                          | 312.18              | 721.37                                | 1033.55              | PKR              | 0000             | TRANSACTION_APPROVED    | 0000                         | TRANSACTION_APPROVED                | 0000             | TRANSACTION_APPROVED    | AUTH_ACQUIRED                               | DEBIT_REVERSAL                                   | 0.01                         | 278.63                                   | -33.55                       | 1000          |
      | AUTHORIZATION        | REVERSAL                      | AUTHORIZATION        | PURCHASE         | 615.34          | 354.82                      | 253.09          | 354.82                            | 607.91           | AED          | 725.67              | 852.31                          | 27.09               | 852.31                                | 879.4                | PKR              | 0000             | TRANSACTION_APPROVED    | 0000                         | TRANSACTION_APPROVED                | 0000             | TRANSACTION_APPROVED    | AUTH_ACQUIRED                               | DEBIT_INCREMENT                                  | 274.33                       | 147.69                                   | 120.60                       | 1000          |
      | AUTHORIZATION        | REVERSAL                      | AUTHORIZATION        | CASH_WITHDRAWAL  | 562.19          | 432.31                      | 437.81          | 432.31                            | 870.12           | INR          | 615.34              | 747.53                          | 252.47              | 747.53                                | 1000                 | PKR              | 0000             | TRANSACTION_APPROVED    | 0000                         | TRANSACTION_APPROVED                | 0000             | TRANSACTION_APPROVED    | AUTH_ACQUIRED                               | DEBIT_INCREMENT                                  | 384.66                       | 252.47                                   | 0.00                         | 1000          |
      | AUTHORIZATION        | REVERSAL                      | AUTHORIZATION_ADVICE | CASH_WITHDRAWAL  | 502.31          | 100.00                      | 223.18          | 100.00                            | 323.18           | CAD          | 562.19              | 724.71                          | 443.88              | 724.71                                | 1168.59              | PKR              | 0000             | TRANSACTION_APPROVED    | 0000                         | TRANSACTION_APPROVED                | 0000             | TRANSACTION_APPROVED    | AUTH_ACQUIRED                               | DEBIT_INCREMENT                                  | 437.81                       | 275.29                                   | -168.59                      | 1000          |
      | AUTHORIZATION        | REVERSAL_ADVICE               | AUTHORIZATION_ADVICE | PURCHASE         | 1210.83         | 400.00                      | 200.00          | 400.00                            | 600.00           | USD          | 502.31              | 1031.08                         | 302.71              | 1031.08                               | 1333.79              | PKR              | 0000             | TRANSACTION_APPROVED    | 0000                         | TRANSACTION_APPROVED                | 0000             | TRANSACTION_APPROVED    | AUTH_ACQUIRED                               | DEBIT_INCREMENT                                  | 497.69                       | -31.08                                   | -333.79                      | 1000          |
      | AUTHORIZATION        | REVERSAL                      | AUTHORIZATION_ADVICE | PURCHASE         | 1134.45         | 275.67                      | 413.43          | 275.67                            | 689.10           | CNY          | 502.31              | 1000                            | 255.08              | 1000                                  | 1255.08              | PKR              | 0000             | TRANSACTION_APPROVED    | 0000                         | TRANSACTION_APPROVED                | 0000             | TRANSACTION_APPROVED    | AUTH_ACQUIRED                               | DEBIT_INCREMENT                                  | 497.69                       | 0.00                                     | -255.08                      | 1000          |
      | AUTHORIZATION_ADVICE | REVERSAL_ADVICE               | AUTHORIZATION_ADVICE | CASH_WITHDRAWAL  | 1910.56         | 823.27                      | 234.56          | 823.27                            | 1057.83          | GBP          | 1406.92             | 1680.00                         | 121.09              | 1680.00                               | 1801.09              | PKR              | 0000             | TRANSACTION_APPROVED    | 0000                         | TRANSACTION_APPROVED                | 0000             | TRANSACTION_APPROVED    | AUTH_ACQUIRED                               | DEBIT_INCREMENT                                  | -406.92                      | -680.00                                  | -801.09                      | 1000          |
      | AUTHORIZATION_ADVICE | REVERSAL                      | AUTHORIZATION        | PURCHASE         | 2023.67         | 1010.23                     | 252.18          | 1010.23                           | 1262.41          | USD          | 1451.45             | 382.74                          | 147.56              | 382.74                                | 530.3                | PKR              | 0000             | TRANSACTION_APPROVED    | 0000                         | TRANSACTION_APPROVED                | 0000             | TRANSACTION_APPROVED    | AUTH_ACQUIRED                               | DEBIT_REVERSAL                                   | -451.45                      | 617.26                                   | 469.70                       | 1000          |
      | AUTHORIZATION_ADVICE | REVERSAL                      | AUTHORIZATION_ADVICE | PURCHASE         | 1860.43         | 789.34                      | 259.87          | 789.34                            | 1049.21          | GBP          | 2345.67             | 43.21                           | 2134.98             | 43.21                                 | 2178.19              | PKR              | 0000             | TRANSACTION_APPROVED    | 0000                         | TRANSACTION_APPROVED                | 0000             | TRANSACTION_APPROVED    | AUTH_ACQUIRED                               | DEBIT_REVERSAL                                   | -1345.67                     | 956.79                                   | -1178.19                     | 1000          |
      | AUTHORIZATION_ADVICE | REVERSAL                      | AUTHORIZATION_ADVICE | CASH_WITHDRAWAL  | 1945.82         | 975.46                      | 284.12          | 975.46                            | 1259.58          | USD          | 4397.31             | 1000                            | 162.78              | 1000                                  | 1162.78              | PKR              | 0000             | TRANSACTION_APPROVED    | 0000                         | TRANSACTION_APPROVED                | 0000             | TRANSACTION_APPROVED    | AUTH_ACQUIRED                               | DEBIT_REVERSAL                                   | -3397.31                     | 0.00                                     | -162.78                      | 1000          |

  Scenario Outline: Nymcard Transaction - Debit authorization followed by full clearing
    Given I set the following transaction information
      | transaction_identifier | parent_transaction_identifier | network | message_type                 | transaction_type   | transaction_description | rrn_identifier |
      | T1                     |                               | VISA    | <auth_message_type>          | <transaction_type> | <transaction_type>      | RRN1           |
      | T2                     | T1                            | VISA    | <full_clearing_message_type> | <transaction_type> | <transaction_type>      | RRN1           |

    Then I set card information in the transaction context
      | transaction_identifier | card_identifier | user_identifier |
      | T1                     | CardId1         | ECPID1          |
      | T2                     | CardId1         | ECPID1          |

    Then I set merchant information in transaction context
      | transaction_identifier | acquirer_id | merchant_id | mcc  | merchant_name | merchant_city | merchant_country | terminal_id |
      | T1                     | 136200      | SCOTIABANK  | 5999 | CAIROO        | CHATTANOOG    | USA              | 99999999    |

    Then I set amount information in transaction context
      | transaction_identifier | transaction_amount         | transaction_currency | billing_amount                 | billing_currency   |
      | T1                     | <auth_txn_amount>          | <txn_currency>       | <auth_billing_amount>          | <billing_currency> |
      | T2                     | <full_clearing_txn_amount> | <txn_currency>       | <full_clearing_billing_amount> | <billing_currency> |

    Then I set the following required indicators in transaction context
      | transaction_identifier | card_entry   | pos_environment | pin_present | moto  | performed_operation_type | incremental_transaction | processing_code | three_ds_indicator |
      | T1                     | DATA_ON_FILE | E_COMMERCE      | false       | false | D                        | false                   | 000000          | true               |
      | T2                     | DATA_ON_FILE | E_COMMERCE      | false       | false | D                        | false                   | 000000          | true               |

    Then I set clearing information in transaction context
      | transaction_identifier | settlement_status | interchange_fee | interchange_fee_indicator |
      | T2                     | MATCHED           | 0.10            | C                         |

    When I initiate below Nymcard Transaction requests
      | transaction_identifier | status_code        | status_description        |
      | T1                     | <auth_status_code> | <auth_status_description> |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_after_auth> and total balance of <total_balance_after_auth> for customerProfileId PKCPID1

    Then I validate TransactionLog entries for the performed Nymcard Transactions
      | transaction_identifier | fp_transaction_id | transaction_amount | billing_amount        | transaction_currency | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T1                     | VALID_UUID        | <auth_txn_amount>  | <auth_billing_amount> | <txn_currency>       | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate TransactionLogDetail entries for the performed Nymcard Transactions
      | transaction_identifier | idempotency_key | transaction_amount | billing_amount        | transaction_currency | billing_currency   | transaction_type | transaction_status |
      | T1                     | T1              | <auth_txn_amount>  | <auth_billing_amount> | <txn_currency>       | <billing_currency> | DEBIT_INITIAL    | COMPLETED          |

    When I initiate below Nymcard Transaction requests
      | transaction_identifier | status_code                 | status_description                 |
      | T2                     | <full_clearing_status_code> | <full_clearing_status_description> |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_after_full_clearing> and total balance of <total_balance_after_full_clearing> for customerProfileId PKCPID1

    Then I validate TransactionLog entries for the performed Nymcard Transactions
      | transaction_identifier | linked_transaction_ids | fp_transaction_id | transaction_amount         | billing_amount                 | transaction_currency | billing_currency   | transaction_type | transaction_status | clearing                                                                                          | release_auth_ts | release_type     |
      | T2                     | T1                     | VALID_UUID        | <full_clearing_txn_amount> | <full_clearing_billing_amount> | <txn_currency>       | <billing_currency> | DEBIT_CLEAR      | SETTLED            | {"interchange_fee": 0.1, "interchange_type": "CR", "clearing_outcome": "AUTH_FOUND_AMOUNT_MATCH"} | T+30            |                  |
      | T1                     | T2                     | VALID_UUID        | <total_txn_amount>         | <total_billing_amount>         | <txn_currency>       | <billing_currency> | DEBIT_CREATE     | AUTH_CLEARED       |                                                                                                   | T+30            | SCHEDULED_EXPIRY |

    Then I validate TransactionLogDetail entries for the performed Nymcard Transactions
      | transaction_identifier | idempotency_key | transaction_amount         | billing_amount                 | transaction_currency | billing_currency   | transaction_type | transaction_status |
      | T2                     | T2              | <full_clearing_txn_amount> | <full_clearing_billing_amount> | <txn_currency>       | <billing_currency> | DEBIT_CLEAR      | COMPLETED          |

    Examples:
      | auth_message_type    | full_clearing_message_type | transaction_type | auth_txn_amount | full_clearing_txn_amount | total_txn_amount | txn_currency | auth_billing_amount | full_clearing_billing_amount | total_billing_amount | billing_currency | auth_status_code | auth_status_description | full_clearing_status_code | full_clearing_status_description | available_balance_after_auth | available_balance_after_full_clearing | total_balance_after_auth | total_balance_after_full_clearing |
      | AUTHORIZATION        | CLEARING                   | PURCHASE         | 823.27          | 823.27                   | 0                | USD          | 576.82              | 576.82                       | 0                    | PKR              | 0000             | TRANSACTION_APPROVED    | 0000                      | TRANSACTION_APPROVED             | 423.18                       | 423.18                                | 1000                     | 423.18                            |
      | AUTHORIZATION        | CLEARING                   | PURCHASE         | 920.72          | 920.72                   | 0                | EUR          | 999.99              | 999.99                       | 0                    | PKR              | 0000             | TRANSACTION_APPROVED    | 0000                      | TRANSACTION_APPROVED             | 0.01                         | 0.01                                  | 1000                     | 0.01                              |
      | AUTHORIZATION        | CLEARING                   | PURCHASE         | 8539.43         | 8539.43                  | 0                | JPY          | 1000                | 1000                         | 0                    | PKR              | 0000             | TRANSACTION_APPROVED    | 0000                      | TRANSACTION_APPROVED             | 0                            | 0                                     | 1000                     | 0                                 |
      | AUTHORIZATION_ADVICE | CLEARING                   | PURCHASE         | 1381.40         | 1381.40                  | 0                | CAD          | 999.98              | 999.98                       | 0                    | PKR              | 0000             | TRANSACTION_APPROVED    | 0000                      | TRANSACTION_APPROVED             | 0.02                         | 0.02                                  | 1000                     | 0.02                              |
      | AUTHORIZATION_ADVICE | CLEARING                   | PURCHASE         | 239.75          | 239.75                   | 0                | AUD          | 1252.53             | 1252.53                      | 0                    | PKR              | 0000             | TRANSACTION_APPROVED    | 0000                      | TRANSACTION_APPROVED             | -252.53                      | -252.53                               | 1000                     | -252.53                           |

  Scenario Outline: Nymcard Transaction - Debit authorization followed by multiple partial clearing
    Given I set the following transaction information
      | transaction_identifier | parent_transaction_identifier | network | message_type                      | transaction_type   | transaction_description | rrn_identifier |
      | T1                     |                               | VISA    | <auth_message_type>               | <transaction_type> | <transaction_type>      | RRN1           |
      | T2                     | T1                            | VISA    | <partial_clearing_1_message_type> | <transaction_type> | <transaction_type>      | RRN1           |
      | T3                     | T1                            | VISA    | <partial_clearing_2_message_type> | <transaction_type> | <transaction_type>      | RRN1           |

    Then I set card information in the transaction context
      | transaction_identifier | card_identifier | user_identifier |
      | T1                     | CardId1         | ECPID1          |
      | T2                     | CardId1         | ECPID1          |
      | T3                     | CardId1         | ECPID1          |

    Then I set merchant information in transaction context
      | transaction_identifier | acquirer_id | merchant_id | mcc  | merchant_name | merchant_city | merchant_country | terminal_id |
      | T1                     | 136200      | SCOTIABANK  | 5999 | CAIROO        | CHATTANOOG    | USA              | 99999999    |

    Then I set amount information in transaction context
      | transaction_identifier | transaction_amount              | transaction_currency | billing_amount                      | billing_currency   |
      | T1                     | <auth_txn_amount>               | <txn_currency>       | <auth_billing_amount>               | <billing_currency> |
      | T2                     | <partial_clearing_1_txn_amount> | <txn_currency>       | <partial_clearing_1_billing_amount> | <billing_currency> |
      | T3                     | <partial_clearing_2_txn_amount> | <txn_currency>       | <partial_clearing_2_billing_amount> | <billing_currency> |

    Then I set the following required indicators in transaction context
      | transaction_identifier | card_entry   | pos_environment | pin_present | moto  | performed_operation_type | incremental_transaction | processing_code | three_ds_indicator |
      | T1                     | DATA_ON_FILE | E_COMMERCE      | false       | false | D                        | false                   | 000000          | true               |
      | T2                     | DATA_ON_FILE | E_COMMERCE      | false       | false | D                        | false                   | 000000          | true               |
      | T3                     | DATA_ON_FILE | E_COMMERCE      | false       | false | D                        | false                   | 000000          | true               |

    Then I set clearing information in transaction context
      | transaction_identifier | settlement_status        | interchange_fee | interchange_fee_indicator |
      | T2                     | COMPLETION_AMOUNT_LESSER | 0.10            | C                         |
      | T3                     | COMPLETION_AMOUNT_LESSER | 0.15            | C                         |

    When I initiate below Nymcard Transaction requests
      | transaction_identifier | status_code        | status_description        |
      | T1                     | <auth_status_code> | <auth_status_description> |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_after_auth> and total balance of <total_balance_after_auth> for customerProfileId PKCPID1

    Then I validate TransactionLog entries for the performed Nymcard Transactions
      | transaction_identifier | fp_transaction_id | transaction_amount | billing_amount        | transaction_currency | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T1                     | VALID_UUID        | <auth_txn_amount>  | <auth_billing_amount> | <txn_currency>       | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate TransactionLogDetail entries for the performed Nymcard Transactions
      | transaction_identifier | idempotency_key | transaction_amount | billing_amount        | transaction_currency | billing_currency   | transaction_type | transaction_status |
      | T1                     | T1              | <auth_txn_amount>  | <auth_billing_amount> | <txn_currency>       | <billing_currency> | DEBIT_INITIAL    | COMPLETED          |

    When I initiate below Nymcard Transaction requests
      | transaction_identifier | status_code                      | status_description                      |
      | T2                     | <partial_clearing_1_status_code> | <partial_clearing_1_status_description> |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_after_partial_clearing_1> and total balance of <total_balance_after_partial_clearing_1> for customerProfileId PKCPID1

    Then I validate TransactionLog entries for the performed Nymcard Transactions
      | transaction_identifier | linked_transaction_ids | fp_transaction_id | transaction_amount                          | billing_amount                                  | transaction_currency | billing_currency   | transaction_type | transaction_status | clearing                                                                                          | release_auth_ts | release_type     |
      | T2                     | T1                     | VALID_UUID        | <partial_clearing_1_txn_amount>             | <partial_clearing_1_billing_amount>             | <txn_currency>       | <billing_currency> | DEBIT_CLEAR      | SETTLED            | {"interchange_fee": 0.1, "interchange_type": "CR", "clearing_outcome": "AUTH_FOUND_AMOUNT_MATCH"} | T+30            |                  |
      | T1                     | T2                     | VALID_UUID        | <total_txn_amount_after_partial_clearing_1> | <total_billing_amount_after_partial_clearing_1> | <txn_currency>       | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      |                                                                                                   | T+30            | SCHEDULED_EXPIRY |

    Then I validate TransactionLogDetail entries for the performed Nymcard Transactions
      | transaction_identifier | idempotency_key | transaction_amount              | billing_amount                      | transaction_currency | billing_currency   | transaction_type | transaction_status |
      | T2                     | T2              | <partial_clearing_1_txn_amount> | <partial_clearing_1_billing_amount> | <txn_currency>       | <billing_currency> | DEBIT_CLEAR      | COMPLETED          |

    When I initiate below Nymcard Transaction requests
      | transaction_identifier | status_code                      | status_description                      |
      | T3                     | <partial_clearing_2_status_code> | <partial_clearing_2_status_description> |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_after_partial_clearing_2> and total balance of <total_balance_after_partial_clearing_2> for customerProfileId PKCPID1

    Then I validate TransactionLog entries for the performed Nymcard Transactions
      | transaction_identifier | linked_transaction_ids | fp_transaction_id | transaction_amount              | billing_amount                      | transaction_currency | billing_currency   | transaction_type | transaction_status | clearing                                                                                           | release_auth_ts | release_type     |
      | T3                     | T1                     | VALID_UUID        | <partial_clearing_2_txn_amount> | <partial_clearing_2_billing_amount> | <txn_currency>       | <billing_currency> | DEBIT_CLEAR      | SETTLED            | {"interchange_fee": 0.15, "interchange_type": "CR", "clearing_outcome": "AUTH_FOUND_AMOUNT_MATCH"} | T+30            |                  |
      | T1                     | T2, T3                 | VALID_UUID        | <total_txn_amount>              | <total_billing_amount>              | <txn_currency>       | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      |                                                                                                    | T+30            | SCHEDULED_EXPIRY |

    Then I validate TransactionLogDetail entries for the performed Nymcard Transactions
      | transaction_identifier | idempotency_key | transaction_amount              | billing_amount                      | transaction_currency | billing_currency   | transaction_type | transaction_status |
      | T3                     | T3              | <partial_clearing_2_txn_amount> | <partial_clearing_2_billing_amount> | <txn_currency>       | <billing_currency> | DEBIT_CLEAR      | COMPLETED          |

    Examples:
      | auth_message_type | partial_clearing_1_message_type | partial_clearing_2_message_type | transaction_type | auth_txn_amount | partial_clearing_1_txn_amount | partial_clearing_2_txn_amount | total_txn_amount_after_partial_clearing_1 | total_txn_amount | txn_currency | auth_billing_amount | partial_clearing_1_billing_amount | partial_clearing_2_billing_amount | total_billing_amount_after_partial_clearing_1 | total_billing_amount | billing_currency | auth_status_code | auth_status_description | partial_clearing_1_status_code | partial_clearing_1_status_description | partial_clearing_2_status_code | partial_clearing_2_status_description | available_balance_after_auth | available_balance_after_partial_clearing_1 | available_balance_after_partial_clearing_2 | total_balance_after_auth | total_balance_after_partial_clearing_1 | total_balance_after_partial_clearing_2 |
      | AUTHORIZATION     | CLEARING                        | CLEARING                        | PURCHASE         | 1050.75         | 420.50                        | 360.00                        | 630.25                                    | 270.25           | JPY          | 700.00              | 280.00                            | 245.00                            | 420.00                                        | 175.00               | PKR              | 0000             | TRANSACTION_APPROVED    | 0000                           | TRANSACTION_APPROVED                  | 0000                           | TRANSACTION_APPROVED                  | 300.00                       | 300.00                                     | 300.00                                     | 1000.00                  | 720                                    | 475.00                                 |
