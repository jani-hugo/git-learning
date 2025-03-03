Feature: CoA service's CoA config features

  Scenario Outline: Onboard Customer onto Customer Book and set customer book level config

    Given I onboard Customer to Chart of Accounts
      | customer_profile_id | node_code_length | number_of_levels | base_currency | node_type     | start_date   | duration   | duration_unit   | status_code   |
      | CPid1               | 7                | 7                | PKR           | CUSTOMER_BOOK | <start_date> | <duration> | <duration_unit> | <status_code> |

    Then I set the level config for the Chart of Account Nodes for customer
      | customer_profile_id | node_type     | status_code   | level_config                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
      | CPid1               | CUSTOMER_BOOK | <status_code> | [{"level_number": 0,"child_level_prefix_length": 1,"child_level_attribute_name": "LEAD"},{"level_number": 1,"child_level_prefix_length": 1,"child_level_attribute_name": "PROVINCE"},{"level_number": 2,"child_level_prefix_length": 1,"child_level_attribute_name": "REGION"},{"level_number": 3,"child_level_prefix_length": 1,"child_level_attribute_name": "AREA"},{"level_number": 4,"child_level_prefix_length": 2,"child_level_attribute_name": "CITY"},{"level_number": 5,"child_level_prefix_length": 1,"child_level_attribute_name": "BUSINESS UNIT"}] |

    Examples:
      | status_code | start_date | duration | duration_unit |
      | 200         | 2024-04-01 | 12       | MONTHS        |

  Scenario Outline: Onboard Customer onto General Ledger and set general ledger level config

    Given I onboard Customer to Chart of Accounts
      | customer_profile_id | node_code_length | number_of_levels | base_currency | node_type    | start_date   | duration   | duration_unit   | status_code   |
      | CPid1               | 6                | 4                | PKR           | CUSTOMER_COA | <start_date> | <duration> | <duration_unit> | <status_code> |

    Then I set the level config for the Chart of Account Nodes for customer
      | customer_profile_id | node_type    | status_code   | level_config                                                                                                                                                                                                                                                  |
      | CPid1               | CUSTOMER_COA | <status_code> | [{"level_number": 0,"child_level_prefix_length": 2,"child_level_attribute_name": ""},{"level_number": 1,"child_level_prefix_length": 2,"child_level_attribute_name": ""},{"level_number": 2,"child_level_prefix_length": 2,"child_level_attribute_name": ""}] |

    Examples:
      | status_code | start_date | duration | duration_unit |
      | 200         | 2024-04-01 | 12       | MONTHS        |

  Scenario Outline:  Onboard Customer onto Customer Book with number of levels less than minimum

    Given I onboard Customer to Chart of Accounts
      | customer_profile_id | node_code_length | number_of_levels | base_currency | node_type     | start_date   | duration   | duration_unit   | status_code   |
      | CPid1               | 6                | 1                | PKR           | CUSTOMER_BOOK | <start_date> | <duration> | <duration_unit> | <status_code> |

    Examples:
      | status_code | start_date | duration | duration_unit |
      | COSM_9402   | 2024-04-01 | 12       | MONTHS        |

  Scenario Outline:  Onboard Customer onto General Ledger with number of levels less than minimum

    Given I onboard Customer to Chart of Accounts
      | customer_profile_id | node_code_length | number_of_levels | base_currency | node_type    | start_date   | duration   | duration_unit   | status_code   |
      | CPid1               | 6                | 1                | PKR           | CUSTOMER_COA | <start_date> | <duration> | <duration_unit> | <status_code> |

    Examples:
      | status_code | start_date | duration | duration_unit |
      | COSM_9402   | 2024-04-01 | 12       | MONTHS        |

  Scenario Outline:  Onboard Customer onto Customer Book with number of levels more than maximum

    Given I onboard Customer to Chart of Accounts
      | customer_profile_id | node_code_length | number_of_levels | base_currency | node_type     | start_date   | duration   | duration_unit   | status_code   |
      | CPid1               | 6                | 21               | PKR           | CUSTOMER_BOOK | <start_date> | <duration> | <duration_unit> | <status_code> |

    Examples:
      | status_code | start_date | duration | duration_unit |
      | COSM_9402   | 2024-04-01 | 12       | MONTHS        |

  Scenario Outline:  Onboard Customer onto General Ledger with number of levels more than maximum

    Given I onboard Customer to Chart of Accounts
      | customer_profile_id | node_code_length | number_of_levels | base_currency | node_type    | start_date   | duration   | duration_unit   | status_code   |
      | CPid1               | 6                | 21               | PKR           | CUSTOMER_COA | <start_date> | <duration> | <duration_unit> | <status_code> |

    Examples:
      | status_code | start_date | duration | duration_unit |
      | COSM_9402   | 2024-04-01 | 12       | MONTHS        |

  Scenario Outline:  Onboard Customer onto Customer Book with node code length less than minimum

    Given I onboard Customer to Chart of Accounts
      | customer_profile_id | node_code_length | number_of_levels | base_currency | node_type     | start_date   | duration   | duration_unit   | status_code   |
      | CPid1               | 2                | 4                | PKR           | CUSTOMER_BOOK | <start_date> | <duration> | <duration_unit> | <status_code> |

    Examples:
      | status_code | start_date | duration | duration_unit |
      | COSM_9403   | 2024-04-01 | 12       | MONTHS        |

  Scenario Outline:  Onboard Customer onto General Ledger with node code length less than minimum

    Given I onboard Customer to Chart of Accounts
      | customer_profile_id | node_code_length | number_of_levels | base_currency | node_type    | start_date   | duration   | duration_unit   | status_code   |
      | CPid1               | 2                | 4                | PKR           | CUSTOMER_COA | <start_date> | <duration> | <duration_unit> | <status_code> |

    Examples:
      | status_code | start_date | duration | duration_unit |
      | COSM_9403   | 2024-04-01 | 12       | MONTHS        |

  Scenario Outline:  Onboard Customer onto Customer Book with node code length more than maximum

    Given I onboard Customer to Chart of Accounts
      | customer_profile_id | node_code_length | number_of_levels | base_currency | node_type     | start_date   | duration   | duration_unit   | status_code   |
      | CPid1               | 31               | 4                | PKR           | CUSTOMER_BOOK | <start_date> | <duration> | <duration_unit> | <status_code> |

    Examples:
      | status_code | start_date | duration | duration_unit |
      | COSM_9403   | 2024-04-01 | 12       | MONTHS        |

  Scenario Outline:  Onboard Customer onto General Ledger with node code length more than maximum

    Given I onboard Customer to Chart of Accounts
      | customer_profile_id | node_code_length | number_of_levels | base_currency | node_type    | start_date   | duration   | duration_unit   | status_code   |
      | CPid1               | 31               | 4                | PKR           | CUSTOMER_COA | <start_date> | <duration> | <duration_unit> | <status_code> |

    Examples:
      | status_code | start_date | duration | duration_unit |
      | COSM_9403   | 2024-04-01 | 12       | MONTHS        |

  Scenario Outline: Set customer book level config without onboarding customer

    Then I set the level config for the Chart of Account Nodes for customer
      | customer_profile_id | level_config                                                                                            | node_type     | status_code         |
      |   CPid1             | [{"level_number": 0,"child_level_prefix_length": 2},{"level_number": 1,"child_level_prefix_length": 2}]   | CUSTOMER_BOOK  | <error_status_code>    |

    Examples:
      | status_code | error_status_code |
      | 200         | COSM_9408               |

  Scenario Outline: Set general ledger level config without onboarding customer

    Then I set the level config for the Chart of Account Nodes for customer
      | customer_profile_id | level_config                                                                                            | node_type     | status_code         |
      |   CPid1             | [{"level_number": 0,"child_level_prefix_length": 2},{"level_number": 1,"child_level_prefix_length": 2}]   | CUSTOMER_COA  | <error_status_code>    |

    Examples:
      | status_code | error_status_code |
      | 200         | COSM_9408               |

  Scenario Outline: Onboard Customer onto Customer Book and set customer book level config with invalid level number

    Given I onboard Customer to Chart of Accounts
      | customer_profile_id | node_code_length | number_of_levels | base_currency | node_type     | start_date   | duration   | duration_unit   | status_code   |
      | CPid1               | 4                | 3                | PKR           | CUSTOMER_BOOK | <start_date> | <duration> | <duration_unit> | <status_code> |

    Then I set the level config for the Chart of Account Nodes for customer
      | customer_profile_id | level_config                                                                                            | node_type     | status_code         |
      |   CPid1             | [{"level_number": 0,"child_level_prefix_length": 2},{"level_number": 2,"child_level_prefix_length": 2}]   | CUSTOMER_BOOK  | <error_status_code>    |

    Examples:
      | status_code | error_status_code | start_date | duration | duration_unit |
      | 200         | COSM_9411         | 2024-04-01 | 12       | MONTHS        |

  Scenario Outline: Onboard Customer onto General Ledger and set general ledger level config with invalid level number

    Given I onboard Customer to Chart of Accounts
      | customer_profile_id | node_code_length | number_of_levels | base_currency | node_type    | start_date   | duration   | duration_unit   | status_code   |
      | CPid1               | 4                | 3                | PKR           | CUSTOMER_COA | <start_date> | <duration> | <duration_unit> | <status_code> |

    Then I set the level config for the Chart of Account Nodes for customer
      | customer_profile_id | level_config                                                                                            | node_type     | status_code         |
      |   CPid1             | [{"level_number": 0,"child_level_prefix_length": 2},{"level_number": 2,"child_level_prefix_length": 2}]   | CUSTOMER_COA  | <error_status_code>    |

    Examples:
      | status_code | error_status_code | start_date | duration | duration_unit |
      | 200         | COSM_9411         | 2024-04-01 | 12       | MONTHS        |

  Scenario Outline: Onboard Customer onto Customer Book and set customer book level config with invalid node code length sum

    Given I onboard Customer to Chart of Accounts
      | customer_profile_id | node_code_length | number_of_levels | base_currency | node_type     | start_date   | duration   | duration_unit   | status_code   |
      | CPid1               | 4                | 3                | PKR           | CUSTOMER_BOOK | <start_date> | <duration> | <duration_unit> | <status_code> |

    Then I set the level config for the Chart of Account Nodes for customer
      | customer_profile_id | level_config                                                                                            | node_type     | status_code         |
      |   CPid1             | [{"level_number": 0,"child_level_prefix_length": 2},{"level_number": 1,"child_level_prefix_length": 3}]   | CUSTOMER_BOOK  | <error_status_code>    |

    Examples:
      | status_code | error_status_code | start_date | duration | duration_unit |
      | 200         | COSM_9412         | 2024-04-01 | 12       | MONTHS        |

  Scenario Outline: Onboard Customer onto General Ledger and set general ledger level config with invalid node code length sum

    Given I onboard Customer to Chart of Accounts
      | customer_profile_id | node_code_length | number_of_levels | base_currency | node_type    | start_date   | duration   | duration_unit   | status_code   |
      | CPid1               | 4                | 3                | PKR           | CUSTOMER_COA | <start_date> | <duration> | <duration_unit> | <status_code> |

    Then I set the level config for the Chart of Account Nodes for customer
      | customer_profile_id | level_config                                                                                            | node_type     | status_code         |
      |   CPid1             | [{"level_number": 0,"child_level_prefix_length": 2},{"level_number": 1,"child_level_prefix_length": 3}]   | CUSTOMER_COA  | <error_status_code>    |

    Examples:
      | status_code | error_status_code | start_date | duration | duration_unit |
      | 200         | COSM_9412         | 2024-04-01 | 12       | MONTHS        |

