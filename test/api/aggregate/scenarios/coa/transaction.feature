Feature: CoA service's transaction features

  Background:
    Given I onboard Customer to Chart of Accounts
      | customer_profile_id | node_code_length | number_of_levels | base_currency | node_type     | start_date | duration | duration_unit | status_code |
      | CPid1               | 4                | 3                | PKR           | CUSTOMER_BOOK | 2024-04-01 | 12       | MONTHS        | 200         |
      | CPid1               | 6                | 4                | PKR           | CUSTOMER_COA  | 2024-04-01 | 12       | MONTHS        | 200         |

    Then I set the level config for the Chart of Account Nodes for customer
      | customer_profile_id | node_type     | status_code | level_config                                                                                                                                                                                                                                                  |
      | CPid1               | CUSTOMER_BOOK | 200         | [{"level_number": 0,"child_level_prefix_length": 2,"child_level_attribute_name": "CITY"},{"level_number": 1,"child_level_prefix_length": 2,"child_level_attribute_name": "BUSINESS UNIT"}]                                                                    |
      | CPid1               | CUSTOMER_COA  | 200         | [{"level_number": 0,"child_level_prefix_length": 2,"child_level_attribute_name": ""},{"level_number": 1,"child_level_prefix_length": 2,"child_level_attribute_name": ""},{"level_number": 2,"child_level_prefix_length": 2,"child_level_attribute_name": ""}] |

    Then I create Customer Book node for customer
      | customer_profile_id | parent_cb_code | cb_attribute_value | cb_description | status_code |
      | CPid1               | 0000           | KARACHI            | Level 1 Node   | 200         |
      | CPid1               | 0000           | HYDERABAD          | Level 1 Node   | 200         |
      | CPid1               | 0100           | FCC                | Level 2 Node   | 200         |
      | CPid1               | 0100           | BAAS               | Level 2 Node   | 200         |
      | CPid1               | 0200           | FCC                | Level 2 Node   | 200         |
      | CPid1               | 0200           | BAAS               | Level 2 Node   | 200         |


    Then I create General Ledger node for customer
      | customer_profile_id | parent_gl_code | gl_name           | gl_type  | gl_description         | is_manual_entry_allowed | gl_cumulative_balance_type | gl_allowed_txn_type | profile_info | status_code |
      | CPid1               | 000000         | ASSETS            | HEADER   | Asset-node             | true                    | ALL                        | ALL                 | {}           | 200         |
      | CPid1               | 000000         | LIABILITIES       | HEADER   | Liability-node         | true                    | ALL                        | ALL                 | {}           | 200         |
      | CPid1               | 030000         | NET-ASSETS        | HEADER   | Net-assets-node        | true                    | ALL                        | ALL                 | {}           | 200         |
      | CPid1               | 040000         | NET-LIABILITIES   | HEADER   | Net-liabilities-node   | true                    | ALL                        | ALL                 | {}           | 200         |
      | CPid1               | 030100         | GROSS-ASSETS      | DETAILED | Gross-assets-node      | true                    | CREDIT                     | ALL                 | {}           | 200         |
      | CPid1               | 040100         | GROSS-LIABILITIES | DETAILED | Gross-liabilities-node | true                    | DEBIT                      | ALL                 | {}           | 200         |
      | CPid1               | 030100         | OTHER-ASSETS      | DETAILED | Other-assets-node      | true                    | ALL                        | CREDIT              | {}           | 200         |
      | CPid1               | 030000         | NET-INVESTMENTS   | HEADER   | Net-investments-node   | true                    | ALL                        | ALL                 | {}           | 200         |
      | CPid1               | 030200         | INVESTMENTS       | DETAILED | Investments-node       | true                    | ALL                        | ALL                 | {}           | 200         |
      | CPid1               | 040100         | OTHER-LIABILITIES | DETAILED | Other-liabilities-node | true                    | ALL                        | DEBIT               | {}           | 200         |

    Then I add transaction codes to CORE module
      | customer_profile_id | transaction_code | iso_code | description   | status_code |
      | CPid1               | 210002           | CASH_TXN | CASH_TXN_CODE | 200         |


  Scenario Outline: Create transaction code to general ledger mapping

    Then I map transaction to codes for customer
      | customer_profile_id | txn_code | gl_code | product_id | status_code   |
      | CPid1               | 210002   | 030101  | 123        | <status_code> |

    Examples:
      | status_code |
      | 200         |

  Scenario Outline: Create transaction code to general ledger mapping on Header node

    Then I map transaction to codes for customer
      | customer_profile_id | txn_code | gl_code | product_id | status_code   |
      | CPid1               | 210002   | 030000  | 123        | <status_code> |

    Examples:
      | status_code |
      | COSM_9405   |


  Scenario Outline: Create transaction code and product id to general ledger mapping then add a DEBIT transaction with same transaction code and product id along with proper profile attributes

    Then I map transaction to codes for customer
      | customer_profile_id | txn_code       | gl_code   | product_id   | status_code   |
      | CPid1               | <coa_txn_code> | <gl_code> | <product_id> | <status_code> |

    Then I add transactions for customer
      | financial_entry_id | metadata | coa_transaction_message_type   | status_code   | transactions                                                                                                                                                                                                                                                                                                                                                                                                                           |
      | financialEntry1    | {}       | <coa_transaction_message_type> | <status_code> | [{"txn_id":"Tid1","product_id":"<product_id>","txn_code":"<coa_txn_code>","customer_profile_id":"CPid1","end_customer_profile_id":"ECPid1","transaction_type":"<transaction_type>","txn_amount":<amount>,"currency": "<currency>","base_currency_rate_per_unit": <base_currency_rate_per_unit>,"source":"CASH","booking_ts":"<booking_ts>","value_ts":"<value_ts>","profile_attributes":<profile_attributes>, "metadata":<metadata> }] |

    Then I check the General Ledger <gl_code> under Customer Book 0101 for Customer with id CPid1 to ensure the transaction with id Tid1 is successfully added

    Then I check the aggregated value at the gl node <gl_code> under Customer Book 0101 against transaction of amount <amount> and of type <transaction_type> for customer CPid1

    Examples:
      | status_code | product_id | txn_code  | coa_txn_code | transaction_type | coa_transaction_message_type | amount | currency | base_currency_rate_per_unit | gl_code | profile_attributes                                                                                                 | booking_ts                  | value_ts                    | metadata                                                     |
      | 200         | P123       | CASH_TXN1 | 210002       | DEBIT            | EXTERNAL_TRANSACTION         | 100    | PKR      | 1.0                         | 040101  | [{"attribute_key":"CITY","attribute_value": "Karachi"},{"attribute_key":"BUSINESS UNIT","attribute_value": "FCC"}] | 2024-10-20T09:27:02.584189Z | 2024-10-20T09:27:02.584189Z | {"metadata":{"invoice":"B123HD82H", "Vendor": "McDonald's"}} |

  Scenario Outline: Create transaction code and product id to general ledger mapping then add a DEBIT transaction with same transaction code and product id with no profile attributes

    Then I map transaction to codes for customer
      | customer_profile_id | txn_code       | gl_code   | product_id   | status_code   |
      | CPid1               | <coa_txn_code> | <gl_code> | <product_id> | <status_code> |

    Then I add transactions for customer
      | financial_entry_id | metadata | coa_transaction_message_type   | status_code   | transactions                                                                                                                                                                                                                                                                                                                                                                                 |
      | financialEntry1    | {}       | <coa_transaction_message_type> | <status_code> | [{"txn_id":"Tid1","product_id":"<product_id>","txn_code":"<coa_txn_code>","customer_profile_id":"CPid1","end_customer_profile_id":"ECPid1","transaction_type":"<transaction_type>","txn_amount":<amount>,"currency": "<currency>","base_currency_rate_per_unit": <base_currency_rate_per_unit>,"source":"CASH", "booking_ts":"<booking_ts>","value_ts":"<value_ts>", "metadata":<metadata>}] |

    Then I check the General Ledger <gl_code> under Customer Book 0301 for Customer with id CPid1 to ensure the transaction with id Tid1 is successfully added

    Then I check the aggregated value at the gl node <gl_code> under Customer Book 0301 against transaction of amount <amount> and of type <transaction_type> for customer CPid1

    Examples:
      | status_code | product_id | txn_code  | coa_txn_code | transaction_type | coa_transaction_message_type | amount | currency | base_currency_rate_per_unit | gl_code | booking_ts                  | value_ts                    | metadata                                                     |
      | 200         | P123       | CASH_TXN1 | 210002       | DEBIT            | EXTERNAL_TRANSACTION         | 100    | PKR      | 1.0                         | 040101  | 2024-10-20T09:27:02.584189Z | 2024-10-20T09:27:02.584189Z | {"metadata":{"invoice":"B123HD82H", "Vendor": "McDonald's"}} |

  Scenario Outline: Create transaction code and product id to general ledger mapping then add a CREDIT transaction with same transaction code and product id along with proper profile attributes

    Then I map transaction to codes for customer
      | customer_profile_id | txn_code       | gl_code   | product_id   | status_code   |
      | CPid1               | <coa_txn_code> | <gl_code> | <product_id> | <status_code> |

    Then I add transactions for customer
      | financial_entry_id | metadata | coa_transaction_message_type   | status_code   | transactions                                                                                                                                                                                                                                                                                                                                                                                                                            |
      | financialEntry1    | {}       | <coa_transaction_message_type> | <status_code> | [{"txn_id":"Tid1","product_id":"<product_id>","txn_code":"<coa_txn_code>","customer_profile_id":"CPid1","end_customer_profile_id":"ECPid1","transaction_type":"<transaction_type>","txn_amount":<amount>,"currency": "<currency>","base_currency_rate_per_unit": <base_currency_rate_per_unit>,"source":"CASH","booking_ts":"<booking_ts>","value_ts":"<value_ts>", "profile_attributes":<profile_attributes>, "metadata":<metadata> }] |

    Then I check the General Ledger <gl_code> under Customer Book 0101 for Customer with id CPid1 to ensure the transaction with id Tid1 is successfully added

    Then I check the aggregated value at the gl node <gl_code> under Customer Book 0101 against transaction of amount <amount> and of type <transaction_type> for customer CPid1

    Examples:
      | status_code | product_id | txn_code  | coa_txn_code | transaction_type | coa_transaction_message_type | amount | currency | base_currency_rate_per_unit | gl_code | profile_attributes                                                                                                 | booking_ts                  | value_ts                    | metadata                                                     |
      | 200         | P123       | CASH_TXN1 | 210002       | CREDIT           | EXTERNAL_TRANSACTION         | 100    | PKR      | 1.0                         | 030101  | [{"attribute_key":"CITY","attribute_value": "Karachi"},{"attribute_key":"BUSINESS UNIT","attribute_value": "FCC"}] | 2024-10-20T09:27:02.584189Z | 2024-10-20T09:27:02.584189Z | {"metadata":{"invoice":"B123HD82H", "Vendor": "McDonald's"}} |

  Scenario Outline: Create transaction code and product id to general ledger mapping then add a CREDIT transaction with same transaction code and product id with no profile attributes

    Then I map transaction to codes for customer
      | customer_profile_id | txn_code       | gl_code   | product_id   | status_code   |
      | CPid1               | <coa_txn_code> | <gl_code> | <product_id> | <status_code> |

    Then I add transactions for customer
      | financial_entry_id | metadata | coa_transaction_message_type   | status_code   | transactions                                                                                                                                                                                                                                                                                                                                                                                 |
      | financialEntry1    | {}       | <coa_transaction_message_type> | <status_code> | [{"txn_id":"Tid1","product_id":"<product_id>","txn_code":"<coa_txn_code>","customer_profile_id":"CPid1","end_customer_profile_id":"ECPid1","transaction_type":"<transaction_type>","txn_amount":<amount>,"currency": "<currency>","base_currency_rate_per_unit": <base_currency_rate_per_unit>,"source":"CASH", "booking_ts":"<booking_ts>","value_ts":"<value_ts>", "metadata":<metadata>}] |

    Then I check the General Ledger <gl_code> under Customer Book 0301 for Customer with id CPid1 to ensure the transaction with id Tid1 is successfully added

    Then I check the aggregated value at the gl node <gl_code> under Customer Book 0301 against transaction of amount <amount> and of type <transaction_type> for customer CPid1

    Examples:
      | status_code | product_id | txn_code  | coa_txn_code | transaction_type | coa_transaction_message_type | amount | currency | base_currency_rate_per_unit | gl_code | booking_ts                  | value_ts                    | metadata                                                     |
      | 200         | P123       | CASH_TXN1 | 210002       | CREDIT           | EXTERNAL_TRANSACTION         | 100    | PKR      | 1.0                         | 030101  | 2024-10-20T09:27:02.584189Z | 2024-10-20T09:27:02.584189Z | {"metadata":{"invoice":"B123HD82H", "Vendor": "McDonald's"}} |

  Scenario Outline: Create transaction code and product id to general ledger mapping then add a DEBIT transaction with different transaction code and product id along with proper profile attributes

    Then I map transaction to codes for customer
      | customer_profile_id | txn_code       | gl_code   | product_id   | status_code   |
      | CPid1               | <coa_txn_code> | <gl_code> | <product_id> | <status_code> |

    Then I add transactions for customer
      | financial_entry_id | metadata | coa_transaction_message_type   | status_code   | transactions                                                                                                                                                                                                                                                                                                                                                                                                                    |
      | financialEntry1    | {}       | <coa_transaction_message_type> | <status_code> | [{"txn_id":"Tid1","product_id":"<product_id>","txn_code":"Test123","customer_profile_id":"CPid1","end_customer_profile_id":"ECPid1","transaction_type":"<transaction_type>","txn_amount":<amount>,"currency": "<currency>","base_currency_rate_per_unit": <base_currency_rate_per_unit>,"source":"CASH","booking_ts":"<booking_ts>","value_ts":"<value_ts>","profile_attributes":<profile_attributes>, "metadata":<metadata> }] |

    Then I check the General Ledger <gl_code> under Customer Book 0101 for Customer with id CPid1 to ensure the transaction with id Tid1 is successfully added

    Then I check the aggregated value at the gl node <gl_code> under Customer Book 0101 against transaction of amount <amount> and of type <transaction_type> for customer CPid1

    Examples:
      | status_code | product_id | txn_code  | coa_txn_code | transaction_type | coa_transaction_message_type | amount | currency | base_currency_rate_per_unit | gl_code        | profile_attributes                                                                                                 | booking_ts                  | value_ts                    | metadata                                                     |
      | 200         | P123       | CASH_TXN1 | 210002       | DEBIT            | EXTERNAL_TRANSACTION         | 100    | PKR      | 1.0                         | SUSPENSE-DEBIT | [{"attribute_key":"CITY","attribute_value": "Karachi"},{"attribute_key":"BUSINESS UNIT","attribute_value": "FCC"}] | 2024-10-20T09:27:02.584189Z | 2024-10-20T09:27:02.584189Z | {"metadata":{"invoice":"B123HD82H", "Vendor": "McDonald's"}} |

  Scenario Outline: Create transaction code and product id to general ledger mapping then add a DEBIT transaction with different transaction code and product id and no profile attributes

    Then I map transaction to codes for customer
      | customer_profile_id | txn_code       | gl_code   | product_id   | status_code   |
      | CPid1               | <coa_txn_code> | <gl_code> | <product_id> | <status_code> |

    Then I add transactions for customer
      | financial_entry_id | metadata | coa_transaction_message_type   | status_code   | transactions                                                                                                                                                                                                                                                                                                                                                                          |
      | financialEntry1    | {}       | <coa_transaction_message_type> | <status_code> | [{"txn_id":"Tid1","product_id":"<product_id>","txn_code":"Test123","customer_profile_id":"CPid1","end_customer_profile_id":"ECPid1","transaction_type":"<transaction_type>","txn_amount":<amount>,"currency": "<currency>","base_currency_rate_per_unit": <base_currency_rate_per_unit>,"source":"CASH", "booking_ts":"<booking_ts>","value_ts":"<value_ts>", "metadata":<metadata>}] |

    Then I check the General Ledger <gl_code> under Customer Book 0301 for Customer with id CPid1 to ensure the transaction with id Tid1 is successfully added

    Then I check the aggregated value at the gl node <gl_code> under Customer Book 0301 against transaction of amount <amount> and of type <transaction_type> for customer CPid1

    Examples:
      | status_code | product_id | txn_code  | coa_txn_code | transaction_type | coa_transaction_message_type | amount | currency | base_currency_rate_per_unit | gl_code        | booking_ts                  | value_ts                    | metadata                                                     |
      | 200         | P123       | CASH_TXN1 | 210002       | DEBIT            | EXTERNAL_TRANSACTION         | 100    | PKR      | 1.0                         | SUSPENSE-DEBIT | 2024-10-20T09:27:02.584189Z | 2024-10-20T09:27:02.584189Z | {"metadata":{"invoice":"B123HD82H", "Vendor": "McDonald's"}} |

  Scenario Outline: Create transaction code and product id to general ledger mapping then add a CREDIT transaction with different transaction code and product id along with proper profile attributes

    Then I map transaction to codes for customer
      | customer_profile_id | txn_code       | gl_code   | product_id   | status_code   |
      | CPid1               | <coa_txn_code> | <gl_code> | <product_id> | <status_code> |

    Then I add transactions for customer
      | financial_entry_id | metadata | coa_transaction_message_type   | status_code   | transactions                                                                                                                                                                                                                                                                                                                                                                                                                    |
      | financialEntry1    | {}       | <coa_transaction_message_type> | <status_code> | [{"txn_id":"Tid1","product_id":"<product_id>","txn_code":"Test123","customer_profile_id":"CPid1","end_customer_profile_id":"ECPid1","transaction_type":"<transaction_type>","txn_amount":<amount>,"currency": "<currency>","base_currency_rate_per_unit": <base_currency_rate_per_unit>,"source":"CASH","booking_ts":"<booking_ts>","value_ts":"<value_ts>","profile_attributes":<profile_attributes>, "metadata":<metadata> }] |

    Then I check the General Ledger <gl_code> under Customer Book 0101 for Customer with id CPid1 to ensure the transaction with id Tid1 is successfully added

    Then I check the aggregated value at the gl node <gl_code> under Customer Book 0101 against transaction of amount <amount> and of type <transaction_type> for customer CPid1

    Examples:
      | status_code | product_id | txn_code  | coa_txn_code | transaction_type | coa_transaction_message_type | amount | currency | base_currency_rate_per_unit | gl_code         | profile_attributes                                                                                                 | booking_ts                  | value_ts                    | metadata                                                     |
      | 200         | P123       | CASH_TXN1 | 210002       | CREDIT           | EXTERNAL_TRANSACTION         | 100    | PKR      | 1.0                         | SUSPENSE-CREDIT | [{"attribute_key":"CITY","attribute_value": "Karachi"},{"attribute_key":"BUSINESS UNIT","attribute_value": "FCC"}] | 2024-10-20T09:27:02.584189Z | 2024-10-20T09:27:02.584189Z | {"metadata":{"invoice":"B123HD82H", "Vendor": "McDonald's"}} |

  Scenario Outline: Create transaction code and product id to general ledger mapping then add a CREDIT transaction with different transaction code and product id and no profile attributes

    Then I map transaction to codes for customer
      | customer_profile_id | txn_code       | gl_code   | product_id   | status_code   |
      | CPid1               | <coa_txn_code> | <gl_code> | <product_id> | <status_code> |

    Then I add transactions for customer
      | financial_entry_id | metadata | coa_transaction_message_type   | status_code   | transactions                                                                                                                                                                                                                                                                                                                                                                          |
      | financialEntry1    | {}       | <coa_transaction_message_type> | <status_code> | [{"txn_id":"Tid1","product_id":"<product_id>","txn_code":"Test123","customer_profile_id":"CPid1","end_customer_profile_id":"ECPid1","transaction_type":"<transaction_type>","txn_amount":<amount>,"currency": "<currency>","base_currency_rate_per_unit": <base_currency_rate_per_unit>,"source":"CASH", "booking_ts":"<booking_ts>","value_ts":"<value_ts>", "metadata":<metadata>}] |

    Then I check the General Ledger <gl_code> under Customer Book 0301 for Customer with id CPid1 to ensure the transaction with id Tid1 is successfully added

    Then I check the aggregated value at the gl node <gl_code> under Customer Book 0301 against transaction of amount <amount> and of type <transaction_type> for customer CPid1

    Examples:
      | status_code | product_id | txn_code  | coa_txn_code | transaction_type | coa_transaction_message_type | amount | currency | base_currency_rate_per_unit | gl_code         | booking_ts                  | value_ts                    | metadata                                                     |
      | 200         | P123       | CASH_TXN1 | 210002       | CREDIT           | EXTERNAL_TRANSACTION         | 100    | PKR      | 1.0                         | SUSPENSE-CREDIT | 2024-10-20T09:27:02.584189Z | 2024-10-20T09:27:02.584189Z | {"metadata":{"invoice":"B123HD82H", "Vendor": "McDonald's"}} |


  Scenario Outline: Create transaction with incorrect product id to map to CREDIT-SUSPENSE and then map it to the correct General Ledger Node

    Then I map transaction to codes for customer
      | customer_profile_id | txn_code       | gl_code   | product_id   | status_code   |
      | CPid1               | <coa_txn_code> | <gl_code> | <product_id> | <status_code> |

    Then I add transactions for customer
      | financial_entry_id | metadata | coa_transaction_message_type   | status_code   | transactions                                                                                                                                                                                                                                                                                                                                                                          |
      | financialEntry1    | {}       | <coa_transaction_message_type> | <status_code> | [{"txn_id":"Tid1","product_id":"<product_id>","txn_code":"Test123","customer_profile_id":"CPid1","end_customer_profile_id":"ECPid1","transaction_type":"<transaction_type>","txn_amount":<amount>,"currency": "<currency>","base_currency_rate_per_unit": <base_currency_rate_per_unit>,"source":"CASH", "booking_ts":"<booking_ts>","value_ts":"<value_ts>", "metadata":<metadata>}] |

    Then I check the General Ledger <suspense_gl_code> under Customer Book 0301 for Customer with id CPid1 to ensure the transaction with id Tid1 is successfully added

    Then I check the aggregated value at the gl node <suspense_gl_code> under Customer Book 0301 against transaction of amount <amount> and of type <transaction_type> for customer CPid1

    Then I manually remap the transaction to correct General Ledger
      | txn_id | customer_profile_id | mapped_cb_code | mapped_gl_code | source | value_ts   | status_code   |
      | Tid1   | CPid1               | 0301           | <gl_code>      | CASH   | <value_ts> | <status_code> |

#    Then I check the General Ledger SUSPENSE-CREDIT under Customer Book 0301 for Customer with id CPid1 to ensure the transaction with id Tid1 is successfully added

    Then I check the aggregated value at the gl node <gl_code> under Customer Book 0301 against transaction of amount <amount> and of type <transaction_type> for customer CPid1

    Then I check the aggregated value at the gl node <suspense_gl_code> under Customer Book 0301 against transaction of amount 0.0 and of type <transaction_type> for customer CPid1

    Examples:
      | status_code | product_id | txn_code  | coa_txn_code | transaction_type | coa_transaction_message_type | amount | currency | base_currency_rate_per_unit | gl_code | suspense_gl_code | booking_ts                  | value_ts                    | metadata                                                     |
      | 200         | P123       | CASH_TXN1 | 210002       | CREDIT           | EXTERNAL_TRANSACTION         | 100.0  | PKR      | 1.0                         | 030101  | SUSPENSE-CREDIT  | 2024-10-20T09:27:02.584189Z | 2024-10-20T09:27:02.584189Z | {"metadata":{"invoice":"B123HD82H", "Vendor": "McDonald's"}} |


  Scenario Outline: Create CREDIT transaction to a general ledger node with gl_allowed_txn_type CREDIT

    Then I map transaction to codes for customer
      | customer_profile_id | txn_code       | gl_code   | product_id   | status_code   |
      | CPid1               | <coa_txn_code> | <gl_code> | <product_id> | <status_code> |

    Then I add transactions for customer
      | financial_entry_id | metadata | coa_transaction_message_type   | status_code   | transactions                                                                                                                                                                                                                                                                                                                                                                                 |
      | financialEntry1    | {}       | <coa_transaction_message_type> | <status_code> | [{"txn_id":"Tid1","product_id":"<product_id>","txn_code":"<coa_txn_code>","customer_profile_id":"CPid1","end_customer_profile_id":"ECPid1","transaction_type":"<transaction_type>","txn_amount":<amount>,"currency": "<currency>","base_currency_rate_per_unit": <base_currency_rate_per_unit>,"source":"CASH", "booking_ts":"<booking_ts>","value_ts":"<value_ts>", "metadata":<metadata>}] |

    Then I check the General Ledger <gl_code> under Customer Book 0301 for Customer with id CPid1 to ensure the transaction with id Tid1 is successfully added

    Then I check the aggregated value at the gl node <gl_code> under Customer Book 0301 against transaction of amount <amount> and of type <transaction_type> for customer CPid1

    Examples:
      | status_code | product_id | txn_code  | coa_txn_code | transaction_type | coa_transaction_message_type | amount | currency | base_currency_rate_per_unit | gl_code | booking_ts                  | value_ts                    | metadata                                                     |
      | 200         | P123       | CASH_TXN1 | 210002       | CREDIT           | EXTERNAL_TRANSACTION         | 100.0  | PKR      | 1.0                         | 030102  | 2024-10-20T09:27:02.584189Z | 2024-10-20T09:27:02.584189Z | {"metadata":{"invoice":"B123HD82H", "Vendor": "McDonald's"}} |

  Scenario Outline: Create DEBIT transaction to a general ledger node with gl_allowed_txn_type DEBIT

    Then I map transaction to codes for customer
      | customer_profile_id | txn_code       | gl_code   | product_id   | status_code   |
      | CPid1               | <coa_txn_code> | <gl_code> | <product_id> | <status_code> |

    Then I add transactions for customer
      | financial_entry_id | metadata | coa_transaction_message_type   | status_code   | transactions                                                                                                                                                                                                                                                                                                                                                                                 |
      | financialEntry1    | {}       | <coa_transaction_message_type> | <status_code> | [{"txn_id":"Tid1","product_id":"<product_id>","txn_code":"<coa_txn_code>","customer_profile_id":"CPid1","end_customer_profile_id":"ECPid1","transaction_type":"<transaction_type>","txn_amount":<amount>,"currency": "<currency>","base_currency_rate_per_unit": <base_currency_rate_per_unit>,"source":"CASH", "booking_ts":"<booking_ts>","value_ts":"<value_ts>", "metadata":<metadata>}] |

    Then I check the General Ledger <gl_code> under Customer Book 0301 for Customer with id CPid1 to ensure the transaction with id Tid1 is successfully added

    Then I check the aggregated value at the gl node <gl_code> under Customer Book 0301 against transaction of amount <amount> and of type <transaction_type> for customer CPid1

    Examples:
      | status_code | product_id | txn_code  | coa_txn_code | transaction_type | coa_transaction_message_type | amount | currency | base_currency_rate_per_unit | gl_code | booking_ts                  | value_ts                    | metadata                                                     |
      | 200         | P123       | CASH_TXN1 | 210002       | DEBIT            | EXTERNAL_TRANSACTION         | 100.0  | PKR      | 1.0                         | 040102  | 2024-10-20T09:27:02.584189Z | 2024-10-20T09:27:02.584189Z | {"metadata":{"invoice":"B123HD82H", "Vendor": "McDonald's"}} |

  Scenario Outline: Create CREDIT transaction to a general ledger node with gl_allowed_txn_type DEBIT

    Then I map transaction to codes for customer
      | customer_profile_id | txn_code       | gl_code   | product_id   | status_code   |
      | CPid1               | <coa_txn_code> | <gl_code> | <product_id> | <status_code> |

    Then I add transactions for customer
      | financial_entry_id | metadata | coa_transaction_message_type   | status_code   | transactions                                                                                                                                                                                                                                                                                                                                                                                 |
      | financialEntry1    | {}       | <coa_transaction_message_type> | <status_code> | [{"txn_id":"Tid1","product_id":"<product_id>","txn_code":"<coa_txn_code>","customer_profile_id":"CPid1","end_customer_profile_id":"ECPid1","transaction_type":"<transaction_type>","txn_amount":<amount>,"currency": "<currency>","base_currency_rate_per_unit": <base_currency_rate_per_unit>,"source":"CASH", "booking_ts":"<booking_ts>","value_ts":"<value_ts>", "metadata":<metadata>}] |

    Then I check the General Ledger <gl_code> under Customer Book 0301 for Customer with id CPid1 to ensure the transaction with id Tid1 is successfully added

    Then I check the aggregated value at the gl node <gl_code> under Customer Book 0301 against transaction of amount <amount> and of type <transaction_type> for customer CPid1

    Examples:
      | status_code | product_id | txn_code  | coa_txn_code | transaction_type | coa_transaction_message_type | amount | currency | base_currency_rate_per_unit | gl_code         | booking_ts                  | value_ts                    | metadata                                                     |
      | 200         | P123       | CASH_TXN1 | 210002       | CREDIT           | EXTERNAL_TRANSACTION         | 100.0  | PKR      | 1.0                         | SUSPENSE-CREDIT | 2024-10-20T09:27:02.584189Z | 2024-10-20T09:27:02.584189Z | {"metadata":{"invoice":"B123HD82H", "Vendor": "McDonald's"}} |

  Scenario Outline: Create DEBIT transaction to a general ledger node with gl_allowed_txn_type CREDIT

    Then I map transaction to codes for customer
      | customer_profile_id | txn_code       | gl_code   | product_id   | status_code   |
      | CPid1               | <coa_txn_code> | <gl_code> | <product_id> | <status_code> |

    Then I add transactions for customer
      | financial_entry_id | metadata | coa_transaction_message_type   | status_code   | transactions                                                                                                                                                                                                                                                                                                                                                                                 |
      | financialEntry1    | {}       | <coa_transaction_message_type> | <status_code> | [{"txn_id":"Tid1","product_id":"<product_id>","txn_code":"<coa_txn_code>","customer_profile_id":"CPid1","end_customer_profile_id":"ECPid1","transaction_type":"<transaction_type>","txn_amount":<amount>,"currency": "<currency>","base_currency_rate_per_unit": <base_currency_rate_per_unit>,"source":"CASH", "booking_ts":"<booking_ts>","value_ts":"<value_ts>", "metadata":<metadata>}] |

    Then I check the General Ledger <gl_code> under Customer Book 0301 for Customer with id CPid1 to ensure the transaction with id Tid1 is successfully added

    Then I check the aggregated value at the gl node <gl_code> under Customer Book 0301 against transaction of amount <amount> and of type <transaction_type> for customer CPid1

    Examples:
      | status_code | product_id | txn_code  | coa_txn_code | transaction_type | coa_transaction_message_type | amount | currency | base_currency_rate_per_unit | gl_code        | booking_ts                  | value_ts                    | metadata                                                     |
      | 200         | P123       | CASH_TXN1 | 210002       | DEBIT            | EXTERNAL_TRANSACTION         | 100.0  | PKR      | 1.0                         | SUSPENSE-DEBIT | 2024-10-20T09:27:02.584189Z | 2024-10-20T09:27:02.584189Z | {"metadata":{"invoice":"B123HD82H", "Vendor": "McDonald's"}} |

  Scenario Outline: Create CREDIT transaction to a general ledger node with gl_cumulative_balance_type DEBIT and try to increase aggregated value of node over 0

    Then I map transaction to codes for customer
      | customer_profile_id | txn_code       | gl_code   | product_id   | status_code   |
      | CPid1               | <coa_txn_code> | <gl_code> | <product_id> | <status_code> |

    Then I add transactions for customer
      | financial_entry_id | metadata | coa_transaction_message_type   | status_code   | transactions                                                                                                                                                                                                                                                                                                                                                                                 |
      | financialEntry1    | {}       | <coa_transaction_message_type> | <status_code> | [{"txn_id":"Tid1","product_id":"<product_id>","txn_code":"<coa_txn_code>","customer_profile_id":"CPid1","end_customer_profile_id":"ECPid1","transaction_type":"<transaction_type>","txn_amount":<amount>,"currency": "<currency>","base_currency_rate_per_unit": <base_currency_rate_per_unit>,"source":"CASH", "booking_ts":"<booking_ts>","value_ts":"<value_ts>", "metadata":<metadata>}] |

    Then I check the General Ledger <suspense_gl_code> under Customer Book 0301 for Customer with id CPid1 to ensure the transaction with id Tid1 is successfully added

    Then I check the aggregated value at the gl node <suspense_gl_code> under Customer Book 0301 against transaction of amount <amount> and of type <transaction_type> for customer CPid1

    Then I check the aggregated value at the gl node <gl_code> under Customer Book 0301 against transaction of amount 0 and of type <transaction_type> for customer CPid1

    Examples:
      | status_code | product_id | txn_code  | coa_txn_code | transaction_type | coa_transaction_message_type | amount | currency | base_currency_rate_per_unit | gl_code | suspense_gl_code | booking_ts                  | value_ts                    | metadata                                                     |
      | 200         | P123       | CASH_TXN1 | 210002       | CREDIT           | EXTERNAL_TRANSACTION         | 100.0  | PKR      | 1.0                         | 040101  | SUSPENSE-CREDIT  | 2024-10-20T09:27:02.584189Z | 2024-10-20T09:27:02.584189Z | {"metadata":{"invoice":"B123HD82H", "Vendor": "McDonald's"}} |

  Scenario Outline: Create DEBIT transaction to a general ledger node with gl_cumulative_balance_type CREDIT and try to decrease aggregated value of node below 0

    Then I map transaction to codes for customer
      | customer_profile_id | txn_code       | gl_code   | product_id   | status_code   |
      | CPid1               | <coa_txn_code> | <gl_code> | <product_id> | <status_code> |

    Then I add transactions for customer
      | financial_entry_id | metadata | coa_transaction_message_type   | status_code   | transactions                                                                                                                                                                                                                                                                                                                                                                                 |
      | financialEntry1    | {}       | <coa_transaction_message_type> | <status_code> | [{"txn_id":"Tid1","product_id":"<product_id>","txn_code":"<coa_txn_code>","customer_profile_id":"CPid1","end_customer_profile_id":"ECPid1","transaction_type":"<transaction_type>","txn_amount":<amount>,"currency": "<currency>","base_currency_rate_per_unit": <base_currency_rate_per_unit>,"source":"CASH", "booking_ts":"<booking_ts>","value_ts":"<value_ts>", "metadata":<metadata>}] |

    Then I check the General Ledger <suspense_gl_code> under Customer Book 0301 for Customer with id CPid1 to ensure the transaction with id Tid1 is successfully added

    Then I check the aggregated value at the gl node <suspense_gl_code> under Customer Book 0301 against transaction of amount <amount> and of type <transaction_type> for customer CPid1

    Then I check the aggregated value at the gl node <gl_code> under Customer Book 0301 against transaction of amount 0 and of type <transaction_type> for customer CPid1

    Examples:
      | status_code | product_id | txn_code  | coa_txn_code | transaction_type | coa_transaction_message_type | amount | currency | base_currency_rate_per_unit | gl_code | suspense_gl_code | booking_ts                  | value_ts                    | metadata                                                     |
      | 200         | P123       | CASH_TXN1 | 210002       | DEBIT            | EXTERNAL_TRANSACTION         | 100.0  | PKR      | 1.0                         | 030101  | SUSPENSE-DEBIT   | 2024-10-20T09:27:02.584189Z | 2024-10-20T09:27:02.584189Z | {"metadata":{"invoice":"B123HD82H", "Vendor": "McDonald's"}} |

  Scenario Outline: Create CREDIT transaction to a general ledger beyond end booking date and ensure new aggregation book is created for the transaction

    Then I map transaction to codes for customer
      | customer_profile_id | txn_code       | gl_code   | product_id   | status_code   |
      | CPid1               | <coa_txn_code> | <gl_code> | <product_id> | <status_code> |

    Then I add transactions for customer
      | financial_entry_id | metadata | coa_transaction_message_type   | status_code   | transactions                                                                                                                                                                                                                                                                                                                                                                                                                            |
      | financialEntry1    | {}       | <coa_transaction_message_type> | <status_code> | [{"txn_id":"Tid1","product_id":"<product_id>","txn_code":"<coa_txn_code>","customer_profile_id":"CPid1","end_customer_profile_id":"ECPid1","transaction_type":"<transaction_type>","txn_amount":<amount>,"currency": "<currency>","base_currency_rate_per_unit": <base_currency_rate_per_unit>,"source":"CASH","booking_ts":"<booking_ts>","value_ts":"<value_ts>", "profile_attributes":<profile_attributes>, "metadata":<metadata> }] |

#      Then I check the General Ledger <gl_code> under Customer Book 0101 for Customer with id CPid1 to ensure the transaction with id Tid1 is successfully added
#
#      Then I check the aggregated value at the gl node <gl_code> under Customer Book 0101 against transaction of amount <amount> and of type <transaction_type> for customer CPid1

    Examples:
      | status_code | product_id | txn_code  | coa_txn_code | transaction_type | coa_transaction_message_type | amount | currency | base_currency_rate_per_unit | gl_code | profile_attributes                                                                                                 | booking_ts                  | value_ts                    | metadata                                                     |
      | 200         | P123       | CASH_TXN1 | 210002       | CREDIT           | EXTERNAL_TRANSACTION         | 100    | PKR      | 1.0                         | 030101  | [{"attribute_key":"CITY","attribute_value": "Karachi"},{"attribute_key":"BUSINESS UNIT","attribute_value": "FCC"}] | 2025-10-20T09:27:02.584189Z | 2025-10-20T09:27:02.584189Z | {"metadata":{"invoice":"B123HD82H", "Vendor": "McDonald's"}} |


  Scenario Outline: Create CREDIT transaction to a general ledger older than start booking date and ensure transaction fails

    Then I map transaction to codes for customer
      | customer_profile_id | txn_code       | gl_code   | product_id   | status_code   |
      | CPid1               | <coa_txn_code> | <gl_code> | <product_id> | <status_code> |

    Then I add transactions for customer
      | financial_entry_id | metadata | coa_transaction_message_type   | status_code   | transactions                                                                                                                                                                                                                                                                                                                                                                                                                            |
      | financialEntry1    | {}       | <coa_transaction_message_type> | <status_code> | [{"txn_id":"Tid1","product_id":"<product_id>","txn_code":"<coa_txn_code>","customer_profile_id":"CPid1","end_customer_profile_id":"ECPid1","transaction_type":"<transaction_type>","txn_amount":<amount>,"currency": "<currency>","base_currency_rate_per_unit": <base_currency_rate_per_unit>,"source":"CASH","booking_ts":"<booking_ts>","value_ts":"<value_ts>", "profile_attributes":<profile_attributes>, "metadata":<metadata> }] |

#      Then I check the General Ledger <gl_code> under Customer Book 0101 for Customer with id CPid1 to ensure the transaction with id Tid1 is successfully added
#
#      Then I check the aggregated value at the gl node <gl_code> under Customer Book 0101 against transaction of amount <amount> and of type <transaction_type> for customer CPid1

    Examples:
      | status_code | product_id | txn_code  | coa_txn_code | transaction_type | coa_transaction_message_type | amount | currency | base_currency_rate_per_unit | gl_code | profile_attributes                                                                                                 | booking_ts                  | value_ts                    | metadata                                                     |
      | 200         | P123       | CASH_TXN1 | 210002       | CREDIT           | EXTERNAL_TRANSACTION         | 100    | PKR      | 1.0                         | 030101  | [{"attribute_key":"CITY","attribute_value": "Karachi"},{"attribute_key":"BUSINESS UNIT","attribute_value": "FCC"}] | 2023-10-20T09:27:02.584189Z | 2023-10-20T09:27:02.584189Z | {"metadata":{"invoice":"B123HD82H", "Vendor": "McDonald's"}} |
