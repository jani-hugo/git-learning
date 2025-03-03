Feature: Banking service bank account beneficiaries scenarios

  Background: Setup CustomerProfile and EndCustomerProfile profile onto banking

    #CustomerProfile verifying and Onboarding on to banking service on given providers
    Given I set and verify customer BCID1, customer profile BCPID1 on cash service on below providers and expect status 200 in the context
      | provider_name |
      | DBS Bank Ltd  |

    Then I wait until max time to verify CustomerProfile BCPID1 onboard status as ONBOARD_SUCCESS

    Then I create below End-Customer-Profile
      | customer_identifier | customer_profile_identifier | end_customer_profile_identifier | first_name | last_name | region | email   | phone_number |
      | BCID1               | BCPID1                      | ECPID1                          | banking    | service   | SG     | x@y.com | 00000000     |

    Then I wait until max time to verify CustomerProfile BCPID1 onboard status as ONBOARD_SUCCESS

    # EndCustomerProfile Onboarding
    Given I onboard EndCustomerProfile ECPID1 of CustomerProfile BCPID1 on cash service on below providers and expect status 200
      | provider_name |
      | DBS Bank Ltd  |

    Then I wait until max time to verify EndCustomerProfile ECPID1 of CustomerProfile BCPID1 onboard status as ONBOARD_SUCCESS

  Scenario Outline: Create and Verify adding internal account as a beneficiary.

    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier    | product_type   | profile_type | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type    |
      | ProductID1    | WALLET         | CUSTOMER     |  SHARIAH      | <currency> | <country> | SAVINGS      | <balance_policy_limit>  | <balance_policy_type>  |

    Then I approve the product ProductID1 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Given I create account for CustomerProfile with id BCPID1 with product id as ProductID1 with bank account type as Payments Account with provider DBS Bank Ltd and expect the header status 200
      | identifier         | customer_profile_id | currency | country | in_trust | on_behalf_of | metadata              | kyc_completed | trust_verification_completed |
      | CustomerProfileBA1 | IntegrationTest1    | SGD      | SGP     | false    | CUSTOMER     | {"key": "MyMetaData"} | false         | false                        |

    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier    | product_type   | profile_type | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type   |
      | ProductID2    | WALLET         | CUSTOMER     |  SHARIAH      | <currency> | <country> | SAVINGS      | <balance_policy_limit>  | <balance_policy_type> |

    Then I approve the product ProductID2 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Given I create account for CustomerProfile with id BCPID1 with product id as ProductID2 with bank account type as Payments Account with provider DBS Bank Ltd and expect the header status 200
      | identifier         | customer_profile_id | end_customer_profile_id | currency | country | in_trust | on_behalf_of | metadata              | kyc_completed | trust_verification_completed |
      | CustomerProfileBA2 | IntegrationTest1    | IntegrationEndCustomer  | SGD      | SGP     | false    | CUSTOMER     | {"key": "MyMetaData"} | false         | false                        |

    Then I wait until max time to verify the bank account CustomerProfileBA1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    Then I wait until max time to verify the bank account CustomerProfileBA2 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    When I add bank account CustomerProfileBA2 as beneficiary to bank account CustomerProfileBA1 of CustomerProfile BCPID1 for provider DBS Bank Ltd and expect status <status_code>
      | identifier     | beneficiary_name   | address   | beneficiary_email   | is_hidden   | metadata              | is_overdraft_allowed   |
      | BeneficiaryId1 | <beneficiary_name> | <address> | <beneficiary_email> | <is_hidden> | {"key": "MyMetaData"} | <is_overdraft_allowed> |

    Then I wait until max time to verify beneficiary BeneficiaryId1 create status as BENEFICIARY_CREATED with provider <bank_name> for customerProfileId BCPID1

    Then I verify bank account CustomerProfileBA1 has bank account CustomerProfileBA2 as beneficiary on provider DBS Bank Ltd with values for customerProfileId BCPID1
      | identifier     | beneficiary_name   | address   | beneficiary_email   | is_hidden   | metadata              | is_overdraft_allowed   |
      | BeneficiaryId1 | <beneficiary_name> | <address> | <beneficiary_email> | <is_hidden> | {"key": "MyMetaData"} | <is_overdraft_allowed> |

    Examples:
      | bank_name        | country | currency | beneficiary_name | beneficiary_email     | is_hidden | is_overdraft_allowed | balance_policy_limit | balance_policy_type | address                                                                                                                                                                    | status_code |
      | DBS Bank Ltd     | SGP     | SGD      | Beneficiary1     | beneficiary1@test.com | false     | false                | 0                    | STRICT              | {"address_line_1":"line1","address_line_2":"line2","address_line_3":"line3","address_line_4":"line4","city":"Tokyo","state":"Tokyo","country_code":"JP","local_code":"JP"} | 200         |
      | DBS Bank Ltd     | SGP     | SGD      | Beneficiary1     | beneficiary1@test.com | false     | false                | 0                    | STRICT              | {"address_line_1":"line1","address_line_2":"line2","address_line_3":"line3","address_line_4":"line4","city":"Tokyo","state":"Tokyo","country_code":"JP","local_code":"JP"} | 200         |
      | DBS Bank Ltd     | SGP     | SGD      | Beneficiary1     | beneficiary1@test.com | true      | false                | 0                    | STRICT              | {"address_line_1":"line1","address_line_2":"line2","address_line_3":"line3","address_line_4":"line4","city":"Tokyo","state":"Tokyo","country_code":"JP","local_code":"JP"} | 200         |
      | DBS Bank Ltd     | SGP     | SGD      | Beneficiary1     | beneficiary1@test.com | true      | false                | 0                    | STRICT              | {"address_line_1":"line1","address_line_2":"line2","address_line_3":"line3","address_line_4":"line4","city":"Tokyo","state":"Tokyo","country_code":"JP","local_code":"JP"} | 200         |

  Scenario Outline: Create and verify beneficiary between Hugoserve account and an external Account

    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier | product_type | profile_type | product_class | currency   | country   | account_type | balance_policy_limit | balance_policy_type |
      | ProductID1 | WALLET       | END_CUSTOMER    | SHARIAH       | <currency> | <country> | SAVINGS      | 0                    | STRICT              |

    Then I approve the product ProductID1 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Given I create account for EndCustomerProfile with id ECPID1 for CustomerProfile BCPID1 with product id ProductID1 with bank account type as PPA with provider DBS Bank Ltd and expect the header status 200
      | identifier | customer_profile_id | end_customer_profile_id | currency        | country       | in_trust  | on_behalf_of | metadata              | kyc_completed | trust_verification_completed |
      | BankAccId1 | IntegrationTest1    | IntegrationEndCustomer  | <currency>      | <country>     | false     | CUSTOMER     | {"key": "MyMetaData"} | false         | false                        |

    Then I wait until max time to verify the bank account BankAccId1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    When I add External Bank Account as beneficiary to bank account BankAccId1 of CustomerProfile BCPID1 for provider DBS Bank Ltd and expect status <status_code>
      | identifier     | beneficiary_name   | address   | beneficiary_email   | is_hidden   | metadata              | is_overdraft_allowed   | beneficiary_account_details   |
      | BeneficiaryId1 | <beneficiary_name> | <address> | <beneficiary_email> | <is_hidden> | {"key": "MyMetaData"} | <is_overdraft_allowed> | <beneficiary_account_details> |

    Then I wait until max time to verify beneficiary BeneficiaryId1 create status as BENEFICIARY_CREATED with provider <bank_name> for customerProfileId BCPID1

    Then I verify hugoserve bank account BankAccId1 has bank account External Bank Account as beneficiary with provider <bank_name> with values for customerProfileId BCPID1
      | identifier     | beneficiary_name   | address   | beneficiary_email   | is_hidden   | metadata              | is_overdraft_allowed   | beneficiary_account_details   |
      | BeneficiaryId1 | <beneficiary_name> | <address> | <beneficiary_email> | <is_hidden> | {"key": "MyMetaData"} | <is_overdraft_allowed> | <beneficiary_account_details> |

    Examples:
      | bank_name     | country | currency          | beneficiary_name | beneficiary_email     | is_hidden | is_overdraft_allowed | address                                                                                                                                                                               | beneficiary_account_details                                                                                                                                   | status_code |
      | DBS Bank Ltd  | SGP     | SGD               | Beneficiary1     | beneficiary1@test.com | false     | false                           | {"address_line_1":"line1","address_line_2":"line2","address_line_3":"line3","address_line_4":"line4","city":"Tokyo","state":"Tokyo","country_code":"JP","local_code":"JP"} | {"bank_name":"SBI","currency":"SGD","country":"SGP","code_details":{"sg_code_details":{"swift_bic":"DBSSS0SGXXX","account_number": "1123344455"}}}            | 200         |
      | DBS Bank Ltd  | SGP     | SGD               | Beneficiary1     | beneficiary1@test.com | false     | false                           | {"address_line_1":"line1","address_line_2":"line2","address_line_3":"line3","address_line_4":"line4","city":"Tokyo","state":"Tokyo","country_code":"JP","local_code":"JP"} | {"bank_name":"SBI","currency":"SGD","country":"SGP","code_details":{"sg_code_details":{"swift_bic":"DBSSS0SGXXX","account_number": "1123344455"}}}            | 200         |
      | DBS Bank Ltd  | SGP     | SGD               | Beneficiary1     | beneficiary1@test.com | false     | false                           | {"address_line_1":"line1","address_line_2":"line2","address_line_3":"line3","address_line_4":"line4","city":"Tokyo","state":"Tokyo","country_code":"JP","local_code":"JP"} | {"bank_name":"SBI","currency":"SGD","country":"SGP","code_details":{"sg_code_details":{"swift_bic":"DBSSS0SGXXX","account_number": "1123344455"}}}            | 200         |
      | DBS Bank Ltd  | SGP     | SGD               | Beneficiary1     | beneficiary1@test.com | false     | false                           | {"address_line_1":"line1","address_line_2":"line2","address_line_3":"line3","address_line_4":"line4","city":"Tokyo","state":"Tokyo","country_code":"JP","local_code":"JP"} | {"bank_name":"SBI","currency":"SGD","country":"SGP","code_details":{"sg_code_details":{"swift_bic":"DBSSS0SGXXX"}}}                                            | E9400       |

  Scenario Outline: Create and Verify adding self account as a beneficiary gives error status

    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier    | product_type   | profile_type | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type    |
      | ProductID1    | WALLET         | END_CUSTOMER     |  SHARIAH      | <currency> | <country> | SAVINGS      | 0                       | STRICT                 |

    Then I approve the product ProductID1 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Given I create account for EndCustomerProfile with id ECPID1 for CustomerProfile BCPID1 with product id ProductID1 with bank account type as PPA with provider <bank_name> and expect the header status 200
      | identifier | customer_profile_id | end_customer_profile_id | currency   | country        | in_trust | on_behalf_of | metadata        |
      | BankAccId1 | IntegrationTest1    | IntegrationEndCustomer  | <currency> |  <country>     | false    | CUSTOMER     | {"key": "test"} |

    Then I wait until max time to verify the bank account BankAccId1 status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId BCPID1

    When I add bank account BankAccId1 as beneficiary to bank account BankAccId1 of CustomerProfile BCPID1 for provider DBS Bank Ltd and expect status <status_code>
      | identifier     | beneficiary_name   | address   | beneficiary_email   | is_hidden   | metadata              | is_overdraft_allowed   |
      | BeneficiaryId1 | <beneficiary_name> | <address> | <beneficiary_email> | <is_hidden> | {"key": "MyMetaData"} | <is_overdraft_allowed> |

    Examples:
      | beneficiary_name | country | currency | bank_name    | beneficiary_email     | is_hidden | is_overdraft_allowed | address                                                                                                                                                                    | status_code |
      | Beneficiary1     | SGP     | SGD      | DBS Bank Ltd | beneficiary1@test.com | false     | false                           | {"address_line_1":"line1","address_line_2":"line2","address_line_3":"line3","address_line_4":"line4","city":"Tokyo","state":"Tokyo","country_code":"JP","local_code":"JP"} | CSSM_9603   |

  Scenario Outline: Create and verify 2 beneficiaries for an account

    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier    | product_type   | profile_type | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type    |
      | ProductID1    | WALLET         | CUSTOMER     |  SHARIAH      | <currency> | <country> | SAVINGS      | <balance_policy_limit>  | <balance_policy_type>  |

    Then I approve the product ProductID1 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Given I create account for EndCustomerProfile with id ECPID1 for CustomerProfile BCPID1 with product id ProductID1 with bank account type as PPA with provider DBS Bank Ltd and expect the header status 200
      | identifier             | customer_profile_id | end_customer_profile_id | currency | country | in_trust | is_overdraft_allowed | on_behalf_of | metadata              | kyc_completed | trust_verification_completed |
      | EndCustomerProfileBA2B | IntegrationTest1    | IntegrationEndCustomer  | <currency> | <country> | false    | false                | CUSTOMER     | {"key": "MyMetaData"} | false         | false                        |

    Then I wait until max time to verify the bank account EndCustomerProfileBA2B status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId BCPID1

    When I add External Bank Account as beneficiary to bank account EndCustomerProfileBA2B of CustomerProfile BCPID1 for provider DBS Bank Ltd and expect status <status_code>
      | identifier     | beneficiary_name   | address   | beneficiary_email   | is_hidden   | metadata              | is_overdraft_allowed   | beneficiary_account_details                                                                                                                           |
      | BeneficiaryId1 | <beneficiary_name> | <address> | <beneficiary_email> | <is_hidden> | {"key": "MyMetaData"} | <is_overdraft_allowed> | {"bank_name":"SBI","currency":"SGD", "account_number": "112334445335","country":"SGP","code_details":{"sg_code_details":{"swift_bic":"DBSSS0SGXXX"}}} |

    When I add External Bank Account as beneficiary to bank account EndCustomerProfileBA2B of CustomerProfile BCPID1 for provider DBS Bank Ltd and expect status <status_code>
      | identifier     | beneficiary_name   | address   | beneficiary_email   | is_hidden   | metadata              | is_overdraft_allowed   | beneficiary_account_details                                                                                                                         |
      | BeneficiaryId2 | <beneficiary_name> | <address> | <beneficiary_email> | <is_hidden> | {"key": "MyMetaData"} | <is_overdraft_allowed> | {"bank_name":"SBI","currency":"SGD","country":"SGP","code_details":{"sg_code_details":{"swift_bic":"DBSSS0SGXXX","account_number": "1123344455"}}} |

    Then I wait until max time to verify beneficiary BeneficiaryId2 create status as BENEFICIARY_CREATED with provider <bank_name> for customerProfileId BCPID1

    Then I verify hugoserve bank account EndCustomerProfileBA2B has 2 beneficiaries created with provider <bank_name> with values for customerProfileId BCPID1
      | identifier     | beneficiary_name   | address   | beneficiary_email   | is_hidden   | metadata              | is_overdraft_allowed   | beneficiary_account_details   |
      | BeneficiaryId1 | <beneficiary_name> | <address> | <beneficiary_email> | <is_hidden> | {"key": "MyMetaData"} | <is_overdraft_allowed> | <beneficiary_account_details> |
      | BeneficiaryId2 | <beneficiary_name> | <address> | <beneficiary_email> | <is_hidden> | {"key": "MyMetaData"} | <is_overdraft_allowed> | <beneficiary_account_details> |

    Examples:
      | bank_name    | beneficiary_name | beneficiary_email     | is_hidden | is_overdraft_allowed | address                                                                                                                                                                    | currency | country | status_code |
      | DBS Bank Ltd | Beneficiary1     | beneficiary1@test.com | false     | false                | {"address_line_1":"line1","address_line_2":"line2","address_line_3":"line3","address_line_4":"line4","city":"Tokyo","state":"Tokyo","country_code":"JP","local_code":"JP"} | SGD      | SGP     | 200         |

  Scenario Outline: Creating beneficiary with invalid accountId

    Given I add External Bank Account as beneficiary to hugoserve bank account EndCustomerProfileBA2B of CustomerProfile BCPID1 for provider <bank_name> and expect status <status_code>
      | identifier     | beneficiary_name   | address   | beneficiary_email   | is_hidden   | metadata              | is_overdraft_allowed   | beneficiary_account_details                                                                                                                           |
      | BeneficiaryId1 | <beneficiary_name> | <address> | <beneficiary_email> | <is_hidden> | {"key": "MyMetaData"} | <is_overdraft_allowed> | {"bank_name":"SBI","currency":"SGD", "account_number": "112334445335","country":"SGP","code_details":{"sg_code_details":{"swift_bic":"DBSSS0SGXXX"}}} |

    Examples:
      | bank_name    | beneficiary_name | beneficiary_email     | is_hidden | is_overdraft_allowed | address                                                                                                                                                                    | status_code |
      | DBS Bank Ltd | Beneficiary1     | beneficiary1@test.com | false     | false                           | {"address_line_1":"line1","address_line_2":"line2","address_line_3":"line3","address_line_4":"line4","city":"Tokyo","state":"Tokyo","country_code":"JP","local_code":"JP"} | CSSM_9448   |

  Scenario Outline: Create and verify creating a negative beneficiary

    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier    | product_type   | profile_type | product_class | currency    | country   | account_type | balance_policy_limit    | balance_policy_type  |
      | ProductID1    | WALLET         | CUSTOMER     |  SHARIAH      | SGD         | SGP       | SAVINGS      | 0                       | STRICT               |

    Then I approve the product ProductID1 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Given I create account for CustomerProfile with id BCPID1 with product id as ProductID1 with bank account type as Payments Account with provider DBS Bank Ltd and expect the header status 200
      | identifier         | customer_profile_id | currency | country | in_trust | on_behalf_of | metadata              | kyc_completed | trust_verification_completed |
      | CustomerProfileBA1 | IntegrationTest1    | SGD      | SGP     | false    | CUSTOMER     | {"key": "MyMetaData"} | false         | false                        |

    Then I wait until max time to verify the bank account CustomerProfileBA1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier    | product_type   | profile_type | product_class | currency   | country   | account_type | balance_policy_limit   | balance_policy_type    |
      | ProductID2    | WALLET         | END_CUSTOMER |  SHARIAH      | SGD        | SGP       | SAVINGS      | <balance_policy_limit> |  <balance_policy_type> |

    Then I approve the product ProductID2 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Given I create account for EndCustomerProfile with id ECPID1 for CustomerProfile BCPID1 with product id ProductID2 with bank account type as e-money with provider DBS Bank Ltd and expect the header status 200
      | identifier | customer_profile_id | end_customer_profile_id | currency | country | in_trust  | on_behalf_of | metadata              | kyc_completed | trust_verification_completed |
      | BankAccId1 | IntegrationTest1    | IntegrationEndCustomer  | SGD      | SGP     | false     | CUSTOMER     | {"key": "MyMetaData"} | false         | false                        |

    Then I wait until max time to verify the bank account BankAccId1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
      | identifier    | product_type   | profile_type | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type |
      | ProductID3    | WALLET         | END_CUSTOMER |  SHARIAH      | SGD        | SGP       | SAVINGS      | 0                       | STRICT              |

    Then I approve the product ProductID3 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1

    Given I create account for EndCustomerProfile with id ECPID1 for CustomerProfile BCPID1 with product id ProductID3 with bank account type as PPA with provider DBS Bank Ltd and expect the header status 200
      | identifier  | customer_profile_id | end_customer_profile_id | currency | country | in_trust | on_behalf_of | metadata              | kyc_completed | trust_verification_completed |
      | BankAccId12 | IntegrationTest1    | IntegrationEndCustomer  | SGD      | SGP     | false    | CUSTOMER     | {"key": "MyMetaData"} | false         | false                        |

    Then I wait until max time to verify the bank account BankAccId12 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1

    When I add External Bank Account as beneficiary to bank account BankAccId1 of CustomerProfile BCPID1 for provider DBS Bank Ltd and expect status <status_code>
      | identifier     | beneficiary_name   | address   | beneficiary_email   | is_hidden   | metadata              | is_overdraft_allowed   | beneficiary_account_details   | overdraft_funding_account_id   |
      | BeneficiaryId1 | <beneficiary_name> | <address> | <beneficiary_email> | <is_hidden> | {"key": "MyMetaData"} | <is_overdraft_allowed> | <beneficiary_account_details> | <overdraft_funding_account_id> |

    Then I wait until max time to verify beneficiary BeneficiaryId1 create status as BENEFICIARY_CREATED with provider <bank_name> for customerProfileId BCPID1

    Then I verify hugoserve bank account BankAccId1 has bank account External Bank Account as beneficiary with provider <bank_name> with values for customerProfileId BCPID1
      | identifier     | beneficiary_name   | address   | beneficiary_email   | is_hidden   | metadata              | is_overdraft_allowed   | beneficiary_account_details   |
      | BeneficiaryId1 | <beneficiary_name> | <address> | <beneficiary_email> | <is_hidden> | {"key": "MyMetaData"} | <is_overdraft_allowed> | <beneficiary_account_details> |

    Examples:
      | bank_name    | beneficiary_name | beneficiary_email     | is_hidden | is_overdraft_allowed             | balance_policy_limit| balance_policy_type   | overdraft_funding_account_id | address                                                                                                                                                                    | beneficiary_account_details                                                                                                                         | status_code |
      | DBS Bank Ltd | Beneficiary1     | beneficiary1@test.com | false     | true                             |   0                 |  LENIENT              |CustomerProfileBA1            | {"address_line_1":"line1","address_line_2":"line2","address_line_3":"line3","address_line_4":"line4","city":"Tokyo","state":"Tokyo","country_code":"JP","local_code":"JP"} | {"bank_name":"SBI","currency":"SGD","country":"SGP","code_details":{"sg_code_details":{"swift_bic":"DBSSS0SGXXX","account_number": "1123344455"}}} | 200         |
      | DBS Bank Ltd | Beneficiary1     | beneficiary1@test.com | false     | true                             |   0                 |  LENIENT              |                              | {"address_line_1":"line1","address_line_2":"line2","address_line_3":"line3","address_line_4":"line4","city":"Tokyo","state":"Tokyo","country_code":"JP","local_code":"JP"} | {"bank_name":"SBI","currency":"SGD","country":"SGP","code_details":{"sg_code_details":{"swift_bic":"DBSSS0SGXXX","account_number": "1123344455"}}} | E9400       |
      | DBS Bank Ltd | Beneficiary1     | beneficiary1@test.com | false     | true                             |   0                 |  LENIENT             |  BankAccId12                 | {"address_line_1":"line1","address_line_2":"line2","address_line_3":"line3","address_line_4":"line4","city":"Tokyo","state":"Tokyo","country_code":"JP","local_code":"JP"} | {"bank_name":"SBI","currency":"SGD", "country":"SGP","code_details":{"sg_code_details":{"swift_bic":"DBSSS0SGXXX","account_number": "1123344455"}}} | CSSM_9707   |
      | DBS Bank Ltd | Beneficiary1     | beneficiary1@test.com | false     | true                             |   0                 | STRICT.              |CustomerProfileBA1            | {"address_line_1":"line1","address_line_2":"line2","address_line_3":"line3","address_line_4":"line4","city":"Tokyo","state":"Tokyo","country_code":"JP","local_code":"JP"} | {"bank_name":"SBI","currency":"SGD", "country":"SGP","code_details":{"sg_code_details":{"swift_bic":"DBSSS0SGXXX","account_number": "1123344455"}}} | CSSM_9605   |
