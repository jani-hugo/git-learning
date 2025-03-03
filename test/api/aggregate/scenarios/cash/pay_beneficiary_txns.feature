#Feature: cash service transaction, payments and deposit scenarios
#
#  Background: Setup customer and end-customer profile on banking
#
#     #CustomerProfile verifying and Onboarding on to banking service on given providers
#    Given I set and verify customer BCID1, customer profile BCPID1 on cash service on below providers and expect status 200 in the context
#      | provider_name |
#      | DBS Bank Ltd  |
#
#    Then I wait until max time to verify CustomerProfile BCPID1 onboard status as ONBOARD_SUCCESS
#
#    Then I create below End-Customer-Profile
#      | customer_identifier | customer_profile_identifier | end_customer_profile_identifier | first_name | last_name | region | email   | phone_number |
#      | BCID1               | BCPID1                      | ECPID1                          | banking    | service   | SG     | x@y.com | 00000000     |
#
#    Then I verify End-Customer-Profile exist with values
#      | customer_profile_identifier | end_customer_profile_identifier | customer_profile_id   | first_name | last_name | email   | phone_number | status |
#      | BCPID1                      | ECPID1                          | <customer_profile_id> | banking    | service   | x@y.com | 00000000     | ACTIVE |
#
#    # EndCustomerProfile Onboarding
#    Given I onboard EndCustomerProfile ECPID1 of CustomerProfile BCPID1 on cash service on below providers and expect status 200
#      | provider_name |
#      | DBS Bank Ltd  |
#
#    Then I wait until max time to verify EndCustomerProfile ECPID1 of CustomerProfile BCPID1 onboard status as ONBOARD_SUCCESS
#
#  Scenario Outline: I call Pay Beneficiary to transfer an amount between internal Hugoserve bank accounts and verify the transaction is settled
#
#    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
#      | identifier    | product_type   | profile_type | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type    |
#      | ProductID1    | CASH_ACCOUNT   | CUSTOMER     |  SHARIAH      | <currency> | <country> | SAVINGS      | 0                       | STRICT                 |
#
#    Then I approve the product ProductID1 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1
#
#    Given I create account for CustomerProfile with id BCPID1 with product id as ProductID1 with bank account type as <account_type> with provider <bank_name> and expect the header status 200
#      | identifier | customer_profile_id | currency | country | in_trust  | on_behalf_of | metadata                           |
#      | BankAccId1 | BCPID1              | SGD      | SGP     | false     | CUSTOMER     | {"key": "TransactionIntegration1"} |
#
#    Then I wait until max time to verify the bank account BankAccId1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1
#
#    Then I verify for bank account BankAccId1 total balance is 0 and available balance is 0 for customerProfileId BCPID1
#
#    Given I create account for CustomerProfile with id BCPID1 with product id as ProductID1 with bank account type as <account_type> with provider <bank_name> and expect the header status 200
#      | identifier | customer_profile_id | currency | country | in_trust  | on_behalf_of | metadata                           |
#      | BankAccId2 | BCPID1              | SGD      | SGP     | false     | CUSTOMER     | {"key": "TransactionIntegration1"} |
#
#    Then I wait until max time to verify the bank account BankAccId2 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1
#
#    Then I verify for bank account BankAccId2 total balance is <initial_total_balance> and available balance is <initial_available_balance> for customerProfileId BCPID1
#
#    When I add bank account BankAccId1 as beneficiary to bank account BankAccId2 of CustomerProfile BCPID1 for provider <bank_name> and expect status 200
#      | identifier     | beneficiary_name | address                                                                                                                                                                    | beneficiary_email     | is_hidden | metadata              | is_overdraft_allowed |
#      | BeneficiaryId1 | Beneficiary1     | {"address_line_1":"line1","address_line_2":"line2","address_line_3":"line3","address_line_4":"line4","city":"Tokyo","state":"Tokyo","country_code":"JP","local_code":"JP"} | beneficiary1@test.com | false     | {"key": "MyMetaData"} | false                |
#
#    Then I wait until max time to verify beneficiary BeneficiaryId1 create status as BENEFICIARY_CREATED with provider <bank_name> for customerProfileId BCPID1
#
#    Then I verify bank account BankAccId2 has bank account BankAccId1 as beneficiary on provider <bank_name> with values for customerProfileId BCPID1
#      | identifier     | beneficiary_name | address                                                                                                                                                                    | beneficiary_email     | is_hidden | metadata              | is_overdraft_allowed |
#      | BeneficiaryId1 | Beneficiary1     | {"address_line_1":"line1","address_line_2":"line2","address_line_3":"line3","address_line_4":"line4","city":"Tokyo","state":"Tokyo","country_code":"JP","local_code":"JP"} | beneficiary1@test.com | false     | {"key": "MyMetaData"} | false                |
#
#    Given I deposit an amount of <deposit_amount> into BankAccId2 using cash DevDeposit and expect the header status 200
#      | identifier           | customer_profile_id | purpose  | currency | transaction_rail |
#      | DevDepositIdentifier | BCPID1              | TRANSFER | SGD      | FAST             |
#
#    Then I wait until max time to verify bank account BankAccId2 with an increased balance of <deposit_amount> for customerProfileId BCPID1
#
#    Then I initiate pay beneficiary to transfer funds with below details and expect the header status <status_code> and <message>
#      | identifier | customer_profile_id | account_id | beneficiary_id | amount   | purpose          | transaction_rail | is_overdraft_allowed | overdraft_funding_account_id | metadata              | currency | total_balance    | available_balance |
#      | TxId1      | BCPID1              | BankAccId2 | BeneficiaryId1 | <amount> | Integration Test | FAST             | false                |                              | {"key": "MyMetaData"} | SGD      | <deposit_amount> | <deposit_amount>  |
#
#    Then I verify for bank account BankAccId2 total balance is <total_balance> and available balance is <available_balance> for customerProfileId BCPID1
#
#    Then I wait until max time to verify bank account BankAccId1 total balance is <SAVINGS_total_balance> and available balance is <SAVINGS_available_balance>  for customerProfileId BCPID1
#
#    Examples:
#      | amount | bank_name    | account_type     | initial_total_balance | initial_available_balance | status_code | deposit_amount | total_balance | available_balance | SAVINGS_total_balance | SAVINGS_available_balance | message             | country | currency |
#      | 10     | DBS Bank Ltd | Payments Account | 0                     | 0                         | 200         | 100            | 90            | 90                | 10                    | 10                        | TRANSACTION_PENDING | SGP     | SGD      |
#      | 20     | DBS Bank Ltd | Payments Account | 0                     | 0                         | 200         | 100            | 80            | 80                | 20                    | 20                        | TRANSACTION_PENDING | SGP     | SGD      |
#
#  Scenario Outline: I call Pay Beneficiary to transfer amount from an Hugoserve bank account to an external beneficiary and verify the transaction is settled
#    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
#      | identifier    | product_type   | profile_type | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type    |
#      | ProductID1    | CASH_ACCOUNT   | CUSTOMER     |  SHARIAH      | <currency> | <country> | SAVINGS      | 0                       | STRICT                 |
#
#    Then I approve the product ProductID1 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1
#
#    Given I create account for CustomerProfile with id BCPID1 with product id as ProductID1 with bank account type as <account_type> with provider <bank_name> and expect the header status 200
#      | identifier | customer_profile_id | currency | country | in_trust  | on_behalf_of | metadata                           |
#      | BankAccId1 | BCPID1              | SGD      | SGP     | false     | CUSTOMER     | {"key": "TransactionIntegration1"} |
#
#    Then I wait until max time to verify the bank account BankAccId1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1
#
#    Then I verify for bank account BankAccId1 total balance is <initial_total_balance> and available balance is <initial_available_balance> for customerProfileId BCPID1
#
#    When I add External Bank Account as beneficiary to bank account BankAccId1 of CustomerProfile BCPID1 for provider <bank_name> and expect status 200
#      | identifier     | beneficiary_name | address                                                                                                                                                                    | beneficiary_email     | is_hidden | metadata              | is_overdraft_allowed | beneficiary_account_details                                                                                                                        |
#      | BeneficiaryId1 | Beneficiary1     | {"address_line_1":"line1","address_line_2":"line2","address_line_3":"line3","address_line_4":"line4","city":"Tokyo","state":"Tokyo","country_code":"JP","local_code":"JP"} | beneficiary1@test.com | false     | {"key": "MyMetaData"} | false                | {"bank_name":"SBI","currency":"SGD","country":"SGP","code_details":{"sg_code_details":{"swift_bic":"DBSSSGSGXXX","account_number": "1123344455"}}} |
#
#    Then I wait until max time to verify beneficiary BeneficiaryId1 create status as BENEFICIARY_CREATED with provider <bank_name> for customerProfileId BCPID1
#
#    Then I verify hugoserve bank account BankAccId1 has bank account External Bank Account as beneficiary with provider <bank_name> with values for customerProfileId BCPID1
#      | identifier     | beneficiary_name | address                                                                                                                                                                    | beneficiary_email     | is_hidden | metadata              | is_overdraft_allowed | beneficiary_account_details                                                                                                                        |
#      | BeneficiaryId1 | Beneficiary1     | {"address_line_1":"line1","address_line_2":"line2","address_line_3":"line3","address_line_4":"line4","city":"Tokyo","state":"Tokyo","country_code":"JP","local_code":"JP"} | beneficiary1@test.com | false     | {"key": "MyMetaData"} | false                | {"bank_name":"SBI","currency":"SGD","country":"SGP","code_details":{"sg_code_details":{"swift_bic":"DBSSSGSGXXX","account_number": "1123344455"}}} |
#
#    Given I deposit an amount of <deposit_amount> into BankAccId1 using cash DevDeposit and expect the header status 200
#      | identifier           | customer_profile_id | purpose  | currency | transaction_rail |
#      | DevDepositIdentifier | BCPID1              | TRANSFER | SGD      | FAST             |
#
#    Then I wait until max time to verify bank account BankAccId1 with an increased balance of <deposit_amount> for customerProfileId BCPID1
#
#    Then I initiate pay beneficiary to transfer funds with below details and expect the header status <status_code> and <message>
#      | identifier | customer_profile_id | account_id | beneficiary_id | amount   | purpose          | transaction_rail | is_overdraft_allowed | overdraft_funding_account_id | metadata              | currency | total_balance    | available_balance |
#      | TxId1      | BCPID1              | BankAccId1 | BeneficiaryId1 | <amount> | Integration Test | FAST             | false                |                              | {"key": "MyMetaData"} | SGD      | <deposit_amount> | <deposit_amount>  |
#
#    Then I wait until max time to verify the transaction TxId1 status as TRANSACTION_SETTLED for customerProfileId BCPID1
#
#    Then I verify for bank account BankAccId1 total balance is <total_balance> and available balance is <available_balance> for customerProfileId BCPID1
#
#    Examples:
#      | amount | bank_name    | account_type     | initial_total_balance | initial_available_balance | status_code | deposit_amount | total_balance | available_balance | message             | country | currency |
#      | 10     | DBS Bank Ltd | Payments Account | 0                     | 0                         | 200         | 100            | 90            | 90                | TRANSACTION_PENDING | SGP     | SGD      |
#      | 20     | DBS Bank Ltd | Payments Account | 0                     | 0                         | 200         | 100            | 80            | 80                | TRANSACTION_PENDING | SGP     | SGD      |
#
#  Scenario Outline: I call Pay Beneficiary to transfer amount from an Hugoserve DBS Bank Ltd bank account to an external beneficiary with invalid data and validate and strip invalid data and settle the txn
#    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
#      | identifier    | product_type   | profile_type | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type    |
#      | ProductID1    | CASH_ACCOUNT   | CUSTOMER     |  SHARIAH      | <currency> | <country> | SAVINGS      | 0                       | STRICT                 |
#
#    Then I approve the product ProductID1 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1
#
#    Given I create account for CustomerProfile with id BCPID1 with product id as ProductID1 with bank account type as <account_type> with provider <bank_name> and expect the header status 200
#      | identifier | customer_profile_id | currency | country | in_trust  | on_behalf_of | metadata                           |
#      | BankAccId1 | BCPID1              | SGD      | SGP     | false     | CUSTOMER     | {"key": "TransactionIntegration1"} |
#
#    Then I wait until max time to verify the bank account BankAccId1 status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId BCPID1
#
#    Then I verify for bank account BankAccId1 total balance is <initial_total_balance> and available balance is <initial_available_balance> for customerProfileId BCPID1
#
#    When I add External Bank Account as beneficiary to bank account BankAccId1 of CustomerProfile BCPID1 for provider <bank_name> and expect status 200
#      | identifier     | beneficiary_name | address                                                                                                                                                                    | beneficiary_email     | is_hidden | metadata              | is_overdraft_allowed | beneficiary_account_details                                                                                                                         |
#      | BeneficiaryId1 | Beneficiary1     | {"address_line_1":"line1","address_line_2":"line2","address_line_3":"line3","address_line_4":"line4","city":"Tokyo","state":"Tokyo","country_code":"JP","local_code":"JP"} | beneficiary1@test.com | false     | {"key": "MyMetaData"} | false                | {"bank_name":"SBI","currency":"SGD","country":"SGP","code_details":{"sg_code_details":{"swift_bic":"DBSSSGSGXXX", "account_number": "1123344455"}}} |
#
#    Then I wait until max time to verify beneficiary BeneficiaryId1 create status as BENEFICIARY_CREATED with provider <bank_name> for customerProfileId BCPID1
#
#    Then I verify hugoserve bank account BankAccId1 has bank account External Bank Account as beneficiary with provider <bank_name> with values for customerProfileId BCPID1
#      | identifier     | beneficiary_name | address                                                                                                                                                                    | beneficiary_email     | is_hidden | metadata              | is_overdraft_allowed | beneficiary_account_details                                                                                                                         |
#      | BeneficiaryId1 | Beneficiary1     | {"address_line_1":"line1","address_line_2":"line2","address_line_3":"line3","address_line_4":"line4","city":"Tokyo","state":"Tokyo","country_code":"JP","local_code":"JP"} | beneficiary1@test.com | false     | {"key": "MyMetaData"} | false                | {"bank_name":"SBI","currency":"SGD","country":"SGP","code_details":{"sg_code_details":{"swift_bic":"DBSSSGSGXXX", "account_number": "1123344455"}}} |
#
#    Given I deposit an amount of <deposit_amount> into BankAccId1 using cash DevDeposit and expect the header status 200
#      | identifier           | customer_profile_id | purpose  | currency | transaction_rail |
#      | DevDepositIdentifier | BCPID1              | TRANSFER | SGD      | FAST             |
#
#    Then I wait until max time to verify bank account BankAccId1 with an increased balance of <deposit_amount> for customerProfileId BCPID1
#
#    Then I initiate pay beneficiary to transfer funds with below details and expect the header status <status_code> and <message>
#      | identifier | customer_profile_id | account_id | beneficiary_id | amount               | purpose          | transaction_rail | is_overdraft_allowed | overdraft_funding_account_id | metadata              | currency | total_balance    | available_balance |
#      | TxId1      | BCPID1              | BankAccId1 | BeneficiaryId1 | <transaction_amount> | IntegrationTest# | FAST             | false                |                              | {"key": "MyMetaData"} | SGD      | <deposit_amount> | <deposit_amount>  |
#
#    Then I wait until max time to verify the transaction TxId1 status as TRANSACTION_SETTLED for customerProfileId BCPID1
#
#    Then I verify for bank account BankAccId1 total balance is <total_balance> and available balance is <available_balance> for customerProfileId BCPID1
#
#    Examples:
#      | transaction_amount | bank_name    | account_type     | initial_total_balance | initial_available_balance | status_code | deposit_amount | total_balance | available_balance | message             | country | currency |
#      | 10                 | DBS Bank Ltd | Payments Account | 0                     | 0                         | 200         | 100            | 90            | 90                | TRANSACTION_PENDING | SGP     | SGD      |
#      | 20                 | DBS Bank Ltd | Payments Account | 0                     | 0                         | 200         | 100            | 80            | 80                | TRANSACTION_PENDING | SGP     | SGD      |
#
#  Scenario Outline: I call Pay Pay Beneficiary with wrong account id and verify its failure
#    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
#      | identifier    | product_type   | profile_type | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type    |
#      | ProductID1    | CASH_ACCOUNT   | CUSTOMER     |  SHARIAH      | <currency> | <country> | SAVINGS      | 0                       | STRICT                 |
#
#    Then I approve the product ProductID1 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1
#
#    Given I create account for CustomerProfile with id BCPID1 with product id as ProductID1 with bank account type as <account_type> with provider <bank_name> and expect the header status 200
#      | identifier | customer_profile_id | currency | country | in_trust  | on_behalf_of | metadata                           |
#      | BankAccId1 | BCPID1              | SGD      | SGP     | false     | CUSTOMER     | {"key": "TransactionIntegration1"} |
#
#    Then I wait until max time to verify the bank account BankAccId1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1
#
#    Then I verify for bank account BankAccId1 total balance is <initial_total_balance> and available balance is <initial_available_balance> for customerProfileId BCPID1
#
#    When I add External Bank Account as beneficiary to bank account BankAccId1 of CustomerProfile BCPID1 for provider <bank_name> and expect status 200
#      | identifier     | beneficiary_name | address                                                                                                                                                                    | beneficiary_email     | is_hidden | metadata              | is_overdraft_allowed | beneficiary_account_details                                                                                                                          |
#      | BeneficiaryId1 | Beneficiary1     | {"address_line_1":"line1","address_line_2":"line2","address_line_3":"line3","address_line_4":"line4","city":"Tokyo","state":"Tokyo","country_code":"JP","local_code":"JP"} | beneficiary1@test.com | false     | {"key": "MyMetaData"} | false                | {"bank_name":"SBI","currency":"SGD", "country":"SGP","code_details":{"sg_code_details":{"swift_bic":"DBSSSGSGXXX", "account_number": "1123344455"}}} |
#
#    Then I wait until max time to verify beneficiary BeneficiaryId1 create status as BENEFICIARY_CREATED with provider <bank_name> for customerProfileId BCPID1
#
#    Then I verify hugoserve bank account BankAccId1 has bank account External Bank Account as beneficiary with provider <bank_name> with values for customerProfileId BCPID1
#      | identifier     | beneficiary_name | address                                                                                                                                                                    | beneficiary_email     | is_hidden | metadata              | is_overdraft_allowed | beneficiary_account_details                                                                                                                         |
#      | BeneficiaryId1 | Beneficiary1     | {"address_line_1":"line1","address_line_2":"line2","address_line_3":"line3","address_line_4":"line4","city":"Tokyo","state":"Tokyo","country_code":"JP","local_code":"JP"} | beneficiary1@test.com | false     | {"key": "MyMetaData"} | false                | {"bank_name":"SBI","currency":"SGD","country":"SGP","code_details":{"sg_code_details":{"swift_bic":"DBSSSGSGXXX", "account_number": "1123344455"}}} |
#
#    Given I deposit an amount of <deposit_amount> into BankAccId1 using cash DevDeposit and expect the header status 200
#      | identifier           | customer_profile_id | purpose  | currency | transaction_rail |
#      | DevDepositIdentifier | BCPID1              | TRANSFER | SGD      | FAST             |
#
#    Then I wait until max time to verify bank account BankAccId1 with an increased balance of <deposit_amount> for customerProfileId BCPID1
#
#    Then I initiate pay beneficiary with invalid account Id and and expect the header status <status_code> with the below values
#      | identifier | customer_profile_id | account_id | beneficiary_id | amount   | purpose          | transaction_rail | is_overdraft_allowed | overdraft_funding_account_id | metadata              | currency |
#      | TxId1      | BCPID1              | BankAccId2 | BeneficiaryId1 | <amount> | Integration Test | FAST             | false                |                              | {"key": "MyMetaData"} | SGD      |
#
#    Examples:
#      | amount | bank_name    | account_type     | initial_total_balance | initial_available_balance | status_code | deposit_amount | country | currency |
#      | 10     | DBS Bank Ltd | Payments Account | 0                     | 0                         | CSSM_9448   | 100            | SGP     | SGD      |
#
#  Scenario Outline: I call Pay Beneficiary with wrong beneficiary id and verify its failure
#
#    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
#      | identifier    | product_type   | profile_type | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type    |
#      | ProductID1    | CASH_ACCOUNT   | CUSTOMER     |  SHARIAH      | <currency> | <country> | SAVINGS      | 0                       | STRICT                 |
#
#    Then I approve the product ProductID1 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1
#
#    Given I create account for CustomerProfile with id BCPID1 with product id as ProductID1 with bank account type as <account_type> with provider <bank_name> and expect the header status 200
#      | identifier | customer_profile_id | currency | country | in_trust  | on_behalf_of | metadata                           |
#      | BankAccId1 | BCPID1              | SGD      | SGP     | false     | CUSTOMER     | {"key": "TransactionIntegration1"} |
#
#    Then I wait until max time to verify the bank account BankAccId1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1
#
#    Then I verify for bank account BankAccId1 total balance is <initial_total_balance> and available balance is <initial_available_balance> for customerProfileId BCPID1
#
#    When I add External Bank Account as beneficiary to bank account BankAccId1 of CustomerProfile BCPID1 for provider <bank_name> and expect status 200
#      | identifier     | beneficiary_name | address                                                                                                                                                                    | beneficiary_email     | is_hidden | metadata              | is_overdraft_allowed | beneficiary_account_details                                                                                                                         |
#      | BeneficiaryId1 | Beneficiary1     | {"address_line_1":"line1","address_line_2":"line2","address_line_3":"line3","address_line_4":"line4","city":"Tokyo","state":"Tokyo","country_code":"JP","local_code":"JP"} | beneficiary1@test.com | false     | {"key": "MyMetaData"} | false                | {"bank_name":"SBI","currency":"SGD","country":"SGP","code_details":{"sg_code_details":{"swift_bic":"DBSSSGSGXXX", "account_number": "1123344455"}}} |
#
#    Then I wait until max time to verify beneficiary BeneficiaryId1 create status as BENEFICIARY_CREATED with provider <bank_name> for customerProfileId BCPID1
#
#    Then I verify hugoserve bank account BankAccId1 has bank account External Bank Account as beneficiary with provider <bank_name> with values for customerProfileId BCPID1
#      | identifier     | beneficiary_name | address                                                                                                                                                                    | beneficiary_email     | is_hidden | metadata              | is_overdraft_allowed | beneficiary_account_details                                                                                                                                                         |
#      | BeneficiaryId1 | Beneficiary1     | {"address_line_1":"line1","address_line_2":"line2","address_line_3":"line3","address_line_4":"line4","city":"Tokyo","state":"Tokyo","country_code":"JP","local_code":"JP"} | beneficiary1@test.com | false     | {"key": "MyMetaData"} | false                | {"bank_name":"SBI","currency":"SGD","country":"SGP","code_details":{"sg_code_details":{"swift_bic":"DBSSSGSGXXX", "account_number": "1123344455"}}} |
#
#    Given I deposit an amount of <deposit_amount> into BankAccId1 using cash DevDeposit and expect the header status 200
#      | identifier           | customer_profile_id | purpose  | currency | transaction_rail |
#      | DevDepositIdentifier | BCPID1              | TRANSFER | SGD      | FAST             |
#
#    Then I wait until max time to verify bank account BankAccId1 with an increased balance of <deposit_amount> for customerProfileId BCPID1
#
#    Then I initiate pay beneficiary with invalid beneficiary Id and expect the header status <status_code> with the below values
#      | identifier | customer_profile_id | account_id | beneficiary_id | amount   | purpose          | transaction_rail | is_overdraft_allowed | overdraft_funding_account_id | metadata              | currency |
#      | TxId1      | BCPID1              | BankAccId1 | BeneficiaryId2 | <amount> | Integration Test | FAST             | false                |                              | {"key": "MyMetaData"} | SGD      |
#
#    Examples:
#      | amount | bank_name    | account_type     | initial_total_balance | initial_available_balance | status_code | deposit_amount | country | currency |
#      | 10     | DBS Bank Ltd | Payments Account | 0                     | 0                         | CSSM_9601   | 100            | SGP     | SGD      |
#
#  Scenario Outline: I call Pay Beneficiary with Insufficient balance and verify its failure
#
#    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
#      | identifier    | product_type   | profile_type | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type    |
#      | ProductID1    | CASH_ACCOUNT   | CUSTOMER     |  SHARIAH      | <currency> | <country> | SAVINGS      | 0                       | STRICT                 |
#
#    Then I approve the product ProductID1 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1
#
#    Given I create account for CustomerProfile with id BCPID1 with product id as ProductID1 with bank account type as <account_type> with provider <bank_name> and expect the header status 200
#      | identifier | customer_profile_id | currency | country | in_trust | is_overdraft_allowed | on_behalf_of | metadata                           |
#      | BankAccId1 | BCPID1              | SGD      | SGP     | false    | false                | CUSTOMER     | {"key": "TransactionIntegration1"} |
#
#    Then I wait until max time to verify the bank account BankAccId1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1
#
#    Then I verify for bank account BankAccId1 total balance is <initial_total_balance> and available balance is <initial_available_balance> for customerProfileId BCPID1
#
#    When I add External Bank Account as beneficiary to bank account BankAccId1 of CustomerProfile BCPID1 for provider <bank_name> and expect status 200
#      | identifier     | beneficiary_name | address                                                                                                                                                                    | beneficiary_email     | is_hidden | metadata              | is_overdraft_allowed | beneficiary_account_details                                                                                                                         |
#      | BeneficiaryId1 | Beneficiary1     | {"address_line_1":"line1","address_line_2":"line2","address_line_3":"line3","address_line_4":"line4","city":"Tokyo","state":"Tokyo","country_code":"JP","local_code":"JP"} | beneficiary1@test.com | false     | {"key": "MyMetaData"} | false                | {"bank_name":"SBI","currency":"SGD","country":"SGP","code_details":{"sg_code_details":{"swift_bic":"DBSSSGSGXXX", "account_number": "1123344455"}}} |
#
#    Then I wait until max time to verify beneficiary BeneficiaryId1 create status as BENEFICIARY_CREATED with provider <bank_name> for customerProfileId BCPID1
#
#    Then I verify hugoserve bank account BankAccId1 has bank account External Bank Account as beneficiary with provider <bank_name> with values for customerProfileId BCPID1
#      | identifier     | beneficiary_name | address                                                                                                                                                                    | beneficiary_email     | is_hidden | metadata              | is_overdraft_allowed | beneficiary_account_details                                                                                                                         |
#      | BeneficiaryId1 | Beneficiary1     | {"address_line_1":"line1","address_line_2":"line2","address_line_3":"line3","address_line_4":"line4","city":"Tokyo","state":"Tokyo","country_code":"JP","local_code":"JP"} | beneficiary1@test.com | false     | {"key": "MyMetaData"} | false                | {"bank_name":"SBI","currency":"SGD","country":"SGP","code_details":{"sg_code_details":{"swift_bic":"DBSSSGSGXXX", "account_number": "1123344455"}}} |
#
#    Then I initiate pay beneficiary to transfer funds with below details and expect the header status <status_code> and <message>
#      | identifier | customer_profile_id | account_id | beneficiary_id | amount   | purpose          | transaction_rail | balance_policy_limit | balance_policy_type | overdraft_funding_account_id | metadata              | currency |
#      | TxId1      | BCPID1              | BankAccId1 | BeneficiaryId1 | <amount> | Integration Test | FAST             | 0                    | STRICT              |                              | {"key": "MyMetaData"} | SGD      |
#
#    Examples:
#      | amount | bank_name    | account_type     | initial_total_balance | initial_available_balance | status_code | message            | country | currency |
#      | 10     | DBS Bank Ltd | Payments Account | 0                     | 0                         | CSSM_9801   | TRANSACTION_FAILED | SGP     | SGD      |
#
#  Scenario Outline: Pay beneficiary with negative allowed and lent required case
#    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
#      | identifier    | product_type   | profile_type | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type    |
#      | ProductID1    | CASH_ACCOUNT   | CUSTOMER     |  SHARIAH      | <currency> | <country> | SAVINGS      | 0                       | STRICT                 |
#
#    Then I approve the product ProductID1 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1
#
#    Given I create account for CustomerProfile with id BCPID1 with product id as ProductID1 with bank account type as Payments Account with provider DBS Bank Ltd and expect the header status 200
#      | identifier         | customer_profile_id | currency | country | in_trust  | on_behalf_of | metadata              | kyc_completed | trust_verification_completed |
#      | CustomerProfileBA1 | IntegrationTest1    | SGD      | SGP     | false     | CUSTOMER     | {"key": "MyMetaData"} | false         | false                        |
#
#    Then I wait until max time to verify the bank account CustomerProfileBA1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1
#
#    Given I deposit an amount of 1000 into CustomerProfileBA1 using cash DevDeposit and expect the header status 200
#      | identifier           | customer_profile_id | purpose  | currency | transaction_rail |
#      | DevDepositIdentifier | BCPID1              | TRANSFER | SGD      | FAST             |
#
#    Then I wait until max time to verify bank account CustomerProfileBA1 with an increased balance of 1000 for customerProfileId BCPID1
#
#    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
#      | identifier | product_type | profile_type | product_class | currency   | country   | account_type | balance_policy_limit | balance_policy_type |
#      | ProductID2 | CASH_ACCOUNT | END_CUSTOMER | SHARIAH       | <currency> | <country> | SAVINGS      | 0                    | LENIENT             |
#
#    Then I approve the product ProductID2 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1
#
#    Given I create account for EndCustomerProfile with id ECPID1 for CustomerProfile BCPID1 with product id ProductID2 with bank account type as e-money with provider <bank_name> and expect the header status 200
#      | identifier | customer_profile_id | end_customer_profile_id | currency | country | in_trust  | on_behalf_of | metadata                           |
#      | BankAccId1 | BCPID1              | ECPID1                  | SGD      | SGP     | false     | CUSTOMER     | {"key": "TransactionIntegration1"} |
#
#    Then I wait until max time to verify the bank account BankAccId1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1
#
#    Then I verify for bank account BankAccId1 total balance is <initial_total_balance> and available balance is <initial_available_balance> for customerProfileId BCPID1
#
#    Given I create account for CustomerProfile with id BCPID1 with product id as ProductID1 with bank account type as Payments Account with provider <bank_name> and expect the header status 200
#      | identifier | customer_profile_id | currency | country | in_trust | is_overdraft_allowed | on_behalf_of | metadata                           |
#      | BankAccId2 | BCPID1              | SGD      | SGP     | false    | false                | CUSTOMER     | {"key": "TransactionIntegration1"} |
#
#    Then I wait until max time to verify the bank account BankAccId2 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1
#
#    Then I verify for bank account BankAccId2 total balance is <initial_total_balance> and available balance is <initial_available_balance> for customerProfileId BCPID1
#
#    When I add bank account BankAccId2 as beneficiary to bank account BankAccId1 of CustomerProfile BCPID1 for provider <bank_name> and expect status 200
#      | identifier     | beneficiary_name | address                                                                                                                                                                    | beneficiary_email     | is_hidden | metadata              | is_overdraft_allowed | overdraft_funding_account_id |
#      | BeneficiaryId1 | Beneficiary1     | {"address_line_1":"line1","address_line_2":"line2","address_line_3":"line3","address_line_4":"line4","city":"Tokyo","state":"Tokyo","country_code":"JP","local_code":"JP"} | beneficiary1@test.com | false     | {"key": "MyMetaData"} | true                 | CustomerProfileBA1           |
#
#    Then I wait until max time to verify beneficiary BeneficiaryId1 create status as BENEFICIARY_CREATED with provider <bank_name> for customerProfileId BCPID1
#
#    Then I verify bank account BankAccId1 has bank account BankAccId2 as beneficiary on provider <bank_name> with values for customerProfileId BCPID1
#      | identifier     | beneficiary_name | address                                                                                                                                                                    | beneficiary_email     | is_hidden | metadata              | is_overdraft_allowed |
#      | BeneficiaryId1 | Beneficiary1     | {"address_line_1":"line1","address_line_2":"line2","address_line_3":"line3","address_line_4":"line4","city":"Tokyo","state":"Tokyo","country_code":"JP","local_code":"JP"} | beneficiary1@test.com | false     | {"key": "MyMetaData"} | true                 |
#
#    Given I deposit an amount of <deposit_amount> into BankAccId1 using cash DevDeposit and expect the header status 200
#      | identifier           | customer_profile_id | purpose  | currency | transaction_rail |
#      | DevDepositIdentifier | BCPID1              | TRANSFER | SGD      | FAST             |
#
#    Then I wait until max time to verify bank account BankAccId1 with an increased balance of <deposit_amount> for customerProfileId BCPID1
#
#    Then I initiate pay beneficiary to transfer funds with below details and expect the header status <status_code> and TRANSACTION_PENDING
#      | identifier | customer_profile_id | account_id | beneficiary_id | amount | purpose          | transaction_rail | is_overdraft_allowed | overdraft_funding_account_id | metadata              | currency |
#      | TxId1      | BCPID1              | BankAccId1 | BeneficiaryId1 | 80     | Integration Test | FAST             | true                 | CustomerProfileBA1           | {"key": "MyMetaData"} | SGD      |
#
#    Then I wait until max time to verify bank account BankAccId2 with an available balance of <updated_available_balance-1> and total balance of <updated_total_balance-1> for customerProfileId BCPID1
#
#    Then I wait until max time to verify bank account BankAccId1 with an available balance of <updated_available_balance-2> and total balance of <updated_total_balance-2> for customerProfileId BCPID1
#
#    Examples:
#      | deposit_amount | initial_total_balance | initial_available_balance | updated_available_balance-1 | updated_total_balance-1 | updated_available_balance-2 | updated_total_balance-2 | bank_name    | status_code | country | currency |
#      | 70             | 0                     | 0                         | 80                          | 80                      | -10                         | -10                     | DBS Bank Ltd | 200         | SGP     | SGD      |
#
#  Scenario Outline: I call Pay Beneficiary with Invalid data and verify its failure
#
#    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
#      | identifier    | product_type   | profile_type | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type    |
#      | ProductID1    | CASH_ACCOUNT   | CUSTOMER     |  SHARIAH      | <currency> | <country> | SAVINGS      | 0                       | STRICT                 |
#
#    Then I approve the product ProductID1 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1
#
#    Given I create account for CustomerProfile with id BCPID1 with product id as ProductID1 with bank account type as <account_type> with provider <bank_name> and expect the header status 200
#      | identifier | customer_profile_id | currency | country | in_trust  | on_behalf_of | metadata                           |
#      | BankAccId1 | BCPID1              | SGD      | SGP     | false     | CUSTOMER     | {"key": "TransactionIntegration1"} |
#
#    Then I wait until max time to verify the bank account BankAccId1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1
#
#    Then I verify for bank account BankAccId1 total balance is <initial_total_balance> and available balance is <initial_available_balance> for customerProfileId BCPID1
#
#    When I add External Bank Account as beneficiary to bank account BankAccId1 of CustomerProfile BCPID1 for provider <bank_name> and expect status 200
#      | identifier     | beneficiary_name | address                                                                                                                                                                    | beneficiary_email     | is_hidden | metadata              | is_overdraft_allowed | beneficiary_account_details                                                                                                                         |
#      | BeneficiaryId1 | Beneficiary1     | {"address_line_1":"line1","address_line_2":"line2","address_line_3":"line3","address_line_4":"line4","city":"Tokyo","state":"Tokyo","country_code":"JP","local_code":"JP"} | beneficiary1@test.com | false     | {"key": "MyMetaData"} | false                | {"bank_name":"SBI","currency":"SGD","country":"SGP","code_details":{"sg_code_details":{"swift_bic":"DBSSSGSGXXX", "account_number": "1123344455"}}} |
#
#    Then I wait until max time to verify beneficiary BeneficiaryId1 create status as BENEFICIARY_CREATED with provider <bank_name> for customerProfileId BCPID1
#
#    Then I verify hugoserve bank account BankAccId1 has bank account External Bank Account as beneficiary with provider <bank_name> with values for customerProfileId BCPID1
#      | identifier     | beneficiary_name | address                                                                                                                                                                    | beneficiary_email     | is_hidden | metadata              | is_overdraft_allowed | beneficiary_account_details                                                                                                                         |
#      | BeneficiaryId1 | Beneficiary1     | {"address_line_1":"line1","address_line_2":"line2","address_line_3":"line3","address_line_4":"line4","city":"Tokyo","state":"Tokyo","country_code":"JP","local_code":"JP"} | beneficiary1@test.com | false     | {"key": "MyMetaData"} | false                | {"bank_name":"SBI","currency":"SGD","country":"SGP","code_details":{"sg_code_details":{"swift_bic":"DBSSSGSGXXX", "account_number": "1123344455"}}} |
#
#    Given I deposit an amount of <deposit_amount> into BankAccId1 using cash DevDeposit and expect the header status 200
#      | identifier           | customer_profile_id | purpose  | currency | transaction_rail |
#      | DevDepositIdentifier | BCPID1              | TRANSFER | SGD      | FAST             |
#
#    Then I wait until max time to verify bank account BankAccId1 with an increased balance of <deposit_amount> for customerProfileId BCPID1
#
#    Then I initiate pay beneficiary to transfer funds with below details and expect the header status <status_code> and <message>
#      | identifier | customer_profile_id | account_id | beneficiary_id | amount   | purpose          | transaction_rail | is_overdraft_allowed | overdraft_funding_account_id | metadata              | currency |
#      | TxId1      | BCPID1              | BankAccId1 | BeneficiaryId1 | <amount> | Integration Test | FAST             | false                |                              | {"key": "MyMetaData"} | SGD      |
#
#    Examples:
#      | amount | bank_name    | account_type     | initial_total_balance | initial_available_balance | status_code | deposit_amount | country | currency |
#      | -1     | DBS Bank Ltd | Payments Account | 0                     | 0                         | E9400       | 100            | SGP     | SGD      |
#
#  Scenario Outline: I call Pay Beneficiary with amount having decimal digits more than permitted and verify its failure
#    Given I create a product with customer profile BCPID1 provider as <bank_name> and expect product_status PRODUCT_DRAFT
#      | identifier    | product_type   | profile_type | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type    |
#      | ProductID1    | CASH_ACCOUNT   | CUSTOMER     |  SHARIAH      | <currency> | <country> | SAVINGS      | 0                       | STRICT                 |
#
#    Then I approve the product ProductID1 and verify status as PRODUCT_SUCCESS with provider <bank_name> for customerProfileId BCPID1
#
#    Given I create account for CustomerProfile with id BCPID1 with product id as ProductID1 with bank account type as <account_type> with provider <bank_name> and expect the header status 200
#      | identifier | customer_profile_id | currency | country | in_trust  | on_behalf_of | metadata                           |
#      | BankAccId1 | BCPID1              | SGD      | SGP     | false     | CUSTOMER     | {"key": "TransactionIntegration1"} |
#
#    Then I wait until max time to verify the bank account BankAccId1 status as ACCOUNT_CREATED with provider <bank_name> for customerProfileId BCPID1
#
#    Then I verify for bank account BankAccId1 total balance is <initial_total_balance> and available balance is <initial_available_balance> for customerProfileId BCPID1
#
#    When I add External Bank Account as beneficiary to bank account BankAccId1 of CustomerProfile BCPID1 for provider <bank_name> and expect status 200
#      | identifier     | beneficiary_name | address                                                                                                                                                                    | beneficiary_email     | is_hidden | metadata              | is_overdraft_allowed | beneficiary_account_details                                                                                                                         |
#      | BeneficiaryId1 | Beneficiary1     | {"address_line_1":"line1","address_line_2":"line2","address_line_3":"line3","address_line_4":"line4","city":"Tokyo","state":"Tokyo","country_code":"JP","local_code":"JP"} | beneficiary1@test.com | false     | {"key": "MyMetaData"} | false                | {"bank_name":"SBI","currency":"SGD","country":"SGP","code_details":{"sg_code_details":{"swift_bic":"DBSSSGSGXXX", "account_number": "1123344455"}}} |
#
#    Then I wait until max time to verify beneficiary BeneficiaryId1 create status as BENEFICIARY_CREATED with provider <bank_name> for customerProfileId BCPID1
#
#    Then I verify hugoserve bank account BankAccId1 has bank account External Bank Account as beneficiary with provider <bank_name> with values for customerProfileId BCPID1
#      | identifier     | beneficiary_name | address                                                                                                                                                                    | beneficiary_email     | is_hidden | metadata              | is_overdraft_allowed | beneficiary_account_details                                                                                                                         |
#      | BeneficiaryId1 | Beneficiary1     | {"address_line_1":"line1","address_line_2":"line2","address_line_3":"line3","address_line_4":"line4","city":"Tokyo","state":"Tokyo","country_code":"JP","local_code":"JP"} | beneficiary1@test.com | false     | {"key": "MyMetaData"} | false                | {"bank_name":"SBI","currency":"SGD","country":"SGP","code_details":{"sg_code_details":{"swift_bic":"DBSSSGSGXXX", "account_number": "1123344455"}}} |
#
#    Given I deposit an amount of <deposit_amount> into BankAccId1 using cash DevDeposit and expect the header status 200
#      | identifier           | customer_profile_id | purpose  | currency | transaction_rail |
#      | DevDepositIdentifier | BCPID1              | TRANSFER | SGD      | FAST             |
#
#    Then I wait until max time to verify bank account BankAccId1 with an increased balance of <deposit_amount> for customerProfileId BCPID1
#
#    Then I initiate pay beneficiary to transfer funds with below details and expect the header status <status_code> and <message>
#      | identifier | customer_profile_id | account_id | beneficiary_id | amount   | purpose          | transaction_rail | is_overdraft_allowed | overdraft_funding_account_id | metadata              | currency |
#      | TxId1      | BCPID1              | BankAccId1 | BeneficiaryId1 | <amount> | Integration Test | FAST             | false                |                              | {"key": "MyMetaData"} | SGD      |
#
#    Examples:
#      | amount   | bank_name    | account_type     | initial_total_balance | initial_available_balance | status_code | deposit_amount | country | currency |
#      | 100.2354 | DBS Bank Ltd | Payments Account | 0                     | 0                         | E9400       | 100            | SGP     | SGD      |
#
