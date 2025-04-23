Feature: Investment service scenarios for transaction service

  Background: Setup customer and end-customer profile on Account and Bank Service
    Given I set and verify customer Cid1, customer profile CPid1 in the context
    Then I create below End-Customer-Profile
      | customer_identifier | customer_profile_identifier | end_customer_profile_identifier | first_name | last_name | region | email   | phone_number |
      | Cid1               | CPid1                        | EPid1                           | cash       | service   | SG     | x@y.com | 00000000     |

    Then I verify End-Customer-Profile exist with values
      | customer_profile_identifier | end_customer_profile_identifier | customer_profile_id   | first_name | last_name | email   | phone_number | status |
      | EPid1                       | EPid1                           | <customer_profile_id> | cash       | service   | x@y.com | 00000000     | ACTIVE |

  Scenario Outline: Initiate transaction with rate and verify success
    Given I onboard Customer Profile on investment service
      | identifier | customer_id | customer_profile_id   | provider_id      |
      | CPid1      |             | <customer_profile_id> | [SILVER_BULLION] |
      | CPid1      |             | <customer_profile_id> | [GTN] |
    Then I wait until max time to verify Investment Customer-Profile <customer_profile_id> onboard status as <status>

    Given I deposit an amount of <amount> in Customer-Profile <customer_profile_id>

    Given I onboard End Customer-Profile of Customer-Profile CPid1 on Investment Service
      | end_customer_identifier | end_customer_profile_id | provider_id      |
      | EPid1                   | EPid1                   | [SILVER_BULLION] |
#      | EPid1                   | EPid1                   | [GTN]            |

    Then I wait until max time to verify Investment End Customer-Profile EPid1 of Customer-Profile CPid1 onboard status as <status>

    Given I create a product with customer profile <customer_profile_id>
      | identifier    | product_type           | profile_type | product_class | allocation   | allocation_strategy   | re_balance_strategy        | provider_id |
      | ProductID1    | INVESTMENT_PORTFOLIO   | CUSTOMER     |  SHARIAH      | <allocation> | <allocation_strategy> | <re_balance_strategy>      | <provider>  |

    Given I create Portfolio for End Customer-Profile EPid1 of Customer-Profile <customer_profile_id>
      | portfolio_identifier | product_id  |
      | Pid1                 | ProductID1  |
      | Pid2                 | ProductID1  |

    Then I wait until max time for Portfolio creation of Customer-Profile CPid1 and verify Portfolio status
      | portfolio_identifier | portfolio_id | status  |
      | Pid1                 | Pid1         | SUCCESS |
      | Pid2                 | Pid2         | SUCCESS |
#      | Pid3                 | Pid3         | SUCCESS |

    Given I process below transaction INVEST for Customer-Profile <customer_profile_id> and expect header status of <status_code>
      | transaction_identifier | portfolio_id | total_amount                | transaction_type | quantity | rate               | is_rate_included |
      | Tid1                   | Pid1         | <invest_transaction_amount> | INVEST           | 2        | {"asset_rates":[]} | true             |
      | Tid2                   | Pid2         | <invest_transaction_amount> | INVEST           | 1        | {"asset_rates":[]} | true             |

    Then I wait until max time to verify transaction status of Tid1 of Customer-Profile <customer_profile_id>  as <transaction_status>
    Then I wait until max time to verify transaction status of Tid2 of Customer-Profile <customer_profile_id>  as TRANSACTION_STATUS_SETTLED

    Given I process below transaction WITHDRAW for Customer-Profile <customer_profile_id> and expect header status of <status_code>
      | transaction_identifier | portfolio_id | total_amount                  | transaction_type | quantity | rate               | is_rate_included |
      | Tid3                   | Pid1         | <withdraw_transaction_amount> | WITHDRAW         | 1        | {"asset_rates":[]} | true             |
#      | Tid4                   | Pid3         | <withdraw_transaction_amount> | WITHDRAW         | 1        | {"asset_rates":[]} | true             |
    Then I wait until max time to verify withdraw transaction status of Tid3 of Customer-Profile <customer_profile_id> as <transaction_status>
#    Then I wait until max time to verify withdraw transaction status of Tid4 of Customer-Profile <customer_profile_id> as <transaction_status>

    Then I request to get transaction details of Tid1 of Customer-Profile <customer_profile_id> and expect header status of <status_code> and below details

#    Given I request to get Transactions For Customer-Profile CPid1 and expect header as <status_code>
    Given I request to get Transactions for below Portfolios and expect header as <status_code>
      | portfolio_identifier | customer_profile_identifier |
      | Pid1                 | CPid1                       |
    Given I request to get transaction details of End Customer-Profile EPid1 and expect header as <status_code>
      | portfolio_identifier | customer_profile_identifier |
      | Pid1                 | CPid1                       |

    Examples:
      | customer_profile_id | status          | amount | invest_transaction_amount | transaction_status         | status_code | withdraw_transaction_amount | customer_profile_id | status          | allocation_strategy | re_balance_strategy | provider        | allocation |
      | CPid1               | ONBOARD_SUCCESS | 200    | 50                        | TRANSACTION_STATUS_SETTLED | 200         | 45                          | CPid1               | ONBOARD_SUCCESS | YEARLY              | YEARLY              | SILVER-BULLION  | [{"assets":[{"asset_symbol":"XAU","percentage":100,"provider_id":"SILVER_BULLION"}]}] |
      | CPid1               | ONBOARD_SUCCESS | 300    | 20.22                     | TRANSACTION_STATUS_SETTLED | 200         | 3.32                        | CPid1               | ONBOARD_SUCCESS | YEARLY              | YEARLY              | SILVER-BULLION  | [{"assets":[{"asset_symbol":"XAU","percentage":100,"provider_id":"SILVER_BULLION"}]}] |
      | CPid1               | ONBOARD_SUCCESS | 70     | 5.91                      | TRANSACTION_STATUS_SETTLED | 200         | 3.29                        | CPid1               | ONBOARD_SUCCESS | YEARLY              | YEARLY              | SILVER-BULLION  | [{"assets":[{"asset_symbol":"XAU","percentage":100,"provider_id":"SILVER_BULLION"}]}] |


  Scenario Outline: Initiate INVEST transaction with invalid amount and verify ISM_9302
    Given I onboard Customer Profile on investment service
      | identifier | customer_id | customer_profile_id   | provider_id      |
      | CPid1      |             | <customer_profile_id> | [SILVER_BULLION] |
#      | CPid1      |             | <customer_profile_id> | [GTN] |
    Then I wait until max time to verify Investment Customer-Profile <customer_profile_id> onboard status as <status>

    Given I deposit an amount of <amount> in Customer-Profile <customer_profile_id>

    Given I onboard End Customer-Profile of Customer-Profile CPid1 on Investment Service
      | end_customer_identifier | end_customer_profile_id | provider_id      |
      | EPid1                   | EPid1                   | [SILVER_BULLION] |
#      | EPid1                   | EPid1                   | [GTN]            |
    Then I wait until max time to verify Investment End Customer-Profile EPid1 of Customer-Profile CPid1 onboard status as <status>

    Given I create a product with customer profile <customer_profile_id>
      | identifier    | product_type           | profile_type | product_class | allocation   | allocation_strategy   | re_balance_strategy        | provider_id |
      | ProductID1    | INVESTMENT_PORTFOLIO   | CUSTOMER     |  SHARIAH      | <allocation> | <allocation_strategy> | <re_balance_strategy>      | <provider>  |

    Given I create Portfolio for End Customer-Profile EPid1 of Customer-Profile <customer_profile_id>
      | portfolio_identifier | product_id  |
      | Pid1                 | ProductID1  |

    Then I wait until max time for Portfolio creation of Customer-Profile CPid1 and verify Portfolio status
      | portfolio_identifier | portfolio_id | status  |
      | Pid1                 | Pid1         | SUCCESS |

    Given I process below transaction <transaction_type> for Customer-Profile <customer_profile_id> with invalid amount and expect status of <transaction_status>
      | transaction_identifier | portfolio_id | total_amount | transaction_type | quantity |
      | Tid1                   | Pid1         | 0            | INVEST           | 1        |
      | Tid2                   | Pid1         | -500         | INVEST           | 1        |
      | Tid3                   | Pid1         | 0            | WITHDRAW         | 1        |
      | Tid4                   | Pid1         | -289         | WITHDRAW         | 1        |
    Examples:
      | identifier | customer_profile_id | status          | amount | transaction_type | transaction_status | status          | allocation_strategy | re_balance_strategy | provider        | allocation |
      | CPid1      | CPid1               | ONBOARD_SUCCESS | 500    | INVEST           | ISM_9302           | ONBOARD_SUCCESS | YEARLY              | YEARLY              | SILVER-BULLION  | [{"assets":[{"asset_symbol":"XAU","percentage":100,"provider_id":"SILVER_BULLION"}]}] |

  Scenario Outline: Initiate INVEST transaction for portfolio with insufficient balance and verify failure
    Given I onboard Customer Profile on investment service
      | identifier | customer_id | customer_profile_id   | provider_id      |
      | CPid1      |             | <customer_profile_id> | [SILVER_BULLION] |
#      | CPid1      |             | <customer_profile_id> | [GTN] |
    Then I wait until max time to verify Investment Customer-Profile <customer_profile_id> onboard status as <status>

    Given I deposit an amount of <amount> in Customer-Profile <customer_profile_id>

    Given I onboard End Customer-Profile of Customer-Profile CPid1 on Investment Service
      | end_customer_identifier | end_customer_profile_id | provider_id      |
      | EPid1                   | EPid1                   | [SILVER_BULLION] |
#      | EPid1                   | EPid1                   | [GTN]            |
    Then I wait until max time to verify Investment End Customer-Profile EPid1 of Customer-Profile CPid1 onboard status as <status>

    Given I create a product with customer profile <customer_profile_id>
      | identifier    | product_type           | profile_type | product_class | allocation   | allocation_strategy   | re_balance_strategy        | provider_id |
      | ProductID1    | INVESTMENT_PORTFOLIO   | CUSTOMER     |  SHARIAH      | <allocation> | <allocation_strategy> | <re_balance_strategy>      | <provider>  |

    Given I create Portfolio for End Customer-Profile EPid1 of Customer-Profile <customer_profile_id>
      | portfolio_identifier | product_id  |
      | Pid1                 | ProductID1  |

    Then I wait until max time for Portfolio creation of Customer-Profile CPid1 and verify Portfolio status
      | portfolio_identifier | portfolio_id | status  |
      | Pid1                 | Pid1         | SUCCESS |

    Given I process below transaction for Customer-Profile <customer_profile_id> with insufficient balance and verify <transaction_status>
      | transaction_identifier | portfolio_id | total_amount | transaction_type   | quantity | is_rate_included |
      | Tid1                   | Pid1         | 50000000      | <transaction_type> | 1        | true             |
      | Tid2                   | Pid1         | 100000           | WITHDRAW           | 1        | true             |

    Examples:
      | identifier | customer_profile_id | status          | amount | transaction_amount | transaction_type | transaction_status        |  allocation_strategy | re_balance_strategy | provider        | allocation |
      | CPid1      | CPid1               | ONBOARD_SUCCESS | 10     | 500                | INVEST           | TRANSACTION_STATUS_FAILED |  YEARLY              | YEARLY              | SILVER-BULLION  | [{"assets":[{"asset_symbol":"XAU","percentage":100,"provider_id":"SILVER_BULLION"}]}] |


  Scenario Outline: Initiate INVEST transaction for portfolio with invalid customer-profile-id and verify failure ISM_9402
    Given I onboard Customer Profile on investment service
      | identifier | customer_id | customer_profile_id   | provider_id      |
      | CPid1      |             | <customer_profile_id> | [SILVER_BULLION] |
#      | CPid1      |             | <customer_profile_id> | [GTN] |
    Then I wait until max time to verify Investment Customer-Profile <customer_profile_id> onboard status as <status>

    Given I deposit an amount of <amount> in Customer-Profile <customer_profile_id>

    Given I onboard End Customer-Profile of Customer-Profile CPid1 on Investment Service
      | end_customer_identifier | end_customer_profile_id | provider_id      |
      | EPid1                   | EPid1                   | [SILVER_BULLION] |
#      | EPid1                   | EPid1                   | [GTN]            |
    Then I wait until max time to verify Investment End Customer-Profile EPid1 of Customer-Profile CPid1 onboard status as <status>

    Given I create a product with customer profile <customer_profile_id>
      | identifier    | product_type           | profile_type | product_class | allocation   | allocation_strategy   | re_balance_strategy        | provider_id |
      | ProductID1    | INVESTMENT_PORTFOLIO   | CUSTOMER     |  SHARIAH      | <allocation> | <allocation_strategy> | <re_balance_strategy>      | <provider>  |

    Given I create Portfolio for End Customer-Profile EPid1 of Customer-Profile <customer_profile_id>
      | portfolio_identifier | product_id  |
      | Pid1                 | ProductID1  |

    Then I wait until max time for Portfolio creation of Customer-Profile CPid1 and verify Portfolio status
      | portfolio_identifier | portfolio_id | status  |
      | Pid1                 | Pid1         | SUCCESS |
#      | Pid2                 | Pid2         | SUCCESS |
#      | Pid3                 | Pid3         | SUCCESS |

    Given I process below transaction for incorrect Customer-Profile <customer_profile_id> and verify header status as <transaction_status>
      | transaction_identifier | portfolio_id | total_amount         | transaction_type | quantity | is_rate_included |
      | Tid1                   | Pid1         | <transaction_amount> | INVEST           | 1        | false            |
      | Tid2                   | Pid1         | <transaction_amount> | WITHDRAW         | 1        | false            |
#      | Tid3                   | Pid3         | <transaction_amount> | INVEST           | 1        | false            |
#      | Tid4                   | Pid3         | <transaction_amount> | WITHDRAW         | 1        | false            |

    Given I process below transaction <transaction_type> for invalid Customer-Profile <customer_profile_id> and verify header status as <transaction_status>
      | transaction_identifier | portfolio_id | total_amount         | transaction_type | quantity | is_rate_included |
      | Tid5                   | Pid1         | <transaction_amount> | INVEST           | 1        | true             |
      | Tid6                   | Pid1         | <transaction_amount> | WITHDRAW         | 1        | false            |
#      | Tid7                   | Pid3         | <transaction_amount> | INVEST           | 1        | true             |
#      | Tid8                   | Pid3         | <transaction_amount> | WITHDRAW         | 1        | true             |


    Examples:
      | identifier | customer_profile_id | status          | amount | transaction_amount | transaction_type | transaction_status | allocation_strategy | re_balance_strategy | provider        | allocation |
      | CPid1      | CPid1               | ONBOARD_SUCCESS | 100    | 50                 | INVEST           | ISM_9101           | YEARLY              | YEARLY              | SILVER-BULLION  | [{"assets":[{"asset_symbol":"XAU","percentage":100,"provider_id":"SILVER_BULLION"}]}] |


  Scenario Outline: Initiate INVEST transaction for portfolio with incorrect and invalid portfolio-id and verify failure
    Given I onboard Customer Profile on investment service
      | identifier | customer_id | customer_profile_id   | provider_id      |
      | CPid1      |             | <customer_profile_id> | [SILVER_BULLION] |
#      | CPid1      |             | <customer_profile_id> | [GTN] |
    Then I wait until max time to verify Investment Customer-Profile <customer_profile_id> onboard status as <status>

    Given I deposit an amount of <amount> in Customer-Profile <customer_profile_id>

    Given I onboard End Customer-Profile of Customer-Profile CPid1 on Investment Service
      | end_customer_identifier | end_customer_profile_id | provider_id      |
      | EPid1                   | EPid1                   | [SILVER_BULLION] |
#      | EPid1                   | EPid1                   | [GTN]            |
    Then I wait until max time to verify Investment End Customer-Profile EPid1 of Customer-Profile CPid1 onboard status as <status>

    Given I create a product with customer profile <customer_profile_id>
      | identifier    | product_type           | profile_type | product_class | allocation   | allocation_strategy   | re_balance_strategy        | provider_id |
      | ProductID1    | INVESTMENT_PORTFOLIO   | CUSTOMER     |  SHARIAH      | <allocation> | <allocation_strategy> | <re_balance_strategy>      | <provider>  |

    Given I create Portfolio for End Customer-Profile EPid1 of Customer-Profile <customer_profile_id>
      | portfolio_identifier | product_id  |
      | Pid1                 | ProductID1  |

    Then I wait until max time for Portfolio creation of Customer-Profile CPid1 and verify Portfolio status
      | portfolio_identifier | portfolio_id | status  |
      | Pid1                 | Pid1         | SUCCESS |
#      | Pid2                 | Pid2         | SUCCESS |
#      | Pid3                 | Pid3         | SUCCESS |

    Given I process below transaction for Customer-Profile <customer_profile_id> with incorrect portfolio-id and verify status as <transaction_status>
      | transaction_identifier | portfolio_id                         | total_amount         | transaction_type | quantity |
      | Tid1                   | Pid1                                 | <transaction_amount> | INVEST           | 1        |
      | Tid2                   |                                      | <transaction_amount> | WITHDRAW         | 1        |
      | Tid3                   | 497550ee-33dc-43f2-894a-b5a9fc5ee82c | <transaction_amount> | WITHDRAW         | 1        |

    Examples:
      | customer_profile_id | status          | amount | transaction_amount | transaction_status | allocation_strategy | re_balance_strategy | provider        | allocation |
      | CPid1               | ONBOARD_SUCCESS | 500    | 50                 | ISM_9402           | YEARLY              | YEARLY              | SILVER-BULLION  | [{"assets":[{"asset_symbol":"XAU","percentage":100,"provider_id":"SILVER_BULLION"}]}] |


  Scenario Outline: Initiate invalid Transaction Type for portfolio and verify failure
    Given I onboard Customer Profile on investment service
      | identifier | customer_id | customer_profile_id   | provider_id      |
      | CPid1      |             | <customer_profile_id> | [SILVER_BULLION] |
#      | CPid1      |             | <customer_profile_id> | [GTN] |
    Then I wait until max time to verify Investment Customer-Profile <customer_profile_id> onboard status as <status>

    Given I deposit an amount of <amount> in Customer-Profile <customer_profile_id>

    Given I onboard End Customer-Profile of Customer-Profile CPid1 on Investment Service
      | end_customer_identifier | end_customer_profile_id | provider_id      |
      | EPid1                   | EPid1                   | [SILVER_BULLION] |
#      | EPid1                   | EPid1                   | [GTN]            |
    Then I wait until max time to verify Investment End Customer-Profile EPid1 of Customer-Profile CPid1 onboard status as <status>

    Given I create a product with customer profile <customer_profile_id>
      | identifier    | product_type           | profile_type | product_class | allocation   | allocation_strategy   | re_balance_strategy        | provider_id |
      | ProductID1    | INVESTMENT_PORTFOLIO   | CUSTOMER     |  SHARIAH      | <allocation> | <allocation_strategy> | <re_balance_strategy>      | <provider>  |

    Given I create Portfolio for End Customer-Profile EPid1 of Customer-Profile <customer_profile_id>
      | portfolio_identifier | product_id  |
      | Pid1                 | ProductID1  |

    Then I wait until max time for Portfolio creation of Customer-Profile CPid1 and verify Portfolio status
      | portfolio_identifier | portfolio_id | status  |
      | Pid1                 | Pid1         | SUCCESS |
#      | Pid2                 | Pid2         | SUCCESS |
#      | Pid3                 | Pid3         | SUCCESS |

    Given I process below transaction for Customer-Profile <customer_profile_id> with invalid transaction_type someGarbageValue and verify status as <transaction_status>
      | transaction_identifier | portfolio_id | total_amount         | transaction_type   | quantity | is_rate_included |
      | Tid1                   | Pid1         | <transaction_amount> | <transaction_type> | 1        | true             |
#      | Tid2                   | Pid3         | <transaction_amount> | <transaction_type> | 1        | true             |

    Examples:
      | customer_profile_id | status          | amount | transaction_amount | transaction_type | transaction_status        | allocation_strategy | re_balance_strategy | provider        | allocation |
      | CPid1               | ONBOARD_SUCCESS | 500    | 50                 | INVEST           | TRANSACTION_STATUS_FAILED | YEARLY              | YEARLY              | SILVER-BULLION  | [{"assets":[{"asset_symbol":"XAU","percentage":100,"provider_id":"SILVER_BULLION"}]}] |


  Scenario Outline: Initiate transaction with malformed and invalid rate and verify failure
    Given I onboard Customer Profile on investment service
      | identifier | customer_id | customer_profile_id   | provider_id      |
      | CPid1      |             | <customer_profile_id> | [SILVER_BULLION] |
#      | CPid1      |             | <customer_profile_id> | [GTN] |
    Then I wait until max time to verify Investment Customer-Profile <customer_profile_id> onboard status as <status>

    Given I deposit an amount of <amount> in Customer-Profile <customer_profile_id>

    Given I onboard End Customer-Profile of Customer-Profile CPid1 on Investment Service
      | end_customer_identifier | end_customer_profile_id | provider_id      |
      | EPid1                   | EPid1                   | [SILVER_BULLION] |
#      | EPid1                   | EPid1                   | [GTN]            |
    Then I wait until max time to verify Investment End Customer-Profile EPid1 of Customer-Profile CPid1 onboard status as <status>

    Given I create a product with customer profile <customer_profile_id>
      | identifier    | product_type           | profile_type | product_class | allocation   | allocation_strategy   | re_balance_strategy        | provider_id |
      | ProductID1    | INVESTMENT_PORTFOLIO   | CUSTOMER     |  SHARIAH      | <allocation> | <allocation_strategy> | <re_balance_strategy>      | <provider>  |

    Given I create Portfolio for End Customer-Profile EPid1 of Customer-Profile <customer_profile_id>
      | portfolio_identifier | product_id  |
      | Pid1                 | ProductID1  |

    Then I wait until max time for Portfolio creation of Customer-Profile CPid1 and verify Portfolio status
      | portfolio_identifier | portfolio_id | status  |
      | Pid1                 | Pid1         | SUCCESS |
#      | Pid2                 | Pid2         | SUCCESS |
#      | Pid3                 | Pid3         | SUCCESS |

    Given I process below transaction <transaction_type> for Customer-Profile <customer_profile_id> and expect header status of <status_code>
      | transaction_identifier | portfolio_id | total_amount | transaction_type | quantity | rate               | is_rate_included |
      | Tid1                   | Pid1         | 400          | INVEST           | 2        | {"asset_rates":[]} | true             |

    Given I process below transaction withdraw for Customer-Profile <customer_profile_id> and expect header status of <status_code>
      | transaction_identifier | portfolio_id | total_amount | transaction_type | quantity | rate               | is_rate_included |
      | Tid1                   | Pid1         | 10           | WITHDRAW         | 1        | {"asset_rates":[]} | true             |
    Examples:
      | customer_profile_id | status          | amount | transaction_type | status_code | allocation_strategy | re_balance_strategy | provider        | allocation |
      | CPid1               | ONBOARD_SUCCESS | 600    | INVEST           | ISM_9408    | YEARLY              | YEARLY              | SILVER-BULLION  | [{"assets":[{"asset_symbol":"XAU","percentage":100,"provider_id":"SILVER_BULLION"}]}] |
      | CPid1               | ONBOARD_SUCCESS | 600    | INVEST           | ISM_9410    | YEARLY              | YEARLY              | SILVER-BULLION  | [{"assets":[{"asset_symbol":"XAU","percentage":100,"provider_id":"SILVER_BULLION"}]}] |
