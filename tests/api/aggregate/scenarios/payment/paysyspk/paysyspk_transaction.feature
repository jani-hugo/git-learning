Feature: Payment service transaction, payments and deposit scenarios for provider PAYSYS

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


  Scenario Outline: I call TransferOut to transfer an amount between internal Hugohub customer profile accounts from CASH_SERVICE on behalf of CUSTOMER and verify the transaction is settled

    Given I create account for CustomerProfile with customerProfileId PSCPID1 from <request_origin> on behalf of <on_behalf_of> with provider PAYSYS and expect the header status <status_code>
      | identifier                | currency   | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I verify CustomerProfile with id PSCPID1 has payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> exists with provider PAYSYS with values
      | account_id                | provider_id | currency   | account_status  | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | PAYSYS-PK   | <currency> | ACCOUNT_CREATED | <country> | <metadata> | <on_behalf_of> |

    Given I create account for CustomerProfile with customerProfileId PSCPID1 from CASH_SERVICE on behalf of CUSTOMER with provider PAYSYS and expect the header status <status_code>
      | identifier                | currency   | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId2 | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account CustomerProfileAccountId2 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I verify CustomerProfile with id PSCPID1 has payment account CustomerProfileAccountId2 from <request_origin> on behalf of <on_behalf_of> exists with provider PAYSYS with values
      | account_id                | provider_id | currency   | account_status  | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId2 | PAYSYS-PK   | <currency> | ACCOUNT_CREATED | <country> | <metadata> | <on_behalf_of> |

    Then I retrieve the payment account CustomerProfileAccountId1 from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I initiate a request to inquiry an account CustomerProfileAccountId1 to validate the account to initiate a credit payment of amount <deposit_amount> from initiator RAAST and expect the response status 0000
      | identifier                  | customer_profile_id | txn_info                                                                                                                                                                                                                                                                        |
      | InboundTitleFetchIdentifier | PSCPID1             | {"info":{"rrn":"InboundTitleFetchIdentifier","stan":"InboundTitleFetchIdentifier","txndate":"InboundTitleFetchIdentifier","txntime":"InboundTitleFetchIdentifier", "initiator":"RAAST"},"receiverinfo":{"to_account":"PK96HUGO0000003363390659"},"payment_info":{"amount":100}} |

    Given I deposit an amount of <deposit_amount> into account CustomerProfileAccountId1 using CreditPosting for customerProfileId PSCPID1
      | identifier              | customer_profile_id | txn_info                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
      | CreditPostingIdentifier | PSCPID1             | {"info":{"rrn":"CreditPostingIdentifier","stan":"CreditPostingIdentifier","txndate":"CreditPostingIdentifier","txntime":"CreditPostingIdentifier"},"receiverinfo":{"to_account":"PK96HUGO0000003363390659","to_account_title":"Waqas Nizam"},"senderinfo":{"sender_bank_iMD":"","sender_bank_bIC":"NBPBPKKA","from_account":"PK56AIIN1234567890000001","from_account_title":"Muhammad Ali","from_account_cnic":"1234512345671"},"payment_info":{"purpose_code":"0125","narration":"Integration Test transaction","amount":100,"instr_id":"TMIC230511125023876423","end_to_end_id":"1fc66b584e77-46e6-9dcb-fb12c00e7742","tx_id":"TMIC230511125023876423","msg_id":"CreditPostingIdentifier"}} |

    Then I wait until max time to verify master  account CustomerProfileAccountId1 with an increased updated balance of <deposit_amount> for customerProfileId PSCPID1 in Paysys

    Then I initiate transfer out to transfer funds internally with below details from CASH_SERVICE and expect the header status <status_code> and status as TRANSACTION_SETTLED in Paysys
      | identifier | customer_profile_id | account_id                | receiver_account_id       | txn_mode   | txn_currency | txn_amount   | purpose          | transfer_out_account_details                                                                                                                                                        | metadata                    | currency   | total_balance    | available_balance |
      | TxnId1     | PSCPID1             | CustomerProfileAccountId1 | CustomerProfileAccountId2 | <txn_mode> | PKR          | <txn_amount> | Internal Pay Out | {"account_holder_name" : "XYZ","country" : "PAK","currency": "PKR","bank_name" : "HugoBank","code_details" : {'pk_bank_details' : {'bank_bic' : 'HUGOPKKA','bank_imd' : '998890'}}} | {"key": "Internal Pay Out"} | <currency> | <deposit_amount> | <deposit_amount>  |

    Examples:
      | txn_amount | currency | country | status_code | request_origin | on_behalf_of | metadata                    | deposit_amount | txn_mode  |
      | 10         | PKR      | PAK     | 200         | CASH_SERVICE   | CUSTOMER     | {"key": "Internal Pay Out"} | 100            | RAASTP2P  |
      | 20         | PKR      | PAK     | 200         | CASH_SERVICE   | CUSTOMER     | {"key": "Internal Pay Out"} | 100            | 1LINKIBFT |

  Scenario Outline: I call TransferOut to transfer an amount between internal Hugohub end customer profile accounts from CASH_SERVICE on behalf of CUSTOMER and verify the transaction is settled

    Given I create account for EndCustomerProfile with id ECPID1 for CustomerProfile PSCPID1 from <request_origin> on behalf of <on_behalf_of> with provider PAYSYS and expect the header status <status_code>
      | identifier                   | currency   | country   | metadata   | on_behalf_of   |
      | EndCustomerProfileAccountId1 | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account EndCustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I verify EndCustomerProfile with id ECPID1 for CustomerProfile PSCPID1 has payment account AccountId from <request_origin> on behalf of <on_behalf_of> exists with provider PAYSYS with values
      | identifier                   | provider_id | currency   | country   | account_status  | metadata   | on_behalf_of   |
      | EndCustomerProfileAccountId1 | PAYSYS-PK   | <currency> | <country> | ACCOUNT_CREATED | <metadata> | <on_behalf_of> |

    Given I create account for EndCustomerProfile with id ECPID1 for CustomerProfile PSCPID1 from <request_origin> on behalf of <on_behalf_of> with provider PAYSYS and expect the header status <status_code>
      | identifier                   | currency   | country   | metadata   | on_behalf_of   |
      | EndCustomerProfileAccountId2 | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account EndCustomerProfileAccountId2 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I verify EndCustomerProfile with id ECPID1 for CustomerProfile PSCPID1 has payment account AccountId from <request_origin> on behalf of <on_behalf_of> exists with provider PAYSYS with values
      | identifier                   | provider_id | currency   | country   | account_status  | metadata   | on_behalf_of   |
      | EndCustomerProfileAccountId2 | PAYSYS-PK   | <currency> | <country> | ACCOUNT_CREATED | <metadata> | <on_behalf_of> |

    Then I retrieve the payment account EndCustomerProfileAccountId1 from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I initiate a request to inquiry an account EndCustomerProfileAccountId1 to validate the account to initiate a credit payment of amount <deposit_amount> from initiator RAAST and expect the response status 0000
      | identifier                  | customer_profile_id | txn_info                                                                                                                                                                                                                                                                        |
      | InboundTitleFetchIdentifier | PSCPID1             | {"info":{"rrn":"InboundTitleFetchIdentifier","stan":"InboundTitleFetchIdentifier","txndate":"InboundTitleFetchIdentifier","txntime":"InboundTitleFetchIdentifier", "initiator":"RAAST"},"receiverinfo":{"to_account":"PK96HUGO0000003363390659"},"payment_info":{"amount":100}} |

    Given I deposit an amount of <deposit_amount> into account EndCustomerProfileAccountId1 using CreditPosting for customerProfileId PSCPID1
      | identifier              | customer_profile_id | txn_info                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
      | CreditPostingIdentifier | PSCPID1             | {"info":{"rrn":"CreditPostingIdentifier","stan":"CreditPostingIdentifier","txndate":"CreditPostingIdentifier","txntime":"CreditPostingIdentifier"},"receiverinfo":{"to_account":"PK96HUGO0000003363390659","to_account_title":"Waqas Nizam"},"senderinfo":{"sender_bank_iMD":"","sender_bank_bIC":"NBPBPKKA","from_account":"PK56AIIN1234567890000001","from_account_title":"Muhammad Ali","from_account_cnic":"1234512345671"},"payment_info":{"purpose_code":"0125","narration":"Integration Test transaction","amount":100,"instr_id":"TMIC230511125023876423","end_to_end_id":"1fc66b584e77-46e6-9dcb-fb12c00e7742","tx_id":"TMIC230511125023876423","msg_id":"CreditPostingIdentifier"}} |

    Then I wait until max time to verify master account EndCustomerProfileAccountId1 with an increased updated balance of <deposit_amount> for customerProfileId PSCPID1

    Then I initiate transfer out to transfer funds internally with below details from CASH_SERVICE  and expect the header status <status_code> and status as TRANSACTION_SETTLED in Paysys
      | identifier | customer_profile_id | account_id                   | receiver_account_id          | txn_currency | txn_amount   | txn_mode   | purpose          | transfer_out_account_details                                                                                                                                                        | metadata                    | currency   | total_balance    | available_balance |
      | TxnId1     | PSCPID1             | EndCustomerProfileAccountId1 | EndCustomerProfileAccountId2 | PKR          | <txn_amount> | <txn_mode> | Internal Pay Out | {"account_holder_name" : "XYZ","country" : "PAK","currency": "PKR","bank_name" : "HugoBank","code_details" : {'pk_bank_details' : {'bank_bic' : 'HUGOPKKA','bank_imd' : '998890'}}} | {"key": "Internal Pay Out"} | <currency> | <deposit_amount> | <deposit_amount>  |

    Examples:
      | txn_amount | currency | country | status_code | request_origin | on_behalf_of | metadata                    | deposit_amount | txn_mode  |
      | 10         | PKR      | PAK     | 200         | CASH_SERVICE   | CUSTOMER     | {"key": "Internal Pay Out"} | 100            | RAASTP2P  |
      | 20         | PKR      | PAK     | 200         | CASH_SERVICE   | CUSTOMER     | {"key": "Internal Pay Out"} | 100            | 1LINKIBFT |

  Scenario Outline: I call TransferOut to transfer an amount between internal Hugohub customer profile and end customer profile accounts from CASH_SERVICE on behalf of CUSTOMER and verify the transaction is settled

    Given I create account for CustomerProfile with customerProfileId PSCPID1 from <request_origin> on behalf of <on_behalf_of> with provider PAYSYS and expect the header status <status_code>
      | identifier                | currency   | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I verify CustomerProfile with id PSCPID1 has payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> exists with provider PAYSYS with values
      | account_id                | provider_id | currency   | account_status  | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | PAYSYS-PK   | <currency> | ACCOUNT_CREATED | <country> | <metadata> | <on_behalf_of> |

    Given I create account for EndCustomerProfile with id ECPID1 for CustomerProfile PSCPID1 from <request_origin> on behalf of <on_behalf_of> with provider PAYSYS and expect the header status <status_code>
      | identifier                   | currency   | country   | metadata   | on_behalf_of   |
      | EndCustomerProfileAccountId1 | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account EndCustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I verify EndCustomerProfile with id ECPID1 for CustomerProfile PSCPID1 has payment account AccountId from <request_origin> on behalf of <on_behalf_of> exists with provider PAYSYS with values
      | identifier                   | provider_id | currency   | country   | account_status  | metadata   | on_behalf_of   |
      | EndCustomerProfileAccountId1 | PAYSYS-PK   | <currency> | <country> | ACCOUNT_CREATED | <metadata> | <on_behalf_of> |

    Then I retrieve the payment account CustomerProfileAccountId1 from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I initiate a request to inquiry an account CustomerProfileAccountId1 to validate the account to initiate a credit payment of amount <deposit_amount> from initiator RAAST and expect the response status 0000
      | identifier                  | customer_profile_id | txn_info                                                                                                                                                                                                                                                                        |
      | InboundTitleFetchIdentifier | PSCPID1             | {"info":{"rrn":"InboundTitleFetchIdentifier","stan":"InboundTitleFetchIdentifier","txndate":"InboundTitleFetchIdentifier","txntime":"InboundTitleFetchIdentifier", "initiator":"RAAST"},"receiverinfo":{"to_account":"PK96HUGO0000003363390659"},"payment_info":{"amount":100}} |

    Given I deposit an amount of <deposit_amount> into account CustomerProfileAccountId1 using CreditPosting for customerProfileId PSCPID1
      | identifier              | customer_profile_id | txn_info                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
      | CreditPostingIdentifier | PSCPID1             | {"info":{"rrn":"CreditPostingIdentifier","stan":"CreditPostingIdentifier","txndate":"CreditPostingIdentifier","txntime":"CreditPostingIdentifier"},"receiverinfo":{"to_account":"PK96HUGO0000003363390659","to_account_title":"Waqas Nizam"},"senderinfo":{"sender_bank_iMD":"","sender_bank_bIC":"NBPBPKKA","from_account":"PK56AIIN1234567890000001","from_account_title":"Muhammad Ali","from_account_cnic":"1234512345671"},"payment_info":{"purpose_code":"0125","narration":"Integration Test transaction","amount":100,"instr_id":"TMIC230511125023876423","end_to_end_id":"1fc66b584e77-46e6-9dcb-fb12c00e7742","tx_id":"TMIC230511125023876423","msg_id":"CreditPostingIdentifier"}} |

    Then I wait until max time to verify master account CustomerProfileAccountId1 with an increased updated balance of <deposit_amount> for customerProfileId PSCPID1

    Then I initiate transfer out to transfer funds internally with below details from CASH_SERVICE and expect the header status <status_code> and status as TRANSACTION_SETTLED in Paysys
      | identifier | customer_profile_id | account_id                | receiver_account_id          | txn_currency | txn_amount   | txn_mode   | purpose          | transfer_out_account_details                                                                                                                                                        | metadata                    | currency   | total_balance    | available_balance |
      | TxnId1     | PSCPID1             | CustomerProfileAccountId1 | EndCustomerProfileAccountId1 | PKR          | <txn_amount> | <txn_mode> | Internal Pay Out | {"account_holder_name" : "XYZ","country" : "PAK","currency": "PKR","bank_name" : "HugoBank","code_details" : {'pk_bank_details' : {'bank_bic' : 'HUGOPKKA','bank_imd' : '998890'}}} | {"key": "Internal Pay Out"} | <currency> | <deposit_amount> | <deposit_amount>  |

    Examples:
      | txn_amount | currency | country | status_code | request_origin | on_behalf_of | metadata                    | deposit_amount | txn_mode  |
      | 10         | PKR      | PAK     | 200         | CASH_SERVICE   | CUSTOMER     | {"key": "Internal Pay Out"} | 100            | RAASTP2P  |
      | 20         | PKR      | PAK     | 200         | CASH_SERVICE   | CUSTOMER     | {"key": "Internal Pay Out"} | 100            | 1LINKIBFT |

  Scenario Outline: I call TransferOut to transfer an amount between internal Hugohub end customer profile and customer profile accounts from CASH_SERVICE on behalf of CUSTOMER and verify the transaction is settled

    Given I create account for EndCustomerProfile with id ECPID1 for CustomerProfile PSCPID1 from <request_origin> on behalf of <on_behalf_of> with provider PAYSYS and expect the header status <status_code>
      | identifier                   | currency   | country   | metadata   | on_behalf_of   |
      | EndCustomerProfileAccountId1 | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account EndCustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I verify EndCustomerProfile with id ECPID1 for CustomerProfile PSCPID1 has payment account AccountId from <request_origin> on behalf of <on_behalf_of> exists with provider PAYSYS with values
      | identifier                   | provider_id | currency   | country   | account_status  | metadata   | on_behalf_of   |
      | EndCustomerProfileAccountId1 | PAYSYS-PK   | <currency> | <country> | ACCOUNT_CREATED | <metadata> | <on_behalf_of> |

    Given I create account for CustomerProfile with customerProfileId PSCPID1 from <request_origin> on behalf of <on_behalf_of> with provider PAYSYS and expect the header status <status_code>
      | identifier                | currency   | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I verify CustomerProfile with id PSCPID1 has payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> exists with provider PAYSYS with values
      | account_id                | provider_id | currency   | account_status  | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | PAYSYS-PK   | <currency> | ACCOUNT_CREATED | <country> | <metadata> | <on_behalf_of> |

    Then I retrieve the payment account EndCustomerProfileAccountId1 from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I initiate a request to inquiry an account EndCustomerProfileAccountId1 to validate the account to initiate a credit payment of amount <deposit_amount> from initiator RAAST and expect the response status 0000
      | identifier                  | customer_profile_id | txn_info                                                                                                                                                                                                                                                                        |
      | InboundTitleFetchIdentifier | PSCPID1             | {"info":{"rrn":"InboundTitleFetchIdentifier","stan":"InboundTitleFetchIdentifier","txndate":"InboundTitleFetchIdentifier","txntime":"InboundTitleFetchIdentifier", "initiator":"RAAST"},"receiverinfo":{"to_account":"PK96HUGO0000003363390659"},"payment_info":{"amount":100}} |

    Given I deposit an amount of <deposit_amount> into account EndCustomerProfileAccountId1 using CreditPosting for customerProfileId PSCPID1
      | identifier              | customer_profile_id | txn_info                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
      | CreditPostingIdentifier | PSCPID1             | {"info":{"rrn":"CreditPostingIdentifier","stan":"CreditPostingIdentifier","txndate":"CreditPostingIdentifier","txntime":"CreditPostingIdentifier"},"receiverinfo":{"to_account":"PK96HUGO0000003363390659","to_account_title":"Waqas Nizam"},"senderinfo":{"sender_bank_iMD":"","sender_bank_bIC":"NBPBPKKA","from_account":"PK56AIIN1234567890000001","from_account_title":"Muhammad Ali","from_account_cnic":"1234512345671"},"payment_info":{"purpose_code":"0125","narration":"Integration Test transaction","amount":100,"instr_id":"TMIC230511125023876423","end_to_end_id":"1fc66b584e77-46e6-9dcb-fb12c00e7742","tx_id":"TMIC230511125023876423","msg_id":"CreditPostingIdentifier"}} |

    Then I wait until max time to verify master account EndCustomerProfileAccountId1 with an increased updated balance of <deposit_amount> for customerProfileId PSCPID1

    Then I initiate transfer out to transfer funds internally with below details from CASH_SERVICE and expect the header status <status_code> and status as TRANSACTION_SETTLED in Paysys
      | identifier | customer_profile_id | account_id                   | receiver_account_id       | txn_currency | txn_amount   | txn_mode   | purpose          | txn_mode | transfer_out_account_details                                                                                                                                                        | metadata                    | currency   | total_balance    | available_balance |
      | TxnId1     | PSCPID1             | EndCustomerProfileAccountId1 | CustomerProfileAccountId1 | PKR          | <txn_amount> | <txn_mode> | Internal Pay Out | RAASTP2P | {"account_holder_name" : "XYZ","country" : "PAK","currency": "PKR","bank_name" : "HugoBank","code_details" : {'pk_bank_details' : {'bank_bic' : 'HUGOPKKA','bank_imd' : '998890'}}} | {"key": "Internal Pay Out"} | <currency> | <deposit_amount> | <deposit_amount>  |

    Examples:
      | txn_amount | currency | country | status_code | request_origin | on_behalf_of | metadata                    | deposit_amount | txn_mode  |
      | 10         | PKR      | PAK     | 200         | CASH_SERVICE   | CUSTOMER     | {"key": "Internal Pay Out"} | 100            | RAASTP2P  |
      | 20         | PKR      | PAK     | 200         | CASH_SERVICE   | CUSTOMER     | {"key": "Internal Pay Out"} | 100            | 1LINKIBFT |

  Scenario Outline: I call TransferOut to transfer an amount between internal Hugohub end customer profile accounts with wrong account details from CASH_SERVICE on behalf of CUSTOMER and verify the transaction is failed

    Given I create account for EndCustomerProfile with id ECPID1 for CustomerProfile PSCPID1 from <request_origin> on behalf of <on_behalf_of> with provider PAYSYS and expect the header status <status_code>
      | identifier                   | currency   | country   | metadata   | on_behalf_of   |
      | EndCustomerProfileAccountId1 | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account EndCustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I verify EndCustomerProfile with id ECPID1 for CustomerProfile PSCPID1 has payment account AccountId from <request_origin> on behalf of <on_behalf_of> exists with provider PAYSYS with values
      | identifier                   | provider_id | currency   | country   | account_status  | metadata   | on_behalf_of   |
      | EndCustomerProfileAccountId1 | PAYSYS-PK   | <currency> | <country> | ACCOUNT_CREATED | <metadata> | <on_behalf_of> |

    Given I create account for EndCustomerProfile with id ECPID1 for CustomerProfile PSCPID1 from <request_origin> on behalf of <on_behalf_of> with provider PAYSYS and expect the header status <status_code>
      | identifier                   | currency   | country   | metadata   | on_behalf_of   |
      | EndCustomerProfileAccountId2 | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account EndCustomerProfileAccountId2 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I verify EndCustomerProfile with id ECPID1 for CustomerProfile PSCPID1 has payment account AccountId from <request_origin> on behalf of <on_behalf_of> exists with provider PAYSYS with values
      | identifier                   | provider_id | currency   | country   | account_status  | metadata   | on_behalf_of   |
      | EndCustomerProfileAccountId2 | PAYSYS-PK   | <currency> | <country> | ACCOUNT_CREATED | <metadata> | <on_behalf_of> |

    Then I retrieve the payment account EndCustomerProfileAccountId1 from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I initiate a request to inquiry an account EndCustomerProfileAccountId1 to validate the account to initiate a credit payment of amount <deposit_amount> from initiator RAAST and expect the response status 0000
      | identifier                  | customer_profile_id | txn_info                                                                                                                                                                                                                                                                        |
      | InboundTitleFetchIdentifier | PSCPID1             | {"info":{"rrn":"InboundTitleFetchIdentifier","stan":"InboundTitleFetchIdentifier","txndate":"InboundTitleFetchIdentifier","txntime":"InboundTitleFetchIdentifier", "initiator":"RAAST"},"receiverinfo":{"to_account":"PK96HUGO0000003363390659"},"payment_info":{"amount":100}} |

    Given I deposit an amount of <deposit_amount> into account EndCustomerProfileAccountId1 using CreditPosting for customerProfileId PSCPID1
      | identifier              | customer_profile_id | txn_info                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
      | CreditPostingIdentifier | PSCPID1             | {"info":{"rrn":"CreditPostingIdentifier","stan":"CreditPostingIdentifier","txndate":"CreditPostingIdentifier","txntime":"CreditPostingIdentifier"},"receiverinfo":{"to_account":"PK96HUGO0000003363390659","to_account_title":"Waqas Nizam"},"senderinfo":{"sender_bank_iMD":"","sender_bank_bIC":"NBPBPKKA","from_account":"PK56AIIN1234567890000001","from_account_title":"Muhammad Ali","from_account_cnic":"1234512345671"},"payment_info":{"purpose_code":"0125","narration":"Integration Test transaction","amount":100,"instr_id":"TMIC230511125023876423","end_to_end_id":"1fc66b584e77-46e6-9dcb-fb12c00e7742","tx_id":"TMIC230511125023876423","msg_id":"CreditPostingIdentifier"}} |

    Then I wait until max time to verify master account EndCustomerProfileAccountId1 with an increased updated balance of <deposit_amount> for customerProfileId PSCPID1

    Then I initiate transfer out to transfer funds internally with below details from CASH_SERVICE and expect the header status <status_code> and status as TRANSACTION_FAILED in Paysys
      | identifier | customer_profile_id | account_id                   | receiver_account_id          | txn_currency | txn_amount   | txn_mode   | purpose          | txn_mode | transfer_out_account_details                                                                                                                                                        | metadata                    | currency   | total_balance    | available_balance |
      | TxnId1     | PSCPID1             | EndCustomerProfileAccountId1 | EndCustomerProfileAccountId3 | PKR          | <txn_amount> | <txn_mode> | Internal Pay Out | RAASTP2P | {"account_holder_name" : "XYZ","country" : "PAK","currency": "PKR","bank_name" : "HugoBank","code_details" : {'pk_bank_details' : {'bank_bic' : 'HUGOPKKA','bank_imd' : '998890'}}} | {"key": "Internal Pay Out"} | <currency> | <deposit_amount> | <deposit_amount>  |

    Examples:
      | txn_amount | currency | country | status_code | request_origin | on_behalf_of | metadata                    | deposit_amount | txn_mode  |
      | 10         | PKR      | PAK     | 200         | CASH_SERVICE   | CUSTOMER     | {"key": "Internal Pay Out"} | 100            | RAASTP2P  |
      | 20         | PKR      | PAK     | 200         | CASH_SERVICE   | CUSTOMER     | {"key": "Internal Pay Out"} | 100            | 1LINKIBFT |

  Scenario Outline: I call TransferOut to transfer an amount between internal Hugohub accounts where TxnMode is not passed from CASH_SERVICE on behalf of CUSTOMER and verify the transaction is settled

    Given I create account for CustomerProfile with customerProfileId PSCPID1 from <request_origin> on behalf of <on_behalf_of> with provider PAYSYS and expect the header status <status_code>
      | identifier                | currency   | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I verify CustomerProfile with id PSCPID1 has payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> exists with provider PAYSYS with values
      | account_id                | provider_id | currency   | account_status  | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | PAYSYS-PK   | <currency> | ACCOUNT_CREATED | <country> | <metadata> | <on_behalf_of> |

    Given I create account for CustomerProfile with customerProfileId PSCPID1 from CASH_SERVICE on behalf of CUSTOMER with provider PAYSYS and expect the header status <status_code>
      | identifier                | currency   | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId2 | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account CustomerProfileAccountId2 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I verify CustomerProfile with id PSCPID1 has payment account CustomerProfileAccountId2 from <request_origin> on behalf of <on_behalf_of> exists with provider PAYSYS with values
      | account_id                | provider_id | currency   | account_status  | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId2 | PAYSYS-PK   | <currency> | ACCOUNT_CREATED | <country> | <metadata> | <on_behalf_of> |

    Then I retrieve the payment account CustomerProfileAccountId1 from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I initiate a request to inquiry an account CustomerProfileAccountId1 to validate the account to initiate a credit payment of amount <deposit_amount> from initiator RAAST and expect the response status 0000
      | identifier                  | customer_profile_id | txn_info                                                                                                                                                                                                                                                                        |
      | InboundTitleFetchIdentifier | PSCPID1             | {"info":{"rrn":"InboundTitleFetchIdentifier","stan":"InboundTitleFetchIdentifier","txndate":"InboundTitleFetchIdentifier","txntime":"InboundTitleFetchIdentifier", "initiator":"RAAST"},"receiverinfo":{"to_account":"PK96HUGO0000003363390659"},"payment_info":{"amount":100}} |

    Given I deposit an amount of <deposit_amount> into account CustomerProfileAccountId1 using CreditPosting for customerProfileId PSCPID1
      | identifier              | customer_profile_id | txn_info                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
      | CreditPostingIdentifier | PSCPID1             | {"info":{"rrn":"CreditPostingIdentifier","stan":"CreditPostingIdentifier","txndate":"CreditPostingIdentifier","txntime":"CreditPostingIdentifier"},"receiverinfo":{"to_account":"PK96HUGO0000003363390659","to_account_title":"Waqas Nizam"},"senderinfo":{"sender_bank_iMD":"","sender_bank_bIC":"NBPBPKKA","from_account":"PK56AIIN1234567890000001","from_account_title":"Muhammad Ali","from_account_cnic":"1234512345671"},"payment_info":{"purpose_code":"0125","narration":"Integration Test transaction","amount":100,"instr_id":"TMIC230511125023876423","end_to_end_id":"1fc66b584e77-46e6-9dcb-fb12c00e7742","tx_id":"TMIC230511125023876423","msg_id":"CreditPostingIdentifier"}} |

    Then I wait until max time to verify master  account CustomerProfileAccountId1 with an increased updated balance of <deposit_amount> for customerProfileId PSCPID1 in Paysys

    Then I initiate transfer out to transfer funds internally with below details from CASH_SERVICE and expect the header status <status_code> and status as TRANSACTION_SETTLED in Paysys
      | identifier | customer_profile_id | account_id                | receiver_account_id       | txn_currency | txn_amount   | purpose          | transfer_out_account_details                                                                                                                                                        | metadata                    | currency | total_balance    | available_balance |
      | TxnId1     | PSCPID1             | CustomerProfileAccountId1 | CustomerProfileAccountId2 | PKR          | <txn_amount> | Internal Pay Out | {"account_holder_name" : "XYZ","country" : "PAK","currency": "PKR","bank_name" : "HugoBank","code_details" : {'pk_bank_details' : {'bank_bic' : 'HUGOPKKA','bank_imd' : '998890'}}} | {"key": "Internal Pay Out"} | PKR      | <deposit_amount> | <deposit_amount>  |

    Examples:
      | txn_amount | currency | country | status_code | request_origin | on_behalf_of | metadata                    | deposit_amount |
      | 10         | PKR      | PAK     | 200         | CASH_SERVICE   | CUSTOMER     | {"key": "Internal Pay Out"} | 100            |
      | 20         | PKR      | PAK     | 200         | CASH_SERVICE   | CUSTOMER     | {"key": "Internal Pay Out"} | 100            |

  Scenario Outline: I call TransferOut to transfer an amount between internal Hugohub customer profile account and external account where TxnMode is not passed from CASH_SERVICE on behalf of CUSTOMER and verify the transaction is settled

    Given I create account for CustomerProfile with customerProfileId PSCPID1 from <request_origin> on behalf of <on_behalf_of> with provider PAYSYS and expect the header status <status_code>
      | identifier                | currency   | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I verify CustomerProfile with id PSCPID1 has payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> exists with provider PAYSYS with values
      | account_id                | provider_id | currency   | account_status  | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | PAYSYS-PK   | <currency> | ACCOUNT_CREATED | <country> | <metadata> | <on_behalf_of> |

    Then I retrieve the payment account CustomerProfileAccountId1 from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I initiate a request to inquiry an account CustomerProfileAccountId1 to validate the account to initiate a credit payment of amount <deposit_amount> from initiator RAAST and expect the response status 0000
      | identifier                  | customer_profile_id | txn_info                                                                                                                                                                                                                                                                        |
      | InboundTitleFetchIdentifier | PSCPID1             | {"info":{"rrn":"InboundTitleFetchIdentifier","stan":"InboundTitleFetchIdentifier","txndate":"InboundTitleFetchIdentifier","txntime":"InboundTitleFetchIdentifier", "initiator":"RAAST"},"receiverinfo":{"to_account":"PK96HUGO0000003363390659"},"payment_info":{"amount":100}} |

    Given I deposit an amount of <deposit_amount> into account CustomerProfileAccountId1 using CreditPosting for customerProfileId PSCPID1
      | identifier              | customer_profile_id | txn_info                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
      | CreditPostingIdentifier | PSCPID1             | {"info":{"rrn":"CreditPostingIdentifier","stan":"CreditPostingIdentifier","txndate":"CreditPostingIdentifier","txntime":"CreditPostingIdentifier"},"receiverinfo":{"to_account":"PK96HUGO0000003363390659","to_account_title":"Waqas Nizam"},"senderinfo":{"sender_bank_iMD":"","sender_bank_bIC":"NBPBPKKA","from_account":"PK56AIIN1234567890000001","from_account_title":"Muhammad Ali","from_account_cnic":"1234512345671"},"payment_info":{"purpose_code":"0125","narration":"Integration Test transaction","amount":100,"instr_id":"TMIC230511125023876423","end_to_end_id":"1fc66b584e77-46e6-9dcb-fb12c00e7742","tx_id":"TMIC230511125023876423","msg_id":"CreditPostingIdentifier"}} |

    Then I wait until max time to verify master account CustomerProfileAccountId1 with an increased updated balance of <deposit_amount> for customerProfileId PSCPID1

    Then I initiate transfer out to transfer funds to an external account from CASH_SERVICE and expect the header status <status_code> and status as TRANSACTION_SETTLED in Paysys
      | identifier | customer_profile_id | account_id                | txn_currency | txn_amount   | purpose          | transfer_out_account_details                                                                                                                                                                                                                    | metadata                    | currency   | total_balance    | available_balance |
      | TxnId1     | PSCPID1             | CustomerProfileAccountId1 | PKR          | <txn_amount> | Internal Pay Out | {'account_holder_name': 'Stark', 'bank_name': 'XYZ','country': 'PAK', 'currency': 'PKR', 'code_details': {'pk_bank_details': {'account_number': '123456789', 'bank_bic':'TMICFBPK', 'bank_imd': '639390', iban' : 'PK76NBPA1234567890000999'}}} | {"key": "External Pay Out"} | <currency> | <deposit_amount> | <deposit_amount>  |

    Examples:
      | txn_amount | currency | country | status_code | request_origin | on_behalf_of | metadata                    | deposit_amount |
      | 10         | PKR      | PAK     | 200         | CASH_SERVICE   | CUSTOMER     | {"key": "External Pay Out"} | 100            |
      | 20         | PKR      | PAK     | 200         | CASH_SERVICE   | CUSTOMER     | {"key": "External Pay Out"} | 100            |

  Scenario Outline: I call TransferOut to transfer an amount between internal Hugohub customer profile account and external account from CASH_SERVICE on behalf of CUSTOMER and verify the transaction is settled

    Given I create account for CustomerProfile with customerProfileId PSCPID1 from <request_origin> on behalf of <on_behalf_of> with provider PAYSYS and expect the header status <status_code>
      | identifier                | currency   | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I verify CustomerProfile with id PSCPID1 has payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> exists with provider PAYSYS with values
      | account_id                | provider_id | currency   | account_status  | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | PAYSYS-PK   | <currency> | ACCOUNT_CREATED | <country> | <metadata> | <on_behalf_of> |

    Then I retrieve the payment account CustomerProfileAccountId1 from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I initiate a request to inquiry an account CustomerProfileAccountId1 to validate the account to initiate a credit payment of amount <deposit_amount> from initiator RAAST and expect the response status 0000
      | identifier                  | customer_profile_id | txn_info                                                                                                                                                                                                                                                                        |
      | InboundTitleFetchIdentifier | PSCPID1             | {"info":{"rrn":"InboundTitleFetchIdentifier","stan":"InboundTitleFetchIdentifier","txndate":"InboundTitleFetchIdentifier","txntime":"InboundTitleFetchIdentifier", "initiator":"RAAST"},"receiverinfo":{"to_account":"PK96HUGO0000003363390659"},"payment_info":{"amount":100}} |

    Given I deposit an amount of <deposit_amount> into account CustomerProfileAccountId1 using CreditPosting for customerProfileId PSCPID1
      | identifier              | customer_profile_id | txn_info                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
      | CreditPostingIdentifier | PSCPID1             | {"info":{"rrn":"CreditPostingIdentifier","stan":"CreditPostingIdentifier","txndate":"CreditPostingIdentifier","txntime":"CreditPostingIdentifier"},"receiverinfo":{"to_account":"PK96HUGO0000003363390659","to_account_title":"Waqas Nizam"},"senderinfo":{"sender_bank_iMD":"","sender_bank_bIC":"NBPBPKKA","from_account":"PK56AIIN1234567890000001","from_account_title":"Muhammad Ali","from_account_cnic":"1234512345671"},"payment_info":{"purpose_code":"0125","narration":"Integration Test transaction","amount":100,"instr_id":"TMIC230511125023876423","end_to_end_id":"1fc66b584e77-46e6-9dcb-fb12c00e7742","tx_id":"TMIC230511125023876423","msg_id":"CreditPostingIdentifier"}} |

    Then I wait until max time to verify master account CustomerProfileAccountId1 with an increased updated balance of <deposit_amount> for customerProfileId PSCPID1

    Then I initiate transfer out to transfer funds to an external account from CASH_SERVICE  and expect the header status <status_code> and status as TRANSACTION_SETTLED in Paysys
      | identifier | customer_profile_id | account_id                | txn_currency | txn_mode   | txn_amount   | purpose          | transfer_out_account_details                                                                                                                                                                                                                   | metadata                    | currency   | total_balance    | available_balance |
      | TxnId1     | PSCPID1             | CustomerProfileAccountId1 | PKR          | <txn_mode> | <txn_amount> | Internal Pay Out | {'account_holder_name': 'Stark', 'bank_name': 'XYZ','country': 'PAK', 'currency': 'PKR', 'code_details': {'pk_bank_details': {'account_number': '123456789', 'bank_bic':'TMICFBPK', 'bank_imd': '639390', iban : 'PK76NBPA1234567890000999'}}} | {"key": "External Pay Out"} | <currency> | <deposit_amount> | <deposit_amount>  |

    Examples:
      | txn_amount | currency | country | status_code | request_origin | on_behalf_of | metadata                    | deposit_amount | txn_mode  |
      | 10         | PKR      | PAK     | 200         | CASH_SERVICE   | CUSTOMER     | {"key": "External Pay Out"} | 100            | RAASTP2P  |
      | 20         | PKR      | PAK     | 200         | CASH_SERVICE   | CUSTOMER     | {"key": "External Pay Out"} | 100            | 1LINKIBFT |

  Scenario Outline: I call TransferOut to transfer an amount between internal Hugohub customer profile accounts using linked VirtualId from CASH_SERVICE on behalf of CUSTOMER and verify the transaction is settled

    Given I create account for CustomerProfile with customerProfileId PSCPID1 from <request_origin> on behalf of <on_behalf_of> with provider PAYSYS and expect the header status <status_code>
      | identifier                | currency   | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I verify CustomerProfile with id PSCPID1 has payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> exists with provider PAYSYS with values
      | account_id                | provider_id | currency | account_status  | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | PAYSYS-PK   | PKR      | ACCOUNT_CREATED | <country> | <metadata> | <on_behalf_of> |

    Given I create account for CustomerProfile with customerProfileId PSCPID1 from CASH_SERVICE on behalf of CUSTOMER with provider PAYSYS and expect the header status <status_code>
      | identifier                | currency   | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId2 | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account CustomerProfileAccountId2 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I verify CustomerProfile with id PSCPID1 has payment account CustomerProfileAccountId2 from <request_origin> on behalf of <on_behalf_of> exists with provider PAYSYS with values
      | account_id                | provider_id | currency | account_status  | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId2 | PAYSYS-PK   | PKR      | ACCOUNT_CREATED | <country> | <metadata> | <on_behalf_of> |

    Then I retrieve the payment account CustomerProfileAccountId1 from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I initiate a request to inquiry an account CustomerProfileAccountId1 to validate the account to initiate a credit payment of amount <deposit_amount> from initiator RAAST and expect the response status 0000
      | identifier                  | customer_profile_id | txn_info                                                                                                                                                                                                                                                                        |
      | InboundTitleFetchIdentifier | PSCPID1             | {"info":{"rrn":"InboundTitleFetchIdentifier","stan":"InboundTitleFetchIdentifier","txndate":"InboundTitleFetchIdentifier","txntime":"InboundTitleFetchIdentifier", "initiator":"RAAST"},"receiverinfo":{"to_account":"PK96HUGO0000003363390659"},"payment_info":{"amount":100}} |

    Given I deposit an amount of <deposit_amount> into account CustomerProfileAccountId1 using CreditPosting for customerProfileId PSCPID1
      | identifier              | customer_profile_id | txn_info                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
      | CreditPostingIdentifier | PSCPID1             | {"info":{"rrn":"CreditPostingIdentifier","stan":"CreditPostingIdentifier","txndate":"CreditPostingIdentifier","txntime":"CreditPostingIdentifier"},"receiverinfo":{"to_account":"PK96HUGO0000003363390659","to_account_title":"Waqas Nizam"},"senderinfo":{"sender_bank_iMD":"","sender_bank_bIC":"NBPBPKKA","from_account":"PK56AIIN1234567890000001","from_account_title":"Muhammad Ali","from_account_cnic":"1234512345671"},"payment_info":{"purpose_code":"0125","narration":"Integration Test transaction","amount":100,"instr_id":"TMIC230511125023876423","end_to_end_id":"1fc66b584e77-46e6-9dcb-fb12c00e7742","tx_id":"TMIC230511125023876423","msg_id":"CreditPostingIdentifier"}} |

    Then I wait until max time to verify master  account CustomerProfileAccountId1 with an increased updated balance of <deposit_amount> for customerProfileId PSCPID1 in Paysys

    Then I intiate a request to link VirtualId to the account from CASH_SERVICE and expect the header status <status_code> and status as LINK_SUCCESS in Paysys
      | account_id                | customer_profile_id | virtual_id_details                                                   |
      | CustomerProfileAccountId2 | PSCPID1             | { "virtual_id_type" : "MOBILE" , "virtual_id_value" : "9876543210" } |

    Then I initiate transfer out to transfer funds internally with below details from CASH_SERVICE and expect the header status <status_code> and status as TRANSACTION_SETTLED in Paysys
      | identifier | customer_profile_id | account_id                | receiver_account_id       | txn_mode   | txn_currency | txn_amount   | purpose          | transfer_out_account_details                                                                                                                                                                             | metadata                    | currency | total_balance    | available_balance |
      | TxnId1     | PSCPID1             | CustomerProfileAccountId1 | CustomerProfileAccountId2 | <txn_mode> | PKR          | <txn_amount> | Internal Pay Out | {"account_holder_name" : "XYZ","country" : "PAK","currency": "PKR","bank_name" : "HugoBank","code_details" : {'pk_bank_details' : { 'virtual_id_type' : 'MOBILE' , 'virtual_id_value' : "9876543210" }}} | {"key": "Internal Pay Out"} | PKR      | <deposit_amount> | <deposit_amount>  |

    Examples:
      | txn_amount | currency | country | status_code | request_origin | on_behalf_of | metadata                    | deposit_amount | txn_mode  |
      | 10         | PKR      | PAK     | 200         | CASH_SERVICE   | CUSTOMER     | {"key": "Internal Pay Out"} | 100            | RAASTP2P  |
      | 20         | PKR      | PAK     | 200         | CASH_SERVICE   | CUSTOMER     | {"key": "Internal Pay Out"} | 100            | 1LINKIBFT |

  Scenario Outline: I call TransferOut to transfer an amount between internal Hugohub customer profile accounts using VirtualId which is not linked from CASH_SERVICE on behalf of CUSTOMER and verify the transaction is failed

    Given I create account for CustomerProfile with customerProfileId PSCPID1 from <request_origin> on behalf of <on_behalf_of> with provider PAYSYS and expect the header status <status_code>
      | identifier                | currency   | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I verify CustomerProfile with id PSCPID1 has payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> exists with provider PAYSYS with values
      | account_id                | provider_id | currency   | account_status  | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | PAYSYS-PK   | <currency> | ACCOUNT_CREATED | <country> | <metadata> | <on_behalf_of> |

    Given I create account for CustomerProfile with customerProfileId PSCPID1 from CASH_SERVICE on behalf of CUSTOMER with provider PAYSYS and expect the header status <status_code>
      | identifier                | currency   | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId2 | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account CustomerProfileAccountId2 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I verify CustomerProfile with id PSCPID1 has payment account CustomerProfileAccountId2 from <request_origin> on behalf of <on_behalf_of> exists with provider PAYSYS with values
      | account_id                | provider_id | currency   | account_status  | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId2 | PAYSYS-PK   | <currency> | ACCOUNT_CREATED | <country> | <metadata> | <on_behalf_of> |

    Then I retrieve the payment account CustomerProfileAccountId1 from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I initiate a request to inquiry an account CustomerProfileAccountId1 to validate the account to initiate a credit payment of amount <deposit_amount> from initiator RAAST and expect the response status 0000
      | identifier                  | customer_profile_id | txn_info                                                                                                                                                                                                                                                                        |
      | InboundTitleFetchIdentifier | PSCPID1             | {"info":{"rrn":"InboundTitleFetchIdentifier","stan":"InboundTitleFetchIdentifier","txndate":"InboundTitleFetchIdentifier","txntime":"InboundTitleFetchIdentifier", "initiator":"RAAST"},"receiverinfo":{"to_account":"PK96HUGO0000003363390659"},"payment_info":{"amount":100}} |

    Given I deposit an amount of <deposit_amount> into account CustomerProfileAccountId1 using CreditPosting for customerProfileId PSCPID1
      | identifier              | customer_profile_id | txn_info                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
      | CreditPostingIdentifier | PSCPID1             | {"info":{"rrn":"CreditPostingIdentifier","stan":"CreditPostingIdentifier","txndate":"CreditPostingIdentifier","txntime":"CreditPostingIdentifier"},"receiverinfo":{"to_account":"PK96HUGO0000003363390659","to_account_title":"Waqas Nizam"},"senderinfo":{"sender_bank_iMD":"","sender_bank_bIC":"NBPBPKKA","from_account":"PK56AIIN1234567890000001","from_account_title":"Muhammad Ali","from_account_cnic":"1234512345671"},"payment_info":{"purpose_code":"0125","narration":"Integration Test transaction","amount":100,"instr_id":"TMIC230511125023876423","end_to_end_id":"1fc66b584e77-46e6-9dcb-fb12c00e7742","tx_id":"TMIC230511125023876423","msg_id":"CreditPostingIdentifier"}} |

    Then I wait until max time to verify master  account CustomerProfileAccountId1 with an increased updated balance of <deposit_amount> for customerProfileId PSCPID1 in Paysys

    Then I initiate transfer out to transfer funds internally with below details from CASH_SERVICE and expect the header status PTM_1305 and status as TRANSACTION_FAILED in Paysys
      | identifier | customer_profile_id | account_id                | receiver_account_id       | txn_mode   | txn_currency | txn_amount   | purpose          | transfer_out_account_details                                                                                                                                                                             | metadata                    | currency   | total_balance    | available_balance |
      | TxnId1     | PSCPID1             | CustomerProfileAccountId1 | CustomerProfileAccountId2 | <txn_mode> | PKR          | <txn_amount> | Internal Pay Out | {"account_holder_name" : "XYZ","country" : "PAK","currency": "PKR","bank_name" : "HugoBank","code_details" : {'pk_bank_details' : { 'virtual_id_type' : 'MOBILE' , 'virtual_id_value' : "9876543210" }}} | {"key": "Internal Pay Out"} | <currency> | <deposit_amount> | <deposit_amount>  |

    Examples:
      | txn_amount | currency | country | status_code | request_origin | on_behalf_of | metadata                    | deposit_amount | txn_mode  |
      | 10         | PKR      | PAK     | 200         | CASH_SERVICE   | CUSTOMER     | {"key": "Internal Pay Out"} | 100            | RAASTP2P  |
      | 20         | PKR      | PAK     | 200         | CASH_SERVICE   | CUSTOMER     | {"key": "Internal Pay Out"} | 100            | 1LINKIBFT |

  Scenario Outline: I call TransferOut to transfer an amount between internal Hugohub customer profile account and external account using virtualId from CASH_SERVICE on behalf of CUSTOMER and verify the transaction is settled

    Given I create account for CustomerProfile with customerProfileId PSCPID1 from <request_origin> on behalf of <on_behalf_of> with provider PAYSYS and expect the header status <status_code>
      | identifier                | currency   | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I verify CustomerProfile with id PSCPID1 has payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> exists with provider PAYSYS with values
      | account_id                | provider_id | currency   | account_status  | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | PAYSYS-PK   | <currency> | ACCOUNT_CREATED | <country> | <metadata> | <on_behalf_of> |

    Then I retrieve the payment account CustomerProfileAccountId1 from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I initiate a request to inquiry an account CustomerProfileAccountId1 to validate the account to initiate a credit payment of amount <deposit_amount> from initiator RAAST and expect the response status 0000
      | identifier                  | customer_profile_id | txn_info                                                                                                                                                                                                                                                                        |
      | InboundTitleFetchIdentifier | PSCPID1             | {"info":{"rrn":"InboundTitleFetchIdentifier","stan":"InboundTitleFetchIdentifier","txndate":"InboundTitleFetchIdentifier","txntime":"InboundTitleFetchIdentifier", "initiator":"RAAST"},"receiverinfo":{"to_account":"PK96HUGO0000003363390659"},"payment_info":{"amount":100}} |

    Given I deposit an amount of <deposit_amount> into account CustomerProfileAccountId1 using CreditPosting for customerProfileId PSCPID1
      | identifier              | customer_profile_id | txn_info                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
      | CreditPostingIdentifier | PSCPID1             | {"info":{"rrn":"CreditPostingIdentifier","stan":"CreditPostingIdentifier","txndate":"CreditPostingIdentifier","txntime":"CreditPostingIdentifier"},"receiverinfo":{"to_account":"PK96HUGO0000003363390659","to_account_title":"Waqas Nizam"},"senderinfo":{"sender_bank_iMD":"","sender_bank_bIC":"NBPBPKKA","from_account":"PK56AIIN1234567890000001","from_account_title":"Muhammad Ali","from_account_cnic":"1234512345671"},"payment_info":{"purpose_code":"0125","narration":"Integration Test transaction","amount":100,"instr_id":"TMIC230511125023876423","end_to_end_id":"1fc66b584e77-46e6-9dcb-fb12c00e7742","tx_id":"TMIC230511125023876423","msg_id":"CreditPostingIdentifier"}} |

    Then I wait until max time to verify master account CustomerProfileAccountId1 with an increased updated balance of <deposit_amount> for customerProfileId PSCPID1

    Then I initiate transfer out to transfer funds to an external account from CASH_SERVICE and expect the header status <status_code> and status as TRANSACTION_SETTLED in Paysys
      | identifier | customer_profile_id | account_id                | txn_currency | txn_mode   | txn_amount   | purpose          | transfer_out_account_details                                                                                                                                                                        | metadata                    | currency   | total_balance    | available_balance |
      | TxnId1     | PSCPID1             | CustomerProfileAccountId1 | PKR          | <txn_mode> | <txn_amount> | Internal Pay Out | {'account_holder_name': 'Stark', 'bank_name': 'XYZ','country': 'PAK', 'currency': 'PKR', 'code_details': {'pk_bank_details': { 'virtual_id_type' : 'MOBILE' , 'virtual_id_value' : "9976543210" }}} | {"key": "External Pay Out"} | <currency> | <deposit_amount> | <deposit_amount>  |

    Examples:
      | txn_amount | currency | country | status_code | request_origin | on_behalf_of | metadata                    | deposit_amount | txn_mode  |
      | 10         | PKR      | PAK     | 200         | CASH_SERVICE   | CUSTOMER     | {"key": "External Pay Out"} | 100            | RAASTP2P  |
      | 20         | PKR      | PAK     | 200         | CASH_SERVICE   | CUSTOMER     | {"key": "External Pay Out"} | 100            | 1LINKIBFT |

  Scenario Outline: I call Bill Payment to transfer an amount between internal Hugohub customer profile account and external biller of unpaid bill from CASH_SERVICE on behalf of CUSTOMER and verify the transaction is settled

    Given I create account for CustomerProfile with customerProfileId PSCPID1 from <request_origin> on behalf of <on_behalf_of> with provider PAYSYS and expect the header status <status_code>
      | identifier                | currency   | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I verify CustomerProfile with id PSCPID1 has payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> exists with provider PAYSYS with values
      | account_id                | provider_id | currency   | account_status  | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | PAYSYS-PK   | <currency> | ACCOUNT_CREATED | <country> | <metadata> | <on_behalf_of> |

    Then I retrieve the payment account CustomerProfileAccountId1 from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I initiate a request to inquiry an account CustomerProfileAccountId1 to validate the account to initiate a credit payment of amount <deposit_amount> from initiator RAAST and expect the response status 0000
      | identifier                  | customer_profile_id | txn_info                                                                                                                                                                                                                                                                        |
      | InboundTitleFetchIdentifier | PSCPID1             | {"info":{"rrn":"InboundTitleFetchIdentifier","stan":"InboundTitleFetchIdentifier","txndate":"InboundTitleFetchIdentifier","txntime":"InboundTitleFetchIdentifier", "initiator":"RAAST"},"receiverinfo":{"to_account":"PK96HUGO0000003363390659"},"payment_info":{"amount":100}} |

    Given I deposit an amount of <deposit_amount> into account CustomerProfileAccountId1 using CreditPosting for customerProfileId PSCPID1
      | identifier              | customer_profile_id | txn_info                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
      | CreditPostingIdentifier | PSCPID1             | {"info":{"rrn":"CreditPostingIdentifier","stan":"CreditPostingIdentifier","txndate":"CreditPostingIdentifier","txntime":"CreditPostingIdentifier"},"receiverinfo":{"to_account":"PK96HUGO0000003363390659","to_account_title":"Waqas Nizam"},"senderinfo":{"sender_bank_iMD":"","sender_bank_bIC":"NBPBPKKA","from_account":"PK56AIIN1234567890000001","from_account_title":"Muhammad Ali","from_account_cnic":"1234512345671"},"payment_info":{"purpose_code":"0125","narration":"Integration Test transaction","amount":100,"instr_id":"TMIC230511125023876423","end_to_end_id":"1fc66b584e77-46e6-9dcb-fb12c00e7742","tx_id":"TMIC230511125023876423","msg_id":"CreditPostingIdentifier"}} |

    Then I wait until max time to verify master account CustomerProfileAccountId1 with an increased updated balance of <deposit_amount> for customerProfileId PSCPID1

    Then I initiate bill payment to transfer funds to an external biller from CASH_SERVICE and expect the header status <status_code> and status as TRANSACTION_SETTLED in Paysys
      | identifier | customer_profile_id | account_id                | country | txn_currency | txn_amount   | purpose      | biller_details   | metadata                | total_balance    | available_balance |
      | TxnId1     | PSCPID1             | CustomerProfileAccountId1 | PAK     | PKR          | <txn_amount> | Bill Payment | <biller_details> | {"key": "Bill Payment"} | <deposit_amount> | <deposit_amount>  |

    Examples:
      | txn_amount | currency | country | status_code | request_origin | on_behalf_of | metadata                | deposit_amount | biller_details                                                                        |
      | 10         | PKR      | PAK     | 200         | CASH_SERVICE   | CUSTOMER     | {"key": "Bill Payment"} | 100            | {'biller_category': 'ELECTRICITY', 'biller_id': '1', 'consumer_id': '100987654321'}   |
      | 20         | PKR      | PAK     | 200         | CASH_SERVICE   | CUSTOMER     | {"key": "Bill Payment"} | 100            | {'biller_category': 'WATER', 'biller_id': '62', 'consumer_id': '100896745231'}        |
      | 20         | PKR      | PAK     | 200         | CASH_SERVICE   | CUSTOMER     | {"key": "Bill Payment"} | 100            | {'biller_category': 'GAS_PAYMENTS', 'biller_id': '25', 'consumer_id': '100678945123'} |
      | 20         | PKR      | PAK     | 200         | CASH_SERVICE   | CUSTOMER     | {"key": "Bill Payment"} | 100            | {'biller_category': 'MOBILE', 'biller_id': '68', 'consumer_id': '1001001001'}         |

  Scenario Outline: I call Bill Payment to transfer an amount between internal Hugohub customer profile account and external biller of paid bill from CASH_SERVICE on behalf of CUSTOMER and verify the transaction is rejected

    Given I create account for CustomerProfile with customerProfileId PSCPID1 from <request_origin> on behalf of <on_behalf_of> with provider PAYSYS and expect the header status <status_code>
      | identifier                | currency   | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I verify CustomerProfile with id PSCPID1 has payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> exists with provider PAYSYS with values
      | account_id                | provider_id | currency   | account_status  | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | PAYSYS-PK   | <currency> | ACCOUNT_CREATED | <country> | <metadata> | <on_behalf_of> |

    Then I retrieve the payment account CustomerProfileAccountId1 from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I initiate a request to inquiry an account CustomerProfileAccountId1 to validate the account to initiate a credit payment of amount <deposit_amount> from initiator RAAST and expect the response status 0000
      | identifier                  | customer_profile_id | txn_info                                                                                                                                                                                                                                                                        |
      | InboundTitleFetchIdentifier | PSCPID1             | {"info":{"rrn":"InboundTitleFetchIdentifier","stan":"InboundTitleFetchIdentifier","txndate":"InboundTitleFetchIdentifier","txntime":"InboundTitleFetchIdentifier", "initiator":"RAAST"},"receiverinfo":{"to_account":"PK96HUGO0000003363390659"},"payment_info":{"amount":100}} |

    Given I deposit an amount of <deposit_amount> into account CustomerProfileAccountId1 using CreditPosting for customerProfileId PSCPID1
      | identifier              | customer_profile_id | txn_info                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
      | CreditPostingIdentifier | PSCPID1             | {"info":{"rrn":"CreditPostingIdentifier","stan":"CreditPostingIdentifier","txndate":"CreditPostingIdentifier","txntime":"CreditPostingIdentifier"},"receiverinfo":{"to_account":"PK96HUGO0000003363390659","to_account_title":"Waqas Nizam"},"senderinfo":{"sender_bank_iMD":"","sender_bank_bIC":"NBPBPKKA","from_account":"PK56AIIN1234567890000001","from_account_title":"Muhammad Ali","from_account_cnic":"1234512345671"},"payment_info":{"purpose_code":"0125","narration":"Integration Test transaction","amount":100,"instr_id":"TMIC230511125023876423","end_to_end_id":"1fc66b584e77-46e6-9dcb-fb12c00e7742","tx_id":"TMIC230511125023876423","msg_id":"CreditPostingIdentifier"}} |

    Then I wait until max time to verify master account CustomerProfileAccountId1 with an increased updated balance of <deposit_amount> for customerProfileId PSCPID1

    Then I initiate bill payment to transfer funds to an external biller from CASH_SERVICE and expect the header status <status_code> and status as TRANSACTION_REJECTED in Paysys
      | identifier | customer_profile_id | account_id                | country | txn_currency | txn_amount   | purpose      | biller_details   | metadata                | total_balance    | available_balance |
      | TxnId1     | PSCPID1             | CustomerProfileAccountId1 | PAK     | PKR          | <txn_amount> | Bill Payment | <biller_details> | {"key": "Bill Payment"} | <deposit_amount> | <deposit_amount>  |

    Examples:
      | txn_amount | currency | country | status_code | request_origin | on_behalf_of | metadata                | deposit_amount | biller_details                                                                        |
      | 10         | PKR      | PAK     | 200         | CASH_SERVICE   | CUSTOMER     | {"key": "Bill Payment"} | 100            | {'biller_category': 'ELECTRICITY', 'biller_id': '1', 'consumer_id': '101987654321'}   |
      | 20         | PKR      | PAK     | 200         | CASH_SERVICE   | CUSTOMER     | {"key": "Bill Payment"} | 100            | {'biller_category': 'WATER', 'biller_id': '62', 'consumer_id': '101896745231'}        |
      | 20         | PKR      | PAK     | 200         | CASH_SERVICE   | CUSTOMER     | {"key": "Bill Payment"} | 100            | {'biller_category': 'GAS_PAYMENTS', 'biller_id': '25', 'consumer_id': '101678945123'} |
      | 20         | PKR      | PAK     | 200         | CASH_SERVICE   | CUSTOMER     | {"key": "Bill Payment"} | 100            | {'biller_category': 'MOBILE', 'biller_id': '68', 'consumer_id': '1011001001'}         |

  Scenario Outline: I call Bill Payment to transfer an amount between internal Hugohub customer profile account and external biller of unpaid bill from CASH_SERVICE on behalf of CUSTOMER and verify the transaction is rejected

    Given I create account for CustomerProfile with customerProfileId PSCPID1 from <request_origin> on behalf of <on_behalf_of> with provider PAYSYS and expect the header status <status_code>
      | identifier                | currency   | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I verify CustomerProfile with id PSCPID1 has payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> exists with provider PAYSYS with values
      | account_id                | provider_id | currency   | account_status  | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | PAYSYS-PK   | <currency> | ACCOUNT_CREATED | <country> | <metadata> | <on_behalf_of> |

    Then I retrieve the payment account CustomerProfileAccountId1 from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I initiate a request to inquiry an account CustomerProfileAccountId1 to validate the account to initiate a credit payment of amount <deposit_amount> from initiator RAAST and expect the response status 0000
      | identifier                  | customer_profile_id | txn_info                                                                                                                                                                                                                                                                        |
      | InboundTitleFetchIdentifier | PSCPID1             | {"info":{"rrn":"InboundTitleFetchIdentifier","stan":"InboundTitleFetchIdentifier","txndate":"InboundTitleFetchIdentifier","txntime":"InboundTitleFetchIdentifier", "initiator":"RAAST"},"receiverinfo":{"to_account":"PK96HUGO0000003363390659"},"payment_info":{"amount":100}} |

    Given I deposit an amount of <deposit_amount> into account CustomerProfileAccountId1 using CreditPosting for customerProfileId PSCPID1
      | identifier              | customer_profile_id | txn_info                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
      | CreditPostingIdentifier | PSCPID1             | {"info":{"rrn":"CreditPostingIdentifier","stan":"CreditPostingIdentifier","txndate":"CreditPostingIdentifier","txntime":"CreditPostingIdentifier"},"receiverinfo":{"to_account":"PK96HUGO0000003363390659","to_account_title":"Waqas Nizam"},"senderinfo":{"sender_bank_iMD":"","sender_bank_bIC":"NBPBPKKA","from_account":"PK56AIIN1234567890000001","from_account_title":"Muhammad Ali","from_account_cnic":"1234512345671"},"payment_info":{"purpose_code":"0125","narration":"Integration Test transaction","amount":100,"instr_id":"TMIC230511125023876423","end_to_end_id":"1fc66b584e77-46e6-9dcb-fb12c00e7742","tx_id":"TMIC230511125023876423","msg_id":"CreditPostingIdentifier"}} |

    Then I wait until max time to verify master account CustomerProfileAccountId1 with an increased updated balance of <deposit_amount> for customerProfileId PSCPID1

    Then I initiate bill payment to transfer funds to an external biller from CASH_SERVICE and expect the header status <status_code> and status as TRANSACTION_REJECTED in Paysys
      | identifier | customer_profile_id | account_id                | country | txn_currency | txn_amount   | purpose      | biller_details   | metadata                | total_balance    | available_balance |
      | TxnId1     | PSCPID1             | CustomerProfileAccountId1 | PAK     | PKR          | <txn_amount> | Bill Payment | <biller_details> | {"key": "Bill Payment"} | <deposit_amount> | <deposit_amount>  |

    Examples:
      | txn_amount | currency | country | status_code | request_origin | on_behalf_of | metadata                | deposit_amount | biller_details                                                                         |
      | 10         | PKR      | PAK     | 200         | CASH_SERVICE   | CUSTOMER     | {"key": "Bill Payment"} | 100            | {'biller_category': 'ELECTRICITY', 'biller_id': '1', 'consumer_id': '1000987654321'}   |
      | 20         | PKR      | PAK     | 200         | CASH_SERVICE   | CUSTOMER     | {"key": "Bill Payment"} | 100            | {'biller_category': 'WATER', 'biller_id': '62', 'consumer_id': '1000896745231'}        |
      | 20         | PKR      | PAK     | 200         | CASH_SERVICE   | CUSTOMER     | {"key": "Bill Payment"} | 100            | {'biller_category': 'GAS_PAYMENTS', 'biller_id': '25', 'consumer_id': '1000678945123'} |
      | 20         | PKR      | PAK     | 200         | CASH_SERVICE   | CUSTOMER     | {"key": "Bill Payment"} | 100            | {'biller_category': 'MOBILE', 'biller_id': '68', 'consumer_id': '10001001001'}         |

  Scenario Outline: I call Bill Payment to transfer an amount between internal Hugohub customer profile account and external biller of blocked bill from CASH_SERVICE on behalf of CUSTOMER and verify the transaction is rejected

    Given I create account for CustomerProfile with customerProfileId PSCPID1 from <request_origin> on behalf of <on_behalf_of> with provider PAYSYS and expect the header status <status_code>
      | identifier                | currency   | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I verify CustomerProfile with id PSCPID1 has payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> exists with provider PAYSYS with values
      | account_id                | provider_id | currency   | account_status  | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | PAYSYS-PK   | <currency> | ACCOUNT_CREATED | <country> | <metadata> | <on_behalf_of> |

    Then I retrieve the payment account CustomerProfileAccountId1 from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I initiate a request to inquiry an account CustomerProfileAccountId1 to validate the account to initiate a credit payment of amount <deposit_amount> from initiator RAAST and expect the response status 0000
      | identifier                  | customer_profile_id | txn_info                                                                                                                                                                                                                                                                        |
      | InboundTitleFetchIdentifier | PSCPID1             | {"info":{"rrn":"InboundTitleFetchIdentifier","stan":"InboundTitleFetchIdentifier","txndate":"InboundTitleFetchIdentifier","txntime":"InboundTitleFetchIdentifier", "initiator":"RAAST"},"receiverinfo":{"to_account":"PK96HUGO0000003363390659"},"payment_info":{"amount":100}} |

    Given I deposit an amount of <deposit_amount> into account CustomerProfileAccountId1 using CreditPosting for customerProfileId PSCPID1
      | identifier              | customer_profile_id | txn_info                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
      | CreditPostingIdentifier | PSCPID1             | {"info":{"rrn":"CreditPostingIdentifier","stan":"CreditPostingIdentifier","txndate":"CreditPostingIdentifier","txntime":"CreditPostingIdentifier"},"receiverinfo":{"to_account":"PK96HUGO0000003363390659","to_account_title":"Waqas Nizam"},"senderinfo":{"sender_bank_iMD":"","sender_bank_bIC":"NBPBPKKA","from_account":"PK56AIIN1234567890000001","from_account_title":"Muhammad Ali","from_account_cnic":"1234512345671"},"payment_info":{"purpose_code":"0125","narration":"Integration Test transaction","amount":100,"instr_id":"TMIC230511125023876423","end_to_end_id":"1fc66b584e77-46e6-9dcb-fb12c00e7742","tx_id":"TMIC230511125023876423","msg_id":"CreditPostingIdentifier"}} |

    Then I wait until max time to verify master account CustomerProfileAccountId1 with an increased updated balance of <deposit_amount> for customerProfileId PSCPID1

    Then I initiate bill payment to transfer funds to an external biller from CASH_SERVICE and expect the header status <status_code> and status as TRANSACTION_REJECTED in Paysys
      | identifier | customer_profile_id | account_id                | country | txn_currency | txn_amount   | purpose      | biller_details   | metadata                | total_balance    | available_balance |
      | TxnId1     | PSCPID1             | CustomerProfileAccountId1 | PAK     | PKR          | <txn_amount> | Bill Payment | <biller_details> | {"key": "Bill Payment"} | <deposit_amount> | <deposit_amount>  |

    Examples:
      | txn_amount | currency | country | status_code | request_origin | on_behalf_of | metadata                | deposit_amount | biller_details                                                                        |
      | 10         | PKR      | PAK     | 200         | CASH_SERVICE   | CUSTOMER     | {"key": "Bill Payment"} | 100            | {'biller_category': 'ELECTRICITY', 'biller_id': '1', 'consumer_id': '103987654321'}   |
      | 20         | PKR      | PAK     | 200         | CASH_SERVICE   | CUSTOMER     | {"key": "Bill Payment"} | 100            | {'biller_category': 'WATER', 'biller_id': '62', 'consumer_id': '103896745231'}        |
      | 20         | PKR      | PAK     | 200         | CASH_SERVICE   | CUSTOMER     | {"key": "Bill Payment"} | 100            | {'biller_category': 'GAS_PAYMENTS', 'biller_id': '25', 'consumer_id': '103678945123'} |
      | 20         | PKR      | PAK     | 200         | CASH_SERVICE   | CUSTOMER     | {"key": "Bill Payment"} | 100            | {'biller_category': 'MOBILE', 'biller_id': '68', 'consumer_id': '1031001001'}         |
