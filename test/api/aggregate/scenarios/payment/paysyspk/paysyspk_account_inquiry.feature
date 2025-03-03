Feature: Payment Service Account Inquiry for provider Paysys

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


  Scenario Outline: Existing payment account is inquiring the internal CustomerProfile Account from request origin as CASH_SERVICE and on behalf of CUSTOMER and verify it's processed successfully

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

    Then I initiate a request to inquiry an internal account CustomerProfileAccountId1 from CASH_SERVICE and expect the header status <status_code> in Paysys
      | identifier        | account_id                | customer_profile_id | txn_mode   | amount   | receiver_details                                                                                                                                                          |
      | InquiryIdentifier | CustomerProfileAccountId2 | PSCPID1             | <txn_mode> | <amount> | { "country" : "PAK" , "code_details": { 'pk_account': { 'account_number': 'InquiryIdentifier', 'bank_bic':'HUGOPKKA' , 'bank_imd':'998890', 'iban':'InquiryIdentifier'}}} |

    Examples:
      | currency | country | amount | txn_mode | metadata                    | request_origin | on_behalf_of | country | status_code |
      | PKR      | PAK     | 20     | RAASTP2P | {"key": "IntegrationTest1"} | CASH_SERVICE           | CUSTOMER     | PAK     | 200         |
      | PKR      | PAK     | 0      | RAASTP2P | {"key": "IntegrationTest2"} | CASH_SERVICE           | CUSTOMER     | PAK     | 200         |
      | PKR      | PAK     | 20     | 1LINK    | {"key": "IntegrationTest3"} | CASH_SERVICE           | CUSTOMER     | PAK     | 200         |
      | PKR      | PAK     | 0      | 1LINK    | {"key": "IntegrationTest4"} | CASH_SERVICE           | CUSTOMER     | PAK     | 200         |

  Scenario Outline: Existing payment account is inquiring the internal EndCustomerProfile Account from request origin as CASH_SERVICE and on behalf of CUSTOMER and verify it's processed successfully

    Given I create account for EndCustomerProfile with id ECPID1 for CustomerProfile PSCPID1 from <request_origin> on behalf of <on_behalf_of> with provider PAYSYS and expect the header status <status_code>
      | identifier                   | currency   | country   | metadata   | on_behalf_of   |
      | EndCustomerProfileAccountId1 | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account EndCustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I verify EndCustomerProfile with id ECPID1 for CustomerProfile PSCPID1 has payment account AccountId from <request_origin> on behalf of <on_behalf_of> exists with provider PAYSYS with values
      | identifier                   | provider_id | currency | country | account_status  | metadata   | on_behalf_of   |
      | EndCustomerProfileAccountId1 | PAYSYS-PK   | PKR      | PAK     | ACCOUNT_CREATED | <metadata> | <on_behalf_of> |

    Given I create account for EndCustomerProfile with id ECPID1 for CustomerProfile PSCPID1 from <request_origin> on behalf of <on_behalf_of> with provider PAYSYS and expect the header status <status_code>
      | identifier                   | currency   | country   | metadata   | on_behalf_of   |
      | EndCustomerProfileAccountId2 | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account EndCustomerProfileAccountId2 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I verify EndCustomerProfile with id ECPID1 for CustomerProfile PSCPID1 has payment account AccountId from <request_origin> on behalf of <on_behalf_of> exists with provider PAYSYS with values
      | identifier                   | provider_id | currency | country | account_status  | metadata   | on_behalf_of   |
      | EndCustomerProfileAccountId2 | PAYSYS-PK   | PKR      | PAK     | ACCOUNT_CREATED | <metadata> | <on_behalf_of> |

    Then I retrieve the payment account EndCustomerProfileAccountId1 from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I initiate a request to inquiry an internal account EndCustomerProfileAccountId1 from CASH_SERVICE and expect the header status <status_code> in Paysys
      | identifier        | account_id                   | customer_profile_id | txn_mode | receiver_details                                                                                                                                                          |
      | InquiryIdentifier | EndCustomerProfileAccountId2 | PSCPID1             | RAASTP2P | { "country" : "PAK" , "code_details": { 'pk_account': { 'account_number': 'InquiryIdentifier', 'bank_bic':'HUGOPKKA' , 'bank_imd':'998890', 'iban':'InquiryIdentifier'}}} |

    Examples:
      | currency | country | metadata                   | request_origin | on_behalf_of | country | status_code |
      | PKR      | PAK     | {"key": "IntegrationTest"} | CASH_SERVICE           | CUSTOMER     | PAK     | 200         |

  Scenario Outline: Existing payment account is inquiring the internal CustomerProfile Account where TxnMode is not passed from request origin as CASH_SERVICE and on behalf of CUSTOMER and verify it's processed successfully

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

    Then I initiate a request to inquiry an internal account CustomerProfileAccountId1 from CASH_SERVICE and expect the header status <status_code> in Paysys
      | identifier        | account_id                | customer_profile_id | amount   | receiver_details                                                                                                                                                          |
      | InquiryIdentifier | CustomerProfileAccountId2 | PSCPID1             | <amount> | { "country" : "PAK" , "code_details": { 'pk_account': { 'account_number': 'InquiryIdentifier', 'bank_bic':'HUGOPKKA' , 'bank_imd':'998890', 'iban':'InquiryIdentifier'}}} |

    Examples:
      | currency | country | amount | metadata                    | request_origin | on_behalf_of | country | status_code |
      | PKR      | PAK     | 20     | {"key": "IntegrationTest1"} | CASH_SERVICE           | CUSTOMER     | PAK     | 200         |

  Scenario Outline: Existing payment account is inquiring the external Account where invalid bankCode is passed from request origin as CASH_SERVICE and on behalf of CUSTOMER and verify it's failed

    Given I create account for CustomerProfile with customerProfileId PSCPID1 from <request_origin> on behalf of <on_behalf_of> with provider PAYSYS and expect the header status <status_code>
      | identifier                | currency   | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I verify CustomerProfile with id PSCPID1 has payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> exists with provider PAYSYS with values
      | account_id                | provider_id | currency | account_status  | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | PAYSYS-PK   | PKR      | ACCOUNT_CREATED | <country> | <metadata> | <on_behalf_of> |

    Then I initiate a request to inquiry an external account from CASH_SERVICE and expect the header status PTM_1404 in Paysys
      | identifier        | account_id                | customer_profile_id | txn_mode   | amount   | receiver_details                                                                                                                                       |
      | InquiryIdentifier | CustomerProfileAccountId1 | PSCPID1             | <txn_mode> | <amount> | { "country" : "PAK" , "code_details": { 'pk_account': { 'account_number': '123456789', 'bank_bic':'NBPBPKKAXXX' , 'bank_imd':'601492', 'iban':'PK76NBPA1234567890000999'}}} |

    Examples:
      | currency | country | amount | txn_mode | metadata                    | request_origin | on_behalf_of | country | status_code |
      | PKR      | PAK     | 20     | RAASTP2P | {"key": "IntegrationTest1"} | CASH_SERVICE           | CUSTOMER     | PAK     | 200         |
      | PKR      | PAK     | 20     | 1LINK    | {"key": "IntegrationTest3"} | CASH_SERVICE           | CUSTOMER     | PAK     | 200         |

  Scenario Outline: Existing payment account is inquiring the external Account from request origin as CASH_SERVICE and on behalf of CUSTOMER and verify it's processed successfully

    Given I create account for CustomerProfile with customerProfileId PSCPID1 from <request_origin> on behalf of <on_behalf_of> with provider PAYSYS and expect the header status <status_code>
      | identifier                | currency   | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I verify CustomerProfile with id PSCPID1 has payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> exists with provider PAYSYS with values
      | account_id                | provider_id | currency | account_status  | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | PAYSYS-PK   | PKR      | ACCOUNT_CREATED | <country> | <metadata> | <on_behalf_of> |

    Then I initiate a request to inquiry an external account from CASH_SERVICE and expect the header status <status_code> in Paysys
      | identifier        | account_id                | customer_profile_id | txn_mode   | amount   | receiver_details                                                                                                                                                         |
      | InquiryIdentifier | CustomerProfileAccountId1 | PSCPID1             | <txn_mode> | <amount> | { "country" : "PAK" , "code_details": { 'pk_account': { 'account_number': '123456789', 'bank_bic':'TMICFBPK' , 'bank_imd':'639390', 'iban':'PK76NBPA1234567890000999'}}} |

    Examples:
      | currency | country | amount | txn_mode | metadata                    | request_origin | on_behalf_of | country | status_code |
      | PKR      | PAK     | 20     | RAASTP2P | {"key": "IntegrationTest1"} | CASH_SERVICE           | CUSTOMER     | PAK     | 200         |
      | PKR      | PAK     | 20     | 1LINK    | {"key": "IntegrationTest2"} | CASH_SERVICE           | CUSTOMER     | PAK     | 200         |


  Scenario Outline: Existing payment account is inquiring the internal CustomerProfile Account using linked VirtualId from request origin as CASH_SERVICE and on behalf of CUSTOMER and verify it's processed successfully

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

    Then I intiate a request to link VirtualId to the account from CASH_SERVICE and expect the header status <status_code> and status as LINK_SUCCESS in Paysys
      | account_id                | customer_profile_id | virtual_id_details                                                   |
      | CustomerProfileAccountId1 | PSCPID1             | { "virtual_id_type" : "MOBILE" , "virtual_id_value" : "9876543210" } |

    Then I initiate a request to inquiry an internal account CustomerProfileAccountId1 from CASH_SERVICE and expect the header status <status_code> in Paysys
      | identifier        | account_id                | customer_profile_id | amount   | receiver_details                                                                                                                                  |
      | InquiryIdentifier | CustomerProfileAccountId2 | PSCPID1             | <amount> | { "country" : "PAK" , "code_details": { 'pk_account': { 'virtual_id_details' : { 'virtual_id_type':'MOBILE' ,'virtual_id_value': '9876543210'}}}} |

    Examples:
      | currency | country | amount | metadata                    | request_origin | on_behalf_of | country | status_code |
      | PKR      | PAK     | 20     | {"key": "IntegrationTest1"} | CASH_SERVICE           | CUSTOMER     | PAK     | 200         |

  Scenario Outline: Existing payment account is inquiring the internal CustomerProfile Account using not linked VirtualId from request origin as CASH_SERVICE and on behalf of CUSTOMER and verify it's failed

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

    Then I initiate a request to inquiry an internal account CustomerProfileAccountId1 from CASH_SERVICE and expect the header status PTM_1305 in Paysys
      | identifier        | account_id                | customer_profile_id | amount   | receiver_details                                                                                                                                  |
      | InquiryIdentifier | CustomerProfileAccountId2 | PSCPID1             | <amount> | { "country" : "PAK" , "code_details": { 'pk_account': { 'virtual_id_details' : { 'virtual_id_type':'MOBILE' ,'virtual_id_value': '8876543210'}}}} |

    Examples:
      | currency | country | amount | metadata                    | request_origin | on_behalf_of | country | status_code |
      | PKR      | PAK     | 20     | {"key": "IntegrationTest1"} | CASH_SERVICE           | CUSTOMER     | PAK     | 200         |

  Scenario Outline: Existing payment account is inquiring the external Account using externally linked VirtualId from request origin as CASH_SERVICE and on behalf of CUSTOMER and verify it's processed successfully

    Given I create account for CustomerProfile with customerProfileId PSCPID1 from <request_origin> on behalf of <on_behalf_of> with provider PAYSYS and expect the header status <status_code>
      | identifier                | currency   | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I verify CustomerProfile with id PSCPID1 has payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> exists with provider PAYSYS with values
      | account_id                | provider_id | currency | account_status  | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | PAYSYS-PK   | PKR      | ACCOUNT_CREATED | <country> | <metadata> | <on_behalf_of> |

    Then I retrieve the payment account CustomerProfileAccountId1 from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I initiate a request to inquiry an external account from CASH_SERVICE and expect the header status <status_code> in Paysys
      | identifier        | account_id                | customer_profile_id | txn_mode   | amount   | receiver_details                                                                                                                                  |
      | InquiryIdentifier | CustomerProfileAccountId1 | PSCPID1             | <txn_mode> | <amount> | { "country" : "PAK" , "code_details": { 'pk_account': { 'virtual_id_details' : { 'virtual_id_type':'MOBILE' ,'virtual_id_value': '3276543210'}}}} |

    Examples:
      | currency | country | amount | txn_mode | metadata                    | request_origin | on_behalf_of | country | status_code |
      | PKR      | PAK     | 20     | RAASTP2P | {"key": "IntegrationTest1"} | CASH_SERVICE           | CUSTOMER     | PAK     | 200         |

