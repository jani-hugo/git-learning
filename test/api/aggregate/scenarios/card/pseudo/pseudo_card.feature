Feature: Card Service Card test scenarios for Pseudo Provider

  Background: Setup Customer Profile and End-Customer Profile on Card Service and Pseudo Provider
#    Given I create Customer, Customer Profile, Onboard to account, banking, compliance, card

    Given I set and verify customer CID1, customer profile CPID1 in the context

    Then I create below End-Customer-Profile
      | customer_profile_identifier | end_customer_profile_identifier | first_name | last_name | region | email         | phone_number   |
      | CPID1                       | ECPID1                          | John       | Snow      | SG     | john@snow.com | +63 1234567890 |

    Then I verify End-Customer-Profile exist with values
      | customer_profile_identifier | end_customer_profile_identifier | first_name | last_name | email         | phone_number   | status |
      | CPID1                       | ECPID1                          | John       | Snow      | john@snow.com | +63 1234567890 | ACTIVE |

    Given I onboard CustomerProfile CPID1 with customerId CID1 on cash service on below providers and expect status 200
      | provider_name   |
      | Pseudo Provider |

    Then I wait until max time to verify CustomerProfile CPID1 onboard status as ONBOARD_SUCCESS

    When I onboard EndCustomerProfile ECPID1 of CustomerProfile CPID1 on cash service on below providers and expect status 200
      | provider_name   |
      | Pseudo Provider |

    Then I wait until max time to verify EndCustomerProfile ECPID1 of CustomerProfile CPID1 onboard status as ONBOARD_SUCCESS

    Then I onboard below Customer-Profile onto Compliance Provider Id
      | customer_identifier | customer_profile_identifier | provider_id     | status_code |
      | CID1                | CPID1                       | TRU-NARRATIVE   | 200         |

    Then I verify Customer-Profile onboarded with provider Id
      | customer_identifier | customer_profile_identifier | provider_id     |
      | CID1                | CPID1                       | TRU-NARRATIVE   |

    Then I process compliance for the end customer
      | customer_profile_identifier | end_customer_profile_identifier | compliance_identifier | provider_id     | compliance_type | end_customer_profile_id | status_code |
      | CPID1                       | ECPID1                          | COMPID1               | TRU-NARRATIVE   | IDV_JOURNEY     | 2985729835              | 200         |

    Then I push dev webhook with status
      | customer_profile_identifier | compliance_identifier | status |
      | CPID1                       | COMPID1               | pass   |

    Then I fetch compliance status and verify
      | customer_profile_identifier | compliance_identifier | status   | decision |
      | CPID1                       | COMPID1               | COMPLETE | ACCEPT   |

    Given I onboard End-Customer Profile ECPID1 of Customer Profile CPID1 on fund provider CASH and on card service on below providers
      | provider_name |
      | Pseudo        |

    Then I wait until max time to verify End-Customer Profile ECPID1 onboard status on card service provider Pseudo as ONBOARD_SUCCESS

    Given I create account for EndCustomerProfile with id ECPID1 for CustomerProfile CPID1 with bank account type as Current with provider Pseudo Provider and expect the header status 200
      | identifier | currency | country | in_trust | is_overdraft_allowed | on_behalf_of | metadata                    |
      | BankAccId  | PKR      | PAK     | false    | true                 | CUSTOMER     | {"key": "IntegrationTest1"} |

    Then I wait until max time to verify the bank account BankAccId status as ACCOUNT_CREATED with provider Pseudo Provider for customerProfileId CPID1

    Given I create below Card Account
      | card_account_identifier | end_customer_profile_identifier | provider_name | bank_account_identifier | customer_address                                                                                                                                                                                                                                      |
      | CardAccId1              | ECPID1                          | Pseudo        | BankAccId               | {"address_line_1":"Atlas Consolidated Labs", "address_line_2":"Mukunda Towers", "address_line_3":"Indian Airlines Colony", "address_line_4":"Begumpet", "city":"Hyderabad", "state":"", "country": "", "country_code": "SGP", "local_code": "800003"} |

    Then I wait until max time to verify Card Account CardAccId1 onboard status on card service provider Pseudo as CARD_ACCOUNT_CREATED

  Scenario Outline: Issuing Card for the Card Account on Pseudo provider
    Given I issue Card for Card Account
      | card_identifier   | card_account_identifier | card_type   | emboss_name   | three_d_secure_config                                                  | delivery_address                                                                                                                                                                                                                                      |
      | <card_identifier> | CardAccId1              | <card_type> | <emboss_name> | {"security_question": "What is your name?", "security_answer": "John"} | {"address_line_1":"Atlas Consolidated Labs", "address_line_2":"Mukunda Towers", "address_line_3":"Indian Airlines Colony", "address_line_4":"Begumpet", "city":"Hyderabad", "state":"", "country": "", "country_code": "SGP", "local_code": "800003"} |

    Then I wait until max time to verify Card <card_identifier> status on card service provider Pseudo as INACTIVE

    Examples:
      | card_identifier | card_type | emboss_name |
      | CardId1         | PHYSICAL  | Zoro        |

  Scenario Outline: Activating Card on Pseudo provider
    Given I issue Card for Card Account
      | card_identifier   | card_account_identifier | card_type   | emboss_name   | three_d_secure_config                                                  | delivery_address                                                                                                                                                                                                                                      |
      | <card_identifier> | CardAccId1              | <card_type> | <emboss_name> | {"security_question": "What is your name?", "security_answer": "John"} | {"address_line_1":"Atlas Consolidated Labs", "address_line_2":"Mukunda Towers", "address_line_3":"Indian Airlines Colony", "address_line_4":"Begumpet", "city":"Hyderabad", "state":"", "country": "", "country_code": "SGP", "local_code": "800003"} |

    Then I wait until max time to verify Card <card_identifier> status on card service provider Pseudo as INACTIVE

    Then I activate the Card
      | card_identifier   |
      | <card_identifier> |

    Then I validate card status by fetching card with id <card_identifier> and checking card status as ACTIVE

    Examples:
      | card_identifier | card_type | emboss_name |
      | CardId1         | PHYSICAL  | Zoro        |

#    Valid Permutations
  Scenario Outline: Active -> Block -> Unblock -> Block -> Disable on Pseudo provider
    Given I issue Card for Card Account
      | card_identifier   | card_account_identifier | card_type   | emboss_name   | three_d_secure_config                                                  | delivery_address                                                                                                                                                                                                                                      |
      | <card_identifier> | CardAccId1              | <card_type> | <emboss_name> | {"security_question": "What is your name?", "security_answer": "John"} | {"address_line_1":"Atlas Consolidated Labs", "address_line_2":"Mukunda Towers", "address_line_3":"Indian Airlines Colony", "address_line_4":"Begumpet", "city":"Hyderabad", "state":"", "country": "", "country_code": "SGP", "local_code": "800003"} |

    Then I wait until max time to verify Card <card_identifier> status on card service provider Pseudo as INACTIVE

    Then I activate the Card
      | card_identifier   |
      | <card_identifier> |

    Then I validate card status by fetching card with id <card_identifier> and checking card status as ACTIVE

    Then I update the status of Card with id <card_identifier>
      | card_status |
      | BLOCK       |
      | UNBLOCK     |
      | BLOCK       |
      | DISABLE     |

    Examples:
      | card_identifier | card_type | emboss_name |
      | CardId1         | PHYSICAL  | Zoro        |

  Scenario Outline: Active -> Block -> Unblock -> Disable on Pseudo provider
    Given I issue Card for Card Account
      | card_identifier   | card_account_identifier | card_type   | emboss_name   | three_d_secure_config                                                  | delivery_address                                                                                                                                                                                                                                      |
      | <card_identifier> | CardAccId1              | <card_type> | <emboss_name> | {"security_question": "What is your name?", "security_answer": "John"} | {"address_line_1":"Atlas Consolidated Labs", "address_line_2":"Mukunda Towers", "address_line_3":"Indian Airlines Colony", "address_line_4":"Begumpet", "city":"Hyderabad", "state":"", "country": "", "country_code": "SGP", "local_code": "800003"} |

    Then I wait until max time to verify Card <card_identifier> status on card service provider Pseudo as INACTIVE

    Then I activate the Card
      | card_identifier   |
      | <card_identifier> |

    Then I validate card status by fetching card with id <card_identifier> and checking card status as ACTIVE

    Then I update the status of Card with id <card_identifier>
      | card_status |
      | BLOCK       |
      | UNBLOCK     |
      | DISABLE     |

    Then I validate card status by fetching card with id <card_identifier> and checking card status as DISABLED

    Examples:
      | card_identifier | card_type | emboss_name |
      | CardId1         | PHYSICAL  | Zoro        |

  Scenario Outline: Inactive to Disabled on Pseudo provider
    Given I issue Card for Card Account
      | card_identifier   | card_account_identifier | card_type   | emboss_name   | three_d_secure_config                                                  | delivery_address                                                                                                                                                                                                                                      |
      | <card_identifier> | CardAccId1              | <card_type> | <emboss_name> | {"security_question": "What is your name?", "security_answer": "John"} | {"address_line_1":"Atlas Consolidated Labs", "address_line_2":"Mukunda Towers", "address_line_3":"Indian Airlines Colony", "address_line_4":"Begumpet", "city":"Hyderabad", "state":"", "country": "", "country_code": "SGP", "local_code": "800003"} |

    Then I wait until max time to verify Card <card_identifier> status on card service provider Pseudo as INACTIVE

    Then I update the status of Card with id <card_identifier>
      | card_status |
      | DISABLE     |

    Then I validate card status by fetching card with id <card_identifier> and checking card status as DISABLED

    Examples:
      | card_identifier | card_type | emboss_name |
      | CardId1         | PHYSICAL  | Zoro        |

#    Invalid permutations
  Scenario Outline: Updating Card Status from Disabled on Pseudo provider
    Given I issue Card for Card Account
      | card_identifier   | card_account_identifier | card_type   | emboss_name   | three_d_secure_config                                                  | delivery_address                                                                                                                                                                                                                                      |
      | <card_identifier> | CardAccId1              | <card_type> | <emboss_name> | {"security_question": "What is your name?", "security_answer": "John"} | {"address_line_1":"Atlas Consolidated Labs", "address_line_2":"Mukunda Towers", "address_line_3":"Indian Airlines Colony", "address_line_4":"Begumpet", "city":"Hyderabad", "state":"", "country": "", "country_code": "SGP", "local_code": "800003"} |

    Then I wait until max time to verify Card <card_identifier> status on card service provider Pseudo as INACTIVE

    Then I activate the Card
      | card_identifier   |
      | <card_identifier> |

    Then I validate card status by fetching card with id <card_identifier> and checking card status as ACTIVE

    Then I update the status of Card with id <card_identifier>
      | card_status |
      | DISABLE     |

    Then I validate card status by fetching card with id <card_identifier> and checking card status as DISABLED

    Then To test the invalid scenario, I update the status of Card with id <card_identifier>
      | card_status |
      | BLOCK       |
      | UNBLOCK     |

    Then I validate card status by fetching card with id <card_identifier> and checking card status as DISABLED

    Examples:
      | card_identifier | card_type | emboss_name |
      | CardId1         | PHYSICAL  | Zoro        |

  Scenario Outline: Activating the Blocked Card on Pseudo provider
    Given I issue Card for Card Account
      | card_identifier   | card_account_identifier | card_type   | emboss_name   | three_d_secure_config                                                  | delivery_address                                                                                                                                                                                                                                      |
      | <card_identifier> | CardAccId1              | <card_type> | <emboss_name> | {"security_question": "What is your name?", "security_answer": "John"} | {"address_line_1":"Atlas Consolidated Labs", "address_line_2":"Mukunda Towers", "address_line_3":"Indian Airlines Colony", "address_line_4":"Begumpet", "city":"Hyderabad", "state":"", "country": "", "country_code": "SGP", "local_code": "800003"} |

    Then I wait until max time to verify Card <card_identifier> status on card service provider Pseudo as INACTIVE

    Then I activate the Card
      | card_identifier   |
      | <card_identifier> |

    Then I validate card status by fetching card with id <card_identifier> and checking card status as ACTIVE

    Then I update the status of Card with id <card_identifier>
      | card_status |
      | BLOCK       |

    Then I validate card status by fetching card with id <card_identifier> and checking card status as BLOCKED

    Then I activate the Card to test the invalid scenario
      | card_identifier   |
      | <card_identifier> |

    Then I validate card status by fetching card with id <card_identifier> and checking card status as BLOCKED

    Examples:
      | card_identifier | card_type | emboss_name |
      | CardId1         | PHYSICAL  | Zoro        |

  Scenario Outline: Activating the disabled Card on Pseudo provider
    Given I issue Card for Card Account
      | card_identifier   | card_account_identifier | card_type   | emboss_name   | three_d_secure_config                                                  | delivery_address                                                                                                                                                                                                                                      |
      | <card_identifier> | CardAccId1              | <card_type> | <emboss_name> | {"security_question": "What is your name?", "security_answer": "John"} | {"address_line_1":"Atlas Consolidated Labs", "address_line_2":"Mukunda Towers", "address_line_3":"Indian Airlines Colony", "address_line_4":"Begumpet", "city":"Hyderabad", "state":"", "country": "", "country_code": "SGP", "local_code": "800003"} |

    Then I wait until max time to verify Card <card_identifier> status on card service provider Pseudo as INACTIVE

    Then I activate the Card
      | card_identifier   |
      | <card_identifier> |

    Then I validate card status by fetching card with id <card_identifier> and checking card status as ACTIVE

    Then I update the status of Card with id <card_identifier>
      | card_status |
      | DISABLE     |

    Then I validate card status by fetching card with id <card_identifier> and checking card status as DISABLED

    Then I activate the Card to test the invalid scenario
      | card_identifier   |
      | <card_identifier> |

    Then I validate card status by fetching card with id <card_identifier> and checking card status as DISABLED

    Examples:
      | card_identifier | card_type | emboss_name |
      | CardId1         | PHYSICAL  | Zoro        |

  Scenario Outline: Inactive to Blocked on Pseudo provider
    Given I issue Card for Card Account
      | card_identifier   | card_account_identifier | card_type   | emboss_name   | three_d_secure_config                                                  | delivery_address                                                                                                                                                                                                                                      |
      | <card_identifier> | CardAccId1              | <card_type> | <emboss_name> | {"security_question": "What is your name?", "security_answer": "John"} | {"address_line_1":"Atlas Consolidated Labs", "address_line_2":"Mukunda Towers", "address_line_3":"Indian Airlines Colony", "address_line_4":"Begumpet", "city":"Hyderabad", "state":"", "country": "", "country_code": "SGP", "local_code": "800003"} |

    Then I wait until max time to verify Card <card_identifier> status on card service provider Pseudo as INACTIVE

    Then To test the invalid scenario, I update the status of Card with id <card_identifier>
      | card_status |
      | BLOCK       |

    Then I validate card status by fetching card with id <card_identifier> and checking card status as INACTIVE

    Examples:
      | card_identifier | card_type | emboss_name |
      | CardId1         | PHYSICAL  | Zoro        |

  Scenario Outline: Get Secure Card Detail from Pseudo provider
    Given I issue Card for Card Account
      | card_identifier   | card_account_identifier | card_type   | emboss_name   | three_d_secure_config                                                  | delivery_address                                                                                                                                                                                                                                      |
      | <card_identifier> | CardAccId1              | <card_type> | <emboss_name> | {"security_question": "What is your name?", "security_answer": "John"} | {"address_line_1":"Atlas Consolidated Labs", "address_line_2":"Mukunda Towers", "address_line_3":"Indian Airlines Colony", "address_line_4":"Begumpet", "city":"Hyderabad", "state":"", "country": "", "country_code": "SGP", "local_code": "800003"} |

    Then I wait until max time to verify Card <card_identifier> status on card service provider Pseudo as INACTIVE

    Given I get Secure Card Detail with id <card_identifier>

    Examples:
      | card_identifier | card_type | emboss_name |
      | CardId1         | PHYSICAL  | Zoro        |

