Feature: Payment Service CustomerProfileOnboarding Scenario for provider DBS

  Scenario Outline: Onboard and verify Customer Profile on Payment service from CASH_SERVICE on behalf of CUSTOMER with response status_code as 200

    Given In Payment Service, I set and verify customer <customer_id>, customer profile <customer_profile_id> on below providers from CASH_SERVICE on behalf of CUSTOMER and expect status <status_code> in the context
      | provider_name |
      | DBS Bank Ltd  |

    Then I wait until max time to verify the master account <master_account_id> with master account status <master_account_status> for the customer profile <customer_profile_id> on behalf of <on_behalf_of> status as <onboard_status> with provider DBS Bank Ltd

    Examples:
      | customer_id | customer_profile_id | master_account_id | status_code | onboard_status  | master_account_status  | on_behalf_of |
      | PSCID1      | PSCPID1             | MASAccId          | 200         | ONBOARD_SUCCESS | MASTER_ACCOUNT_CREATED | CUSTOMER     |

  Scenario Outline: Onboard Customer Profile on Payment service from CASH_SERVICE on behalf of CUSTOMER with response status_code as 200 ---- 2nd Customer Profile

    Given I onboard CustomerProfile <customer_profile_id> with customerId <customer_id> on payment service from CASH_SERVICE on behalf of <on_behalf_of> on below providers and expect status <status_code> for different customer
      | provider_name |
      | DBS Bank Ltd  |

    Then I wait until max time to verify the master account <master_account_id> with master account status <master_account_status> for the customer profile <customer_profile_id> on behalf of <on_behalf_of> status as <onboard_status> with provider DBS Bank Ltd

    Examples:
      | customer_id | customer_profile_id | master_account_id | status_code | onboard_status  | master_account_status  | on_behalf_of |
      | PSCID2      | PSCPID2             | MASAccId          | 200         | ONBOARD_SUCCESS | MASTER_ACCOUNT_CREATED | CUSTOMER     |


  Scenario Outline: Onboard and verify Customer Profile on Payment service from CASH_SERVICE on behalf of CASH_SERVICE with response status_code as E9400

    Given I create below Customer
      | customer_identifier | name | date                 |
      | PSCID1              | hugo | 2022-12-28T00:00:00Z |

    Then I create below Customer-Profile
      | customer_identifier | customer_profile_identifier | region | name  | email          | phone_number |
      | PSCID1              | PSCPID1                     | SG     | Stark | hugo@atlas.com | 8989548747   |

    Then I verify Customer-Profile exist with values
      | customer_identifier | customer_profile_identifier | region | name  | email          | phone_number | status |
      | PSCID1              | PSCPID1                     | SG     | Stark | hugo@atlas.com | 8989548747   | ACTIVE |

    Given I onboard CustomerProfile <customer_profile_identifier> with customerId <customer_identifier> on payment service from CASH_SERVICE on behalf of <on_behalf_of> on below providers and expect status <status_code>
      | provider_name |
      | DBS Bank Ltd  |

    Examples:
      | customer_identifier | customer_profile_identifier | status_code | on_behalf_of |
      | PSCID1              | PSCPID1                     | PTM_1302    | CASH_SERVICE |

  Scenario Outline: Onboard and verify Customer Profile on Payment service from different services except CASH_SERVICE on behalf of CASH_SERVICE with response status_code as E9400

    Given I create below Customer
      | customer_identifier | name | date                 |
      | PSCID1              | hugo | 2022-12-28T00:00:00Z |

    Then I create below Customer-Profile
      | customer_identifier | customer_profile_identifier | region | name  | email          | phone_number |
      | PSCID1              | PSCPID1                     | SG     | Stark | hugo@atlas.com | 8989548747   |

    Then I verify Customer-Profile exist with values
      | customer_identifier | customer_profile_identifier | region | name  | email          | phone_number | status |
      | PSCID1              | PSCPID1                     | SG     | Stark | hugo@atlas.com | 8989548747   | ACTIVE |

    Given I onboard CustomerProfile <customer_profile_identifier> with customerId <customer_identifier> on payment service from <request_origin> on behalf of <on_behalf_of> on below providers and expect status <status_code>
      | provider_name |
      | DBS Bank Ltd  |

    Examples:
      | customer_identifier | customer_profile_identifier | status_code | request_origin | on_behalf_of |
      | PSCID1              | PSCPID1                     | PTM_1303    | CARD           | CUSTOMER     |
      | PSCID1              | PSCPID1                     | PTM_1303    | INVESTMENT     | CUSTOMER     |


  Scenario Outline: Onboard Customer Profile on Payment service from CASH_SERVICE on behalf of CASH_SERVICE onto wrong provider with response status_code as E9400

    Given I create below Customer
      | customer_identifier | name | date                 |
      | PSCID1              | hugo | 2022-12-28T00:00:00Z |

    Then I create below Customer-Profile
      | customer_identifier | customer_profile_identifier | region | name  | email          | phone_number |
      | PSCID1              | PSCPID1                     | SG     | Stark | hugo@atlas.com | 8989548747   |

    Then I verify Customer-Profile exist with values
      | customer_identifier | customer_profile_identifier | region | name  | email          | phone_number | status |
      | PSCID1              | PSCPID1                     | SG     | Stark | hugo@atlas.com | 8989548747   | ACTIVE |

    Given I onboard CustomerProfile <customer_profile_identifier> with customerId <customer_identifier> on payment service from CASH_SERVICE on behalf of <on_behalf_of> on below wrong providers
      | provider_name |
      | HSBC Bank Ltd |

    Examples:
      | customer_identifier | customer_profile_identifier | on_behalf_of |
      | PSCID1              | PSCPID1                     | CASH_SERVICE |

  Scenario Outline: Onboarding the same customer again and validate whether masterAccountId is same or not

    Given I create below Customer
      | customer_identifier | name | date                 |
      | PSCID1              | hugo | 2022-12-28T00:00:00Z |

    Then I create below Customer-Profile
      | customer_identifier | customer_profile_identifier | region | name  | email          | phone_number |
      | PSCID1              | PSCPID1                     | SG     | Stark | hugo@atlas.com | 8989548747   |

    Then I verify Customer-Profile exist with values
      | customer_identifier | customer_profile_identifier | region | name  | email          | phone_number | status |
      | PSCID1              | PSCPID1                     | SG     | Stark | hugo@atlas.com | 8989548747   | ACTIVE |

    Given I onboard CustomerProfile <customer_profile_identifier> with customerId <customer_identifier> on payment service from CASH_SERVICE on behalf of <on_behalf_of> on below providers and expect status <status_code>
      | provider_name |
      | DBS Bank Ltd  |

    Then I wait until max time to verify the master account MASAccId1 with master account status <master_account_status> for the customer profile <customer_profile_identifier> on behalf of <on_behalf_of> status as <onboard_status> with provider DBS Bank Ltd

    Then I retrieve CustomerProfile <customer_profile_identifier> from CASH_SERVICE onboard status as <onboard_status> onto Payment Service

    Given I onboard CustomerProfile <customer_profile_identifier> with customerId <customer_identifier> on payment service from CASH_SERVICE on behalf of <on_behalf_of> on below providers and expect status <status_code>
      | provider_name |
      | DBS Bank Ltd  |

    Then I wait until max time to verify the master account MASAccId2 with master account status <master_account_status> for the customer profile <customer_profile_identifier> on behalf of <on_behalf_of> status as <onboard_status> with provider DBS Bank Ltd

    Then I retrieve CustomerProfile <customer_profile_identifier> from CASH_SERVICE onboard status as <onboard_status> onto Payment Service

    Then I check if we are getting same master_account_id for two requests for MASAccId1 PSCPID1 and MASAccId2 PSCPID1

    Examples:
      | customer_identifier | customer_profile_identifier | status_code | onboard_status  | master_account_status  | on_behalf_of |
      | PSCID1              | PSCPID1                     | 200         | ONBOARD_SUCCESS | MASTER_ACCOUNT_CREATED | CUSTOMER     |

