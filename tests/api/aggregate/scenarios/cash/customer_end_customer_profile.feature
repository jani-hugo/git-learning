Feature: Cash service Customer Profile, End-Customer Profile and Account scenarios

  Background: Setup customer and end-customer profile on cash
    Given I set and verify customer BCID1, customer profile BCPID1 in the context

    Then I create below End-Customer-Profile
      | customer_identifier | customer_profile_identifier | end_customer_profile_identifier | first_name | last_name | region | email   | phone_number |
      | BCID1               | BCPID1                      | ECPID1                          | cash       | service   | SG     | x@y.com | 00000000     |

    Then I verify End-Customer-Profile exist with values
      | customer_profile_identifier | end_customer_profile_identifier | customer_profile_id   | first_name | last_name | email   | phone_number | status |
      | BCPID1                      | ECPID1                          | <customer_profile_id> | cash       | service   | x@y.com | 00000000     | ACTIVE |


  Scenario Outline: Onboard and verify Customer Profile on cash service with response status_code as 200
    Given I onboard CustomerProfile <customer_profile_id> with customerId <customer_id> on cash service on below providers and expect status <status_code>
      | provider_name |
      | DBS Bank Ltd  |

    Then I wait until max time to verify CustomerProfile <customer_profile_id> onboard status as <onboard_status>

    Examples:
      | customer_id | customer_profile_id | status_code | onboard_status  |
      | BCID1       | BCPID1              | 200         | ONBOARD_SUCCESS |

  Scenario Outline: Onboard and verify EndCustomerProfile on cash service with response status_code as 200
    Given I onboard CustomerProfile <customer_profile_id> with customerId <customer_id> on cash service on below providers and expect status <status_code>
      | provider_name |
      | DBS Bank Ltd  |

    Then I wait until max time to verify CustomerProfile <customer_profile_id> onboard status as ONBOARD_SUCCESS

    When I onboard EndCustomerProfile <end_customer_profile_id> of CustomerProfile <customer_profile_id> on cash service on below providers and expect status <end_customer_status_code>
      | provider_name |
      | DBS Bank Ltd  |

    Then I wait until max time to verify EndCustomerProfile <end_customer_profile_id> of CustomerProfile <customer_profile_id> onboard status as <onboard_status>

    Examples:
      | customer_id | customer_profile_id | end_customer_profile_id | status_code | end_customer_status_code | onboard_status  |
      | BCID1       | BCPID1              | ECPID1                  | 200         | 200                      | ONBOARD_SUCCESS |

