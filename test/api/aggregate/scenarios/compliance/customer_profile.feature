Feature: Compliance Customer Profile Scenarios
  Background: Create customer profile on Account Service
    Given I set and verify customer Cid1, customer profile CPid1 in the context
  Scenario Outline: Create Customer-Profile and verify it's created successfully

    Then I verify Customer-Profile onboarded with provider Id
      | customer_identifier | customer_profile_identifier | provider_id   |
      | Cid1                | CPid1                       | <provider_id> |

    Examples:
      | region | name | email              | phone_number | provider_id      |
      | SG     | hugo | rubocop@atlas.com | 8989487497    | TRU-NARRATIVE    |

  Scenario Outline: Create Customer-Profile with invalid data and verify it's response

    Then I onboard below Customer-Profile onto Compliance Provider Id
      | customer_identifier | customer_profile_identifier | provider_id   | status_code |
      | Cid1                | CPid1                       | <provider_id> | CSM_9100       |

    Examples:
      | region | name | email          | phone_number | provider_id |
      | SG     | hugo | hugo@atlas.com | 8989548747   | 63298672    |

#
  Scenario Outline: Create and delete Customer-Profile in compliance
    Given I create below Customer
      | customer_identifier | name | date       |
      | Cid1                | hugo | 01-01-2001 |

    Then I create below Customer-Profile
      | customer_identifier | customer_profile_identifier | region   | name   | email   | phone_number   |
      | Cid1                | CPid1                       | <region> | <name> | <email> | <phone_number> |

    Then I verify Customer-Profile exist with values
      | customer_identifier | customer_profile_identifier | customer_profile_id   | api_key   | customer_id   | region   | name   | email   | phone_number   | status |
      | Cid1                | CPid1                       | <customer_profile_id> | <api_key> | <customer_id> | <region> | <name> | <email> | <phone_number> | ACTIVE |

    Then I onboard below Customer-Profile onto Compliance Provider Id
      | customer_identifier | customer_profile_identifier | provider_id   | status_code |
      | Cid1                | CPid1                       | <provider_id> | 200         |

    Then I verify Customer-Profile onboarded with provider Id
      | customer_identifier | customer_profile_identifier | provider_id   |
      | Cid1                | CPid1                       | <provider_id> |

    Then I delete the provider for Customer-Profile
      | customer_profile_identifier | provider_id   |
      | CPid1                       | <provider_id> |

    Then I verify Customer-Profile doesn't exist for provider id
      | customer_profile_identifier | provider_id   |
      | CPid1                       | <provider_id> |

    Examples:
      | region | name | email          | phone_number | provider_id     |
      | SG     | hugo | hugo@atlas.com | 8989548747   | TRU-NARRATIVE   |
