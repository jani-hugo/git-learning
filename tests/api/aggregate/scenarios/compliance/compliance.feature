Feature: # Compliance Scenarios
  Background: Create customer profile on Account Service
    Given I set and verify customer Cid1, customer profile CPid1 in the context
    Then I verify Customer-Profile onboarded with provider Id
      | customer_identifier | customer_profile_identifier | provider_id     |
      | Cid1                | CPid1                       | TRU-NARRATIVE   |

  Scenario Outline:  I try to verify data with invalid customer profile id

    Then I try to verify user with data
      | customer_profile_id   | provider_id   | status_code   | compliance_type |
      | <customer_profile_id> | <provider_id> | <status_code> | IDV_JOURNEY     |

    Examples:
      | customer_profile_id | provider_id     | status_code |
      | ndalwer832ruo       | TRU-NARRATIVE   | CSM_9200    |
      | ndalwer832ruo       | 890e0464        | CSM_9200    |

  Scenario Outline:  I try to verify compliance with invalid compliance type
    Then I create below End-Customer-Profile
      | customer_identifier | customer_profile_identifier | end_customer_profile_identifier | first_name   | last_name   | region   | email   | phone_number   |
      | Cid1                | CPid1                       | ECPid1                          | <first_name> | <last_name> | <region> | <email> | <phone_number> |

    Then I verify End-Customer-Profile exist with values
      | customer_profile_identifier | end_customer_profile_identifier | customer_profile_id   | first_name   | last_name   | email   | phone_number   | status |
      | CPid1                       | ECPid1                          | <customer_profile_id> | <first_name> | <last_name> | <email> | <phone_number> | ACTIVE |

    Then I try to verify user with data
      | customer_profile_identifier | end_customer_profile_identifier | provider_id   | compliance_type     | status_code   |
      | CPid1                       | ECPid1                          | <provider_id> | FAKE_COMP           | <status_code> |
      | CPid1                       | ECPid1                          | <provider_id> | IDV_COMPLIANCE      | <status_code> |

    Examples:
      | region | name       | email            | phone_number | provider_id     | first_name | last_name | region | email   | phone_number | status_code |
      | SG     | Compliance | hugo23@atlas.com | 8989548747   | TRU-NARRATIVE   | x          | y         | SG     | x@y.com | 8989548747   | CSM_9104    |

  Scenario Outline:  Using invalid end customer profile to process compliance
    Then I try to verify user with data
      | customer_profile_identifier | provider_id   | compliance_type   | end_customer_profile_id | status_code   |
      | CPid1                       | <provider_id> | <compliance_type> | 2985729835              | <status_code> |
      | CPid1                       | <provider_id> | <compliance_type> | 3452o52456              | <status_code> |

    Examples:
      | region | name       | email            | phone_number | provider_id     | region | email   | phone_number | compliance_type     | status_code |
      | SG     | Compliance | hugo23@atlas.com | 8989548747   | TRU-NARRATIVE   | SG     | x@y.com | 8989548747   | IDV_JOURNEY         | CSM_9110    |

  Scenario Outline:   Process compliance with accept status with accept as webhook
    Then I create below End-Customer-Profile
      | customer_identifier | customer_profile_identifier | end_customer_profile_identifier | first_name   | last_name   | region   | email   | phone_number   |
      | Cid1                | CPid1                       | ECPid1                          | <first_name> | <last_name> | <region> | <email> | <phone_number> |

    Then I verify End-Customer-Profile exist with values
      | customer_profile_identifier | end_customer_profile_identifier | customer_profile_id   | first_name   | last_name   | email   | phone_number   | status |
      | CPid1                       | ECPid1                          | <customer_profile_id> | <first_name> | <last_name> | <email> | <phone_number> | ACTIVE |

    Then I process compliance for the end customer
      | customer_profile_identifier | end_customer_profile_identifier | compliance_identifier | provider_id   | compliance_type   | end_customer_profile_id | status_code   |
      | CPid1                       | ECPid1                          | compId1               | <provider_id> | <compliance_type> | 2985729835              | <status_code> |

    Then I push dev webhook with status
      | customer_profile_identifier | compliance_identifier | status |
      | CPid1                       | compId1               | pass   |

    Then I fetch compliance status and verify
      | customer_profile_identifier | compliance_identifier | status   | decision |
      | CPid1                       | compId1               | COMPLETE | ACCEPT   |

    Examples:
      | region | name       | email            | phone_number | provider_id     | region | email   | phone_number | compliance_type | status_code |
      | SG     | Compliance | hugo23@atlas.com | 8989548747   | TRU-NARRATIVE   | SG     | x@y.com | 8989548747   | IDV_JOURNEY     | 200         |

  Scenario Outline:  Decline scenario of process compliance
    Then I create below End-Customer-Profile
      | customer_identifier | customer_profile_identifier | end_customer_profile_identifier | first_name   | last_name   | region   | email   | phone_number   |
      | Cid1                | CPid1                       | ECPid1                          | <first_name> | <last_name> | <region> | <email> | <phone_number> |

    Then I verify End-Customer-Profile exist with values
      | customer_profile_identifier | end_customer_profile_identifier | customer_profile_id   | first_name   | last_name   | email   | phone_number   | status |
      | CPid1                       | ECPid1                          | <customer_profile_id> | <first_name> | <last_name> | <email> | <phone_number> | ACTIVE |

    Then I process compliance for the end customer
      | customer_profile_identifier | end_customer_profile_identifier | compliance_identifier | provider_id   | compliance_type   | end_customer_profile_id | status_code   |
      | CPid1                       | ECPid1                          | compId1               | <provider_id> | <compliance_type> | 2985729835              | <status_code> |

    Then I push dev webhook with status
      | customer_profile_identifier | compliance_identifier | status |
      | CPid1                       | compId1               | fail   |

    Then I fetch compliance status and verify
      | customer_profile_identifier | compliance_identifier | status   | decision |
      | CPid1                       | compId1               | COMPLETE | DECLINE  |

    Examples:
      | region | name       | email            | phone_number | provider_id     | region | email   | phone_number | compliance_type | status_code |
      | SG     | Compliance | hugo23@atlas.com | 8989548747   | TRU-NARRATIVE   | SG     | x@y.com | 8989548747   | IDV_JOURNEY     | 200         |

  Scenario Outline:  Missing cases
    Then I create below End-Customer-Profile
      | customer_identifier | customer_profile_identifier | end_customer_profile_identifier | first_name   | last_name   | region   | email   | phone_number   |
      | Cid1                | CPid1                       | ECPid1                          | <first_name> | <last_name> | <region> | <email> | <phone_number> |

    Then I verify End-Customer-Profile exist with values
      | customer_profile_identifier | end_customer_profile_identifier | customer_profile_id   | first_name   | last_name   | email   | phone_number   | status |
      | CPid1                       | ECPid1                          | <customer_profile_id> | <first_name> | <last_name> | <email> | <phone_number> | ACTIVE |

    Then I verify compliance details
      | customer_profile_identifier | end_customer_profile_identifier | provider_id   | compliance_type   | missing_param   | status_code   |
      | CPid1                       | ECPid1                          | <provider_id> | <compliance_type> | <missing_param> | <status_code> |
#      | CPid1                       | ECPid1                          | <provider_id> | <compliance_type> | last_name     | CSM_9008    |

    Examples:
      | region | name       | missing_param | email            | phone_number | provider_id     | compliance_type     | first_name | last_name | status_code |
      | SG     | Compliance | date_of_birth | hugo23@atlas.com | 8989548747   | TRU-NARRATIVE   | IDV_JOURNEY         | csa        | abc       | CSM_9011    |
      | SG     | Compliance | first_name    | hugo23@atlas.com | 8989548747   | TRU-NARRATIVE   | IDV_JOURNEY         | xyz        | abc       | CSM_9007    |
      | SG     | Compliance | email         | hugo23@atlas.com | 8989548747   | TRU-NARRATIVE   | IDV_JOURNEY         | csa        | abc       | CSM_9010    |
      | SG     | Compliance | phone_number  | hugo23@atlas.com | 8989548747   | TRU-NARRATIVE   | IDV_JOURNEY         | csa        | abc       | CSM_9009    |

  Scenario Outline:  Missing address lines
    Then I create below End-Customer-Profile
      | customer_identifier | customer_profile_identifier | end_customer_profile_identifier | first_name   | last_name   | region   | email   | phone_number   |
      | Cid1                | CPid1                       | ECPid1                          | <first_name> | <last_name> | <region> | <email> | <phone_number> |

    Then I verify End-Customer-Profile exist with values
      | customer_profile_identifier | end_customer_profile_identifier | customer_profile_id   | first_name   | last_name   | email   | phone_number   | status |
      | CPid1                       | ECPid1                          | <customer_profile_id> | <first_name> | <last_name> | <email> | <phone_number> | ACTIVE |

    Then I verify compliance details
      | customer_profile_identifier | end_customer_profile_identifier | provider_id   | compliance_type   | missing_param   | status_code   |
      | CPid1                       | ECPid1                          | <provider_id> | <compliance_type> | <missing_param> | <status_code> |

    Examples:
      | region | name       | missing_param  | email            | phone_number | provider_id    | compliance_type     | first_name | last_name | status_code |
      | SG     | Compliance | address_line_1 | hugo23@atlas.com | 8989548747   | TRU-NARRATIVE  | IDV_JOURNEY         | xyz        | abc       | CSM_9016    |
      | SG     | Compliance | address_line_2 | hugo23@atlas.com | 8989548747   | TRU-NARRATIVE  | IDV_JOURNEY         | xyz        | abc       | CSM_9017    |
      | SG     | Compliance | city           | hugo23@atlas.com | 8989548747   | TRU-NARRATIVE  | IDV_JOURNEY         | xyz        | abc       | CSM_9018    |
      | SG     | Compliance | country_code   | hugo23@atlas.com | 8989548747   | TRU-NARRATIVE  | IDV_JOURNEY         | xyz        | abc       | CSM_9019    |
