Feature: CMS service's Product scenarios

  Background: Set Customer Profile
    Given I set and verify customer Cid1, customer profile CPid1 in the context

  Scenario Outline: Onboard Customer Profile

    Given I onboard HUGOHUB Customer Profile for CMS with <payment_provider> and verify onboard status as ONBOARD_SUCCESS

    Then I onboard Customer Profile to CMS with <payment_provider> and verify onboard status as ONBOARD_SUCCESS

    Then I create following products and verify product status to be PRODUCT_APPROVAL_PENDING
      | product_id | product_name   | product_type             | description                               |product_class|profile_type|product_category|
      | Pid1       | My Credit Card | CREDIT_ACCOUNT           | Premium Credit Card for Premium Customers |   STANDARD  |   CUSTOMER |   category1    |

    Then I approve following products and verify product status to be PRODUCT_SUCCESS
      | product_id |
      | Pid1       |

    Examples:
      | payment_provider |
      | DBS              |
