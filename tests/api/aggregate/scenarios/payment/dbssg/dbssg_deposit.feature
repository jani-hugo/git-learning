Feature: Payment Service DBSSG Deposit Notification --- ICN and IDN

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

    Given I create account for CustomerProfile with customerProfileId PSCPID1 from CASH_SERVICE on behalf of CUSTOMER with provider DBS Bank Ltd and expect the header status 200
      | identifier        | currency | country | metadata                    | on_behalf_of |
      | CustomerAccountId | SGD      | SGP     | {"key": "IntegrationTest1"} | CUSTOMER     |

    Then I wait until max time to verify the payment account CustomerAccountId from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID1

    Then I verify CustomerProfile with id PSCPID1 has payment account CustomerAccountId from CASH_SERVICE on behalf of CUSTOMER exists with provider DBS Bank Ltd with values
      | account_id        | provider_id | currency | account_status  | metadata                    | on_behalf_of |
      | CustomerAccountId | DBS-SG      | SGD      | ACCOUNT_CREATED | {"key": "IntegrationTest1"} | CUSTOMER     |

    Given I create account for EndCustomerProfile with id ECPID1 for CustomerProfile PSCPID1 from CASH_SERVICE on behalf of CUSTOMER with provider DBS Bank Ltd and expect the header status 200
      | identifier | currency | country | metadata                    | on_behalf_of |
      | AccountId  | SGD      | SGP     | {"key": "IntegrationTest1"} | CUSTOMER     |

    Then I wait until max time to verify the payment account AccountId from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID1

    Then I verify CustomerProfile with id PSCPID1 has payment account AccountId from CASH_SERVICE on behalf of CUSTOMER exists with provider DBS Bank Ltd with values
      | account_id | provider_id | currency | account_status  | metadata                    | on_behalf_of |
      | AccountId  | DBS-SG      | SGD      | ACCOUNT_CREATED | {"key": "IntegrationTest1"} | CUSTOMER     |

  Scenario Outline: ICN Deposit Notification --- Deposit amount into customer profile account using ICN and check if balance of the account

    Then I retrieve the payment account CustomerAccountId from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID1

    Given I deposit an amount of <amount> into account CustomerAccountId using ICN for customerProfileId PSCPID1
      | identifier    | customer_profile_id | header                                                                                         | txn_info                                                                                                                                                                                                                                                                                                                                                  |
      | ICNIdentifier | PSCPID1             | {"msgId":"ICNIdentifier","orgId":"ATLCONS3","ctry":"SG","timeStamp":"2023-11-28T11:00:00.000"} | {"amt_dtls": {"txn_amt": "100","txn_ccy": "SGD"},"customer_reference": "ICNIdentifier","sender_party": { "name": "HUGO","sender_bank_id": "DBSSSGSGXXX"},"txn_ref_id": "ICNIdentifier","receiving_party": {"account_no":"88532600026958397","name": "ATLAS CONSOLIDATED PTE. LTD."},"txn_type":"FAST","txn_date": "2023-11-28","value_dt": "2023-11-28" } |

    Then I wait until max time to verify master account CustomerAccountId with an increased updated balance of <amount> for customerProfileId PSCPID1
    Examples:
      | amount |
      | 100    |

  Scenario Outline: ICN Deposit Notification --- Deposit amount into end customer profile account using ICN and check if balance of the account

    Then I retrieve the payment account AccountId from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID1

    Given I deposit an amount of <amount> into account AccountId using ICN for customerProfileId PSCPID1
      | identifier    | customer_profile_id | header                                                                                         | txn_info                                                                                                                                                                                                                                                                                                                                                  |
      | ICNIdentifier | PSCPID1             | {"msgId":"ICNIdentifier","orgId":"ATLCONS3","ctry":"SG","timeStamp":"2023-11-28T11:00:00.000"} | {"amt_dtls": {"txn_amt": "100","txn_ccy": "SGD"},"customer_reference": "ICNIdentifier","sender_party": { "name": "HUGO","sender_bank_id": "DBSSSGSGXXX"},"txn_ref_id": "ICNIdentifier","receiving_party": {"account_no":"88532600026958397","name": "ATLAS CONSOLIDATED PTE. LTD."},"txn_type":"FAST","txn_date": "2023-11-28","value_dt": "2023-11-28" } |

    Then I wait until max time to verify master account AccountId with an increased updated balance of <amount> for customerProfileId PSCPID1
    Examples:
      | amount |
      | 100    |

  Scenario Outline: IDN Deposit Notification --- Deposit amount into customer profile account using ICN and check if balance of the account

    Then I retrieve the payment account CustomerAccountId from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID1

    Given I deposit an amount of <amount> into account CustomerAccountId using IDN for customerProfileId PSCPID1
      | identifier    | customer_profile_id | header                                                                                         | txn_info                                                                                                                                                                                                                                                                                                                                                  |
      | IDNIdentifier | PSCPID1             | {"msgId":"IDNIdentifier","orgId":"ATLCONS3","ctry":"SG","timeStamp":"2023-01-06T09:48:59.457"} | {"amt_dtls": {"txn_amt": "150","txn_ccy": "SGD"},"customer_reference": "IDNIdentifier","sender_party": { "name": "HUGO","sender_bank_id": "DBSSSGSGXXX"},"txn_ref_id": "IDNIdentifier","receiving_party": {"account_no":"88532600026958397","name": "ATLAS CONSOLIDATED PTE. LTD."},"txn_type":"FAST","txn_date": "2023-01-06","value_dt": "2023-01-06" } |

    Then I wait until max time to verify master account CustomerAccountId with an increased updated balance of <amount> for customerProfileId PSCPID1
    Examples:
      | amount |
      | 100    |

  Scenario Outline: IDN Deposit Notification --- Deposit amount into end customer profile account using IDN and check if balance of the account

    Then I retrieve the payment account AccountId from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID1

    Given I deposit an amount of <amount> into account AccountId using IDN for customerProfileId PSCPID1
      | identifier    | customer_profile_id | header                                                                                         | txn_info                                                                                                                                                                                                                                                                                                                                                  |
      | IDNIdentifier | PSCPID1             | {"msgId":"ICNIdentifier","orgId":"ATLCONS3","ctry":"SG","timeStamp":"2023-01-06T09:48:59.457"} | {"amt_dtls": {"txn_amt": "150","txn_ccy": "SGD"},"customer_reference": "IDNIdentifier","sender_party": { "name": "HUGO","sender_bank_id": "DBSSSGSGXXX"},"txn_ref_id": "IDNIdentifier","receiving_party": {"account_no":"88532600026958397","name": "ATLAS CONSOLIDATED PTE. LTD."},"txn_type":"FAST","txn_date": "2023-01-06","value_dt": "2023-01-06" } |

    Then I wait until max time to verify master account AccountId with an increased updated balance of <amount> for customerProfileId PSCPID1
    Examples:
      | amount |
      | 100    |

  Scenario Outline: IDN Deposit Notification --- Deposit amount into master account using IDN and check if balance of the account

    Then I retrieve the payment account AccountId from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID1

    Given I deposit an amount of <amount> into master account AccountId using IDN for customerProfileId PSCPID1
      | identifier    | customer_profile_id | header                                                                                         | txn_info                                                                                                                                                                                                                                                                                                                                                  |
      | IDNIdentifier | PSCPID1             | {"msgId":"ICNIdentifier","orgId":"ATLCONS3","ctry":"SG","timeStamp":"2023-01-06T09:48:59.457"} | {"amt_dtls": {"txn_amt": "150","txn_ccy": "SGD"},"customer_reference": "IDNIdentifier","sender_party": { "name": "HUGO","sender_bank_id": "DBSSSGSGXXX"},"txn_ref_id": "IDNIdentifier","receiving_party": {"account_no":"88532600026958397","name": "ATLAS CONSOLIDATED PTE. LTD."},"txn_type":"FAST","txn_date": "2023-01-06","value_dt": "2023-01-06" } |

    Then I wait until max time to verify master account AccountId with an increased updated balance of <amount> for customerProfileId PSCPID1
    Examples:
      | amount |
      | 100    |

  Scenario Outline: ICN Deposit Notification --- Deposit amount into master account using ICN and check if balance of the account

    Then I retrieve the payment account AccountId from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId PSCPID1

    Given I deposit an amount of <amount> into master account AccountId using ICN for customerProfileId PSCPID1
      | identifier    | customer_profile_id | header                                                                                         | txn_info                                                                                                                                                                                                                                                                                                                                                  |
      | ICNIdentifier | PSCPID1             | {"msgId":"ICNIdentifier","orgId":"ATLCONS3","ctry":"SG","timeStamp":"2023-11-28T11:00:00.000"} | {"amt_dtls": {"txn_amt": "100","txn_ccy": "SGD"},"customer_reference": "ICNIdentifier","sender_party": { "name": "HUGO","sender_bank_id": "DBSSSGSGXXX"},"txn_ref_id": "ICNIdentifier","receiving_party": {"account_no":"88532600026958397","name": "ATLAS CONSOLIDATED PTE. LTD."},"txn_type":"FAST","txn_date": "2023-11-28","value_dt": "2023-11-28" } |

    Then I wait until max time to verify master account AccountId with an increased updated balance of <amount> for customerProfileId PSCPID1
    Examples:
      | amount |
      | 100    |
