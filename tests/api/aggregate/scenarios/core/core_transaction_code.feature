Feature: Testing the transaction code service

    Scenario Outline: Trying to create a transaction code with valid parameter lengths
        When I try to create a transaction code
            | customer_profile_id   | requestDTO   | status_code   |
            | <customer_profile_id> | <requestDTO> | <status_code> |

        Examples:
            | customer_profile_id | requestDTO                                                                                               | status_code |
            | ndalwer832ruo       | {"transaction_code":"123456789","coa_transaction_code":"123456","description":"transaction description"} | 200         |

    Scenario Outline: Trying to create a transaction code with shorter coa_transaction_code

        When I try to create a transaction code
            | customer_profile_id   | requestDTO   | status_code   |
            | <customer_profile_id> | <requestDTO> | <status_code> |

        Examples:
            | customer_profile_id | requestDTO                                                                                             | status_code |
            | ndalwer832ruo       | {"transaction_code":"123456789","coa_transaction_code":"1234","description":"transaction description"} | 200         |

    Scenario Outline: Trying to create a transaction code with shorter transaction_code

        When I try to create a transaction code
            | customer_profile_id   | requestDTO   | status_code   |
            | <customer_profile_id> | <requestDTO> | <status_code> |

        Examples:
            | customer_profile_id | requestDTO                                                                                          | status_code |
            | ndalwer832ruo       | {"transaction_code":"1234","coa_transaction_code":"123456","description":"transaction description"} | 200         |

    Scenario Outline: Trying to create a transaction code with shorter transaction_code and coa_transaction_code

        When I try to create a transaction code
            | customer_profile_id   | requestDTO   | status_code   |
            | <customer_profile_id> | <requestDTO> | <status_code> |

        Examples:
            | customer_profile_id | requestDTO                                                                                        | status_code |
            | ndalwer832ruo       | {"transaction_code":"1234","coa_transaction_code":"1234","description":"transaction description"} | 200         |

    Scenario Outline: Trying to create a transaction code with longer coa_transaction_code

        When I try to create a transaction code
            | customer_profile_id   | requestDTO   | status_code   |
            | <customer_profile_id> | <requestDTO> | <status_code> |

        Examples:
            | customer_profile_id | requestDTO                                                                                                  | status_code |
            | ndalwer832ruo       | {"transaction_code":"123456789","coa_transaction_code":"123456789","description":"transaction description"} | E9400       |

    Scenario Outline: Trying to create a transaction code with longer transaction_code

        When I try to create a transaction code
            | customer_profile_id   | requestDTO   | status_code   |
            | <customer_profile_id> | <requestDTO> | <status_code> |

        Examples:
            | customer_profile_id | requestDTO                                                                                                  | status_code |
            | ndalwer832ruo       | {"transaction_code":"123456789123","coa_transaction_code":"123456","description":"transaction description"} | E9400       |

    Scenario Outline: Trying to create a transaction code with longer transaction_code and coa_transaction_code
        When I try to create a transaction code
            | customer_profile_id   | requestDTO   | status_code   |
            | <customer_profile_id> | <requestDTO> | <status_code> |

        Examples:
            | customer_profile_id | requestDTO                                                                                                     | status_code |
            | ndalwer832ruo       | {"transaction_code":"123456789123","coa_transaction_code":"123456789","description":"transaction description"} | E9400       |

    Scenario Outline: Trying to create a transaction with no description
        When I try to create a transaction code
            | customer_profile_id   | requestDTO   | status_code   |
            | <customer_profile_id> | <requestDTO> | <status_code> |

        Examples:
            | customer_profile_id | requestDTO                                                                        | status_code |
            | ndalwer832ruo       | {"transaction_code":"123456789","coa_transaction_code":"123456","description":""} | 200         |

    Scenario Outline: Trying to create a transaction with invalid transaction_code
        When I try to create a transaction code
            | customer_profile_id   | requestDTO   | status_code   |
            | <customer_profile_id> | <requestDTO> | <status_code> |

        Examples:
            | customer_profile_id | requestDTO                                                                                                  | status_code |
            | ndalwer832ruo       | {"transaction_code":"hh_123456","coa_transaction_code":"123456","description":"transaction description"}    | E9400       |
            | ndalwer832ruo       | {"transaction_code":"hH_123456","coa_transaction_code":"123456","description":"transaction description"}    | E9400       |
            | ndalwer832ruo       | {"transaction_code":"Hh_123456","coa_transaction_code":"123456","description":"transaction description"}    | E9400       |
            | ndalwer832ruo       | {"transaction_code":"HH_123456","coa_transaction_code":"123456","description":"transaction description"}    | E9400       |
            | ndalwer832ruo       | {"transaction_code":"HH_123456789","coa_transaction_code":"123456","description":"transaction description"} | E9400       |

    Scenario Outline: Trying to create a transaction with invalid coa_transaction_code

        When I try to create a transaction code
            | customer_profile_id   | requestDTO   | status_code   |
            | <customer_profile_id> | <requestDTO> | <status_code> |

        Examples:
            | customer_profile_id | requestDTO                                                                                                  | status_code |
            | ndalwer832ruo       | {"transaction_code":"123456789","coa_transaction_code":"hh_123","description":"transaction description"}    | E9400       |
            | ndalwer832ruo       | {"transaction_code":"123456789","coa_transaction_code":"hH_123","description":"transaction description"}    | E9400       |
            | ndalwer832ruo       | {"transaction_code":"123456789","coa_transaction_code":"Hh_123","description":"transaction description"}    | E9400       |
            | ndalwer832ruo       | {"transaction_code":"123456789","coa_transaction_code":"HH_123","description":"transaction description"}    | E9400       |
            | ndalwer832ruo       | {"transaction_code":"123456789","coa_transaction_code":"HH_123456","description":"transaction description"} | E9400       |

    Scenario Outline: Trying to fetch a transaction
        When I try to fetch all transaction codes
            | customer_profile_id   | status_code   |
            | <customer_profile_id> | <status_code> |

        Examples:
            | customer_profile_id | status_code |
            | ndalwer832ruo       | 200         |
            | ndalwer832ru1       | 200         |

    Scenario Outline: Trying to Fetch CoA Transaction Codes
        When I try to fetch CoA Transaction Codes
            | customer_profile_id   | txn_code   | status_code   |
            | <customer_profile_id> | <txn_code> | <status_code> |

        Examples:
            | customer_profile_id | txn_code | status_code |
            | ndalwer832ruo       | 1234     | 200         |
            | ndalwer832roo       | 1235     | COSM_9405   |

    Scenario Outline: Trying to get a paginated response from the database
        When I try to map fetch a paginated response from the database
            | customer_profile_id   | status_code   |
            | <customer_profile_id> | <status_code> |

        Examples:
            | customer_profile_id | status_code |
            | ndalwer832ruo       | 200         |

    Scenario Outline: Trying to update CoA transaction Code
        When I try to update CoA transaction Code
            | customer_profile_id   | txnCode   | transactionCodeDTO   | status_code   |
            | <customer_profile_id> | <txnCode> | <transactionCodeDTO> | <status_code> |

        Examples:
            | customer_profile_id | txnCode | transactionCodeDTO                                                   | status_code |
            | ndalwer832ruo       | 1234    | {"coa_transaction_code": "654321", "description": "New Description"} | 200         |
            | ndalwer832ruo       | 1234    | {"coa_transaction_code": "654123"}                                   | 200         |
            | ndalwer832ruo       | 1234    | {"description": "New New Description"}                                   | 200         |
            | ndalwer832ruo       | 1234    | {}                                                                   | 200         |
