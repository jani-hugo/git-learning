Feature: Profile service's End-Customer-Profile scenarios

  Scenario Outline: Create End-Customer-Profile and verify it's created successfully
    Given I set and verify customer Cid1, customer profile CPid1 in the context

    Then I create below End-Customer-Profile
      | customer_identifier | customer_profile_identifier | end_customer_profile_identifier | first_name   | last_name   | region   | email   | phone_number   |
      | Cid1                | CPid1                       | ECPid1                          | <first_name> | <last_name> | <region> | <email> | <phone_number> |

    Then I verify End-Customer-Profile exist with values
      | customer_profile_identifier | end_customer_profile_identifier | customer_profile_id   | first_name   | last_name   | email   | phone_number   | status |
      | CPid1                       | ECPid1                          | <customer_profile_id> | <first_name> | <last_name> | <email> | <phone_number> | ACTIVE |

    Examples:
      | customer_profile_id   | first_name | last_name | region | email   | phone_number |
      | <customer_profile_id> | x          | y         | SG     | x@y.com | 8989548747   |


  Scenario Outline: Create End-Customer-Profile with invalid datatype and verify failure

    Then I attempt to create End-Customer-Profile with invalid datatype and verify create failed
      | customer_profile_id   | region   | first_name   | last_name   | email   | phone_number   |
      | <customer_profile_id> | <region> | <first_name> | <last_name> | <email> | <phone_number> |

    Examples:
      | customer_profile_id | region | first_name | last_name | email          | phone_number |
      | 1245                | sg     | hugo       | save      | hugo@atlas.com | 8989548747   |


  Scenario Outline: Create End-Customer-Profile and delete it
    Given I create below Customer
      | customer_identifier | name | date                 |
      | Cid1                | hugo | 2022-12-28T00:00:00Z |

    Then I create below Customer-Profile
      | customer_identifier | customer_profile_identifier | region | name | email          | phone_number |
      | Cid1                | CPid1                       | SG     | hugo | hugo@atlas.com | 8989548747   |

    Then I create below End-Customer-Profile
      | customer_identifier | customer_profile_identifier | end_customer_profile_identifier | first_name   | last_name   | region   | email   | phone_number   |
      | Cid1                | CPid1                       | ECPid1                          | <first_name> | <last_name> | <region> | <email> | <phone_number> |

    And I delete the above created End-Customer-Profile
      | customer_profile_identifier | end_customer_profile_identifier |
      | CPid1                       | ECPid1                          |

    And I verify End-Customer-Profile doesn't exist
      | customer_profile_identifier | end_customer_profile_identifier |
      | CPid1                       | ECPid1                          |

    Examples:
      | first_name | last_name | region | email   | phone_number |
      | x          | y         | SG     | x@y.com | 8989548747   |

