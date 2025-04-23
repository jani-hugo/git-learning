Feature: CoA service's general ledger features

  Scenario Outline: Create general ledger for a customer from root to leaf node

    Given I onboard Customer to Chart of Accounts
      | customer_profile_id | node_code_length | number_of_levels | base_currency | node_type    | start_date   | duration   | duration_unit   | status_code   |
      | CPid1               | 6                | 4                | PKR           | CUSTOMER_COA | <start_date> | <duration> | <duration_unit> | <status_code> |

    Then I set the level config for the Chart of Account Nodes for customer
      | customer_profile_id | node_type    | status_code   | level_config                                                                                                                                                                                                                                         |
      | CPid1               | CUSTOMER_COA | <status_code> | [{"level_number": 0,"child_level_prefix_length": 2,"child_level_attribute_name": ""},{"level_number": 1,"child_level_prefix_length": 2,"child_level_attribute_name": ""},{"level_number": 2,"child_level_prefix_length": 2,"child_level_attribute_name": ""}] |

    Then I create General Ledger node for customer
      | customer_profile_id | parent_gl_code | gl_name           | gl_type  | gl_description         | is_manual_entry_allowed | gl_cumulative_balance_type | gl_allowed_txn_type | profile_info | status_code   |
      | CPid1               | <parent_code>  | ASSETS            | HEADER   | Asset-node             | true                    | ALL                        | ALL                 | {}           | <status_code> |
      | CPid1               | <parent_code>  | LIABILITIES       | HEADER   | Liability-node         | true                    | ALL                        | ALL                 | {}           | <status_code> |
      | CPid1               | 030000         | NET-ASSETS        | HEADER   | Net-assets-node        | true                    | ALL                        | ALL                 | {}           | <status_code> |
      | CPid1               | 040000         | NET-LIABILITIES   | HEADER   | Net-liabilities-node   | true                    | ALL                        | ALL                 | {}           | <status_code> |
      | CPid1               | 030100         | GROSS-ASSETS      | DETAILED | Gross-assets-node      | true                    | ALL                        | ALL                 | {}           | <status_code> |
      | CPid1               | 040100         | GROSS-LIABILITIES | DETAILED | Gross-liabilities-node | true                    | ALL                        | ALL                 | {}           | <status_code> |
      | CPid1               | 030100         | OTHER-ASSETS      | DETAILED | Other-assets-node      | true                    | CREDIT                     | ALL                 | {}           | <status_code> |
      | CPid1               | 030000         | NET-INVESTMENTS   | HEADER   | Net-investments-node   | true                    | ALL                        | ALL                 | {}           | <status_code> |
      | CPid1               | 030200         | INVESTMENTS       | DETAILED | Investments-node       | true                    | ALL                        | ALL                 | {}           | <status_code> |
      | CPid1               | 040100         | OTHER-LIABILITIES | DETAILED | Other-liabilities-node | true                    | DEBIT                      | ALL                 | {}           | <status_code> |

    Examples:
      | status_code | parent_code | start_date | duration | duration_unit |
      | 200         | 000000      | 2024-04-01 | 12       | MONTHS        |
