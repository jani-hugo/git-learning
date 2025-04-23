Feature: Cash service CustomerProfile, EndCustomerProfile Products

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
      | BCPID1                      | ECPID1                          | <customer_profile_id> | cash       | service   | x@y.com | 00000000     | ACTIVE |

    # EndCustomerProfile Onboarding
    Given I onboard EndCustomerProfile ECPID1 of CustomerProfile BCPID1 on cash service on below providers and expect status 200
      | provider_name |
      | DBS Bank Ltd  |

    Then I wait until max time to verify EndCustomerProfile ECPID1 of CustomerProfile BCPID1 onboard status as ONBOARD_SUCCESS

  Scenario Outline: Create Product
    Given I create a product with customer profile <customer_profile_identifier> provider as <provider> and expect product_status PRODUCT_DRAFT
      | identifier    | product_type   | profile_type | product_class | currency   | country   | account_type | balance_policy_limit    | balance_policy_type |
      | ProductID1    | WALLET         | CUSTOMER     |  SHARIAH      | <currency> | <country> | SAVINGS      | 0                       | STRICT              |

    Then I approve the product ProductID1 and verify status as PRODUCT_SUCCESS with provider <provider> for customerProfileId <customer_profile_identifier>

    Examples:
      | customer_profile_identifier| provider     | currency | country   |
      | BCPID1                     | DBS Bank Ltd | SGD      | SGP       |

