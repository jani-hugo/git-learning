Feature: Payment Service Bill Inquiry for provider Paysys

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

  Scenario Outline: Bill Inquiry for existing account with biller details to return unpaid bill details for ordinary biller categories

    Given I create account for CustomerProfile with customerProfileId PSCPID1 from <request_origin> on behalf of <on_behalf_of> with provider PAYSYS and expect the header status <status_code>
      | identifier                | currency   | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I verify CustomerProfile with id PSCPID1 has payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> exists with provider PAYSYS with values
      | account_id                | provider_id | currency | account_status  | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | PAYSYS-PK   | PKR      | ACCOUNT_CREATED | <country> | <metadata> | <on_behalf_of> |

    Then I retrieve the payment account CustomerProfileAccountId1 from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I initiate a request to inquiry bill details on consumerId <consumer_id> under category <biller_category> and billerId <biller_id> from CASH_SERVICE and expect the header status <status_code> and bill status <bill_status> in Paysys
      | identifier            | account_id                | customer_profile_id | biller_category   | biller_id   | consumer_id   |
      | BillInquiryIdentifier | CustomerProfileAccountId1 | PSCPID1             | <biller_category> | <biller_id> | <consumer_id> |

    Examples:
      | currency | country | biller_category | biller_id | consumer_id  | metadata                    | request_origin | on_behalf_of | country | status_code | bill_status |
      | PKR      | PAK     | ELECTRICITY     | 1         | 100987654321 | {"key": "IntegrationTest1"} | CASH_SERVICE   | CUSTOMER     | PAK     | 200         | BILL_UNPAID |
      | PKR      | PAK     | WATER           | 62        | 100896745231 | {"key": "IntegrationTest1"} | CASH_SERVICE   | CUSTOMER     | PAK     | 200         | BILL_UNPAID |
      | PKR      | PAK     | GAS_PAYMENTS    | 25        | 100678945123 | {"key": "IntegrationTest1"} | CASH_SERVICE   | CUSTOMER     | PAK     | 200         | BILL_UNPAID |
      | PKR      | PAK     | MOBILE          | 68        | 1001001001   | {"key": "IntegrationTest1"} | CASH_SERVICE   | CUSTOMER     | PAK     | 200         | BILL_UNPAID |

  Scenario Outline: Bill Inquiry for existing account with biller details to return paid bill details which is paid before due date for ordinary biller categories

    Given I create account for CustomerProfile with customerProfileId PSCPID1 from <request_origin> on behalf of <on_behalf_of> with provider PAYSYS and expect the header status <status_code>
      | identifier                | currency   | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I verify CustomerProfile with id PSCPID1 has payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> exists with provider PAYSYS with values
      | account_id                | provider_id | currency | account_status  | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | PAYSYS-PK   | PKR      | ACCOUNT_CREATED | <country> | <metadata> | <on_behalf_of> |

    Then I retrieve the payment account CustomerProfileAccountId1 from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I initiate a request to inquiry bill details on consumerId <consumer_id> under category <biller_category> and billerId <biller_id> from CASH_SERVICE and expect the header status <status_code> and bill status <bill_status> in Paysys
      | identifier            | account_id                | customer_profile_id | biller_category   | biller_id   | consumer_id   |
      | BillInquiryIdentifier | CustomerProfileAccountId1 | PSCPID1             | <biller_category> | <biller_id> | <consumer_id> |

    Examples:
      | currency | country | biller_category | biller_id | consumer_id  | metadata                    | request_origin | on_behalf_of | country | status_code | bill_status |
      | PKR      | PAK     | ELECTRICITY     | 1         | 101987654321 | {"key": "IntegrationTest1"} | CASH_SERVICE   | CUSTOMER     | PAK     | 200         | BILL_PAID   |
      | PKR      | PAK     | WATER           | 62        | 101896745231 | {"key": "IntegrationTest1"} | CASH_SERVICE   | CUSTOMER     | PAK     | 200         | BILL_PAID   |
      | PKR      | PAK     | GAS_PAYMENTS    | 25        | 101678945123 | {"key": "IntegrationTest1"} | CASH_SERVICE   | CUSTOMER     | PAK     | 200         | BILL_PAID   |
      | PKR      | PAK     | MOBILE          | 68        | 1011001001   | {"key": "IntegrationTest1"} | CASH_SERVICE   | CUSTOMER     | PAK     | 200         | BILL_PAID   |

  Scenario Outline: Bill Inquiry for existing account with biller details to return paid bill details which is paid after due date for ordinary biller categories

    Given I create account for CustomerProfile with customerProfileId PSCPID1 from <request_origin> on behalf of <on_behalf_of> with provider PAYSYS and expect the header status <status_code>
      | identifier                | currency   | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I verify CustomerProfile with id PSCPID1 has payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> exists with provider PAYSYS with values
      | account_id                | provider_id | currency | account_status  | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | PAYSYS-PK   | PKR      | ACCOUNT_CREATED | <country> | <metadata> | <on_behalf_of> |

    Then I retrieve the payment account CustomerProfileAccountId1 from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I initiate a request to inquiry bill details on consumerId <consumer_id> under category <biller_category> and billerId <biller_id> from CASH_SERVICE and expect the header status <status_code> and bill status <bill_status> in Paysys
      | identifier            | account_id                | customer_profile_id | biller_category   | biller_id   | consumer_id   |
      | BillInquiryIdentifier | CustomerProfileAccountId1 | PSCPID1             | <biller_category> | <biller_id> | <consumer_id> |

    Examples:
      | currency | country | biller_category | biller_id | consumer_id  | metadata                    | request_origin | on_behalf_of | country | status_code | bill_status |
      | PKR      | PAK     | ELECTRICITY     | 1         | 102987654321 | {"key": "IntegrationTest1"} | CASH_SERVICE   | CUSTOMER     | PAK     | 200         | BILL_PAID   |
      | PKR      | PAK     | WATER           | 62        | 102896745231 | {"key": "IntegrationTest1"} | CASH_SERVICE   | CUSTOMER     | PAK     | 200         | BILL_PAID   |
      | PKR      | PAK     | GAS_PAYMENTS    | 25        | 102678945123 | {"key": "IntegrationTest1"} | CASH_SERVICE   | CUSTOMER     | PAK     | 200         | BILL_PAID   |
      | PKR      | PAK     | MOBILE          | 68        | 1021001001   | {"key": "IntegrationTest1"} | CASH_SERVICE   | CUSTOMER     | PAK     | 200         | BILL_PAID   |

  Scenario Outline: Bill Inquiry for existing account with biller details to return blocked bill details for ordinary biller categories

    Given I create account for CustomerProfile with customerProfileId PSCPID1 from <request_origin> on behalf of <on_behalf_of> with provider PAYSYS and expect the header status <status_code>
      | identifier                | currency   | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I verify CustomerProfile with id PSCPID1 has payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> exists with provider PAYSYS with values
      | account_id                | provider_id | currency | account_status  | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | PAYSYS-PK   | PKR      | ACCOUNT_CREATED | <country> | <metadata> | <on_behalf_of> |

    Then I retrieve the payment account CustomerProfileAccountId1 from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I initiate a request to inquiry bill details on consumerId <consumer_id> under category <biller_category> and billerId <biller_id> from CASH_SERVICE and expect the header status <status_code> and bill status <bill_status> in Paysys
      | identifier            | account_id                | customer_profile_id | biller_category   | biller_id   | consumer_id   |
      | BillInquiryIdentifier | CustomerProfileAccountId1 | PSCPID1             | <biller_category> | <biller_id> | <consumer_id> |

    Examples:
      | currency | country | biller_category | biller_id | consumer_id  | metadata                    | request_origin | on_behalf_of | country | status_code | bill_status  |
      | PKR      | PAK     | ELECTRICITY     | 1         | 103987654321 | {"key": "IntegrationTest1"} | CASH_SERVICE   | CUSTOMER     | PAK     | 200         | BILL_BLOCKED |
      | PKR      | PAK     | WATER           | 62        | 103896745231 | {"key": "IntegrationTest1"} | CASH_SERVICE   | CUSTOMER     | PAK     | 200         | BILL_BLOCKED |
      | PKR      | PAK     | GAS_PAYMENTS    | 25        | 103678945123 | {"key": "IntegrationTest1"} | CASH_SERVICE   | CUSTOMER     | PAK     | 200         | BILL_BLOCKED |
      | PKR      | PAK     | MOBILE          | 68        | 1031001001   | {"key": "IntegrationTest1"} | CASH_SERVICE   | CUSTOMER     | PAK     | 200         | BILL_BLOCKED |

  Scenario Outline: Bill Inquiry for existing account with invalid biller details to return exception

    Given I create account for CustomerProfile with customerProfileId PSCPID1 from <request_origin> on behalf of <on_behalf_of> with provider PAYSYS and expect the header status 200
      | identifier                | currency   | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I verify CustomerProfile with id PSCPID1 has payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> exists with provider PAYSYS with values
      | account_id                | provider_id | currency | account_status  | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | PAYSYS-PK   | PKR      | ACCOUNT_CREATED | <country> | <metadata> | <on_behalf_of> |

    Then I retrieve the payment account CustomerProfileAccountId1 from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I initiate a request to inquiry bill details on consumerId <consumer_id> under category <biller_category> and billerId <biller_id> from CASH_SERVICE and expect the header status <status_code> in Paysys
      | identifier            | account_id                | customer_profile_id | biller_category   | biller_id   | consumer_id   |
      | BillInquiryIdentifier | CustomerProfileAccountId1 | PSCPID1             | <biller_category> | <biller_id> | <consumer_id> |

    Examples:
      | currency | country | biller_category | biller_id | consumer_id  | metadata                    | request_origin | on_behalf_of | country | status_code |
      | PKR      | PAK     | ELECTRICITY     | 1         | 123987654321 | {"key": "IntegrationTest1"} | CASH_SERVICE   | CUSTOMER     | PAK     | PTM_1500    |
      | PKR      | PAK     | WATER           | 62        | 123896745231 | {"key": "IntegrationTest1"} | CASH_SERVICE   | CUSTOMER     | PAK     | PTM_1500    |
      | PKR      | PAK     | GAS_PAYMENTS    | 25        | 123678945123 | {"key": "IntegrationTest1"} | CASH_SERVICE   | CUSTOMER     | PAK     | PTM_1500    |
      | PKR      | PAK     | MOBILE          | 68        | 1231001001   | {"key": "IntegrationTest1"} | CASH_SERVICE   | CUSTOMER     | PAK     | PTM_1500    |

  Scenario Outline: Bill Inquiry for existing account for Mobile Biller Category Prepaid Biller

    Given I create account for CustomerProfile with customerProfileId PSCPID1 from <request_origin> on behalf of <on_behalf_of> with provider PAYSYS and expect the header status <status_code>
      | identifier                | currency   | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I verify CustomerProfile with id PSCPID1 has payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> exists with provider PAYSYS with values
      | account_id                | provider_id | currency | account_status  | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | PAYSYS-PK   | PKR      | ACCOUNT_CREATED | <country> | <metadata> | <on_behalf_of> |

    Then I retrieve the payment account CustomerProfileAccountId1 from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I initiate a request to inquiry bill details on mobile prepaid consumerId <consumer_id> under category <biller_category> and billerId <biller_id> from CASH_SERVICE and expect the header status <status_code> in Paysys
      | identifier            | account_id                | customer_profile_id | biller_category   | biller_id   | consumer_id   |
      | BillInquiryIdentifier | CustomerProfileAccountId1 | PSCPID1             | <biller_category> | <biller_id> | <consumer_id> |

    Examples:
      | currency | country | biller_category | biller_id | consumer_id | metadata                    | request_origin | on_behalf_of | country | status_code |
      | PKR      | PAK     | MOBILE          | 67        | 987654321   | {"key": "IntegrationTest1"} | CASH_SERVICE   | CUSTOMER     | PAK     | 200         |
      | PKR      | PAK     | MOBILE          | 69        | 987654321   | {"key": "IntegrationTest1"} | CASH_SERVICE   | CUSTOMER     | PAK     | 200         |

  Scenario Outline: Bill Inquiry for existing account for Mobile Biller Category Bundle Biller

    Given I create account for CustomerProfile with customerProfileId PSCPID1 from <request_origin> on behalf of <on_behalf_of> with provider PAYSYS and expect the header status <status_code>
      | identifier                | currency   | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I verify CustomerProfile with id PSCPID1 has payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> exists with provider PAYSYS with values
      | account_id                | provider_id | currency | account_status  | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | PAYSYS-PK   | PKR      | ACCOUNT_CREATED | <country> | <metadata> | <on_behalf_of> |

    Then I retrieve the payment account CustomerProfileAccountId1 from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I initiate a request to inquiry bill details on mobile prepaid consumerId <consumer_id> under category <biller_category> and billerId <biller_id> from CASH_SERVICE and expect the header status <status_code> in Paysys
      | identifier            | account_id                | customer_profile_id | biller_category   | biller_id   | consumer_id   |
      | BillInquiryIdentifier | CustomerProfileAccountId1 | PSCPID1             | <biller_category> | <biller_id> | <consumer_id> |

    Examples:
      | currency | country | biller_category | biller_id | consumer_id | metadata                    | request_origin | on_behalf_of | country | status_code |
      | PKR      | PAK     | MOBILE          | 73        | 987654321   | {"key": "IntegrationTest1"} | CASH_SERVICE   | CUSTOMER     | PAK     | 200         |
      | PKR      | PAK     | MOBILE          | 74        | 987654321   | {"key": "IntegrationTest1"} | CASH_SERVICE   | CUSTOMER     | PAK     | 200         |

  Scenario Outline: Bill Inquiry for existing account for invalid billerId

    Given I create account for CustomerProfile with customerProfileId PSCPID1 from <request_origin> on behalf of <on_behalf_of> with provider PAYSYS and expect the header status 200
      | identifier                | currency   | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I verify CustomerProfile with id PSCPID1 has payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> exists with provider PAYSYS with values
      | account_id                | provider_id | currency | account_status  | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | PAYSYS-PK   | PKR      | ACCOUNT_CREATED | <country> | <metadata> | <on_behalf_of> |

    Then I retrieve the payment account CustomerProfileAccountId1 from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I initiate a request to inquiry bill details on consumerId <consumer_id> under category <biller_category> and billerId <biller_id> from CASH_SERVICE and expect the header status <status_code> in Paysys
      | identifier            | account_id                | customer_profile_id | biller_category   | biller_id   | consumer_id   |
      | BillInquiryIdentifier | CustomerProfileAccountId1 | PSCPID1             | <biller_category> | <biller_id> | <consumer_id> |

    Examples:
      | currency | country | biller_category | biller_id | consumer_id  | metadata                    | request_origin | on_behalf_of | country | status_code |
      | PKR      | PAK     | ELECTRICITY     | 100       | 123987654321 | {"key": "IntegrationTest1"} | CASH_SERVICE   | CUSTOMER     | PAK     | PTM_1904    |
      | PKR      | PAK     | WATER           | 620       | 123896745231 | {"key": "IntegrationTest1"} | CASH_SERVICE   | CUSTOMER     | PAK     | PTM_1904    |
      | PKR      | PAK     | GAS_PAYMENTS    | 250       | 123678945123 | {"key": "IntegrationTest1"} | CASH_SERVICE   | CUSTOMER     | PAK     | PTM_1904    |
      | PKR      | PAK     | MOBILE          | 680       | 1231001001   | {"key": "IntegrationTest1"} | CASH_SERVICE   | CUSTOMER     | PAK     | PTM_1904    |

  Scenario Outline: Bill Inquiry for existing account for invalid biller category

    Given I create account for CustomerProfile with customerProfileId PSCPID1 from <request_origin> on behalf of <on_behalf_of> with provider PAYSYS and expect the header status 200
      | identifier                | currency   | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | <currency> | <country> | <metadata> | <on_behalf_of> |

    Then I wait until max time to verify the payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I verify CustomerProfile with id PSCPID1 has payment account CustomerProfileAccountId1 from <request_origin> on behalf of <on_behalf_of> exists with provider PAYSYS with values
      | account_id                | provider_id | currency | account_status  | country   | metadata   | on_behalf_of   |
      | CustomerProfileAccountId1 | PAYSYS-PK   | PKR      | ACCOUNT_CREATED | <country> | <metadata> | <on_behalf_of> |

    Then I retrieve the payment account CustomerProfileAccountId1 from CASH_SERVICE on behalf of CUSTOMER status as ACCOUNT_CREATED with provider PAYSYS for customerProfileId PSCPID1

    Then I initiate a request to inquiry bill details on consumerId <consumer_id> under category <biller_category> and billerId <biller_id> from CASH_SERVICE and expect the header status <status_code> in Paysys
      | identifier            | account_id                | customer_profile_id | biller_category   | biller_id   | consumer_id   |
      | BillInquiryIdentifier | CustomerProfileAccountId1 | PSCPID1             | <biller_category> | <biller_id> | <consumer_id> |

    Examples:
      | currency | country | biller_category | biller_id | consumer_id  | metadata                    | request_origin | on_behalf_of | country | status_code |
      | PKR      | PAK     | ELEC            | 100       | 123987654321 | {"key": "IntegrationTest1"} | CASH_SERVICE   | CUSTOMER     | PAK     | E9400       |
      | PKR      | PAK     | WAT             | 620       | 123896745231 | {"key": "IntegrationTest1"} | CASH_SERVICE   | CUSTOMER     | PAK     | E9400       |
      | PKR      | PAK     | GAS             | 250       | 123678945123 | {"key": "IntegrationTest1"} | CASH_SERVICE   | CUSTOMER     | PAK     | E9400       |
      | PKR      | PAK     | MOB             | 680       | 1231001001   | {"key": "IntegrationTest1"} | CASH_SERVICE   | CUSTOMER     | PAK     | E9400       |

