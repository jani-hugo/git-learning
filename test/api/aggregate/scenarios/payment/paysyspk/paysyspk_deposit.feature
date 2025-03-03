Feature: Payment Service Paysys Deposit Notification --- Credit Posting and Credit Advice

  Background: Setup CustomerProfile and EndCustomerProfile profile onto Payment Service

    #CustomerProfile verifying and Onboarding on to payment service on given providers
    Given In Payment Service, I set and verify customer PSCID1, customer profile PSCPID1 on below providers from CASH_SERVICE on behalf of CUSTOMER and expect status 200 in the context
      | provider_name |
      | PAYSYS        |

    Then I wait until max time to verify CustomerProfile PSCPID1 on behalf of CASH_SERVICE onboard status as ONBOARD_SUCCESS onto Payment Service

    Then I create below End-Customer-Profile
      | customer_identifier | customer_profile_identifier | end_customer_profile_identifier | first_name | last_name | region | email            | phone_number |
      | PSCID1              | PSCPID1                     | ECPID1                          | Kiyotaka   | Ayanokōji | PK     | KA@gmail.com.com | 00000000     |

    Then I verify End-Customer-Profile exist with values
      | customer_profile_identifier | end_customer_profile_identifier | first_name | last_name | email            | phone_number | status |
      | PSCPID1                     | ECPID1                          | Kiyotaka   | Ayanokōji | KA@gmail.com.com | 00000000     | ACTIVE |

    # EndCustomerProfile Onboarding
    Given I onboard EndCustomerProfile ECPID1 of CustomerProfile PSCPID1 on payment service on below providers from CASH_SERVICE on behalf of CUSTOMER and expect status 200
      | provider_name |
      | PAYSYS        |

    Then I wait until max time to verify EndCustomerProfile ECPID1 of CustomerProfile PSCPID1 from CASH_SERVICE onboard status as ONBOARD_SUCCESS onto Payment Service

  Scenario Outline: Credit Posting Deposit Notification --- Deposit amount into customer profile account using Credit Posting and check if balance of the account is increased

    Given I create account for CustomerProfile with customerProfileId PSCPID1 from CASH_SERVICE on behalf of CUSTOMER with provider PAYSYS and expect the header status 200
      | identifier        | currency | country | metadata                    | on_behalf_of |
      | CustomerAccountId | PKR      | PAK     | {"key": "IntegrationTest1"} | CUSTOMER     |

    Then I wait until max time to verify the payment account CustomerAccountId from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I verify CustomerProfile with id PSCPID1 has payment account CustomerAccountId from CASH_SERVICE on behalf of CUSTOMER exists with provider PAYSYS with values
      | account_id        | provider_id | currency | account_status  | metadata                    | on_behalf_of |
      | CustomerAccountId | PAYSYS-PK   | PKR      | ACCOUNT_CREATED | {"key": "IntegrationTest1"} | CUSTOMER     |

    Then I retrieve the payment account CustomerAccountId from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I initiate a request to inquiry an account CustomerAccountId to validate the account to initiate a credit payment of amount <amount> from initiator RAAST and expect the response status 0000
      | identifier                  | customer_profile_id | txn_info                                                                                                                                                                                                                                                                        |
      | InboundTitleFetchIdentifier | PSCPID1             | {"info":{"rrn":"InboundTitleFetchIdentifier","stan":"InboundTitleFetchIdentifier","txndate":"InboundTitleFetchIdentifier","txntime":"InboundTitleFetchIdentifier", "initiator":"RAAST"},"receiverinfo":{"to_account":"PK96HUGO0000003363390659"},"payment_info":{"amount":100}} |

    Given I deposit an amount of <amount> into account CustomerAccountId using CreditPosting for customerProfileId PSCPID1
      | identifier              | customer_profile_id | txn_info                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
      | CreditPostingIdentifier | PSCPID1             | {"info":{"rrn":"CreditPostingIdentifier","stan":"CreditPostingIdentifier","txndate":"CreditPostingIdentifier","txntime":"CreditPostingIdentifier"},"receiverinfo":{"to_account":"PK96HUGO0000003363390659","to_account_title":"Waqas Nizam"},"senderinfo":{"sender_bank_iMD":"","sender_bank_bIC":"NBPBPKKA","from_account":"PK56AIIN1234567890000001","from_account_title":"Muhammad Ali","from_account_cnic":"1234512345671"},"payment_info":{"purpose_code":"0125","narration":"Integration Test transaction","amount":100,"instr_id":"TMIC230511125023876423","end_to_end_id":"1fc66b584e77-46e6-9dcb-fb12c00e7742","tx_id":"TMIC230511125023876423","msg_id":"CreditPostingIdentifier"}} |

    Then I wait until max time to verify master  account CustomerAccountId with an increased updated balance of <amount> for customerProfileId PSCPID1 in Paysys

    Examples:
      | amount |
      | 100    |

  Scenario Outline: Credit Posting Deposit Notification --- Deposit amount into end customer profile account using Credit Posting and check if balance of the account is increased

    Given I create account for EndCustomerProfile with id ECPID1 for CustomerProfile PSCPID1 from CASH_SERVICE on behalf of CUSTOMER with provider PAYSYS and expect the header status 200
      | identifier | currency | country | metadata                    | on_behalf_of |
      | AccountId  | PKR      | PAK     | {"key": "IntegrationTest1"} | CUSTOMER     |

    Then I wait until max time to verify the payment account AccountId from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I verify CustomerProfile with id PSCPID1 has payment account AccountId from CASH_SERVICE on behalf of CUSTOMER exists with provider PAYSYS with values
      | account_id | provider_id | currency | account_status  | metadata                    | on_behalf_of |
      | AccountId  | PAYSYS-PK   | PKR      | ACCOUNT_CREATED | {"key": "IntegrationTest1"} | CUSTOMER     |

    Then I retrieve the payment account AccountId from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I initiate a request to inquiry an account AccountId to validate the account to initiate a credit payment of amount <amount> from initiator RAAST and expect the response status 0000
      | identifier                  | customer_profile_id | txn_info                                                                                                                                                                                                                                                                        |
      | InboundTitleFetchIdentifier | PSCPID1             | {"info":{"rrn":"InboundTitleFetchIdentifier","stan":"InboundTitleFetchIdentifier","txndate":"InboundTitleFetchIdentifier","txntime":"InboundTitleFetchIdentifier", "initiator":"RAAST"},"receiverinfo":{"to_account":"PK96HUGO0000003363390659"},"payment_info":{"amount":100}} |

    Given I deposit an amount of <amount> into account AccountId using CreditPosting for customerProfileId PSCPID1
      | identifier              | customer_profile_id | txn_info                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
      | CreditPostingIdentifier | PSCPID1             | {"info":{"rrn":"CreditPostingIdentifier","stan":"CreditPostingIdentifier","txndate":"CreditPostingIdentifier","txntime":"CreditPostingIdentifier"},"receiverinfo":{"to_account":"PK96HUGO0000003363390659","to_account_title":"Waqas Nizam"},"senderinfo":{"sender_bank_iMD":"","sender_bank_bIC":"NBPBPKKA","from_account":"PK56AIIN1234567890000001","from_account_title":"Muhammad Ali","from_account_cnic":"1234512345671"},"payment_info":{"purpose_code":"0125","narration":"Integration Test transaction","amount":100,"instr_id":"TMIC230511125023876423","end_to_end_id":"1fc66b584e77-46e6-9dcb-fb12c00e7742","tx_id":"TMIC230511125023876423","msg_id":"CreditPostingIdentifier"}} |

    Then I wait until max time to verify master  account AccountId with an increased updated balance of <amount> for customerProfileId PSCPID1 in Paysys

    Examples:
      | amount |
      | 100    |

  Scenario Outline: Credit Posting Deposit Notification --- Deposit amount into master account using Credit Posting and check if balance of the account is increased

    Then I retrieve the payment account AccountId from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I initiate a request to inquiry an account AccountId to validate the account to initiate a credit payment of amount <amount> from initiator RAAST and expect the response status 0000
      | identifier                  | customer_profile_id | txn_info                                                                                                                                                                                                                                                                        |
      | InboundTitleFetchIdentifier | PSCPID1             | {"info":{"rrn":"InboundTitleFetchIdentifier","stan":"InboundTitleFetchIdentifier","txndate":"InboundTitleFetchIdentifier","txntime":"InboundTitleFetchIdentifier", "initiator":"RAAST"},"receiverinfo":{"to_account":"PK96HUGO0000003363390659"},"payment_info":{"amount":100}} |

    Given I deposit an amount of <amount> into master account AccountId using CreditPosting for customerProfileId PSCPID1
      | identifier              | customer_profile_id | txn_info                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
      | CreditPostingIdentifier | PSCPID1             | {"info":{"rrn":"CreditPostingIdentifier","stan":"CreditPostingIdentifier","txndate":"CreditPostingIdentifier","txntime":"CreditPostingIdentifier"},"receiverinfo":{"to_account":"PK96HUGO0000003363390659","to_account_title":"Waqas Nizam"},"senderinfo":{"sender_bank_iMD":"","sender_bank_bIC":"NBPBPKKA","from_account":"PK56AIIN1234567890000001","from_account_title":"Muhammad Ali","from_account_cnic":"1234512345671"},"payment_info":{"purpose_code":"0125","narration":"Integration Test transaction","amount":100,"instr_id":"TMIC230511125023876423","end_to_end_id":"1fc66b584e77-46e6-9dcb-fb12c00e7742","tx_id":"TMIC230511125023876423","msg_id":"CreditPostingIdentifier"}} |

    Then I wait until max time to verify master  account AccountId with an increased updated balance of <amount> for customerProfileId PSCPID1 in Paysys

    Examples:
      | amount |
      | 100    |

  Scenario Outline: Inbound Title Fetch to validate account -- Success case/Account found

    Given I create account for EndCustomerProfile with id ECPID1 for CustomerProfile PSCPID1 from CASH_SERVICE on behalf of CUSTOMER with provider PAYSYS and expect the header status 200
      | identifier | currency | country | metadata                    | on_behalf_of |
      | AccountId  | PKR      | PAK     | {"key": "IntegrationTest1"} | CUSTOMER     |

    Then I wait until max time to verify the payment account AccountId from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I verify CustomerProfile with id PSCPID1 has payment account AccountId from CASH_SERVICE on behalf of CUSTOMER exists with provider PAYSYS with values
      | account_id | provider_id | currency | account_status  | metadata                    | on_behalf_of |
      | AccountId  | PAYSYS-PK   | PKR      | ACCOUNT_CREATED | {"key": "IntegrationTest1"} | CUSTOMER     |

    Then I retrieve the payment account AccountId from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I initiate a request to inquiry an account AccountId to validate the account to initiate a credit payment of amount <amount> from initiator RAAST and expect the response status 0000
      | identifier                  | customer_profile_id | txn_info                                                                                                                                                                                                                                                                        |
      | InboundTitleFetchIdentifier | PSCPID1             | {"info":{"rrn":"InboundTitleFetchIdentifier","stan":"InboundTitleFetchIdentifier","txndate":"InboundTitleFetchIdentifier","txntime":"InboundTitleFetchIdentifier", "initiator":"RAAST"},"receiverinfo":{"to_account":"PK96HUGO0000003363390659"},"payment_info":{"amount":100}} |

    Examples:
      | amount |
      | 100    |

  Scenario Outline: Inbound Title Fetch to validate account -- Failure case/Account not found

    Given I create account for EndCustomerProfile with id ECPID1 for CustomerProfile PSCPID1 from CASH_SERVICE on behalf of CUSTOMER with provider PAYSYS and expect the header status 200
      | identifier | currency | country | metadata                    | on_behalf_of |
      | AccountId  | PKR      | PAK     | {"key": "IntegrationTest1"} | CUSTOMER     |

    Then I wait until max time to verify the payment account AccountId from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I verify CustomerProfile with id PSCPID1 has payment account AccountId from CASH_SERVICE on behalf of CUSTOMER exists with provider PAYSYS with values
      | account_id | provider_id | currency | account_status  | metadata                    | on_behalf_of |
      | AccountId  | PAYSYS-PK   | PKR      | ACCOUNT_CREATED | {"key": "IntegrationTest1"} | CUSTOMER     |

    Then I retrieve the payment account AccountId from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I initiate a request to inquiry an account AccountId to validate the account to initiate a credit payment of amount <amount> from initiator RAAST and expect the failure response status 001
      | identifier                  | customer_profile_id | txn_info                                                                                                                                                                                                                                                                        |
      | InboundTitleFetchIdentifier | PSCPID1             | {"info":{"rrn":"InboundTitleFetchIdentifier","stan":"InboundTitleFetchIdentifier","txndate":"InboundTitleFetchIdentifier","txntime":"InboundTitleFetchIdentifier", "initiator":"RAAST"},"receiverinfo":{"to_account":"PK96HUGO0000003363390659"},"payment_info":{"amount":100}} |

    Examples:
      | amount |
      | 100    |

  Scenario Outline: Credit Inquiry --- Process CreditPosting and initiate the creditInquiry request to get the status of processed creditPosting

    Given I create account for EndCustomerProfile with id ECPID1 for CustomerProfile PSCPID1 from CASH_SERVICE on behalf of CUSTOMER with provider PAYSYS and expect the header status 200
      | identifier | currency | country | metadata                    | on_behalf_of |
      | AccountId  | PKR      | PAK     | {"key": "IntegrationTest1"} | CUSTOMER     |

    Then I wait until max time to verify the payment account AccountId from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I verify CustomerProfile with id PSCPID1 has payment account AccountId from CASH_SERVICE on behalf of CUSTOMER exists with provider PAYSYS with values
      | account_id | provider_id | currency | account_status  | metadata                    | on_behalf_of |
      | AccountId  | PAYSYS-PK   | PKR      | ACCOUNT_CREATED | {"key": "IntegrationTest1"} | CUSTOMER     |

    Then I retrieve the payment account AccountId from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I initiate a request to inquiry an account AccountId to validate the account to initiate a credit payment of amount <amount> from initiator RAAST and expect the response status 0000
      | identifier                  | customer_profile_id | txn_info                                                                                                                                                                                                                                                                        |
      | InboundTitleFetchIdentifier | PSCPID1             | {"info":{"rrn":"InboundTitleFetchIdentifier","stan":"InboundTitleFetchIdentifier","txndate":"InboundTitleFetchIdentifier","txntime":"InboundTitleFetchIdentifier", "initiator":"RAAST"},"receiverinfo":{"to_account":"PK96HUGO0000003363390659"},"payment_info":{"amount":100}} |

    Given I deposit an amount of <amount> into account AccountId using CreditPosting for customerProfileId PSCPID1
      | identifier              | customer_profile_id | txn_info                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
      | CreditPostingIdentifier | PSCPID1             | {"info":{"rrn":"CreditPostingIdentifier","stan":"CreditPostingIdentifier","txndate":"CreditPostingIdentifier","txntime":"CreditPostingIdentifier"},"receiverinfo":{"to_account":"PK96HUGO0000003363390659","to_account_title":"Waqas Nizam"},"senderinfo":{"sender_bank_iMD":"","sender_bank_bIC":"NBPBPKKA","from_account":"PK56AIIN1234567890000001","from_account_title":"Muhammad Ali","from_account_cnic":"1234512345671"},"payment_info":{"purpose_code":"0125","narration":"Integration Test transaction","amount":100,"instr_id":"TMIC230511125023876423","end_to_end_id":"1fc66b584e77-46e6-9dcb-fb12c00e7742","tx_id":"TMIC230511125023876423","msg_id":"CreditPostingIdentifier"}} |

    Then I wait until max time to verify master  account AccountId with an increased updated balance of <amount> for customerProfileId PSCPID1 in Paysys

    Given I initiate a creditInquiry request to get the status of the credit CreditPostingIdentifier that is processed successfully
      | identifier              | txn_info                                                                                                                                                                                                                                                                                                                        |
      | CreditInquiryIdentifier | {"info":{"rrn":"CreditInquiryIdentifier","stan":"CreditInquiryIdentifier","txndate":"CreditInquiryIdentifier","txntime":"CreditInquiryIdentifier"},"orgTxnInfo":{"orgtxnrrn":"CreditPostingIdentifier","orgtxnstan":"CreditPostingIdentifier", "orgtxndate":"CreditPostingIdentifier", "orgtxntime":"CreditPostingIdentifier"}} |

    Examples:
      | amount |
      | 100    |

#  Scenario Outline: Credit Advise Deposit Notification --- Deposit amount into customer profile account using Credit Advise and check if balance of the account
#
#    Then I retrieve the payment account CustomerAccountId from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1
#
#    Given I deposit an amount of <amount> into account CustomerAccountId using IDN for customerProfileId PSCPID1
#      | identifier    | customer_profile_id |  txn_info                                                                                                                                                                                                                                                                                                                                                  |
#      | IDNIdentifier | PSCPID1             | {"amt_dtls": {"txn_amt": "150","txn_ccy": "SGD"},"customer_reference": "IDNIdentifier","sender_party": { "name": "HUGO","sender_bank_id": "DBSSSGSGXXX"},"txn_ref_id": "IDNIdentifier","receiving_party": {"account_no":"88532600026958397","name": "ATLAS CONSOLIDATED PTE. LTD."},"txn_type":"FAST","txn_date": "2023-01-06","value_dt": "2023-01-06" } |
#
#    Then I wait until max time to verify master account CustomerAccountId with an increased updated balance of <amount> for customerProfileId PSCPID1
#    Examples:
#      | amount |
#      | 100    |
#
#  Scenario Outline: Credit Advise Deposit Notification --- Deposit amount into end customer profile account using IDN and check if balance of the account
#
#    Then I retrieve the payment account AccountId from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID1
#
#    Given I deposit an amount of <amount> into account AccountId using IDN for customerProfileId PSCPID1
#      | identifier    | customer_profile_id | header                                                                                         | txn_info                                                                                                                                                                                                                                                                                                                                                  |
#      | IDNIdentifier | PSCPID1             | {"msgId":"ICNIdentifier","orgId":"ATLCONS3","ctry":"SG","timeStamp":"2023-01-06T09:48:59.457"} | {"amt_dtls": {"txn_amt": "150","txn_ccy": "SGD"},"customer_reference": "IDNIdentifier","sender_party": { "name": "HUGO","sender_bank_id": "DBSSSGSGXXX"},"txn_ref_id": "IDNIdentifier","receiving_party": {"account_no":"88532600026958397","name": "ATLAS CONSOLIDATED PTE. LTD."},"txn_type":"FAST","txn_date": "2023-01-06","value_dt": "2023-01-06" } |
#
#    Then I wait until max time to verify master account AccountId with an increased updated balance of <amount> for customerProfileId PSCPID1
#    Examples:
#      | amount |
#      | 100    |
#
#  Scenario Outline: IDN Deposit Notification --- Deposit amount into master account using IDN and check if balance of the account
#
#    Then I retrieve the payment account AccountId from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID1
#
#    Given I deposit an amount of <amount> into master account AccountId using IDN for customerProfileId PSCPID1
#      | identifier    | customer_profile_id | header                                                                                         | txn_info                                                                                                                                                                                                                                                                                                                                                  |
#      | IDNIdentifier | PSCPID1             | {"msgId":"ICNIdentifier","orgId":"ATLCONS3","ctry":"SG","timeStamp":"2023-01-06T09:48:59.457"} | {"amt_dtls": {"txn_amt": "150","txn_ccy": "SGD"},"customer_reference": "IDNIdentifier","sender_party": { "name": "HUGO","sender_bank_id": "DBSSSGSGXXX"},"txn_ref_id": "IDNIdentifier","receiving_party": {"account_no":"88532600026958397","name": "ATLAS CONSOLIDATED PTE. LTD."},"txn_type":"FAST","txn_date": "2023-01-06","value_dt": "2023-01-06" } |
#
#    Then I wait until max time to verify master account AccountId with an increased updated balance of <amount> for customerProfileId PSCPID1
#    Examples:
#      | amount |
#      | 100    |


