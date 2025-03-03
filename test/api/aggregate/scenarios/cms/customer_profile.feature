Feature: CMS service's customer profile scenarios

  Background: Set Customer Profile
    Given I set and verify customer Cid1, customer profile CPid1 in the context

  Scenario Outline: Onboard Customer Profile

    Given I onboard HUGOHUB Customer Profile for CMS with <payment_provider> and verify onboard status as ONBOARD_SUCCESS

    Then I onboard Customer Profile to CMS with <payment_provider> and verify onboard status as ONBOARD_SUCCESS

    Examples:
      | payment_provider |
      | DBS              |
