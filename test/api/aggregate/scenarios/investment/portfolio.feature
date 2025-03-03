Feature: Investment service scenarios for portfolio service

  Background: Create customer profile on Account Service
    Given I set and verify customer Cid1, customer profile CPid1 in the context
    Then I create below End-Customer-Profile
      | customer_identifier | customer_profile_identifier | end_customer_profile_identifier | first_name | last_name | region | email   | phone_number |
      | Cid1               | CPid1                        | EPid1                           | cash       | service   | SG     | x@y.com | 00000000     |

    Then I verify End-Customer-Profile exist with values
      | customer_profile_identifier | end_customer_profile_identifier | customer_profile_id   | first_name | last_name | email   | phone_number | status |
      | EPid1                       | EPid1                           | <customer_profile_id> | cash       | service   | x@y.com | 00000000     | ACTIVE |

  Scenario Outline: Portfolio Creation for end-Customer on Investment Service and  verify success
    Given I onboard Customer Profile on investment service
      | identifier | customer_id | customer_profile_id   | provider_id      |
      | CPid1      |             | <customer_profile_id> | [SILVER_BULLION] |
#      | CPid1      |             | <customer_profile_id> | [GTN] |

    Then I wait until max time to verify Investment Customer-Profile CPid1 onboard status as <status>

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
      | Pid1                 | ProductID1 |

    Then I wait until max time for Portfolio creation of Customer-Profile CPid1 and verify Portfolio status
      | portfolio_identifier | portfolio_id | status  |
      | Pid1                 | Pid1         | SUCCESS |

    Then I request to get Asset Rate for Portfolio Pid1 of End Customer-Profile EPid1 and expect the response body to contain the Portfolio assetRates

    Then I request to delete the Portfolio Pid1 of End Customer-Profile EPid1

    Then I verify Asset Rate is not found for Portfolio Pid1 of End Customer-Profile EPid1

    Then I verify Portfolio Pid1 is not found for End-Customer EPid1

    Examples:
      | customer_profile_id | status          | allocation_strategy | re_balance_strategy | provider        | allocation |
      | CPid1               | ONBOARD_SUCCESS | YEARLY              | YEARLY              | SILVER-BULLION  | [{"assets":[{"asset_symbol":"XAU","percentage":100,"provider_id":"SILVER_BULLION"}]}] |


  Scenario Outline: Create portfolio for incorrect End Customer and incorrect Customer-Profile Id and verify failure
    Given I onboard Customer Profile on investment service
      | identifier | customer_id | customer_profile_id   | provider_id      |
      | CPid1      |             | <customer_profile_id> | [SILVER_BULLION] |
#      | CPid1      |             | <customer_profile_id> | [GTN]            |

    Then I wait until max time to verify Investment Customer-Profile CPid1 onboard status as <status>

    Given I onboard End Customer-Profile of Customer-Profile CPid1 on Investment Service
      | end_customer_identifier | end_customer_profile_id | provider_id      |
      | EPid1                   | EPid1                   | [SILVER_BULLION] |
#      | EPid1                   | EPid1                   | [GTN]            |
    Then I wait until max time to verify Investment End Customer-Profile EPid1 of Customer-Profile CPid1 onboard status as <status>

    Given I create a product with customer profile <customer_profile_id>
      | identifier    | product_type           | profile_type | product_class | allocation   | allocation_strategy   | re_balance_strategy        | provider_id |
      | ProductID1    | INVESTMENT_PORTFOLIO   | CUSTOMER     |  SHARIAH      | <allocation> | <allocation_strategy> | <re_balance_strategy>      | <provider>  |

    Given I create Portfolio for End Customer-Profile EPid1 of incorrect Customer-Profile CPid1 and verify <status_code>
      | portfolio_identifier | product_id  |
      | Pid1                 | ProductID1  |

    Examples:
      | customer_profile_id | status          | status_code | allocation_strategy | re_balance_strategy | provider        | allocation |
      | CPid1               | ONBOARD_SUCCESS | ISM_9201    | YEARLY              | YEARLY              | SILVER-BULLION  | [{"assets":[{"asset_symbol":"XAU","percentage":100,"provider_id":"SILVER_BULLION"}]}] |


#  Scenario Outline: Create portfolio for End Customer with incorrect portfolio allocation and asset symbol and verify failure
#    Given I onboard Customer Profile on investment service
#      | identifier | customer_id | customer_profile_id   | provider_id      |
#      | CPid1      |             | <customer_profile_id> | [SILVER_BULLION] |
#    Then I wait until max time to verify Investment Customer-Profile CPid1 onboard status as <status>
#
#    Given I onboard End Customer-Profile of Customer-Profile CPid1 on Investment Service
#      | end_customer_identifier | end_customer_profile_id | provider_id      |
#      | EPid1                   | EPid1                   | [SILVER_BULLION] |
#    Then I wait until max time to verify Investment End Customer-Profile EPid1 of Customer-Profile CPid1 onboard status as <status>
#
#    Given I create Portfolio for End Customer-Profile EPid1 with incorrect portfolio allocation and verify <status_code>
#      | portfolio_identifier | portfolio                                                                                                                                                                                                                                                                                                 |  |
#      | Pid1                 | {"end_customer_profile_id":"EPid1","portfolio_name":"Testing P1","metadata":{"key":"value-test"},"portfolio_allocation":[{"assets":[{"asset_symbol":"XAU","percentage":40,"provider_id":"SILVER_BULLION"}]}],"allocation_strategy":{"frequency":"YEARLY"},"re_balancing_strategy":{"frequency":"YEARLY"}} |  |
#
#    Given I create Portfolio for End Customer-Profile EPid1 with invalid asset symbol and verify <asset_symbol_error_status>
#      | portfolio_identifier | portfolio                                                                                                                                                                                                                                                                                                                                                                        |  |
#      | Pid1                 | {"end_customer_profile_id":"EPid1","portfolio_name":"Testing P1","metadata":{"key":"value-test"},"portfolio_allocation":[{"assets":[{"asset_symbol":"GOLD","percentage":100,"provider_id":"SILVER_BULLION"}]}],"allocation_strategy":{"frequency":"YEARLY"},"re_balancing_strategy":{"frequency":"YEARLY"}} |  |
#
#    Examples:
#      | customer_profile_id | status          | status_code | asset_symbol_error_status |
#      | CPid1               | ONBOARD_SUCCESS | ISM_9403    | ISM_9411                  |


  Scenario Outline: Fetch assetRate with incorrect Portfolio Id and verify failure
    Given I onboard Customer Profile on investment service
      | identifier | customer_id | customer_profile_id   | provider_id      |
      | CPid1      |             | <customer_profile_id> | [SILVER_BULLION] |
    Then I wait until max time to verify Investment Customer-Profile CPid1 onboard status as <status>

    Given I onboard End Customer-Profile of Customer-Profile CPid1 on Investment Service
      | end_customer_identifier | end_customer_profile_id | provider_id      |
      | EPid1                   | EPid1                   | [SILVER_BULLION] |
    Then I wait until max time to verify Investment End Customer-Profile EPid1 of Customer-Profile CPid1 onboard status as <status>

    Given I create a product with customer profile <customer_profile_id>
      | identifier    | product_type           | profile_type | product_class | allocation   | allocation_strategy   | re_balance_strategy        | provider_id |
      | ProductID1    | INVESTMENT_PORTFOLIO   | CUSTOMER     |  SHARIAH      | <allocation> | <allocation_strategy> | <re_balance_strategy>      | <provider>  |

    Given I create Portfolio for End Customer-Profile EPid1 of Customer-Profile <customer_profile_id>
      | portfolio_identifier | product_id  |
      | Pid1                 | ProductID1 |

    Then I wait until max time for Portfolio creation of Customer-Profile CPid1 and verify Portfolio status
      | portfolio_identifier | portfolio_id | status  |
      | Pid1                 | Pid1         | SUCCESS |

    Then I request to get Asset Rate for incorrect Portfolio Pid1 of End Customer-Profile EPid1 and verify <status_code>
    Then I request to get Asset Rate for Portfolio Pid1 of End Customer-Profile EPid1 of incorrect Customer-Profile CPid1 and verify <status_code>
    Examples:
      | customer_profile_id | status          | status_code | allocation_strategy | re_balance_strategy | provider        | allocation |
      | CPid1               | ONBOARD_SUCCESS | ISM_9402    | YEARLY              | YEARLY              | SILVER-BULLION  | [{"assets":[{"asset_symbol":"XAU","percentage":100,"provider_id":"SILVER_BULLION"}]}] |


  Scenario Outline: Delete portfolio for End Customer with incorrect Customer-Profile Id and verify failure
    Given I onboard Customer Profile on investment service
      | identifier | customer_id | customer_profile_id   | provider_id      |
      | CPid1      |             | <customer_profile_id> | [SILVER_BULLION] |
    Then I wait until max time to verify Investment Customer-Profile CPid1 onboard status as <status>

    Given I onboard End Customer-Profile of Customer-Profile CPid1 on Investment Service
      | end_customer_identifier | end_customer_profile_id | provider_id      |
      | EPid1                   | EPid1                   | [SILVER_BULLION] |
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

    Then I try to delete the incorrect Portfolio Pid1 of End Customer-Profile EPid1 of Customer-Profile CPid1 and verify ISM_9402
    Examples:
      | customer_profile_id | status           | allocation_strategy | re_balance_strategy | provider        | allocation |
      | CPid1               | ONBOARD_SUCCESS  | YEARLY              | YEARLY              | SILVER-BULLION  | [{"assets":[{"asset_symbol":"XAU","percentage":100,"provider_id":"SILVER_BULLION"}]}] |

