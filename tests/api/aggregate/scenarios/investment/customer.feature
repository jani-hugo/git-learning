Feature: Investment service scenarios for customer onboarding

  Background: Create customer profile on Account Service
    Given I set and verify customer Cid1, customer profile CPid1 in the context

  Scenario Outline: Onboard customer Profile onto Investment Service

    Given I onboard Customer Profile on investment service
      | identifier | customer_id | customer_profile_id   | provider_id      |
#      | CPid1      |             | <customer_profile_id> | [SILVER_BULLION] |
      | CPid1      |             | <customer_profile_id> | [GTN]            |

    Then I wait until max time to verify Investment Customer-Profile CPid1 onboard status as <status>

    Examples:
      | customer_profile_id | status          |
      | CPid1               | ONBOARD_SUCCESS |

  Scenario Outline: Onboard invalid customer Profile onto Investment Service and verify failure
    Given I try to onboard invalid Customer Profile on investment service and verify status as <status>
      | identifier | customer_id | customer_profile_id   | provider_id      |
      | CPid1      |             | <customer_profile_id> | [SILVER_BULLION] |
#      | CPid1      |             | <customer_profile_id> | [GTN]            |

    Examples:
      | identifier | customer_profile_id       | status   |
      | CPid1      | someRandomCustomerProfile | ISM_9107 |

  Scenario: Provider test scenarios
    Given I request to get all providers for below region
      | region |
      | SG     |

    Then I request to get Assets for each Provider
    Then I request to get all Assets for below Region
      | region |
      | SG     |
    Then I request to get Asset for invalid provider and expect ISM_9500
      | provider        |
      | someRandomValue |
