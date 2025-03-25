Feature: Card Transaction test scenarios for provider Clowd9

  Background: I setup end-customer profile, card account and card for transactions on provider Clowd9
    Given I set and verify customer CID1, customer profile CPID1 of SG region in the context

    Then I create below End-Customer-Profile
      | customer_profile_identifier | end_customer_profile_identifier | first_name | last_name | region | email         | phone_number   |
      | CPID1                       | ECPID1                          | John       | Snow      | SG     | john@snow.com | +63 1234567890 |

    Then I verify End-Customer-Profile exist with values
      | customer_profile_identifier | end_customer_profile_identifier | first_name | last_name | email         | phone_number   | status |
      | CPID1                       | ECPID1                          | John       | Snow      | john@snow.com | +63 1234567890 | ACTIVE |

    Given I onboard CustomerProfile CPID1 with customerId CID1 on cash service on below providers and expect status 200
      | provider_name |
      | DBS Bank Ltd  |

    Then I wait until max time to verify CustomerProfile CPID1 onboard status as ONBOARD_SUCCESS

    When I onboard EndCustomerProfile ECPID1 of CustomerProfile CPID1 on cash service on below providers and expect status 200
      | provider_name |
      | DBS Bank Ltd  |

    Then I wait until max time to verify EndCustomerProfile ECPID1 of CustomerProfile CPID1 onboard status as ONBOARD_SUCCESS

    Then I onboard below Customer-Profile onto Compliance Provider Id
      | customer_identifier | customer_profile_identifier | provider_id   | status_code |
      | CID1                | CPID1                       | TRU-NARRATIVE | 200         |

    Then I verify Customer-Profile onboarded with provider Id
      | customer_identifier | customer_profile_identifier | provider_id   |
      | CID1                | CPID1                       | TRU-NARRATIVE |

    Then I process compliance for the end customer
      | customer_profile_identifier | end_customer_profile_identifier | compliance_identifier | provider_id       | compliance_type | end_customer_profile_id | status_code |
      | CPID1                       | ECPID1                          | COMPID1               | TRU-NARRATIVE     | IDV_JOURNEY     | 2985729835              | 200         |

    Then I push dev webhook with status
      | customer_profile_identifier | compliance_identifier | status |
      | CPID1                       | COMPID1               | pass   |

    Then I fetch compliance status and verify
      | customer_profile_identifier | compliance_identifier | status   | decision |
      | CPID1                       | COMPID1               | COMPLETE | ACCEPT   |

    Given I onboard End-Customer Profile ECPID1 of Customer Profile CPID1 on fund provider CASH and on card service on below providers
      | provider_name |
      | Clowd9        |

    Then I wait until max time to verify End-Customer Profile ECPID1 onboard status on card service provider Clowd9 as ONBOARD_SUCCESS

    Given I create a product with customer profile CPID1 provider as DBS Bank Ltd and expect product_status PRODUCT_DRAFT
      | identifier | product_type | profile_type | product_class | currency | country | account_type | balance_policy_type | balance_policy_limit |
      | ProductID1 | WALLET       | END_CUSTOMER | SHARIAH       | SGD      | SGP     | SAVINGS      | LENIENT             | 0                    |

    Then I approve the product ProductID1 and verify status as PRODUCT_SUCCESS with provider DBS Bank Ltd for customerProfileId CPID1

    Given I create account for EndCustomerProfile with id ECPID1 for CustomerProfile CPID1 with product id ProductID1 with bank account type as e-money with provider DBS Bank Ltd and expect the header status 200
      | identifier | currency | country | in_trust | is_overdraft_allowed | on_behalf_of | metadata                    |
      | BankAccId  | SGD      | SGP     | false    | true                 | CUSTOMER     | {"key": "IntegrationTest1"} |

    Then I wait until max time to verify the bank account BankAccId status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId CPID1

    Given I deposit an amount of 1000 into BankAccId using cash DevDeposit and expect the header status 200
      | identifier           | customer_profile_id | purpose  | currency | transaction_rail |
      | DevDepositIdentifier | CPID1               | TRANSFER | SGD      | FAST             |

    Then I wait until max time to verify bank account BankAccId with an increased balance of 1000 for customerProfileId CPID1

    Given I create below Card Account
      | card_account_identifier | end_customer_profile_identifier | provider_name | fund_provider | bank_account_identifier | customer_address                                                                                                                                                                                                                                      |
      | CardAccId1              | ECPID1                          | Clowd9        | CASH          | BankAccId               | {"address_line_1":"Atlas Consolidated Labs", "address_line_2":"Mukunda Towers", "address_line_3":"Indian Airlines Colony", "address_line_4":"Begumpet", "city":"Hyderabad", "state":"", "country": "", "country_code": "SGP", "local_code": "800003"} |

    Then I wait until max time to verify Card Account CardAccId1 onboard status on card service provider Clowd9 as CARD_ACCOUNT_CREATED

    Given I issue Card for Card Account on provider Clowd9
      | card_identifier | card_account_identifier | card_type | emboss_name | validity_in_months | three_d_secure_config                                                  | delivery_address                                                                                                                                                                                                                                      |
      | CardId1         | CardAccId1              | PHYSICAL  | Sasuke      | 60                 | {"security_question": "What is your name?", "security_answer": "John"} | {"address_line_1":"Atlas Consolidated Labs", "address_line_2":"Mukunda Towers", "address_line_3":"Indian Airlines Colony", "address_line_4":"Begumpet", "city":"Hyderabad", "state":"", "country": "", "country_code": "SGP", "local_code": "800003"} |

    Then I wait until max time to verify Card CardId1 status on card service provider Clowd9 as INACTIVE

    Then I activate the Card
      | card_identifier |
      | CardId1         |

  Scenario Outline: Clowd9-Test debit single authorization
    Given I build below transactions
      | transaction_identifier | message_type  | message_qualifier   | source |
      | T1                     | authorization | <message_qualifier> | VISA   |

    Then I set card objects in transaction context
      | transaction_identifier | card_identifier | card_form_factor | card_status |
      | T1                     | CardId1         | physical         | active      |

    Then I set customer objects in transaction context
      | transaction_identifier | customer_identifier |
      | T1                     | CardAccId1          |

    Then I set transaction objects in transaction context
      | transaction_identifier | transaction_id | transaction_type | transaction_amount   | transaction_currency_code   | cardholder_billing_amount | cardholder_billing_currency_code | system_trace_audit_number | retrieval_reference_number | network_transaction_id | transaction_local_time | transmission_date | transmission_time | transaction_local_date | dcc_indicator | chip_indicator | pin_indicator | three_ds_indicator | partial_approval_supported | cardholder_condition |
      | T1                     | TxnId1         | 00               | <transaction_amount> | <transaction_currency_code> | <billing_amount>          | <billing_currency_code>          | STAN1                     | RRN1                       | NT1                    | 192748                 | 1206              | 182751            | 1206                   | n             | contact        | online_passed | n                  | n                          | 00                   |

    Then I set acquirer objects in transaction context
      | transaction_identifier | card_acceptor_country_code   | acquiring_institution_country_code | acquiring_institution_id_code | merchant_category_code | card_acceptor_terminal_id | card_acceptor_id | card_acceptor_name | card_acceptor_city |
      | T1                     | <card_acceptor_country_code> | <transaction_currency_code>        | 843759                        | 6011                   | DUMMY_TERMINAL            | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code   | response_reason   | case_type |
      | T1                     | authorization | <transaction_amount> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | <response_code> | <response_reason> | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance> and total balance of <total_balance> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount   | billing_amount   | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T1                     | VALID_UUID          | <transaction_amount> | <billing_amount> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount   | billing_amount   | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T1                     | TxnId1          | <transaction_amount> | <billing_amount> | <transaction_currency_code> | <billing_currency_code> | DEBIT_INITIAL    | COMPLETED          |

    Examples:
      | message_qualifier | response_code | response_reason     | transaction_amount | billing_amount | transaction_currency_code | transaction_currency | billing_currency_code | billing_currency | card_acceptor_country_code | available_balance | total_balance |
      | request           | 000           | Approved            | 100                | 100            | 702                       | SGD                  | 702                   | SGD              | SG                         | 900               | 1000          |
      | notification      | 091           | Advice acknowledged | 100                | 100            | 702                       | SGD                  | 702                   | SGD              | SG                         | 900               | 1000          |
      | request           | 000           | Approved            | 10.27              | 10.27          | 702                       | SGD                  | 702                   | SGD              | SG                         | 989.73            | 1000          |
      | notification      | 091           | Advice acknowledged | 10.27              | 10.27          | 702                       | SGD                  | 702                   | SGD              | SG                         | 989.73            | 1000          |
      | request           | 000           | Approved            | 1000               | 1000           | 702                       | SGD                  | 702                   | SGD              | SG                         | 0                 | 1000          |
      | notification      | 091           | Advice acknowledged | 1000               | 1000           | 702                       | SGD                  | 702                   | SGD              | SG                         | 0                 | 1000          |
      | notification      | 091           | Advice acknowledged | 1000.01            | 1000.01        | 702                       | SGD                  | 702                   | SGD              | SG                         | -0.01             | 1000          |
      | request           | 000           | Approved            | 100                | 100            | 826                       | GBP                  | 702                   | SGD              | GB                         | 900               | 1000          |
      | notification      | 091           | Advice acknowledged | 100                | 100            | 826                       | GBP                  | 702                   | SGD              | GB                         | 900               | 1000          |

  Scenario Outline: Clowd9-Test OCT authorization and auto clearing
    Given I build below transactions
      | transaction_identifier | message_type  | message_qualifier   | source |
      | T1                     | authorization | <message_qualifier> | VISA   |

    Then I set card objects in transaction context
      | transaction_identifier | card_identifier | card_form_factor | card_status |
      | T1                     | CardId1         | physical         | active      |

    Then I set customer objects in transaction context
      | transaction_identifier | customer_identifier |
      | T1                     | CardAccId1          |

    Then I set transaction objects in transaction context
      | transaction_identifier | transaction_id | transaction_type | transaction_amount   | transaction_currency_code   | cardholder_billing_amount | cardholder_billing_currency_code | system_trace_audit_number | retrieval_reference_number | network_transaction_id | transaction_local_time | transmission_date | transmission_time | transaction_local_date | dcc_indicator | chip_indicator | pin_indicator | three_ds_indicator | partial_approval_supported | cardholder_condition |
      | T1                     | TxnId1         | 26               | <transaction_amount> | <transaction_currency_code> | <billing_amount>          | <billing_currency_code>          | STAN1                     | RRN1                       | NT1                    | 192748                 | 1206              | 182751            | 1206                   | n             | contact        | online_passed | n                  | n                          | 00                   |

    Then I set acquirer objects in transaction context
      | transaction_identifier | card_acceptor_country_code   | acquiring_institution_country_code | acquiring_institution_id_code | merchant_category_code | card_acceptor_terminal_id | card_acceptor_id | card_acceptor_name | card_acceptor_city |
      | T1                     | <card_acceptor_country_code> | <transaction_currency_code>        | 843759                        | 6011                   | DUMMY_TERMINAL            | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | auto_clearing_ts | message_type  | authorized_tx_amount | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code   | response_reason   | case_type |
      | T1                     | T+m15            | authorization | <transaction_amount> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | <response_code> | <response_reason> | positive  |

    Then I update DDS Transaction auto clearing ts to current ts manually and trigger the auto clearing process for DDS Transactions
      | transaction_identifier | status_code | case_type |
      | T1                     | 200         | positive  |

    Then I validate DynamicDataStream entry after auto clearing process
      | transaction_identifier | status_reason                 | case_type |
      | T1                     | APPROVED: OCT Auto cleared    | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance> and total balance of <total_balance> for customerProfileId CPID1

    Then I validate authorization TransactionLog entry for the performed DDS Transaction auto clearing
      | transaction_identifier | bank_transaction_id | transaction_amount | billing_amount | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T1                     | VALID_UUID          | 0                  | 0              | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | CREDIT_CREATE    | AUTH_CLEARED       | T+30            | SCHEDULED_EXPIRY |

    Then I validate clearing TransactionLog entry for the performed DDS Transaction auto clearing
      | transaction_identifier | bank_transaction_id | transaction_amount   | billing_amount   | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | clearing                                                                                                                    |
      | T1                     | VALID_UUID          | <transaction_amount> | <billing_amount> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | CREDIT_CLEAR     | CLEARED            | {"interchange_fee": 0.0, "interchange_type": "UNKNOWN_INTERCHANGE_FEE_TYPE", "clearing_outcome": "AUTH_FOUND_AMOUNT_MATCH"} |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount   | billing_amount   | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T1                     | TxnId1          | <transaction_amount> | <billing_amount> | <transaction_currency_code> | <billing_currency_code> | CREDIT_INITIAL   | COMPLETED          |

    Examples:
      | message_qualifier | response_code | response_reason     | transaction_amount | billing_amount | transaction_currency_code | transaction_currency | billing_currency_code | billing_currency | card_acceptor_country_code | available_balance | total_balance |
      | request           | 000           | Approved            | 100                | 100            | 702                       | SGD                  | 702                   | SGD              | SG                         | 1100              | 1100          |
      | notification      | 091           | Advice acknowledged | 100                | 100            | 702                       | SGD                  | 702                   | SGD              | SG                         | 1100              | 1100          |
      | request           | 000           | Approved            | 10.27              | 10.27          | 702                       | SGD                  | 702                   | SGD              | SG                         | 1010.27           | 1010.27       |
      | notification      | 091           | Advice acknowledged | 10.27              | 10.27          | 702                       | SGD                  | 702                   | SGD              | SG                         | 1010.27           | 1010.27       |
      | request           | 000           | Approved            | 1000               | 1000           | 702                       | SGD                  | 702                   | SGD              | SG                         | 2000              | 2000          |
      | notification      | 091           | Advice acknowledged | 1000               | 1000           | 702                       | SGD                  | 702                   | SGD              | SG                         | 2000              | 2000          |
      | notification      | 091           | Advice acknowledged | 1000.01            | 1000.01        | 702                       | SGD                  | 702                   | SGD              | SG                         | 2000.01           | 2000.01       |
      | request           | 000           | Approved            | 100                | 100            | 826                       | GBP                  | 702                   | SGD              | GB                         | 1100              | 1100          |
      | notification      | 091           | Advice acknowledged | 100                | 100            | 826                       | GBP                  | 702                   | SGD              | GB                         | 1100              | 1100          |

  Scenario Outline: Clowd9-Test debit authorization with insufficient funds
    Given I build below transactions
      | transaction_identifier | message_type  | message_qualifier   | source |
      | T1                     | authorization | <message_qualifier> | VISA   |

    Then I set card objects in transaction context
      | transaction_identifier | card_identifier | card_form_factor | card_status |
      | T1                     | CardId1         | PHYSICAL         | active      |

    Then I set customer objects in transaction context
      | transaction_identifier | customer_identifier |
      | T1                     | CardAccId1          |

    Then I set transaction objects in transaction context
      | transaction_identifier | transaction_id | transaction_type | transaction_amount   | transaction_currency_code   | cardholder_billing_amount | cardholder_billing_currency_code | system_trace_audit_number | retrieval_reference_number | network_transaction_id | transaction_local_time | transmission_date | transmission_time | transaction_local_date | dcc_indicator | chip_indicator | pin_indicator | three_ds_indicator | partial_approval_supported |
      | T1                     | TxnId1         | 00               | <transaction_amount> | <transaction_currency_code> | <billing_amount>          | <billing_currency_code>          | STAN1                     | RRN1                       | NT1                    | 192748                 | 1206              | 182751            | 1206                   | n             | contact        | online_passed | n                  | n                          |

    Then I set acquirer objects in transaction context
      | transaction_identifier | card_acceptor_country_code   | acquiring_institution_country_code | acquiring_institution_id_code | merchant_category_code | card_acceptor_terminal_id | card_acceptor_id | card_acceptor_name | card_acceptor_city |
      | T1                     | <card_acceptor_country_code> | <transaction_currency_code>        | 843759                        | 6011                   | DUMMY_TERMINAL            | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason    | case_type |
      | T1                     | authorization | <transaction_amount> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 116           | Insufficient Funds | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance> and total balance of <total_balance> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | transaction_amount   | billing_amount   | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status |
      | T1                     | <transaction_amount> | <billing_amount> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_DECLINED      |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount   | billing_amount   | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T1                     | TxnId1          | <transaction_amount> | <billing_amount> | <transaction_currency_code> | <billing_currency_code> | DEBIT_INITIAL    | FAILED             |

    Examples:
      | message_qualifier | transaction_amount | billing_amount | transaction_currency_code | transaction_currency | billing_currency_code | billing_currency | card_acceptor_country_code | available_balance | total_balance |
      | request           | 1000.01            | 1000.01        | 702                       | SGD                  | 702                   | SGD              | SG                         | 1000              | 1000          |
      | request           | 500                | 1000.01        | 826                       | GBP                  | 702                   | SGD              | GB                         | 1000              | 1000          |
      | request           | 1500               | 1500           | 702                       | SGD                  | 702                   | SGD              | SG                         | 1000              | 1000          |
      | request           | 750                | 1500           | 826                       | GBP                  | 702                   | SGD              | GB                         | 1000              | 1000          |

  Scenario Outline: Clowd9-Test debit authorization for verification check
    Given I build below transactions
      | transaction_identifier | message_type  | message_qualifier   | source |
      | T1                     | authorization | <message_qualifier> | VISA   |

    Then I set card objects in transaction context
      | transaction_identifier | card_identifier | card_form_factor | card_status |
      | T1                     | CardId1         | PHYSICAL         | active      |

    Then I set customer objects in transaction context
      | transaction_identifier | customer_identifier |
      | T1                     | CardAccId1          |

    Then I set transaction objects in transaction context
      | transaction_identifier | transaction_id | transaction_type | transaction_amount   | transaction_currency_code   | cardholder_billing_amount | cardholder_billing_currency_code | system_trace_audit_number | retrieval_reference_number | network_transaction_id | transmission_date | transmission_time | transaction_local_date | transaction_local_time | dcc_indicator | chip_indicator | pin_indicator | three_ds_indicator | partial_approval_supported |
      | T1                     | TxnId1         | 00               | <transaction_amount> | <transaction_currency_code> | <billing_amount>          | <billing_currency_code>          | STAN1                     | RRN1                       | NT1                    | 1206              | 182751            | 1206                   | 192748                 | n             | contact        | online_passed | n                  | n                          |

    Then I set acquirer objects in transaction context
      | transaction_identifier | card_acceptor_country_code | acquiring_institution_country_code | acquiring_institution_id_code | merchant_category_code | card_acceptor_terminal_id | card_acceptor_id | card_acceptor_name | card_acceptor_city |
      | T1                     | SG                         | 702                                | 843759                        | 6011                   | DUMMY_TERMINAL            | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason | case_type   |
      | T1                     | authorization | 0                    | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 000           | Approved        | <case_type> |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance> and total balance of <total_balance> for customerProfileId CPID1

    Examples:
      | message_qualifier | transaction_amount | billing_amount | transaction_currency_code | transaction_currency | billing_currency_code | billing_currency | available_balance | total_balance | case_type   |
      | request           | 0                  | 0              | 702                       | SGD                  | 702                   | SGD              | 1000              | 1000          | positive    |
      | notification      | 0                  | 0              | 702                       | SGD                  | 702                   | SGD              | 1000              | 1000          | bad_request |
      | request           | 0                  | 0              | 826                       | GBP                  | 702                   | SGD              | 1000              | 1000          | positive    |
      | notification      | 0                  | 0              | 826                       | GBP                  | 702                   | SGD              | 1000              | 1000          | bad_request |
      | request           | 0                  | 0              | 702                       | SGD                  | 826                   | GBP              | 1000              | 1000          | positive    |
      | notification      | 0                  | 0              | 702                       | SGD                  | 826                   | GBP              | 1000              | 1000          | bad_request |

  Scenario Outline: Clowd9-Test debit authorization request rejected with 119 Txn Forbidden to Cardholder when billing currency code is not 702 SGD
    Given I build below transactions
      | transaction_identifier | message_type  | message_qualifier   | source |
      | T1                     | authorization | <message_qualifier> | VISA   |

    Then I set card objects in transaction context
      | transaction_identifier | card_identifier | card_form_factor | card_status |
      | T1                     | CardId1         | PHYSICAL         | active      |

    Then I set customer objects in transaction context
      | transaction_identifier | customer_identifier |
      | T1                     | CardAccId1          |

    Then I set transaction objects in transaction context
      | transaction_identifier | transaction_id | transaction_type | transaction_amount   | transaction_currency_code   | cardholder_billing_amount   | cardholder_billing_currency_code   | system_trace_audit_number | retrieval_reference_number | network_transaction_id | transmission_date | transmission_time | transaction_local_date | transaction_local_time | dcc_indicator | chip_indicator | pin_indicator | three_ds_indicator | partial_approval_supported |
      | T1                     | TxnId1         | 00               | <transaction_amount> | <transaction_currency_code> | <cardholder_billing_amount> | <cardholder_billing_currency_code> | STAN1                     | RRN1                       | NT1                    | 1206              | 182751            | 1206                   | 192748                 | n             | contact        | online_passed | n                  | n                          |

    Then I set acquirer objects in transaction context
      | transaction_identifier | card_acceptor_country_code   | acquiring_institution_country_code | acquiring_institution_id_code | merchant_category_code | card_acceptor_terminal_id | card_acceptor_id | card_acceptor_name | card_acceptor_city |
      | T1                     | <card_acceptor_country_code> | <transaction_currency_code>        | 843759                        | 6011                   | DUMMY_TERMINAL            | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason             | case_type |
      | T1                     | authorization | 0                    | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 119           | Txn Forbidden to Cardholder | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance> and total balance of <total_balance> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | transaction_amount   | billing_amount   | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts |
      | T1                     | <transaction_amount> | <billing_amount> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_DECLINED      | T+30            |

    Examples:
      | message_qualifier | transaction_amount | billing_amount | transaction_currency_code | transaction_currency | billing_currency_code | billing_currency | cardholder_billing_amount | cardholder_billing_currency_code | card_acceptor_country_code | available_balance | total_balance | case_type |
      | request           | 100                | 100            | 826                       | GBP                  | 826                   | GBP              | 100                       | 826                              | GB                         | 1000              | 1000          | negative  |
      | request           | 100                | 100            | 826                       | GBP                  | 826                   | GBP              |                           |                                  | GB                         | 1000              | 1000          | negative  |
    # TODO: Add more tests where billing currency code is present but not SG

  Scenario Outline: Clowd9-Test debit authorization notification accepted with 091 Advice acknowledged when currency code is not 702 SGD
    Given I build below transactions
      | transaction_identifier | message_type  | message_qualifier   | source |
      | T1                     | authorization | <message_qualifier> | VISA   |

    Then I set card objects in transaction context
      | transaction_identifier | card_identifier | card_form_factor | card_status |
      | T1                     | CardId1         | PHYSICAL         | active      |

    Then I set customer objects in transaction context
      | transaction_identifier | customer_identifier |
      | T1                     | CardAccId1          |

    Then I set transaction objects in transaction context
      | transaction_identifier | transaction_id | transaction_type | transaction_amount   | transaction_currency_code   | cardholder_billing_amount   | cardholder_billing_currency_code   | system_trace_audit_number | retrieval_reference_number | network_transaction_id | transmission_date | transmission_time | transaction_local_date | transaction_local_time | dcc_indicator | chip_indicator | pin_indicator | three_ds_indicator | partial_approval_supported |
      | T1                     | TxnId1         | 00               | <transaction_amount> | <transaction_currency_code> | <cardholder_billing_amount> | <cardholder_billing_currency_code> | STAN1                     | RRN1                       | NT1                    | 1206              | 182751            | 1206                   | 192748                 | n             | contact        | online_passed | n                  | n                          |

    Then I set acquirer objects in transaction context
      | transaction_identifier | card_acceptor_country_code   | acquiring_institution_country_code | acquiring_institution_id_code | merchant_category_code | card_acceptor_terminal_id | card_acceptor_id | card_acceptor_name | card_acceptor_city |
      | T1                     | <card_acceptor_country_code> | <transaction_currency_code>        | 843759                        | 6011                   | DUMMY_TERMINAL            | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code   | cardholder_billing_currency | response_code | response_reason             | case_type |
      | T1                     | authorization | <transaction_amount> | <transaction_currency_code> | <transaction_currency> | <cardholder_billing_currency_code> | <billing_currency>          | 119           | Txn Forbidden to Cardholder | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance> and total balance of <total_balance> for customerProfileId CPID1

    Examples:
      | message_qualifier | transaction_amount | cardholder_billing_amount | transaction_currency_code | cardholder_billing_currency_code | transaction_currency | billing_currency | card_acceptor_country_code | available_balance | total_balance |
      | notification      | 100                |                           | 826                       |                                  | GBP                  | GBP              | GB                         | 1000              | 1000          |
    # TODO: Add more tests where billing currency code is present but

  Scenario Outline: Clowd9-Test debit authorization rejected with bad request for invalid currency code and amounts
    Given I build below transactions
      | transaction_identifier | message_type  | message_qualifier   | source |
      | T1                     | authorization | <message_qualifier> | VISA   |

    Then I set card objects in transaction context
      | transaction_identifier | card_identifier | card_form_factor | card_status   |
      | T1                     | CardId1         | PHYSICAL         | <card_status> |

    Then I set customer objects in transaction context
      | transaction_identifier | customer_identifier |
      | T1                     | CardAccId1          |

    Then I set transaction objects in transaction context
      | transaction_identifier | transaction_id | transaction_type | transaction_amount   | transaction_currency_code   | cardholder_billing_amount | cardholder_billing_currency_code | system_trace_audit_number | retrieval_reference_number | network_transaction_id | transmission_date | transmission_time | transaction_local_date | transaction_local_time | dcc_indicator | chip_indicator | pin_indicator | three_ds_indicator | partial_approval_supported |
      | T1                     | TxnId1         | 00               | <transaction_amount> | <transaction_currency_code> | <billing_amount>          | <billing_currency_code>          | STAN1                     | RRN1                       | NT1                    | 1206              | 182751            | 1206                   | 192748                 | n             | contact        | online_passed | n                  | n                          |

    Then I set acquirer objects in transaction context
      | transaction_identifier | acquiring_institution_id_code | card_acceptor_country_code   | acquiring_institution_country_code | merchant_category_code | card_acceptor_terminal_id | card_acceptor_id | card_acceptor_name | card_acceptor_city |
      | T1                     | 843759                        | <card_acceptor_country_code> | <transaction_currency_code>        | 6011                   | DUMMY_TERMINAL            | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | case_type   |
      | T1                     | bad_request |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance> and total balance of <total_balance> for customerProfileId CPID1

    Examples:
      | message_qualifier | card_status | transaction_amount | billing_amount | transaction_currency_code | transaction_currency | billing_currency_code | billing_currency | card_acceptor_country_code | available_balance | total_balance |
      | request           | active      |                    |                | 555                       | USD                  | 702                   | SGD              | SZ                         | 1000              | 1000          |
      | request           | active      |                    |                | 356                       | INR                  | 555                   | USD              |                            | 1000              | 1000          |
      | request           | active      | -100               | -100           | 702                       | SGD                  | 702                   | SGD              | SZ                         | 1000              | 1000          |

  Scenario Outline: Clowd9-Test debit authorization request is rejected with 119 Txn Forbidden to Cardholder when currency code is not supported by bank account
    Given I build below transactions
      | transaction_identifier | message_type  | message_qualifier | source |
      | T1                     | authorization | request           | VISA   |

    Then I set card objects in transaction context
      | transaction_identifier | card_identifier | card_form_factor | card_status   |
      | T1                     | CardId1         | PHYSICAL         | <card_status> |

    Then I set customer objects in transaction context
      | transaction_identifier | customer_identifier |
      | T1                     | CardAccId1          |

    Then I set transaction objects in transaction context
      | transaction_identifier | transaction_id | transaction_type | transaction_amount   | transaction_currency_code   | cardholder_billing_amount | cardholder_billing_currency_code | system_trace_audit_number | retrieval_reference_number | network_transaction_id | transmission_date | transmission_time | transaction_local_date | transaction_local_time | dcc_indicator | chip_indicator | pin_indicator | three_ds_indicator | partial_approval_supported |
      | T1                     | TxnId1         | 00               | <transaction_amount> | <transaction_currency_code> | <billing_amount>          | <billing_currency_code>          | STAN1                     | RRN1                       | NT1                    | 1206              | 182751            | 1206                   | 192748                 | n             | contact        | online_passed | n                  | n                          |

    Then I set acquirer objects in transaction context
      | transaction_identifier | acquiring_institution_id_code | card_acceptor_country_code   | acquiring_institution_country_code | merchant_category_code | card_acceptor_terminal_id | card_acceptor_id | card_acceptor_name | card_acceptor_city |
      | T1                     | 843759                        | <card_acceptor_country_code> | <transaction_currency_code>        | 6011                   | DUMMY_TERMINAL            | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason             | case_type |
      | T1                     | authorization | 0                    | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 119           | Txn Forbidden to Cardholder | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance> and total balance of <total_balance> for customerProfileId CPID1

    Examples:
      | card_status | transaction_amount | billing_amount | transaction_currency_code | transaction_currency | billing_currency_code | billing_currency | card_acceptor_country_code | available_balance | total_balance |
      | active      | 100                | 100            | 356                       | INR                  | 826                   | GBP              | MT                         | 1000              | 1000          |

  Scenario Outline: Clowd9-Test debit authorization notification is approved with 091 Advice acknowledged when currency code is not supported by bank account
    Given I build below transactions
      | transaction_identifier | message_type  | message_qualifier   | source |
      | T1                     | authorization | <message_qualifier> | VISA   |

    Then I set card objects in transaction context
      | transaction_identifier | card_identifier | card_form_factor | card_status   |
      | T1                     | CardId1         | PHYSICAL         | <card_status> |

    Then I set customer objects in transaction context
      | transaction_identifier | customer_identifier |
      | T1                     | CardAccId1          |

    Then I set transaction objects in transaction context
      | transaction_identifier | transaction_id | transaction_type | transaction_amount   | transaction_currency_code   | cardholder_billing_amount | cardholder_billing_currency_code | system_trace_audit_number | retrieval_reference_number | network_transaction_id | transmission_date | transmission_time | transaction_local_date | transaction_local_time | dcc_indicator | chip_indicator | pin_indicator | three_ds_indicator | partial_approval_supported |
      | T1                     | TxnId1         | 00               | <transaction_amount> | <transaction_currency_code> | <billing_amount>          | <billing_currency_code>          | STAN1                     | RRN1                       | NT1                    | 1206              | 182751            | 1206                   | 192748                 | n             | contact        | online_passed | n                  | n                          |

    Then I set acquirer objects in transaction context
      | transaction_identifier | acquiring_institution_id_code | card_acceptor_country_code   | acquiring_institution_country_code | merchant_category_code | card_acceptor_terminal_id | card_acceptor_id | card_acceptor_name | card_acceptor_city |
      | T1                     | 843759                        | <card_acceptor_country_code> | <transaction_currency_code>        | 6011                   | DUMMY_TERMINAL            | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason             | case_type |
      | T1                     | authorization | <transaction_amount> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 119           | Txn Forbidden to Cardholder | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance> and total balance of <total_balance> for customerProfileId CPID1

    Examples:
      | message_qualifier | card_status | transaction_amount | billing_amount | transaction_currency_code | transaction_currency | billing_currency_code | billing_currency | card_acceptor_country_code | available_balance | total_balance |
      | notification      | active      | 100                | 100            | 356                       | INR                  | 826                   | GBP              | MT                         | 1000              | 1000          |

  Scenario Outline: Clowd9-Test debit authorization request accepted with 000 Approved for supported transaction types
    Given I build below transactions
      | transaction_identifier | message_type  | message_qualifier | source |
      | T1                     | authorization | request           | VISA   |

    Then I set card objects in transaction context
      | transaction_identifier | card_identifier | card_form_factor | card_status |
      | T1                     | CardId1         | PHYSICAL         | active      |

    Then I set customer objects in transaction context
      | transaction_identifier | customer_identifier |
      | T1                     | CardAccId1          |

    Then I set transaction objects in transaction context
      | transaction_identifier | transaction_id | transaction_type   | transaction_amount | transaction_currency_code | cardholder_billing_amount | cardholder_billing_currency_code | system_trace_audit_number | retrieval_reference_number | network_transaction_id | transmission_date | transmission_time | transaction_local_date | transaction_local_time | dcc_indicator | chip_indicator | pin_indicator | three_ds_indicator | partial_approval_supported |
      | T1                     | TxnId1         | <transaction_type> | 100                | 702                       | 100                       | 702                              | STAN1                     | RRN1                       | NT1                    | 1206              | 182751            | 1206                   | 192748                 | n             | contact        | online_passed | n                  | n                          |

    Then I set acquirer objects in transaction context
      | transaction_identifier | acquiring_institution_id_code | card_acceptor_country_code | acquiring_institution_country_code | merchant_category_code | card_acceptor_terminal_id | card_acceptor_id | card_acceptor_name | card_acceptor_city |
      | T1                     | 843759                        | SG                         | 702                                | 6011                   | DUMMY_TERMINAL            | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount | transaction_currency_code | transaction_currency | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason | case_type |
      | T1                     | authorization | 0                    | 702                       | SGD                  | 702                              | SGD                         | 000           | Approved        | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of 900 and total balance of 1000 for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount | billing_amount | tx_currency_code | transaction_currency | billing_currency_code | billing_currency | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T1                     | VALID_UUID          | 100                | 100            | 702              | SGD                  | 702                   | SGD              | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount | billing_amount | tx_currency_code | billing_currency_code | transaction_type | transaction_status |
      | T1                     | TxnId1          | 100                | 100            | 702              | 702                   | DEBIT_INITIAL    | COMPLETED          |

    Examples:
      | transaction_type |
      | 00               |
      | 30               |
      | 50               |
      | 70               |
      | 71               |

  Scenario Outline: Clowd9-Test debit authorization request declined with 100 Do Not Honour for unsupported transaction types
    Given I build below transactions
      | transaction_identifier | message_type  | message_qualifier | source |
      | T1                     | authorization | request           | VISA   |

    Then I set card objects in transaction context
      | transaction_identifier | card_identifier | card_form_factor | card_status |
      | T1                     | CardId1         | PHYSICAL         | active      |

    Then I set customer objects in transaction context
      | transaction_identifier | customer_identifier |
      | T1                     | CardAccId1          |

    Then I set transaction objects in transaction context
      | transaction_identifier | transaction_id | transaction_type   | transaction_amount | transaction_currency_code | cardholder_billing_amount | cardholder_billing_currency_code | system_trace_audit_number | retrieval_reference_number | network_transaction_id | transmission_date | transmission_time | transaction_local_date | transaction_local_time | dcc_indicator | chip_indicator | pin_indicator | three_ds_indicator | partial_approval_supported |
      | T1                     | TxnId1         | <transaction_type> | 100                | 356                       | 100                       | 702                              | STAN1                     | RRN1                       | NT1                    | 1206              | 182751            | 1206                   | 192748                 | n             | contact        | online_passed | n                  | n                          |

    Then I set acquirer objects in transaction context
      | transaction_identifier | acquiring_institution_id_code | card_acceptor_country_code | acquiring_institution_country_code | merchant_category_code | card_acceptor_terminal_id | card_acceptor_id | card_acceptor_name | card_acceptor_city |
      | T1                     | 843759                        | MT                         | 356                                | 6011                   | DUMMY_TERMINAL            | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | is_empty_service_tx_id | authorized_tx_amount | transaction_currency_code | transaction_currency | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason | case_type |
      | T1                     | authorization | true                   | 0                    | 356                       | INR                  | 702                              | SGD                         | 100           | Do Not Honour   | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of 1000 and total balance of 1000 for customerProfileId CPID1

    Examples:
      | transaction_type |
      | 01               |
      | 09               |
      | 10               |
      | 11               |

  Scenario Outline: Clowd9-Test debit authorization request is approved and the transaction is reverted when authorization notification arrives with 100 Do Not Honour
    Given I build below transactions
      | transaction_identifier | message_type  | message_qualifier | source |
      | T1                     | authorization | request           | VISA   |
      | T2                     | authorization | notification      | VISA   |

    Then I set card objects in transaction context
      | transaction_identifier | card_identifier | card_form_factor | card_status |
      | T1                     | CardId1         | PHYSICAL         | active      |
      | T2                     | CardId1         | PHYSICAL         | active      |

    Then I set customer objects in transaction context
      | transaction_identifier | customer_identifier |
      | T1                     | CardAccId1          |
      | T2                     | CardAccId1          |

    Then I set transaction objects in transaction context
      | transaction_identifier | transaction_id | transaction_type | transaction_amount   | transaction_currency_code   | cardholder_billing_amount | cardholder_billing_currency_code | system_trace_audit_number | retrieval_reference_number | network_transaction_id | transmission_date | transmission_time | transaction_local_date | transaction_local_time | dcc_indicator | chip_indicator | pin_indicator | three_ds_indicator | partial_approval_supported |
      | T1                     | TxnId1         | 00               | <transaction_amount> | <transaction_currency_code> | <billing_amount>          | <billing_currency_code>          | STAN1                     | RRN1                       | NT1                    | 1206              | 182751            | 1206                   | 192748                 | n             | contact        | online_passed | n                  | n                          |
      | T2                     | TxnId2         | 00               | <transaction_amount> | <transaction_currency_code> | <billing_amount>          | <billing_currency_code>          | STAN2                     | RRN1                       | NT2                    | 0329              | 142654            | 0329                   | 142654                 | n             | contact        | online_passed | n                  | n                          |

    Then I set status in transaction context
      | transaction_identifier | response_code | response_source | response_reason |
      | T1                     | 000           | Scheme          | Approved        |
      | T2                     | 100           | Scheme          | Do Not Honour   |

    Then I set acquirer objects in transaction context
      | transaction_identifier | acquiring_institution_id_code | card_acceptor_country_code   | acquiring_institution_country_code | merchant_category_code | card_acceptor_terminal_id | card_acceptor_id | card_acceptor_name | card_acceptor_city |
      | T1                     | 843759                        | <card_acceptor_country_code> | <transaction_currency_code>        | 6011                   | DUMMY_TERMINAL            | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |
      | T2                     | 843759                        | <card_acceptor_country_code> | <transaction_currency_code>        | 6011                   | DUMMY_TERMINAL            | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason | case_type |
      | T1                     | authorization | <transaction_amount> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 000           | Approved        | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_1> and total balance of 1000 for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount   | billing_amount   | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T1                     | VALID_UUID          | <transaction_amount> | <billing_amount> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount   | billing_amount   | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T1                     | TxnId1          | <transaction_amount> | <billing_amount> | <transaction_currency_code> | <billing_currency_code> | DEBIT_INITIAL    | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason | case_type |
      | T2                     | authorization | 0                    | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 000           | Approved        | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of 1000 and total balance of 1000 for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount | billing_amount | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type    |
      | T2                     | VALID_UUID          | 0                  | 0              | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_CLOSED        | T+30            | SCHEME_STAND_IN |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount | billing_amount | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T2                     | TxnId2          | 0                  | 0              | <transaction_currency_code> | <billing_currency_code> | DEBIT_CLOSED     | COMPLETED          |

    Examples:
      | transaction_amount | billing_amount | transaction_currency_code | transaction_currency | billing_currency_code | billing_currency | card_acceptor_country_code | available_balance_1 |
      | 100                | 100            | 702                       | SGD                  | 702                   | SGD              | SG                         | 900                 |
      | 100                | 200            | 826                       | GBP                  | 702                   | SGD              | GB                         | 800                 |

  Scenario Outline: Clowd9-Test debit authorizations approved for partial reversal
    Given I build below transactions
      | transaction_identifier | message_type  | message_qualifier      | source |
      | T1                     | authorization | <T1_message_qualifier> | VISA   |
      | T2                     | reversal      | <T2_message_qualifier> | VISA   |

    Then I set card objects in transaction context
      | transaction_identifier | card_identifier | card_form_factor | card_status |
      | T1                     | CardId1         | PHYSICAL         | active      |
      | T2                     | CardId1         | PHYSICAL         | active      |

    Then I set customer objects in transaction context
      | transaction_identifier | customer_identifier |
      | T1                     | CardAccId1          |
      | T2                     | CardAccId1          |

    Then I set transaction objects in transaction context
      | transaction_identifier | transaction_id | reversal_type | transaction_type | transaction_amount   | transaction_currency_code   | cardholder_billing_amount | cardholder_billing_currency_code | system_trace_audit_number | retrieval_reference_number | network_transaction_id | transmission_date | transmission_time | transaction_local_date | transaction_local_time | dcc_indicator | chip_indicator | pin_indicator | three_ds_indicator | partial_approval_supported |
      | T1                     | TxnId1         |               | 00               | <transaction_amount> | <transaction_currency_code> | <billing_amount>          | <billing_currency_code>          | STAN1                     | RRN1                       | NT1                    | 1206              | 182751            | 1206                   | 192748                 | n             | contact        | online_passed | n                  | n                          |
      | T2                     | TxnId2         | PARTIAL       | 00               | <transaction_amount> | <transaction_currency_code> | <billing_amount>          | <billing_currency_code>          | STAN2                     | RRN1                       | NT2                    | 0329              | 142654            | 0329                   | 142654                 | n             | contact        | online_passed | n                  | n                          |

    Then I set update in transaction context
      | transaction_identifier | original_transaction_id | original_message_type | original_message_qualifier | original_transaction_amount | actual_transaction_amount   | original_system_trace_audit_number | original_retrieval_reference_number | original_transmission_date | original_transmission_time |
      | T2                     | TxnId1                  | authorization         | <T1_message_qualifier>     | <transaction_amount>        | <actual_transaction_amount> | STAN1                              | RRN1                                | 1206                       | 182751                     |

    Then I set status in transaction context
      | transaction_identifier | response_code | response_source | response_reason |
      | T2                     | 000           | Scheme          | Approved        |

    Then I set acquirer objects in transaction context
      | transaction_identifier | acquiring_institution_id_code | card_acceptor_country_code   | acquiring_institution_country_code | merchant_category_code | card_acceptor_terminal_id | card_acceptor_id | card_acceptor_name | card_acceptor_city |
      | T1                     | 843759                        | <card_acceptor_country_code> | <transaction_currency_code>        | 6011                   | DUMMY_TERMINAL            | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |
      | T2                     | 843759                        | <card_acceptor_country_code> | <transaction_currency_code>        | 6011                   | DUMMY_TERMINAL            | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code      | response_reason      | case_type |
      | T1                     | authorization | <transaction_amount> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | <T1_response_code> | <T1_response_reason> | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_1> and total balance of <total_balance> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount   | billing_amount   | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T1                     | VALID_UUID          | <transaction_amount> | <billing_amount> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount   | billing_amount   | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T1                     | TxnId1          | <transaction_amount> | <billing_amount> | <transaction_currency_code> | <billing_currency_code> | DEBIT_INITIAL    | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type | authorized_tx_amount        | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code      | response_reason      | case_type |
      | T2                     | reversal     | <actual_transaction_amount> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | <T2_response_code> | <T2_response_reason> | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_2> and total balance of <total_balance> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount          | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T2                     | VALID_UUID          | <actual_transaction_amount> | <actual_billing_amount> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount          | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T2                     | TxnId2          | <actual_transaction_amount> | <actual_billing_amount> | <transaction_currency_code> | <billing_currency_code> | DEBIT_REVERSAL   | COMPLETED          |

    Examples:
      | T1_message_qualifier | T2_message_qualifier | transaction_amount | billing_amount | actual_transaction_amount | actual_billing_amount | transaction_currency_code | transaction_currency | billing_currency_code | billing_currency | card_acceptor_country_code | available_balance_1 | available_balance_2 | total_balance | T1_response_code | T1_response_reason  | T2_response_code | T2_response_reason  |
      | request              | request              | 100                | 100            | 80                        | 80                    | 702                       | SGD                  | 702                   | SGD              | SG                         | 900                 | 920                 | 1000          | 000              | Approved            | 000              | Approved            |
      | request              | request              | 50.45              | 50.45          | 40.37                     | 40.37                 | 702                       | SGD                  | 702                   | SGD              | SG                         | 949.55              | 959.63              | 1000          | 000              | Approved            | 000              | Approved            |
      | request              | notification         | 0.97               | 0.97           | 0.73                      | 0.73                  | 702                       | SGD                  | 702                   | SGD              | SG                         | 999.03              | 999.27              | 1000          | 000              | Approved            | 091              | Advice acknowledged |
      | request              | notification         | 100.1              | 100.1          | 100.09                    | 100.09                | 702                       | SGD                  | 702                   | SGD              | SG                         | 899.9               | 899.91              | 1000          | 000              | Approved            | 091              | Advice acknowledged |
      | notification         | request              | 1000               | 1000           | 0.01                      | 0.01                  | 702                       | SGD                  | 702                   | SGD              | SG                         | 0                   | 999.99              | 1000          | 091              | Advice acknowledged | 000              | Approved            |
      | notification         | request              | 1100               | 1100           | 1000                      | 1000                  | 702                       | SGD                  | 702                   | SGD              | SG                         | -100                | 0                   | 1000          | 091              | Advice acknowledged | 000              | Approved            |
      | notification         | notification         | 1100               | 1100           | 1000                      | 1000                  | 702                       | SGD                  | 702                   | SGD              | SG                         | -100                | 0                   | 1000          | 091              | Advice acknowledged | 091              | Advice acknowledged |
      | request              | request              | 50                 | 100            | 40                        | 80                    | 826                       | GBP                  | 702                   | SGD              | GB                         | 900                 | 920                 | 1000          | 000              | Approved            | 000              | Approved            |
      | request              | request              | 1                  | 100            | 0.5                       | 50                    | 826                       | GBP                  | 702                   | SGD              | GB                         | 900                 | 950                 | 1000          | 000              | Approved            | 000              | Approved            |
      | request              | notification         | 10.80              | 108            | 5.40                      | 54                    | 826                       | GBP                  | 702                   | SGD              | GB                         | 892                 | 946                 | 1000          | 000              | Approved            | 091              | Advice acknowledged |
      | request              | notification         | 100                | 200            | 40                        | 80                    | 826                       | GBP                  | 702                   | SGD              | GB                         | 800                 | 920                 | 1000          | 000              | Approved            | 091              | Advice acknowledged |
      | notification         | notification         | 50                 | 100            | 40                        | 80                    | 826                       | GBP                  | 702                   | SGD              | GB                         | 900                 | 920                 | 1000          | 091              | Advice acknowledged | 091              | Advice acknowledged |
      | notification         | request              | 50                 | 100            | 40                        | 80                    | 826                       | GBP                  | 702                   | SGD              | GB                         | 900                 | 920                 | 1000          | 091              | Advice acknowledged | 000              | Approved            |
      | request              | request              | 50                 | 100            | 1                         | 2                     | 826                       | GBP                  | 702                   | SGD              | GB                         | 900                 | 998                 | 1000          | 000              | Approved            | 000              | Approved            |

  Scenario Outline: Clowd9-Test a full debit reversal is approved
    Given I build below transactions
      | transaction_identifier | message_type  | message_qualifier      | source |
      | T1                     | authorization | <T1_message_qualifier> | VISA   |
      | T2                     | reversal      | <T2_message_qualifier> | VISA   |

    Then I set card objects in transaction context
      | transaction_identifier | card_identifier | card_form_factor | card_status |
      | T1                     | CardId1         | PHYSICAL         | active      |
      | T2                     | CardId1         | PHYSICAL         | active      |

    Then I set customer objects in transaction context
      | transaction_identifier | customer_identifier |
      | T1                     | CardAccId1          |
      | T2                     | CardAccId1          |

    Then I set transaction objects in transaction context
      | transaction_identifier | transaction_id | reversal_type | transaction_type | transaction_amount        | transaction_currency_code   | cardholder_billing_amount | cardholder_billing_currency_code | system_trace_audit_number | retrieval_reference_number | network_transaction_id | transmission_date | transmission_time | transaction_local_date | transaction_local_time | dcc_indicator | chip_indicator | pin_indicator | three_ds_indicator | partial_approval_supported |
      | T1                     | TxnId1         |               | 00               | <auth_transaction_amount> | <transaction_currency_code> | <auth_billing_amount>     | <billing_currency_code>          | STAN1                     | RRN1                       | NT1                    | 1206              | 182751            | 1206                   | 192748                 | n             | contact        | online_passed | n                  | n                          |
      | T2                     | TxnId2         | FULL          | 00               | <auth_transaction_amount> | <transaction_currency_code> | <auth_billing_amount>     | <billing_currency_code>          | STAN2                     | RRN1                       | NT2                    | 0329              | 142654            | 0329                   | 142654                 | n             | contact        | online_passed | n                  | n                          |

    Then I set update in transaction context
      | transaction_identifier | original_transaction_id | original_message_type | original_message_qualifier | original_transaction_amount | original_system_trace_audit_number | original_retrieval_reference_number | original_transmission_date | original_transmission_time |
      | T2                     | TxnId1                  | authorization         | <T1_message_qualifier>     | <auth_transaction_amount>   | STAN1                              | RRN1                                | 1206                       | 182751                     |

    Then I set status in transaction context
      | transaction_identifier | response_code | response_source | response_reason |
      | T2                     | 000           | Scheme          | Approved        |

    Then I set acquirer objects in transaction context
      | transaction_identifier | acquiring_institution_id_code | card_acceptor_country_code   | acquiring_institution_country_code | merchant_category_code | card_acceptor_terminal_id | card_acceptor_id | card_acceptor_name | card_acceptor_city |
      | T1                     | 843759                        | <card_acceptor_country_code> | <transaction_currency_code>        | 6011                   | DUMMY_TERMINAL            | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |
      | T2                     | 843759                        | <card_acceptor_country_code> | <transaction_currency_code>        | 6011                   | DUMMY_TERMINAL            | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount      | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code      | response_reason      | case_type |
      | T1                     | authorization | <auth_transaction_amount> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | <T1_response_code> | <T1_response_reason> | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_1> and total balance of <total_balance> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount        | billing_amount        | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T1                     | VALID_UUID          | <auth_transaction_amount> | <auth_billing_amount> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount        | billing_amount        | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T1                     | TxnId1          | <auth_transaction_amount> | <auth_billing_amount> | <transaction_currency_code> | <billing_currency_code> | DEBIT_INITIAL    | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type | authorized_tx_amount | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code      | response_reason      | case_type |
      | T2                     | reversal     | 0                    | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | <T2_response_code> | <T2_response_reason> | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <total_balance> and total balance of <total_balance> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount | billing_amount | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status   | release_auth_ts | release_type     |
      | T2                     | VALID_UUID          | 0                  | 0              | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | TRANSACTION_REVERTED | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount | billing_amount | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T2                     | TxnId2          | 0                  | 0              | <transaction_currency_code> | <billing_currency_code> | DEBIT_REVERSAL   | COMPLETED          |

    Examples:
      | T1_message_qualifier | T2_message_qualifier | auth_transaction_amount | auth_billing_amount | transaction_currency_code | transaction_currency | billing_currency_code | billing_currency | card_acceptor_country_code | available_balance_1 | total_balance | T1_response_code | T1_response_reason  | T2_response_code | T2_response_reason  |
      | request              | request              | 100                     | 100                 | 702                       | SGD                  | 702                   | SGD              | SG                         | 900                 | 1000          | 000              | Approved            | 000              | Approved            |
      | request              | notification         | 20                      | 45                  | 826                       | GBP                  | 702                   | SGD              | GB                         | 955                 | 1000          | 000              | Approved            | 091              | Advice acknowledged |
      | notification         | request              | 500                     | 1000.01             | 826                       | GBP                  | 702                   | SGD              | GB                         | -0.01               | 1000          | 091              | Advice acknowledged | 000              | Approved            |
      | notification         | notification         | 500                     | 1000.01             | 826                       | GBP                  | 702                   | SGD              | GB                         | -0.01               | 1000          | 091              | Advice acknowledged | 091              | Advice acknowledged |

  Scenario Outline: Clowd9-Test a full debit reversal is approved using Clowd9's original transaction ID when RRN doesn't match
    Given I build below transactions
      | transaction_identifier | message_type  | message_qualifier      | source |
      | T1                     | authorization | <T1_message_qualifier> | VISA   |
      | T2                     | reversal      | <T2_message_qualifier> | VISA   |

    Then I set card objects in transaction context
      | transaction_identifier | card_identifier | card_form_factor | card_status |
      | T1                     | CardId1         | PHYSICAL         | active      |
      | T2                     | CardId1         | PHYSICAL         | active      |

    Then I set customer objects in transaction context
      | transaction_identifier | customer_identifier |
      | T1                     | CardAccId1          |
      | T2                     | CardAccId1          |

    Then I set transaction objects in transaction context
      | transaction_identifier | transaction_id | reversal_type | transaction_type | transaction_amount        | transaction_currency_code   | cardholder_billing_amount | cardholder_billing_currency_code | system_trace_audit_number | retrieval_reference_number | network_transaction_id | transmission_date | transmission_time | transaction_local_date | transaction_local_time | dcc_indicator | chip_indicator | pin_indicator | three_ds_indicator | partial_approval_supported |
      | T1                     | TxnId1         |               | 00               | <auth_transaction_amount> | <transaction_currency_code> | <auth_billing_amount>     | <billing_currency_code>          | STAN1                     | RRN1                       | NT1                    | 1206              | 182751            | 1206                   | 192748                 | n             | contact        | online_passed | n                  | n                          |
      | T2                     | TxnId2         | FULL          | 00               | <auth_transaction_amount> | <transaction_currency_code> | <auth_billing_amount>     | <billing_currency_code>          | STAN2                     | RRN2                       | NT2                    | 0329              | 142654            | 0329                   | 142654                 | n             | contact        | online_passed | n                  | n                          |

    Then I set update in transaction context
      | transaction_identifier | original_transaction_id | original_message_type | original_message_qualifier | original_transaction_amount | original_system_trace_audit_number | original_retrieval_reference_number | original_transmission_date | original_transmission_time |
      | T2                     | TxnId1                  | authorization         | <T1_message_qualifier>     | <auth_transaction_amount>   | STAN1                              | RRN1                                | 1206                       | 182751                     |

    Then I set status in transaction context
      | transaction_identifier | response_code | response_source | response_reason |
      | T2                     | 000           | Scheme          | Approved        |

    Then I set acquirer objects in transaction context
      | transaction_identifier | acquiring_institution_id_code | card_acceptor_country_code   | acquiring_institution_country_code | merchant_category_code | card_acceptor_terminal_id | card_acceptor_id | card_acceptor_name | card_acceptor_city |
      | T1                     | 843759                        | <card_acceptor_country_code> | <transaction_currency_code>        | 6011                   | DUMMY_TERMINAL            | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |
      | T2                     | 843759                        | <card_acceptor_country_code> | <transaction_currency_code>        | 6011                   | DUMMY_TERMINAL            | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount      | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code      | response_reason      | case_type |
      | T1                     | authorization | <auth_transaction_amount> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | <T1_response_code> | <T1_response_reason> | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_1> and total balance of <total_balance> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount        | billing_amount        | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T1                     | VALID_UUID          | <auth_transaction_amount> | <auth_billing_amount> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount        | billing_amount        | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T1                     | TxnId1          | <auth_transaction_amount> | <auth_billing_amount> | <transaction_currency_code> | <billing_currency_code> | DEBIT_INITIAL    | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type | authorized_tx_amount | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code      | response_reason      | case_type |
      | T2                     | reversal     | 0                    | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | <T2_response_code> | <T2_response_reason> | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <total_balance> and total balance of <total_balance> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount | billing_amount | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status   | release_auth_ts | release_type     |
      | T2                     | VALID_UUID          | 0                  | 0              | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | TRANSACTION_REVERTED | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount | billing_amount | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T2                     | TxnId2          | 0                  | 0              | <transaction_currency_code> | <billing_currency_code> | DEBIT_REVERSAL   | COMPLETED          |

    Examples:
      | T1_message_qualifier | T2_message_qualifier | auth_transaction_amount | auth_billing_amount | transaction_currency_code | transaction_currency | billing_currency_code | billing_currency | card_acceptor_country_code | available_balance_1 | total_balance | T1_response_code | T1_response_reason  | T2_response_code | T2_response_reason  |
      | request              | request              | 100                     | 100                 | 702                       | SGD                  | 702                   | SGD              | SG                         | 900                 | 1000          | 000              | Approved            | 000              | Approved            |
      | request              | notification         | 20                      | 45                  | 826                       | GBP                  | 702                   | SGD              | GB                         | 955                 | 1000          | 000              | Approved            | 091              | Advice acknowledged |
      | notification         | request              | 500                     | 1000.01             | 826                       | GBP                  | 702                   | SGD              | GB                         | -0.01               | 1000          | 091              | Advice acknowledged | 000              | Approved            |
      | notification         | notification         | 500                     | 1000.01             | 826                       | GBP                  | 702                   | SGD              | GB                         | -0.01               | 1000          | 091              | Advice acknowledged | 091              | Advice acknowledged |

  Scenario Outline: Clowd9-Test a full debit reversal is approved using NTID when Clowd9's original transaction ID and RRN doesn't match
    Given I build below transactions
      | transaction_identifier | message_type  | message_qualifier      | source |
      | T1                     | authorization | <T1_message_qualifier> | VISA   |
      | T2                     | reversal      | <T2_message_qualifier> | VISA   |
    Then I set card objects in transaction context
      | transaction_identifier | card_identifier | card_form_factor | card_status |
      | T1                     | CardId1         | PHYSICAL         | active      |
      | T2                     | CardId1         | PHYSICAL         | active      |

    Then I set customer objects in transaction context
      | transaction_identifier | customer_identifier |
      | T1                     | CardAccId1          |
      | T2                     | CardAccId1          |

    Then I set transaction objects in transaction context
      | transaction_identifier | transaction_id | reversal_type | transaction_type | transaction_amount        | transaction_currency_code   | cardholder_billing_amount | cardholder_billing_currency_code | system_trace_audit_number | retrieval_reference_number | network_transaction_id | transmission_date | transmission_time | transaction_local_date | transaction_local_time | dcc_indicator | chip_indicator | pin_indicator | three_ds_indicator | partial_approval_supported |
      | T1                     | TxnId1         |               | 00               | <auth_transaction_amount> | <transaction_currency_code> | <auth_billing_amount>     | <billing_currency_code>          | STAN1                     | RRN1                       | NT1                    | 1206              | 182751            | 1206                   | 192748                 | n             | contact        | online_passed | n                  | n                          |
      | T2                     | TxnId2         | FULL          | 00               | <auth_transaction_amount> | <transaction_currency_code> | <auth_billing_amount>     | <billing_currency_code>          | STAN2                     | RRN2                       | NT1                    | 0329              | 142654            | 0329                   | 142654                 | n             | contact        | online_passed | n                  | n                          |

    Then I set update in transaction context
      | transaction_identifier | original_transaction_id | original_message_type | original_message_qualifier | original_transaction_amount | original_system_trace_audit_number | original_retrieval_reference_number | original_transmission_date | original_transmission_time |
      | T2                     | TxnId3                  | authorization         | <T1_message_qualifier>     | <auth_transaction_amount>   | STAN1                              | RRN1                                | 1206                       | 182751                     |

    Then I set status in transaction context
      | transaction_identifier | response_code | response_source | response_reason |
      | T2                     | 000           | Scheme          | Approved        |

    Then I set acquirer objects in transaction context
      | transaction_identifier | acquiring_institution_id_code | card_acceptor_country_code   | acquiring_institution_country_code | merchant_category_code | card_acceptor_terminal_id | card_acceptor_id | card_acceptor_name | card_acceptor_city |
      | T1                     | 843759                        | <card_acceptor_country_code> | <transaction_currency_code>        | 6011                   | DUMMY_TERMINAL            | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |
      | T2                     | 843759                        | <card_acceptor_country_code> | <transaction_currency_code>        | 6011                   | DUMMY_TERMINAL            | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount      | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code      | response_reason      | case_type |
      | T1                     | authorization | <auth_transaction_amount> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | <T1_response_code> | <T1_response_reason> | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_1> and total balance of <total_balance> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount        | billing_amount        | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T1                     | VALID_UUID          | <auth_transaction_amount> | <auth_billing_amount> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount        | billing_amount        | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T1                     | TxnId1          | <auth_transaction_amount> | <auth_billing_amount> | <transaction_currency_code> | <billing_currency_code> | DEBIT_INITIAL    | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type | authorized_tx_amount | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code      | response_reason      | case_type |
      | T2                     | reversal     | 0                    | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | <T2_response_code> | <T2_response_reason> | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <total_balance> and total balance of <total_balance> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount | billing_amount | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status   | release_auth_ts | release_type     |
      | T2                     | VALID_UUID          | 0                  | 0              | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | TRANSACTION_REVERTED | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount | billing_amount | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T2                     | TxnId2          | 0                  | 0              | <transaction_currency_code> | <billing_currency_code> | DEBIT_REVERSAL   | COMPLETED          |

    Examples:
      | T1_message_qualifier | T2_message_qualifier | auth_transaction_amount | auth_billing_amount | transaction_currency_code | transaction_currency | billing_currency_code | billing_currency | card_acceptor_country_code | available_balance_1 | total_balance | T1_response_code | T1_response_reason  | T2_response_code | T2_response_reason  |
      | request              | request              | 100                     | 100                 | 702                       | SGD                  | 702                   | SGD              | SG                         | 900                 | 1000          | 000              | Approved            | 000              | Approved            |
      | request              | notification         | 20                      | 45                  | 826                       | GBP                  | 702                   | SGD              | GB                         | 955                 | 1000          | 000              | Approved            | 091              | Advice acknowledged |
      | notification         | request              | 500                     | 1000.01             | 826                       | GBP                  | 702                   | SGD              | GB                         | -0.01               | 1000          | 091              | Advice acknowledged | 000              | Approved            |
      | notification         | notification         | 500                     | 1000.01             | 826                       | GBP                  | 702                   | SGD              | GB                         | -0.01               | 1000          | 091              | Advice acknowledged | 091              | Advice acknowledged |

  Scenario Outline: Clowd9-Test debit authorization approved for multiple partial reversals
    Given I build below transactions
      | transaction_identifier | message_type  | message_qualifier      | source |
      | T1                     | authorization | <T1_message_qualifier> | VISA   |
      | T2                     | reversal      | <T2_message_qualifier> | VISA   |
      | T3                     | reversal      | <T3_message_qualifier> | VISA   |

    Then I set card objects in transaction context
      | transaction_identifier | card_identifier | card_form_factor | card_status |
      | T1                     | CardId1         | PHYSICAL         | active      |
      | T2                     | CardId1         | PHYSICAL         | active      |
      | T3                     | CardId1         | PHYSICAL         | active      |

    Then I set customer objects in transaction context
      | transaction_identifier | customer_identifier |
      | T1                     | CardAccId1          |
      | T2                     | CardAccId1          |
      | T3                     | CardAccId1          |

    Then I set transaction objects in transaction context
      | transaction_identifier | transaction_id | reversal_type | transaction_type | transaction_amount        | transaction_currency_code   | cardholder_billing_amount | cardholder_billing_currency_code | system_trace_audit_number | retrieval_reference_number | network_transaction_id | transmission_date | transmission_time | transaction_local_date | transaction_local_time | dcc_indicator | chip_indicator | pin_indicator | three_ds_indicator | partial_approval_supported |
      | T1                     | TxnId1         |               | 00               | <auth_transaction_amount> | <transaction_currency_code> | <auth_billing_amount>     | <billing_currency_code>          | STAN1                     | RRN1                       | NT1                    | 1206              | 182751            | 1206                   | 192748                 | n             | contact        | online_passed | n                  | n                          |
      | T2                     | TxnId2         | PARTIAL       | 00               | <auth_transaction_amount> | <transaction_currency_code> | <auth_billing_amount>     | <billing_currency_code>          | STAN2                     | RRN1                       | NT2                    | 0329              | 142654            | 0329                   | 142654                 | n             | contact        | online_passed | n                  | n                          |
      | T3                     | TxnId3         | PARTIAL       | 00               | <auth_transaction_amount> | <transaction_currency_code> | <auth_billing_amount>     | <billing_currency_code>          | STAN3                     | RRN1                       | NT3                    | 0403              | 112654            | 0403                   | 112654                 | n             | contact        | online_passed | n                  | n                          |

    Then I set update in transaction context
      | transaction_identifier | original_transaction_id | original_message_type | original_message_qualifier | original_transaction_amount     | actual_transaction_amount       | original_system_trace_audit_number | original_retrieval_reference_number | original_transmission_date | original_transmission_time |
      | T2                     | TxnId1                  | authorization         | <T1_message_qualifier>     | <auth_transaction_amount>       | <reversal_transaction_amount_1> | STAN1                              | RRN1                                | 1206                       | 182751                     |
      | T3                     | TxnId1                  | authorization         | <T1_message_qualifier>     | <reversal_transaction_amount_1> | <reversal_transaction_amount_2> | STAN1                              | RRN1                                | 1206                       | 182751                     |

    Then I set status in transaction context
      | transaction_identifier | response_code | response_source | response_reason |
      | T2                     | 000           | Scheme          | Approved        |
      | T3                     | 000           | Scheme          | Approved        |

    Then I set acquirer objects in transaction context
      | transaction_identifier | acquiring_institution_id_code | card_acceptor_country_code   | acquiring_institution_country_code | merchant_category_code | card_acceptor_terminal_id | card_acceptor_id | card_acceptor_name | card_acceptor_city |
      | T1                     | 843759                        | <card_acceptor_country_code> |                                    | 6011                   | DUMMY_TERMINAL            | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |
      | T2                     | 843759                        | <card_acceptor_country_code> | <transaction_currency_code>        | 6011                   | DUMMY_TERMINAL            | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |
      | T3                     | 843759                        | <card_acceptor_country_code> | <transaction_currency_code>        | 6011                   | DUMMY_TERMINAL            | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount      | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code      | response_reason      | case_type |
      | T1                     | authorization | <auth_transaction_amount> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | <T1_response_code> | <T1_response_reason> | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_1> and total balance of 1000 for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount        | billing_amount        | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T1                     | VALID_UUID          | <auth_transaction_amount> | <auth_billing_amount> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount        | billing_amount        | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T1                     | TxnId1          | <auth_transaction_amount> | <auth_billing_amount> | <transaction_currency_code> | <billing_currency_code> | DEBIT_INITIAL    | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type | authorized_tx_amount            | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code      | response_reason      | case_type |
      | T2                     | reversal     | <reversal_transaction_amount_1> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | <T2_response_code> | <T2_response_reason> | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_2> and total balance of 1000 for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount              | billing_amount            | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T2                     | VALID_UUID          | <reversal_transaction_amount_1> | <actual_billing_amount_1> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount              | billing_amount            | tx_currency_code            | billing_currency_code   | transaction_type   | transaction_status |
      | T2                     | TxnId2          | <reversal_transaction_amount_1> | <actual_billing_amount_1> | <transaction_currency_code> | <billing_currency_code> | <transaction_type> | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type | authorized_tx_amount            | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code      | response_reason      | case_type |
      | T3                     | reversal     | <reversal_transaction_amount_2> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | <T3_response_code> | <T3_response_reason> | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_3> and total balance of 1000 for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount              | billing_amount            | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T3                     | VALID_UUID          | <reversal_transaction_amount_2> | <actual_billing_amount_2> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount              | billing_amount            | tx_currency_code            | billing_currency_code   | transaction_type   | transaction_status |
      | T3                     | TxnId3          | <reversal_transaction_amount_2> | <actual_billing_amount_2> | <transaction_currency_code> | <billing_currency_code> | <transaction_type> | COMPLETED          |

    Examples:
      | T1_message_qualifier | T2_message_qualifier | T3_message_qualifier | auth_transaction_amount | auth_billing_amount | reversal_transaction_amount_1 | actual_billing_amount_1 | reversal_transaction_amount_2 | actual_billing_amount_2 | transaction_currency_code | transaction_currency | billing_currency_code | billing_currency | card_acceptor_country_code | available_balance_1 | available_balance_2 | available_balance_3 | transaction_type | T1_response_code | T1_response_reason  | T2_response_code | T2_response_reason  | T3_response_code | T3_response_reason  |
      | request              | request              | request              | 100                     | 100                 | 80                            | 80                      | 60                            | 60                      | 702                       | SGD                  | 702                   | SGD              | SG                         | 900                 | 920                 | 940                 | DEBIT_REVERSAL   | 000              | Approved            | 000              | Approved            | 000              | Approved            |
      | notification         | notification         | notification         | 100                     | 100                 | 50                            | 50                      | 30                            | 30                      | 702                       | SGD                  | 702                   | SGD              | SG                         | 900                 | 950                 | 970                 | DEBIT_REVERSAL   | 091              | Advice acknowledged | 091              | Advice acknowledged | 091              | Advice acknowledged |
      | request              | notification         | notification         | 150                     | 150                 | 200                           | 200                     | 250                           | 250                     | 826                       | GBP                  | 702                   | SGD              | GB                         | 850                 | 800                 | 750                 | DEBIT_INCREMENT  | 000              | Approved            | 091              | Advice acknowledged | 091              | Advice acknowledged |
      | notification         | request              | request              | 50                      | 50                  | 30                            | 30                      | 10                            | 10                      | 702                       | SGD                  | 702                   | SGD              | SG                         | 950                 | 970                 | 990                 | DEBIT_REVERSAL   | 091              | Advice acknowledged | 000              | Approved            | 000              | Approved            |

  Scenario Outline: Clowd9-Test incremental authorization approved
    Given I build below transactions
      | transaction_identifier | message_type  | message_qualifier      | source |
      | T1                     | authorization | <T1_message_qualifier> | VISA   |
      | T2                     | authorization | <T2_message_qualifier> | VISA   |

    Then I set card objects in transaction context
      | transaction_identifier | card_identifier | card_form_factor |
      | T1                     | CardId1         | PHYSICAL         |
      | T2                     | CardId1         | PHYSICAL         |

    Then I set customer objects in transaction context
      | transaction_identifier | customer_identifier |
      | T1                     | CardAccId1          |
      | T2                     | CardAccId1          |

    Then I set transaction objects in transaction context
      | transaction_identifier | transaction_id | auth_type   | transaction_type | transaction_amount          | transaction_currency_code   | cardholder_billing_amount | cardholder_billing_currency_code | system_trace_audit_number | retrieval_reference_number | network_transaction_id | transmission_date | transmission_time | transaction_local_date | transaction_local_time | dcc_indicator | chip_indicator | pin_indicator | three_ds_indicator | partial_approval_supported |
      | T1                     | TxnId1         |             | 00               | <auth_transaction_amount_1> | <transaction_currency_code> | <auth_billing_amount_1>   | <billing_currency_code>          | STAN1                     | RRN1                       | NT1                    | 1206              | 182751            | 1206                   | 192748                 | n             | contact        | online_passed | n                  | n                          |
      | T2                     | TxnId2         | INCREMENTAL | 00               | <auth_transaction_amount_2> | <transaction_currency_code> | <auth_billing_amount_2>   | <billing_currency_code>          | STAN2                     | RRN1                       | NT2                    | 0329              | 112336            | 0329                   | 112336                 | n             | contact        | online_passed | n                  | n                          |

    Then I set acquirer objects in transaction context
      | transaction_identifier | acquiring_institution_id_code | card_acceptor_country_code   | acquiring_institution_country_code | merchant_category_code | card_acceptor_terminal_id | card_acceptor_id | card_acceptor_name | card_acceptor_city |
      | T1                     | 843759                        | <card_acceptor_country_code> | SG                                 | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |
      | T2                     | 843759                        | <card_acceptor_country_code> | SG                                 | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount        | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code      | response_reason      | case_type |
      | T1                     | authorization | <auth_transaction_amount_1> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | <T1_response_code> | <T1_response_reason> | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_1> and total balance of <total_balance> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount          | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T1                     | VALID_UUID          | <auth_transaction_amount_1> | <auth_billing_amount_1> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount          | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T1                     | TxnId1          | <auth_transaction_amount_1> | <auth_billing_amount_1> | <transaction_currency_code> | <billing_currency_code> | DEBIT_INITIAL    | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount        | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason | case_type |
      | T2                     | authorization | <auth_transaction_amount_2> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 000           | Approved        | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_2> and total balance of <total_balance> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount         | billing_amount         | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T2                     | VALID_UUID          | <total_transaction_amount> | <total_billing_amount> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount         | billing_amount         | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T2                     | TxnId2          | <total_transaction_amount> | <total_billing_amount> | <transaction_currency_code> | <billing_currency_code> | DEBIT_INCREMENT  | COMPLETED          |

    Examples:
      | T1_message_qualifier | T2_message_qualifier | auth_transaction_amount_1 | auth_billing_amount_1 | auth_transaction_amount_2 | auth_billing_amount_2 | total_transaction_amount | total_billing_amount | transaction_currency_code | transaction_currency | billing_currency_code | billing_currency | card_acceptor_country_code | available_balance_1 | available_balance_2 | total_balance | T1_response_code | T1_response_reason |
      | request              | request              | 100                       | 100                   | 50                        | 50                    | 150                      | 150                  | 702                       | SGD                  | 702                   | SGD              | SG                         | 900                 | 850                 | 1000          | 000              | Approved           |

  Scenario Outline: Clowd9-Test debit incremental authorization with insufficient funds
    Given I build below transactions
      | transaction_identifier | message_type  | message_qualifier   | source |
      | T1                     | authorization | <message_qualifier> | VISA   |
      | T2                     | authorization | <message_qualifier> | VISA   |

    Then I set card objects in transaction context
      | transaction_identifier | card_identifier | card_form_factor | card_status |
      | T1                     | CardId1         | PHYSICAL         | active      |
      | T2                     | CardId1         | PHYSICAL         | active      |

    Then I set customer objects in transaction context
      | transaction_identifier | customer_identifier |
      | T1                     | CardAccId1          |
      | T2                     | CardAccId1          |

    Then I set transaction objects in transaction context
      | transaction_identifier | transaction_id | auth_type   | transaction_type | transaction_amount     | transaction_currency_code   | cardholder_billing_amount | cardholder_billing_currency_code | system_trace_audit_number | retrieval_reference_number | network_transaction_id | transaction_local_time | transmission_date | transmission_time | transaction_local_date | dcc_indicator | chip_indicator | pin_indicator | three_ds_indicator | partial_approval_supported |
      | T1                     | TxnId1         |             | 00               | <transaction_amount_1> | <transaction_currency_code> | <billing_amount_1>        | <billing_currency_code>          | STAN1                     | RRN1                       | NT1                    | 192748                 | 1206              | 182751            | 1206                   | n             | contact        | online_passed | n                  | n                          |
      | T2                     | TxnId2         | INCREMENTAL | 00               | <transaction_amount_2> | <transaction_currency_code> | <billing_amount_2>        | <billing_currency_code>          | STAN2                     | RRN1                       | NT2                    | 032933                 | 1207              | 185022            | 1206                   | n             | contact        | online_passed | n                  | n                          |

    Then I set acquirer objects in transaction context
      | transaction_identifier | card_acceptor_country_code   | acquiring_institution_country_code | acquiring_institution_id_code | merchant_category_code | card_acceptor_terminal_id | card_acceptor_id | card_acceptor_name | card_acceptor_city |
      | T1                     | <card_acceptor_country_code> | <transaction_currency_code>        | 843759                        | 6011                   | DUMMY_TERMINAL            | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |
      | T2                     | <card_acceptor_country_code> | <transaction_currency_code>        | 843759                        | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount   | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason | case_type |
      | T1                     | authorization | <transaction_amount_1> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 000           | Approved        | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance> and total balance of <total_balance> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount     | billing_amount     | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T1                     | VALID_UUID          | <transaction_amount_1> | <billing_amount_1> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount     | billing_amount     | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T1                     | TxnId1          | <transaction_amount_1> | <billing_amount_1> | <transaction_currency_code> | <billing_currency_code> | DEBIT_INITIAL    | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount   | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason    | case_type |
      | T2                     | authorization | <transaction_amount_2> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 116           | Insufficient Funds | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance> and total balance of <total_balance> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount     | billing_amount     | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T1                     | VALID_UUID          | <transaction_amount_1> | <billing_amount_1> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

#    Then I validate below TransactionLog entries
#      | transaction_identifier | idempotency_key | transaction_amount         | billing_amount         | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
#      | T1                     | TxnId2          | <total_transaction_amount> | <total_billing_amount> | <transaction_currency_code> | <billing_currency_code> | DEBIT_INITIAL    | FAILED             |

    Examples:
      | message_qualifier | transaction_amount_1 | billing_amount_1 | transaction_amount_2 | billing_amount_2 | total_transaction_amount | total_billing_amount | transaction_currency_code | transaction_currency | billing_currency_code | billing_currency | card_acceptor_country_code | available_balance | total_balance |
      | request           | 1000                 | 1000             | 1                    | 1                | 1001                     | 1001                 | 702                       | SGD                  | 702                   | SGD              | SG                         | 0                 | 1000          |
      | request           | 1                    | 1                | 1000                 | 1000             | 1001                     | 1001                 | 702                       | SGD                  | 702                   | SGD              | SG                         | 999               | 1000          |
      | request           | 500                  | 500              | 1000                 | 1000             | 1500                     | 1500                 | 702                       | SGD                  | 702                   | SGD              | SG                         | 500               | 1000          |

  Scenario Outline: Clowd9-Test debit authorization followed multiple incremental authorization.
    Given I build below transactions
      | transaction_identifier | message_type  | message_qualifier      | source |
      | T1                     | authorization | <T1_message_qualifier> | VISA   |
      | T2                     | authorization | <T2_message_qualifier> | VISA   |
      | T3                     | authorization | <T3_message_qualifier> | VISA   |

    Then I set card objects in transaction context
      | transaction_identifier | card_identifier | card_form_factor |
      | T1                     | CardId1         | PHYSICAL         |
      | T2                     | CardId1         | PHYSICAL         |
      | T3                     | CardId1         | PHYSICAL         |

    Then I set customer objects in transaction context
      | transaction_identifier | customer_identifier |
      | T1                     | CardAccId1          |
      | T2                     | CardAccId1          |
      | T3                     | CardAccId1          |

    Then I set transaction objects in transaction context
      | transaction_identifier | transaction_id | auth_type   | transaction_type | transaction_amount          | transaction_currency_code   | cardholder_billing_amount | cardholder_billing_currency_code | system_trace_audit_number | retrieval_reference_number | network_transaction_id | transmission_date | transmission_time | transaction_local_date | transaction_local_time | dcc_indicator | chip_indicator | pin_indicator | three_ds_indicator | partial_approval_supported |
      | T1                     | TxnId1         |             | 00               | <auth_transaction_amount_1> | <transaction_currency_code> | <auth_billing_amount_1>   | <billing_currency_code>          | STAN1                     | RRN1                       | NT1                    | 1206              | 182751            | 1206                   | 192748                 | n             | contact        | online_passed | n                  | n                          |
      | T2                     | TxnId2         | INCREMENTAL | 00               | <auth_transaction_amount_2> | <transaction_currency_code> | <auth_billing_amount_2>   | <billing_currency_code>          | STAN2                     | RRN1                       | NT2                    | 0329              | 112336            | 0329                   | 112336                 | n             | contact        | online_passed | n                  | n                          |
      | T3                     | TxnId3         | INCREMENTAL | 00               | <auth_transaction_amount_3> | <transaction_currency_code> | <auth_billing_amount_3>   | <billing_currency_code>          | STAN3                     | RRN1                       | NT3                    | 0404              | 123445            | 0404                   | 123445                 | n             | contact        | online_passed | n                  | n                          |

    Then I set acquirer objects in transaction context
      | transaction_identifier | acquiring_institution_id_code | card_acceptor_country_code   | acquiring_institution_country_code | merchant_category_code | card_acceptor_terminal_id | card_acceptor_id | card_acceptor_name | card_acceptor_city |
      | T1                     | 843759                        | <card_acceptor_country_code> |                                    | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |
      | T2                     | 843759                        | <card_acceptor_country_code> | <transaction_currency_code>        | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |
      | T3                     | 843759                        | <card_acceptor_country_code> |                                    | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount        | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason | case_type |
      | T1                     | authorization | <auth_transaction_amount_1> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 000           | Approved        | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_1> and total balance of <total_balance> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount          | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T1                     | VALID_UUID          | <auth_transaction_amount_1> | <auth_billing_amount_1> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount          | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T1                     | TxnId1          | <auth_transaction_amount_1> | <auth_billing_amount_1> | <transaction_currency_code> | <billing_currency_code> | DEBIT_INITIAL    | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount        | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason | case_type |
      | T2                     | authorization | <auth_transaction_amount_2> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 000           | Approved        | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_2> and total balance of <total_balance> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount           | billing_amount           | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T2                     | VALID_UUID          | <total_transaction_amount_1> | <total_billing_amount_1> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount           | billing_amount           | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T2                     | TxnId2          | <total_transaction_amount_1> | <total_billing_amount_1> | <transaction_currency_code> | <billing_currency_code> | DEBIT_INCREMENT  | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount        | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason | case_type |
      | T3                     | authorization | <auth_transaction_amount_3> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 000           | Approved        | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_3> and total balance of <total_balance> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount           | billing_amount           | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T3                     | VALID_UUID          | <total_transaction_amount_2> | <total_billing_amount_2> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount           | billing_amount           | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T3                     | TxnId3          | <total_transaction_amount_2> | <total_billing_amount_2> | <transaction_currency_code> | <billing_currency_code> | DEBIT_INCREMENT  | COMPLETED          |

    Examples:
      | T1_message_qualifier | T2_message_qualifier | T3_message_qualifier | auth_transaction_amount_1 | auth_billing_amount_1 | auth_transaction_amount_2 | auth_billing_amount_2 | total_transaction_amount_1 | total_billing_amount_1 | auth_transaction_amount_3 | auth_billing_amount_3 | total_transaction_amount_2 | total_billing_amount_2 | transaction_currency_code | transaction_currency | billing_currency_code | billing_currency | card_acceptor_country_code | available_balance_1 | available_balance_2 | available_balance_3 | total_balance |
      | request              | request              | request              | 100                       | 100                   | 50                        | 50                    | 150                        | 150                    | 50                        | 50                    | 200                        | 200                    | 702                       | SGD                  | 702                   | SGD              | SG                         | 900                 | 850                 | 800                 | 1000          |

  Scenario Outline: Clowd9-Test incremental authorization notification is rejected with bad request
    Given I build below transactions
      | transaction_identifier | message_type  | message_qualifier      | source |
      | T1                     | authorization | <T1_message_qualifier> | VISA   |
      | T2                     | authorization | <T2_message_qualifier> | VISA   |

    Then I set card objects in transaction context
      | transaction_identifier | card_identifier | card_form_factor |
      | T1                     | CardId1         | PHYSICAL         |
      | T2                     | CardId1         | PHYSICAL         |

    Then I set customer objects in transaction context
      | transaction_identifier | customer_identifier |
      | T1                     | CardAccId1          |
      | T2                     | CardAccId1          |

    Then I set transaction objects in transaction context
      | transaction_identifier | transaction_id | auth_type   | reversal_type | transaction_type | transaction_amount          | transaction_currency_code   | cardholder_billing_amount | cardholder_billing_currency_code | system_trace_audit_number | retrieval_reference_number | network_transaction_id | transmission_date | transmission_time | transaction_local_date | transaction_local_time | dcc_indicator | chip_indicator | pin_indicator | three_ds_indicator | partial_approval_supported |
      | T1                     | TxnId1         |             |               | 00               | <auth_transaction_amount_1> | <transaction_currency_code> | <auth_billing_amount_1>   | <billing_currency_code>          | STAN1                     | RRN1                       | NT1                    | 1206              | 182751            | 1206                   | 192748                 | n             | contact        | online_passed | n                  | n                          |
      | T2                     | TxnId2         | INCREMENTAL |               | 00               | <auth_transaction_amount_2> | <transaction_currency_code> | <auth_billing_amount_2>   | <billing_currency_code>          | STAN2                     | RRN1                       | NT2                    | 0329              | 112336            | 0329                   | 112336                 | n             | contact        | online_passed | n                  | n                          |

    Then I set acquirer objects in transaction context
      | transaction_identifier | acquiring_institution_id_code | card_acceptor_country_code   | acquiring_institution_country_code | merchant_category_code | card_acceptor_terminal_id | card_acceptor_id | card_acceptor_name | card_acceptor_city |
      | T1                     | 843759                        | <card_acceptor_country_code> |                                    | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |
      | T2                     | 843759                        |                              | <transaction_currency_code>        | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount        | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code      | response_reason      | case_type |
      | T1                     | authorization | <auth_transaction_amount_1> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | <T1_response_code> | <T1_response_reason> | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_1> and total balance of <total_balance> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount          | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T1                     | VALID_UUID          | <auth_transaction_amount_1> | <auth_billing_amount_1> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount          | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T1                     | TxnId1          | <auth_transaction_amount_1> | <auth_billing_amount_1> | <transaction_currency_code> | <billing_currency_code> | DEBIT_INITIAL    | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | case_type   |
      | T2                     | bad_request |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_1> and total balance of <total_balance> for customerProfileId CPID1

    Examples:
      | T1_message_qualifier | T2_message_qualifier | auth_transaction_amount_1 | auth_billing_amount_1 | auth_transaction_amount_2 | auth_billing_amount_2 | transaction_currency_code | transaction_currency | billing_currency_code | billing_currency | card_acceptor_country_code | available_balance_1 | total_balance | T1_response_code | T1_response_reason  |
      | request              | notification         | 599                       | 599                   | 600                       | 600                   | 702                       | SGD                  | 702                   | SGD              | SG                         | 401                 | 1000          | 000              | Approved            |
      | notification         | notification         | 50                        | 150                   | 300                       | 300                   | 826                       | GBP                  | 702                   | SGD              | GB                         | 850                 | 1000          | 091              | Advice acknowledged |

  Scenario Outline: Clowd9-Test debit authorization with a partial reversal and then full reversal
    Given I build below transactions
      | transaction_identifier | message_type  | message_qualifier      | source |
      | T1                     | authorization | <T1_message_qualifier> | VISA   |
      | T2                     | reversal      | <T2_message_qualifier> | VISA   |
      | T3                     | reversal      | <T3_message_qualifier> | VISA   |

    Then I set card objects in transaction context
      | transaction_identifier | card_identifier | card_form_factor | card_status |
      | T1                     | CardId1         | PHYSICAL         | active      |
      | T2                     | CardId1         | PHYSICAL         | active      |
      | T3                     | CardId1         | PHYSICAL         | active      |

    Then I set customer objects in transaction context
      | transaction_identifier | customer_identifier |
      | T1                     | CardAccId1          |
      | T2                     | CardAccId1          |
      | T3                     | CardAccId1          |

    Then I set transaction objects in transaction context
      | transaction_identifier | transaction_id | reversal_type | transaction_type | transaction_amount            | transaction_currency_code   | cardholder_billing_amount     | cardholder_billing_currency_code | system_trace_audit_number | retrieval_reference_number | network_transaction_id | transmission_date | transmission_time | transaction_local_date | transaction_local_time | dcc_indicator | chip_indicator | pin_indicator | three_ds_indicator | partial_approval_supported |
      | T1                     | TxnId1         |               | 00               | <auth_transaction_amount>     | <transaction_currency_code> | <auth_billing_amount>         | <billing_currency_code>          | STAN1                     | RRN1                       | NT1                    | 1206              | 182751            | 1206                   | 192748                 | n             | contact        | online_passed | n                  | n                          |
      | T2                     | TxnId2         | PARTIAL       | 00               | <auth_transaction_amount>     | <transaction_currency_code> | <auth_billing_amount>         | <billing_currency_code>          | STAN2                     | RRN1                       | NT2                    | 0329              | 142654            | 0329                   | 142654                 | n             | contact        | online_passed | n                  | n                          |
      | T3                     | TxnId3         | FULL          | 00               | <reversal_transaction_amount> | <transaction_currency_code> | <reversal_transaction_amount> | <billing_currency_code>          | STAN3                     | RRN1                       | NT3                    | 0330              | 112654            | 0330                   | 112654                 | n             | contact        | online_passed | n                  | n                          |

    Then I set update in transaction context
      | transaction_identifier | original_transaction_id | original_message_type | original_message_qualifier | original_transaction_amount   | actual_transaction_amount     | original_system_trace_audit_number | original_retrieval_reference_number | original_transmission_date | original_transmission_time |
      | T2                     | TxnId1                  | authorization         | request                    | <auth_transaction_amount>     | <reversal_transaction_amount> | STAN1                              | RRN1                                | 1206                       | 182751                     |
      | T3                     | TxnId1                  | authorization         | request                    | <reversal_transaction_amount> |                               | STAN1                              | RRN1                                | 1206                       | 182751                     |

    Then I set status in transaction context
      | transaction_identifier | response_code | response_source | response_reason |
      | T2                     | 000           | Scheme          | Approved        |
      | T3                     | 000           | Scheme          | Approved        |

    Then I set acquirer objects in transaction context
      | transaction_identifier | acquiring_institution_id_code | card_acceptor_country_code   | acquiring_institution_country_code | merchant_category_code | card_acceptor_terminal_id | card_acceptor_id | card_acceptor_name | card_acceptor_city |
      | T1                     | 843759                        | <card_acceptor_country_code> |                                    | 6011                   | DUMMY_TERMINAL            | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |
      | T2                     | 843759                        | <card_acceptor_country_code> | <transaction_currency_code>        | 6011                   | DUMMY_TERMINAL            | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |
      | T3                     | 843759                        | <card_acceptor_country_code> |                                    | 6011                   | DUMMY_TERMINAL            | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount      | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code      | response_reason      | case_type |
      | T1                     | authorization | <auth_transaction_amount> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | <T1_response_code> | <T1_response_reason> | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_1> and total balance of 1000 for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount        | billing_amount        | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T1                     | VALID_UUID          | <auth_transaction_amount> | <auth_billing_amount> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount        | billing_amount        | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T1                     | TxnId1          | <auth_transaction_amount> | <auth_billing_amount> | <transaction_currency_code> | <billing_currency_code> | DEBIT_INITIAL    | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type | authorized_tx_amount          | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code      | response_reason      | case_type |
      | T2                     | reversal     | <reversal_transaction_amount> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | <T2_response_code> | <T2_response_reason> | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_2> and total balance of 1000 for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount            | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T2                     | VALID_UUID          | <reversal_transaction_amount> | <actual_billing_amount> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount            | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T2                     | TxnId2          | <reversal_transaction_amount> | <actual_billing_amount> | <transaction_currency_code> | <billing_currency_code> | DEBIT_REVERSAL   | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type | authorized_tx_amount | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code      | response_reason      | case_type |
      | T3                     | reversal     | 0                    | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | <T3_response_code> | <T3_response_reason> | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_3> and total balance of 1000 for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount | billing_amount | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status   | release_auth_ts | release_type     |
      | T3                     | VALID_UUID          | 0                  | 0              | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | TRANSACTION_REVERTED | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount | billing_amount | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T3                     | TxnId3          | 0                  | 0              | <transaction_currency_code> | <billing_currency_code> | DEBIT_REVERSAL   | COMPLETED          |

    Examples:
      | T1_message_qualifier | T2_message_qualifier | T3_message_qualifier | auth_transaction_amount | auth_billing_amount | reversal_transaction_amount | actual_billing_amount | transaction_currency_code | transaction_currency | billing_currency_code | billing_currency | card_acceptor_country_code | available_balance_1 | available_balance_2 | available_balance_3 | T1_response_code | T1_response_reason  | T2_response_code | T2_response_reason  | T3_response_code | T3_response_reason  |
      | request              | request              | request              | 100                     | 100                 | 80                          | 80                    | 702                       | SGD                  | 702                   | SGD              | SG                         | 900                 | 920                 | 1000                | 000              | Approved            | 000              | Approved            | 000              | Approved            |
      | notification         | notification         | notification         | 1200                    | 1200                | 1100                        | 1100                  | 702                       | SGD                  | 702                   | SGD              | SG                         | -200                | -100                | 1000                | 091              | Advice acknowledged | 091              | Advice acknowledged | 091              | Advice acknowledged |
      | request              | notification         | notification         | 989.99                  | 989.99              | 600                         | 600                   | 826                       | GBP                  | 702                   | SGD              | GB                         | 10.01               | 400                 | 1000                | 000              | Approved            | 091              | Advice acknowledged | 091              | Advice acknowledged |

  Scenario Outline: Clowd9-Test debit authorization with a partial reversal then an incremental authorization
    Given I build below transactions
      | transaction_identifier | message_type  | message_qualifier      | source |
      | T1                     | authorization | <T1_message_qualifier> | VISA   |
      | T2                     | reversal      | <T2_message_qualifier> | VISA   |
      | T3                     | authorization | <T3_message_qualifier> | VISA   |

    Then I set card objects in transaction context
      | transaction_identifier | card_identifier | card_form_factor |
      | T1                     | CardId1         | PHYSICAL         |
      | T2                     | CardId1         | PHYSICAL         |
      | T3                     | CardId1         | PHYSICAL         |

    Then I set customer objects in transaction context
      | transaction_identifier | customer_identifier |
      | T1                     | CardAccId1          |
      | T2                     | CardAccId1          |
      | T3                     | CardAccId1          |

    Then I set transaction objects in transaction context
      | transaction_identifier | transaction_id | reversal_type | auth_type   | transaction_type | transaction_amount              | transaction_currency_code   | cardholder_billing_amount       | cardholder_billing_currency_code | system_trace_audit_number | retrieval_reference_number | network_transaction_id | transmission_date | transmission_time | transaction_local_date | transaction_local_time | dcc_indicator | chip_indicator | pin_indicator | three_ds_indicator | partial_approval_supported |
      | T1                     | TxnId1         |               |             | 00               | <auth_transaction_amount_1>     | <transaction_currency_code> | <auth_billing_amount_1>         | <billing_currency_code>          | STAN1                     | RRN1                       | NT1                    | 1206              | 182751            | 1206                   | 192748                 | n             | contact        | online_passed | n                  | n                          |
      | T2                     | TxnId2         | PARTIAL       |             | 00               | <reversal_transaction_amount_1> | <transaction_currency_code> | <reversal_transaction_amount_1> | <billing_currency_code>          | STAN2                     | RRN1                       | NT2                    | 0329              | 142654            | 0329                   | 142654                 | n             | contact        | online_passed | n                  | n                          |
      | T3                     | TxnId3         |               | INCREMENTAL | 00               | <auth_transaction_amount_2>     | <transaction_currency_code> | <auth_billing_amount_2>         | <billing_currency_code>          | STAN3                     | RRN1                       | NT3                    | 0403              | 112654            | 0403                   | 112654                 | n             | contact        | online_passed | n                  | n                          |

    Then I set update in transaction context
      | transaction_identifier | original_transaction_id | original_message_type | original_message_qualifier | original_transaction_amount | actual_transaction_amount   | original_system_trace_audit_number | original_retrieval_reference_number | original_transmission_date | original_transmission_time |
      | T2                     | TxnId1                  | authorization         | <T1_message_qualifier>     | <auth_transaction_amount_1> | <actual_transaction_amount> | STAN1                              | RRN1                                | 1206                       | 182751                     |

    Then I set status in transaction context
      | transaction_identifier | response_code | response_source | response_reason |
      | T2                     | 000           | Scheme          | Approved        |

    Then I set acquirer objects in transaction context
      | transaction_identifier | acquiring_institution_id_code | card_acceptor_country_code   | acquiring_institution_country_code | merchant_category_code | card_acceptor_terminal_id | card_acceptor_id | card_acceptor_name | card_acceptor_city |
      | T1                     | 843759                        | <card_acceptor_country_code> | <transaction_currency_code>        | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |
      | T2                     | 843759                        | <card_acceptor_country_code> | <transaction_currency_code>        | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |
      | T3                     | 843759                        | <card_acceptor_country_code> |                                    | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount        | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code      | response_reason      | case_type |
      | T1                     | authorization | <auth_transaction_amount_1> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | <T1_response_code> | <T1_response_reason> | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_1> and total balance of 1000 for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount          | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T1                     | VALID_UUID          | <auth_transaction_amount_1> | <auth_billing_amount_1> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount          | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T1                     | TxnId1          | <auth_transaction_amount_1> | <auth_billing_amount_1> | <transaction_currency_code> | <billing_currency_code> | DEBIT_INITIAL    | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type | authorized_tx_amount        | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code      | response_reason      | case_type |
      | T2                     | reversal     | <actual_transaction_amount> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | <T2_response_code> | <T2_response_reason> | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_2> and total balance of 1000 for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount              | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T2                     | VALID_UUID          | <reversal_transaction_amount_1> | <actual_billing_amount> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount              | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_type   | transaction_status |
      | T2                     | TxnId2          | <reversal_transaction_amount_1> | <actual_billing_amount> | <transaction_currency_code> | <billing_currency_code> | <transaction_type> | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount        | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason | case_type |
      | T3                     | authorization | <auth_transaction_amount_2> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 000           | Approved        | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_3> and total balance of 1000 for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount         | billing_amount         | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T3                     | VALID_UUID          | <total_transaction_amount> | <total_billing_amount> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount         | billing_amount         | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T3                     | TxnId3          | <total_transaction_amount> | <total_billing_amount> | <transaction_currency_code> | <billing_currency_code> | DEBIT_INCREMENT  | COMPLETED          |

    Examples:
      | T1_message_qualifier | T2_message_qualifier | T3_message_qualifier | auth_transaction_amount_1 | auth_billing_amount_1 | auth_transaction_amount_2 | auth_billing_amount_2 | total_transaction_amount | total_billing_amount | reversal_transaction_amount_1 | actual_transaction_amount | actual_billing_amount | transaction_currency_code | transaction_currency | billing_currency_code | billing_currency | card_acceptor_country_code | available_balance_1 | available_balance_2 | available_balance_3 | transaction_type | T1_response_code | T1_response_reason  | T2_response_code | T2_response_reason  |
      | request              | request              | request              | 50                        | 50                    | 50                        | 50                    | 80                       | 80                   | 30                            | 30                        | 30                    | 702                       | SGD                  | 702                   | SGD              | SG                         | 950                 | 970                 | 920                 | DEBIT_REVERSAL   | 000              | Approved            | 000              | Approved            |
      | request              | notification         | request              | 100                       | 200                   | 50                        | 100                   | 100                      | 200                  | 50                            | 50                        | 100                   | 826                       | GBP                  | 702                   | SGD              | GB                         | 800                 | 900                 | 800                 | DEBIT_REVERSAL   | 000              | Approved            | 091              | Advice acknowledged |
      | notification         | notification         | request              | 1200                      | 1200                  | 200                       | 200                   | 700                      | 700                  | 500                           | 500                       | 500                   | 702                       | SGD                  | 702                   | SGD              | SG                         | -200                | 500                 | 300                 | DEBIT_REVERSAL   | 091              | Advice acknowledged | 091              | Advice acknowledged |

  Scenario Outline: Clowd9-Test debit authorization with an incremental authorization and finally a partial reversal
    Given I build below transactions
      | transaction_identifier | message_type  | message_qualifier      | source |
      | T1                     | authorization | <T1_message_qualifier> | VISA   |
      | T2                     | authorization | <T2_message_qualifier> | VISA   |
      | T3                     | reversal      | <T3_message_qualifier> |        |

    Then I set card objects in transaction context
      | transaction_identifier | card_identifier | card_form_factor |
      | T1                     | CardId1         | PHYSICAL         |
      | T2                     | CardId1         | PHYSICAL         |
      | T3                     | CardId1         | PHYSICAL         |

    Then I set customer objects in transaction context
      | transaction_identifier | customer_identifier |
      | T1                     | CardAccId1          |
      | T2                     | CardAccId1          |
      | T3                     | CardAccId1          |

    Then I set transaction objects in transaction context
      | transaction_identifier | transaction_id | auth_type   | reversal_type | transaction_type | transaction_amount              | transaction_currency_code   | cardholder_billing_amount       | cardholder_billing_currency_code | system_trace_audit_number | retrieval_reference_number | network_transaction_id | transmission_date | transmission_time | transaction_local_date | transaction_local_time | dcc_indicator | chip_indicator | pin_indicator | three_ds_indicator | partial_approval_supported |
      | T1                     | TxnId1         |             |               | 00               | <auth_transaction_amount_1>     | <transaction_currency_code> | <auth_billing_amount_1>         | <billing_currency_code>          | STAN1                     | RRN1                       | NT1                    | 1206              | 182751            | 1206                   | 192748                 | n             | contact        | online_passed | n                  | n                          |
      | T2                     | TxnId2         | INCREMENTAL |               | 00               | <auth_transaction_amount_2>     | <transaction_currency_code> | <auth_billing_amount_2>         | <billing_currency_code>          | STAN2                     | RRN1                       | NT2                    | 0329              | 112336            | 0329                   | 112336                 | n             | contact        | online_passed | n                  | n                          |
      | T3                     | TxnId3         |             | PARTIAL       | 00               | <reversal_transaction_amount_1> | <transaction_currency_code> | <reversal_transaction_amount_1> | <billing_currency_code>          | STAN3                     | RRN1                       | NT3                    | 0329              | 142654            | 0329                   | 142654                 | n             | contact        | online_passed | n                  | n                          |

    Then I set update in transaction context
      | transaction_identifier | original_transaction_id | original_message_type | original_message_qualifier | original_transaction_amount | actual_transaction_amount       | original_system_trace_audit_number | original_retrieval_reference_number | original_transmission_date | original_transmission_time |
      | T3                     | TxnId1                  | authorization         | <T1_message_qualifier>     | <auth_transaction_amount_2> | <reversal_transaction_amount_1> | STAN1                              | RRN1                                | 0329                       | 112336                     |

    Then I set status in transaction context
      | transaction_identifier | response_code | response_source | response_reason |
      | T3                     | 000           | Scheme          | Approved        |

    Then I set acquirer objects in transaction context
      | transaction_identifier | acquiring_institution_id_code | card_acceptor_country_code   | acquiring_institution_country_code | merchant_category_code | card_acceptor_terminal_id | card_acceptor_id | card_acceptor_name | card_acceptor_city |
      | T1                     | 843759                        | <card_acceptor_country_code> |                                    | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |
      | T2                     | 843759                        | <card_acceptor_country_code> | <transaction_currency_code>        | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |
      | T3                     | 843759                        | <card_acceptor_country_code> |                                    | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount        | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code      | response_reason      | case_type |
      | T1                     | authorization | <auth_transaction_amount_1> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | <T1_response_code> | <T1_response_reason> | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_1> and total balance of <total_balance> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount          | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T1                     | VALID_UUID          | <auth_transaction_amount_1> | <auth_billing_amount_1> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount          | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T1                     | TxnId1          | <auth_transaction_amount_1> | <auth_billing_amount_1> | <transaction_currency_code> | <billing_currency_code> | DEBIT_INITIAL    | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount        | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason | case_type |
      | T2                     | authorization | <auth_transaction_amount_2> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 000           | Approved        | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_2> and total balance of <total_balance> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount         | billing_amount         | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T2                     | VALID_UUID          | <total_transaction_amount> | <total_billing_amount> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount         | billing_amount         | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T2                     | TxnId2          | <total_transaction_amount> | <total_billing_amount> | <transaction_currency_code> | <billing_currency_code> | DEBIT_INCREMENT  | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type | authorized_tx_amount            | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code      | response_reason      | case_type |
      | T3                     | reversal     | <reversal_transaction_amount_1> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | <T3_response_code> | <T3_response_reason> | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_3> and total balance of <total_balance> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount          | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T3                     | VALID_UUID          | <actual_transaction_amount> | <actual_billing_amount> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount          | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T3                     | TxnId3          | <actual_transaction_amount> | <actual_billing_amount> | <transaction_currency_code> | <billing_currency_code> | DEBIT_REVERSAL   | COMPLETED          |

    Examples:
      | T1_message_qualifier | T2_message_qualifier | T3_message_qualifier | auth_transaction_amount_1 | auth_billing_amount_1 | auth_transaction_amount_2 | auth_billing_amount_2 | total_transaction_amount | total_billing_amount | reversal_transaction_amount_1 | actual_transaction_amount | actual_billing_amount | transaction_currency_code | transaction_currency | billing_currency_code | billing_currency | card_acceptor_country_code | available_balance_1 | available_balance_2 | available_balance_3 | total_balance | T1_response_code | T1_response_reason  | T3_response_code | T3_response_reason  |
      | request              | request              | request              | 100                       | 100                   | 50                        | 50                    | 150                      | 150                  | 70                            | 70                        | 70                    | 702                       | SGD                  | 702                   | SGD              | SG                         | 900                 | 850                 | 930                 | 1000          | 000              | Approved            | 000              | Approved            |
      | notification         | request              | notification         | 599                       | 599                   | 100                       | 100                   | 699                      | 699                  | 1                             | 1                         | 1                     | 826                       | GBP                  | 702                   | SGD              | GB                         | 401                 | 301                 | 999                 | 1000          | 091              | Advice acknowledged | 091              | Advice acknowledged |

  Scenario Outline: Clowd9-Test debit authorization with an incremental authorization and finally a full reversal
    Given I build below transactions
      | transaction_identifier | message_type  | message_qualifier      | source |
      | T1                     | authorization | <T1_message_qualifier> | VISA   |
      | T2                     | authorization | <T2_message_qualifier> | VISA   |
      | T3                     | reversal      | <T3_message_qualifier> | VISA   |

    Then I set card objects in transaction context
      | transaction_identifier | card_identifier | card_form_factor |
      | T1                     | CardId1         | PHYSICAL         |
      | T2                     | CardId1         | PHYSICAL         |
      | T3                     | CardId1         | PHYSICAL         |

    Then I set customer objects in transaction context
      | transaction_identifier | customer_identifier |
      | T1                     | CardAccId1          |
      | T2                     | CardAccId1          |
      | T3                     | CardAccId1          |

    Then I set transaction objects in transaction context
      | transaction_identifier | transaction_id | auth_type   | reversal_type | transaction_type | transaction_amount          | transaction_currency_code   | cardholder_billing_amount  | cardholder_billing_currency_code | system_trace_audit_number | retrieval_reference_number | network_transaction_id | transmission_date | transmission_time | transaction_local_date | transaction_local_time | dcc_indicator | chip_indicator | pin_indicator | three_ds_indicator | partial_approval_supported |
      | T1                     | TxnId1         |             |               | 00               | <auth_transaction_amount_1> | <transaction_currency_code> | <auth_billing_amount_1>    | <billing_currency_code>          | STAN1                     | RRN1                       | NT1                    | 1206              | 182751            | 1206                   | 192748                 | N             | n              | n             | N                  | N                          |
      | T2                     | TxnId2         | INCREMENTAL |               | 00               | <auth_transaction_amount_2> | <transaction_currency_code> | <auth_billing_amount_2>    | <billing_currency_code>          | STAN2                     | RRN1                       | NT2                    | 0329              | 112336            | 0329                   | 112336                 | N             | n              | n             | N                  | N                          |
      | T3                     | TxnId3         |             | FULL          | 00               | <total_transaction_amount>  | <transaction_currency_code> | <total_transaction_amount> | <billing_currency_code>          | STAN3                     | RRN1                       | NT3                    | 0329              | 142654            | 0329                   | 142654                 | N             | n              | n             | N                  | N                          |

    Then I set update in transaction context
      | transaction_identifier | original_transaction_id | original_message_type | original_message_qualifier | original_transaction_amount | actual_transaction_amount | original_system_trace_audit_number | original_retrieval_reference_number | original_transmission_date | original_transmission_time |
      | T3                     | TxnId1                  | authorization         | <T1_message_qualifier>     | <total_transaction_amount>  |                           | STAN1                              | RRN1                                | 0329                       | 112336                     |

    Then I set status in transaction context
      | transaction_identifier | response_code | response_source | response_reason |
      | T3                     | 000           | Scheme          | Approved        |

    Then I set acquirer objects in transaction context
      | transaction_identifier | acquiring_institution_id_code | card_acceptor_country_code   | acquiring_institution_country_code | merchant_category_code | card_acceptor_terminal_id | card_acceptor_id | card_acceptor_name | card_acceptor_city |
      | T1                     | 843759                        | <card_acceptor_country_code> | <transaction_currency_code>        | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |
      | T2                     | 843759                        | <card_acceptor_country_code> |                                    | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |
      | T3                     | 843759                        | <card_acceptor_country_code> |                                    | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount        | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason | case_type |
      | T1                     | authorization | <auth_transaction_amount_1> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 000           | Approved        | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_1> and total balance of <total_balance> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount          | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T1                     | VALID_UUID          | <auth_transaction_amount_1> | <auth_billing_amount_1> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount          | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T1                     | TxnId1          | <auth_transaction_amount_1> | <auth_billing_amount_1> | <transaction_currency_code> | <billing_currency_code> | DEBIT_INITIAL    | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount        | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason | case_type |
      | T2                     | authorization | <auth_transaction_amount_2> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 000           | Approved        | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_2> and total balance of <total_balance> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount         | billing_amount         | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T2                     | VALID_UUID          | <total_transaction_amount> | <total_billing_amount> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount         | billing_amount         | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T2                     | TxnId2          | <total_transaction_amount> | <total_billing_amount> | <transaction_currency_code> | <billing_currency_code> | DEBIT_INCREMENT  | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type | authorized_tx_amount | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason | case_type |
      | T3                     | reversal     | 0                    | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 000           | Approved        | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <total_balance> and total balance of <total_balance> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount | billing_amount | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status   | release_auth_ts | release_type     |
      | T1                     | VALID_UUID          | 0                  | 0              | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | TRANSACTION_REVERTED | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount | billing_amount | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T3                     | TxnId3          | 0                  | 0              | <transaction_currency_code> | <billing_currency_code> | DEBIT_REVERSAL   | COMPLETED          |

    Examples:
      | T1_message_qualifier | T2_message_qualifier | T3_message_qualifier | auth_transaction_amount_1 | auth_billing_amount_1 | auth_transaction_amount_2 | auth_billing_amount_2 | total_transaction_amount | total_billing_amount | transaction_currency_code | transaction_currency | billing_currency_code | billing_currency | card_acceptor_country_code | available_balance_1 | available_balance_2 | total_balance | case_type |
      | request              | request              | request              | 100                       | 100                   | 50                        | 50                    | 150                      | 150                  | 702                       | SGD                  | 702                   | SGD              | SG                         | 900                 | 850                 | 1000          | positive  |
      # Add more tests for this scenario

  Scenario Outline: Clowd9-Test debit authorization with an incremental authorization then a partial reversal and finally an incremental authorization
    Given I build below transactions
      | transaction_identifier | message_type  | message_qualifier      | source |
      | T1                     | authorization | <T1_message_qualifier> | VISA   |
      | T2                     | authorization | <T2_message_qualifier> | VISA   |
      | T3                     | reversal      | <T3_message_qualifier> |        |
      | T4                     | authorization | <T4_message_qualifier> | VISA   |

    Then I set card objects in transaction context
      | transaction_identifier | card_identifier | card_form_factor |
      | T1                     | CardId1         | PHYSICAL         |
      | T2                     | CardId1         | PHYSICAL         |
      | T3                     | CardId1         | PHYSICAL         |
      | T4                     | CardId1         | PHYSICAL         |

    Then I set customer objects in transaction context
      | transaction_identifier | customer_identifier |
      | T1                     | CardAccId1          |
      | T2                     | CardAccId1          |
      | T3                     | CardAccId1          |
      | T4                     | CardAccId1          |

    Then I set transaction objects in transaction context
      | transaction_identifier | transaction_id | auth_type   | reversal_type | transaction_type | transaction_amount              | transaction_currency_code   | cardholder_billing_amount | cardholder_billing_currency_code | system_trace_audit_number | retrieval_reference_number | network_transaction_id | transmission_date | transmission_time | transaction_local_date | transaction_local_time | dcc_indicator | chip_indicator | pin_indicator | three_ds_indicator | partial_approval_supported |
      | T1                     | TxnId1         |             |               | 00               | <auth_transaction_amount_1>     | <transaction_currency_code> | <auth_billing_amount_1>   | <billing_currency_code>          | STAN1                     | RRN1                       | NT1                    | 1206              | 182751            | 1206                   | 192748                 | n             | contact        | online_passed | n                  | n                          |
      | T2                     | TxnId2         | INCREMENTAL |               | 00               | <auth_transaction_amount_2>     | <transaction_currency_code> | <auth_billing_amount_2>   | <billing_currency_code>          | STAN2                     | RRN1                       | NT2                    | 0329              | 112336            | 0329                   | 112336                 | n             | contact        | online_passed | n                  | n                          |
      | T3                     | TxnId3         |             | PARTIAL       | 00               | <reversal_transaction_amount_1> | <transaction_currency_code> |                           |                                  | STAN3                     | RRN1                       | NT3                    | 0329              | 142654            | 0329                   | 142654                 | n             | contact        | online_passed | n                  | n                          |
      | T4                     | TxnId4         | INCREMENTAL |               | 00               | <auth_transaction_amount_3>     | <transaction_currency_code> | <auth_billing_amount_3>   | <billing_currency_code>          | STAN4                     | RRN1                       | NT4                    | 0329              | 112336            | 0329                   | 112336                 | n             | contact        | online_passed | n                  | n                          |

    Then I set update in transaction context
      | transaction_identifier | original_transaction_id | original_message_type | original_message_qualifier | original_transaction_amount | actual_transaction_amount   | original_system_trace_audit_number | original_retrieval_reference_number | original_transmission_date | original_transmission_time |
      | T3                     | TxnId1                  | authorization         | <T1_message_qualifier>     | <total_transaction_amount>  | <actual_transaction_amount> | STAN1                              | RRN1                                | 0329                       | 112336                     |

    Then I set status in transaction context
      | transaction_identifier | response_code | response_source | response_reason |
      | T3                     | 000           | Scheme          | Approved        |

    Then I set acquirer objects in transaction context
      | transaction_identifier | acquiring_institution_id_code | card_acceptor_country_code   | acquiring_institution_country_code | merchant_category_code | card_acceptor_terminal_id | card_acceptor_id | card_acceptor_name | card_acceptor_city |
      | T1                     | 843759                        | <card_acceptor_country_code> | <transaction_currency_code>        | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |
      | T2                     | 843759                        | <card_acceptor_country_code> | <transaction_currency_code>        | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |
      | T3                     | 843759                        | <card_acceptor_country_code> |                                    | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |
      | T4                     | 843759                        | <card_acceptor_country_code> |                                    | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount        | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason | case_type |
      | T1                     | authorization | <auth_transaction_amount_1> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 000           | Approved        | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_1> and total balance of <total_balance> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount          | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T1                     | VALID_UUID          | <auth_transaction_amount_1> | <auth_billing_amount_1> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount          | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T1                     | TxnId1          | <auth_transaction_amount_1> | <auth_billing_amount_1> | <transaction_currency_code> | <billing_currency_code> | DEBIT_INITIAL    | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount        | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason | case_type |
      | T2                     | authorization | <auth_transaction_amount_2> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 000           | Approved        | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_2> and total balance of <total_balance> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount           | billing_amount           | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T2                     | VALID_UUID          | <total_transaction_amount_1> | <total_billing_amount_1> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount           | billing_amount           | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T2                     | TxnId2          | <total_transaction_amount_1> | <total_billing_amount_1> | <transaction_currency_code> | <billing_currency_code> | DEBIT_INCREMENT  | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type | authorized_tx_amount        | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code      | response_reason      | case_type |
      | T3                     | reversal     | <actual_transaction_amount> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | <T3_response_code> | <T3_response_reason> | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_3> and total balance of <total_balance> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount          | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T3                     | VALID_UUID          | <actual_transaction_amount> | <actual_billing_amount> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount          | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_type   | transaction_status |
      | T3                     | TxnId3          | <actual_transaction_amount> | <actual_billing_amount> | <transaction_currency_code> | <billing_currency_code> | <transaction_type> | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount        | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason | case_type |
      | T4                     | authorization | <auth_transaction_amount_3> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 000           | Approved        | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_4> and total balance of <total_balance> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount           | billing_amount           | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T4                     | VALID_UUID          | <total_transaction_amount_2> | <total_billing_amount_2> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount           | billing_amount           | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T4                     | TxnId4          | <total_transaction_amount_2> | <total_billing_amount_2> | <transaction_currency_code> | <billing_currency_code> | DEBIT_INCREMENT  | COMPLETED          |

    Examples:
      | T1_message_qualifier | T2_message_qualifier | T3_message_qualifier | T4_message_qualifier | auth_transaction_amount_1 | auth_billing_amount_1 | auth_transaction_amount_2 | auth_billing_amount_2 | total_transaction_amount_1 | total_billing_amount_1 | auth_transaction_amount_3 | auth_billing_amount_3 | reversal_transaction_amount_1 | actual_transaction_amount | actual_billing_amount | total_transaction_amount_2 | total_billing_amount_2 | transaction_currency_code | transaction_currency | billing_currency_code | billing_currency | card_acceptor_country_code | total_transaction_amount | available_balance_1 | available_balance_2 | available_balance_3 | available_balance_4 | total_balance | transaction_type | T3_response_code | T3_response_reason  |
      | request              | request              | request              | request              | 100                       | 100                   | 50                        | 50                    | 150                        | 150                    | 30                        | 30                    | 70                            | 70                        | 70                    | 100                        | 100                    | 702                       | SGD                  | 702                   | SGD              | SG                         | 150                      | 900                 | 850                 | 930                 | 900                 | 1000          | DEBIT_REVERSAL   | 000              | Approved            |
      | request              | request              | notification         | request              | 100                       | 100                   | 50                        | 50                    | 150                        | 150                    | 30                        | 30                    | 70                            | 70                        | 70                    | 100                        | 100                    | 702                       | SGD                  | 702                   | SGD              | SG                         | 150                      | 900                 | 850                 | 930                 | 900                 | 1000          | DEBIT_REVERSAL   | 091              | Advice acknowledged |

  Scenario Outline: Clowd9-Test debit authorization with an incremental authorization then a full reversal and finally a debit authorization
    Given I build below transactions
      | transaction_identifier | message_type  | message_qualifier      | source |
      | T1                     | authorization | <T1_message_qualifier> | VISA   |
      | T2                     | authorization | <T2_message_qualifier> | VISA   |
      | T3                     | reversal      | <T3_message_qualifier> |        |
      | T4                     | authorization | <T4_message_qualifier> | VISA   |

    Then I set card objects in transaction context
      | transaction_identifier | card_identifier | card_form_factor |
      | T1                     | CardId1         | PHYSICAL         |
      | T2                     | CardId1         | PHYSICAL         |
      | T3                     | CardId1         | PHYSICAL         |
      | T4                     | CardId1         | PHYSICAL         |

    Then I set customer objects in transaction context
      | transaction_identifier | customer_identifier |
      | T1                     | CardAccId1          |
      | T2                     | CardAccId1          |
      | T3                     | CardAccId1          |
      | T4                     | CardAccId1          |

    Then I set transaction objects in transaction context
      | transaction_identifier | transaction_id | auth_type   | reversal_type | transaction_type | transaction_amount          | transaction_currency_code   | cardholder_billing_amount  | cardholder_billing_currency_code | system_trace_audit_number | retrieval_reference_number | network_transaction_id | transmission_date | transmission_time | transaction_local_date | transaction_local_time | dcc_indicator | chip_indicator | pin_indicator | three_ds_indicator | partial_approval_supported |
      | T1                     | TxnId1         |             |               | 00               | <auth_transaction_amount_1> | <transaction_currency_code> | <auth_billing_amount_1>    | <billing_currency_code>          | STAN1                     | RRN1                       | NT1                    | 1206              | 182751            | 1206                   | 192748                 | n             | contact        | online_passed | n                  | n                          |
      | T2                     | TxnId2         | INCREMENTAL |               | 00               | <auth_transaction_amount_2> | <transaction_currency_code> | <auth_billing_amount_2>    | <billing_currency_code>          | STAN2                     | RRN1                       | NT2                    | 0329              | 112336            | 0329                   | 112336                 | n             | contact        | online_passed | n                  | n                          |
      | T3                     | TxnId3         |             | FULL          | 00               | <total_transaction_amount>  | <transaction_currency_code> | <total_transaction_amount> | <billing_currency_code>          | STAN3                     | RRN1                       | NT3                    | 0329              | 142654            | 0329                   | 142654                 | n             | contact        | online_passed | n                  | n                          |
      | T4                     | TxnId4         |             |               | 00               | <auth_transaction_amount_3> | <transaction_currency_code> | <auth_billing_amount_3>    | <billing_currency_code>          | STAN4                     | RRN1                       | NT4                    | 0329              | 112336            | 0329                   | 112336                 | n             | contact        | online_passed | n                  | n                          |

    Then I set update in transaction context
      | transaction_identifier | original_transaction_id | original_message_type | original_message_qualifier | original_transaction_amount | original_system_trace_audit_number | original_retrieval_reference_number | original_transmission_date | original_transmission_time |
      | T3                     | TxnId1                  | authorization         | <T1_message_qualifier>     | <total_transaction_amount>  | STAN1                              | RRN1                                | 0329                       | 112336                     |

    Then I set status in transaction context
      | transaction_identifier | response_code | response_source | response_reason |
      | T3                     | 000           | Scheme          | Approved        |

    Then I set acquirer objects in transaction context
      | transaction_identifier | acquiring_institution_id_code | card_acceptor_country_code   | acquiring_institution_country_code | merchant_category_code | card_acceptor_terminal_id | card_acceptor_id | card_acceptor_name | card_acceptor_city |
      | T1                     | 843759                        | <card_acceptor_country_code> | <transaction_currency_code>        | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |
      | T2                     | 843759                        | <card_acceptor_country_code> |                                    | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |
      | T3                     | 843759                        | <card_acceptor_country_code> |                                    | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |
      | T4                     | 843759                        | <card_acceptor_country_code> | <transaction_currency_code>        | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount        | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason | case_type |
      | T1                     | authorization | <auth_transaction_amount_1> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 000           | Approved        | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_1> and total balance of <total_balance> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount          | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T1                     | VALID_UUID          | <auth_transaction_amount_1> | <auth_billing_amount_1> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount          | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T1                     | TxnId1          | <auth_transaction_amount_1> | <auth_billing_amount_1> | <transaction_currency_code> | <billing_currency_code> | DEBIT_INITIAL    | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount        | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason | case_type |
      | T2                     | authorization | <auth_transaction_amount_2> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 000           | Approved        | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_2> and total balance of <total_balance> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount         | billing_amount         | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T2                     | VALID_UUID          | <total_transaction_amount> | <total_billing_amount> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount         | billing_amount         | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T2                     | TxnId2          | <total_transaction_amount> | <total_billing_amount> | <transaction_currency_code> | <billing_currency_code> | DEBIT_INCREMENT  | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type | authorized_tx_amount | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code      | response_reason      | case_type |
      | T3                     | reversal     | 0                    | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | <T3_response_code> | <T3_response_reason> | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_3> and total balance of <total_balance> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount | billing_amount | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status   | release_auth_ts | release_type     |
      | T3                     | VALID_UUID          | 0                  | 0              | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | TRANSACTION_REVERTED | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount | billing_amount | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T3                     | TxnId3          | 0                  | 0              | <transaction_currency_code> | <billing_currency_code> | DEBIT_REVERSAL   | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount        | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code      | response_reason      | case_type |
      | T4                     | authorization | <auth_transaction_amount_3> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | <T4_response_code> | <T4_response_reason> | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_4> and total balance of <total_balance> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount          | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T4                     | VALID_UUID          | <auth_transaction_amount_3> | <auth_billing_amount_3> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount          | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T4                     | TxnId4          | <auth_transaction_amount_3> | <auth_billing_amount_3> | <transaction_currency_code> | <billing_currency_code> | DEBIT_INITIAL    | COMPLETED          |

    Examples:
      | T1_message_qualifier | T2_message_qualifier | T3_message_qualifier | T4_message_qualifier | auth_transaction_amount_1 | auth_billing_amount_1 | auth_transaction_amount_2 | auth_billing_amount_2 | total_transaction_amount | total_billing_amount | auth_transaction_amount_3 | auth_billing_amount_3 | transaction_currency_code | transaction_currency | billing_currency_code | billing_currency | card_acceptor_country_code | available_balance_1 | available_balance_2 | available_balance_3 | available_balance_4 | total_balance | T3_response_code | T3_response_reason  | T4_response_code | T4_response_reason  |
      | request              | request              | request              | request              | 100                       | 100                   | 50                        | 50                    | 150                      | 150                  | 30                        | 30                    | 702                       | SGD                  | 702                   | SGD              | SG                         | 900                 | 850                 | 1000                | 970                 | 1000          | 000              | Approved            | 000              | Approved            |
      | request              | request              | notification         | notification         | 1.6                       | 1.6                   | 500                       | 500                   | 501.6                    | 501.6                | 40                        | 40                    | 826                       | GBP                  | 702                   | SGD              | GB                         | 998.4               | 498.4               | 1000                | 960                 | 1000          | 091              | Advice acknowledged | 091              | Advice acknowledged |

  Scenario Outline: Clowd9-Test debit authorization with an incremental authorization then a partial reversal followed by a full reversal and finally a debit authorization
    Given I build below transactions
      | transaction_identifier | message_type  | message_qualifier      | source |
      | T1                     | authorization | <T1_message_qualifier> | VISA   |
      | T2                     | authorization | <T2_message_qualifier> | VISA   |
      | T3                     | reversal      | <T3_message_qualifier> |        |
      | T4                     | reversal      | <T4_message_qualifier> |        |
      | T5                     | authorization | <T5_message_qualifier> | VISA   |

    Then I set card objects in transaction context
      | transaction_identifier | card_identifier | card_form_factor |
      | T1                     | CardId1         | PHYSICAL         |
      | T2                     | CardId1         | PHYSICAL         |
      | T3                     | CardId1         | PHYSICAL         |
      | T4                     | CardId1         | PHYSICAL         |
      | T5                     | CardId1         | PHYSICAL         |

    Then I set customer objects in transaction context
      | transaction_identifier | customer_identifier |
      | T1                     | CardAccId1          |
      | T2                     | CardAccId1          |
      | T3                     | CardAccId1          |
      | T4                     | CardAccId1          |
      | T5                     | CardAccId1          |

    Then I set transaction objects in transaction context
      | transaction_identifier | transaction_id | auth_type   | reversal_type | transaction_type | transaction_amount            | transaction_currency_code   | cardholder_billing_amount | cardholder_billing_currency_code | system_trace_audit_number | retrieval_reference_number | network_transaction_id | transmission_date | transmission_time | transaction_local_date | transaction_local_time | dcc_indicator | chip_indicator | pin_indicator | three_ds_indicator | partial_approval_supported |
      | T1                     | TxnId1         |             |               | 00               | <auth_transaction_amount_1>   | <transaction_currency_code> | <auth_billing_amount_1>   | <billing_currency_code>          | STAN1                     | RRN1                       | NT1                    | 1206              | 182751            | 1206                   | 192748                 | n             | contact        | online_passed | n                  | n                          |
      | T2                     | TxnId2         | INCREMENTAL |               | 00               | <auth_transaction_amount_2>   | <transaction_currency_code> | <auth_billing_amount_2>   | <billing_currency_code>          | STAN2                     | RRN1                       | NT2                    | 0329              | 112336            | 0329                   | 112336                 | n             | contact        | online_passed | n                  | n                          |
      | T3                     | TxnId3         |             | PARTIAL       | 00               | <reversal_transaction_amount> | <transaction_currency_code> |                           |                                  | STAN3                     | RRN1                       | NT3                    | 0329              | 142654            | 0329                   | 142654                 | n             | contact        | online_passed | n                  | n                          |
      | T4                     | TxnId4         |             | FULL          | 00               | <reversal_transaction_amount> | <transaction_currency_code> |                           |                                  | STAN4                     | RRN1                       | NT4                    | 0329              | 142654            | 0329                   | 142654                 | n             | contact        | online_passed | n                  | n                          |
      | T5                     | TxnId5         |             |               | 00               | <auth_transaction_amount_3>   | <transaction_currency_code> | <auth_billing_amount_3>   | <billing_currency_code>          | STAN5                     | RRN1                       | NT5                    | 0329              | 112336            | 0329                   | 112336                 | n             | contact        | online_passed | n                  | n                          |

    Then I set update in transaction context
      | transaction_identifier | original_transaction_id | original_message_type | original_message_qualifier | original_transaction_amount   | actual_transaction_amount     | original_system_trace_audit_number | original_retrieval_reference_number | original_transmission_date | original_transmission_time |
      | T3                     | TxnId1                  | authorization         | <T1_message_qualifier>     | <total_transaction_amount>    | <reversal_transaction_amount> | STAN1                              | RRN1                                | 0329                       | 112336                     |
      | T4                     | TxnId1                  | authorization         | <T1_message_qualifier>     | <reversal_transaction_amount> |                               | STAN1                              | RRN1                                | 0329                       | 112336                     |

    Then I set status in transaction context
      | transaction_identifier | response_code | response_source | response_reason |
      | T3                     | 000           | Scheme          | Approved        |
      | T4                     | 000           | Scheme          | Approved        |

    Then I set acquirer objects in transaction context
      | transaction_identifier | acquiring_institution_id_code | card_acceptor_country_code   | acquiring_institution_country_code | merchant_category_code | card_acceptor_terminal_id | card_acceptor_id | card_acceptor_name | card_acceptor_city |
      | T1                     | 843759                        | <card_acceptor_country_code> | <transaction_currency_code>        | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |
      | T2                     | 843759                        | <card_acceptor_country_code> |                                    | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |
      | T3                     | 843759                        | <card_acceptor_country_code> |                                    | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |
      | T4                     | 843759                        | <card_acceptor_country_code> | <transaction_currency_code>        | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |
      | T5                     | 843759                        | <card_acceptor_country_code> | <transaction_currency_code>        | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount        | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason | case_type |
      | T1                     | authorization | <auth_transaction_amount_1> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 000           | Approved        | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_1> and total balance of 1000 for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount          | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T1                     | VALID_UUID          | <auth_transaction_amount_1> | <auth_billing_amount_1> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount          | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T1                     | TxnId1          | <auth_transaction_amount_1> | <auth_billing_amount_1> | <transaction_currency_code> | <billing_currency_code> | DEBIT_INITIAL    | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount        | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason | case_type |
      | T2                     | authorization | <auth_transaction_amount_2> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 000           | Approved        | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_2> and total balance of 1000 for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount         | billing_amount         | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T2                     | VALID_UUID          | <total_transaction_amount> | <total_billing_amount> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount         | billing_amount         | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T2                     | TxnId2          | <total_transaction_amount> | <total_billing_amount> | <transaction_currency_code> | <billing_currency_code> | DEBIT_INCREMENT  | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type | authorized_tx_amount          | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason | case_type |
      | T3                     | reversal     | <reversal_transaction_amount> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 000           | Approved        | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_3> and total balance of 1000 for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount            | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T3                     | VALID_UUID          | <reversal_transaction_amount> | <actual_billing_amount> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount            | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T3                     | TxnId3          | <reversal_transaction_amount> | <actual_billing_amount> | <transaction_currency_code> | <billing_currency_code> | DEBIT_REVERSAL   | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type | authorized_tx_amount | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason | case_type |
      | T4                     | reversal     | 0                    | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 000           | Approved        | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_4> and total balance of 1000 for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount | billing_amount | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status   | release_auth_ts | release_type     |
      | T4                     | VALID_UUID          | 0                  | 0              | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | TRANSACTION_REVERTED | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount | billing_amount | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T4                     | TxnId4          | 0                  | 0              | <transaction_currency_code> | <billing_currency_code> | DEBIT_REVERSAL   | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount        | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason | case_type |
      | T5                     | authorization | <auth_transaction_amount_3> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 000           | Approved        | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_5> and total balance of 1000 for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount          | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T5                     | VALID_UUID          | <auth_transaction_amount_3> | <auth_billing_amount_3> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount          | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T5                     | TxnId5          | <auth_transaction_amount_3> | <auth_billing_amount_3> | <transaction_currency_code> | <billing_currency_code> | DEBIT_INITIAL    | COMPLETED          |

    Examples:
      | T1_message_qualifier | T2_message_qualifier | T3_message_qualifier | T4_message_qualifier | T5_message_qualifier | auth_transaction_amount_1 | auth_billing_amount_1 | auth_transaction_amount_2 | auth_billing_amount_2 | total_transaction_amount | total_billing_amount | reversal_transaction_amount | actual_billing_amount | auth_transaction_amount_3 | auth_billing_amount_3 | transaction_currency_code | transaction_currency | billing_currency_code | billing_currency | card_acceptor_country_code | available_balance_1 | available_balance_2 | available_balance_3 | available_balance_4 | available_balance_5 | case_type |
      | request              | request              | request              | request              | request              | 100                       | 200                   | 50                        | 100                   | 150                      | 300                  | 70                          | 140                   | 30                        | 60                    | 702                       | SGD                  | 702                   | SGD              | SG                         | 800                 | 700                 | 860                 | 1000                | 940                 | positive  |

  Scenario Outline: Clowd9-Test debit authorization with an incremental authorization and then multiple partial reversals
    Given I build below transactions
      | transaction_identifier | message_type  | message_qualifier      | source |
      | T1                     | authorization | <T1_message_qualifier> | VISA   |
      | T2                     | authorization | <T2_message_qualifier> | VISA   |
      | T3                     | reversal      | <T3_message_qualifier> |        |
      | T4                     | reversal      | <T4_message_qualifier> |        |

    Then I set card objects in transaction context
      | transaction_identifier | card_identifier | card_form_factor |
      | T1                     | CardId1         | PHYSICAL         |
      | T2                     | CardId1         | PHYSICAL         |
      | T3                     | CardId1         | PHYSICAL         |
      | T4                     | CardId1         | PHYSICAL         |

    Then I set customer objects in transaction context
      | transaction_identifier | customer_identifier |
      | T1                     | CardAccId1          |
      | T2                     | CardAccId1          |
      | T3                     | CardAccId1          |
      | T4                     | CardAccId1          |

    Then I set transaction objects in transaction context
      | transaction_identifier | transaction_id | auth_type   | reversal_type | transaction_type | transaction_amount              | transaction_currency_code   | cardholder_billing_amount | cardholder_billing_currency_code | system_trace_audit_number | retrieval_reference_number | network_transaction_id | transmission_date | transmission_time | transaction_local_date | transaction_local_time | dcc_indicator | chip_indicator | pin_indicator | three_ds_indicator | partial_approval_supported |
      | T1                     | TxnId1         |             |               | 00               | <auth_transaction_amount_1>     | <transaction_currency_code> | <auth_billing_amount_1>   | <billing_currency_code>          | STAN1                     | RRN1                       | NT1                    | 1206              | 182751            | 1206                   | 192748                 | n             | contact        | online_passed | n                  | n                          |
      | T2                     | TxnId2         | INCREMENTAL |               | 00               | <auth_transaction_amount_2>     | <transaction_currency_code> | <auth_billing_amount_2>   | <billing_currency_code>          | STAN2                     | RRN1                       | NT2                    | 0329              | 112336            | 0329                   | 112336                 | n             | contact        | online_passed | n                  | n                          |
      | T3                     | TxnId3         |             | PARTIAL       | 00               | <reversal_transaction_amount_1> | <transaction_currency_code> |                           |                                  | STAN3                     | RRN1                       | NT3                    | 0329              | 142654            | 0329                   | 142654                 | n             | contact        | online_passed | n                  | n                          |
      | T4                     | TxnId4         |             | PARTIAL       | 00               | <reversal_transaction_amount_2> | <transaction_currency_code> |                           |                                  | STAN4                     | RRN1                       | NT4                    | 0329              | 142654            | 0329                   | 142654                 | n             | contact        | online_passed | n                  | n                          |

    Then I set update in transaction context
      | transaction_identifier | original_transaction_id | original_message_type | original_message_qualifier | original_transaction_amount     | actual_transaction_amount       | original_system_trace_audit_number | original_retrieval_reference_number | original_transmission_date | original_transmission_time |
      | T3                     | TxnId1                  | authorization         | <T1_message_qualifier>     | <total_transaction_amount>      | <reversal_transaction_amount_1> | STAN1                              | RRN1                                | 0329                       | 112336                     |
      | T4                     | TxnId1                  | authorization         | <T1_message_qualifier>     | <reversal_transaction_amount_1> | <reversal_transaction_amount_2> | STAN1                              | RRN1                                | 0329                       | 112336                     |

    Then I set status in transaction context
      | transaction_identifier | response_code | response_source | response_reason |
      | T3                     | 000           | Scheme          | Approved        |
      | T4                     | 000           | Scheme          | Approved        |

    Then I set acquirer objects in transaction context
      | transaction_identifier | acquiring_institution_id_code | card_acceptor_country_code   | acquiring_institution_country_code | merchant_category_code | card_acceptor_terminal_id | card_acceptor_id | card_acceptor_name | card_acceptor_city |
      | T1                     | 843759                        | <card_acceptor_country_code> | <transaction_currency_code>        | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |
      | T2                     | 843759                        | <card_acceptor_country_code> | <transaction_currency_code>        | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |
      | T3                     | 843759                        | <card_acceptor_country_code> |                                    | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |
      | T4                     | 843759                        | <card_acceptor_country_code> |                                    | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount        | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason | case_type |
      | T1                     | authorization | <auth_transaction_amount_1> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 000           | Approved        | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_1> and total balance of <total_balance> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount          | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T1                     | VALID_UUID          | <auth_transaction_amount_1> | <auth_billing_amount_1> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount          | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T1                     | TxnId1          | <auth_transaction_amount_1> | <auth_billing_amount_1> | <transaction_currency_code> | <billing_currency_code> | DEBIT_INITIAL    | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount        | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason | case_type |
      | T2                     | authorization | <auth_transaction_amount_2> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 000           | Approved        | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_2> and total balance of <total_balance> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount         | billing_amount         | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T2                     | VALID_UUID          | <total_transaction_amount> | <total_billing_amount> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount         | billing_amount         | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T2                     | TxnId2          | <total_transaction_amount> | <total_billing_amount> | <transaction_currency_code> | <billing_currency_code> | DEBIT_INCREMENT  | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type | authorized_tx_amount            | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason | case_type |
      | T3                     | reversal     | <reversal_transaction_amount_1> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 000           | Approved        | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_3> and total balance of <total_balance> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount              | billing_amount            | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T3                     | VALID_UUID          | <reversal_transaction_amount_1> | <actual_billing_amount_1> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount              | billing_amount            | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T3                     | TxnId3          | <reversal_transaction_amount_1> | <actual_billing_amount_1> | <transaction_currency_code> | <billing_currency_code> | DEBIT_REVERSAL   | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type | authorized_tx_amount            | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason | case_type |
      | T4                     | reversal     | <reversal_transaction_amount_2> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 000           | Approved        | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_4> and total balance of <total_balance> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount              | billing_amount            | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T4                     | VALID_UUID          | <reversal_transaction_amount_2> | <actual_billing_amount_2> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount              | billing_amount            | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T4                     | TxnId4          | <reversal_transaction_amount_2> | <actual_billing_amount_2> | <transaction_currency_code> | <billing_currency_code> | DEBIT_REVERSAL   | COMPLETED          |

    Examples:
      | T1_message_qualifier | T2_message_qualifier | T3_message_qualifier | T4_message_qualifier | auth_transaction_amount_1 | auth_billing_amount_1 | auth_transaction_amount_2 | auth_billing_amount_2 | total_transaction_amount | total_billing_amount | reversal_transaction_amount_1 | actual_billing_amount_1 | reversal_transaction_amount_2 | actual_billing_amount_2 | transaction_currency_code | transaction_currency | billing_currency_code | billing_currency | card_acceptor_country_code | available_balance_1 | available_balance_2 | available_balance_3 | available_balance_4 | total_balance | case_type |
      | request              | request              | request              | request              | 100                       | 100                   | 50                        | 50                    | 150                      | 150                  | 70                            | 70                      | 30                            | 30                      | 702                       | SGD                  | 702                   | SGD              | SG                         | 900                 | 850                 | 930                 | 970                 | 1000          | positive  |

  Scenario Outline: Clowd9-Test debit authorization with an incremental authorization then a partial reversal and finally a full reversal
    Given I build below transactions
      | transaction_identifier | message_type  | message_qualifier      | source |
      | T1                     | authorization | <T1_message_qualifier> | VISA   |
      | T2                     | authorization | <T2_message_qualifier> | VISA   |
      | T3                     | reversal      | <T3_message_qualifier> |        |
      | T4                     | reversal      | <T4_message_qualifier> |        |

    Then I set card objects in transaction context
      | transaction_identifier | card_identifier | card_form_factor |
      | T1                     | CardId1         | PHYSICAL         |
      | T2                     | CardId1         | PHYSICAL         |
      | T3                     | CardId1         | PHYSICAL         |
      | T4                     | CardId1         | PHYSICAL         |

    Then I set customer objects in transaction context
      | transaction_identifier | customer_identifier |
      | T1                     | CardAccId1          |
      | T2                     | CardAccId1          |
      | T3                     | CardAccId1          |
      | T4                     | CardAccId1          |

    Then I set transaction objects in transaction context
      | transaction_identifier | transaction_id | auth_type   | reversal_type | transaction_type | transaction_amount            | transaction_currency_code   | cardholder_billing_amount | cardholder_billing_currency_code | system_trace_audit_number | retrieval_reference_number | network_transaction_id | transmission_date | transmission_time | transaction_local_date | transaction_local_time | dcc_indicator | chip_indicator | pin_indicator | three_ds_indicator | partial_approval_supported |
      | T1                     | TxnId1         |             |               | 00               | <auth_transaction_amount_1>   | <transaction_currency_code> | <auth_billing_amount_1>   | <billing_currency_code>          | STAN1                     | RRN1                       | NT1                    | 1206              | 182751            | 1206                   | 192748                 | n             | contact        | online_passed | n                  | n                          |
      | T2                     | TxnId2         | INCREMENTAL |               | 00               | <auth_transaction_amount_2>   | <transaction_currency_code> | <auth_billing_amount_2>   | <billing_currency_code>          | STAN2                     | RRN1                       | NT2                    | 0329              | 112336            | 0329                   | 112336                 | n             | contact        | online_passed | n                  | n                          |
      | T3                     | TxnId3         |             | PARTIAL       | 00               | <reversal_transaction_amount> | <transaction_currency_code> |                           | <billing_currency_code>          | STAN3                     | RRN1                       | NT3                    | 0329              | 142654            | 0329                   | 142654                 | n             | contact        | online_passed | n                  | n                          |
      | T4                     | TxnId4         |             | FULL          | 00               | <reversal_transaction_amount> | <transaction_currency_code> |                           | <billing_currency_code>          | STAN4                     | RRN1                       | NT4                    | 0329              | 142654            | 0329                   | 142654                 | n             | contact        | online_passed | n                  | n                          |

    Then I set update in transaction context
      | transaction_identifier | original_transaction_id | original_message_type | original_message_qualifier | original_transaction_amount   | actual_transaction_amount     | original_system_trace_audit_number | original_retrieval_reference_number | original_transmission_date | original_transmission_time |
      | T3                     | TxnId1                  | authorization         | <T1_message_qualifier>     | <total_transaction_amount>    | <reversal_transaction_amount> | STAN1                              | RRN1                                | 0329                       | 112336                     |
      | T4                     | TxnId1                  | authorization         | <T1_message_qualifier>     | <reversal_transaction_amount> |                               | STAN1                              | RRN1                                | 0329                       | 112336                     |

    Then I set status in transaction context
      | transaction_identifier | response_code | response_source | response_reason |
      | T3                     | 000           | Scheme          | Approved        |
      | T4                     | 000           | Scheme          | Approved        |

    Then I set acquirer objects in transaction context
      | transaction_identifier | acquiring_institution_id_code | card_acceptor_country_code   | acquiring_institution_country_code | merchant_category_code | card_acceptor_terminal_id | card_acceptor_id | card_acceptor_name | card_acceptor_city |
      | T1                     | 843759                        | <card_acceptor_country_code> | <transaction_currency_code>        | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |
      | T2                     | 843759                        | <card_acceptor_country_code> |                                    | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |
      | T3                     | 843759                        | <card_acceptor_country_code> |                                    | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |
      | T4                     | 843759                        | <card_acceptor_country_code> | <transaction_currency_code>        | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount        | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason | case_type |
      | T1                     | authorization | <auth_transaction_amount_1> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 000           | Approved        | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_1> and total balance of <total_balance> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount          | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T1                     | VALID_UUID          | <auth_transaction_amount_1> | <auth_billing_amount_1> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount          | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T1                     | TxnId1          | <auth_transaction_amount_1> | <auth_billing_amount_1> | <transaction_currency_code> | <billing_currency_code> | DEBIT_INITIAL    | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount        | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason | case_type |
      | T2                     | authorization | <auth_transaction_amount_2> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 000           | Approved        | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_2> and total balance of <total_balance> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount         | billing_amount         | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T2                     | VALID_UUID          | <total_transaction_amount> | <total_billing_amount> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount         | billing_amount         | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T2                     | TxnId2          | <total_transaction_amount> | <total_billing_amount> | <transaction_currency_code> | <billing_currency_code> | DEBIT_INCREMENT  | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type | authorized_tx_amount          | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason | case_type |
      | T3                     | reversal     | <reversal_transaction_amount> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 000           | Approved        | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_3> and total balance of <total_balance> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount            | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T3                     | VALID_UUID          | <reversal_transaction_amount> | <actual_billing_amount> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount            | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T3                     | TxnId3          | <reversal_transaction_amount> | <actual_billing_amount> | <transaction_currency_code> | <billing_currency_code> | DEBIT_REVERSAL   | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type | authorized_tx_amount | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason | case_type |
      | T4                     | reversal     | 0                    | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 000           | Approved        | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <total_balance> and total balance of <total_balance> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount | billing_amount | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status   | release_auth_ts | release_type     |
      | T4                     | VALID_UUID          | 0                  | 0              | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | TRANSACTION_REVERTED | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount | billing_amount | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T4                     | TxnId4          | 0                  | 0              | <transaction_currency_code> | <billing_currency_code> | DEBIT_REVERSAL   | COMPLETED          |

    Examples:
      | T1_message_qualifier | T2_message_qualifier | T3_message_qualifier | T4_message_qualifier | auth_transaction_amount_1 | auth_billing_amount_1 | auth_transaction_amount_2 | auth_billing_amount_2 | total_transaction_amount | total_billing_amount | reversal_transaction_amount | actual_billing_amount | transaction_currency_code | transaction_currency | billing_currency_code | billing_currency | card_acceptor_country_code | available_balance_1 | available_balance_2 | available_balance_3 | total_balance | case_type |
      | request              | request              | request              | request              | 100                       | 100                   | 50                        | 50                    | 150                      | 150                  | 70                          | 70                    | 702                       | SGD                  | 702                   | SGD              | SG                         | 900                 | 850                 | 930                 | 1000          | positive  |

  Scenario Outline: Clowd9-Test decline transaction with card status update
    Given I build below transactions
      | transaction_identifier | message_type  | message_qualifier      | source |
      | T1                     | authorization | <T1_message_qualifier> | VISA   |

    Then I set card objects in transaction context
      | transaction_identifier | card_identifier | card_form_factor | card_status   | card_prev_status   |
      | T1                     | CardId1         | PHYSICAL         | <card_status> | <card_prev_status> |

    Then I set customer objects in transaction context
      | transaction_identifier | customer_identifier |
      | T1                     | CardAccId1          |

    Then I set transaction objects in transaction context
      | transaction_identifier | transaction_id | transaction_type | transaction_amount        | transaction_currency_code   | cardholder_billing_amount | cardholder_billing_currency_code | system_trace_audit_number | retrieval_reference_number | network_transaction_id | transmission_date | transmission_time | transaction_local_date | transaction_local_time | dcc_indicator | chip_indicator | pin_indicator | three_ds_indicator | partial_approval_supported |
      | T1                     | TxnId1         | 00               | <auth_transaction_amount> | <transaction_currency_code> | <auth_billing_amount>     | <billing_currency_code>          | STAN1                     | RRN1                       | NT1                    | 1206              | 182751            | 1206                   | 192748                 | n             | contact        | online_passed | n                  | n                          |

    Then I set status in transaction context
      | transaction_identifier | response_code | response_source | response_reason              |
      | T1                     | 104           | CLOWD9          | Allowable PIN Tries Exceeded |

    Then I set acquirer objects in transaction context
      | transaction_identifier | acquiring_institution_id_code | card_acceptor_country_code   | acquiring_institution_country_code | merchant_category_code | card_acceptor_terminal_id | card_acceptor_id | card_acceptor_name | card_acceptor_city |
      | T1                     | 843759                        | <card_acceptor_country_code> |                                    | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason     | case_type |
      | T1                     | authorization | 0                    | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 091           | Advice acknowledged | positive  |

    Then I validate card status by fetching card with id CardId1 and checking card status as <card_status>

    Examples:
      | T1_message_qualifier | auth_transaction_amount | auth_billing_amount | transaction_currency_code | transaction_currency | billing_currency_code | billing_currency | card_acceptor_country_code | card_prev_status | card_status |
      | notification         | 100                     | 100                 | 702                       | SGD                  | 702                   | SGD              | SG                         | ACTIVE           | EXPIRED     |

  Scenario Outline: Clowd9-Test declined authorization
    Given I build below transactions
      | transaction_identifier | message_type  | message_qualifier | source |
      | T1                     | authorization | notification      | VISA   |

    Then I set card objects in transaction context
      | transaction_identifier | card_identifier | card_form_factor |
      | T1                     | CardId1         | PHYSICAL         |

    Then I set customer objects in transaction context
      | transaction_identifier | customer_identifier |
      | T1                     | CardAccId1          |

    Then I set transaction objects in transaction context
      | transaction_identifier | transaction_id | transaction_type | transaction_amount        | transaction_currency_code   | cardholder_billing_amount | cardholder_billing_currency_code | system_trace_audit_number | retrieval_reference_number | network_transaction_id | transmission_date | transmission_time | transaction_local_date | transaction_local_time | dcc_indicator | chip_indicator | pin_indicator | three_ds_indicator | partial_approval_supported |
      | T1                     | TxnId1         | 00               | <auth_transaction_amount> | <transaction_currency_code> | <auth_billing_amount>     | <billing_currency_code>          | STAN1                     | RRN1                       | NT1                    | 1206              | 182751            | 1206                   | 192748                 | n             | contact        | online_passed | n                  | n                          |

    Then I set status in transaction context
      | transaction_identifier | response_code | response_source | response_reason                 |
      | T1                     | 121           | CLOWD9          | Exceeds Withdrawal Amount Limit |

    Then I set acquirer objects in transaction context
      | transaction_identifier | acquiring_institution_id_code | card_acceptor_country_code   | acquiring_institution_country_code | merchant_category_code | card_acceptor_terminal_id | card_acceptor_id | card_acceptor_name | card_acceptor_city |
      | T1                     | 843759                        | <card_acceptor_country_code> | <transaction_currency_code>        | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason     | case_type |
      | T1                     | authorization | 0                    | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 091           | Advice acknowledged | positive  |

    Examples:
      | auth_transaction_amount | auth_billing_amount | transaction_currency_code | transaction_currency | billing_currency_code | billing_currency | card_acceptor_country_code |
      | 100                     | 100                 | 702                       | SGD                  | 702                   | SGD              | SG                         |

  Scenario Outline: Clowd9-Test debit authorization and then clearing
    Given I build below transactions
      | transaction_identifier | message_type  | message_qualifier      | source |
      | T1                     | authorization | <T1_message_qualifier> | VISA   |
      | T2                     | clearing      | <T2_message_qualifier> |        |

    Then I set card objects in transaction context
      | transaction_identifier | card_identifier | card_form_factor |
      | T1                     | CardId1         | PHYSICAL         |

    Then I set customer objects in transaction context
      | transaction_identifier | customer_identifier |
      | T1                     | CardAccId1          |

    Then I set transaction objects in transaction context
      | transaction_identifier | transaction_id | transaction_type | transaction_amount        | transaction_currency_code   | cardholder_billing_amount | cardholder_billing_currency_code | system_trace_audit_number | retrieval_reference_number | network_transaction_id | transmission_date | transmission_time | transaction_local_date | transaction_local_time | dcc_indicator | chip_indicator | pin_indicator | three_ds_indicator | partial_approval_supported |
      | T1                     | TxnId1         | 00               | <auth_transaction_amount> | <transaction_currency_code> | <auth_billing_amount>     | <billing_currency_code>          | STAN1                     | RRN1                       | NT1                    | 1206              | 182751            | 1206                   | 192748                 | n             | contact        | online_passed | n                  | n                          |

    Then I set acquirer objects in transaction context
      | transaction_identifier | acquiring_institution_id_code | card_acceptor_country_code   | acquiring_institution_country_code | merchant_category_code | card_acceptor_terminal_id | card_acceptor_id | card_acceptor_name | card_acceptor_city |
      | T1                     | 843759                        | <card_acceptor_country_code> | <transaction_currency_code>        | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |

    Then I set clearing objects in transaction context
      | transaction_identifier | record_id_clearing | card_id | transaction_type | transaction_amount        | transaction_currency_code   | billing_amount            | billing_currency_code   | interchange_fee | clearing_category | clearing_outcome | authorization_code | reason_code | reference_number | sequence_number | clearing_date |
      | T2                     | TxnId2             | CardId1 | 1                | <auth_transaction_amount> | <transaction_currency_code> | <clearing_billing_amount> | <billing_currency_code> | C0000500        | sales_debit       | 0                | C90012             | 00          | 5942             | 1               | 1206          |

    Then I set authorizations to be cleared in transaction context
      | transaction_identifier | auth_transaction_id | system_trace_audit_number | retrieval_reference_number |
      | T2                     | TxnId1              | STAN1                     | RRN1                       |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount      | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason | case_type |
      | T1                     | authorization | <auth_transaction_amount> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 000           | Approved        | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance> and total balance of <total_balance_1> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount        | billing_amount        | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T1                     | VALID_UUID          | <auth_transaction_amount> | <auth_billing_amount> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount        | billing_amount        | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T1                     | TxnId1          | <auth_transaction_amount> | <auth_billing_amount> | <transaction_currency_code> | <billing_currency_code> | DEBIT_INITIAL    | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason     | case_type |
      | T2                     | clearing     | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 091           | Advice acknowledged | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance> and total balance of <total_balance_2> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | linked_transaction_ids | bank_transaction_id | transaction_amount        | billing_amount            | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | clearing                                                                                             | release_auth_ts | release_type     |
      | T2                     | TxnId1                 | VALID_UUID          | <auth_transaction_amount> | <clearing_billing_amount> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CLEAR      | SETTLED            | {"interchange_fee": 0.0005, "interchange_type": "CR", "clearing_outcome": "AUTH_FOUND_AMOUNT_MATCH"} | T+30            |                  |
      | T1                     | TxnId2                 | VALID_UUID          | 0                         | 0                         | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_CLEARED       |                                                                                                      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount        | billing_amount            | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T2                     | TxnId2          | <auth_transaction_amount> | <clearing_billing_amount> | <transaction_currency_code> | <billing_currency_code> | DEBIT_CLEAR      | COMPLETED          |

    Examples:
      | T1_message_qualifier | T2_message_qualifier | auth_transaction_amount | auth_billing_amount | clearing_billing_amount | transaction_currency_code | transaction_currency | billing_currency_code | billing_currency | card_acceptor_country_code | available_balance | total_balance_1 | total_balance_2 |
      | request              | notification         | 100                     | 100                 | 100                     | 702                       | SGD                  | 702                   | SGD              | SG                         | 900               | 1000            | 900             |

  Scenario Outline: Clowd9-Test debit authorization and then multiple clearing
    Given I build below transactions
      | transaction_identifier | message_type  | message_qualifier      | source |
      | T1                     | authorization | <T1_message_qualifier> | VISA   |
      | T2                     | clearing      | <T2_message_qualifier> |        |
      | T3                     | clearing      | <T3_message_qualifier> |        |

    Then I set card objects in transaction context
      | transaction_identifier | card_identifier | card_form_factor |
      | T1                     | CardId1         | PHYSICAL         |

    Then I set customer objects in transaction context
      | transaction_identifier | customer_identifier |
      | T1                     | CardAccId1          |

    Then I set transaction objects in transaction context
      | transaction_identifier | transaction_id | transaction_type | transaction_amount        | transaction_currency_code   | cardholder_billing_amount | cardholder_billing_currency_code | system_trace_audit_number | retrieval_reference_number | network_transaction_id | transmission_date | transmission_time | transaction_local_date | transaction_local_time | dcc_indicator | chip_indicator | pin_indicator | three_ds_indicator | partial_approval_supported |
      | T1                     | TxnId1         | 00               | <auth_transaction_amount> | <transaction_currency_code> | <auth_billing_amount>     | <billing_currency_code>          | STAN1                     | RRN1                       | NT1                    | 1206              | 182751            | 1206                   | 192748                 | n             | contact        | online_passed | n                  | n                          |

    Then I set acquirer objects in transaction context
      | transaction_identifier | acquiring_institution_id_code | card_acceptor_country_code   | acquiring_institution_country_code | merchant_category_code | card_acceptor_terminal_id | card_acceptor_id | card_acceptor_name | card_acceptor_city |
      | T1                     | 843759                        | <card_acceptor_country_code> | <transaction_currency_code>        | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |

    Then I set clearing objects in transaction context
      | transaction_identifier | record_id_clearing | card_id | transaction_type | transaction_amount          | transaction_currency_code   | billing_amount              | billing_currency_code   | interchange_fee | clearing_category | clearing_outcome | authorization_code | reason_code | reference_number | sequence_number | clearing_date |
      | T2                     | TxnId2             | CardId1 | 1                | <clearing_billing_amount_1> | <transaction_currency_code> | <clearing_billing_amount_1> | <billing_currency_code> | C0000400        | sales_debit       | 0                | C90012             | 00          | 5942             | 1               | 1206          |
      | T3                     | TxnId3             | CardId1 | 1                | <clearing_billing_amount_2> | <transaction_currency_code> | <clearing_billing_amount_2> | <billing_currency_code> | C0000300        | sales_debit       | 0                | C90012             | 00          | 5942             | 1               | 1206          |

    Then I set authorizations to be cleared in transaction context
      | transaction_identifier | auth_transaction_id | system_trace_audit_number | retrieval_reference_number |
      | T2                     | TxnId1              | STAN1                     | RRN1                       |
      | T3                     | TxnId1              | STAN1                     | RRN1                       |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount      | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason | case_type |
      | T1                     | authorization | <auth_transaction_amount> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 000           | Approved        | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance> and total balance of <total_balance_1> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount        | billing_amount        | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T1                     | VALID_UUID          | <auth_transaction_amount> | <auth_billing_amount> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount        | billing_amount        | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T1                     | TxnId1          | <auth_transaction_amount> | <auth_billing_amount> | <transaction_currency_code> | <billing_currency_code> | DEBIT_INITIAL    | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason     | case_type |
      | T2                     | clearing     | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 091           | Advice acknowledged | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance> and total balance of <total_balance_2> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | linked_transaction_ids | bank_transaction_id | transaction_amount          | billing_amount              | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | clearing                                                                                             | release_auth_ts | release_type     |
      | T2                     | TxnId1                 | VALID_UUID          | <clearing_billing_amount_1> | <clearing_billing_amount_1> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CLEAR      | SETTLED            | {"interchange_fee": 0.0004, "interchange_type": "CR", "clearing_outcome": "AUTH_FOUND_AMOUNT_MATCH"} | T+30            |                  |
      | T1                     | TxnId2                 | VALID_UUID          | <clearing_billing_amount_2> | <clearing_billing_amount_2> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      |                                                                                                      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount          | billing_amount              | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T2                     | TxnId2          | <clearing_billing_amount_1> | <clearing_billing_amount_1> | <transaction_currency_code> | <billing_currency_code> | DEBIT_CLEAR      | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason     | case_type |
      | T3                     | clearing     | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 091           | Advice acknowledged | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance> and total balance of <total_balance_3> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | linked_transaction_ids | bank_transaction_id | transaction_amount          | billing_amount              | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | clearing                                                                                             | release_auth_ts | release_type     |
      | T3                     | TxnId1                 | VALID_UUID          | <clearing_billing_amount_2> | <clearing_billing_amount_2> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CLEAR      | SETTLED            | {"interchange_fee": 0.0003, "interchange_type": "CR", "clearing_outcome": "AUTH_FOUND_AMOUNT_MATCH"} | T+30            |                  |
      | T1                     | TxnId2, TxnId3         | VALID_UUID          | 0                           | 0                           | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_CLEARED       |                                                                                                      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount          | billing_amount              | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T3                     | TxnId3          | <clearing_billing_amount_2> | <clearing_billing_amount_2> | <transaction_currency_code> | <billing_currency_code> | DEBIT_CLEAR      | COMPLETED          |

    Examples:
      | T1_message_qualifier | T2_message_qualifier | T3_message_qualifier | auth_transaction_amount | auth_billing_amount | clearing_billing_amount_1 | clearing_billing_amount_2 | transaction_currency_code | transaction_currency | billing_currency_code | billing_currency | card_acceptor_country_code | available_balance | total_balance_1 | total_balance_2 | total_balance_3 |
      | request              | notification         | notification         | 100                     | 100                 | 60                        | 40                        | 702                       | SGD                  | 702                   | SGD              | SG                         | 900               | 1000            | 940             | 900             |

  Scenario Outline: Clowd9-Test debit authorization with an incremental authorization and then a clearing
    Given I build below transactions
      | transaction_identifier | message_type  | message_qualifier      | source |
      | T1                     | authorization | <T1_message_qualifier> | VISA   |
      | T2                     | authorization | <T2_message_qualifier> | VISA   |
      | T3                     | clearing      | <T3_message_qualifier> |        |

    Then I set card objects in transaction context
      | transaction_identifier | card_identifier | card_form_factor |
      | T1                     | CardId1         | PHYSICAL         |
      | T2                     | CardId1         | PHYSICAL         |

    Then I set customer objects in transaction context
      | transaction_identifier | customer_identifier |
      | T1                     | CardAccId1          |
      | T2                     | CardAccId1          |

    Then I set transaction objects in transaction context
      | transaction_identifier | transaction_id | auth_type   | transaction_type | transaction_amount          | transaction_currency_code   | cardholder_billing_amount | cardholder_billing_currency_code | system_trace_audit_number | retrieval_reference_number | network_transaction_id | transmission_date | transmission_time | transaction_local_date | transaction_local_time | dcc_indicator | chip_indicator | pin_indicator | three_ds_indicator | partial_approval_supported |
      | T1                     | TxnId1         |             | 00               | <auth_transaction_amount_1> | <transaction_currency_code> | <auth_billing_amount_1>   | <billing_currency_code>          | STAN1                     | RRN1                       | NT1                    | 1206              | 182751            | 1206                   | 192748                 | n             | contact        | online_passed | n                  | n                          |
      | T2                     | TxnId2         | INCREMENTAL | 00               | <auth_transaction_amount_2> | <transaction_currency_code> | <auth_billing_amount_2>   | <billing_currency_code>          | STAN2                     | RRN1                       | NT2                    | 0329              | 112336            | 0329                   | 112336                 | n             | contact        | online_passed | n                  | n                          |

    Then I set acquirer objects in transaction context
      | transaction_identifier | acquiring_institution_id_code | card_acceptor_country_code   | acquiring_institution_country_code | merchant_category_code | card_acceptor_terminal_id | card_acceptor_id | card_acceptor_name | card_acceptor_city |
      | T1                     | 843759                        | <card_acceptor_country_code> |                                    | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |
      | T2                     | 843759                        | <card_acceptor_country_code> | <transaction_currency_code>        | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |

    Then I set clearing objects in transaction context
      | transaction_identifier | record_id_clearing | card_id | transaction_type | transaction_amount            | transaction_currency_code   | billing_amount            | billing_currency_code   | clearing_category | interchange_fee | clearing_outcome | authorization_code | reason_code | reference_number | sequence_number | clearing_date |
      | T3                     | TxnId3             | CardId1 | 1                | <clearing_transaction_amount> | <transaction_currency_code> | <clearing_billing_amount> | <billing_currency_code> | sales_debit       | C0000500        | 0                | C90012             | 00          | 5942             | 1               | 1206          |

    Then I set authorizations to be cleared in transaction context
      | transaction_identifier | auth_transaction_id | system_trace_audit_number | retrieval_reference_number |
      | T3                     | TxnId1              | STAN1                     | RRN1                       |
      | T3                     | TxnId2              | STAN2                     | RRN1                       |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount        | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason | case_type |
      | T1                     | authorization | <auth_transaction_amount_1> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 000           | Approved        | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_1> and total balance of <total_balance_1> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount          | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T1                     | VALID_UUID          | <auth_transaction_amount_1> | <auth_billing_amount_1> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount          | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T1                     | TxnId1          | <auth_transaction_amount_1> | <auth_billing_amount_1> | <transaction_currency_code> | <billing_currency_code> | DEBIT_INITIAL    | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount        | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason | case_type |
      | T2                     | authorization | <auth_transaction_amount_2> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 000           | Approved        | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_2> and total balance of <total_balance_2> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount         | billing_amount         | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T2                     | VALID_UUID          | <total_transaction_amount> | <total_billing_amount> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount         | billing_amount         | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T2                     | TxnId2          | <total_transaction_amount> | <total_billing_amount> | <transaction_currency_code> | <billing_currency_code> | DEBIT_INCREMENT  | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason     | case_type |
      | T3                     | clearing     | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 091           | Advice acknowledged | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_3> and total balance of <total_balance_3> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | linked_transaction_ids | bank_transaction_id | transaction_amount            | billing_amount            | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | clearing                                                                                             | release_auth_ts | release_type     |
      | T3                     | TxnId1                 | VALID_UUID          | <clearing_transaction_amount> | <clearing_billing_amount> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CLEAR      | SETTLED            | {"interchange_fee": 0.0005, "interchange_type": "CR", "clearing_outcome": "AUTH_FOUND_AMOUNT_MATCH"} | T+30            |                  |
      | T1                     | TxnId3                 | VALID_UUID          | 0                             | 0                         | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_CLEARED       |                                                                                                      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount            | billing_amount            | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T3                     | TxnId3          | <clearing_transaction_amount> | <clearing_billing_amount> | <transaction_currency_code> | <billing_currency_code> | DEBIT_CLEAR      | COMPLETED          |

    Examples:
      | T1_message_qualifier | T2_message_qualifier | T3_message_qualifier | auth_transaction_amount_1 | auth_billing_amount_1 | auth_transaction_amount_2 | auth_billing_amount_2 | total_transaction_amount | total_billing_amount | clearing_transaction_amount | clearing_billing_amount | transaction_currency_code | transaction_currency | billing_currency_code | billing_currency | card_acceptor_country_code | available_balance_1 | available_balance_2 | available_balance_3 | total_balance_1 | total_balance_2 | total_balance_3 |
      | request              | request              | notification         | 100                       | 100                   | 50                        | 50                    | 150                      | 150                  | 150                         | 150                     | 702                       | SGD                  | 702                   | SGD              | SG                         | 900                 | 850                 | 850                 | 1000            | 1000            | 850             |

  Scenario Outline: Clowd9-Test debit authorization with an incremental authorization followed by multiple clearing
    Given I build below transactions
      | transaction_identifier | message_type  | message_qualifier      | source |
      | T1                     | authorization | <T1_message_qualifier> | VISA   |
      | T2                     | authorization | <T2_message_qualifier> | VISA   |
      | T3                     | clearing      | <T3_message_qualifier> |        |
      | T4                     | clearing      | <T4_message_qualifier> |        |

    Then I set card objects in transaction context
      | transaction_identifier | card_identifier | card_form_factor |
      | T1                     | CardId1         | PHYSICAL         |
      | T2                     | CardId1         | PHYSICAL         |

    Then I set customer objects in transaction context
      | transaction_identifier | customer_identifier |
      | T1                     | CardAccId1          |
      | T2                     | CardAccId1          |

    Then I set transaction objects in transaction context
      | transaction_identifier | transaction_id | auth_type   | transaction_type | transaction_amount          | transaction_currency_code   | cardholder_billing_amount | cardholder_billing_currency_code | system_trace_audit_number | retrieval_reference_number | network_transaction_id | transmission_date | transmission_time | transaction_local_date | transaction_local_time | dcc_indicator | chip_indicator | pin_indicator | three_ds_indicator | partial_approval_supported |
      | T1                     | TxnId1         |             | 00               | <auth_transaction_amount_1> | <transaction_currency_code> | <auth_billing_amount_1>   | <billing_currency_code>          | STAN1                     | RRN1                       | NT1                    | 1206              | 182751            | 1206                   | 192748                 | n             | contact        | online_passed | n                  | n                          |
      | T2                     | TxnId2         | INCREMENTAL | 00               | <auth_transaction_amount_2> | <transaction_currency_code> | <auth_billing_amount_2>   | <billing_currency_code>          | STAN2                     | RRN1                       | NT2                    | 0329              | 112336            | 0329                   | 112336                 | n             | contact        | online_passed | n                  | n                          |

    Then I set acquirer objects in transaction context
      | transaction_identifier | acquiring_institution_id_code | card_acceptor_country_code   | acquiring_institution_country_code | merchant_category_code | card_acceptor_terminal_id | card_acceptor_id | card_acceptor_name | card_acceptor_city |
      | T1                     | 843759                        | <card_acceptor_country_code> | <transaction_currency_code>        | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |
      | T2                     | 843759                        | <card_acceptor_country_code> |                                    | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |

    Then I set clearing objects in transaction context
      | transaction_identifier | record_id_clearing | card_id | transaction_type | transaction_amount              | transaction_currency_code   | billing_amount              | billing_currency_code   | interchange_fee | clearing_category | clearing_outcome | authorization_code | reason_code | reference_number | sequence_number | clearing_date |
      | T3                     | TxnId3             | CardId1 | 1                | <clearing_transaction_amount_1> | <transaction_currency_code> | <clearing_billing_amount_1> | <billing_currency_code> | C0000500        | sales_debit       | 0                | C90012             | 00          | 5942             | 1               | 1206          |
      | T4                     | TxnId4             | CardId1 | 1                | <clearing_transaction_amount_2> | <transaction_currency_code> | <clearing_billing_amount_2> | <billing_currency_code> | C0000500        | sales_debit       | 0                | C90012             | 00          | 5942             | 1               | 1206          |

    Then I set authorizations to be cleared in transaction context
      | transaction_identifier | auth_transaction_id | system_trace_audit_number | retrieval_reference_number |
      | T3                     | TxnId2              | STAN2                     | RRN1                       |
      | T4                     | TxnId2              | STAN2                     | RRN1                       |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount        | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason | case_type |
      | T1                     | authorization | <auth_transaction_amount_1> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 000           | Approved        | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_1> and total balance of <total_balance_1> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount          | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T1                     | VALID_UUID          | <auth_transaction_amount_1> | <auth_billing_amount_1> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount          | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T1                     | TxnId1          | <auth_transaction_amount_1> | <auth_billing_amount_1> | <transaction_currency_code> | <billing_currency_code> | DEBIT_INITIAL    | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount        | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason | case_type |
      | T2                     | authorization | <auth_transaction_amount_2> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 000           | Approved        | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_2> and total balance of <total_balance_2> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount         | billing_amount         | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T2                     | VALID_UUID          | <total_transaction_amount> | <total_billing_amount> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount         | billing_amount         | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T2                     | TxnId2          | <total_transaction_amount> | <total_billing_amount> | <transaction_currency_code> | <billing_currency_code> | DEBIT_INCREMENT  | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason     | case_type |
      | T3                     | clearing     | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 091           | Advice acknowledged | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_3> and total balance of <total_balance_3> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | linked_transaction_ids | bank_transaction_id | transaction_amount              | billing_amount              | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | clearing                                                                                             | release_auth_ts | release_type     |
      | T3                     | TxnId2                 | VALID_UUID          | <clearing_transaction_amount_1> | <clearing_billing_amount_1> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CLEAR      | SETTLED            | {"interchange_fee": 0.0005, "interchange_type": "CR", "clearing_outcome": "AUTH_FOUND_AMOUNT_MATCH"} | T+30            |                  |
      | T1                     | TxnId3                 | VALID_UUID          | <clearing_transaction_amount_2> | <clearing_billing_amount_2> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      |                                                                                                      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount              | billing_amount              | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T3                     | TxnId3          | <clearing_transaction_amount_1> | <clearing_billing_amount_1> | <transaction_currency_code> | <billing_currency_code> | DEBIT_CLEAR      | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason     | case_type |
      | T4                     | clearing     | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 091           | Advice acknowledged | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_4> and total balance of <total_balance_4> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | linked_transaction_ids | bank_transaction_id | transaction_amount              | billing_amount              | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | clearing                                                                                             | release_auth_ts | release_type     |
      | T4                     | TxnId2                 | VALID_UUID          | <clearing_transaction_amount_2> | <clearing_billing_amount_2> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CLEAR      | SETTLED            | {"interchange_fee": 0.0005, "interchange_type": "CR", "clearing_outcome": "AUTH_FOUND_AMOUNT_MATCH"} | T+30            |                  |
      | T1                     | TxnId3, TxnId4         | VALID_UUID          | 0                               | 0                           | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_CLEARED       |                                                                                                      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount              | billing_amount              | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T4                     | TxnId4          | <clearing_transaction_amount_2> | <clearing_billing_amount_2> | <transaction_currency_code> | <billing_currency_code> | DEBIT_CLEAR      | COMPLETED          |

    Examples:
      | T1_message_qualifier | T2_message_qualifier | T3_message_qualifier | T4_message_qualifier | auth_transaction_amount_1 | auth_billing_amount_1 | auth_transaction_amount_2 | auth_billing_amount_2 | total_transaction_amount | total_billing_amount | clearing_transaction_amount_1 | clearing_billing_amount_1 | clearing_transaction_amount_2 | clearing_billing_amount_2 | transaction_currency_code | transaction_currency | billing_currency_code | billing_currency | card_acceptor_country_code | available_balance_1 | available_balance_2 | available_balance_3 | available_balance_4 | total_balance_1 | total_balance_2 | total_balance_3 | total_balance_4 |
      | request              | request              | notification         | notification         | 100                       | 100                   | 50                        | 50                    | 150                      | 150                  | 60                            | 60                        | 90                            | 90                        | 702                       | SGD                  | 702                   | SGD              | SG                         | 900                 | 850                 | 850                 | 850                 | 1000            | 1000            | 940             | 850             |

  Scenario Outline: Clowd9-Test pre-authorization transaction is accepted with 000 Approved when completion is sent for lesser amount
    Given I build below transactions
      | transaction_identifier | message_type  | message_qualifier      | source |
      | T1                     | authorization | <T1_message_qualifier> | VISA   |
      | T2                     | authorization | <T2_message_qualifier> | VISA   |
      | T3                     | clearing      | <T3_message_qualifier> |        |

    Then I set card objects in transaction context
      | transaction_identifier | card_identifier | card_form_factor |
      | T1                     | CardId1         | PHYSICAL         |
      | T2                     | CardId1         | PHYSICAL         |

    Then I set customer objects in transaction context
      | transaction_identifier | customer_identifier |
      | T1                     | CardAccId1          |
      | T2                     | CardAccId1          |

    Then I set transaction objects in transaction context
      | transaction_identifier | transaction_id | auth_type  | transaction_type | transaction_amount          | transaction_currency_code   | cardholder_billing_amount | cardholder_billing_currency_code | system_trace_audit_number | retrieval_reference_number | network_transaction_id | transmission_date | transmission_time | transaction_local_date | transaction_local_time | dcc_indicator | chip_indicator | pin_indicator | three_ds_indicator | partial_approval_supported |
      | T1                     | TxnId1         | PREAUTH    | 00               | <auth_transaction_amount_1> | <transaction_currency_code> | <auth_billing_amount_1>   | <billing_currency_code>          | STAN1                     | RRN1                       | NT1                    | 1206              | 182751            | 1206                   | 192748                 | n             | contact        | online_passed | n                  | n                          |
      | T2                     | TxnId2         | COMPLETION | 00               | <auth_transaction_amount_2> | <transaction_currency_code> | <auth_billing_amount_2>   | <billing_currency_code>          | STAN2                     | RRN1                       | NT2                    | 0329              | 112336            | 0329                   | 112336                 | n             | contact        | online_passed | n                  | n                          |

    Then I set update in transaction context
      | transaction_identifier | original_transaction_id | original_message_type | original_message_qualifier | original_transaction_amount | actual_transaction_amount   | original_system_trace_audit_number | original_retrieval_reference_number | original_transmission_date | original_transmission_time |
      | T2                     | TxnId1                  | authorization         | <T1_message_qualifier>     | <auth_transaction_amount_1> | <auth_transaction_amount_2> | STAN1                              | RRN1                                | 1206                       | 182751                     |

    Then I set acquirer objects in transaction context
      | transaction_identifier | acquiring_institution_id_code | card_acceptor_country_code   | acquiring_institution_country_code | merchant_category_code | card_acceptor_terminal_id | card_acceptor_id | card_acceptor_name | card_acceptor_city |
      | T1                     | 843759                        | <card_acceptor_country_code> |                                    | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |
      | T2                     | 843759                        | <card_acceptor_country_code> | <transaction_currency_code>        | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |

    Then I set clearing objects in transaction context
      | transaction_identifier | record_id_clearing | card_id | transaction_type | transaction_amount            | transaction_currency_code   | billing_amount            | billing_currency_code   | interchange_fee | clearing_category | clearing_outcome | authorization_code | reason_code | reference_number | sequence_number | clearing_date |
      | T3                     | TxnId3             | CardId1 | 1                | <clearing_transaction_amount> | <transaction_currency_code> | <clearing_billing_amount> | <billing_currency_code> | C0000500        | sales_debit       | 0                | C90012             | 00          | 5942             | 1               | 1206          |

    Then I set authorizations to be cleared in transaction context
      | transaction_identifier | auth_transaction_id | system_trace_audit_number | retrieval_reference_number |
      | T3                     | TxnId2              | STAN2                     | RRN1                       |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount        | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason | case_type |
      | T1                     | authorization | <auth_transaction_amount_1> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 000           | Approved        | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <avail_bal1> and total balance of 1000 for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount          | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T1                     | VALID_UUID          | <auth_transaction_amount_1> | <auth_billing_amount_1> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount          | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T1                     | TxnId1          | <auth_transaction_amount_1> | <auth_billing_amount_1> | <transaction_currency_code> | <billing_currency_code> | DEBIT_INITIAL    | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount        | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason     | case_type |
      | T2                     | authorization | <auth_transaction_amount_2> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 091           | Advice acknowledged | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <avail_bal2> and total balance of 1000 for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount          | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T2                     | VALID_UUID          | <auth_transaction_amount_2> | <auth_billing_amount_2> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount          | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T2                     | TxnId2          | <auth_transaction_amount_2> | <auth_billing_amount_2> | <transaction_currency_code> | <billing_currency_code> | DEBIT_REVERSAL   | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason     | case_type |
      | T3                     | clearing     | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 091           | Advice acknowledged | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <avail_bal3> and total balance of <avail_bal3> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | linked_transaction_ids | bank_transaction_id | transaction_amount            | billing_amount            | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | clearing                                                                                             | release_auth_ts | release_type     |
      | T3                     | TxnId2                 | VALID_UUID          | <clearing_transaction_amount> | <clearing_billing_amount> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CLEAR      | SETTLED            | {"interchange_fee": 0.0005, "interchange_type": "CR", "clearing_outcome": "AUTH_FOUND_AMOUNT_MATCH"} | T+30            |                  |
      | T1                     | TxnId3                 | VALID_UUID          | 0                             | 0                         | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_CLEARED       |                                                                                                      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount            | billing_amount            | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T3                     | TxnId3          | <clearing_transaction_amount> | <clearing_billing_amount> | <transaction_currency_code> | <billing_currency_code> | DEBIT_CLEAR      | COMPLETED          |

    Examples:
      | T1_message_qualifier | T2_message_qualifier | T3_message_qualifier | auth_transaction_amount_1 | auth_billing_amount_1 | auth_transaction_amount_2 | auth_billing_amount_2 | clearing_transaction_amount | clearing_billing_amount | transaction_currency_code | transaction_currency | billing_currency_code | billing_currency | card_acceptor_country_code | avail_bal1 | avail_bal2 | avail_bal3 |
      | request              | notification         | notification         | 100                       | 100                   | 80                        | 80                    | 80                          | 80                      | 702                       | SGD                  | 702                   | SGD              | SG                         | 900        | 920        | 920        |
      | request              | notification         | notification         | 100                       | 200                   | 50                        | 100                   | 50                          | 100                     | 826                       | GBP                  | 702                   | SGD              | GB                         | 800        | 900        | 900        |

  Scenario Outline: Clowd9-Test pre-authorization transaction is accepted with 000 Approved when completion is sent for greater amount
    Given I build below transactions
      | transaction_identifier | message_type  | message_qualifier      | source |
      | T1                     | authorization | <T1_message_qualifier> | VISA   |
      | T2                     | authorization | <T2_message_qualifier> | VISA   |

    Then I set card objects in transaction context
      | transaction_identifier | card_identifier | card_form_factor |
      | T1                     | CardId1         | PHYSICAL         |
      | T2                     | CardId1         | PHYSICAL         |

    Then I set customer objects in transaction context
      | transaction_identifier | customer_identifier |
      | T1                     | CardAccId1          |
      | T2                     | CardAccId1          |

    Then I set transaction objects in transaction context
      | transaction_identifier | transaction_id | auth_type  | transaction_type | transaction_amount          | transaction_currency_code   | cardholder_billing_amount | cardholder_billing_currency_code | system_trace_audit_number | retrieval_reference_number | network_transaction_id | transmission_date | transmission_time | transaction_local_date | transaction_local_time | dcc_indicator | chip_indicator | pin_indicator | three_ds_indicator | partial_approval_supported |
      | T1                     | TxnId1         | PREAUTH    | 00               | <auth_transaction_amount_1> | <transaction_currency_code> | <auth_billing_amount_1>   | <billing_currency_code>          | STAN1                     | RRN1                       | NT1                    | 1206              | 182751            | 1206                   | 192748                 | n             | contact        | online_passed | n                  | n                          |
      | T2                     | TxnId2         | COMPLETION | 00               | <auth_transaction_amount_2> | <transaction_currency_code> | <auth_billing_amount_2>   | <billing_currency_code>          | STAN2                     | RRN1                       | NT2                    | 0329              | 112336            | 0329                   | 112336                 | n             | contact        | online_passed | n                  | n                          |

    Then I set update in transaction context
      | transaction_identifier | original_transaction_id | original_message_type | original_message_qualifier | original_transaction_amount | actual_transaction_amount   | original_system_trace_audit_number | original_retrieval_reference_number | original_transmission_date | original_transmission_time |
      | T2                     | TxnId1                  | authorization         | <T1_message_qualifier>     | <auth_transaction_amount_1> | <auth_transaction_amount_2> | STAN1                              | RRN1                                | 1206                       | 182751                     |

    Then I set acquirer objects in transaction context
      | transaction_identifier | acquiring_institution_id_code | card_acceptor_country_code   | acquiring_institution_country_code | merchant_category_code | card_acceptor_terminal_id | card_acceptor_id | card_acceptor_name | card_acceptor_city |
      | T1                     | 843759                        | <card_acceptor_country_code> |                                    | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |
      | T2                     | 843759                        | <card_acceptor_country_code> | <transaction_currency_code>        | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount        | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason | case_type |
      | T1                     | authorization | <auth_transaction_amount_1> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 000           | Approved        | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of 900 and total balance of 1000 for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount          | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T1                     | VALID_UUID          | <auth_transaction_amount_1> | <auth_billing_amount_1> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount          | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T1                     | TxnId1          | <auth_transaction_amount_1> | <auth_billing_amount_1> | <transaction_currency_code> | <billing_currency_code> | DEBIT_INITIAL    | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount        | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason     | case_type |
      | T2                     | authorization | <auth_transaction_amount_2> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 091           | Advice acknowledged | positive  |

    Examples:
      | T1_message_qualifier | T2_message_qualifier | auth_transaction_amount_1 | auth_billing_amount_1 | auth_transaction_amount_2 | auth_billing_amount_2 | transaction_currency_code | transaction_currency | billing_currency_code | billing_currency | card_acceptor_country_code |
      | request              | notification         | 100                       | 100                   | 120                       | 120                   | 702                       | SGD                  | 702                   | SGD              | SG                         |

  Scenario Outline: Clowd9-Test debit authorization with a partial reversal then a full clearing
    Given I build below transactions
      | transaction_identifier | message_type  | message_qualifier      | source |
      | T1                     | authorization | <T1_message_qualifier> | VISA   |
      | T2                     | reversal      | <T2_message_qualifier> |        |
      | T3                     | clearing      | <T3_message_qualifier> |        |

    Then I set card objects in transaction context
      | transaction_identifier | card_identifier | card_form_factor |
      | T1                     | CardId1         | PHYSICAL         |
      | T2                     | CardId1         | PHYSICAL         |

    Then I set customer objects in transaction context
      | transaction_identifier | customer_identifier |
      | T1                     | CardAccId1          |
      | T2                     | CardAccId1          |

    Then I set transaction objects in transaction context
      | transaction_identifier | transaction_id | reversal_type | transaction_type | transaction_amount            | transaction_currency_code   | cardholder_billing_amount | cardholder_billing_currency_code | system_trace_audit_number | retrieval_reference_number | network_transaction_id | transmission_date | transmission_time | transaction_local_date | transaction_local_time | dcc_indicator | chip_indicator | pin_indicator | three_ds_indicator | partial_approval_supported |
      | T1                     | TxnId1         |               | 00               | <auth_transaction_amount>     | <transaction_currency_code> | <auth_billing_amount>     | <billing_currency_code>          | STAN1                     | RRN1                       | NT1                    | 1206              | 182751            | 1206                   | 192748                 | n             | contact        | online_passed | n                  | n                          |
      | T2                     | TxnId2         | PARTIAL       | 00               | <reversal_transaction_amount> | <transaction_currency_code> |                           |                                  | STAN2                     | RRN1                       | NT2                    | 0329              | 142654            | 0329                   | 142654                 | n             | contact        | online_passed | n                  | n                          |

    Then I set update in transaction context
      | transaction_identifier | original_transaction_id | original_message_type | original_message_qualifier | original_transaction_amount | actual_transaction_amount     | original_system_trace_audit_number | original_retrieval_reference_number | original_transmission_date | original_transmission_time |
      | T2                     | TxnId1                  | authorization         | <T1_message_qualifier>     | <auth_transaction_amount>   | <reversal_transaction_amount> | STAN1                              | RRN1                                | 1206                       | 192748                     |

    Then I set status in transaction context
      | transaction_identifier | response_code | response_source | response_reason |
      | T2                     | 000           | Scheme          | Approved        |

    Then I set acquirer objects in transaction context
      | transaction_identifier | acquiring_institution_id_code | card_acceptor_country_code   | acquiring_institution_country_code | merchant_category_code | card_acceptor_terminal_id | card_acceptor_id | card_acceptor_name | card_acceptor_city |
      | T1                     | 843759                        | <card_acceptor_country_code> | <transaction_currency_code>        | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |
      | T2                     | 843759                        | <card_acceptor_country_code> |                                    | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |

    Then I set clearing objects in transaction context
      | transaction_identifier | record_id_clearing | card_id | transaction_type | transaction_amount            | transaction_currency_code   | billing_amount            | billing_currency_code   | interchange_fee | clearing_category | clearing_outcome | authorization_code | reason_code | reference_number | sequence_number | clearing_date |
      | T3                     | TxnId3             | CardId1 | 1                | <clearing_transaction_amount> | <transaction_currency_code> | <clearing_billing_amount> | <billing_currency_code> | C0000500        | sales_debit       | 0                | C90012             | 00          | 5942             | 1               | 1206          |

    Then I set authorizations to be cleared in transaction context
      | transaction_identifier | auth_transaction_id | system_trace_audit_number | retrieval_reference_number |
      | T3                     | TxnId1              | STAN1                     | RRN1                       |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount      | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason | case_type |
      | T1                     | authorization | <auth_transaction_amount> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 000           | Approved        | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_1> and total balance of <total_balance_1> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount        | billing_amount        | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T1                     | VALID_UUID          | <auth_transaction_amount> | <auth_billing_amount> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount        | billing_amount        | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T1                     | TxnId1          | <auth_transaction_amount> | <auth_billing_amount> | <transaction_currency_code> | <billing_currency_code> | DEBIT_INITIAL    | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type | authorized_tx_amount          | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason | case_type |
      | T2                     | reversal     | <reversal_transaction_amount> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 000           | Approved        | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_2> and total balance of <total_balance_2> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount            | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T2                     | VALID_UUID          | <reversal_transaction_amount> | <actual_billing_amount> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount            | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T2                     | TxnId2          | <reversal_transaction_amount> | <actual_billing_amount> | <transaction_currency_code> | <billing_currency_code> | DEBIT_REVERSAL   | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason     | case_type |
      | T3                     | clearing     | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 091           | Advice acknowledged | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_3> and total balance of <total_balance_3> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | linked_transaction_ids | bank_transaction_id | transaction_amount            | billing_amount            | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | clearing                                                                                             | release_auth_ts | release_type     |
      | T3                     | TxnId1                 | VALID_UUID          | <clearing_transaction_amount> | <clearing_billing_amount> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CLEAR      | SETTLED            | {"interchange_fee": 0.0005, "interchange_type": "CR", "clearing_outcome": "AUTH_FOUND_AMOUNT_MATCH"} | T+30            |                  |
      | T1                     | TxnId3                 | VALID_UUID          | 0                             | 0                         | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_CLEARED       |                                                                                                      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount            | billing_amount            | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T3                     | TxnId3          | <clearing_transaction_amount> | <clearing_billing_amount> | <transaction_currency_code> | <billing_currency_code> | DEBIT_CLEAR      | COMPLETED          |

    Examples:
      | T1_message_qualifier | T2_message_qualifier | T3_message_qualifier | auth_transaction_amount | auth_billing_amount | reversal_transaction_amount | actual_billing_amount | clearing_transaction_amount | clearing_billing_amount | transaction_currency_code | transaction_currency | billing_currency_code | billing_currency | card_acceptor_country_code | available_balance_1 | available_balance_2 | available_balance_3 | total_balance_1 | total_balance_2 | total_balance_3 | case_type |
      | request              | request              | notification         | 100                     | 100                 | 80                          | 80                    | 80                          | 80                      | 702                       | SGD                  | 702                   | SGD              | SG                         | 900                 | 920                 | 920                 | 1000            | 1000            | 920             | positive  |

  Scenario Outline: Clowd9-Test debit authorization, followed by an incremental authorization, then a partial reversal, and finally a full clearing.
    Given I build below transactions
      | transaction_identifier | message_type  | message_qualifier      | source |
      | T1                     | authorization | <T1_message_qualifier> | VISA   |
      | T2                     | authorization | <T2_message_qualifier> | VISA   |
      | T3                     | reversal      | <T3_message_qualifier> |        |
      | T4                     | clearing      | <T4_message_qualifier> |        |

    Then I set card objects in transaction context
      | transaction_identifier | card_identifier | card_form_factor |
      | T1                     | CardId1         | PHYSICAL         |
      | T2                     | CardId1         | PHYSICAL         |
      | T3                     | CardId1         | PHYSICAL         |

    Then I set customer objects in transaction context
      | transaction_identifier | customer_identifier |
      | T1                     | CardAccId1          |
      | T2                     | CardAccId1          |
      | T3                     | CardAccId1          |

    Then I set transaction objects in transaction context
      | transaction_identifier | transaction_id | auth_type   | reversal_type | transaction_type | transaction_amount            | transaction_currency_code   | cardholder_billing_amount | cardholder_billing_currency_code | system_trace_audit_number | retrieval_reference_number | network_transaction_id | transmission_date | transmission_time | transaction_local_date | transaction_local_time | dcc_indicator | chip_indicator | pin_indicator | three_ds_indicator | partial_approval_supported |
      | T1                     | TxnId1         |             |               | 00               | <auth_transaction_amount_1>   | <transaction_currency_code> | <auth_billing_amount_1>   | <billing_currency_code>          | STAN1                     | RRN1                       | NT1                    | 1206              | 182751            | 1206                   | 192748                 | n             | contact        | online_passed | n                  | n                          |
      | T2                     | TxnId2         | INCREMENTAL |               | 00               | <auth_transaction_amount_2>   | <transaction_currency_code> | <auth_billing_amount_2>   | <billing_currency_code>          | STAN2                     | RRN1                       | NT2                    | 0329              | 112336            | 0329                   | 112336                 | n             | contact        | online_passed | n                  | n                          |
      | T3                     | TxnId3         |             | PARTIAL       | 00               | <reversal_transaction_amount> | <transaction_currency_code> |                           |                                  | STAN3                     | RRN1                       | NT3                    | 0329              | 142654            | 0329                   | 142654                 | n             | contact        | online_passed | n                  | n                          |

    Then I set update in transaction context
      | transaction_identifier | original_message_type | original_message_qualifier | original_transaction_amount | actual_transaction_amount | original_transaction_id | original_system_trace_audit_number | original_retrieval_reference_number | original_transmission_date | original_transmission_time |
      | T3                     | authorization         | <T2_message_qualifier>     | <total_transaction_amount>  | <actual_billing_amount>   | TxnId2                  | STAN2                              | RRN1                                | 0329                       | 112336                     |

    Then I set status in transaction context
      | transaction_identifier | response_code | response_source | response_reason |
      | T3                     | 000           | Scheme          | Approved        |

    Then I set acquirer objects in transaction context
      | transaction_identifier | acquiring_institution_id_code | card_acceptor_country_code   | acquiring_institution_country_code | merchant_category_code | card_acceptor_terminal_id | card_acceptor_id | card_acceptor_name | card_acceptor_city |
      | T1                     | 843759                        | <card_acceptor_country_code> | <transaction_currency_code>        | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |
      | T2                     | 843759                        | <card_acceptor_country_code> | <transaction_currency_code>        | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |
      | T3                     | 843759                        | <card_acceptor_country_code> |                                    | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |

    Then I set clearing objects in transaction context
      | transaction_identifier | record_id_clearing | card_id | transaction_type | transaction_amount            | transaction_currency_code   | billing_amount            | billing_currency_code   | interchange_fee | clearing_category | clearing_outcome | authorization_code | reason_code | reference_number | sequence_number | clearing_date |
      | T4                     | TxnId4             | CardId1 | 1                | <clearing_transaction_amount> | <transaction_currency_code> | <clearing_billing_amount> | <billing_currency_code> | C0000500        | sales_debit       | 0                | C90012             | 00          | 5942             | 1               | 1206          |

    Then I set authorizations to be cleared in transaction context
      | transaction_identifier | auth_transaction_id | system_trace_audit_number | retrieval_reference_number |
      | T4                     | TxnId2              | STAN2                     | RRN1                       |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount        | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason | case_type |
      | T1                     | authorization | <auth_transaction_amount_1> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 000           | Approved        | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_1> and total balance of <total_balance_1> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount          | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T1                     | VALID_UUID          | <auth_transaction_amount_1> | <auth_billing_amount_1> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount          | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T1                     | TxnId1          | <auth_transaction_amount_1> | <auth_billing_amount_1> | <transaction_currency_code> | <billing_currency_code> | DEBIT_INITIAL    | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount        | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason | case_type |
      | T2                     | authorization | <auth_transaction_amount_2> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 000           | Approved        | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_2> and total balance of <total_balance_2> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount         | billing_amount         | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T2                     | VALID_UUID          | <total_transaction_amount> | <total_billing_amount> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount         | billing_amount         | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T2                     | TxnId2          | <total_transaction_amount> | <total_billing_amount> | <transaction_currency_code> | <billing_currency_code> | DEBIT_INCREMENT  | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type | authorized_tx_amount    | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason     | case_type |
      | T3                     | reversal     | <actual_billing_amount> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 091           | Advice acknowledged | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_3> and total balance of <total_balance_3> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount            | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T3                     | VALID_UUID          | <reversal_transaction_amount> | <actual_billing_amount> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount            | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T3                     | TxnId3          | <reversal_transaction_amount> | <actual_billing_amount> | <transaction_currency_code> | <billing_currency_code> | DEBIT_REVERSAL   | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason     | case_type |
      | T4                     | clearing     | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 091           | Advice acknowledged | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_4> and total balance of <total_balance_4> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | linked_transaction_ids | bank_transaction_id | transaction_amount            | billing_amount            | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | clearing                                                                                             | release_auth_ts | release_type     |
      | T4                     | TxnId1                 | VALID_UUID          | <clearing_transaction_amount> | <clearing_billing_amount> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CLEAR      | SETTLED            | {"interchange_fee": 0.0005, "interchange_type": "CR", "clearing_outcome": "AUTH_FOUND_AMOUNT_MATCH"} | T+30            |                  |
      | T1                     | TxnId4                 | VALID_UUID          | 0                             | 0                         | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_CLEARED       |                                                                                                      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount            | billing_amount            | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T4                     | TxnId4          | <clearing_transaction_amount> | <clearing_billing_amount> | <transaction_currency_code> | <billing_currency_code> | DEBIT_CLEAR      | COMPLETED          |

    Examples:
      | T1_message_qualifier | T2_message_qualifier | T3_message_qualifier | T4_message_qualifier | auth_transaction_amount_1 | auth_billing_amount_1 | auth_transaction_amount_2 | auth_billing_amount_2 | total_transaction_amount | total_billing_amount | reversal_transaction_amount | actual_billing_amount | clearing_transaction_amount | clearing_billing_amount | transaction_currency_code | transaction_currency | billing_currency_code | billing_currency | card_acceptor_country_code | available_balance_1 | available_balance_2 | available_balance_3 | available_balance_4 | total_balance_1 | total_balance_2 | total_balance_3 | total_balance_4 | case_type |
      | request              | request              | notification         | notification         | 100                       | 100                   | 50                        | 50                    | 150                      | 150                  | 70                          | 70                    | 70                          | 70                      | 702                       | SGD                  | 702                   | SGD              | SG                         | 900                 | 850                 | 930                 | 930                 | 1000            | 1000            | 1000            | 930             | positive  |

  Scenario Outline: Clowd9-Test debit authorization followed by partial reversal, then a partial clearing, and finally a full clearing
    Given I build below transactions
      | transaction_identifier | message_type  | message_qualifier      | source |
      | T1                     | authorization | <T1_message_qualifier> | VISA   |
      | T2                     | reversal      | <T2_message_qualifier> | VISA   |
      | T3                     | clearing      | <T3_message_qualifier> |        |
      | T4                     | clearing      | <T4_message_qualifier> |        |

    Then I set card objects in transaction context
      | transaction_identifier | card_identifier | card_form_factor |
      | T1                     | CardId1         | PHYSICAL         |
      | T2                     | CardId1         | PHYSICAL         |

    Then I set customer objects in transaction context
      | transaction_identifier | customer_identifier |
      | T1                     | CardAccId1          |
      | T2                     | CardAccId1          |

    Then I set transaction objects in transaction context
      | transaction_identifier | transaction_id | reversal_type | transaction_type | transaction_amount            | transaction_currency_code   | cardholder_billing_amount | cardholder_billing_currency_code | system_trace_audit_number | retrieval_reference_number | network_transaction_id | transmission_date | transmission_time | transaction_local_date | transaction_local_time | dcc_indicator | chip_indicator | pin_indicator | three_ds_indicator | partial_approval_supported |
      | T1                     | TxnId1         |               | 00               | <auth_transaction_amount>     | <transaction_currency_code> | <auth_billing_amount>     | <billing_currency_code>          | STAN1                     | RRN1                       | NT1                    | 1206              | 182751            | 1206                   | 192748                 | n             | contact        | online_passed | n                  | n                          |
      | T2                     | TxnId2         | PARTIAL       | 00               | <reversal_transaction_amount> | <transaction_currency_code> |                           |                                  | STAN2                     | RRN1                       | NT2                    | 1206              | 142654            | 1206                   | 142654                 | n             | contact        | online_passed | n                  | n                          |

    Then I set update in transaction context
      | transaction_identifier | original_transaction_id | original_message_type | original_message_qualifier | original_transaction_amount | actual_transaction_amount     | original_system_trace_audit_number | original_retrieval_reference_number | original_transmission_date | original_transmission_time |
      | T2                     | TxnId1                  | authorization         | <T1_message_qualifier>     | <auth_transaction_amount>   | <reversal_transaction_amount> | STAN1                              | RRN1                                | 1206                       | 192748                     |

    Then I set status in transaction context
      | transaction_identifier | response_code | response_source | response_reason |
      | T2                     | 000           | Scheme          | Approved        |

    Then I set acquirer objects in transaction context
      | transaction_identifier | acquiring_institution_id_code | card_acceptor_country_code   | acquiring_institution_country_code | merchant_category_code | card_acceptor_terminal_id | card_acceptor_id | card_acceptor_name | card_acceptor_city |
      | T1                     | 843759                        | <card_acceptor_country_code> |                                    | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |
      | T2                     | 843759                        | <card_acceptor_country_code> | <transaction_currency_code>        | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |

    Then I set clearing objects in transaction context
      | transaction_identifier | record_id_clearing | card_id | transaction_type | transaction_amount              | transaction_currency_code   | billing_amount              | billing_currency_code   | interchange_fee | clearing_category | clearing_outcome | authorization_code | reason_code | reference_number | sequence_number | clearing_date |
      | T3                     | TxnId3             | CardId1 | 1                | <clearing_transaction_amount_1> | <transaction_currency_code> | <clearing_billing_amount_1> | <billing_currency_code> | C0000500        | sales_debit       | 0                | C90012             | 00          | 5942             | 1               | 1206          |
      | T4                     | TxnId4             | CardId1 | 1                | <clearing_transaction_amount_2> | <transaction_currency_code> | <clearing_billing_amount_2> | <billing_currency_code> | C0000500        | sales_debit       | 0                | C90012             | 00          | 5942             | 1               | 1206          |

    Then I set authorizations to be cleared in transaction context
      | transaction_identifier | auth_transaction_id | system_trace_audit_number | retrieval_reference_number |
      | T3                     | TxnId1              | STAN1                     | RRN1                       |
      | T4                     | TxnId1              | STAN1                     | RRN1                       |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount      | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason | case_type |
      | T1                     | authorization | <auth_transaction_amount> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 000           | Approved        | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_1> and total balance of 1000 for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount        | billing_amount        | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T1                     | VALID_UUID          | <auth_transaction_amount> | <auth_billing_amount> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount        | billing_amount        | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T1                     | TxnId1          | <auth_transaction_amount> | <auth_billing_amount> | <transaction_currency_code> | <billing_currency_code> | DEBIT_INITIAL    | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type | authorized_tx_amount          | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason | case_type |
      | T2                     | reversal     | <reversal_transaction_amount> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 000           | Approved        | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_2> and total balance of 1000 for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount            | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T2                     | VALID_UUID          | <reversal_transaction_amount> | <actual_billing_amount> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount            | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T2                     | TxnId2          | <reversal_transaction_amount> | <actual_billing_amount> | <transaction_currency_code> | <billing_currency_code> | DEBIT_REVERSAL   | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason     | case_type |
      | T3                     | clearing     | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 091           | Advice acknowledged | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_3> and total balance of <total_balance_3> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | linked_transaction_ids | bank_transaction_id | transaction_amount              | billing_amount              | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | clearing                                                                                             | release_auth_ts | release_type     |
      | T3                     | TxnId1                 | VALID_UUID          | <clearing_transaction_amount_1> | <clearing_billing_amount_1> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CLEAR      | SETTLED            | {"interchange_fee": 0.0005, "interchange_type": "CR", "clearing_outcome": "AUTH_FOUND_AMOUNT_MATCH"} | T+30            |                  |
      | T1                     | TxnId3                 | VALID_UUID          | <clearing_transaction_amount_2> | <clearing_billing_amount_2> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      |                                                                                                      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount              | billing_amount              | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T3                     | TxnId3          | <clearing_transaction_amount_1> | <clearing_billing_amount_1> | <transaction_currency_code> | <billing_currency_code> | DEBIT_CLEAR      | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason     | case_type |
      | T4                     | clearing     | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 091           | Advice acknowledged | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_4> and total balance of <total_balance_4> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | linked_transaction_ids | bank_transaction_id | transaction_amount              | billing_amount              | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | clearing                                                                                             | release_auth_ts | release_type     |
      | T4                     | TxnId1                 | VALID_UUID          | <clearing_transaction_amount_2> | <clearing_billing_amount_2> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CLEAR      | SETTLED            | {"interchange_fee": 0.0005, "interchange_type": "CR", "clearing_outcome": "AUTH_FOUND_AMOUNT_MATCH"} | T+30            |                  |
      | T1                     | TxnId3, TxnId4         | VALID_UUID          | 0                               | 0                           | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_CLEARED       |                                                                                                      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount              | billing_amount              | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T4                     | TxnId4          | <clearing_transaction_amount_2> | <clearing_billing_amount_2> | <transaction_currency_code> | <billing_currency_code> | DEBIT_CLEAR      | COMPLETED          |

    Examples:
      | T1_message_qualifier | T2_message_qualifier | T3_message_qualifier | T4_message_qualifier | auth_transaction_amount | auth_billing_amount | reversal_transaction_amount | actual_billing_amount | clearing_transaction_amount_1 | clearing_billing_amount_1 | clearing_transaction_amount_2 | clearing_billing_amount_2 | transaction_currency_code | transaction_currency | billing_currency_code | billing_currency | card_acceptor_country_code | available_balance_1 | available_balance_2 | available_balance_3 | available_balance_4 | total_balance_3 | total_balance_4 | case_type |
      | request              | request              | notification         | notification         | 100                     | 100                 | 80                          | 80                    | 40                            | 40                        | 40                            | 40                        | 702                       | SGD                  | 702                   | SGD              | SG                         | 900                 | 920                 | 920                 | 920                 | 960             | 920             | positive  |

  Scenario Outline: Clowd9-Test debit authorization followed by incremental authorization, then a partial reversal and a partial clearing, and finally a full clearing
    Given I build below transactions
      | transaction_identifier | message_type  | message_qualifier      | source |
      | T1                     | authorization | <T1_message_qualifier> | VISA   |
      | T2                     | authorization | <T2_message_qualifier> | VISA   |
      | T3                     | reversal      | <T3_message_qualifier> |        |
      | T4                     | clearing      | <T4_message_qualifier> |        |
      | T5                     | clearing      | <T5_message_qualifier> |        |

    Then I set card objects in transaction context
      | transaction_identifier | card_identifier | card_form_factor |
      | T1                     | CardId1         | PHYSICAL         |
      | T2                     | CardId1         | PHYSICAL         |
      | T3                     | CardId1         | PHYSICAL         |

    Then I set customer objects in transaction context
      | transaction_identifier | customer_identifier |
      | T1                     | CardAccId1          |
      | T2                     | CardAccId1          |
      | T3                     | CardAccId1          |

    Then I set transaction objects in transaction context
      | transaction_identifier | transaction_id | auth_type   | reversal_type | transaction_type | transaction_amount            | transaction_currency_code   | cardholder_billing_amount | cardholder_billing_currency_code | system_trace_audit_number | retrieval_reference_number | network_transaction_id | transmission_date | transmission_time | transaction_local_date | transaction_local_time | dcc_indicator | chip_indicator | pin_indicator | three_ds_indicator | partial_approval_supported |
      | T1                     | TxnId1         |             |               | 00               | <auth_transaction_amount_1>   | <transaction_currency_code> | <auth_billing_amount_1>   | <billing_currency_code>          | STAN1                     | RRN1                       | NT1                    | 1206              | 182751            | 1206                   | 192748                 | n             | contact        | online_passed | n                  | n                          |
      | T2                     | TxnId2         | INCREMENTAL |               | 00               | <auth_transaction_amount_2>   | <transaction_currency_code> | <auth_billing_amount_2>   | <billing_currency_code>          | STAN2                     | RRN1                       | NT2                    | 0329              | 112336            | 0329                   | 112336                 | n             | contact        | online_passed | n                  | n                          |
      | T3                     | TxnId3         |             | PARTIAL       | 00               | <reversal_transaction_amount> | <transaction_currency_code> |                           |                                  | STAN3                     | RRN1                       | NT3                    | 0329              | 142654            | 0329                   | 142654                 | n             | contact        | online_passed | n                  | n                          |

    Then I set update in transaction context
      | transaction_identifier | original_transaction_id | original_message_type | original_message_qualifier | original_transaction_amount | actual_transaction_amount     | original_system_trace_audit_number | original_retrieval_reference_number | original_transmission_date | original_transmission_time |
      | T3                     | TxnId1                  | authorization         | <T1_message_qualifier>     | <total_transaction_amount>  | <reversal_transaction_amount> | STAN1                              | RRN1                                | 0329                       | 112336                     |

    Then I set status in transaction context
      | transaction_identifier | response_code | response_source | response_reason |
      | T3                     | 000           | Scheme          | Approved        |

    Then I set acquirer objects in transaction context
      | transaction_identifier | acquiring_institution_id_code | card_acceptor_country_code   | acquiring_institution_country_code | merchant_category_code | card_acceptor_terminal_id | card_acceptor_id | card_acceptor_name | card_acceptor_city |
      | T1                     | 843759                        | <card_acceptor_country_code> | <transaction_currency_code>        | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |
      | T2                     | 843759                        | <card_acceptor_country_code> |                                    | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |
      | T3                     | 843759                        | <card_acceptor_country_code> |                                    | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |

    Then I set clearing objects in transaction context
      | transaction_identifier | record_id_clearing | card_id | transaction_type | transaction_amount              | transaction_currency_code   | billing_amount              | billing_currency_code   | interchange_fee | clearing_category | clearing_outcome | authorization_code | reason_code | reference_number | sequence_number | clearing_date |
      | T4                     | TxnId4             | CardId1 | 1                | <clearing_transaction_amount_1> | <transaction_currency_code> | <clearing_billing_amount_1> | <billing_currency_code> | C0000400        | sales_debit       | 0                | C90012             | 00          | 5942             | 1               | 1206          |
      | T5                     | TxnId5             | CardId1 | 1                | <clearing_transaction_amount_2> | <transaction_currency_code> | <clearing_billing_amount_2> | <billing_currency_code> | C0000400        | sales_debit       | 0                | C90012             | 00          | 5942             | 1               | 1206          |

    Then I set authorizations to be cleared in transaction context
      | transaction_identifier | auth_transaction_id | system_trace_audit_number | retrieval_reference_number |
      | T4                     | TxnId1              | STAN1                     | RRN1                       |
      | T5                     | TxnId1              | STAN1                     | RRN1                       |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount        | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason | case_type |
      | T1                     | authorization | <auth_transaction_amount_1> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 000           | Approved        | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_1> and total balance of 1000 for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount          | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T1                     | VALID_UUID          | <auth_transaction_amount_1> | <auth_billing_amount_1> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount          | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T1                     | TxnId1          | <auth_transaction_amount_1> | <auth_billing_amount_1> | <transaction_currency_code> | <billing_currency_code> | DEBIT_INITIAL    | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount        | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason | case_type |
      | T2                     | authorization | <auth_transaction_amount_2> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 000           | Approved        | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_2> and total balance of 1000 for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount         | billing_amount         | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T2                     | VALID_UUID          | <total_transaction_amount> | <total_billing_amount> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount         | billing_amount         | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T2                     | TxnId2          | <total_transaction_amount> | <total_billing_amount> | <transaction_currency_code> | <billing_currency_code> | DEBIT_INCREMENT  | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type | authorized_tx_amount          | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason | case_type |
      | T3                     | reversal     | <reversal_transaction_amount> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 000           | Approved        | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_3> and total balance of 1000 for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount            | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T3                     | VALID_UUID          | <reversal_transaction_amount> | <actual_billing_amount> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount            | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T3                     | TxnId3          | <reversal_transaction_amount> | <actual_billing_amount> | <transaction_currency_code> | <billing_currency_code> | DEBIT_REVERSAL   | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason     | case_type |
      | T4                     | clearing     | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 091           | Advice acknowledged | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_4> and total balance of <total_balance_4> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | linked_transaction_ids | bank_transaction_id | transaction_amount              | billing_amount              | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | clearing                                                                                             | release_auth_ts | release_type     |
      | T4                     | TxnId1                 | VALID_UUID          | <clearing_transaction_amount_1> | <clearing_billing_amount_1> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CLEAR      | SETTLED            | {"interchange_fee": 0.0004, "interchange_type": "CR", "clearing_outcome": "AUTH_FOUND_AMOUNT_MATCH"} | T+30            |                  |
      | T1                     | TxnId4                 | VALID_UUID          | <clearing_transaction_amount_2> | <clearing_billing_amount_2> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_ACQUIRED      |                                                                                                      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount              | billing_amount              | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T4                     | TxnId4          | <clearing_transaction_amount_1> | <clearing_billing_amount_1> | <transaction_currency_code> | <billing_currency_code> | DEBIT_CLEAR      | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason     | case_type |
      | T5                     | clearing     | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 091           | Advice acknowledged | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_5> and total balance of <total_balance_5> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | linked_transaction_ids | bank_transaction_id | transaction_amount              | billing_amount              | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | clearing                                                                                             | release_auth_ts | release_type     |
      | T5                     | TxnId1                 | VALID_UUID          | <clearing_transaction_amount_2> | <clearing_billing_amount_2> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CLEAR      | SETTLED            | {"interchange_fee": 0.0004, "interchange_type": "CR", "clearing_outcome": "AUTH_FOUND_AMOUNT_MATCH"} | T+30            |                  |
      | T1                     | TxnId4, TxnId5         | VALID_UUID          | 0                               | 0                           | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CREATE     | AUTH_CLEARED       |                                                                                                      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount              | billing_amount              | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T5                     | TxnId5          | <clearing_transaction_amount_2> | <clearing_billing_amount_2> | <transaction_currency_code> | <billing_currency_code> | DEBIT_CLEAR      | COMPLETED          |

    Examples:
      | T1_message_qualifier | T2_message_qualifier | T3_message_qualifier | T4_message_qualifier | T5_message_qualifier | auth_transaction_amount_1 | auth_billing_amount_1 | auth_transaction_amount_2 | auth_billing_amount_2 | total_transaction_amount | total_billing_amount | reversal_transaction_amount | actual_billing_amount | clearing_transaction_amount_1 | clearing_billing_amount_1 | clearing_transaction_amount_2 | clearing_billing_amount_2 | transaction_currency_code | transaction_currency | billing_currency_code | billing_currency | card_acceptor_country_code | available_balance_1 | available_balance_2 | available_balance_3 | available_balance_4 | available_balance_5 | total_balance_4 | total_balance_5 |
      | request              | request              | request              | notification         | notification         | 100                       | 100                   | 50                        | 50                    | 150                      | 150                  | 80                          | 80                    | 40                            | 40                        | 40                            | 40                        | 702                       | SGD                  | 702                   | SGD              | SG                         | 900                 | 850                 | 920                 | 920                 | 920                 | 960             | 920             |

  Scenario Outline: Clowd9-Test refund authorization request accepted with 000 Approved

    Given I build below transactions
      | transaction_identifier | message_type  | message_qualifier      | source |
      | T1                     | authorization | <T1_message_qualifier> | VISA   |

    Then I set card objects in transaction context
      | transaction_identifier | card_identifier | card_form_factor |
      | T1                     | CardId1         | PHYSICAL         |

    Then I set customer objects in transaction context
      | transaction_identifier | customer_identifier |
      | T1                     | CardAccId1          |

    Then I set transaction objects in transaction context
      | transaction_identifier | transaction_id | transaction_type | transaction_amount          | transaction_currency_code   | cardholder_billing_amount | cardholder_billing_currency_code | system_trace_audit_number | retrieval_reference_number | network_transaction_id | transmission_date | transmission_time | transaction_local_date | transaction_local_time | dcc_indicator | chip_indicator | pin_indicator | three_ds_indicator | partial_approval_supported |
      | T1                     | TxnId1         | 20               | <refund_transaction_amount> | <transaction_currency_code> | <refund_billing_amount>   | <billing_currency_code>          | STAN1                     | RRN1                       | NT1                    | 1206              | 182751            | 1206                   | 192748                 | n             | contact        | online_passed | n                  | n                          |

    Then I set acquirer objects in transaction context
      | transaction_identifier | acquiring_institution_id_code | card_acceptor_country_code   | acquiring_institution_country_code | merchant_category_code | card_acceptor_terminal_id | card_acceptor_id | card_acceptor_name | card_acceptor_city |
      | T1                     | 843759                        | <card_acceptor_country_code> |                                    | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount        | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason | case_type |
      | T1                     | authorization | <refund_transaction_amount> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 000           | Approved        | positive  |

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount          | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T1                     | VALID_UUID          | <refund_transaction_amount> | <refund_billing_amount> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | CREDIT_CREATE    | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount          | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T1                     | TxnId1          | <refund_transaction_amount> | <refund_billing_amount> | <transaction_currency_code> | <billing_currency_code> | CREDIT_INITIAL   | COMPLETED          |

    Examples:
      | T1_message_qualifier | refund_transaction_amount | refund_billing_amount | transaction_currency_code | transaction_currency | billing_currency_code | billing_currency | card_acceptor_country_code |
      | request              | 100                       | 100                   | 702                       | SGD                  | 702                   | SGD              | SG                         |

  Scenario Outline: Clowd9-Test refund authorization request and then a full clearing

    Given I build below transactions
      | transaction_identifier | message_type  | message_qualifier      | source |
      | T1                     | authorization | <T1_message_qualifier> | VISA   |
      | T2                     | clearing      | <T2_message_qualifier> |        |

    Then I set card objects in transaction context
      | transaction_identifier | card_identifier | card_form_factor |
      | T1                     | CardId1         | PHYSICAL         |

    Then I set customer objects in transaction context
      | transaction_identifier | customer_identifier |
      | T1                     | CardAccId1          |

    Then I set transaction objects in transaction context
      | transaction_identifier | transaction_id | transaction_type | transaction_amount          | transaction_currency_code   | cardholder_billing_amount | cardholder_billing_currency_code | system_trace_audit_number | retrieval_reference_number | network_transaction_id | transmission_date | transmission_time | transaction_local_date | transaction_local_time | dcc_indicator | chip_indicator | pin_indicator | three_ds_indicator | partial_approval_supported |
      | T1                     | TxnId1         | 20               | <refund_transaction_amount> | <transaction_currency_code> | <refund_billing_amount>   | <billing_currency_code>          | STAN1                     | RRN1                       | NT1                    | 1206              | 182751            | 1206                   | 192748                 | n             | contact        | online_passed | n                  | n                          |

    Then I set acquirer objects in transaction context
      | transaction_identifier | acquiring_institution_id_code | card_acceptor_country_code   | acquiring_institution_country_code | merchant_category_code | card_acceptor_terminal_id | card_acceptor_id | card_acceptor_name | card_acceptor_city |
      | T1                     | 843759                        | <card_acceptor_country_code> | <transaction_currency_code>        | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |

    Then I set clearing objects in transaction context
      | transaction_identifier | record_id_clearing | card_id | transaction_type | transaction_amount            | transaction_currency_code   | billing_amount            | billing_currency_code   | interchange_fee | clearing_category | clearing_outcome | authorization_code | reason_code | reference_number | sequence_number | clearing_date |
      | T2                     | TxnId2             | CardId1 | 1                | <clearing_transaction_amount> | <transaction_currency_code> | <clearing_billing_amount> | <billing_currency_code> | D0000500        | credit            | 0                | C90012             | 00          | 5942             | 1               | 1206          |

    Then I set authorizations to be cleared in transaction context
      | transaction_identifier | auth_transaction_id | system_trace_audit_number | retrieval_reference_number |
      | T2                     | TxnId1              | STAN1                     | RRN1                       |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount        | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason | case_type |
      | T1                     | authorization | <refund_transaction_amount> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 000           | Approved        | positive  |

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount          | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T1                     | VALID_UUID          | <refund_transaction_amount> | <refund_billing_amount> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | CREDIT_CREATE    | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount          | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T1                     | TxnId1          | <refund_transaction_amount> | <refund_billing_amount> | <transaction_currency_code> | <billing_currency_code> | CREDIT_INITIAL   | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason     | case_type |
      | T2                     | clearing     | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 091           | Advice acknowledged | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance> and total balance of <total_balance> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | linked_transaction_ids | bank_transaction_id | transaction_amount            | billing_amount            | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | clearing                                                                                             | release_auth_ts | release_type     |
      | T2                     | TxnId1                 | VALID_UUID          | <clearing_transaction_amount> | <clearing_billing_amount> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | CREDIT_CLEAR     | SETTLED            | {"interchange_fee": 0.0005, "interchange_type": "DR", "clearing_outcome": "AUTH_FOUND_AMOUNT_MATCH"} | T+30            |                  |
      | T1                     | TxnId2                 | VALID_UUID          | 0                             | 0                         | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | CREDIT_CREATE    | AUTH_CLEARED       |                                                                                                      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount            | billing_amount            | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T2                     | TxnId2          | <clearing_transaction_amount> | <clearing_billing_amount> | <transaction_currency_code> | <billing_currency_code> | CREDIT_CLEAR     | COMPLETED          |

    Examples:
      | T1_message_qualifier | T2_message_qualifier | refund_transaction_amount | refund_billing_amount | clearing_transaction_amount | clearing_billing_amount | transaction_currency_code | transaction_currency | billing_currency_code | billing_currency | card_acceptor_country_code | available_balance | total_balance |
      | request              | notification         | 100                       | 100                   | 100                         | 100                     | 702                       | SGD                  | 702                   | SGD              | SG                         | 1100              | 1100          |

  Scenario Outline: Clowd9-Test refund request followed by partial reversal and finally a full clearing

    Given I build below transactions
      | transaction_identifier | message_type  | message_qualifier      | source |
      | T1                     | authorization | <T1_message_qualifier> | VISA   |
      | T2                     | reversal      | <T2_message_qualifier> | VISA   |
      | T3                     | clearing      | <T3_message_qualifier> |        |

    Then I set card objects in transaction context
      | transaction_identifier | card_identifier | card_form_factor |
      | T1                     | CardId1         | PHYSICAL         |
      | T2                     | CardId1         | PHYSICAL         |

    Then I set customer objects in transaction context
      | transaction_identifier | customer_identifier |
      | T1                     | CardAccId1          |
      | T2                     | CardAccId1          |

    Then I set transaction objects in transaction context
      | transaction_identifier | transaction_id | reversal_type | transaction_type | transaction_amount                   | transaction_currency_code   | cardholder_billing_amount | cardholder_billing_currency_code | system_trace_audit_number | retrieval_reference_number | network_transaction_id | transmission_date | transmission_time | transaction_local_date | transaction_local_time | dcc_indicator | chip_indicator | pin_indicator | three_ds_indicator | partial_approval_supported |
      | T1                     | TxnId1         |               | 20               | <refund_transaction_amount>          | <transaction_currency_code> | <refund_billing_amount>   | <billing_currency_code>          | STAN1                     | RRN1                       | NT1                    | 1206              | 182751            | 1206                   | 192748                 | n             | contact        | online_passed | n                  | n                          |
      | T2                     | TxnId2         | PARTIAL       | 20               | <refund_reversal_transaction_amount> | <transaction_currency_code> |                           |                                  | STAN2                     | RRN1                       | NT2                    | 0329              | 142654            | 0329                   | 142654                 | n             | contact        | online_passed | n                  | n                          |

    Then I set update in transaction context
      | transaction_identifier | original_transaction_id | original_message_type | original_message_qualifier | original_transaction_amount | actual_transaction_amount            | original_system_trace_audit_number | original_retrieval_reference_number | original_transmission_date | original_transmission_time |
      | T2                     | TxnId1                  | authorization         | <T1_message_qualifier>     | <refund_transaction_amount> | <refund_reversal_transaction_amount> | STAN1                              | RRN1                                | 0329                       | 112336                     |

    Then I set status in transaction context
      | transaction_identifier | response_code | response_source | response_reason |
      | T2                     | 000           | Scheme          | Approved        |

    Then I set acquirer objects in transaction context
      | transaction_identifier | acquiring_institution_id_code | card_acceptor_country_code   | acquiring_institution_country_code | merchant_category_code | card_acceptor_terminal_id | card_acceptor_id | card_acceptor_name | card_acceptor_city |
      | T1                     | 843759                        | <card_acceptor_country_code> | <transaction_currency_code>        | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |
      | T2                     | 843759                        | <card_acceptor_country_code> |                                    | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |

    Then I set clearing objects in transaction context
      | transaction_identifier | record_id_clearing | card_id | transaction_type | transaction_amount            | transaction_currency_code   | billing_amount            | billing_currency_code   | interchange_fee | clearing_category | clearing_outcome | authorization_code | reason_code | reference_number | sequence_number | clearing_date |
      | T3                     | TxnId3             | CardId1 | 1                | <clearing_transaction_amount> | <transaction_currency_code> | <clearing_billing_amount> | <billing_currency_code> | D0000500        | credit            | 0                | C90012             | 00          | 5942             | 1               | 1206          |

    Then I set authorizations to be cleared in transaction context
      | transaction_identifier | auth_transaction_id | system_trace_audit_number | retrieval_reference_number |
      | T3                     | TxnId1              | STAN1                     | RRN1                       |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount        | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason | case_type |
      | T1                     | authorization | <refund_transaction_amount> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 000           | Approved        | positive  |

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount          | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T1                     | VALID_UUID          | <refund_transaction_amount> | <refund_billing_amount> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | CREDIT_CREATE    | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount          | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T1                     | TxnId1          | <refund_transaction_amount> | <refund_billing_amount> | <transaction_currency_code> | <billing_currency_code> | CREDIT_INITIAL   | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type | authorized_tx_amount                 | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason | case_type |
      | T2                     | reversal     | <refund_reversal_transaction_amount> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 000           | Approved        | positive  |

    Then I validate below Transaction entries
      | transaction_identifier | bank_transaction_id | transaction_amount                   | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | release_auth_ts | release_type     |
      | T2                     | VALID_UUID          | <refund_reversal_transaction_amount> | <actual_billing_amount> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | CREDIT_CREATE    | AUTH_ACQUIRED      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount                   | billing_amount          | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T2                     | TxnId2          | <refund_reversal_transaction_amount> | <actual_billing_amount> | <transaction_currency_code> | <billing_currency_code> | CREDIT_REVERSAL  | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason     | case_type |
      | T3                     | clearing     | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 091           | Advice acknowledged | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance> and total balance of <total_balance> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | linked_transaction_ids | bank_transaction_id | transaction_amount            | billing_amount            | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | clearing                                                                                             | release_auth_ts | release_type     |
      | T3                     | TxnId1                 | VALID_UUID          | <clearing_transaction_amount> | <clearing_billing_amount> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | CREDIT_CLEAR     | SETTLED            | {"interchange_fee": 0.0005, "interchange_type": "DR", "clearing_outcome": "AUTH_FOUND_AMOUNT_MATCH"} | T+30            |                  |
      | T1                     | TxnId3                 | VALID_UUID          | 0                             | 0                         | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | CREDIT_CREATE    | AUTH_CLEARED       |                                                                                                      | T+30            | SCHEDULED_EXPIRY |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount            | billing_amount            | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T3                     | TxnId3          | <clearing_transaction_amount> | <clearing_billing_amount> | <transaction_currency_code> | <billing_currency_code> | CREDIT_CLEAR     | COMPLETED          |

    Examples:
      | T1_message_qualifier | T2_message_qualifier | T3_message_qualifier | refund_transaction_amount | refund_billing_amount | refund_reversal_transaction_amount | actual_billing_amount | clearing_transaction_amount | clearing_billing_amount | transaction_currency_code | transaction_currency | billing_currency_code | billing_currency | card_acceptor_country_code | available_balance | total_balance |
      | request              | request              | notification         | 100                       | 100                   | 50                                 | 50                    | 50                          | 50                      | 702                       | SGD                  | 702                   | SGD              | SG                         | 1050              | 1050          |

  Scenario Outline: Clowd9-Test credit clearing accepted without existing authorization transaction

    Given I build below transactions
      | transaction_identifier | message_type | message_qualifier |
      | T1                     | clearing     | notification      |

    Then I set clearing objects in transaction context
      | transaction_identifier | record_id_clearing | card_id | transaction_type | transaction_amount            | transaction_currency_code   | billing_amount            | billing_currency_code   | interchange_fee | clearing_category | clearing_outcome | authorization_code | reason_code | reference_number | sequence_number | clearing_date |
      | T1                     | TxnId1             | CardId1 | 1                | <clearing_transaction_amount> | <transaction_currency_code> | <clearing_billing_amount> | <billing_currency_code> | D0000500        | credit            | 9                | C90012             | 00          | 5942             | 1               | 1206          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason     | case_type |
      | T1                     | clearing     | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 091           | Advice acknowledged | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance> and total balance of <total_balance> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | linked_transaction_ids   | bank_transaction_id | transaction_amount            | billing_amount            | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | clearing                                                                                             | clearing_outcome         | release_auth_ts |
      | T1                     | <linked_transaction_ids> | VALID_UUID          | <clearing_transaction_amount> | <clearing_billing_amount> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | CREDIT_CLEAR     | SETTLED            | {"interchange_fee": 0.0005, "interchange_type": "DR", "clearing_outcome": "MATCHING_AUTH_NOT_FOUND"} | UNKNOWN_CLEARING_OUTCOME | T+30            |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount            | billing_amount            | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T1                     | TxnId1          | <clearing_transaction_amount> | <clearing_billing_amount> | <transaction_currency_code> | <billing_currency_code> | CREDIT_CLEAR     | COMPLETED          |

    Examples:
      | clearing_transaction_amount | clearing_billing_amount | transaction_currency_code | transaction_currency | billing_currency_code | billing_currency | linked_transaction_ids | available_balance | total_balance |
      | 100                         | 100                     | 702                       | SGD                  | 702                   | SGD              |                        | 1100              | 1100          |
      | 100                         | 200                     | 826                       | GBP                  | 702                   | SGD              |                        | 1200              | 1200          |

#  Scenario Outline: Clowd9-Test clearing with no card is accepted
#    Given I build below transactions
#      | transaction_identifier | message_type | message_qualifier |
#      | T1                     | clearing     | notification      |
#
#    Then I set clearing objects in transaction context
#      | transaction_identifier | record_id_clearing | transaction_type | transaction_amount            | transaction_currency_code   | billing_amount            | billing_currency_code   | interchange_fee | clearing_category | authorization_code | reason_code | reference_number | sequence_number | clearing_date |
#      | T1                     | TxnId1             | 1                | <clearing_transaction_amount> | <transaction_currency_code> | <clearing_billing_amount> | <billing_currency_code> | C0000500        | sales_debit       | C90012             | 00          | 5942             | 1               | 1206          |
#
#    When I initiate below Dynamic Data Stream transaction requests
#      | transaction_identifier | message_type | response_code | response_reason     | case_type |
#      | T1                     | clearing     | 091           | Advice acknowledged | positive  |
#
#    Examples:
#      | clearing_transaction_amount | clearing_billing_amount | transaction_currency_code | billing_currency_code |
#      | 100                         | 100                     | 702                       | 702                   |

  Scenario Outline: Clowd9-Test administrative message accepted with card status change
    Given I build below transactions
      | transaction_identifier | message_type   | message_qualifier | source |
      | T1                     | administrative | notification      | VISA   |

    Then I set card objects in transaction context
      | transaction_identifier | card_identifier | card_form_factor | card_prev_status   | card_status   |
      | T1                     | CardId1         | PHYSICAL         | <card_prev_status> | <card_status> |

    Then I set customer objects in transaction context
      | transaction_identifier | customer_identifier |
      | T1                     | CardAccId1          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type   | authorized_tx_amount | response_code | response_reason     | case_type |
      | T1                     | administrative | 0                    | 091           | Advice acknowledged | positive  |

    Then I validate card status by fetching card with id CardId1 and checking card status as <card_status>

    Examples:
      | card_prev_status | card_status |
      | active           | EXPIRED     |

  Scenario Outline: Clowd9-Test debit authorization rejected for blocked card and then unsolicited reversal was approved
    Then I update the status of Card with id CardId1
      | card_status |
      | BLOCK       |

    Given I build below transactions
      | transaction_identifier | message_type  | message_qualifier      | source |
      | T1                     | authorization | <T1_message_qualifier> | VISA   |
      | T2                     | reversal      | <T2_message_qualifier> | VISA   |

    Then I set card objects in transaction context
      | transaction_identifier | card_identifier | card_form_factor |
      | T1                     | CardId1         | PHYSICAL         |
      | T2                     | CardId1         | PHYSICAL         |

    Then I set customer objects in transaction context
      | transaction_identifier | customer_identifier |
      | T1                     | CardAccId1          |
      | T2                     | CardAccId1          |

    Then I set transaction objects in transaction context
      | transaction_identifier | reversal_type | transaction_type | transaction_amount        | transaction_currency_code   | cardholder_billing_amount | cardholder_billing_currency_code | transaction_id | system_trace_audit_number | retrieval_reference_number | network_transaction_id | transmission_date | transmission_time | transaction_local_date | transaction_local_time | dcc_indicator | chip_indicator | pin_indicator | three_ds_indicator | partial_approval_supported |
      | T1                     |               | 00               | <auth_transaction_amount> | <transaction_currency_code> | <auth_billing_amount>     | <billing_currency_code>          | TxnId1         | STAN1                     | RRN1                       | NT1                    | 1206              | 182751            | 1206                   | 192748                 | n             | contact        | online_passed | n                  | n                          |
      | T2                     | FULL          | 00               | <auth_transaction_amount> | <transaction_currency_code> | <auth_billing_amount>     | <billing_currency_code>          | TxnId2         | STAN2                     | RRN1                       | NT2                    | 0329              | 142654            | 0329                   | 142654                 | n             | contact        | online_passed | n                  | n                          |

    Then I set update in transaction context
      | transaction_identifier | original_transaction_id | original_message_type | original_message_qualifier | original_transaction_amount | original_system_trace_audit_number | original_retrieval_reference_number | original_transmission_date | original_transmission_time |
      | T2                     | TxnId1                  | authorization         | <T1_message_qualifier>     | <auth_transaction_amount>   | STAN1                              | RRN1                                | 1206                       | 182751                     |

    Then I set status in transaction context
      | transaction_identifier | response_code | response_source | response_reason |
      | T2                     | 000           | Scheme          | Approved        |

    Then I set acquirer objects in transaction context
      | transaction_identifier | acquiring_institution_id_code | card_acceptor_country_code   | acquiring_institution_country_code | merchant_category_code | card_acceptor_terminal_id | card_acceptor_id | card_acceptor_name | card_acceptor_city |
      | T1                     | 843759                        | <card_acceptor_country_code> |                                    | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |
      | T2                     | 843759                        | <card_acceptor_country_code> |                                    | 6011                   |                           | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | is_empty_service_tx_id | authorized_tx_amount | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason             | case_type |
      | T1                     | authorization | true                   | 0                    | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 119           | Txn Forbidden to Cardholder | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_1> and total balance of <total_balance> for customerProfileId CPID1

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type | is_empty_service_tx_id | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason | case_type |
      | T2                     | reversal     | true                   | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 000           | Approved        | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_2> and total balance of <total_balance> for customerProfileId CPID1

    Examples:
      | T1_message_qualifier | T2_message_qualifier | auth_transaction_amount | auth_billing_amount | transaction_currency_code | transaction_currency | billing_currency_code | billing_currency | card_acceptor_country_code | available_balance_1 | available_balance_2 | total_balance |
      | request              | request              | 100                     | 100                 | 702                       | SGD                  | 702                   | SGD              | SG                         | 1000                | 1000                | 1000          |

  Scenario Outline: Clowd9-Test authorization reversals are accepted for blocked card
    Given I build below transactions
      | transaction_identifier | message_type  | message_qualifier      | source |
      | T1                     | authorization | <T1_message_qualifier> | VISA   |
      | T2                     | reversal      | <T2_message_qualifier> | VISA   |

    Then I set card objects in transaction context
      | transaction_identifier | card_identifier | card_form_factor |
      | T1                     | CardId1         | PHYSICAL         |
      | T2                     | CardId1         | PHYSICAL         |

    Then I set customer objects in transaction context
      | transaction_identifier | customer_identifier |
      | T1                     | CardAccId1          |
      | T2                     | CardAccId1          |

    Then I set transaction objects in transaction context
      | transaction_identifier | reversal_type | transaction_type | transaction_amount        | transaction_currency_code   | cardholder_billing_amount | cardholder_billing_currency_code | transaction_id | system_trace_audit_number | retrieval_reference_number | network_transaction_id | transmission_date | transmission_time | transaction_local_date | transaction_local_time | dcc_indicator | chip_indicator | pin_indicator | three_ds_indicator | partial_approval_supported |
      | T1                     |               | 00               | <auth_transaction_amount> | <transaction_currency_code> | <auth_billing_amount>     | <billing_currency_code>          | TxnId1         | STAN1                     | RRN1                       | NT1                    | 1206              | 182751            | 1206                   | 192748                 | n             | contact        | online_passed | n                  | n                          |
      | T2                     | FULL          | 00               | <auth_transaction_amount> | <transaction_currency_code> | <auth_billing_amount>     | <billing_currency_code>          | TxnId2         | STAN2                     | RRN1                       | NT2                    | 0329              | 142654            | 0329                   | 142654                 | n             | contact        | online_passed | n                  | n                          |

    Then I set update in transaction context
      | transaction_identifier | original_transaction_id | original_message_type | original_message_qualifier | original_transaction_amount | original_system_trace_audit_number | original_retrieval_reference_number | original_transmission_date | original_transmission_time |
      | T2                     | TxnId1                  | authorization         | <T1_message_qualifier>     | <auth_transaction_amount>   | STAN1                              | RRN1                                | 1206                       | 182751                     |

    Then I set status in transaction context
      | transaction_identifier | response_code | response_source | response_reason |
      | T2                     | 000           | Scheme          | Approved        |

    Then I set acquirer objects in transaction context
      | transaction_identifier | acquiring_institution_id_code | card_acceptor_country_code   | acquiring_institution_country_code | merchant_category_code | card_acceptor_terminal_id | card_acceptor_id | card_acceptor_name | card_acceptor_city |
      | T1                     | 843759                        | <card_acceptor_country_code> |                                    | 6011                   | ATM00001                  | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |
      | T2                     | 843759                        | <card_acceptor_country_code> |                                    | 6011                   |                           | NEWBANKMERCHANT  | NEW BANK LIMITED   | Oxford             |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type  | authorized_tx_amount      | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code      | response_reason      | case_type |
      | T1                     | authorization | <auth_transaction_amount> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | <T1_response_code> | <T1_response_reason> | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_1> and total balance of <total_balance> for customerProfileId CPID1

    Then I update the status of Card with id CardId1
      | card_status |
      | BLOCK       |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type | authorized_tx_amount      | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code      | response_reason      | case_type |
      | T2                     | reversal     | <auth_transaction_amount> | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | <T2_response_code> | <T2_response_reason> | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance_2> and total balance of <total_balance> for customerProfileId CPID1

    Examples:
      | T1_message_qualifier | T2_message_qualifier | auth_transaction_amount | auth_billing_amount | transaction_currency_code | transaction_currency | billing_currency_code | billing_currency | card_acceptor_country_code | available_balance_1 | available_balance_2 | total_balance | T1_response_code | T1_response_reason  | T2_response_code | T2_response_reason          |
      | request              | request              | 100                     | 100                 | 702                       | SGD                  | 702                   | SGD              | SG                         | 900                 | 900                 | 1000          | 000              | Approved            | 119              | Txn Forbidden to Cardholder |
      | request              | notification         | 100                     | 100                 | 702                       | SGD                  | 702                   | SGD              | SG                         | 900                 | 1000                | 1000          | 000              | Approved            | 091              | Advice acknowledged         |
      | notification         | request              | 100                     | 100                 | 702                       | SGD                  | 702                   | SGD              | SG                         | 900                 | 900                 | 1000          | 091              | Advice acknowledged | 119              | Txn Forbidden to Cardholder |
      | notification         | notification         | 100                     | 100                 | 702                       | SGD                  | 702                   | SGD              | SG                         | 900                 | 1000                | 1000          | 091              | Advice acknowledged | 091              | Advice acknowledged         |

  Scenario Outline: Clowd9-Test debit clearing without existing authorization transaction
    Given I build below transactions
      | transaction_identifier | message_type | message_qualifier      |
      | T1                     | clearing     | <T1_message_qualifier> |

    Then I set clearing objects in transaction context
      | transaction_identifier | record_id_clearing | card_id | transaction_type | transaction_amount            | transaction_currency_code   | billing_amount            | billing_currency_code   | interchange_fee | clearing_category | clearing_outcome | authorization_code | reason_code | reference_number | sequence_number | clearing_date |
      | T1                     | TxnId1             | CardId1 | 1                | <clearing_transaction_amount> | <transaction_currency_code> | <clearing_billing_amount> | <billing_currency_code> | C0000500        | sales_debit       | 9                | C90012             | 00          | 5942             | 1               | 1206          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason     | case_type |
      | T1                     | clearing     | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 091           | Advice acknowledged | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance> and total balance of <total_balance> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | linked_transaction_ids | bank_transaction_id | transaction_amount            | billing_amount            | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | clearing                                                                                             | release_auth_ts |
      | T1                     |                        | VALID_UUID          | <clearing_transaction_amount> | <clearing_billing_amount> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CLEAR      | SETTLED            | {"interchange_fee": 0.0005, "interchange_type": "CR", "clearing_outcome": "MATCHING_AUTH_NOT_FOUND"} | T+30            |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount            | billing_amount            | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T1                     | TxnId1          | <clearing_transaction_amount> | <clearing_billing_amount> | <transaction_currency_code> | <billing_currency_code> | DEBIT_CLEAR      | COMPLETED          |

    Examples:
      | T1_message_qualifier | clearing_transaction_amount | clearing_billing_amount | transaction_currency_code | transaction_currency | billing_currency_code | billing_currency | available_balance | total_balance |
      | notification         | 100                         | 100                     | 702                       | SGD                  | 702                   | SGD              | 900               | 900           |
      | notification         | 1100                        | 1100                    | 702                       | SGD                  | 702                   | SGD              | -100              | -100          |

  Scenario Outline: Clowd9-Test debit clearing where transaction is recorded on Clowd9 but not on HugoHub
    Given I build below transactions
      | transaction_identifier | message_type | message_qualifier      |
      | T1                     | clearing     | <T1_message_qualifier> |

    Then I set clearing objects in transaction context
      | transaction_identifier | record_id_clearing | card_id | transaction_type | transaction_amount            | transaction_currency_code   | billing_amount            | billing_currency_code   | interchange_fee | clearing_category | clearing_outcome | authorization_code | reason_code | reference_number | sequence_number | clearing_date |
      | T1                     | TxnId2             | CardId1 | 1                | <clearing_transaction_amount> | <transaction_currency_code> | <clearing_billing_amount> | <billing_currency_code> | C0000500        | sales_debit       | 9                | C90012             | 00          | 5942             | 1               | 1206          |

    Then I set authorizations to be cleared in transaction context
      | transaction_identifier | auth_transaction_id | system_trace_audit_number | retrieval_reference_number |
      | T1                     | TxnId1              | STAN1                     | RRN1                       |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason     | case_type |
      | T1                     | clearing     | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 091           | Advice acknowledged | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance> and total balance of <total_balance> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | linked_transaction_ids | bank_transaction_id | transaction_amount            | billing_amount            | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | clearing                                                                                             | release_auth_ts |
      | T1                     |                        | VALID_UUID          | <clearing_transaction_amount> | <clearing_billing_amount> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CLEAR      | SETTLED            | {"interchange_fee": 0.0005, "interchange_type": "CR", "clearing_outcome": "MATCHING_AUTH_NOT_FOUND"} | T+30            |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount            | billing_amount            | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T1                     | TxnId2          | <clearing_transaction_amount> | <clearing_billing_amount> | <transaction_currency_code> | <billing_currency_code> | DEBIT_CLEAR      | COMPLETED          |

    Examples:
      | T1_message_qualifier | clearing_transaction_amount | clearing_billing_amount | transaction_currency_code | transaction_currency | billing_currency_code | billing_currency | available_balance | total_balance |
      | notification         | 100                         | 100                     | 702                       | SGD                  | 702                   | SGD              | 900               | 900           |
      | notification         | 1100                        | 1100                    | 702                       | SGD                  | 702                   | SGD              | -100              | -100          |

  Scenario Outline: Clowd9-Avoid processing debit clearing for duplicate mismatch clearing transactions that have already been processed.
    Given I build below transactions
      | transaction_identifier | message_type | message_qualifier      |
      | T1                     | clearing     | <T1_message_qualifier> |

    Then I set clearing objects in transaction context
      | transaction_identifier | record_id_clearing | card_id | transaction_type | transaction_amount            | transaction_currency_code   | billing_amount            | billing_currency_code   | interchange_fee | clearing_category | clearing_outcome | authorization_code | reason_code | reference_number | sequence_number | clearing_date |
      | T1                     | TxnId2             | CardId1 | 1                | <clearing_transaction_amount> | <transaction_currency_code> | <clearing_billing_amount> | <billing_currency_code> | C0000500        | sales_debit       | 0                | C90012             | 00          | 5942             | 1               | 1206          |

    Then I set authorizations to be cleared in transaction context
      | transaction_identifier | auth_transaction_id | system_trace_audit_number | retrieval_reference_number |
      | T1                     | TxnId1              | STAN1                     | RRN1                       |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason     | case_type |
      | T1                     | clearing     | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 091           | Advice acknowledged | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance> and total balance of <total_balance> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | linked_transaction_ids | bank_transaction_id | transaction_amount            | billing_amount            | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | clearing                                                                                             | release_auth_ts |
      | T1                     |                        | VALID_UUID          | <clearing_transaction_amount> | <clearing_billing_amount> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CLEAR      | SETTLED            | {"interchange_fee": 0.0005, "interchange_type": "CR", "clearing_outcome": "AUTH_FOUND_AMOUNT_MATCH"} | T+30            |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount            | billing_amount            | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T1                     | TxnId2          | <clearing_transaction_amount> | <clearing_billing_amount> | <transaction_currency_code> | <billing_currency_code> | DEBIT_CLEAR      | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason     | case_type |
      | T1                     | clearing     | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 091           | Advice acknowledged | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance> and total balance of <total_balance> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | linked_transaction_ids | bank_transaction_id | transaction_amount            | billing_amount            | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | clearing                                                                                             | release_auth_ts |
      | T1                     |                        | VALID_UUID          | <clearing_transaction_amount> | <clearing_billing_amount> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | DEBIT_CLEAR      | SETTLED            | {"interchange_fee": 0.0005, "interchange_type": "CR", "clearing_outcome": "AUTH_FOUND_AMOUNT_MATCH"} | T+30            |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount            | billing_amount            | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T1                     | TxnId2          | <clearing_transaction_amount> | <clearing_billing_amount> | <transaction_currency_code> | <billing_currency_code> | DEBIT_CLEAR      | COMPLETED          |

    Examples:
      | T1_message_qualifier | clearing_transaction_amount | clearing_billing_amount | transaction_currency_code | transaction_currency | billing_currency_code | billing_currency | available_balance | total_balance |
      | notification         | 100                         | 100                     | 702                       | SGD                  | 702                   | SGD              | 900               | 900           |

  Scenario Outline: Clowd9-Avoid processing credit clearing for duplicate mismatch clearing transactions that have already been processed.
    Given I build below transactions
      | transaction_identifier | message_type | message_qualifier      |
      | T1                     | clearing     | <T1_message_qualifier> |

    Then I set clearing objects in transaction context
      | transaction_identifier | record_id_clearing | card_id | transaction_type | transaction_amount            | transaction_currency_code   | billing_amount            | billing_currency_code   | interchange_fee | clearing_category | clearing_outcome | authorization_code | reason_code | reference_number | sequence_number | clearing_date |
      | T1                     | TxnId2             | CardId1 | 1                | <clearing_transaction_amount> | <transaction_currency_code> | <clearing_billing_amount> | <billing_currency_code> | D0000500        | credit            | 0                | C90012             | 00          | 5942             | 1               | 1206          |

    Then I set authorizations to be cleared in transaction context
      | transaction_identifier | auth_transaction_id | system_trace_audit_number | retrieval_reference_number |
      | T1                     | TxnId1              | STAN1                     | RRN1                       |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason     | case_type |
      | T1                     | clearing     | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 091           | Advice acknowledged | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance> and total balance of <total_balance> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | linked_transaction_ids | bank_transaction_id | transaction_amount            | billing_amount            | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | clearing                                                                                             | release_auth_ts |
      | T1                     |                        | VALID_UUID          | <clearing_transaction_amount> | <clearing_billing_amount> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | CREDIT_CLEAR     | SETTLED            | {"interchange_fee": 0.0005, "interchange_type": "DR", "clearing_outcome": "AUTH_FOUND_AMOUNT_MATCH"} | T+30            |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount            | billing_amount            | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T1                     | TxnId2          | <clearing_transaction_amount> | <clearing_billing_amount> | <transaction_currency_code> | <billing_currency_code> | CREDIT_CLEAR     | COMPLETED          |

    When I initiate below Dynamic Data Stream transaction requests
      | transaction_identifier | message_type | transaction_currency_code   | transaction_currency   | cardholder_billing_currency_code | cardholder_billing_currency | response_code | response_reason     | case_type |
      | T1                     | clearing     | <transaction_currency_code> | <transaction_currency> | <billing_currency_code>          | <billing_currency>          | 091           | Advice acknowledged | positive  |

    Then I wait until max time to verify bank account BankAccId with an available balance of <available_balance> and total balance of <total_balance> for customerProfileId CPID1

    Then I validate below Transaction entries
      | transaction_identifier | linked_transaction_ids | bank_transaction_id | transaction_amount            | billing_amount            | tx_currency_code            | billing_currency_code   | transaction_currency   | billing_currency   | transaction_type | transaction_status | clearing                                                                                             | release_auth_ts |
      | T1                     |                        | VALID_UUID          | <clearing_transaction_amount> | <clearing_billing_amount> | <transaction_currency_code> | <billing_currency_code> | <transaction_currency> | <billing_currency> | CREDIT_CLEAR     | SETTLED            | {"interchange_fee": 0.0005, "interchange_type": "DR", "clearing_outcome": "AUTH_FOUND_AMOUNT_MATCH"} | T+30            |

    Then I validate below TransactionLog entries
      | transaction_identifier | idempotency_key | transaction_amount            | billing_amount            | tx_currency_code            | billing_currency_code   | transaction_type | transaction_status |
      | T1                     | TxnId2          | <clearing_transaction_amount> | <clearing_billing_amount> | <transaction_currency_code> | <billing_currency_code> | CREDIT_CLEAR     | COMPLETED          |

    Examples:
      | T1_message_qualifier | clearing_transaction_amount | clearing_billing_amount | transaction_currency_code | transaction_currency | billing_currency_code | billing_currency | available_balance | total_balance |
      | notification         | 100                         | 100                     | 702                       | SGD                  | 702                   | SGD              | 1100              | 1100          |
