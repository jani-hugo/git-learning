Feature: CMS service's Fund Transaction scenarios

  Background: Set Customer Profile
    Given I set and verify customer Cid1, customer profile CPid1 in the context

  Scenario Outline: Onboard Customer Profile

    Given I onboard HUGOHUB Customer Profile for CMS with <payment_provider> and verify onboard status as ONBOARD_SUCCESS

    Then I onboard Customer Profile to CMS with <payment_provider> and verify onboard status as ONBOARD_SUCCESS

    Then I deposit funds into the following funding account for Customer Profile
      | account_type | amount | currency   | txn_mode   |
      | FLOAT        | 5000   | <currency> | <txn_mode> |

#    Then I initiate fund withdraw for Credit-Account and check for transaction status to be TRANSACTION_PENDING
#      | account_type | total_amount  | currency | receiver_details                                                                                                                                                              |
#      | FLOAT       | 10            | SGD      | {"account_details":{"account_number":"123","account_holder":"123","bank_name":"DBS","country":"SGP","currency":"SGD","code_details":{"sg_code_details":{"swift_bic":"abc"}}}} |

    Examples:
      | payment_provider | txn_mode | currency |
      | DBS              | FAST     | SGD      |

