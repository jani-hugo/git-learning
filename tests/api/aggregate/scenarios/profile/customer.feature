Feature: Profile service's customer scenarios

  Scenario Outline: Create customer and verify it's created successfully
    Given I create below Customer
      | customer_identifier | name   | date   |
      | Cid1                | <name> | <date> |

    Then I verify customers exist with values
      | customer_identifier | customer_id   | name   | date   |
      | Cid1                | <customer_id> | <name> | <date> |

    Examples:
      | name      | date                 |
      | customer1 | 2022-12-28T00:00:00Z |

  Scenario Outline: Create customer with missing datatype and verify failure
    Given I attempt to create customer with missing datatype and verify create failed
      | customer_identifier | name   |
      | Cid1                | <name> |

    Examples:
      | name      |
      | customer1 |
