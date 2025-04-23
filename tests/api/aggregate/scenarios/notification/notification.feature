Feature: Notification Service Notification Scenarios

  Scenario Outline: Sending notification with valid callback endpoint
    Given I create below Customer
      | customer_identifier | name | date                 |
      | Cid1                | hugo | 2022-12-28T00:00:00Z |

    Then I create below Customer-Profile
      | customer_identifier | customer_profile_identifier | region | name | email          | phone_number |
      | Cid1                | CPid1                       | SG     | hugo | hugo@atlas.com | 8989548747   |

    Then I create Callback for the Customer-Profile
      | customer_identifier | customer_profile_identifier | callback_identifier | endpoint | type   | auth_token   |
      | Cid1                | CPid1                       | callId1             |          | <type> | <auth_token> |

    Then I validate Callback is set with values
      | customer_identifier | customer_profile_identifier | callback_identifier | endpoint | type   | auth_token   |
      | Cid1                | CPid1                       | callId1             |          | <type> | <auth_token> |

    Then I push dummy notification
      | customer_profile_identifier |
      | CPid1                       |

    Then I fetch notifications for customer profile id and check status
      | customer_profile_identifier | status | wait_time |
      | CPid1                       | SENT   | 15        |

    Examples:
      | type | auth_token |
      | REST | token1     |

  Scenario Outline: Sending notification with invalid callback endpoint
    Given I create below Customer
      | customer_identifier | name | date                 |
      | Cid1                | hugo | 2022-12-28T00:00:00Z |

    Then I create below Customer-Profile
      | customer_identifier | customer_profile_identifier | region | name | email          | phone_number |
      | Cid1                | CPid1                       | SG     | hugo | hugo@atlas.com | 8989548747   |

    Then I set Callback for the Customer-Profile
      | customer_identifier | customer_profile_identifier | callback_identifier | endpoint   | type   | auth_token   |
      | Cid1                | CPid1                       | callId1             | <endpoint> | <type> | <auth_token> |

    Then I verify Callback is set with values
      | customer_identifier | customer_profile_identifier | callback_identifier | endpoint   | type   | auth_token   |
      | Cid1                | CPid1                       | callId1             | <endpoint> | <type> | <auth_token> |

    Then I push dummy notification
      | customer_profile_identifier |
      | CPid1                       |

    Then I fetch notifications for customer profile id and check status
      | customer_profile_identifier | status                | wait_time |
      | CPid1                       | MAX_ATTEMPTS_BREACHED | 300       |

    Examples:
      | endpoint               | type | auth_token |
      | http://localhost:8080/ | REST | token1     |

  Scenario: Sending notification without callback configuration
    Given I create below Customer
      | customer_identifier | name | date                 |
      | Cid1                | hugo | 2022-12-28T00:00:00Z |

    Then I create below Customer-Profile
      | customer_identifier | customer_profile_identifier | region | name | email          | phone_number |
      | Cid1                | CPid1                       | SG     | hugo | hugo@atlas.com | 8989548747   |

    Then I push dummy notification
      | customer_profile_identifier |
      | CPid1                       |

    Then I fetch notifications for customer profile id and check status
      | customer_profile_identifier | status                  | wait_time |
      | CPid1                       | CONFIGURATION_NOT_FOUND | 15        |
