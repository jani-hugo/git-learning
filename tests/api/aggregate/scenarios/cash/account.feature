Feature: Cash service CustomerProfile, EndCustomerProfile Profile and Platform account scenarios

  Background: Setup CustomerProfile and EndCustomerProfile profile onto cash

    #CustomerProfile verifying and Onboarding on to banking service on given providers
    Given I set and verify customer BCID1, customer profile BCPID1 on cash service on below providers and expect status 200 in the context
      | provider_name |
      | DBS Bank Ltd  |

    Then I wait until max time to verify CustomerProfile BCPID1 onboard status as ONBOARD_SUCCESS

    Then I create below End-Customer-Profile
      | customer_identifier | customer_profile_identifier | end_customer_profile_identifier | first_name | last_name | region | email   | phone_number |
      | BCID1               | BCPID1                      | ECPID1                          | cash       | service   | SG     | x@y.com | 00000000     |

    Then I verify End-Customer-Profile exist with values
      | customer_profile_identifier | end_customer_profile_identifier | customer_profile_id   | first_name | last_name | email   | phone_number | status |
      | BCPID1                      | ECPID1                          | <customer_profile_id> | cash          | service   | x@y.com | 00000000     | ACTIVE |

    # EndCustomerProfile Onboarding
    Given I onboard EndCustomerProfile ECPID1 of CustomerProfile BCPID1 on cash service on below providers and expect status 200
      | provider_name |
      | DBS Bank Ltd  |

    Then I wait until max time to verify EndCustomerProfile ECPID1 of CustomerProfile BCPID1 onboard status as ONBOARD_SUCCESS

### NOTE: in_trust is always false unless we integrate with compliance
#  Scenario Outline: Create CustomerProfile account and verify it's created successfully
#    Given I create account for CustomerProfile with id <customer_profile_identifier> with bank account type as <account_type> with provider <bank_name> and expect the header status <status_code>
#      | identifier | customer_profile_id   | currency   | country   | in_trust   | is_overdraft_allowed   | on_behalf_of   | metadata   |
#      | BankAccId  | <customer_profile_id> | <currency> | <country> | <in_trust> | <is_overdraft_allowed> | <on_behalf_of> | <metadata> |
#
#    Then I wait until max time to verify the bank account BankAccId status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1
#
#    Then I verify for bank account BankAccId total balance is <total_balance> and available balance is <available_balance> for customerProfileId BCPID1
#
#    Examples:
#      | customer_profile_identifier | account_type     | currency | country | in_trust | is_overdraft_allowed | on_behalf_of | metadata                    | bank_name    | country | status_code | available_balance | total_balance |
#      | BCPID1                      | Payments Account | SGD      | SGP     | false    | false                | CUSTOMER     | {"key": "IntegrationTest1"} | DBS Bank Ltd | SGP     | 200         | 0                 | 0             |
#
#  Scenario Outline: Create CustomerProfile's Payments account with incorrect data and verify failure
#    Given I create account for CustomerProfile with id <customer_profile_identifier> with bank account type as <account_type> with provider <bank_name> and expect the header status <status_code>
#      | identifier | customer_profile_id   | currency   | country   | in_trust   | is_overdraft_allowed   | on_behalf_of   | metadata   |
#      | BankAccId  | <customer_profile_id> | <currency> | <country> | <in_trust> | <is_overdraft_allowed> | <on_behalf_of> | <metadata> |
#
#    Examples:
#      | customer_profile_identifier | account_type     | currency | country | in_trust | is_overdraft_allowed | on_behalf_of | metadata                    | bank_name    | status_code |
#      | BCPID1                      | Payments Account | SGD      | SGP     | true     | false                | CUSTOMER     | {"key": "IntegrationTest1"} | DBS Bank Ltd | CSSM_9405   |
#      | BCPID1                      | Payments Account | SGD      | SGP     | true     | true                 | CUSTOMER     | {"key": "IntegrationTest2"} | DBS Bank Ltd | CSSM_9405   |
#      | BCPID1                      | Payments Account | SGD      | SGP     | false    | true                 | CUSTOMER     | {"key": "IntegrationTest3"} | DBS Bank Ltd | CSSM_9406   |

  Scenario Outline: Create CustomerProfile account with empty onBehalfOf value and verify it's created successfully

    Given I create a product with customer profile <customer_profile_identifier> provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier    | product_type   | profile_type | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type   |
      | ProductID1    | WALLET         | CUSTOMER     |  SHARIAH      | <currency> | <country> | CURRENT      | <balance_policy_limit>  | <balance_policy_type> |

    Then I approve the product ProductID1 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId <customer_profile_identifier>

    Given I create account for CustomerProfile with id <customer_profile_identifier> with product id as ProductID1 with bank account type as <account_type> with provider <bank_name> and expect the header status <status_code>
      | identifier | customer_profile_id   | currency   | country   | in_trust      | on_behalf_of   | metadata   |
      | BankAccId  | <customer_profile_id> | <currency> | <country> | <in_trust>    | <on_behalf_of> | <metadata> |

    Then I wait until max time to verify the bank account BankAccId status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    Then I verify for bank account BankAccId total balance is <total_balance> and available balance is <available_balance> for customerProfileId BCPID1

    Examples:
      | customer_profile_identifier | account_type     | currency | country | in_trust | balance_policy_limit | balance_policy_type   | on_behalf_of | metadata                    | bank_name    | country | status_code | available_balance | total_balance |
      | BCPID1                      | Payments Account | SGD      | SGP     | false    | 0                    | STRICT                |              | {"key": "IntegrationTest1"} | DBS Bank Ltd | SGP     | 200         | 0                 | 0             |

  Scenario Outline: Create CustomerProfile account with no onBehalfOf value and verify it's created successfully

    Given I create a product with customer profile <customer_profile_identifier> provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier    | product_type   | profile_type | product_class | currency   | country   | account_type | balance_policy_type     | balance_policy_limit   |
      | ProductID1    | WALLET         | CUSTOMER     |  SHARIAH      | <currency> | <country> | CURRENT      | <balance_policy_type>   | <balance_policy_limit> |

    Then I approve the product ProductID1 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId <customer_profile_identifier>

    Given I create account for CustomerProfile with id <customer_profile_identifier> with product id as ProductID1 with bank account type as <account_type> with provider <bank_name> and expect the header status <status_code>
      | identifier | customer_profile_id   | currency   | country   | in_trust   | metadata   |
      | BankAccId  | <customer_profile_id> | <currency> | <country> | <in_trust> | <metadata> |

    Then I wait until max time to verify the bank account BankAccId status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    Then I verify for bank account BankAccId total balance is <total_balance> and available balance is <available_balance> for customerProfileId BCPID1

    Examples:
      | customer_profile_identifier | account_type     | currency | country | in_trust | balance_policy_limit | balance_policy_type | metadata                    | bank_name    | country | status_code | available_balance | total_balance |
      | BCPID1                      | Payments Account | SGD      | SGP     | false    | 0                    | STRICT              | {"key": "IntegrationTest1"} | DBS Bank Ltd | SGP     | 200         | 0                 | 0             |

  Scenario Outline: Create EndCustomerProfile account and verify it's created successfully

    Given I create a product with customer profile <customer_profile_identifier> provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier    | product_type   | profile_type | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type    |
      | ProductID1    | WALLET         | END_CUSTOMER |  SHARIAH      | <currency> | <country> | SAVINGS      | <balance_policy_limit>  | <balance_policy_type>  |

    Then I approve the product ProductID1 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId <customer_profile_identifier>

    Given I create account for EndCustomerProfile with id <end_customer_profile_identifier> for CustomerProfile <customer_profile_identifier> with product id ProductID1 with bank account type as <account_type> with provider <bank_name> and expect the header status <status_code>
      | identifier | customer_profile_id   | end_customer_profile_id   | currency   | country   | in_trust   | on_behalf_of   | metadata   |
      | BankAccId  | <customer_profile_id> | <end_customer_profile_id> | <currency> | <country> | <in_trust> | <on_behalf_of> | <metadata> |

    Then I wait until max time to verify the bank account BankAccId status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    Then I verify for bank account BankAccId total balance is <total_balance> and available balance is <available_balance> for customerProfileId BCPID1

    Examples:
      | customer_profile_identifier | end_customer_profile_identifier | account_type | currency | country | in_trust      | balance_policy_limit | balance_policy_type | on_behalf_of | metadata                    | bank_name    | country | status_code | available_balance | total_balance |
      | BCPID1                      | ECPID1                          | PPA          | SGD      | SGP     | false         | 0                    | STRICT              | CUSTOMER     | {"key": "IntegrationTest1"} | DBS Bank Ltd | SGP     | 200         | 0                 | 0             |
      | BCPID1                      | ECPID1                          | e-money      | SGD      | SGP     | false         | 0                    | STRICT              | CUSTOMER     | {"key": "IntegrationTest2"} | DBS Bank Ltd | SGP     | 200         | 0                 | 0             |
      | BCPID1                      | ECPID1                          | e-money      | SGD      | SGP     | false         | 0                    | LENIENT             | CUSTOMER     | {"key": "IntegrationTest2"} | DBS Bank Ltd | SGP     | 200         | 0                 | 0             |
      | BCPID1                      | ECPID1                          | e-money      | SGD      | SGP     | false         | 0                    | STRICT              | CUSTOMER     | {"key": "IntegrationTest2"} | DBS Bank Ltd | SGP     | 200         | 0                 | 0             |
      | BCPID1                      | ECPID1                          | e-money      | SGD      | SGP     | false         | 0                    | LENIENT             | CUSTOMER     | {"key": "IntegrationTest2"} | DBS Bank Ltd | SGP     | 200         | 0                 | 0             |

  Scenario Outline: Create EndCustomerProfile account with empty onBehalfOf and verify it's created successfully
    Given I create a product with customer profile <customer_profile_identifier> provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier    | product_type   | profile_type | product_class | currency   | country   | account_type | balance_policy_limit   | balance_policy_type   |
      | ProductID1    | WALLET         | END_CUSTOMER |  SHARIAH      | <currency> | <country> | SAVINGS      | <balance_policy_limit> |  <balance_policy_type> |

    Then I approve the product ProductID1 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId <customer_profile_identifier>

    Given I create account for EndCustomerProfile with id <end_customer_profile_identifier> for CustomerProfile <customer_profile_identifier> with product id ProductID1 with bank account type as <account_type> with provider <bank_name> and expect the header status <status_code>
      | identifier | customer_profile_id   | end_customer_profile_id   | currency   | country   | in_trust   | on_behalf_of   | metadata   |
      | BankAccId  | <customer_profile_id> | <end_customer_profile_id> | <currency> | <country> | <in_trust> | <on_behalf_of> | <metadata> |

    Then I wait until max time to verify the bank account BankAccId status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    Then I verify for bank account BankAccId total balance is <total_balance> and available balance is <available_balance> for customerProfileId BCPID1

    Examples:
      | customer_profile_identifier | end_customer_profile_identifier | account_type | currency | country | in_trust | balance_policy_limit | balance_policy_type | on_behalf_of | metadata                    | bank_name    | country | status_code | available_balance | total_balance |
      | BCPID1                      | ECPID1                          | PPA          | SGD      | SGP     | false    | 0                    | STRICT              |              | {"key": "IntegrationTest1"} | DBS Bank Ltd | SGP     | 200         | 0                 | 0             |

  Scenario Outline: Create EndCustomerProfile account with no onBehalfOf and verify it's created successfully
    Given I create a product with customer profile <customer_profile_identifier> provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier    | product_type   | profile_type | product_class | currency   | country   | account_type | balance_policy_limit   | balance_policy_type   |
      | ProductID1    | WALLET         | END_CUSTOMER |  SHARIAH      | <currency> | <country> | SAVINGS      | <balance_policy_limit> |  <balance_policy_type> |

    Then I approve the product ProductID1 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId <customer_profile_identifier>

    Given I create account for EndCustomerProfile with id <end_customer_profile_identifier> for CustomerProfile <customer_profile_identifier> with product id ProductID1 with bank account type as <account_type> with provider <bank_name> and expect the header status <status_code>
      | identifier | customer_profile_id   | end_customer_profile_id   | currency   | country   | in_trust   | metadata   |
      | BankAccId  | <customer_profile_id> | <end_customer_profile_id> | <currency> | <country> | <in_trust> | <metadata> |

    Then I wait until max time to verify the bank account BankAccId status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    Then I verify for bank account BankAccId total balance is <total_balance> and available balance is <available_balance> for customerProfileId BCPID1

    Examples:
      | customer_profile_identifier | end_customer_profile_identifier | account_type | currency | country | in_trust | balance_policy_limit | balance_policy_type | metadata                    | bank_name    | country | status_code | available_balance | total_balance |
      | BCPID1                      | ECPID1                          | PPA          | SGD      | SGP     | false    | 0                    | STRICT              | {"key": "IntegrationTest1"} | DBS Bank Ltd | SGP     | 200         | 0                 | 0             |

  Scenario Outline: Create EndCustomerProfile account with invalid onBehalfOf value and verify failure codes
    Given I create a product with customer profile <customer_profile_identifier> provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier    | product_type   | profile_type | product_class | currency   | country   | account_type | balance_policy_limit   | balance_policy_type    |
      | ProductID1    | WALLET         | END_CUSTOMER |  SHARIAH      | <currency> | <country> | SAVINGS      | <balance_policy_limit> | <balance_policy_type>  |

    Then I approve the product ProductID1 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId <customer_profile_identifier>

    Given I create account for EndCustomerProfile with id <end_customer_profile_identifier> for CustomerProfile <customer_profile_identifier> with product id ProductID1 with bank account type as <account_type> with provider <bank_name> and expect the header status <status_code>
      | identifier | customer_profile_id   | end_customer_profile_id   | currency   | country   | in_trust   | on_behalf_of   | metadata   |
      | BankAccId  | <customer_profile_id> | <end_customer_profile_id> | <currency> | <country> | <in_trust> | <on_behalf_of> | <metadata> |

    Examples:
      | customer_profile_identifier | end_customer_profile_identifier | account_type | currency | country | in_trust | balance_policy_limit | balance_policy_type | on_behalf_of       | metadata                    | bank_name    | status_code |
      | BCPID1                      | ECPID1                          | PPA          | SGD      | SGP     | false    | 0                    | STRICT              | INVESTMENT_SERVICE | {"key": "IntegrationTest1"} | DBS Bank Ltd | CSSM_9710   |
      | BCPID1                      | ECPID1                          | PPA          | SGD      | SGP     | false    | 0                    | STRICT              | CARD_SERVICE       | {"key": "IntegrationTest1"} | DBS Bank Ltd | CSSM_9710   |
