Feature: Profile service's customer profile scenarios

  Scenario Outline: Create Customer-Profile and verify it's created successfully
    Given I create below Customer
      | customer_identifier | name | date                 |
      | Cid1                | hugo | 2022-12-28T00:00:00Z |

    Then I create below Customer-Profile
      | customer_identifier | customer_profile_identifier | region   | name   | email   | phone_number   |
      | Cid1                | CPid1                       | <region> | <name> | <email> | <phone_number> |

    Then I verify Customer-Profile exist with values
      | customer_identifier | customer_profile_identifier | customer_profile_id   | api_key   | customer_id   | region   | name   | email   | phone_number   | status |
      | Cid1                | CPid1                       | <customer_profile_id> | <api_key> | <customer_id> | <region> | <name> | <email> | <phone_number> | ACTIVE |

    Examples:
      | region | name | email          | phone_number |
      | SG     | hugo | hugo@atlas.com | 8989548747   |


  Scenario Outline: Create Customer-Profile with invalid datatype and verify failure
    Given I create below Customer
      | customer_identifier | name | date                 |
      | Cid1                | hugo | 2022-12-28T00:00:00Z |

    Then I attempt to create Customer-Profile with invalid datatype and verify create failed
      | customer_identifier | customer_profile_identifier | region   | name   | email   | phone_number   |
      | Cid1                | CPid1                       | <region> | <name> | <email> | <phone_number> |

    Examples:
      | region | name | email          | phone_number |
      | IN     | hugo | hugo@atlas.com | 8989548747   |


  Scenario Outline: Creating multiple Customer-Profile of a customer in same region should throw error
    Given I set and verify customer Cid1, customer profile CPid1 in the context

    Then I try to create a second Customer-Profile in same region
      | customer_identifier | customer_profile_identifier | region   | name   | email   | phone_number   |
      | Cid1                | CPid1                       | <region> | <name> | <email> | <phone_number> |

    Examples:
      | region | name  | email          | phone_number |
      | SG     | hugo1 | hugo@atlas.com | 8989548747   |
      | SG     | hugo2 | hugo@atlas.com | 8989548747   |
      | SG     | hugo3 | hugo@atlas.com | 8989548747   |
      | SG     | hugo4 | hugo@atlas.com | 8989548747   |
