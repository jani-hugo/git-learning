Feature: CoA service's CoA config features

  Background:
    Given I onboard Customer to Chart of Accounts
      | customer_profile_id | node_code_length | number_of_levels | base_currency | node_type     | status_code |
      | CPid1               | 3                | 2                | PKR           | CUSTOMER_BOOK | 200         |
      | CPid1               | 6                | 4                | PKR           | CUSTOMER_COA  | 200         |

    Then I set the level config for the Chart of Account Nodes for customer
      | customer_profile_id | node_type     | status_code | level_config                                                                                                                                                                                                                                                  |
      | CPid1               | CUSTOMER_BOOK | 200         | [{"level_number": 0,"child_level_prefix_length": 3,"child_level_attribute_name": "LEAD"}]                                                                                                                                                                     |
      | CPid1               | CUSTOMER_COA  | 200         | [{"level_number": 0,"child_level_prefix_length": 2,"child_level_attribute_name": ""},{"level_number": 1,"child_level_prefix_length": 2,"child_level_attribute_name": ""},{"level_number": 2,"child_level_prefix_length": 2,"child_level_attribute_name": ""}] |

    Then I create Customer Book node for customer
      | customer_profile_id | parent_cb_code | cb_attribute_value | cb_description | status_code |
      | CPid1               | 000            | Company-1          | Lead Company 1 | 200         |
      | CPid1               | 000            | Company-2          | Lead Company 2 | 200         |


    Then I create General Ledger node for customer
      | customer_profile_id | parent_gl_code | gl_name           | gl_type  | gl_description           | is_manual_entry_allowed | profile_info | status_code |
      | CPid1               | 000000         | TOTAL-ASSETS      | HEADER   | Total-Asset node         | false                   | {}           | 200         |
      | CPid1               | 000000         | TOTAL-LIABILITIES | HEADER   | Total-Liability node     | false                   | {}           | 200         |
      | CPid1               | 000000         | CASH              | HEADER   | Cash node                | false                   | {}           | 200         |
      | CPid1               | 000000         | BU-CONTROL-AC     | HEADER   | Business Control Account | false                   | {}           | 200         |
      | CPid1               | 000000         | TOTAL-DEPOSIT     | HEADER   | Total-Deposit node       | false                   | {}           | 200         |
      | CPid1               | 070000         | CURRENT-DEPOSIT   | DETAILED | Current-Deposit node     | true                    | {}           | 200         |
      | CPid1               | 070000         | SAVING-DEPOSIT    | DETAILED | Saving-Deposit node      | true                    | {}           | 200         |


  Scenario Outline: Deposit Cash in Customer-1 Current Deposit AC and deposit Cash in Customer-2 Current Deposit AC

    # Map transaction codes
    Then I map transaction to codes for customer
      | customer_profile_id | txn_code                 | gl_code | product_id   | status_code   |
      | CPid1               | CASH_TXN_CURRENT_DEPOSIT | 070100  | <product_id> | <status_code> |
      | CPid1               | CASH_TXN_SAVINGS_DEPOSIT | 070200  | <product_id> | <status_code> |

    # Deposit Cash in Customer-1 Current Deposit AC
    Then I add transactions for customer
      | financial_entry_id | metadata | status_code   | transactions                                                                                                                                                                                                                                                                                                                                               |
      | financialEntry1    | {}       | <status_code> | [{"txn_id":"Tid1","product_id":"<product_id>","txn_code":"CASH_TXN_CURRENT_DEPOSIT","customer_profile_id":"CPid1","end_customer_profile_id":"ECPid1","transaction_type":"CREDIT","txn_amount":<amount>,"currency": "<currency>","base_currency_rate_per_unit": <base_currency_rate_per_unit>,"source":"CASH","profile_attributes":<profile_attribute_1> }] |

    Then I check the General Ledger 070100 under Customer Book 001 for Customer with id CPid1 to ensure the transaction with id Tid1 is successfully added

    Then I check the aggregated value at the gl node 070100 under Customer Book 001 against transaction of amount <amount> and of type CREDIT for customer CPid1

    # Deposit Cash in Customer-2 Current Deposit AC.
    Then I add transactions for customer
      | financial_entry_id | metadata | status_code   | transactions                                                                                                                                                                                                                                                                                                                                           |
      | financialEntry1    | {}       | <status_code> | [{"txn_id":"Tid2","product_id":"<product_id>","txn_code":"CASH_TXN_CURRENT_DEPOSIT","customer_profile_id":"CPid1","end_customer_profile_id":"ECPid2","transaction_type":"CREDIT","txn_amount":<amount>,"currency": "<currency>","base_currency_rate_per_unit": <base_currency_rate_per_unit>,"source":"","profile_attributes":<profile_attribute_2> }] |

    Then I check the General Ledger 070100 under Customer Book 002 for Customer with id CPid1 to ensure the transaction with id Tid2 is successfully added

    Then I check the aggregated value at the gl node 070100 under Customer Book 002 against transaction of amount <amount> and of type CREDIT for customer CPid1

    # Transfer Cash from Customer-1 Current Deposit AC to Customer-1 Saving Deposit AC.
    Then I add transactions for customer
      | financial_entry_id | metadata | status_code   | transactions                                                                                                                                                                                                                                                                                                                                        |
      | financialEntry1    | {}       | <status_code> | [{"txn_id":"Tid3","product_id":"<product_id>","txn_code":"CASH_TXN_CURRENT_DEPOSIT","customer_profile_id":"CPid1","end_customer_profile_id":"ECPid1","transaction_type":"DEBIT","txn_amount":50,"currency": "<currency>","base_currency_rate_per_unit": <base_currency_rate_per_unit>,"source":"CASH","profile_attributes":<profile_attribute_1> }] |

    Then I check the General Ledger 070100 under Customer Book 001 for Customer with id CPid1 to ensure the transaction with id Tid3 is successfully added

    Then I check the aggregated value at the gl node 070100 under Customer Book 001 against transaction of amount 50 and of type DEBIT for customer CPid1

    Then I add transactions for customer
      | financial_entry_id | metadata | status_code   | transactions                                                                                                                                                                                                                                                                                                                                         |
      | financialEntry1    | {}       | <status_code> | [{"txn_id":"Tid4","product_id":"<product_id>","txn_code":"CASH_TXN_SAVINGS_DEPOSIT","customer_profile_id":"CPid1","end_customer_profile_id":"ECPid1","transaction_type":"CREDIT","txn_amount":50,"currency": "<currency>","base_currency_rate_per_unit": <base_currency_rate_per_unit>,"source":"CASH","profile_attributes":<profile_attribute_1> }] |

    Then I check the General Ledger 070200 under Customer Book 001 for Customer with id CPid1 to ensure the transaction with id Tid4 is successfully added

    Then I check the aggregated value at the gl node 070200 under Customer Book 001 against transaction of amount 50 and of type CREDIT for customer CPid1

    # Transfer Cash from Customer-2 Current Deposit AC to Customer-2 Saving Deposit AC.
    Then I add transactions for customer
      | financial_entry_id | metadata | status_code   | transactions                                                                                                                                                                                                                                                                                                                                     |
      | financialEntry1    | {}       | <status_code> | [{"txn_id":"Tid5","product_id":"<product_id>","txn_code":"CASH_TXN_CURRENT_DEPOSIT","customer_profile_id":"CPid1","end_customer_profile_id":"ECPid1","transaction_type":"DEBIT","txn_amount":50,"currency": "<currency>","base_currency_rate_per_unit": <base_currency_rate_per_unit>,"source":"CASH","profile_attributes":<profile_attribute_2> }] |

    Then I check the General Ledger 070100 under Customer Book 002 for Customer with id CPid1 to ensure the transaction with id Tid5 is successfully added

    Then I check the aggregated value at the gl node 070100 under Customer Book 002 against transaction of amount 50 and of type DEBIT for customer CPid1

    Then I add transactions for customer
      | financial_entry_id | metadata | status_code   | transactions                                                                                                                                                                                                                                                                                                                                         |
      | financialEntry1    | {}       | <status_code> | [{"txn_id":"Tid6","product_id":"<product_id>","txn_code":"CASH_TXN_SAVINGS_DEPOSIT","customer_profile_id":"CPid1","end_customer_profile_id":"ECPid1","transaction_type":"CREDIT","txn_amount":50,"currency": "<currency>","base_currency_rate_per_unit": <base_currency_rate_per_unit>,"source":"CASH","profile_attributes":<profile_attribute_2> }] |

    Then I check the General Ledger 070200 under Customer Book 002 for Customer with id CPid1 to ensure the transaction with id Tid6 is successfully added

    Then I check the aggregated value at the gl node 070200 under Customer Book 002 against transaction of amount 50 and of type CREDIT for customer CPid1

    # Transfer Cash from Customer-1 Saving Deposit AC to Customer-2 Saving Deposit AC. Inter-Company Accounting should be generated
    Then I add transactions for customer
      | financial_entry_id | metadata | status_code   | transactions                                                                                                                                                                                                                                                                                                                                        |
      | financialEntry1    | {}       | <status_code> | [{"txn_id":"Tid7","product_id":"<product_id>","txn_code":"CASH_TXN_SAVINGS_DEPOSIT","customer_profile_id":"CPid1","end_customer_profile_id":"ECPid1","transaction_type":"DEBIT","txn_amount":50,"currency": "<currency>","base_currency_rate_per_unit": <base_currency_rate_per_unit>,"source":"CASH","profile_attributes":<profile_attribute_1> }] |

    Then I check the General Ledger 070200 under Customer Book 001 for Customer with id CPid1 to ensure the transaction with id Tid7 is successfully added

    Then I check the aggregated value at the gl node 070200 under Customer Book 001 against transaction of amount 50 and of type DEBIT for customer CPid1

    Then I add transactions for customer
      | financial_entry_id | metadata | status_code   | transactions                                                                                                                                                                                                                                                                                                                                         |
      | financialEntry1    | {}       | <status_code> | [{"txn_id":"Tid8","product_id":"<product_id>","txn_code":"CASH_TXN_SAVINGS_DEPOSIT","customer_profile_id":"CPid1","end_customer_profile_id":"ECPid1","transaction_type":"CREDIT","txn_amount":50,"currency": "<currency>","base_currency_rate_per_unit": <base_currency_rate_per_unit>,"source":"CASH","profile_attributes":<profile_attribute_2> }] |

    Then I check the General Ledger 070200 under Customer Book 002 for Customer with id CPid1 to ensure the transaction with id Tid8 is successfully added

    Then I check the aggregated value at the gl node 070200 under Customer Book 002 against transaction of amount 50 and of type CREDIT for customer CPid1

    # Transfer Cash from Customer-2 Saving Deposit AC to Customer-1 Current Deposit AC
    Then I add transactions for customer
      | financial_entry_id | metadata | status_code   | transactions                                                                                                                                                                                                                                                                                                                                        |
      | financialEntry1    | {}       | <status_code> | [{"txn_id":"Tid9","product_id":"<product_id>","txn_code":"CASH_TXN_SAVINGS_DEPOSIT","customer_profile_id":"CPid1","end_customer_profile_id":"ECPid1","transaction_type":"DEBIT","txn_amount":50,"currency": "<currency>","base_currency_rate_per_unit": <base_currency_rate_per_unit>,"source":"CASH","profile_attributes":<profile_attribute_2> }] |

    Then I check the General Ledger 070200 under Customer Book 002 for Customer with id CPid1 to ensure the transaction with id Tid9 is successfully added

    Then I check the aggregated value at the gl node 070200 under Customer Book 002 against transaction of amount 50 and of type DEBIT for customer CPid1

    Then I add transactions for customer
      | financial_entry_id | metadata | status_code   | transactions                                                                                                                                                                                                                                                                                                                                          |
      | financialEntry1    | {}       | <status_code> | [{"txn_id":"Tid10","product_id":"<product_id>","txn_code":"CASH_TXN_CURRENT_DEPOSIT","customer_profile_id":"CPid1","end_customer_profile_id":"ECPid1","transaction_type":"CREDIT","txn_amount":50,"currency": "<currency>","base_currency_rate_per_unit": <base_currency_rate_per_unit>,"source":"CASH","profile_attributes":<profile_attribute_1> }] |

    Then I check the General Ledger 070100 under Customer Book 001 for Customer with id CPid1 to ensure the transaction with id Tid10 is successfully added

    Then I check the aggregated value at the gl node 070100 under Customer Book 001 against transaction of amount 50 and of type CREDIT for customer CPid1

    # Customer-1 pay bills from Customer-1 Current Deposit AC, since no vendor GL is opened, therefore second leg of the accounting entry will go Suspense GL Account
    Then I add transactions for customer
      | financial_entry_id | metadata | status_code   | transactions                                                                                                                                                                                                                                                                                                                                          |
      | financialEntry1    | {}       | <status_code> | [{"txn_id":"Tid11","product_id":"<product_id>","txn_code":"CASH_TXN_CURRENT_DEPOSIT","customer_profile_id":"CPid1","end_customer_profile_id":"ECPid1","transaction_type":"DEBIT","txn_amount":100,"currency": "<currency>","base_currency_rate_per_unit": <base_currency_rate_per_unit>,"source":"CASH","profile_attributes":<profile_attribute_1> }] |

    Then I check the General Ledger 070100 under Customer Book 001 for Customer with id CPid1 to ensure the transaction with id Tid11 is successfully added

    Then I check the aggregated value at the gl node 070100 under Customer Book 001 against transaction of amount 100 and of type DEBIT for customer CPid1

    Then I add transactions for customer
      | financial_entry_id | metadata | status_code   | transactions                                                                                                                                                                                                                                                                                                                                        |
      | financialEntry1    | {}       | <status_code> | [{"txn_id":"Tid12","product_id":"<product_id>","txn_code":"CASH_TXN_BILL_PAYMENT","customer_profile_id":"CPid1","end_customer_profile_id":"ECPid1","transaction_type":"CREDIT","txn_amount":100,"currency": "<currency>","base_currency_rate_per_unit": <base_currency_rate_per_unit>,"source":"CASH","profile_attributes":<profile_attribute_1> }] |

    Then I check the General Ledger SUSPEND-CREDIT under Customer Book 001 for Customer with id CPid1 to ensure the transaction with id Tid12 is successfully added

    Then I check the aggregated value at the gl node SUSPEND-CREDIT under Customer Book 001 against transaction of amount 100 and of type CREDIT for customer CPid1


    # Customer-2 pay bills from Customer-2 Saving Deposit AC, since no vendor GL is opened, therefore second leg of the accounting entry will go Suspense GL Account
    Then I add transactions for customer
      | financial_entry_id | metadata | status_code   | transactions                                                                                                                                                                                                                                                                                                                                         |
      | financialEntry1    | {}       | <status_code> | [{"txn_id":"Tid13","product_id":"<product_id>","txn_code":"CASH_TXN_SAVINGS_DEPOSIT","customer_profile_id":"CPid1","end_customer_profile_id":"ECPid1","transaction_type":"DEBIT","txn_amount":10,"currency": "<currency>","base_currency_rate_per_unit": <base_currency_rate_per_unit>,"source":"CASH","profile_attributes":<profile_attribute_2> }] |

    Then I check the General Ledger 070200 under Customer Book 002 for Customer with id CPid1 to ensure the transaction with id Tid13 is successfully added

    Then I check the aggregated value at the gl node 070200 under Customer Book 002 against transaction of amount 10 and of type DEBIT for customer CPid1

    Then I add transactions for customer
      | financial_entry_id | metadata | status_code   | transactions                                                                                                                                                                                                                                                                                                                                       |
      | financialEntry1    | {}       | <status_code> | [{"txn_id":"Tid14","product_id":"<product_id>","txn_code":"CASH_TXN_BILL_PAYMENT","customer_profile_id":"CPid1","end_customer_profile_id":"ECPid1","transaction_type":"CREDIT","txn_amount":10,"currency": "<currency>","base_currency_rate_per_unit": <base_currency_rate_per_unit>,"source":"CASH","profile_attributes":<profile_attribute_2> }] |

    Then I check the General Ledger SUSPEND-CREDIT under Customer Book 002 for Customer with id CPid1 to ensure the transaction with id Tid14 is successfully added

    Then I check the aggregated value at the gl node SUSPEND-CREDIT under Customer Book 002 against transaction of amount 10 and of type CREDIT for customer CPid1


    Examples:
      | status_code | product_id | txn_code   | transaction_type | amount | currency | base_currency_rate_per_unit | gl_code | profile_attribute_1                                       | profile_attribute_2                                       |
      | 200         | CURRENT_AC | CASH_TXN_1 | CREDIT           | 200    | PKR      | 1.0                         | 030101  | [{"attribute_key":"LEAD","attribute_value": "Company-1"}] | [{"attribute_key":"LEAD","attribute_value": "Company-2"}] |

