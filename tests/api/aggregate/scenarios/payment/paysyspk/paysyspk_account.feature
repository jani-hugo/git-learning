Feature: Payment Service CustomerProfile, EndCustomerProfile Profile Account for provider PAYSYS

  Background: Setup CustomerProfile and EndCustomerProfile profile onto Payment Service

    #CustomerProfile verifying and Onboarding on to payment service on given providers
    Given In Payment Service, I set and verify customer PSCID1, customer profile PSCPID1 on below providers from CASH_SERVICE on behalf of CUSTOMER and expect status 200 in the context
      | provider_name |
      | PAYSYS        |

    Then I wait until max time to verify CustomerProfile PSCPID1 on behalf of CASH_SERVICE onboard status as ONBOARD_SUCCESS onto Payment Service

    Then I create below End-Customer-Profile
      | customer_identifier | customer_profile_identifier | end_customer_profile_identifier | first_name | last_name | region | email            | phone_number |
      | PSCID1              | PSCPID1                     | ECPID1                          | Kiyotaka   | Ayanokōji | PK     | KA@gmail.com.com | 0000000000   |

    Then I verify End-Customer-Profile exist with values
      | customer_profile_identifier | end_customer_profile_identifier | first_name | last_name | email            | phone_number | status |
      | PSCPID1                     | ECPID1                          | Kiyotaka   | Ayanokōji | KA@gmail.com.com | 0000000000   | ACTIVE |

    # EndCustomerProfile Onboarding
    Given I onboard EndCustomerProfile ECPID1 of CustomerProfile PSCPID1 on payment service on below providers from CASH_SERVICE on behalf of CUSTOMER and expect status 200
      | provider_name |
      | PAYSYS        |

    Then I wait until max time to verify EndCustomerProfile ECPID1 of CustomerProfile PSCPID1 from CASH_SERVICE onboard status as ONBOARD_SUCCESS onto Payment Service

  Scenario Outline: Create CustomerProfile Account from request origin as CASH_SERVICE and on behalf of CUSTOMER and verify it's created successfully

    Given I create account for CustomerProfile with customerProfileId <customer_profile_identifier> from <request_origin> on behalf of <on_behalf_of> with provider PAYSYS and expect the header status <status_code>
      | identifier | currency   | country   | metadata   | on_behalf_of   |
      | AccountId  | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account AccountId from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I verify CustomerProfile with id <customer_profile_identifier> has payment account AccountId from <request_origin> on behalf of <on_behalf_of> exists with provider <bank_name> with values
      | identifier | provider_id | currency | country | account_status  | metadata   | on_behalf_of   |
      | AccountId  | PAYSYS-PK   | PKR      | PAK     | ACCOUNT_CREATED | <metadata> | <on_behalf_of> |

    Examples:
      | customer_profile_identifier | currency | country | metadata                    | request_origin | on_behalf_of | bank_name | country | status_code |
      | PSCPID1                     | PKR      | PAK     | {"key": "IntegrationTest1"} | CASH_SERVICE   | CUSTOMER     | PAYSYS    | PAK     | 200         |
      | PSCPID1                     | PKR      | PAK     | {"key": "IntegrationTest2"} | CASH_SERVICE   | CUSTOMER     | PAYSYS    | PAK     | 200         |
      | PSCPID1                     | PKR      | PAK     | {"key": "IntegrationTest3"} | CASH_SERVICE   | CUSTOMER     | PAYSYS    | PAK     | 200         |

  Scenario Outline: Create EndCustomerProfile account from request origin as CASH_SERVICE and on behalf of CUSTOMER and verify it's created successfully

    Given I create account for EndCustomerProfile with id <end_customer_profile_identifier> for CustomerProfile <customer_profile_identifier> from <request_origin> on behalf of <on_behalf_of> with provider PAYSYS and expect the header status <status_code>
      | identifier | currency   | country   | metadata   | on_behalf_of   |
      | AccountId  | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account AccountId from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I verify EndCustomerProfile with id <end_customer_profile_identifier> for CustomerProfile <customer_profile_identifier> has payment account AccountId from <request_origin> on behalf of <on_behalf_of> exists with provider <bank_name> with values
      | identifier | provider_id | currency | country | account_status  | metadata   | on_behalf_of   |
      | AccountId  | PAYSYS-PK   | PKR      | PAK     | ACCOUNT_CREATED | <metadata> | <on_behalf_of> |

    Examples:
      | customer_profile_identifier | end_customer_profile_identifier | on_behalf_of | request_origin | currency | country | metadata                    | bank_name | country | status_code |
      | PSCPID1                     | ECPID1                          | CUSTOMER     | CASH_SERVICE   | PKR      | PAK     | {"key": "IntegrationTest1"} | PAYSYS    | PAK     | 200         |
      | PSCPID1                     | ECPID1                          | CUSTOMER     | CASH_SERVICE   | PKR      | PAK     | {"key": "IntegrationTest2"} | PAYSYS    | PAK     | 200         |
      | PSCPID1                     | ECPID1                          | CUSTOMER     | CASH_SERVICE   | PKR      | PAK     | {"key": "IntegrationTest3"} | PAYSYS    | PAK     | 200         |

  Scenario Outline: Create CustomerProfile Account and verify from request origin as CASH_SERVICE and on behalf of CASH_SERVICE and verify it's failed

    Given I create account for CustomerProfile with customerProfileId <customer_profile_identifier> from <request_origin> on behalf of <on_behalf_of> with provider PAYSYS and expect the header status <status_code>
      | identifier | currency   | country   | metadata   | on_behalf_of   |
      | AccountId  | <currency> | <country> | <metadata> | <on_behalf_of> |

    Examples:
      | customer_profile_identifier | currency | country | metadata                    | request_origin | on_behalf_of | status_code |
      | PSCPID1                     | PKR      | PAK     | {"key": "IntegrationTest1"} | CASH_SERVICE   | CASH_SERVICE | PTM_1002    |

  Scenario Outline: Create CustomerProfile Account and verify from request origin CASH_SERVICE and on behalf of CUSTOMER and passing incorrect data verify it's failed

    Given I create account for CustomerProfile with customerProfileId <customer_profile_identifier> from <request_origin> on behalf of <on_behalf_of> with provider PAYSYS and expect the header status <status_code>
      | identifier | currency   | country   | metadata   | on_behalf_of   |
      | AccountId  | <currency> | <country> | <metadata> | <on_behalf_of> |

    Examples:
      | customer_profile_identifier | currency | country | metadata                    | request_origin | on_behalf_of | status_code |
      | PSCPID1                     | USD      | SGP     | {"key": "IntegrationTest1"} | CASH_SERVICE   | CUSTOMER     | PTM_1002    |
      | PSCPID1                     | SGD      | SG      | {"key": "IntegrationTest1"} | CASH_SERVICE   | CUSTOMER     | E9400       |


  Scenario Outline: Create CustomerProfile Account on which customer profile is not onboarded on to the provider

    Given I create below Customer
      | customer_identifier | name | date                 |
      | PSCID2              | hugo | 2022-12-28T00:00:00Z |

    Then I create below Customer-Profile
      | customer_identifier | customer_profile_identifier | region | name  | email          | phone_number |
      | PSCID2              | PSCPID2                     | PK     | Stark | hugo@atlas.com | 8989548747   |

    Then I verify Customer-Profile exist with values
      | customer_identifier | customer_profile_identifier | region | name  | email          | phone_number | status |
      | PSCID2              | PSCPID2                     | PK     | Stark | hugo@atlas.com | 8989548747   | ACTIVE |

    Given I create account for CustomerProfile with customerProfileId <customer_profile_identifier> from <request_origin> on behalf of <on_behalf_of> with provider PAYSYS and expect the header status <status_code>
      | identifier | currency   | country   | metadata   | on_behalf_of   |
      | AccountId  | <currency> | <country> | <metadata> | <on_behalf_of> |

    Examples:
      | customer_profile_identifier | currency | country | metadata                    | request_origin | on_behalf_of | status_code |
      | PSCPID2                     | PKR      | PAK     | {"key": "IntegrationTest1"} | CASH_SERVICE   | CUSTOMER     | PTM_1111    |


#  Scenario Outline: Create CustomerProfile Account and verify from request origin different from CASH_SERVICE and on behalf of CASH_SERVICE and verify it's failed
#
#    Given I create account for CustomerProfile with customerProfileId <customer_profile_identifier> from <request_origin> on behalf of <on_behalf_of> with provider PAYSYS and expect the header status <status_code>
#      | identifier | currency   | country   | metadata   | on_behalf_of   |
#      | AccountId  | <currency> | <country> | <metadata> | <on_behalf_of> |
#
#    Examples:
#      | customer_profile_identifier | currency | country | metadata                    | request_origin | on_behalf_of | status_code |
#      | PSCPID1                     | PKR      | PAK     | {"key": "IntegrationTest1"} | CARD           | CUSTOMER     | PTM_2003   |
#      | PSCPID1                     | PKR      | PAK     | {"key": "IntegrationTest1"} | INVESTMENT     | CUSTOMER     | PTM_2003   |
