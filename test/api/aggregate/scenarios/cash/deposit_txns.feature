Feature: Banking Service DBS Bank Ltd SG ICN and IDN deposits.

  Background: Setup customerProfile and EndCustomerProfile and add Accounts.

     #CustomerProfile verifying and Onboarding on to banking service on given providers
    Given I set and verify customer BCID1, customer profile BCPID1 on cash service on below providers and expect status 200 in the context
      | provider_name |
      | DBS Bank Ltd           |

    Then I wait until max time to verify CustomerProfile BCPID1 onboard status as ONBOARD_SUCCESS

    Then I create below End-Customer-Profile
      | customer_identifier | customer_profile_identifier | end_customer_profile_identifier | first_name | last_name | region | email   | phone_number |
      | BCID1               | BCPID1                      | ECPID1                          | banking    | service   | SG     | x@y.com | 00000000     |

    Then I verify End-Customer-Profile exist with values
      | customer_profile_identifier | end_customer_profile_identifier | customer_profile_id   | first_name | last_name | email   | phone_number | status |
      | BCPID1                      | ECPID1                          | <customer_profile_id> | banking    | service   | x@y.com | 00000000     | ACTIVE |

    Then I wait until max time to verify CustomerProfile BCPID1 onboard status as ONBOARD_SUCCESS

    # EndCustomerProfile Onboarding
    Given I onboard EndCustomerProfile ECPID1 of CustomerProfile BCPID1 on cash service on below providers and expect status 200
      | provider_name |
      | DBS Bank Ltd           |

    Then I wait until max time to verify EndCustomerProfile ECPID1 of CustomerProfile BCPID1 onboard status as ONBOARD_SUCCESS

    Given I create a product with customer profile BCPID1 provider as DBS Bank Ltd and expect product_status PRODUCT_DRAFT
      | identifier    | product_type   | profile_type | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type |
      | ProductID1    | WALLET         | END_CUSTOMER |  SHARIAH      | SGD        | SGP       | SAVINGS      | 0                       | STRICT              |

    Then I approve the product ProductID1 and verify status as PRODUCT_SUCCESS with provider DBS Bank Ltd for customerProfileId BCPID1

    Given I create account for EndCustomerProfile with id ECPID1 for CustomerProfile BCPID1 with product id ProductID1 with bank account type as PPA with provider DBS Bank Ltd and expect the header status 200
      | identifier | customer_profile_id | end_customer_profile_id | currency | country | in_trust | is_overdraft_allowed | on_behalf_of | metadata                            |
      | BankAccId  | IntegrationTest1    | IntegrationEndCustomer  | SGD      | SGP     | false    | false                | CUSTOMER     | {"keyref":"M030126179534319754275"} |

    Then I wait until max time to verify the bank account BankAccId status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId BCPID1

  Scenario Outline: Deposit the account using ICN for customerProfileId BCPID1 and verify the increase in account balance
    Given I deposit an amount of <amount> into BankAccId using cash DevDeposit and expect the header status 200
      | identifier           | customer_profile_id             | purpose  | currency | transaction_rail |
      | DevDepositIdentifier | BCPID1                          | TRANSFER | SGD      | FAST             |
    Then I wait until max time to verify bank account BankAccId with an increased balance of <amount> for customerProfileId BCPID1
    Examples:
      | amount |
      | 100    |

  Scenario Outline: Deposit the account using IDN and verify the increase in account balance
    Given I deposit an amount of <amount> into BankAccId using cash DevDeposit and expect the header status 200
      | identifier           | customer_profile_id             | purpose  | currency | transaction_rail |
      | DevDepositIdentifier | BCPID1                          | TRANSFER | SGD      | FAST             |

    Then I wait until max time to verify bank account BankAccId with an increased balance of <amount> for customerProfileId BCPID1
    Examples:
      | amount |
      | 100    |

  Scenario Outline: Deposit the account with decimal digits more than the permitted, and it gives error status.
    Given I deposit an amount of <amount> into BankAccId using cash DevDeposit and expect the header status E9400
      | identifier           | customer_profile_id             | purpose  | currency | transaction_rail |
      | DevDepositIdentifier | BCPID1                          | TRANSFER | SGD      | FAST             |

    Examples:
      | amount   |
      | 100.2345 |
