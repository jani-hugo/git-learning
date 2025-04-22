Feature: Card Service requests to Cash Service scenarios

  # Note:
  # All these below scenarios should pass successfully for the next scenario to be successfully pass, as they are dependant on each other since all end customers have same card_cust_float_refund_account.
  # And also due to that same dependency they will all run successfully only once per customer profiule.

  Background: Customer-Profile
    Given I set and verify customer BCID1, customer profile BCPID1 in the context

    Given I set and verify customer BCID1, customer profile BCPID1 on cash service on below providers and expect status 200 in the context
      | provider_name |
      | DBS Bank Ltd  |

    Then I wait until max time to verify CustomerProfile BCPID1 onboard status as ONBOARD_SUCCESS

    Given I initialise card for Customer Profile BCPID1 and expect request status code as 200 and status as SUCCESS

    Then I setup card float account FloatAccID for Customer Profile BCPID1 and expect request status code as 200 and status as SUCCESS

    Then I create below End-Customer-Profile
      | customer_identifier | customer_profile_identifier | end_customer_profile_identifier | first_name  | last_name | region | email   | phone_number |
      | BCID1               | BCPID1                      | ECPID1                          | Integration | Test      | SG     | x@y.com | 123456       |

    Then I verify End-Customer-Profile exist with values
      | customer_profile_identifier | end_customer_profile_identifier | customer_profile_id | first_name  | last_name | email   | phone_number | status |
      | BCPID1                      | ECPID1                          | BCPID1              | Integration | Test      | x@y.com | 123456       | ACTIVE |

    Given I onboard EndCustomerProfile ECPID1 of CustomerProfile BCPID1 on cash service on below providers and expect status 200
      | provider_name |
      | DBS Bank Ltd  |

    Then I wait until max time to verify EndCustomerProfile ECPID1 of CustomerProfile BCPID1 onboard status as ONBOARD_SUCCESS

    Then I onboard EndCustomerProfile ECPID1 of CustomerProfile BCPID1 on card service and expect request status as 200 and onboard_status as ONBOARD_SUCCESS

    Given I create a cash account product with customer profile BCPID1 provider as DBS Bank Ltd and expect product_status PRODUCT_DRAFT
      | identifier       | product_type | profile_type | product_class | num_of_active_account |
      | CashAccProductId | CASH_ACCOUNT | END_CUSTOMER | SHARIAH       | 1                     |

    Then I approve the product CashAccProductId and verify status as PRODUCT_SUCCESS with provider DBS Bank Ltd for customerProfileId BCPID1

    Given I create a product with customer profile BCPID1 provider as DBS Bank Ltd and expect product_status PRODUCT_DRAFT
      | identifier          | product_type | profile_type | product_class | currency | country | account_type | balance_policy_limit | balance_policy_type |
      | CashWalletProductId | WALLET       | END_CUSTOMER | SHARIAH       | SGD      | SGP     | SAVINGS      | 0                    | LENIENT             |

    Then I approve the product CashWalletProductId and verify status as PRODUCT_SUCCESS with provider DBS Bank Ltd for customerProfileId BCPID1

    Then I create a end customer cash account with id CashAccId customerProfileID BCPID1 with product id CashAccProductId and endCustomerProfileId ECPID1 and expect status as CASH_ACCOUNT_CREATED

    Given I create account for EndCustomerProfile with id ECPID1 for CustomerProfile BCPID1 with product id CashWalletProductId with bank account type as e-money with provider DBS Bank Ltd and expect the header status 200
      | identifier   | customer_profile_id | end_customer_profile_id          | currency | country | in_trust | on_behalf_of | metadata                           | cash_account_id |
      | CashWalletId | BCPID1              | 36974646-3489-47aa-b6c2-w232d543 | SGD      | SGP     | false    | CUSTOMER     | {"key": "TransactionIntegration1"} | CashAccId       |

    Then I wait until max time to verify the bank account CashWalletId status as ACCOUNT_CREATED with provider DBS Bank Ltd for customerProfileId BCPID1

  Scenario: Card Pay Transaction with amount < balance so no overdraft required

    Given I deposit an amount of 1000 into CashWalletId using cash DevDeposit and expect the header status 200
      | identifier           | customer_profile_id | purpose  | currency | transaction_rail |
      | DevDepositIdentifier | BCPID1              | TRANSFER | SGD      | FAST             |

    Then I wait until max time to verify bank account CashWalletId with an increased balance of 1000 for customerProfileId BCPID1

    Then I attach a card onto the cash wallet CashWalletId and CustomerProfileId BCPID1 and expect request status 200 and attach status SUCCESS

    Then I initiate a Card Pay Transaction TX1 on cash wallet CashWalletId and CustomerProfileId BCPID1 and expect request status 200 and txn status PAY_PENDING
      | currency | purpose          | amount | push_overdraft |
      | SGD      | Integration Test | 100    | true           |

    Then I wait until max time to verify the Card transaction TX1 status as TRANSACTION_SETTLED for customerProfileId BCPID1

    Then I wait until max time to verify bank account CashWalletId with an available balance of 900 and total balance of 900 for customerProfileId BCPID1

  Scenario: Card Pay Transaction with amount > balance and overdraft required

    Given I deposit an amount of 50 into cash account FloatAccID and expect the header status 200
      | identifier           | customer_profile_id | purpose  | currency | transaction_rail |
      | DevDepositIdentifier | BCPID1              | TRANSFER | SGD      | FAST             |

    Then I wait until max time to verify cash account FloatAccID with an available balance of 50 and total balance of 50 for customerProfileId BCPID1

    Given I deposit an amount of 100 into CashWalletId using cash DevDeposit and expect the header status 200
      | identifier           | customer_profile_id | purpose  | currency | transaction_rail |
      | DevDepositIdentifier | BCPID1              | TRANSFER | SGD      | FAST             |

    Then I wait until max time to verify bank account CashWalletId with an increased balance of 100 for customerProfileId BCPID1

    Then I attach a card onto the cash wallet CashWalletId and CustomerProfileId BCPID1 and expect request status 200 and attach status SUCCESS

    Then I initiate a Card Pay Transaction TX1 on cash wallet CashWalletId and CustomerProfileId BCPID1 and expect request status 200 and txn status PAY_PENDING
      | currency | purpose          | amount | push_overdraft |
      | SGD      | Integration Test | 150    | true           |

    Then I wait until max time to verify the Card transaction TX1 status as TRANSACTION_SETTLED for customerProfileId BCPID1

    Then I wait until max time to verify bank account CashWalletId with an available balance of -50 and total balance of -50 for customerProfileId BCPID1

    Then I wait until max time to verify cash account FloatAccID with an available balance of 0 and total balance of 0 for customerProfileId BCPID1

  Scenario: Apply Fees on Card with amount = balance and no overdraft required

    Given I deposit an amount of 50 into CashWalletId using cash DevDeposit and expect the header status 200
      | identifier           | customer_profile_id | purpose  | currency | transaction_rail |
      | DevDepositIdentifier | BCPID1              | TRANSFER | SGD      | FAST             |

    Then I wait until max time to verify bank account CashWalletId with an increased balance of 50 for customerProfileId BCPID1

    Then I attach a card onto the cash wallet CashWalletId and CustomerProfileId BCPID1 and expect request status 200 and attach status SUCCESS

    Then I initiate a Apply Fee on Card Transaction TX1 on cash wallet CashWalletId and CustomerProfileId BCPID1 and expect request status 200 and txn status APPLY_FEE_PENDING
      | currency | amount | push_overdraft |
      | SGD      | 50    | true           |

    Then I wait until max time to verify the Card transaction TX1 status as TRANSACTION_SETTLED for customerProfileId BCPID1

    Then I wait until max time to verify bank account CashWalletId with an available balance of 0 and total balance of 0 for customerProfileId BCPID1

    Then I wait until max time to verify cash account FloatAccID with an available balance of 50 and total balance of 50 for customerProfileId BCPID1

  Scenario: Apply Fees on Card with amount > balance and overdraft required

    Given I deposit an amount of 50 into CashWalletId using cash DevDeposit and expect the header status 200
      | identifier           | customer_profile_id | purpose  | currency | transaction_rail |
      | DevDepositIdentifier | BCPID1              | TRANSFER | SGD      | FAST             |

    Then I wait until max time to verify bank account CashWalletId with an increased balance of 50 for customerProfileId BCPID1

    Then I attach a card onto the cash wallet CashWalletId and CustomerProfileId BCPID1 and expect request status 200 and attach status SUCCESS

    Then I initiate a Apply Fee on Card Transaction TX1 on cash wallet CashWalletId and CustomerProfileId BCPID1 and expect request status 200 and txn status APPLY_FEE_PENDING
      | currency | amount | push_overdraft |
      | SGD      | 100    | true           |

    Then I wait until max time to verify the Card transaction TX1 status as TRANSACTION_SETTLED for customerProfileId BCPID1

    Then I wait until max time to verify bank account CashWalletId with an available balance of -50 and total balance of -50 for customerProfileId BCPID1

    Then I wait until max time to verify cash account FloatAccID with an available balance of 100 and total balance of 100 for customerProfileId BCPID1

  Scenario: Apply Tax on Card with amount < balance and no overdraft required

    Given I deposit an amount of 50 into CashWalletId using cash DevDeposit and expect the header status 200
      | identifier           | customer_profile_id | purpose  | currency | transaction_rail |
      | DevDepositIdentifier | BCPID1              | TRANSFER | SGD      | FAST             |

    Then I wait until max time to verify bank account CashWalletId with an increased balance of 50 for customerProfileId BCPID1

    Then I attach a card onto the cash wallet CashWalletId and CustomerProfileId BCPID1 and expect request status 200 and attach status SUCCESS

    Then I initiate a Apply Tax on Card Transaction TX1 on cash wallet CashWalletId and CustomerProfileId BCPID1 and expect request status 200 and txn status APPLY_TAX_PENDING
      | currency | amount | push_overdraft |
      | SGD      | 50    | true           |

    Then I wait until max time to verify the Card transaction TX1 status as TRANSACTION_SETTLED for customerProfileId BCPID1

    Then I wait until max time to verify bank account CashWalletId with an available balance of 0 and total balance of 0 for customerProfileId BCPID1

    Then I wait until max time to verify cash account FloatAccID with an available balance of 150 and total balance of 150 for customerProfileId BCPID1

  Scenario: Apply Tax on Card with amount > balance and overdraft required

    Given I deposit an amount of 50 into CashWalletId using cash DevDeposit and expect the header status 200
      | identifier           | customer_profile_id | purpose  | currency | transaction_rail |
      | DevDepositIdentifier | BCPID1              | TRANSFER | SGD      | FAST             |

    Then I wait until max time to verify bank account CashWalletId with an increased balance of 50 for customerProfileId BCPID1

    Then I attach a card onto the cash wallet CashWalletId and CustomerProfileId BCPID1 and expect request status 200 and attach status SUCCESS

    Then I initiate a Apply Tax on Card Transaction TX1 on cash wallet CashWalletId and CustomerProfileId BCPID1 and expect request status 200 and txn status APPLY_TAX_PENDING
      | currency | amount | push_overdraft |
      | SGD      | 100    | true           |

    Then I wait until max time to verify the Card transaction TX1 status as TRANSACTION_SETTLED for customerProfileId BCPID1

    Then I wait until max time to verify bank account CashWalletId with an available balance of -50 and total balance of -50 for customerProfileId BCPID1

    Then I wait until max time to verify cash account FloatAccID with an available balance of 200 and total balance of 200 for customerProfileId BCPID1

  Scenario: Apply Yield on Card

    Then I attach a card onto the cash wallet CashWalletId and CustomerProfileId BCPID1 and expect request status 200 and attach status SUCCESS

    Then I initiate a Apply Yield on Card Transaction TX1 on cash wallet CashWalletId and CustomerProfileId BCPID1 and expect request status 200 and txn status APPLY_YIELD_PENDING
      | currency | amount | push_overdraft |
      | SGD      | 50    | true           |

    Then I wait until max time to verify the Card transaction TX1 status as TRANSACTION_SETTLED for customerProfileId BCPID1

    Then I wait until max time to verify bank account CashWalletId with an available balance of 50 and total balance of 50 for customerProfileId BCPID1

    Then I wait until max time to verify cash account FloatAccID with an available balance of 150 and total balance of 150 for customerProfileId BCPID1
