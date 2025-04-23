Feature: Payment Service VirtualId Link and Unlink Scenarios for provider Paysys

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

#    Link Scenarios
  Scenario Outline: Link a VirtualId to CustomerProfile Account from request origin as CASH_SERVICE and on behalf of CUSTOMER and verify it's linked successfully

    Given I create account for CustomerProfile with customerProfileId <customer_profile_identifier> from <request_origin> on behalf of <on_behalf_of> with provider PAYSYS and expect the header status <status_code>
      | identifier | currency   | country   | metadata   | on_behalf_of   |
      | AccountId  | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account AccountId from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I verify CustomerProfile with id <customer_profile_identifier> has payment account AccountId from <request_origin> on behalf of <on_behalf_of> exists with provider <bank_name> with values
      | identifier | provider_id | currency | country | account_status  | metadata   | on_behalf_of   |
      | AccountId  | PAYSYS-PK   | PKR      | PAK     | ACCOUNT_CREATED | <metadata> | <on_behalf_of> |

    Then I retrieve the payment account AccountId from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I intiate a request to link VirtualId to the account from CASH_SERVICE and expect the header status <status_code> and status as LINK_SUCCESS in Paysys
      | account_id | customer_profile_id | virtual_id_details                                                   |
      | AccountId  | PSCPID1             | { "virtual_id_type" : "MOBILE" , "virtual_id_value" : "9876543210" } |

    Examples:
      | customer_profile_identifier | currency | country | metadata                   | request_origin | on_behalf_of | bank_name | country | status_code |
      | PSCPID1                     | PKR      | PAK     | {"key": "IntegrationTest"} | CASH_SERVICE   | CUSTOMER     | PAYSYS    | PAK     | 200         |

  Scenario Outline: Link a VirtualId to EndCustomerProfile Account from request origin as CASH_SERVICE and on behalf of CUSTOMER and verify it's linked successfully

    Given I create account for EndCustomerProfile with id <end_customer_profile_identifier> for CustomerProfile <customer_profile_identifier> from <request_origin> on behalf of <on_behalf_of> with provider PAYSYS and expect the header status <status_code>
      | identifier | currency   | country   | metadata   | on_behalf_of   |
      | AccountId  | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account AccountId from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I verify EndCustomerProfile with id <end_customer_profile_identifier> for CustomerProfile <customer_profile_identifier> has payment account AccountId from <request_origin> on behalf of <on_behalf_of> exists with provider <bank_name> with values
      | identifier | provider_id | currency | country | account_status  | metadata   | on_behalf_of   |
      | AccountId  | PAYSYS-PK   | PKR      | PAK     | ACCOUNT_CREATED | <metadata> | <on_behalf_of> |

    Then I retrieve the payment account AccountId from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I intiate a request to link VirtualId to the account from CASH_SERVICE and expect the header status <status_code> and status as LINK_SUCCESS in Paysys
      | account_id | customer_profile_id | virtual_id_details                                                   |
      | AccountId  | PSCPID1             | { "virtual_id_type" : "MOBILE" , "virtual_id_value" : "9876543210" } |

    Examples:
      | customer_profile_identifier | end_customer_profile_identifier | on_behalf_of | request_origin | currency | country | metadata                    | bank_name | country | status_code |
      | PSCPID1                     | ECPID1                          | CUSTOMER     | CASH_SERVICE   | PKR      | PAK     | {"key": "IntegrationTest1"} | PAYSYS    | PAK     | 200         |


  Scenario Outline: Link a VirtualId to CustomerProfile Account which is already linked to same account from request origin as CASH_SERVICE and on behalf of CUSTOMER and verify it's linked successfully

    Given I create account for CustomerProfile with customerProfileId <customer_profile_identifier> from <request_origin> on behalf of <on_behalf_of> with provider PAYSYS and expect the header status <status_code>
      | identifier | currency   | country   | metadata   | on_behalf_of   |
      | AccountId  | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account AccountId from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I verify CustomerProfile with id <customer_profile_identifier> has payment account AccountId from <request_origin> on behalf of <on_behalf_of> exists with provider <bank_name> with values
      | identifier | provider_id | currency | country | account_status  | metadata   | on_behalf_of   |
      | AccountId  | PAYSYS-PK   | PKR      | PAK     | ACCOUNT_CREATED | <metadata> | <on_behalf_of> |

    Then I retrieve the payment account AccountId from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I intiate a request to link VirtualId to the account from CASH_SERVICE and expect the header status <status_code> and status as LINK_SUCCESS in Paysys
      | account_id | customer_profile_id | virtual_id_details                                                   |
      | AccountId  | PSCPID1             | { "virtual_id_type" : "MOBILE" , "virtual_id_value" : "9876543210" } |

    Then I intiate a request to link VirtualId to the account from CASH_SERVICE and expect the header status <status_code> and status as LINK_SUCCESS in Paysys
      | account_id | customer_profile_id | virtual_id_details                                                   |
      | AccountId  | PSCPID1             | { "virtual_id_type" : "MOBILE" , "virtual_id_value" : "9876543210" } |

    Examples:
      | customer_profile_identifier | currency | country | metadata                   | request_origin | on_behalf_of | bank_name | country | status_code |
      | PSCPID1                     | PKR      | PAK     | {"key": "IntegrationTest"} | CASH_SERVICE   | CUSTOMER     | PAYSYS    | PAK     | 200         |

  Scenario Outline: Link a VirtualId to EndCustomerProfile Account which is already linked to same account from request origin as CASH_SERVICE and on behalf of CUSTOMER and verify it's linked successfully

    Given I create account for EndCustomerProfile with id <end_customer_profile_identifier> for CustomerProfile <customer_profile_identifier> from <request_origin> on behalf of <on_behalf_of> with provider PAYSYS and expect the header status <status_code>
      | identifier | currency   | country   | metadata   | on_behalf_of   |
      | AccountId  | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account AccountId from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I verify EndCustomerProfile with id <end_customer_profile_identifier> for CustomerProfile <customer_profile_identifier> has payment account AccountId from <request_origin> on behalf of <on_behalf_of> exists with provider <bank_name> with values
      | identifier | provider_id | currency | country | account_status  | metadata   | on_behalf_of   |
      | AccountId  | PAYSYS-PK   | PKR      | PAK     | ACCOUNT_CREATED | <metadata> | <on_behalf_of> |

    Then I retrieve the payment account AccountId from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I intiate a request to link VirtualId to the account from CASH_SERVICE and expect the header status <status_code> and status as LINK_SUCCESS in Paysys
      | account_id | customer_profile_id | virtual_id_details                                                   |
      | AccountId  | PSCPID1             | { "virtual_id_type" : "MOBILE" , "virtual_id_value" : "9876543210" } |

    Then I intiate a request to link VirtualId to the account from CASH_SERVICE and expect the header status <status_code> and status as LINK_SUCCESS in Paysys
      | account_id | customer_profile_id | virtual_id_details                                                   |
      | AccountId  | PSCPID1             | { "virtual_id_type" : "MOBILE" , "virtual_id_value" : "9876543210" } |

    Examples:
      | customer_profile_identifier | end_customer_profile_identifier | on_behalf_of | request_origin | currency | country | metadata                    | bank_name | country | status_code |
      | PSCPID1                     | ECPID1                          | CUSTOMER     | CASH_SERVICE   | PKR      | PAK     | {"key": "IntegrationTest1"} | PAYSYS    | PAK     | 200         |


  Scenario Outline: Link one more VirtualId to CustomerProfile Account which is already linked to same account from request origin as CASH_SERVICE and on behalf of CUSTOMER and verify it's failed

    Given I create account for CustomerProfile with customerProfileId <customer_profile_identifier> from <request_origin> on behalf of <on_behalf_of> with provider PAYSYS and expect the header status <status_code>
      | identifier | currency   | country   | metadata   | on_behalf_of   |
      | AccountId  | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account AccountId from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I verify CustomerProfile with id <customer_profile_identifier> has payment account AccountId from <request_origin> on behalf of <on_behalf_of> exists with provider <bank_name> with values
      | identifier | provider_id | currency | country | account_status  | metadata   | on_behalf_of   |
      | AccountId  | PAYSYS-PK   | PKR      | PAK     | ACCOUNT_CREATED | <metadata> | <on_behalf_of> |

    Then I retrieve the payment account AccountId from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I intiate a request to link VirtualId to the account from CASH_SERVICE and expect the header status <status_code> and status as LINK_SUCCESS in Paysys
      | account_id | customer_profile_id | virtual_id_details                                                   |
      | AccountId  | PSCPID1             | { "virtual_id_type" : "MOBILE" , "virtual_id_value" : "9876543210" } |

    Then I intiate a request to link VirtualId to the account from CASH_SERVICE and expect the header status <status_code> and status as LINK_FAILED in Paysys
      | account_id | customer_profile_id | virtual_id_details                                                   |
      | AccountId  | PSCPID1             | { "virtual_id_type" : "MOBILE" , "virtual_id_value" : "8876543210" } |

    Examples:
      | customer_profile_identifier | currency | country | metadata                   | request_origin | on_behalf_of | bank_name | country | status_code |
      | PSCPID1                     | PKR      | PAK     | {"key": "IntegrationTest"} | CASH_SERVICE   | CUSTOMER     | PAYSYS    | PAK     | 200         |

  Scenario Outline: Link one more VirtualId to EndCustomerProfile Account which is already linked to same account from request origin as CASH_SERVICE and on behalf of CUSTOMER and verify it's failed

    Given I create account for EndCustomerProfile with id <end_customer_profile_identifier> for CustomerProfile <customer_profile_identifier> from <request_origin> on behalf of <on_behalf_of> with provider PAYSYS and expect the header status <status_code>
      | identifier | currency   | country   | metadata   | on_behalf_of   |
      | AccountId  | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account AccountId from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I verify EndCustomerProfile with id <end_customer_profile_identifier> for CustomerProfile <customer_profile_identifier> has payment account AccountId from <request_origin> on behalf of <on_behalf_of> exists with provider <bank_name> with values
      | identifier | provider_id | currency | country | account_status  | metadata   | on_behalf_of   |
      | AccountId  | PAYSYS-PK   | PKR      | PAK     | ACCOUNT_CREATED | <metadata> | <on_behalf_of> |

    Then I retrieve the payment account AccountId from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I intiate a request to link VirtualId to the account from CASH_SERVICE and expect the header status <status_code> and status as LINK_SUCCESS in Paysys
      | account_id | customer_profile_id | virtual_id_details                                                   |
      | AccountId  | PSCPID1             | { "virtual_id_type" : "MOBILE" , "virtual_id_value" : "9876543210" } |

    Then I intiate a request to link VirtualId to the account from CASH_SERVICE and expect the header status <status_code> and status as LINK_FAILED in Paysys
      | account_id | customer_profile_id | virtual_id_details                                                   |
      | AccountId  | PSCPID1             | { "virtual_id_type" : "MOBILE" , "virtual_id_value" : "8876543210" } |

    Examples:
      | customer_profile_identifier | end_customer_profile_identifier | on_behalf_of | request_origin | currency | country | metadata                    | bank_name | country | status_code |
      | PSCPID1                     | ECPID1                          | CUSTOMER     | CASH_SERVICE   | PKR      | PAK     | {"key": "IntegrationTest1"} | PAYSYS    | PAK     | 200         |


  Scenario Outline: Link a VirtualId to EndCustomerProfile Account which is already linked to different account from request origin as CASH_SERVICE and on behalf of CUSTOMER and verify it's failed

    Given I create account for CustomerProfile with customerProfileId <customer_profile_identifier> from <request_origin> on behalf of <on_behalf_of> with provider PAYSYS and expect the header status <status_code>
      | identifier | currency   | country   | metadata   | on_behalf_of   |
      | AccountId1 | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account AccountId1 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I verify CustomerProfile with id <customer_profile_identifier> has payment account AccountId1 from <request_origin> on behalf of <on_behalf_of> exists with provider PAYSYS with values
      | identifier | provider_id | currency | country | account_status  | metadata   | on_behalf_of   |
      | AccountId1 | PAYSYS-PK   | PKR      | PAK     | ACCOUNT_CREATED | <metadata> | <on_behalf_of> |

    Then I retrieve the payment account AccountId1 from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I intiate a request to link VirtualId to the account from CASH_SERVICE and expect the header status <status_code> and status as LINK_SUCCESS in Paysys
      | account_id | customer_profile_id | virtual_id_details                                                   |
      | AccountId1 | PSCPID1             | { "virtual_id_type" : "MOBILE" , "virtual_id_value" : "9876543210" } |

    Given I create account for CustomerProfile with customerProfileId <customer_profile_identifier> from <request_origin> on behalf of <on_behalf_of> with provider PAYSYS and expect the header status <status_code>
      | identifier | currency   | country   | metadata   | on_behalf_of   |
      | AccountId2 | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account AccountId2 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I verify CustomerProfile with id <customer_profile_identifier> has payment account AccountId2 from <request_origin> on behalf of <on_behalf_of> exists with provider PAYSYS with values
      | identifier | provider_id | currency | country | account_status  | metadata   | on_behalf_of   |
      | AccountId2 | PAYSYS-PK   | PKR      | PAK     | ACCOUNT_CREATED | <metadata> | <on_behalf_of> |

    Then I retrieve the payment account AccountId2 from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I intiate a request to link VirtualId to the account from CASH_SERVICE and expect the header status <status_code> and status as LINK_FAILED in Paysys
      | account_id | customer_profile_id | virtual_id_details                                                   |
      | AccountId2 | PSCPID1             | { "virtual_id_type" : "MOBILE" , "virtual_id_value" : "9876543210" } |

    Examples:
      | customer_profile_identifier | on_behalf_of | request_origin | currency | country | metadata                    | status_code |
      | PSCPID1                     | CUSTOMER     | CASH_SERVICE   | PKR      | PAK     | {"key": "IntegrationTest1"} | 200         |

  Scenario Outline: Link a VirtualId to CustomerProfile Account which is already linked to different account from request origin as CASH_SERVICE and on behalf of CUSTOMER and verify it's failed

    Given I create account for CustomerProfile with customerProfileId PSCPID1 from <request_origin> on behalf of <on_behalf_of> with provider PAYSYS and expect the header status <status_code>
      | identifier | currency   | country   | metadata   | on_behalf_of   |
      | AccountId1 | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account AccountId1 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I verify CustomerProfile with id PSCPID1 has payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> exists with provider PAYSYS with values
      | account_id | provider_id | currency | account_status  | country   | metadata   | on_behalf_of   |
      | AccountId1 | PAYSYS-PK   | PKR      | ACCOUNT_CREATED | <country> | <metadata> | <on_behalf_of> |

    Then I retrieve the payment account AccountId1 from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I intiate a request to link VirtualId to the account from CASH_SERVICE and expect the header status <status_code> and status as LINK_SUCCESS in Paysys
      | account_id | customer_profile_id | virtual_id_details                                                   |
      | AccountId1 | PSCPID1             | { "virtual_id_type" : "MOBILE" , "virtual_id_value" : "9876543210" } |

    Given I create account for CustomerProfile with customerProfileId PSCPID1 from CASH_SERVICE on behalf of CUSTOMER with provider PAYSYS and expect the header status <status_code>
      | identifier | currency   | country   | metadata   | on_behalf_of   |
      | AccountId2 | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account CustomerProfileAccountId2 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I verify CustomerProfile with id PSCPID1 has payment account CustomerProfileAccountId2 from <request_origin> on behalf of <on_behalf_of> exists with provider PAYSYS with values
      | account_id | provider_id | currency | account_status  | country   | metadata   | on_behalf_of   |
      | AccountId2 | PAYSYS-PK   | PKR      | ACCOUNT_CREATED | <country> | <metadata> | <on_behalf_of> |

    Then I retrieve the payment account CustomerProfileAccountId1 from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I intiate a request to link VirtualId to the account from CASH_SERVICE and expect the header status <status_code> and status as LINK_FAILED in Paysys
      | account_id | customer_profile_id | virtual_id_details                                                   |
      | AccountId2 | PSCPID1             | { "virtual_id_type" : "MOBILE" , "virtual_id_value" : "9876543210" } |

    Examples:
      | on_behalf_of | request_origin | currency | country | metadata                    | status_code |
      | CUSTOMER     | CASH_SERVICE   | PKR      | PAK     | {"key": "IntegrationTest1"} | 200         |


#    Unlink Scenarios
  Scenario Outline: Unlink a VirtualId from a CustomerProfile Account which is already linked to same account from request origin as CASH_SERVICE and on behalf of CUSTOMER and verify it's unlinked successfully

    Given I create account for CustomerProfile with customerProfileId <customer_profile_identifier> from <request_origin> on behalf of <on_behalf_of> with provider PAYSYS and expect the header status <status_code>
      | identifier | currency   | country   | metadata   | on_behalf_of   |
      | AccountId  | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account AccountId from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I verify CustomerProfile with id <customer_profile_identifier> has payment account AccountId from <request_origin> on behalf of <on_behalf_of> exists with provider <bank_name> with values
      | identifier | provider_id | currency | country | account_status  | metadata   | on_behalf_of   |
      | AccountId  | PAYSYS-PK   | PKR      | PAK     | ACCOUNT_CREATED | <metadata> | <on_behalf_of> |

    Then I retrieve the payment account AccountId from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I intiate a request to link VirtualId to the account from CASH_SERVICE and expect the header status <status_code> and status as LINK_SUCCESS in Paysys
      | account_id | customer_profile_id | virtual_id_details                                                   |
      | AccountId  | PSCPID1             | { "virtual_id_type" : "MOBILE" , "virtual_id_value" : "9876543210" } |

    Then I intiate a request to unlink VirtualId to the account from CASH_SERVICE and expect the header status <status_code> and status as UNLINK_SUCCESS in Paysys
      | account_id | customer_profile_id | virtual_id_details                                                   |
      | AccountId  | PSCPID1             | { "virtual_id_type" : "MOBILE" , "virtual_id_value" : "9876543210" } |

    Examples:
      | customer_profile_identifier | currency | country | metadata                   | request_origin | on_behalf_of | bank_name | country | status_code |
      | PSCPID1                     | PKR      | PAK     | {"key": "IntegrationTest"} | CASH_SERVICE   | CUSTOMER     | PAYSYS    | PAK     | 200         |

  Scenario Outline: Unlink a VirtualId from a EndCustomerProfile Account which is already linked to same account from request origin as CASH_SERVICE and on behalf of CUSTOMER and verify it's unlinked successfully

    Given I create account for EndCustomerProfile with id <end_customer_profile_identifier> for CustomerProfile <customer_profile_identifier> from <request_origin> on behalf of <on_behalf_of> with provider PAYSYS and expect the header status <status_code>
      | identifier | currency   | country   | metadata   | on_behalf_of   |
      | AccountId  | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account AccountId from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I verify EndCustomerProfile with id <end_customer_profile_identifier> for CustomerProfile <customer_profile_identifier> has payment account AccountId from <request_origin> on behalf of <on_behalf_of> exists with provider <bank_name> with values
      | identifier | provider_id | currency | country | account_status  | metadata   | on_behalf_of   |
      | AccountId  | PAYSYS-PK   | PKR      | PAK     | ACCOUNT_CREATED | <metadata> | <on_behalf_of> |

    Then I retrieve the payment account AccountId from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I intiate a request to link VirtualId to the account from CASH_SERVICE and expect the header status <status_code> and status as LINK_SUCCESS in Paysys
      | account_id | customer_profile_id | virtual_id_details                                                   |
      | AccountId  | PSCPID1             | { "virtual_id_type" : "MOBILE" , "virtual_id_value" : "9876543210" } |

    Then I intiate a request to unlink VirtualId to the account from CASH_SERVICE and expect the header status <status_code> and status as UNLINK_SUCCESS in Paysys
      | account_id | customer_profile_id | virtual_id_details                                                   |
      | AccountId  | PSCPID1             | { "virtual_id_type" : "MOBILE" , "virtual_id_value" : "9876543210" } |

    Examples:
      | customer_profile_identifier | end_customer_profile_identifier | on_behalf_of | request_origin | currency | country | metadata                    | bank_name | country | status_code |
      | PSCPID1                     | ECPID1                          | CUSTOMER     | CASH_SERVICE   | PKR      | PAK     | {"key": "IntegrationTest1"} | PAYSYS    | PAK     | 200         |


  Scenario Outline: Unlink a VirtualId from a CustomerProfile Account which is not linked to an account from request origin as CASH_SERVICE and on behalf of CUSTOMER and verify it's unlink failed

    Given I create account for CustomerProfile with customerProfileId <customer_profile_identifier> from <request_origin> on behalf of <on_behalf_of> with provider PAYSYS and expect the header status <status_code>
      | identifier | currency   | country   | metadata   | on_behalf_of   |
      | AccountId  | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account AccountId from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I verify CustomerProfile with id <customer_profile_identifier> has payment account AccountId from <request_origin> on behalf of <on_behalf_of> exists with provider <bank_name> with values
      | identifier | provider_id | currency | country | account_status  | metadata   | on_behalf_of   |
      | AccountId  | PAYSYS-PK   | PKR      | PAK     | ACCOUNT_CREATED | <metadata> | <on_behalf_of> |

    Then I retrieve the payment account AccountId from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I intiate a request to unlink VirtualId to the account from CASH_SERVICE and expect the header status PTM_2013 and status as UNLINK_FAILED in Paysys
      | account_id | customer_profile_id | virtual_id_details                                                   |
      | AccountId  | PSCPID1             | { "virtual_id_type" : "MOBILE" , "virtual_id_value" : "9876543210" } |

    Examples:
      | customer_profile_identifier | currency | country | metadata                   | request_origin | on_behalf_of | bank_name | country | status_code |
      | PSCPID1                     | PKR      | PAK     | {"key": "IntegrationTest"} | CASH_SERVICE   | CUSTOMER     | PAYSYS    | PAK     | 200         |

  Scenario Outline: Unlink a VirtualId from a EndCustomerProfile Account which is not linked to an account from request origin as CASH_SERVICE and on behalf of CUSTOMER and verify it's unlinked failed

    Given I create account for EndCustomerProfile with id <end_customer_profile_identifier> for CustomerProfile <customer_profile_identifier> from <request_origin> on behalf of <on_behalf_of> with provider PAYSYS and expect the header status <status_code>
      | identifier | currency   | country   | metadata   | on_behalf_of   |
      | AccountId  | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account AccountId from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I verify EndCustomerProfile with id <end_customer_profile_identifier> for CustomerProfile <customer_profile_identifier> has payment account AccountId from <request_origin> on behalf of <on_behalf_of> exists with provider <bank_name> with values
      | identifier | provider_id | currency | country | account_status  | metadata   | on_behalf_of   |
      | AccountId  | PAYSYS-PK   | PKR      | PAK     | ACCOUNT_CREATED | <metadata> | <on_behalf_of> |

    Then I retrieve the payment account AccountId from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I intiate a request to unlink VirtualId to the account from CASH_SERVICE and expect the header status PTM_2013 and status as UNLINK_FAILED in Paysys
      | account_id | customer_profile_id | virtual_id_details                                                   |
      | AccountId  | PSCPID1             | { "virtual_id_type" : "MOBILE" , "virtual_id_value" : "9876543210" } |

    Examples:
      | customer_profile_identifier | end_customer_profile_identifier | on_behalf_of | request_origin | currency | country | metadata                    | bank_name | country | status_code |
      | PSCPID1                     | ECPID1                          | CUSTOMER     | CASH_SERVICE   | PKR      | PAK     | {"key": "IntegrationTest1"} | PAYSYS    | PAK     | 200         |
