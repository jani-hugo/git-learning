Feature: Payment service transaction, payments and deposit scenarios for provider DBS

  Background: Setup CustomerProfile and EndCustomerProfile profile onto Payment Service

    #CustomerProfile verifying and Onboarding on to payment service on given providers
    Given In Payment Service, I set and verify customer PSCID1, customer profile PSCPID1 on below providers from CASH_SERVICE on behalf of CUSTOMER and expect status 200 in the context
      | provider_name |
      | DBS Bank Ltd  |

    Then I wait until max time to verify CustomerProfile PSCPID1 on behalf of CASH_SERVICE onboard status as ONBOARD_SUCCESS onto Payment Service

    Then I create below End-Customer-Profile
      | customer_identifier | customer_profile_identifier | end_customer_profile_identifier | first_name | last_name | region | email            | phone_number |
      | PSCID1              | PSCPID1                     | ECPID1                          | Kiyotaka   | Ayanokōji | SG     | KA@gmail.com.com | 00000000     |

    Then I verify End-Customer-Profile exist with values
      | customer_profile_identifier | end_customer_profile_identifier | first_name | last_name | email            | phone_number | status |
      | PSCPID1                     | ECPID1                          | Kiyotaka   | Ayanokōji | KA@gmail.com.com | 00000000     | ACTIVE |

    # EndCustomerProfile Onboarding
    Given I onboard EndCustomerProfile ECPID1 of CustomerProfile PSCPID1 on payment service on below providers from CASH_SERVICE on behalf of CUSTOMER and expect status 200
      | provider_name |
      | DBS Bank Ltd  |

    Then I wait until max time to verify EndCustomerProfile ECPID1 of CustomerProfile PSCPID1 from CASH_SERVICE onboard status as ONBOARD_SUCCESS onto Payment Service

  Scenario Outline: I call TransferOut to transfer an amount between internal Hugohub customer profile accounts from CASH_SERVICE on behalf of CUSTOMER and verify the transaction is settled

    Given I create account for CustomerProfile with customerProfileId PSCPID1 from <request_origin> on behalf of <on_behalf_of> with provider DBS Bank Ltd and expect the header status <status_code>
      | identifier                | currency   | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID1

    Then I verify CustomerProfile with id PSCPID1 has payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> exists with provider <bank_name> with values
      | account_id                | provider_id | currency | account_status  | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | DBS-SG      | SGD      | ACCOUNT_CREATED | <country> | <metadata> | <on_behalf_of> |

    Given I create account for CustomerProfile with customerProfileId PSCPID1 from CASH_SERVICE on behalf of CUSTOMER with provider DBS Bank Ltd and expect the header status <status_code>
      | identifier                | currency   | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId2 | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account CustomerProfileAccountId2 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID1

    Then I verify CustomerProfile with id PSCPID1 has payment account CustomerProfileAccountId2 from <request_origin> on behalf of <on_behalf_of> exists with provider <bank_name> with values
      | account_id                | provider_id | currency | account_status  | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId2 | DBS-SG      | SGD      | ACCOUNT_CREATED | <country> | <metadata> | <on_behalf_of> |

    Then I retrieve the payment account CustomerProfileAccountId1 from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID1

    Given I deposit an amount of <deposit_amount> into account CustomerProfileAccountId1 using IDN for customerProfileId PSCPID1
      | identifier    | customer_profile_id | header                                                                                         | txn_info                                                                                                                                                                                                                                                                                                                                                  |
      | IDNIdentifier | PSCPID1             | {"msgId":"IDNIdentifier","orgId":"ATLCONS3","ctry":"SG","timeStamp":"2023-01-06T09:48:59.457"} | {"amt_dtls": {"txn_amt": "150","txn_ccy": "SGD"},"customer_reference": "IDNIdentifier","sender_party": { "name": "HUGO","sender_bank_id": "DBSSSGSGXXX"},"txn_ref_id": "IDNIdentifier","receiving_party": {"account_no":"88532600026958397","name": "ATLAS CONSOLIDATED PTE. LTD."},"txn_type":"FAST","txn_date": "2023-01-06","value_dt": "2023-01-06" } |

    Then I wait until max time to verify master account CustomerProfileAccountId1 with an increased updated balance of <deposit_amount> for customerProfileId PSCPID1

    Then I initiate transfer out to transfer funds with below details from CASH_SERVICE and expect the header status <status_code> and status as TRANSACTION_SETTLED
      | identifier | customer_profile_id | account_id                | receiver_account_id       | txn_currency | txn_amount   | purpose          | txn_mode | transfer_out_account_details                                                                                                                                                                       | metadata                    | currency | total_balance    | available_balance |
      | TxnId1     | PSCPID1             | CustomerProfileAccountId1 | CustomerProfileAccountId2 | SGD          | <txn_amount> | Internal Pay Out | FAST     | {'account_holder_name': 'Stark', 'bank_name': 'DBS Bank Ltd','country': 'SGP', 'currency': 'SGD', 'code_details': {'sg_bank_details': {'account_number': '123456789', 'swift_bic':'DBSSSGSGXXX'}}} | {"key": "Internal Pay Out"} | SGD      | <deposit_amount> | <deposit_amount>  |

    Examples:
      | txn_amount | currency | country | bank_name    | status_code | request_origin | on_behalf_of | metadata                    | deposit_amount |
      | 10         | SGD      | SGP     | DBS Bank Ltd | 200         | CASH_SERVICE   | CUSTOMER     | {"key": "Internal Pay Out"} | 100            |
      | 20         | SGD      | SGP     | DBS Bank Ltd | 200         | CASH_SERVICE   | CUSTOMER     | {"key": "Internal Pay Out"} | 100            |


  Scenario Outline: I call TransferOut to transfer an amount between internal Hugohub end customer profile accounts from CASH_SERVICE on behalf of CUSTOMER and verify the transaction is settled

    Given I create account for EndCustomerProfile with id ECPID1 for CustomerProfile PSCPID1 from <request_origin> on behalf of <on_behalf_of> with provider DBS Bank Ltd and expect the header status <status_code>
      | identifier                   | currency   | country   | metadata   | on_behalf_of   |
      | EndCustomerProfileAccountId1 | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account EndCustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID1

    Then I verify EndCustomerProfile with id ECPID1 for CustomerProfile PSCPID1 has payment account AccountId from <request_origin> on behalf of <on_behalf_of> exists with provider <bank_name> with values
      | identifier                   | provider_id | currency | country | account_status  | metadata   | on_behalf_of   |
      | EndCustomerProfileAccountId1 | DBS-SG      | SGD      | SGP     | ACCOUNT_CREATED | <metadata> | <on_behalf_of> |

    Given I create account for EndCustomerProfile with id ECPID1 for CustomerProfile PSCPID1 from <request_origin> on behalf of <on_behalf_of> with provider DBS Bank Ltd and expect the header status <status_code>
      | identifier                   | currency   | country   | metadata   | on_behalf_of   |
      | EndCustomerProfileAccountId2 | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account EndCustomerProfileAccountId2 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID1

    Then I verify EndCustomerProfile with id ECPID1 for CustomerProfile PSCPID1 has payment account AccountId from <request_origin> on behalf of <on_behalf_of> exists with provider <bank_name> with values
      | identifier                   | provider_id | currency | country | account_status  | metadata   | on_behalf_of   |
      | EndCustomerProfileAccountId2 | DBS-SG      | SGD      | SGP     | ACCOUNT_CREATED | <metadata> | <on_behalf_of> |

    Then I retrieve the payment account EndCustomerProfileAccountId1 from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID1

    Given I deposit an amount of <deposit_amount> into account EndCustomerProfileAccountId1 using ICN for customerProfileId PSCPID1
      | identifier    | customer_profile_id | header                                                                                         | txn_info                                                                                                                                                                                                                                                                                                                                                  |
      | ICNIdentifier | PSCPID1             | {"msgId":"ICNIdentifier","orgId":"ATLCONS3","ctry":"SG","timeStamp":"2023-11-28T11:00:00.000"} | {"amt_dtls": {"txn_amt": "100","txn_ccy": "SGD"},"customer_reference": "ICNIdentifier","sender_party": { "name": "HUGO","sender_bank_id": "DBSSSGSGXXX"},"txn_ref_id": "ICNIdentifier","receiving_party": {"account_no":"88532600026958397","name": "ATLAS CONSOLIDATED PTE. LTD."},"txn_type":"FAST","txn_date": "2023-11-28","value_dt": "2023-11-28" } |

    Then I wait until max time to verify master account EndCustomerProfileAccountId1 with an increased updated balance of <deposit_amount> for customerProfileId PSCPID1

    Then I initiate transfer out to transfer funds with below details from CASH_SERVICE and expect the header status <status_code> and status as TRANSACTION_SETTLED
      | identifier | customer_profile_id | account_id                   | receiver_account_id          | txn_currency | txn_amount   | purpose          | txn_mode | transfer_out_account_details                                                                                                                                                                       | metadata                    | currency | total_balance    | available_balance |
      | TxnId1     | PSCPID1             | EndCustomerProfileAccountId1 | EndCustomerProfileAccountId2 | SGD          | <txn_amount> | Internal Pay Out | FAST     | {'account_holder_name': 'Stark', 'bank_name': 'DBS Bank Ltd','country': 'SGP', 'currency': 'SGD', 'code_details': {'sg_bank_details': {'account_number': '123456789', 'swift_bic':'DBSSSGSGXXX'}}} | {"key": "Internal Pay Out"} | SGD      | <deposit_amount> | <deposit_amount>  |

    Examples:
      | txn_amount | currency | country | bank_name    | status_code | request_origin | on_behalf_of | metadata                    | deposit_amount |
      | 10         | SGD      | SGP     | DBS Bank Ltd | 200         | CASH_SERVICE   | CUSTOMER     | {"key": "Internal Pay Out"} | 100            |
      | 20         | SGD      | SGP     | DBS Bank Ltd | 200         | CASH_SERVICE   | CUSTOMER     | {"key": "Internal Pay Out"} | 100            |

  Scenario Outline: I call TransferOut to transfer an amount between internal Hugohub customer profile and end customer profile accounts from CASH_SERVICE on behalf of CUSTOMER and verify the transaction is settled

    Given I create account for CustomerProfile with customerProfileId PSCPID1 from <request_origin> on behalf of <on_behalf_of> with provider DBS Bank Ltd and expect the header status <status_code>
      | identifier                | currency   | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID1

    Then I verify CustomerProfile with id PSCPID1 has payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> exists with provider <bank_name> with values
      | account_id                | provider_id | currency | account_status  | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | DBS-SG      | SGD      | ACCOUNT_CREATED | <country> | <metadata> | <on_behalf_of> |

    Given I create account for EndCustomerProfile with id ECPID1 for CustomerProfile PSCPID1 from <request_origin> on behalf of <on_behalf_of> with provider DBS Bank Ltd and expect the header status <status_code>
      | identifier                   | currency   | country   | metadata   | on_behalf_of   |
      | EndCustomerProfileAccountId1 | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account EndCustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID1

    Then I verify EndCustomerProfile with id ECPID1 for CustomerProfile PSCPID1 has payment account AccountId from <request_origin> on behalf of <on_behalf_of> exists with provider <bank_name> with values
      | identifier                   | provider_id | currency | country | account_status  | metadata   | on_behalf_of   |
      | EndCustomerProfileAccountId1 | DBS-SG      | SGD      | SGP     | ACCOUNT_CREATED | <metadata> | <on_behalf_of> |

    Then I retrieve the payment account CustomerProfileAccountId1 from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID1

    Given I deposit an amount of <deposit_amount> into account CustomerProfileAccountId1 using ICN for customerProfileId PSCPID1
      | identifier    | customer_profile_id | header                                                                                         | txn_info                                                                                                                                                                                                                                                                                                                                                  |
      | ICNIdentifier | PSCPID1             | {"msgId":"ICNIdentifier","orgId":"ATLCONS3","ctry":"SG","timeStamp":"2023-11-28T11:00:00.000"} | {"amt_dtls": {"txn_amt": "100","txn_ccy": "SGD"},"customer_reference": "ICNIdentifier","sender_party": { "name": "HUGO","sender_bank_id": "DBSSSGSGXXX"},"txn_ref_id": "ICNIdentifier","receiving_party": {"account_no":"88532600026958397","name": "ATLAS CONSOLIDATED PTE. LTD."},"txn_type":"FAST","txn_date": "2023-11-28","value_dt": "2023-11-28" } |

    Then I wait until max time to verify master account CustomerProfileAccountId1 with an increased updated balance of <deposit_amount> for customerProfileId PSCPID1

    Then I initiate transfer out to transfer funds with below details from CASH_SERVICE and expect the header status <status_code> and status as TRANSACTION_SETTLED
      | identifier | customer_profile_id | account_id                | receiver_account_id          | txn_currency | txn_amount   | purpose          | txn_mode | transfer_out_account_details                                                                                                                                                                       | metadata                    | currency | total_balance    | available_balance |
      | TxnId1     | PSCPID1             | CustomerProfileAccountId1 | EndCustomerProfileAccountId1 | SGD          | <txn_amount> | Internal Pay Out | FAST     | {'account_holder_name': 'Stark', 'bank_name': 'DBS Bank Ltd','country': 'SGP', 'currency': 'SGD', 'code_details': {'sg_bank_details': {'account_number': '123456789', 'swift_bic':'DBSSSGSGXXX'}}} | {"key": "Internal Pay Out"} | SGD      | <deposit_amount> | <deposit_amount>  |

    Examples:
      | txn_amount | currency | country | bank_name    | status_code | request_origin | on_behalf_of | metadata                    | deposit_amount |
      | 10         | SGD      | SGP     | DBS Bank Ltd | 200         | CASH_SERVICE   | CUSTOMER     | {"key": "Internal Pay Out"} | 100            |
      | 20         | SGD      | SGP     | DBS Bank Ltd | 200         | CASH_SERVICE   | CUSTOMER     | {"key": "Internal Pay Out"} | 100            |

  Scenario Outline: I call TransferOut to transfer an amount between internal Hugohub end customer profile and customer profile accounts from CASH_SERVICE on behalf of CUSTOMER and verify the transaction is settled

    Given I create account for EndCustomerProfile with id ECPID1 for CustomerProfile PSCPID1 from <request_origin> on behalf of <on_behalf_of> with provider DBS Bank Ltd and expect the header status <status_code>
      | identifier                   | currency   | country   | metadata   | on_behalf_of   |
      | EndCustomerProfileAccountId1 | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account EndCustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID1

    Then I verify EndCustomerProfile with id ECPID1 for CustomerProfile PSCPID1 has payment account AccountId from <request_origin> on behalf of <on_behalf_of> exists with provider <bank_name> with values
      | identifier                   | provider_id | currency | country | account_status  | metadata   | on_behalf_of   |
      | EndCustomerProfileAccountId1 | DBS-SG      | SGD      | SGP     | ACCOUNT_CREATED | <metadata> | <on_behalf_of> |

    Given I create account for CustomerProfile with customerProfileId PSCPID1 from <request_origin> on behalf of <on_behalf_of> with provider DBS Bank Ltd and expect the header status <status_code>
      | identifier                | currency   | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID1

    Then I verify CustomerProfile with id PSCPID1 has payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> exists with provider <bank_name> with values
      | account_id                | provider_id | currency | account_status  | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | DBS-SG      | SGD      | ACCOUNT_CREATED | <country> | <metadata> | <on_behalf_of> |

    Then I retrieve the payment account EndCustomerProfileAccountId1 from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID1

    Given I deposit an amount of <deposit_amount> into account EndCustomerProfileAccountId1 using ICN for customerProfileId PSCPID1
      | identifier    | customer_profile_id | header                                                                                         | txn_info                                                                                                                                                                                                                                                                                                                                                  |
      | ICNIdentifier | PSCPID1             | {"msgId":"ICNIdentifier","orgId":"ATLCONS3","ctry":"SG","timeStamp":"2023-11-28T11:00:00.000"} | {"amt_dtls": {"txn_amt": "100","txn_ccy": "SGD"},"customer_reference": "ICNIdentifier","sender_party": { "name": "HUGO","sender_bank_id": "DBSSSGSGXXX"},"txn_ref_id": "ICNIdentifier","receiving_party": {"account_no":"88532600026958397","name": "ATLAS CONSOLIDATED PTE. LTD."},"txn_type":"FAST","txn_date": "2023-11-28","value_dt": "2023-11-28" } |

    Then I wait until max time to verify master account EndCustomerProfileAccountId1 with an increased updated balance of <deposit_amount> for customerProfileId PSCPID1

    Then I initiate transfer out to transfer funds with below details from CASH_SERVICE and expect the header status <status_code> and status as TRANSACTION_SETTLED
      | identifier | customer_profile_id | account_id                   | receiver_account_id       | txn_currency | txn_amount   | purpose          | txn_mode | transfer_out_account_details                                                                                                                                                                       | metadata                    | currency | total_balance    | available_balance |
      | TxnId1     | PSCPID1             | EndCustomerProfileAccountId1 | CustomerProfileAccountId1 | SGD          | <txn_amount> | Internal Pay Out | FAST     | {'account_holder_name': 'Stark', 'bank_name': 'DBS Bank Ltd','country': 'SGP', 'currency': 'SGD', 'code_details': {'sg_bank_details': {'account_number': '123456789', 'swift_bic':'DBSSSGSGXXX'}}} | {"key": "Internal Pay Out"} | SGD      | <deposit_amount> | <deposit_amount>  |

    Examples:
      | txn_amount | currency | country | bank_name    | status_code | request_origin | on_behalf_of | metadata                    | deposit_amount |
      | 10         | SGD      | SGP     | DBS Bank Ltd | 200         | CASH_SERVICE   | CUSTOMER     | {"key": "Internal Pay Out"} | 100            |
      | 20         | SGD      | SGP     | DBS Bank Ltd | 200         | CASH_SERVICE   | CUSTOMER     | {"key": "Internal Pay Out"} | 100            |

  Scenario Outline: I call TransferOut to transfer an amount between internal Hugohub customer profile account and external account where TxnMode is not passed from CASH_SERVICE on behalf of CUSTOMER and verify the transaction is settled

    Given I create account for CustomerProfile with customerProfileId PSCPID1 from <request_origin> on behalf of <on_behalf_of> with provider DBS Bank Ltd and expect the header status <status_code>
      | identifier                | currency   | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID1

    Then I verify CustomerProfile with id PSCPID1 has payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> exists with provider <bank_name> with values
      | account_id                | provider_id | currency | account_status  | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | DBS-SG      | SGD      | ACCOUNT_CREATED | <country> | <metadata> | <on_behalf_of> |

    Then I retrieve the payment account CustomerProfileAccountId1 from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID1

    Given I deposit an amount of <deposit_amount> into account CustomerProfileAccountId1 using ICN for customerProfileId PSCPID1
      | identifier    | customer_profile_id | header                                                                                         | txn_info                                                                                                                                                                                                                                                                                                                                                  |
      | ICNIdentifier | PSCPID1             | {"msgId":"ICNIdentifier","orgId":"ATLCONS3","ctry":"SG","timeStamp":"2023-11-28T11:00:00.000"} | {"amt_dtls": {"txn_amt": "100","txn_ccy": "SGD"},"customer_reference": "ICNIdentifier","sender_party": { "name": "HUGO","sender_bank_id": "DBSSSGSGXXX"},"txn_ref_id": "ICNIdentifier","receiving_party": {"account_no":"88532600026958397","name": "ATLAS CONSOLIDATED PTE. LTD."},"txn_type":"FAST","txn_date": "2023-11-28","value_dt": "2023-11-28" } |

    Then I wait until max time to verify master account CustomerProfileAccountId1 with an increased updated balance of <deposit_amount> for customerProfileId PSCPID1

    Then I initiate transfer out to transfer funds to an external account from CASH_SERVICE and expect the header status <status_code> and status as TRANSACTION_PENDING
      | identifier | customer_profile_id | account_id                | txn_currency | txn_amount   | purpose          | transfer_out_account_details                                                                                                                                                                       | metadata                    | currency | total_balance    | available_balance |
      | TxnId1     | PSCPID1             | CustomerProfileAccountId1 | SGD          | <txn_amount> | Internal Pay Out | {'account_holder_name': 'Stark', 'bank_name': 'DBS Bank Ltd','country': 'SGP', 'currency': 'SGD', 'code_details': {'sg_bank_details': {'account_number': '123456789', 'swift_bic':'DBSSSGSGXXX'}}} | {"key": "External Pay Out"} | SGD      | <deposit_amount> | <deposit_amount>  |

    Then I wait until max time to verify the transaction TxnId1 status as TRANSACTION_SETTLED for customerProfileId PSCPID1 from CASH_SERVICE

    Examples:
      | txn_amount | currency | country | bank_name    | status_code | request_origin | on_behalf_of | metadata                    | deposit_amount |
      | 10         | SGD      | SGP     | DBS Bank Ltd | 200         | CASH_SERVICE   | CUSTOMER     | {"key": "External Pay Out"} | 100            |
      | 20         | SGD      | SGP     | DBS Bank Ltd | 200         | CASH_SERVICE   | CUSTOMER     | {"key": "External Pay Out"} | 100            |


  Scenario Outline: I call TransferOut to transfer an amount between internal Hugohub customer profile account and external account from CASH_SERVICE on behalf of CUSTOMER and verify the transaction is settled --- ACT

    Given I create account for CustomerProfile with customerProfileId PSCPID1 from <request_origin> on behalf of <on_behalf_of> with provider DBS Bank Ltd and expect the header status <status_code>
      | identifier                | currency   | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID1

    Then I verify CustomerProfile with id PSCPID1 has payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> exists with provider <bank_name> with values
      | account_id                | provider_id | currency | account_status  | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | DBS-SG      | SGD      | ACCOUNT_CREATED | <country> | <metadata> | <on_behalf_of> |

    Then I retrieve the payment account CustomerProfileAccountId1 from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID1

    Given I deposit an amount of <deposit_amount> into account CustomerProfileAccountId1 using ICN for customerProfileId PSCPID1
      | identifier    | customer_profile_id | header                                                                                         | txn_info                                                                                                                                                                                                                                                                                                                                                  |
      | ICNIdentifier | PSCPID1             | {"msgId":"ICNIdentifier","orgId":"ATLCONS3","ctry":"SG","timeStamp":"2023-11-28T11:00:00.000"} | {"amt_dtls": {"txn_amt": "100","txn_ccy": "SGD"},"customer_reference": "ICNIdentifier","sender_party": { "name": "HUGO","sender_bank_id": "DBSSSGSGXXX"},"txn_ref_id": "ICNIdentifier","receiving_party": {"account_no":"88532600026958397","name": "ATLAS CONSOLIDATED PTE. LTD."},"txn_type":"FAST","txn_date": "2023-11-28","value_dt": "2023-11-28" } |

    Then I wait until max time to verify master account CustomerProfileAccountId1 with an increased updated balance of <deposit_amount> for customerProfileId PSCPID1

    Then I initiate transfer out to transfer funds to an external account from CASH_SERVICE and expect the header status <status_code> and status as TRANSACTION_PENDING
      | identifier | customer_profile_id | account_id                | txn_currency | txn_amount   | purpose          | txn_mode | transfer_out_account_details                                                                                                                                                                       | metadata                    | currency | total_balance    | available_balance |
      | TxnId1     | PSCPID1             | CustomerProfileAccountId1 | SGD          | <txn_amount> | Internal Pay Out | FAST     | {'account_holder_name': 'Stark', 'bank_name': 'DBS Bank Ltd','country': 'SGP', 'currency': 'SGD', 'code_details': {'sg_bank_details': {'account_number': '123456789', 'swift_bic':'DBSSSGSGXXX'}}} | {"key": "External Pay Out"} | SGD      | <deposit_amount> | <deposit_amount>  |

    Then I wait until max time to verify the transaction TxnId1 status as TRANSACTION_SETTLED for customerProfileId PSCPID1 from CASH_SERVICE

    Examples:
      | txn_amount | currency | country | bank_name    | status_code | request_origin | on_behalf_of | metadata                        | deposit_amount |
      | 10         | SGD      | SGP     | DBS Bank Ltd | 200         | CASH_SERVICE   | CUSTOMER     | {"key": "ACT External Pay Out"} | 100            |
      | 20         | SGD      | SGP     | DBS Bank Ltd | 200         | CASH_SERVICE   | CUSTOMER     | {"key": "ACT External Pay Out"} | 100            |

  Scenario Outline: I call TransferOut to transfer an amount between internal Hugohub customer profile account and external account from CASH_SERVICE on behalf of CUSTOMER and verify the transaction is settled --- FAST

    Given I create account for CustomerProfile with customerProfileId PSCPID1 from <request_origin> on behalf of <on_behalf_of> with provider DBS Bank Ltd and expect the header status <status_code>
      | identifier                | currency   | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID1

    Then I verify CustomerProfile with id PSCPID1 has payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> exists with provider <bank_name> with values
      | account_id                | provider_id | currency | account_status  | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | DBS-SG      | SGD      | ACCOUNT_CREATED | <country> | <metadata> | <on_behalf_of> |

    Then I retrieve the payment account CustomerProfileAccountId1 from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID1

    Given I deposit an amount of <deposit_amount> into account CustomerProfileAccountId1 using ICN for customerProfileId PSCPID1
      | identifier    | customer_profile_id | header                                                                                         | txn_info                                                                                                                                                                                                                                                                                                                                                  |
      | ICNIdentifier | PSCPID1             | {"msgId":"ICNIdentifier","orgId":"ATLCONS3","ctry":"SG","timeStamp":"2023-11-28T11:00:00.000"} | {"amt_dtls": {"txn_amt": "100","txn_ccy": "SGD"},"customer_reference": "ICNIdentifier","sender_party": { "name": "HUGO","sender_bank_id": "DBSSSGSGXXX"},"txn_ref_id": "ICNIdentifier","receiving_party": {"account_no":"88532600026958397","name": "ATLAS CONSOLIDATED PTE. LTD."},"txn_type":"FAST","txn_date": "2023-11-28","value_dt": "2023-11-28" } |

    Then I wait until max time to verify master account CustomerProfileAccountId1 with an increased updated balance of <deposit_amount> for customerProfileId PSCPID1

    Then I initiate transfer out to transfer funds to an external account from CASH_SERVICE and expect the header status <status_code> and status as TRANSACTION_PENDING
      | identifier | customer_profile_id | account_id                | txn_currency | txn_amount   | purpose          | txn_mode | transfer_out_account_details                                                                                                                                                                       | metadata                    | currency | total_balance    | available_balance |
      | TxnId1     | PSCPID1             | CustomerProfileAccountId1 | SGD          | <txn_amount> | Internal Pay Out | FAST     | {'account_holder_name': 'Stark', 'bank_name': 'DBS Bank Ltd','country': 'SGP', 'currency': 'SGD', 'code_details': {'sg_bank_details': {'account_number': '123456789', 'swift_bic':'HSBCSGSGXXX'}}} | {"key": "External Pay Out"} | SGD      | <deposit_amount> | <deposit_amount>  |

    Then I wait until max time to verify the transaction TxnId1 status as TRANSACTION_SETTLED for customerProfileId PSCPID1 from CASH_SERVICE

    Examples:
      | txn_amount | currency | country | bank_name    | status_code | request_origin | on_behalf_of | metadata                         | deposit_amount |
      | 10         | SGD      | SGP     | DBS Bank Ltd | 200         | CASH_SERVICE   | CUSTOMER     | {"key": "FAST External Pay Out"} | 100            |
      | 20         | SGD      | SGP     | DBS Bank Ltd | 200         | CASH_SERVICE   | CUSTOMER     | {"key": "FAST External Pay Out"} | 100            |


  Scenario Outline: I call TransferOut to transfer an amount between internal Hugohub customer profile accounts from CASH_SERVICE on behalf of CUSTOMER with insufficient balance and verify the transaction is failed

    Given I create below Customer
      | customer_identifier | name | date                 |
      | PSCID3              | hugo | 2022-12-28T00:00:00Z |

    Then I create below Customer-Profile
      | customer_identifier | customer_profile_identifier | region | name  | email          | phone_number |
      | PSCID3              | PSCPID3                     | SG     | Stark | hugo@atlas.com | 8989548747   |

    Then I verify Customer-Profile exist with values
      | customer_identifier | customer_profile_identifier | region | name  | email          | phone_number | status |
      | PSCID3              | PSCPID3                     | SG     | Stark | hugo@atlas.com | 8989548747   | ACTIVE |

    Given I onboard CustomerProfile PSCPID3 with customerId PSCID3 on payment service from CASH_SERVICE on behalf of <on_behalf_of> on below providers and expect status 200
      | provider_name |
      | DBS Bank Ltd  |

    Then I wait until max time to verify the master account MASAccId1 with master account status MASTER_ACCOUNT_CREATED for the customer profile PSCPID3 on behalf of <on_behalf_of> status as ONBOARD_SUCCESS with provider DBS Bank Ltd

    Given I create account for CustomerProfile with customerProfileId PSCPID3 from <request_origin> on behalf of <on_behalf_of> with provider DBS Bank Ltd and expect the header status 200
      | identifier                | currency   | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID3

    Then I verify CustomerProfile with id PSCPID3 has payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> exists with provider <bank_name> with values
      | account_id                | provider_id | currency | account_status  | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | DBS-SG      | SGD      | ACCOUNT_CREATED | <country> | <metadata> | <on_behalf_of> |

    Given I create account for CustomerProfile with customerProfileId PSCPID3 from CASH_SERVICE on behalf of CUSTOMER with provider DBS Bank Ltd and expect the header status 200
      | identifier                | currency   | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId2 | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account CustomerProfileAccountId2 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID3

    Then I verify CustomerProfile with id PSCPID3 has payment account CustomerProfileAccountId2 from <request_origin> on behalf of <on_behalf_of> exists with provider <bank_name> with values
      | account_id                | provider_id | currency | account_status  | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId2 | DBS-SG      | SGD      | ACCOUNT_CREATED | <country> | <metadata> | <on_behalf_of> |

    Then I retrieve the payment account CustomerProfileAccountId1 from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID3

    Then I initiate transfer out to transfer funds with below details from CASH_SERVICE and expect the header status <status_code> and status as TRANSACTION_FAILED
      | identifier | customer_profile_id | account_id                | receiver_account_id       | txn_currency | txn_amount   | purpose          | txn_mode | transfer_out_account_details                                                                                                                                                                       | metadata                    | currency |
      | TxnId1     | PSCPID3             | CustomerProfileAccountId1 | CustomerProfileAccountId2 | SGD          | <txn_amount> | Internal Pay Out | FAST     | {'account_holder_name': 'Stark', 'bank_name': 'DBS Bank Ltd','country': 'SGP', 'currency': 'SGD', 'code_details': {'sg_bank_details': {'account_number': '123456789', 'swift_bic':'DBSSSGSGXXX'}}} | {"key": "Internal Pay Out"} | SGD      |

    Examples:
      | txn_amount | currency | country | bank_name    | status_code | request_origin | on_behalf_of | metadata                    |
      | 10         | SGD      | SGP     | DBS Bank Ltd | PTM_1600    | CASH_SERVICE   | CUSTOMER     | {"key": "Internal Pay Out"} |
      | 20         | SGD      | SGP     | DBS Bank Ltd | PTM_1600    | CASH_SERVICE   | CUSTOMER     | {"key": "Internal Pay Out"} |


  Scenario Outline: I call TransferOut to transfer an amount between same account from CASH_SERVICE on behalf of CUSTOMER and verify the transaction is failed

    Given I create account for CustomerProfile with customerProfileId PSCPID1 from <request_origin> on behalf of <on_behalf_of> with provider DBS Bank Ltd and expect the header status <status_code>
      | identifier                | currency   | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID1

    Then I verify CustomerProfile with id PSCPID1 has payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> exists with provider <bank_name> with values
      | account_id                | provider_id | currency | account_status  | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | DBS-SG      | SGD      | ACCOUNT_CREATED | <country> | <metadata> | <on_behalf_of> |

    Then I retrieve the payment account CustomerProfileAccountId1 from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID1

    Given I deposit an amount of <deposit_amount> into account CustomerProfileAccountId1 using IDN for customerProfileId PSCPID1
      | identifier    | customer_profile_id | header                                                                                         | txn_info                                                                                                                                                                                                                                                                                                                                                  |
      | IDNIdentifier | PSCPID1             | {"msgId":"IDNIdentifier","orgId":"ATLCONS3","ctry":"SG","timeStamp":"2023-01-06T09:48:59.457"} | {"amt_dtls": {"txn_amt": "150","txn_ccy": "SGD"},"customer_reference": "IDNIdentifier","sender_party": { "name": "HUGO","sender_bank_id": "DBSSSGSGXXX"},"txn_ref_id": "IDNIdentifier","receiving_party": {"account_no":"88532600026958397","name": "ATLAS CONSOLIDATED PTE. LTD."},"txn_type":"FAST","txn_date": "2023-01-06","value_dt": "2023-01-06" } |

    Then I wait until max time to verify master account CustomerProfileAccountId1 with an increased updated balance of <deposit_amount> for customerProfileId PSCPID1

    Then I initiate transfer out to transfer funds to same account with below details from CASH_SERVICE and expect the header status <status_code> and status as TRANSACTION_REJECTED
      | identifier | customer_profile_id | account_id                | receiver_account_id       | txn_currency | txn_amount   | purpose          | txn_mode | transfer_out_account_details                                                                                                                                                                       | metadata                    | currency | total_balance    | available_balance |
      | TxnId1     | PSCPID1             | CustomerProfileAccountId1 | CustomerProfileAccountId1 | SGD          | <txn_amount> | Internal Pay Out | FAST     | {'account_holder_name': 'Stark', 'bank_name': 'DBS Bank Ltd','country': 'SGP', 'currency': 'SGD', 'code_details': {'sg_bank_details': {'account_number': '123456789', 'swift_bic':'DBSSSGSGXXX'}}} | {"key": "Internal Pay Out"} | SGD      | <deposit_amount> | <deposit_amount>  |

    Examples:
      | txn_amount | currency | country | bank_name    | status_code | request_origin | on_behalf_of | metadata                    | deposit_amount |
      | 10         | SGD      | SGP     | DBS Bank Ltd | 200         | CASH_SERVICE   | CUSTOMER     | {"key": "Internal Pay Out"} | 100            |

  Scenario Outline: I call TransferOut to transfer an amount between 2 different master accounts of 2 different customer profile accounts from CASH_SERVICE on behalf of CUSTOMER and verify the transaction is settled

    Given I onboard CustomerProfile PSCPID2 with customerId PSCID2 on payment service from CASH_SERVICE on behalf of <on_behalf_of> on below providers and expect status 200 for different customer
      | provider_name |
      | DBS Bank Ltd  |

    Then I wait until max time to verify the master account MASAccId2 with master account status MASTER_ACCOUNT_CREATED for the customer profile PSCPID2 on behalf of <on_behalf_of> status as ONBOARD_SUCCESS with provider DBS Bank Ltd

    Then I retrieve CustomerProfile PSCPID1 from CASH_SERVICE onboard status as ONBOARD_SUCCESS onto Payment Service

    Then I retrieve CustomerProfile PSCPID2 from CASH_SERVICE onboard status as ONBOARD_SUCCESS onto Payment Service

    Given I deposit an amount of <deposit_amount> into master account PSCPID1 using DevDeposit expect the header status 200
      | identifier | customer_profile_id | name           | account_id | txn_amount       | currency | purpose          | txn_mode | metadata              |
      | TxId1      | PSCPID1             | Developer Bank | PSCPID1    | <deposit_amount> | SGD      | Integration Test | FAST     | {"key": "DevDeposit"} |

    Then I initiate transfer out to transfer funds between 2 different master accounts of 2 different customer profiles with below details from CASH_SERVICE and expect the header status 200 and status as TRANSACTION_SETTLED
      | identifier | customer_profile_id | account_id | receiver_account_id | txn_currency | txn_amount   | purpose          | txn_mode | transfer_out_account_details                                                                                                                                                                       | metadata                    | currency | total_balance    | available_balance |
      | TxnId1     | PSCPID1             | PSCPID1    | PSCPID2             | SGD          | <txn_amount> | Internal Pay Out | FAST     | {'account_holder_name': 'Stark', 'bank_name': 'DBS Bank Ltd','country': 'SGP', 'currency': 'SGD', 'code_details': {'sg_bank_details': {'account_number': '123456789', 'swift_bic':'DBSSSGSGXXX'}}} | {"key": "Internal Pay Out"} | SGD      | <deposit_amount> | <deposit_amount>  |

    Examples:
      | txn_amount | on_behalf_of | deposit_amount |
      | 10         | CUSTOMER     | 100            |
      | 20         | CUSTOMER     | 100            |

  Scenario Outline: I call TransferOut to transfer an amount between same master account to customer profile account under same master account from CASH_SERVICE on behalf of CUSTOMER and verify the transaction is settled

    Given I create account for CustomerProfile with customerProfileId PSCPID1 from CASH_SERVICE on behalf of <on_behalf_of> with provider DBS Bank Ltd and expect the header status 200
      | identifier                | currency   | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account CustomerProfileAccountId1 from CASH_SERVICE on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID1

    Then I verify CustomerProfile with id PSCPID1 has payment account CustomerProfileAccountId1 from CASH_SERVICE on behalf of <on_behalf_of> exists with provider DBS Bank Ltd with values
      | account_id                | provider_id | currency | account_status  | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | DBS-SG      | SGD      | ACCOUNT_CREATED | <country> | <metadata> | <on_behalf_of> |

    Then I retrieve CustomerProfile PSCPID1 from CASH_SERVICE onboard status as ONBOARD_SUCCESS onto Payment Service

    Given I deposit an amount of <deposit_amount> into master account PSCPID1 using DevDeposit expect the header status 200
      | identifier | customer_profile_id | name           | account_id | txn_amount       | currency | purpose          | txn_mode | metadata              |
      | TxId1      | PSCPID1             | Developer Bank | PSCPID1    | <deposit_amount> | SGD      | Integration Test | FAST     | {"key": "DevDeposit"} |

    Then I initiate transfer out to transfer funds from master account to account under same master account with below details from CASH_SERVICE and expect the header status 200 and status as TRANSACTION_SETTLED
      | identifier | customer_profile_id | account_id | receiver_account_id       | txn_currency | txn_amount   | purpose          | txn_mode | transfer_out_account_details                                                                                                                                                                       | metadata                    | currency | total_balance    | available_balance |
      | TxnId1     | PSCPID1             | PSCPID1    | CustomerProfileAccountId1 | SGD          | <txn_amount> | Internal Pay Out | FAST     | {'account_holder_name': 'Stark', 'bank_name': 'DBS Bank Ltd','country': 'SGP', 'currency': 'SGD', 'code_details': {'sg_bank_details': {'account_number': '123456789', 'swift_bic':'DBSSSGSGXXX'}}} | {"key": "Internal Pay Out"} | SGD      | <deposit_amount> | <deposit_amount>  |

    Examples:
      | txn_amount | on_behalf_of | deposit_amount | currency | country | metadata                                              |
      | 10         | CUSTOMER     | 100            | SGD      | SGP     | {"key": "Master Account to Customer Profile Account"} |
      | 20         | CUSTOMER     | 100            | SGD      | SGP     | {"key": "Master Account to Customer Profile Account"} |

  Scenario Outline: I call TransferOut to transfer an amount from customer account to same master account from CASH_SERVICE on behalf of CUSTOMER and verify the transaction is settled

    Given I create account for CustomerProfile with customerProfileId PSCPID1 from CASH_SERVICE on behalf of <on_behalf_of> with provider DBS Bank Ltd and expect the header status 200
      | identifier                | currency   | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account CustomerProfileAccountId1 from CASH_SERVICE on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID1

    Then I verify CustomerProfile with id PSCPID1 has payment account CustomerProfileAccountId1 from CASH_SERVICE on behalf of <on_behalf_of> exists with provider DBS Bank Ltd with values
      | account_id                | provider_id | currency | account_status  | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | DBS-SG      | SGD      | ACCOUNT_CREATED | <country> | <metadata> | <on_behalf_of> |

    Then I retrieve CustomerProfile PSCPID1 from CASH_SERVICE onboard status as ONBOARD_SUCCESS onto Payment Service

    Given I deposit an amount of <deposit_amount> into CustomerProfileAccountId1 using DevDeposit expect the header status 200
      | identifier | customer_profile_id | name           | account_id                | txn_amount       | currency | purpose          | txn_mode | metadata              |
      | TxId1      | PSCPID1             | Developer Bank | CustomerProfileAccountId1 | <deposit_amount> | SGD      | Integration Test | FAST     | {"key": "DevDeposit"} |

    Then I initiate transfer out to transfer funds from account to master account with below details from CASH_SERVICE and expect the header status 200 and status as TRANSACTION_SETTLED
      | identifier | customer_profile_id | account_id                | receiver_account_id | txn_currency | txn_amount   | purpose          | txn_mode | transfer_out_account_details                                                                                                                                                                       | metadata                    | currency | total_balance    | available_balance |
      | TxnId1     | PSCPID1             | CustomerProfileAccountId1 | PSCPID1             | SGD          | <txn_amount> | Internal Pay Out | FAST     | {'account_holder_name': 'Stark', 'bank_name': 'DBS Bank Ltd','country': 'SGP', 'currency': 'SGD', 'code_details': {'sg_bank_details': {'account_number': '123456789', 'swift_bic':'DBSSSGSGXXX'}}} | {"key": "Internal Pay Out"} | SGD      | <deposit_amount> | <deposit_amount>  |

    Examples:
      | txn_amount | on_behalf_of | deposit_amount | currency | country | metadata                                              |
      | 10         | CUSTOMER     | 100            | SGD      | SGP     | {"key": "Customer Profile Account to Master Account"} |
      | 20         | CUSTOMER     | 100            | SGD      | SGP     | {"key": "Customer Profile Account to Master Account"} |


  Scenario Outline: I call TransferOut to transfer an amount from customer profile master account to different customer profile account from CASH_SERVICE on behalf of CUSTOMER and verify the transaction is settled

    Then I retrieve CustomerProfile PSCPID1 from CASH_SERVICE onboard status as ONBOARD_SUCCESS onto Payment Service

    Given I onboard CustomerProfile PSCPID2 with customerId PSCID2 on payment service from CASH_SERVICE on behalf of <on_behalf_of> on below providers and expect status 200 for different customer
      | provider_name |
      | DBS Bank Ltd  |

    Then I wait until max time to verify the master account MASAccId2 with master account status MASTER_ACCOUNT_CREATED for the customer profile PSCPID2 on behalf of <on_behalf_of> status as ONBOARD_SUCCESS with provider DBS Bank Ltd

    Given I create account for CustomerProfile with customerProfileId PSCPID2 from CASH_SERVICE on behalf of <on_behalf_of> with provider DBS Bank Ltd and expect the header status 200
      | identifier                | currency | country | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | SGD      | SGP     | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account CustomerProfileAccountId1 from CASH_SERVICE on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID2

    Then I verify CustomerProfile with id PSCPID2 has payment account CustomerProfileAccountId1 from CASH_SERVICE on behalf of <on_behalf_of> exists with provider DBS Bank Ltd with values
      | account_id                | provider_id | currency | account_status  | country | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | DBS-SG      | SGD      | ACCOUNT_CREATED | SGD     | <metadata> | <on_behalf_of> |

    Then I retrieve CustomerProfile PSCPID1 from CASH_SERVICE onboard status as ONBOARD_SUCCESS onto Payment Service

    Given I deposit an amount of <deposit_amount> into master account PSCPID1 using DevDeposit expect the header status 200
      | identifier | customer_profile_id | name           | account_id | txn_amount       | currency | purpose          | txn_mode | metadata              |
      | TxId1      | PSCPID1             | Developer Bank | PSCPID1    | <deposit_amount> | SGD      | Integration Test | FAST     | {"key": "DevDeposit"} |

    Then I initiate transfer out to transfer funds between from customer profile PSCPID1 master account to account under different customer profile PSCPID2 with below details from CASH_SERVICE and expect the header status 200 and status as TRANSACTION_SETTLED
      | identifier | customer_profile_id | account_id | receiver_account_id       | txn_currency | txn_amount   | purpose          | txn_mode | transfer_out_account_details                                                                                                                                                                       | metadata                    | currency | total_balance    | available_balance |
      | TxnId1     | PSCPID1             | PSCPID1    | CustomerProfileAccountId1 | SGD          | <txn_amount> | Internal Pay Out | FAST     | {'account_holder_name': 'Stark', 'bank_name': 'DBS Bank Ltd','country': 'SGP', 'currency': 'SGD', 'code_details': {'sg_bank_details': {'account_number': '123456789', 'swift_bic':'DBSSSGSGXXX'}}} | {"key": "Internal Pay Out"} | SGD      | <deposit_amount> | <deposit_amount>  |

    Examples:
      | txn_amount | on_behalf_of | deposit_amount | metadata                                                                  |
      | 10         | CUSTOMER     | 100            | {"key": "Different Master Account to Different Customer Profile Account"} |
      | 20         | CUSTOMER     | 100            | {"key": "Different Master Account to Different Customer Profile Account"} |

  Scenario Outline: I call TransferOut to transfer an amount from customer profile account to different customer profile master account from CASH_SERVICE on behalf of CUSTOMER and verify the transaction is settled

    Given I onboard CustomerProfile PSCPID2 with customerId PSCID2 on payment service from CASH_SERVICE on behalf of <on_behalf_of> on below providers and expect status 200 for different customer
      | provider_name |
      | DBS Bank Ltd  |

    Then I wait until max time to verify the master account MASAccId2 with master account status MASTER_ACCOUNT_CREATED for the customer profile PSCPID2 on behalf of <on_behalf_of> status as ONBOARD_SUCCESS with provider DBS Bank Ltd

    Then I retrieve CustomerProfile PSCPID2 from CASH_SERVICE onboard status as ONBOARD_SUCCESS onto Payment Service

    Given I create account for CustomerProfile with customerProfileId PSCPID1 from CASH_SERVICE on behalf of <on_behalf_of> with provider DBS Bank Ltd and expect the header status 200
      | identifier                | currency | country | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | SGD      | SGP     | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account CustomerProfileAccountId1 from CASH_SERVICE on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID1

    Then I verify CustomerProfile with id PSCPID1 has payment account CustomerProfileAccountId1 from CASH_SERVICE on behalf of <on_behalf_of> exists with provider DBS Bank Ltd with values
      | account_id                | provider_id | currency | account_status  | country | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | DBS-SG      | SGD      | ACCOUNT_CREATED | SGD     | <metadata> | <on_behalf_of> |

    Given I deposit an amount of <deposit_amount> into CustomerProfileAccountId1 using DevDeposit expect the header status 200
      | identifier | customer_profile_id | name           | account_id | txn_amount       | currency | purpose          | txn_mode | metadata              |
      | TxId1      | PSCPID1             | Developer Bank | PSCPID1    | <deposit_amount> | SGD      | Integration Test | FAST     | {"key": "DevDeposit"} |

    Then I initiate transfer out to transfer funds between from customer profile PSCPID1 account to master account under different customer profile PSCPID2 with below details from CASH_SERVICE and expect the header status 200 and status as TRANSACTION_SETTLED
      | identifier | customer_profile_id | account_id                | receiver_account_id | txn_currency | txn_amount   | purpose          | txn_mode | transfer_out_account_details                                                                                                                                                                       | metadata                    | currency | total_balance    | available_balance |
      | TxnId1     | PSCPID1             | CustomerProfileAccountId1 | PSCPID2             | SGD          | <txn_amount> | Internal Pay Out | FAST     | {'account_holder_name': 'Stark', 'bank_name': 'DBS Bank Ltd','country': 'SGP', 'currency': 'SGD', 'code_details': {'sg_bank_details': {'account_number': '123456789', 'swift_bic':'DBSSSGSGXXX'}}} | {"key": "Internal Pay Out"} | SGD      | <deposit_amount> | <deposit_amount>  |

    Examples:
      | txn_amount | on_behalf_of | deposit_amount | metadata                                                                  |
      | 10         | CUSTOMER     | 100            | {"key": "Different Customer Profile Account to Different Master Account"} |
      | 20         | CUSTOMER     | 100            | {"key": "Different Customer Profile Account to Different Master Account"} |

  Scenario Outline: I call TransferOut to transfer an amount from customer profile account of Customer Profile C1 to different customer profile account of Customer Profile C2 from CASH_SERVICE on behalf of CUSTOMER and verify the transaction is settled

    Given I create account for CustomerProfile with customerProfileId PSCPID1 from CASH_SERVICE on behalf of <on_behalf_of> with provider DBS Bank Ltd and expect the header status 200
      | identifier                | currency | country | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | SGD      | SGP     | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account CustomerProfileAccountId1 from CASH_SERVICE on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID1

    Then I verify CustomerProfile with id PSCPID1 has payment account CustomerProfileAccountId1 from CASH_SERVICE on behalf of <on_behalf_of> exists with provider DBS Bank Ltd with values
      | account_id                | provider_id | currency | account_status  | country | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | DBS-SG      | SGD      | ACCOUNT_CREATED | SGD     | <metadata> | <on_behalf_of> |

    Given I onboard CustomerProfile PSCPID2 with customerId PSCID2 on payment service from CASH_SERVICE on behalf of <on_behalf_of> on below providers and expect status 200 for different customer
      | provider_name |
      | DBS Bank Ltd  |

    Then I wait until max time to verify the master account MASAccId2 with master account status MASTER_ACCOUNT_CREATED for the customer profile PSCPID2 on behalf of <on_behalf_of> status as ONBOARD_SUCCESS with provider DBS Bank Ltd

    Given I create account for CustomerProfile with customerProfileId PSCPID2 from CASH_SERVICE on behalf of <on_behalf_of> with provider DBS Bank Ltd and expect the header status 200
      | identifier                | currency | country | metadata   | on_behalf_of   |
      | CustomerProfileAccountId2 | SGD      | SGP     | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account CustomerProfileAccountId2 from CASH_SERVICE on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID2

    Then I verify CustomerProfile with id PSCPID2 has payment account CustomerProfileAccountId2 from CASH_SERVICE on behalf of <on_behalf_of> exists with provider DBS Bank Ltd with values
      | account_id                | provider_id | currency | account_status  | country | metadata   | on_behalf_of   |
      | CustomerProfileAccountId2 | DBS-SG      | SGD      | ACCOUNT_CREATED | SGD     | <metadata> | <on_behalf_of> |

    Then I retrieve CustomerProfile PSCPID2 from CASH_SERVICE onboard status as ONBOARD_SUCCESS onto Payment Service

    Given I deposit an amount of <deposit_amount> into CustomerProfileAccountId1 using DevDeposit expect the header status 200
      | identifier | customer_profile_id | name           | account_id                | txn_amount       | currency | purpose          | txn_mode | metadata              |
      | TxId1      | PSCPID1             | Developer Bank | CustomerProfileAccountId1 | <deposit_amount> | SGD      | Integration Test | FAST     | {"key": "DevDeposit"} |

    Then I initiate transfer out to transfer funds between from customer profile PSCPID1 account to account under different customer profile PSCPID2 with below details from CASH_SERVICE and expect the header status 200 and status as TRANSACTION_SETTLED
      | identifier | customer_profile_id | account_id                | receiver_account_id       | txn_currency | txn_amount   | purpose          | txn_mode | transfer_out_account_details                                                                                                                                                                       | metadata                    | currency | total_balance    | available_balance |
      | TxnId1     | PSCPID1             | CustomerProfileAccountId1 | CustomerProfileAccountId2 | SGD          | <txn_amount> | Internal Pay Out | FAST     | {'account_holder_name': 'Stark', 'bank_name': 'DBS Bank Ltd','country': 'SGP', 'currency': 'SGD', 'code_details': {'sg_bank_details': {'account_number': '123456789', 'swift_bic':'DBSSSGSGXXX'}}} | {"key": "Internal Pay Out"} | SGD      | <deposit_amount> | <deposit_amount>  |

    Examples:
      | txn_amount | on_behalf_of | deposit_amount | metadata                                                                            |
      | 10         | CUSTOMER     | 100            | {"key": "Different Customer Profile Account to Different Customer Profile Account"} |
      | 20         | CUSTOMER     | 100            | {"key": "Different Customer Profile Account to Different Customer Profile Account"} |

  Scenario Outline: Initiate external refund for a Deposit transaction

    Given I create account for CustomerProfile with customerProfileId PSCPID1 from CASH_SERVICE on behalf of <on_behalf_of> with provider DBS Bank Ltd and expect the header status 200
      | identifier                | currency | country | metadata          | on_behalf_of   |
      | CustomerProfileAccountId1 | SGD      | SGP     | {"key": "Refund"} | <on_behalf_of> |

    Then I wait until max time to verify the payment account CustomerProfileAccountId1 from CASH_SERVICE on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID1

    Then I verify CustomerProfile with id PSCPID1 has payment account CustomerProfileAccountId1 from CASH_SERVICE on behalf of <on_behalf_of> exists with provider DBS Bank Ltd with values
      | account_id                | provider_id | currency | account_status  | country | metadata          | on_behalf_of   |
      | CustomerProfileAccountId1 | DBS-SG      | SGD      | ACCOUNT_CREATED | SGD     | {"key": "Refund"} | <on_behalf_of> |

    Given I deposit an amount of <deposit_amount> into CustomerProfileAccountId1 using DevDeposit expect the header status 200
      | identifier | customer_profile_id | name           | account_id                | txn_amount       | currency | purpose          | txn_mode | metadata          |
      | TxId1      | PSCPID1             | Developer Bank | CustomerProfileAccountId1 | <deposit_amount> | SGD      | Integration Test | FAST     | {"key": "Refund"} |

    Then I initiate refund for transaction with below details from CASH_SERVICE expect the header statuscode 200
      | original_transaction_id | customer_profile_id | refund_amount   | purpose          | metadata          |
      | TxId1                   | PSCPID1             | <refund_amount> | Integration Test | {"key": "Refund"} |

    Examples:
      | deposit_amount | refund_amount | on_behalf_of |
      | 100            | 30            | CUSTOMER     |


#    PAYNOW

#  Scenario Outline: I call TransferOut to transfer an amount between internal Hugohub customer profile account and external account with NRIC number from CASH_SERVICE on behalf of CUSTOMER and verify the transaction is settled with transaction mode PAYNOW
#
#    Given I create account for CustomerProfile with customerProfileId PSCPID1 from <request_origin> on behalf of <on_behalf_of> with provider DBS Bank Ltd and expect the header status <status_code>
#      | identifier                | currency   | country   | metadata   | on_behalf_of   |
#      | CustomerProfileAccountId1 | <currency> | <country> | <metadata> | <on_behalf_of> |
#
#    Then I wait until max time to verify the payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID1
#
#    Then I verify CustomerProfile with id PSCPID1 has payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> exists with provider <bank_name> with values
#      | account_id                | provider_id                         | currency | account_status  | country   | metadata   | on_behalf_of   |
#      | CustomerProfileAccountId1 | DBS-SG | SGD      | ACCOUNT_CREATED | <country> | <metadata> | <on_behalf_of> |
#
#    Then I retrieve the payment account CustomerProfileAccountId1 from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID1
#
#    Given I deposit an amount of <deposit_amount> into account CustomerProfileAccountId1 using ICN for customerProfileId PSCPID1
#      | identifier    | customer_profile_id | header                                                                                         | txn_info                                                                                                                                                                                                                                                                                                                                                  |
#      | ICNIdentifier | PSCPID1             | {"msgId":"ICNIdentifier","orgId":"ATLCONS3","ctry":"SG","timeStamp":"2023-11-28T11:00:00.000"} | {"amt_dtls": {"txn_amt": "100","txn_ccy": "SGD"},"customer_reference": "ICNIdentifier","sender_party": { "name": "HUGO","sender_bank_id": "DBSSSGSGXXX"},"txn_ref_id": "ICNIdentifier","receiving_party": {"account_no":"88532600026958397","name": "ATLAS CONSOLIDATED PTE. LTD."},"txn_type":"FAST","txn_date": "2023-11-28","value_dt": "2023-11-28" } |
#
#    Then I wait until max time to verify master account CustomerProfileAccountId1 with an increased updated balance of <deposit_amount> for customerProfileId PSCPID1
#
#    Then I initiate transfer out to transfer funds to an external account from CASH_SERVICE and expect the header status <status_code> and status as TRANSACTION_PENDING
#      | identifier | customer_profile_id | account_id                | txn_currency | txn_amount   | purpose          | txn_mode | transfer_out_account_details                                                                                                                                                                                              | metadata                    | currency | total_balance    | available_balance |
#      | TxnId1     | PSCPID1             | CustomerProfileAccountId1 | SGD          | <txn_amount> | Internal Pay Out | PAYNOW   | {"email": "receiver@abc.com","address": "Wakanda", "account_details": {'account_holder' : 'ABC' , 'country': 'SGP', 'currency': 'SGD', 'code_details': {'sg_identification_details': {'nric': 'S8439061E'}}}} | {"key": "External Pay Out"} | SGD      | <deposit_amount> | <deposit_amount>  |
#
#    Then I wait until max time to verify the transaction TxnId1 status as TRANSACTION_SETTLED for customerProfileId PSCPID1 from CASH_SERVICE
#
#    Examples:
#      | txn_amount | currency | country | bank_name    | status_code | request_origin | on_behalf_of | metadata                    | deposit_amount |
#      | 10         | SGD      | SGP     | DBS Bank Ltd | 200         | CASH_SERVICE           | CUSTOMER     | {"key": "External Pay Out"} | 100            |
#      | 20         | SGD      | SGP     | DBS Bank Ltd | 200         | CASH_SERVICE           | CUSTOMER     | {"key": "External Pay Out"} | 100            |
#
#  Scenario Outline: I call TransferOut to transfer an amount between internal Hugohub customer profile account and external account with FIN number from CASH_SERVICE on behalf of CUSTOMER and verify the transaction is settled with transaction mode PAYNOW
#
#    Given I create account for CustomerProfile with customerProfileId PSCPID1 from <request_origin> on behalf of <on_behalf_of> with provider DBS Bank Ltd and expect the header status <status_code>
#      | identifier                | currency   | country   | metadata   | on_behalf_of   |
#      | CustomerProfileAccountId1 | <currency> | <country> | <metadata> | <on_behalf_of> |
#
#    Then I wait until max time to verify the payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID1
#
#    Then I verify CustomerProfile with id PSCPID1 has payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> exists with provider <bank_name> with values
#      | account_id                | provider_id                         | currency | account_status  | country   | metadata   | on_behalf_of   |
#      | CustomerProfileAccountId1 | DBS-SG | SGD      | ACCOUNT_CREATED | <country> | <metadata> | <on_behalf_of> |
#
#    Then I retrieve the payment account CustomerProfileAccountId1 from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID1
#
#    Given I deposit an amount of <deposit_amount> into account CustomerProfileAccountId1 using ICN for customerProfileId PSCPID1
#      | identifier    | customer_profile_id | header                                                                                         | txn_info                                                                                                                                                                                                                                                                                                                                                  |
#      | ICNIdentifier | PSCPID1             | {"msgId":"ICNIdentifier","orgId":"ATLCONS3","ctry":"SG","timeStamp":"2023-11-28T11:00:00.000"} | {"amt_dtls": {"txn_amt": "100","txn_ccy": "SGD"},"customer_reference": "ICNIdentifier","sender_party": { "name": "HUGO","sender_bank_id": "DBSSSGSGXXX"},"txn_ref_id": "ICNIdentifier","receiving_party": {"account_no":"88532600026958397","name": "ATLAS CONSOLIDATED PTE. LTD."},"txn_type":"FAST","txn_date": "2023-11-28","value_dt": "2023-11-28" } |
#
#    Then I wait until max time to verify master account CustomerProfileAccountId1 with an increased updated balance of <deposit_amount> for customerProfileId PSCPID1
#
#    Then I initiate transfer out to transfer funds to an external account from CASH_SERVICE and expect the header status <status_code> and status as TRANSACTION_PENDING
#      | identifier | customer_profile_id | account_id                | txn_currency | txn_amount   | purpose          | txn_mode | transfer_out_account_details                                                                                                                                                                                            | metadata                    | currency | total_balance    | available_balance |
#      | TxnId1     | PSCPID1             | CustomerProfileAccountId1 | SGD          | <txn_amount> | Internal Pay Out | PAYNOW   | {"email": "receiver@abc.com","address": "Wakanda", "account_details": {'account_holder' : 'ABC', 'country': 'SGP', 'currency': 'SGD', 'code_details': {'sg_identification_details': {'fin': 'S8439061E'}}}} | {"key": "External Pay Out"} | SGD      | <deposit_amount> | <deposit_amount>  |
#
#    Then I wait until max time to verify the transaction TxnId1 status as TRANSACTION_SETTLED for customerProfileId PSCPID1 from CASH_SERVICE
#
#    Examples:
#      | txn_amount | currency | country | bank_name    | status_code | request_origin | on_behalf_of | metadata                    | deposit_amount |
#      | 10         | SGD      | SGP     | DBS Bank Ltd | 200         | CASH_SERVICE           | CUSTOMER     | {"key": "External Pay Out"} | 100            |
#      | 20         | SGD      | SGP     | DBS Bank Ltd | 200         | CASH_SERVICE           | CUSTOMER     | {"key": "External Pay Out"} | 100            |
#
#  Scenario Outline: I call TransferOut to transfer an amount between internal Hugohub customer profile account and external account with UEN number from CASH_SERVICE on behalf of CUSTOMER and verify the transaction is settled with transaction mode PAYNOW
#
#    Given I create account for CustomerProfile with customerProfileId PSCPID1 from <request_origin> on behalf of <on_behalf_of> with provider DBS Bank Ltd and expect the header status <status_code>
#      | identifier                | currency   | country   | metadata   | on_behalf_of   |
#      | CustomerProfileAccountId1 | <currency> | <country> | <metadata> | <on_behalf_of> |
#
#    Then I wait until max time to verify the payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID1
#
#    Then I verify CustomerProfile with id PSCPID1 has payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> exists with provider <bank_name> with values
#      | account_id                | provider_id                         | currency | account_status  | country   | metadata   | on_behalf_of   |
#      | CustomerProfileAccountId1 | DBS-SG | SGD      | ACCOUNT_CREATED | <country> | <metadata> | <on_behalf_of> |
#
#    Then I retrieve the payment account CustomerProfileAccountId1 from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID1
#
#    Given I deposit an amount of <deposit_amount> into account CustomerProfileAccountId1 using ICN for customerProfileId PSCPID1
#      | identifier    | customer_profile_id | header                                                                                         | txn_info                                                                                                                                                                                                                                                                                                                                                  |
#      | ICNIdentifier | PSCPID1             | {"msgId":"ICNIdentifier","orgId":"ATLCONS3","ctry":"SG","timeStamp":"2023-11-28T11:00:00.000"} | {"amt_dtls": {"txn_amt": "100","txn_ccy": "SGD"},"customer_reference": "ICNIdentifier","sender_party": { "name": "HUGO","sender_bank_id": "DBSSSGSGXXX"},"txn_ref_id": "ICNIdentifier","receiving_party": {"account_no":"88532600026958397","name": "ATLAS CONSOLIDATED PTE. LTD."},"txn_type":"FAST","txn_date": "2023-11-28","value_dt": "2023-11-28" } |
#
#    Then I wait until max time to verify master account CustomerProfileAccountId1 with an increased updated balance of <deposit_amount> for customerProfileId PSCPID1
#
#    Then I initiate transfer out to transfer funds to an external account from CASH_SERVICE and expect the header status <status_code> and status as TRANSACTION_PENDING
#      | identifier | customer_profile_id | account_id                | txn_currency | txn_amount   | purpose          | txn_mode | transfer_out_account_details                                                                                                                                                                                             | metadata                    | currency | total_balance    | available_balance |
#      | TxnId1     | PSCPID1             | CustomerProfileAccountId1 | SGD          | <txn_amount> | Internal Pay Out | PAYNOW   | {"email": "receiver@abc.com","address": "Wakanda", "account_details": {'account_holder' : 'ABC', 'country': 'SGP', 'currency': 'SGD', 'code_details': {'sg_identification_details': {'uen': '53361549J'}}}}  | {"key": "External Pay Out"} | SGD      | <deposit_amount> | <deposit_amount>  |
#
#    Then I wait until max time to verify the transaction TxnId1 status as TRANSACTION_SETTLED for customerProfileId PSCPID1 from CASH_SERVICE
#
#    Examples:
#      | txn_amount | currency | country | bank_name    | status_code | request_origin | on_behalf_of | metadata                    | deposit_amount |
#      | 10         | SGD      | SGP     | DBS Bank Ltd | 200         | CASH_SERVICE           | CUSTOMER     | {"key": "External Pay Out"} | 100            |
#      | 20         | SGD      | SGP     | DBS Bank Ltd | 200         | CASH_SERVICE           | CUSTOMER     | {"key": "External Pay Out"} | 100            |
#
#  Scenario Outline: I call TransferOut to transfer an amount between internal Hugohub customer profile account and external account with mobile number from CASH_SERVICE on behalf of CUSTOMER and verify the transaction is settled with transaction mode PAYNOW
#
#    Given I create account for CustomerProfile with customerProfileId PSCPID1 from <request_origin> on behalf of <on_behalf_of> with provider DBS Bank Ltd and expect the header status <status_code>
#      | identifier                | currency   | country   | metadata   | on_behalf_of   |
#      | CustomerProfileAccountId1 | <currency> | <country> | <metadata> | <on_behalf_of> |
#
#    Then I wait until max time to verify the payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID1
#
#    Then I verify CustomerProfile with id PSCPID1 has payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> exists with provider <bank_name> with values
#      | account_id                | provider_id                         | currency | account_status  | country   | metadata   | on_behalf_of   |
#      | CustomerProfileAccountId1 | DBS-SG | SGD      | ACCOUNT_CREATED | <country> | <metadata> | <on_behalf_of> |
#
#    Then I retrieve the payment account CustomerProfileAccountId1 from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID1
#
#    Given I deposit an amount of <deposit_amount> into account CustomerProfileAccountId1 using ICN for customerProfileId PSCPID1
#      | identifier    | customer_profile_id | header                                                                                         | txn_info                                                                                                                                                                                                                                                                                                                                                  |
#      | ICNIdentifier | PSCPID1             | {"msgId":"ICNIdentifier","orgId":"ATLCONS3","ctry":"SG","timeStamp":"2023-11-28T11:00:00.000"} | {"amt_dtls": {"txn_amt": "100","txn_ccy": "SGD"},"customer_reference": "ICNIdentifier","sender_party": { "name": "HUGO","sender_bank_id": "DBSSSGSGXXX"},"txn_ref_id": "ICNIdentifier","receiving_party": {"account_no":"88532600026958397","name": "ATLAS CONSOLIDATED PTE. LTD."},"txn_type":"FAST","txn_date": "2023-11-28","value_dt": "2023-11-28" } |
#
#    Then I wait until max time to verify master account CustomerProfileAccountId1 with an increased updated balance of <deposit_amount> for customerProfileId PSCPID1
#
#    Then I initiate transfer out to transfer funds to an external account from CASH_SERVICE and expect the header status <status_code> and status as TRANSACTION_PENDING
#      | identifier | customer_profile_id | account_id                | txn_currency | txn_amount   | purpose          | txn_mode | transfer_out_account_details                                                                                                                                              | metadata                    | currency | total_balance    | available_balance |
#      | TxnId1     | PSCPID1             | CustomerProfileAccountId1 | SGD          | <txn_amount> | Internal Pay Out | PAYNOW   | {"email": "receiver@abc.com","address": "Wakanda", "account_details": {'mobile':'+6598765432', 'account_holder' : 'ABC', 'country': 'SGP', 'currency': 'SGD'}}| {"key": "External Pay Out"} | SGD      | <deposit_amount> | <deposit_amount>  |
#
#    Then I wait until max time to verify the transaction TxnId1 status as TRANSACTION_SETTLED for customerProfileId PSCPID1 from CASH_SERVICE
#
#    Examples:
#      | txn_amount | currency | country | bank_name    | status_code | request_origin | on_behalf_of | metadata                    | deposit_amount |
#      | 10         | SGD      | SGP     | DBS Bank Ltd | 200         | CASH_SERVICE           | CUSTOMER     | {"key": "External Pay Out"} | 100            |
#      | 20         | SGD      | SGP     | DBS Bank Ltd | 200         | CASH_SERVICE           | CUSTOMER     | {"key": "External Pay Out"} | 100            |
#
#  Scenario Outline: I call TransferOut to transfer an amount between internal Hugohub customer profile account and external account with vpa from CASH_SERVICE on behalf of CUSTOMER and verify the transaction is settled with transaction mode PAYNOW
#
#    Given I create account for CustomerProfile with customerProfileId PSCPID1 from <request_origin> on behalf of <on_behalf_of> with provider DBS Bank Ltd and expect the header status <status_code>
#      | identifier                | currency   | country   | metadata   | on_behalf_of   |
#      | CustomerProfileAccountId1 | <currency> | <country> | <metadata> | <on_behalf_of> |
#
#    Then I wait until max time to verify the payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID1
#
#    Then I verify CustomerProfile with id PSCPID1 has payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> exists with provider <bank_name> with values
#      | account_id                | provider_id                         | currency | account_status  | country   | metadata   | on_behalf_of   |
#      | CustomerProfileAccountId1 | DBS-SG | SGD      | ACCOUNT_CREATED | <country> | <metadata> | <on_behalf_of> |
#
#    Then I retrieve the payment account CustomerProfileAccountId1 from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID1
#
#    Given I deposit an amount of <deposit_amount> into account CustomerProfileAccountId1 using ICN for customerProfileId PSCPID1
#      | identifier    | customer_profile_id | header                                                                                         | txn_info                                                                                                                                                                                                                                                                                                                                                  |
#      | ICNIdentifier | PSCPID1             | {"msgId":"ICNIdentifier","orgId":"ATLCONS3","ctry":"SG","timeStamp":"2023-11-28T11:00:00.000"} | {"amt_dtls": {"txn_amt": "100","txn_ccy": "SGD"},"customer_reference": "ICNIdentifier","sender_party": { "name": "HUGO","sender_bank_id": "DBSSSGSGXXX"},"txn_ref_id": "ICNIdentifier","receiving_party": {"account_no":"88532600026958397","name": "ATLAS CONSOLIDATED PTE. LTD."},"txn_type":"FAST","txn_date": "2023-11-28","value_dt": "2023-11-28" } |
#
#    Then I wait until max time to verify master account CustomerProfileAccountId1 with an increased updated balance of <deposit_amount> for customerProfileId PSCPID1
#
#    Then I initiate transfer out to transfer funds to an external account from CASH_SERVICE and expect the header status <status_code> and status as TRANSACTION_PENDING
#      | identifier | customer_profile_id | account_id                | txn_currency | txn_amount   | purpose          | txn_mode | transfer_out_account_details                                                                                                                                              | metadata                    | currency | total_balance    | available_balance |
#      | TxnId1     | PSCPID1             | CustomerProfileAccountId1 | SGD          | <txn_amount> | Internal Pay Out | PAYNOW   | {"email": "receiver@abc.com","address": "Wakanda", "account_details": {'vpa':'9876543210@ybl', 'account_holder' : 'ABC', 'country': 'SGP', 'currency': 'SGD'}}| {"key": "External Pay Out"} | SGD      | <deposit_amount> | <deposit_amount>  |
#
#    Then I wait until max time to verify the transaction TxnId1 status as TRANSACTION_SETTLED for customerProfileId PSCPID1 from CASH_SERVICE
#
#    Examples:
#      | txn_amount | currency | country | bank_name    | status_code | request_origin | on_behalf_of | metadata                    | deposit_amount |
#      | 10         | SGD      | SGP     | DBS Bank Ltd | 200         | CASH_SERVICE           | CUSTOMER     | {"key": "External Pay Out"} | 100            |
#      | 20         | SGD      | SGP     | DBS Bank Ltd | 200         | CASH_SERVICE           | CUSTOMER     | {"key": "External Pay Out"} | 100            |
#
#  Scenario Outline: I call TransferOut to transfer an amount between internal Hugohub customer profile account and external account with email from CASH_SERVICE on behalf of CUSTOMER and verify the transaction is failed with transaction mode PAYNOW
#
#    Given I create account for CustomerProfile with customerProfileId PSCPID1 from <request_origin> on behalf of <on_behalf_of> with provider DBS Bank Ltd and expect the header status <status_code>
#      | identifier                | currency   | country   | metadata   | on_behalf_of   |
#      | CustomerProfileAccountId1 | <currency> | <country> | <metadata> | <on_behalf_of> |
#
#    Then I wait until max time to verify the payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID1
#
#    Then I verify CustomerProfile with id PSCPID1 has payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> exists with provider <bank_name> with values
#      | account_id                | provider_id                         | currency | account_status  | country   | metadata   | on_behalf_of   |
#      | CustomerProfileAccountId1 | DBS-SG | SGD      | ACCOUNT_CREATED | <country> | <metadata> | <on_behalf_of> |
#
#    Then I retrieve the payment account CustomerProfileAccountId1 from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID1
#
#    Given I deposit an amount of <deposit_amount> into account CustomerProfileAccountId1 using ICN for customerProfileId PSCPID1
#      | identifier    | customer_profile_id | header                                                                                         | txn_info                                                                                                                                                                                                                                                                                                                                                  |
#      | ICNIdentifier | PSCPID1             | {"msgId":"ICNIdentifier","orgId":"ATLCONS3","ctry":"SG","timeStamp":"2023-11-28T11:00:00.000"} | {"amt_dtls": {"txn_amt": "100","txn_ccy": "SGD"},"customer_reference": "ICNIdentifier","sender_party": { "name": "HUGO","sender_bank_id": "DBSSSGSGXXX"},"txn_ref_id": "ICNIdentifier","receiving_party": {"account_no":"88532600026958397","name": "ATLAS CONSOLIDATED PTE. LTD."},"txn_type":"FAST","txn_date": "2023-11-28","value_dt": "2023-11-28" } |
#
#    Then I wait until max time to verify master account CustomerProfileAccountId1 with an increased updated balance of <deposit_amount> for customerProfileId PSCPID1
#
#    Then I initiate transfer out to transfer funds to an external account from CASH_SERVICE and expect the header status <status_code> and status as TRANSACTION_PENDING
#      | identifier | customer_profile_id | account_id                | txn_currency | txn_amount   | purpose          | txn_mode | transfer_out_account_details                                                                                                                       | metadata                    | currency | total_balance    | available_balance |
#      | TxnId1     | PSCPID1             | CustomerProfileAccountId1 | SGD          | <txn_amount> | Internal Pay Out | PAYNOW   | {"address": "Wakanda", "account_details": {'email': 'receiver@abc.com', 'account_holder' : 'ABC', 'country': 'SGP', 'currency': 'SGD'}}| {"key": "External Pay Out"} | SGD      | <deposit_amount> | <deposit_amount>  |
#
#    Then I wait until max time to verify the transaction TxnId1 status as TRANSACTION_FAILED for customerProfileId PSCPID1 from CASH_SERVICE
#
#    Examples:
#      | txn_amount | currency | country | bank_name    | status_code | request_origin | on_behalf_of | metadata                    | deposit_amount |
#      | 10         | SGD      | SGP     | DBS Bank Ltd | 200         | CASH_SERVICE           | CUSTOMER     | {"key": "External Pay Out"} | 100            |
#      | 20         | SGD      | SGP     | DBS Bank Ltd | 200         | CASH_SERVICE           | CUSTOMER     | {"key": "External Pay Out"} | 100            |
#
#  Scenario Outline: I call TransferOut to transfer an amount between internal Hugohub customer profile account and external account with NRIC number from CASH_SERVICE on behalf of CUSTOMER and with insufficient balance verify the transaction is failed with transaction mode PAYNOW
#
#    Given I create below Customer
#      | customer_identifier | name | date       |
#      | PSCID3              | hugo | 01-01-2001 |
#
#    Then I create below Customer-Profile
#      | customer_identifier | customer_profile_identifier | region | name  | email          | phone_number |
#      | PSCID3              | PSCPID3                     | SG     | Stark | hugo@atlas.com | 8989548747   |
#
#    Then I verify Customer-Profile exist with values
#      | customer_identifier | customer_profile_identifier | region | name  | email          | phone_number | status |
#      | PSCID3              | PSCPID3                     | SG     | Stark | hugo@atlas.com | 8989548747   | ACTIVE |
#
#    Given I onboard CustomerProfile PSCPID3 with customerId PSCID3 on payment service from CASH_SERVICE on behalf of <on_behalf_of> on below providers and expect status 200
#      | provider_name |
#      | DBS Bank Ltd  |
#
#    Then I wait until max time to verify the master account MASAccId1 with master account status MASTER_ACCOUNT_CREATED for the customer profile PSCPID3 on behalf of <on_behalf_of> status as ONBOARD_SUCCESS with provider DBS Bank Ltd
#
#    Given I create account for CustomerProfile with customerProfileId PSCPID3 from <request_origin> on behalf of <on_behalf_of> with provider DBS Bank Ltd and expect the header status 200
#      | identifier                | currency   | country   | metadata   | on_behalf_of   |
#      | CustomerProfileAccountId1 | <currency> | <country> | <metadata> | <on_behalf_of> |
#
#    Then I wait until max time to verify the payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID3
#
#    Then I verify CustomerProfile with id PSCPID3 has payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> exists with provider <bank_name> with values
#      | account_id                | provider_id                         | currency | account_status  | country   | metadata   | on_behalf_of   |
#      | CustomerProfileAccountId1 | DBS-SG | SGD      | ACCOUNT_CREATED | <country> | <metadata> | <on_behalf_of> |
#
#    Then I retrieve the payment account CustomerProfileAccountId1 from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID3
#
#    Then I initiate transfer out to transfer funds to an external account from CASH_SERVICE and expect the header status <status_code> and status as TRANSACTION_FAILED
#      | identifier | customer_profile_id | account_id                | txn_currency | txn_amount   | purpose          | txn_mode | transfer_out_account_details                                                                                                                                                                                              | metadata                    | currency | total_balance    | available_balance |
#      | TxnId1     | PSCPID3             | CustomerProfileAccountId1 | SGD          | <txn_amount> | Internal Pay Out | PAYNOW   | {"email": "receiver@abc.com","address": "Wakanda", "account_details": {'account_holder' : 'ABC' , 'country': 'SGP', 'currency': 'SGD', 'code_details': {'sg_identification_details': {'nric': 'S8439061E'}}}} | {"key": "External Pay Out"} | SGD      | <deposit_amount> | <deposit_amount>  |
#
#    Examples:
#      | txn_amount | currency | country | bank_name    | status_code | request_origin | on_behalf_of | metadata                    | deposit_amount |
#      | 10         | SGD      | SGP     | DBS Bank Ltd | PTM_1600    | CASH_SERVICE           | CUSTOMER     | {"key": "External Pay Out"} | 100            |
#      | 20         | SGD      | SGP     | DBS Bank Ltd | PTM_1600    | CASH_SERVICE           | CUSTOMER     | {"key": "External Pay Out"} | 100            |
#
#  Scenario Outline: I call TransferOut to transfer an amount between internal Hugohub customer profile account and external account with FIN number from CASH_SERVICE on behalf of CUSTOMER and with insufficient balance verify the transaction is failed with transaction mode PAYNOW
#
#    Given I create below Customer
#      | customer_identifier | name | date       |
#      | PSCID4              | hugo | 01-01-2001 |
#
#    Then I create below Customer-Profile
#      | customer_identifier | customer_profile_identifier | region | name  | email          | phone_number |
#      | PSCID4              | PSCPID4                     | SG     | Stark | hugo@atlas.com | 8989548747   |
#
#    Then I verify Customer-Profile exist with values
#      | customer_identifier | customer_profile_identifier | region | name  | email          | phone_number | status |
#      | PSCID4              | PSCPID4                     | SG     | Stark | hugo@atlas.com | 8989548747   | ACTIVE |
#
#    Given I onboard CustomerProfile PSCPID4 with customerId PSCID4 on payment service from CASH_SERVICE on behalf of <on_behalf_of> on below providers and expect status 200
#      | provider_name |
#      | DBS Bank Ltd  |
#
#    Then I wait until max time to verify the master account MASAccId1 with master account status MASTER_ACCOUNT_CREATED for the customer profile PSCPID4 on behalf of <on_behalf_of> status as ONBOARD_SUCCESS with provider DBS Bank Ltd
#
#    Given I create account for CustomerProfile with customerProfileId PSCPID4 from <request_origin> on behalf of <on_behalf_of> with provider DBS Bank Ltd and expect the header status 200
#      | identifier                | currency   | country   | metadata   | on_behalf_of   |
#      | CustomerProfileAccountId1 | <currency> | <country> | <metadata> | <on_behalf_of> |
#
#    Then I wait until max time to verify the payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID4
#
#    Then I verify CustomerProfile with id PSCPID4 has payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> exists with provider <bank_name> with values
#      | account_id                | provider_id                         | currency | account_status  | country   | metadata   | on_behalf_of   |
#      | CustomerProfileAccountId1 | DBS-SG | SGD      | ACCOUNT_CREATED | <country> | <metadata> | <on_behalf_of> |
#
#    Then I retrieve the payment account CustomerProfileAccountId1 from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID4
#
#    Then I initiate transfer out to transfer funds to an external account from CASH_SERVICE and expect the header status <status_code> and status as TRANSACTION_FAILED
#      | identifier | customer_profile_id | account_id                | txn_currency | txn_amount   | purpose          | txn_mode | transfer_out_account_details                                                                                                                                                                                              | metadata                    | currency | total_balance    | available_balance |
#      | TxnId1     | PSCPID4             | CustomerProfileAccountId1 | SGD          | <txn_amount> | Internal Pay Out | PAYNOW   | {"email": "receiver@abc.com","address": "Wakanda", "account_details": {'account_holder' : 'ABC' , 'country': 'SGP', 'currency': 'SGD', 'code_details': {'sg_identification_details': {'fin': 'S8439061E'}}}}  | {"key": "External Pay Out"} | SGD      | <deposit_amount> | <deposit_amount>  |
#
#    Examples:
#      | txn_amount | currency | country | bank_name    | status_code | request_origin | on_behalf_of | metadata                    | deposit_amount |
#      | 10         | SGD      | SGP     | DBS Bank Ltd | PTM_1600    | CASH_SERVICE           | CUSTOMER     | {"key": "External Pay Out"} | 100            |
#      | 20         | SGD      | SGP     | DBS Bank Ltd | PTM_1600    | CASH_SERVICE           | CUSTOMER     | {"key": "External Pay Out"} | 100            |
#
#  Scenario Outline: I call TransferOut to transfer an amount between internal Hugohub customer profile account and external account with mobile number from CASH_SERVICE on behalf of CUSTOMER and with insufficient balance verify the transaction is failed with transaction mode PAYNOW
#
#    Given I create below Customer
#      | customer_identifier | name | date       |
#      | PSCID5              | hugo | 01-01-2001 |
#
#    Then I create below Customer-Profile
#      | customer_identifier | customer_profile_identifier | region | name  | email          | phone_number |
#      | PSCID5              | PSCPID5                     | SG     | Stark | hugo@atlas.com | 8989548747   |
#
#    Then I verify Customer-Profile exist with values
#      | customer_identifier | customer_profile_identifier | region | name  | email          | phone_number | status |
#      | PSCID5              | PSCPID5                     | SG     | Stark | hugo@atlas.com | 8989548747   | ACTIVE |
#
#    Given I onboard CustomerProfile PSCPID5 with customerId PSCID5 on payment service from CASH_SERVICE on behalf of <on_behalf_of> on below providers and expect status 200
#      | provider_name |
#      | DBS Bank Ltd  |
#
#    Then I wait until max time to verify the master account MASAccId1 with master account status MASTER_ACCOUNT_CREATED for the customer profile PSCPID5 on behalf of <on_behalf_of> status as ONBOARD_SUCCESS with provider DBS Bank Ltd
#
#    Given I create account for CustomerProfile with customerProfileId PSCPID5 from <request_origin> on behalf of <on_behalf_of> with provider DBS Bank Ltd and expect the header status 200
#      | identifier                | currency   | country   | metadata   | on_behalf_of   |
#      | CustomerProfileAccountId1 | <currency> | <country> | <metadata> | <on_behalf_of> |
#
#    Then I wait until max time to verify the payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID5
#
#    Then I verify CustomerProfile with id PSCPID5 has payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> exists with provider <bank_name> with values
#      | account_id                | provider_id                         | currency | account_status  | country   | metadata   | on_behalf_of   |
#      | CustomerProfileAccountId1 | DBS-SG | SGD      | ACCOUNT_CREATED | <country> | <metadata> | <on_behalf_of> |
#
#    Then I retrieve the payment account CustomerProfileAccountId1 from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID5
#
#    Then I initiate transfer out to transfer funds to an external account from CASH_SERVICE and expect the header status <status_code> and status as TRANSACTION_FAILED
#      | identifier | customer_profile_id | account_id                | txn_currency | txn_amount   | purpose          | txn_mode | transfer_out_account_details                                                                                                                                                                                              | metadata                    | currency | total_balance    | available_balance |
#      | TxnId1     | PSCPID5             | CustomerProfileAccountId1 | SGD          | <txn_amount> | Internal Pay Out | PAYNOW   | {"email": "receiver@abc.com","address": "Wakanda", "account_details": {'mobile':'+6598765432', 'account_holder' : 'ABC', 'country': 'SGP', 'currency': 'SGD'}}  | {"key": "External Pay Out"} | SGD      | <deposit_amount> | <deposit_amount>  |
#
#    Examples:
#      | txn_amount | currency | country | bank_name    | status_code | request_origin | on_behalf_of | metadata                    | deposit_amount |
#      | 10         | SGD      | SGP     | DBS Bank Ltd | PTM_1600    | CASH_SERVICE           | CUSTOMER     | {"key": "External Pay Out"} | 100            |
#      | 20         | SGD      | SGP     | DBS Bank Ltd | PTM_1600    | CASH_SERVICE           | CUSTOMER     | {"key": "External Pay Out"} | 100            |
#
#  Scenario Outline: I call TransferOut to transfer an amount between internal Hugohub customer profile account and external account with vpa from CASH_SERVICE on behalf of CUSTOMER and with insufficient balance verify the transaction is failed with transaction mode PAYNOW
#
#    Given I create below Customer
#      | customer_identifier | name | date       |
#      | PSCID6              | hugo | 01-01-2001 |
#
#    Then I create below Customer-Profile
#      | customer_identifier | customer_profile_identifier | region | name  | email          | phone_number |
#      | PSCID6              | PSCPID6                     | SG     | Stark | hugo@atlas.com | 8989548747   |
#
#    Then I verify Customer-Profile exist with values
#      | customer_identifier | customer_profile_identifier | region | name  | email          | phone_number | status |
#      | PSCID6              | PSCPID6                     | SG     | Stark | hugo@atlas.com | 8989548747   | ACTIVE |
#
#    Given I onboard CustomerProfile PSCPID6 with customerId PSCID6 on payment service from CASH_SERVICE on behalf of <on_behalf_of> on below providers and expect status 200
#      | provider_name |
#      | DBS Bank Ltd  |
#
#    Then I wait until max time to verify the master account MASAccId1 with master account status MASTER_ACCOUNT_CREATED for the customer profile PSCPID6 on behalf of <on_behalf_of> status as ONBOARD_SUCCESS with provider DBS Bank Ltd
#
#    Given I create account for CustomerProfile with customerProfileId PSCPID6 from <request_origin> on behalf of <on_behalf_of> with provider DBS Bank Ltd and expect the header status 200
#      | identifier                | currency   | country   | metadata   | on_behalf_of   |
#      | CustomerProfileAccountId1 | <currency> | <country> | <metadata> | <on_behalf_of> |
#
#    Then I wait until max time to verify the payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID6
#
#    Then I verify CustomerProfile with id PSCPID6 has payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> exists with provider <bank_name> with values
#      | account_id                | provider_id                         | currency | account_status  | country   | metadata   | on_behalf_of   |
#      | CustomerProfileAccountId1 | DBS-SG | SGD      | ACCOUNT_CREATED | <country> | <metadata> | <on_behalf_of> |
#
#    Then I retrieve the payment account CustomerProfileAccountId1 from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID6
#
#    Then I initiate transfer out to transfer funds to an external account from CASH_SERVICE and expect the header status <status_code> and status as TRANSACTION_FAILED
#      | identifier | customer_profile_id | account_id                | txn_currency | txn_amount   | purpose          | txn_mode | transfer_out_account_details                                                                                                                                                 | metadata                    | currency | total_balance    | available_balance |
#      | TxnId1     | PSCPID6             | CustomerProfileAccountId1 | SGD          | <txn_amount> | Internal Pay Out | PAYNOW   | {"email": "receiver@abc.com","address": "Wakanda", "account_details": {'vpa':'9876543210@ybl' , 'account_holder' : 'ABC', 'country': 'SGP', 'currency': 'SGD'}}  | {"key": "External Pay Out"} | SGD      | <deposit_amount> | <deposit_amount>  |
#
#    Examples:
#      | txn_amount | currency | country | bank_name    | status_code | request_origin | on_behalf_of | metadata                    | deposit_amount |
#      | 10         | SGD      | SGP     | DBS Bank Ltd | PTM_1600    | CASH_SERVICE           | CUSTOMER     | {"key": "External Pay Out"} | 100            |
#      | 20         | SGD      | SGP     | DBS Bank Ltd | PTM_1600    | CASH_SERVICE           | CUSTOMER     | {"key": "External Pay Out"} | 100            |
#
#  Scenario Outline: I call TransferOut to transfer an amount between internal Hugohub customer profile account and external account with email from CASH_SERVICE on behalf of CUSTOMER and with insufficient balance verify the transaction is failed with transaction mode PAYNOW
#
#    Given I create below Customer
#      | customer_identifier | name | date       |
#      | PSCID7              | hugo | 01-01-2001 |
#
#    Then I create below Customer-Profile
#      | customer_identifier | customer_profile_identifier | region | name  | email          | phone_number |
#      | PSCID7              | PSCPID7                     | SG     | Stark | hugo@atlas.com | 8989548747   |
#
#    Then I verify Customer-Profile exist with values
#      | customer_identifier | customer_profile_identifier | region | name  | email          | phone_number | status |
#      | PSCID7              | PSCPID7                     | SG     | Stark | hugo@atlas.com | 8989548747   | ACTIVE |
#
#    Given I onboard CustomerProfile PSCPID7 with customerId PSCID7 on payment service from CASH_SERVICE on behalf of <on_behalf_of> on below providers and expect status 200
#      | provider_name |
#      | DBS Bank Ltd  |
#
#    Then I wait until max time to verify the master account MASAccId1 with master account status MASTER_ACCOUNT_CREATED for the customer profile PSCPID7 on behalf of <on_behalf_of> status as ONBOARD_SUCCESS with provider DBS Bank Ltd
#
#    Given I create account for CustomerProfile with customerProfileId PSCPID7 from <request_origin> on behalf of <on_behalf_of> with provider DBS Bank Ltd and expect the header status 200
#      | identifier                | currency   | country   | metadata   | on_behalf_of   |
#      | CustomerProfileAccountId1 | <currency> | <country> | <metadata> | <on_behalf_of> |
#
#    Then I wait until max time to verify the payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID7
#
#    Then I verify CustomerProfile with id PSCPID7 has payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> exists with provider <bank_name> with values
#      | account_id                | provider_id                         | currency | account_status  | country   | metadata   | on_behalf_of   |
#      | CustomerProfileAccountId1 | DBS-SG | SGD      | ACCOUNT_CREATED | <country> | <metadata> | <on_behalf_of> |
#
#    Then I retrieve the payment account CustomerProfileAccountId1 from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID7
#
#    Then I initiate transfer out to transfer funds to an external account from CASH_SERVICE and expect the header status <status_code> and status as TRANSACTION_FAILED
#      | identifier | customer_profile_id | account_id                | txn_currency | txn_amount   | purpose          | txn_mode | transfer_out_account_details                                                                                                                         | metadata                    | currency | total_balance    | available_balance |
#      | TxnId1     | PSCPID7             | CustomerProfileAccountId1 | SGD          | <txn_amount> | Internal Pay Out | PAYNOW   | {"address": "Wakanda", "account_details": {'email': 'receiver@abc.com', 'account_holder' : 'ABC', 'country': 'SGP', 'currency': 'SGD'}}  | {"key": "External Pay Out"} | SGD      | <deposit_amount> | <deposit_amount>  |
#
#    Examples:
#      | txn_amount | currency | country | bank_name    | status_code | request_origin | on_behalf_of | metadata                    | deposit_amount |
#      | 10         | SGD      | SGP     | DBS Bank Ltd | PTM_1600    | CASH_SERVICE           | CUSTOMER     | {"key": "External Pay Out"} | 100            |
#      | 20         | SGD      | SGP     | DBS Bank Ltd | PTM_1600    | CASH_SERVICE           | CUSTOMER     | {"key": "External Pay Out"} | 100            |
#
#  Scenario Outline: I call TransferOut to transfer an amount between internal Hugohub customer profile account and external account with UEN number from CASH_SERVICE on behalf of CUSTOMER and with insufficient balance verify the transaction is failed with transaction mode PAYNOW
#
#    Given I create below Customer
#      | customer_identifier | name | date       |
#      | PSCID8              | hugo | 01-01-2001 |
#
#    Then I create below Customer-Profile
#      | customer_identifier | customer_profile_identifier | region | name  | email          | phone_number |
#      | PSCID8              | PSCPID8                     | SG     | Stark | hugo@atlas.com | 8989548747   |
#
#    Then I verify Customer-Profile exist with values
#      | customer_identifier | customer_profile_identifier | region | name  | email          | phone_number | status |
#      | PSCID8              | PSCPID8                     | SG     | Stark | hugo@atlas.com | 8989548747   | ACTIVE |
#
#    Given I onboard CustomerProfile PSCPID8 with customerId PSCID8 on payment service from CASH_SERVICE on behalf of <on_behalf_of> on below providers and expect status 200
#      | provider_name |
#      | DBS Bank Ltd  |
#
#    Then I wait until max time to verify the master account MASAccId1 with master account status MASTER_ACCOUNT_CREATED for the customer profile PSCPID8 on behalf of <on_behalf_of> status as ONBOARD_SUCCESS with provider DBS Bank Ltd
#
#    Given I create account for CustomerProfile with customerProfileId PSCPID8 from <request_origin> on behalf of <on_behalf_of> with provider DBS Bank Ltd and expect the header status 200
#      | identifier                | currency   | country   | metadata   | on_behalf_of   |
#      | CustomerProfileAccountId1 | <currency> | <country> | <metadata> | <on_behalf_of> |
#
#    Then I wait until max time to verify the payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID8
#
#    Then I verify CustomerProfile with id PSCPID8 has payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> exists with provider <bank_name> with values
#      | account_id                | provider_id                         | currency | account_status  | country   | metadata   | on_behalf_of   |
#      | CustomerProfileAccountId1 | DBS-SG | SGD      | ACCOUNT_CREATED | <country> | <metadata> | <on_behalf_of> |
#
#    Then I retrieve the payment account CustomerProfileAccountId1 from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID8
#
#    Then I initiate transfer out to transfer funds to an external account from CASH_SERVICE and expect the header status <status_code> and status as TRANSACTION_FAILED
#      | identifier | customer_profile_id | account_id                | txn_currency | txn_amount   | purpose          | txn_mode | transfer_out_account_details                                                                                                                                                                                             | metadata                    | currency | total_balance    | available_balance |
#      | TxnId1     | PSCPID8             | CustomerProfileAccountId1 | SGD          | <txn_amount> | Internal Pay Out | PAYNOW   | {"email": "receiver@abc.com","address": "Wakanda", "account_details": {'account_holder' : 'ABC', 'country': 'SGP', 'currency': 'SGD', 'code_details': {'sg_identification_details': {'uen': '53361549J'}}}}  | {"key": "External Pay Out"} | SGD      | <deposit_amount> | <deposit_amount>  |
#
#    Examples:
#      | txn_amount | currency | country | bank_name    | status_code | request_origin | on_behalf_of | metadata                    | deposit_amount |
#      | 10         | SGD      | SGP     | DBS Bank Ltd | PTM_1600    | CASH_SERVICE           | CUSTOMER     | {"key": "External Pay Out"} | 100            |
#      | 20         | SGD      | SGP     | DBS Bank Ltd | PTM_1600    | CASH_SERVICE           | CUSTOMER     | {"key": "External Pay Out"} | 100            |
#
#  Scenario Outline: I call TransferOut to transfer an amount between internal Hugohub customer profile account and external account by passing all details of receiver from CASH_SERVICE on behalf of CUSTOMER and verify the transaction is settled with transaction mode PAYNOW
#
#    Given I create account for CustomerProfile with customerProfileId PSCPID1 from <request_origin> on behalf of <on_behalf_of> with provider DBS Bank Ltd and expect the header status <status_code>
#      | identifier                | currency   | country   | metadata   | on_behalf_of   |
#      | CustomerProfileAccountId1 | <currency> | <country> | <metadata> | <on_behalf_of> |
#
#    Then I wait until max time to verify the payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID1
#
#    Then I verify CustomerProfile with id PSCPID1 has payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> exists with provider <bank_name> with values
#      | account_id                | provider_id                         | currency | account_status  | country   | metadata   | on_behalf_of   |
#      | CustomerProfileAccountId1 | DBS-SG | SGD      | ACCOUNT_CREATED | <country> | <metadata> | <on_behalf_of> |
#
#    Then I retrieve the payment account CustomerProfileAccountId1 from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID1
#
#    Given I deposit an amount of <deposit_amount> into account CustomerProfileAccountId1 using ICN for customerProfileId PSCPID1
#      | identifier    | customer_profile_id | header                                                                                         | txn_info                                                                                                                                                                                                                                                                                                                                                  |
#      | ICNIdentifier | PSCPID1             | {"msgId":"ICNIdentifier","orgId":"ATLCONS3","ctry":"SG","timeStamp":"2023-11-28T11:00:00.000"} | {"amt_dtls": {"txn_amt": "100","txn_ccy": "SGD"},"customer_reference": "ICNIdentifier","sender_party": { "name": "HUGO","sender_bank_id": "DBSSSGSGXXX"},"txn_ref_id": "ICNIdentifier","receiving_party": {"account_no":"88532600026958397","name": "ATLAS CONSOLIDATED PTE. LTD."},"txn_type":"FAST","txn_date": "2023-11-28","value_dt": "2023-11-28" } |
#
#    Then I wait until max time to verify master account CustomerProfileAccountId1 with an increased updated balance of <deposit_amount> for customerProfileId PSCPID1
#
#    Then I initiate transfer out to transfer funds to an external account from CASH_SERVICE and expect the header status <status_code> and status as TRANSACTION_PENDING
#      | identifier | customer_profile_id | account_id                | txn_currency | txn_amount   | purpose          | txn_mode | transfer_out_account_details                                                                                                                                                                                                                                                                                                       | metadata                    | currency | total_balance    | available_balance |
#      | TxnId1     | PSCPID1             | CustomerProfileAccountId1 | SGD          | <txn_amount> | Internal Pay Out | PAYNOW   | {"email": "receiver@abc.com","address": "Wakanda", "account_details": {'mobile' : '+6598765432' , 'email' : 'abc@email.com' , 'vpa' : '9876543210@ybl' , 'account_holder' : 'ABC' , 'country': 'SGP', 'currency': 'SGD', 'code_details': {'sg_identification_details': {'nric': 'S8439061E' , 'uen': '53361549J' }}}} | {"key": "External Pay Out"} | SGD      | <deposit_amount> | <deposit_amount>  |
#
#    Then I wait until max time to verify the transaction TxnId1 status as TRANSACTION_SETTLED for customerProfileId PSCPID1 from CASH_SERVICE
#
#    Examples:
#      | txn_amount | currency | country | bank_name    | status_code | request_origin | on_behalf_of | metadata                    | deposit_amount |
#      | 10         | SGD      | SGP     | DBS Bank Ltd | 200         | CASH_SERVICE           | CUSTOMER     | {"key": "External Pay Out"} | 100            |
#      | 20         | SGD      | SGP     | DBS Bank Ltd | 200         | CASH_SERVICE           | CUSTOMER     | {"key": "External Pay Out"} | 100            |
#
#  Scenario Outline: I call TransferOut to transfer an amount between internal Hugohub customer profile account and external account without passing any  details of receiver from CASH_SERVICE on behalf of CUSTOMER and verify the transaction is failed with transaction mode PAYNOW
#
#    Given I create account for CustomerProfile with customerProfileId PSCPID1 from <request_origin> on behalf of <on_behalf_of> with provider DBS Bank Ltd and expect the header status <status_code>
#      | identifier                | currency   | country   | metadata   | on_behalf_of   |
#      | CustomerProfileAccountId1 | <currency> | <country> | <metadata> | <on_behalf_of> |
#
#    Then I wait until max time to verify the payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID1
#
#    Then I verify CustomerProfile with id PSCPID1 has payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> exists with provider <bank_name> with values
#      | account_id                | provider_id                         | currency | account_status  | country   | metadata   | on_behalf_of   |
#      | CustomerProfileAccountId1 | DBS-SG | SGD      | ACCOUNT_CREATED | <country> | <metadata> | <on_behalf_of> |
#
#    Then I retrieve the payment account CustomerProfileAccountId1 from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID1
#
#    Given I deposit an amount of <deposit_amount> into account CustomerProfileAccountId1 using ICN for customerProfileId PSCPID1
#      | identifier    | customer_profile_id | header                                                                                         | txn_info                                                                                                                                                                                                                                                                                                                                                  |
#      | ICNIdentifier | PSCPID1             | {"msgId":"ICNIdentifier","orgId":"ATLCONS3","ctry":"SG","timeStamp":"2023-11-28T11:00:00.000"} | {"amt_dtls": {"txn_amt": "100","txn_ccy": "SGD"},"customer_reference": "ICNIdentifier","sender_party": { "name": "HUGO","sender_bank_id": "DBSSSGSGXXX"},"txn_ref_id": "ICNIdentifier","receiving_party": {"account_no":"88532600026958397","name": "ATLAS CONSOLIDATED PTE. LTD."},"txn_type":"FAST","txn_date": "2023-11-28","value_dt": "2023-11-28" } |
#
#    Then I wait until max time to verify master account CustomerProfileAccountId1 with an increased updated balance of <deposit_amount> for customerProfileId PSCPID1
#
#    Then I initiate transfer out to transfer funds to an external account from CASH_SERVICE and expect the header status <status_code> with error status as <error_status_code>
#      | identifier | customer_profile_id | account_id                | txn_currency | txn_amount   | purpose          | txn_mode | transfer_out_account_details                                                                       | metadata                    | currency | total_balance    | available_balance |
#      | TxnId1     | PSCPID1             | CustomerProfileAccountId1 | SGD          | <txn_amount> | Internal Pay Out | PAYNOW   | { "account_details": {'account_holder' : 'ABC' , 'country': 'SGP', 'currency': 'SGD'}} | {"key": "External Pay Out"} | SGD      | <deposit_amount> | <deposit_amount>  |
#
#
#    Examples:
#      | txn_amount | currency | country | bank_name    | status_code | request_origin | on_behalf_of | metadata                    | deposit_amount | error_status_code |
#      | 10         | SGD      | SGP     | DBS Bank Ltd | 200         | CASH_SERVICE           | CUSTOMER     | {"key": "External Pay Out"} | 100            | E9400             |
#      | 20         | SGD      | SGP     | DBS Bank Ltd | 200         | CASH_SERVICE           | CUSTOMER     | {"key": "External Pay Out"} | 100            | E9400             |
