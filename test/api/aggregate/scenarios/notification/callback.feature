Feature: Notification service's Customer Profile Callback scenarios

  Scenario Outline: configure Callback endpoint for a customer and verify it's set successfully
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

    Examples:
      | endpoint              | type | auth_token |
      | www.test-endpoint.com | REST | token1     |


  Scenario Outline: Callback endpoint fails for invalid type
    Given I set and verify customer Cid1, customer profile CPid1 in the context

    Then I try to set Callback for the Customer-Profile and fail
      | customer_identifier | customer_profile_identifier | callback_identifier | endpoint   | type   | auth_token   |
      | Cid1                | CPid1                       | callId1             | <endpoint> | <type> | <auth_token> |

    Examples:
      | endpoint              | type | auth_token |
      | www.test-endpoint.com | SOAP | token1     |

#
#  Scenario Outline: update Callback endpoint for a customer and verify it's updated successfully
#    Given I set and verify customer Cid1, customer profile CPid1 in the context
#
#    Then I update Callback with new endpoint
#      | customer_identifier | customer_profile_identifier | callback_identifier | endpoint                      | type   | auth_token   |
#      | Cid1                | CPid1                       | callId2             | www.updated-test-endpoint.com | <type> | <auth_token> |
#
#    Then I verify Callback is set with values
#      | customer_identifier | customer_profile_identifier | callback_identifier | endpoint                      | type   | auth_token   |
#      | Cid1                | CPid1                       | callId2             | www.updated-test-endpoint.com | <type> | <auth_token> |
#
#    Then I update Callback with new endpoint
#      | customer_identifier | customer_profile_identifier | callback_identifier | endpoint                                                                           | type   | auth_token   |
#      | Cid1                | CPid1                       | callId2             | http://devpcommon-LB-429359018.us-east-1.elb.amazonaws.com/app/v2/callback/hugohub | <type> | <auth_token> |
#
#    Then I verify Callback is set with values
#      | customer_identifier | customer_profile_identifier | callback_identifier | endpoint                                                                           | type   | auth_token   |
#      | Cid1                | CPid1                       | callId2             | http://devpcommon-LB-429359018.us-east-1.elb.amazonaws.com/app/v2/callback/hugohub | <type> | <auth_token> |
#
#    Examples:
#      | type | auth_token |
#      | REST | token1     |
