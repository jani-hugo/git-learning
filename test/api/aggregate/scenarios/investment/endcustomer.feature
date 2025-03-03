Feature: Investment service scenarios for end-customer onboarding

  Background: Create customer profile on Account Service
    Given I set and verify customer Cid1, customer profile CPid1 in the context
    Then I create below End-Customer-Profile
      | customer_identifier | customer_profile_identifier | end_customer_profile_identifier | first_name | last_name | region | email   | phone_number |
      | Cid1               | CPid1                        | EPid1                           | cash       | service   | SG     | x@y.com | 00000000     |

    Then I verify End-Customer-Profile exist with values
      | customer_profile_identifier | end_customer_profile_identifier | customer_profile_id   | first_name | last_name | email   | phone_number | status |
      | EPid1                       | EPid1                           | <customer_profile_id> | cash       | service   | x@y.com | 00000000     | ACTIVE |

  Scenario Outline: Onboard end customer Profile onto Investment Service
    Given I onboard Customer Profile on investment service
      | identifier | customer_id | customer_profile_id   | provider_id      |
      | CPid1      |             | <customer_profile_id> | [SILVER_BULLION] |
      | CPid1      |             | <customer_profile_id> | [GTN]            |

    Then I wait until max time to verify Investment Customer-Profile CPid1 onboard status as <status>

    Given I onboard End Customer-Profile of Customer-Profile CPid1 on Investment Service
      | end_customer_identifier | end_customer_profile_id | provider_id      |
      | EPid1                   | EPid1                   | [SILVER_BULLION] |
#      | EPid1                   | EPid1                   | [GTN]                |
    Then I wait until max time to verify Investment End Customer-Profile EPid1 of Customer-Profile CPid1 onboard status as <status>
    Examples:
      | identifier | customer_profile_id | status          |
      | CPid1      | CPid1               | ONBOARD_SUCCESS |

  Scenario Outline: Onboard End Customer-Profile to incorrect Provider and verify ISM_9204
    Given I onboard Customer Profile on investment service
      | identifier | customer_id | customer_profile_id   | provider_id      |
      | CPid1      |             | <customer_profile_id> | [SILVER_BULLION] |
#      | CPid1      |             | <customer_profile_id> | [GTN]            |
    Then I wait until max time to verify Investment Customer-Profile CPid1 onboard status as ONBOARD_SUCCESS

    Given I onboard End Customer-Profile of Customer-Profile CPid1 to incorrect Provider and verify <status>
      | end_customer_identifier | end_customer_profile_id | provider_id      |
      | EPid1                   | EPid1                   | someGarbageValue |
    Examples:
      | identifier | customer_profile_id | status   |
      | CPid1      | CPid1               | ISM_9500 |

  Scenario Outline: Onboard End Customer-Profile to incorrect Customer-Profile on Investment service and verify failure
    Given I onboard Customer Profile on investment service
      | identifier | customer_id | customer_profile_id   | provider_id      |
      | CPid1      |             | <customer_profile_id> | [SILVER_BULLION] |
#      | CPid1      |             | <customer_profile_id> | [GTN]            |

    Then I wait until max time to verify Investment Customer-Profile CPid1 onboard status as ONBOARD_SUCCESS

    Given I onboard End Customer-Profile to incorrect Customer-Profile CPid1 and verify <status>
      | end_customer_identifier | end_customer_profile_id | provider_id      |
      | EPid1                   | EPid1                   | [SILVER_BULLION] |
#      | EPid1                   | EPid1                   | [GTN]            |
    Given I onboard End Customer-Profile of invalid Customer-Profile CPid1 and verify <status>
      | end_customer_identifier | end_customer_profile_id | provider_id      |
      | EPid1                   | EPid1                   | [SILVER_BULLION] |
#      | EPid1                   | EPid1                   | [GTN]            |
    Examples:
      | identifier | customer_profile_id | status   |
      | CPid1      | CPid1               | ISM_9201 |


#Scenario Outline: Delete End Customer-Profile on Investment service
#    Given I onboard Customer Profile on investment service
#      | identifier | customer_id | customer_profile_id   | provider_id          |
#      | CPid1      |             | <customer_profile_id> | [GTN,SILVER_BULLION] |
#    Then I wait until max time to verify Investment Customer-Profile CPid1 onboard status as <status>
#    Then I wait until max time to verify Investment Customer-Profile CPid1 onboard status as <status>
#    Given I get Provider id to below providers names
#      | provider_name |
#      | ATLAS         |
#    Given I onboard End Customer-Profile of Customer-Profile CPid1 on Investment Service
#      | end_customer_identifier | end_customer_profile_id | provider_id |
#      | EPid1                   | EPid1                   |             |
#    Then I wait until max time to verify Investment End Customer-Profile EPid1 of Customer-Profile CPid1 onboard status as <status>
#    Given I delete End Customer-Profile of Customer-Profile CPid1 on Investment Service and verify 200
#      | end_customer_identifier | end_customer_profile_id | provider_id |
#      | EPid1                   | EPid1                   | ATLAS       |
#    Examples:
#      | identifier | customer_profile_id | status          |
#      | CPid1      | CPid1               | ONBOARD_SUCCESS |
