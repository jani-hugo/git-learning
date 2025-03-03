Feature: CoA service's customer book features

  Scenario Outline: Create customer book for customer from root node till leaf node

    Given I onboard Customer to Chart of Accounts
      | customer_profile_id | node_code_length | number_of_levels | base_currency | node_type     | start_date   | duration   | duration_unit   | status_code   |
      | CPid1               | 4                | 3                | PKR           | CUSTOMER_BOOK | <start_date> | <duration> | <duration_unit> | <status_code> |

    Then I set the level config for the Chart of Account Nodes for customer
      | customer_profile_id | node_type     | status_code   | level_config                                                                                                                                                                       |
      | CPid1               | CUSTOMER_BOOK | <status_code> | [{"level_number": 0,"child_level_prefix_length": 2,"child_level_attribute_name": "CITY"},{"level_number": 1,"child_level_prefix_length": 2,"child_level_attribute_name": "BUSINESS UNIT"}] |

    Then I create Customer Book node for customer
      | customer_profile_id | parent_cb_code | cb_attribute_value | cb_description | status_code   |
      | CPid1               | <parent_code>  | Karachi            | Level 1 Node   | <status_code> |
      | CPid1               | <parent_code>  | Hyderabad          | Level 1 Node   | <status_code> |
      | CPid1               | 0100           | FCC                | Level 1 Node   | <status_code> |
      | CPid1               | 0100           | BaaS               | Level 1 Node   | <status_code> |

    Examples:
      | status_code | parent_code | start_date | duration | duration_unit |
      | 200         | 0000        | 2024-04-01 | 12       | MONTHS        |


