Feature: Payment Service EndCustomerProfileOnboarding Scenarios for provider DBS

  Background: Setup customer and end-customer profile on Payment Service
    Given In Payment Service, I set and verify customer PSCID1, customer profile PSCPID1 on below providers from CASH_SERVICE on behalf of CUSTOMER and expect status 200 in the context
      | provider_name |
      | DBS Bank Ltd  |

    Then I create below End-Customer-Profile
      | customer_identifier | customer_profile_identifier | end_customer_profile_identifier | first_name | last_name | region | email            | phone_number |
      | PSCID1              | PSCPID1                     | ECPID1                          | Kiyotaka   | Ayanokōji | SG     | KA@gmail.com.com | 00000000     |

    Then I verify End-Customer-Profile exist with values
      | customer_profile_identifier | end_customer_profile_identifier | first_name | last_name | email            | phone_number | status |
      | PSCPID1                     | ECPID1                          | Kiyotaka   | Ayanokōji | KA@gmail.com.com | 00000000     | ACTIVE |

  Scenario Outline: Onboard and verify EndCustomerProfile on Payment service from CASH_SERVICE on behalf of CUSTOMER with response status_code as 200

    Then I onboard EndCustomerProfile <end_customer_profile_id> of CustomerProfile <customer_profile_id> on payment service on below providers from <request_origin> on behalf of <on_behalf_of> and expect status <end_customer_status_code>
      | provider_name |
      | DBS Bank Ltd  |

    Then I wait until max time to verify EndCustomerProfile <end_customer_profile_id> of CustomerProfile <customer_profile_id> from <request_origin> onboard status as <onboard_status> onto Payment Service

    Examples:
      | customer_profile_id | end_customer_profile_id | request_origin | on_behalf_of | end_customer_status_code | onboard_status  |
      | PSCPID1             | ECPID1                  | CASH_SERVICE   | CUSTOMER     | 200                      | ONBOARD_SUCCESS |

  Scenario Outline: Onboard and verify EndCustomerProfile on Payment service from CASH_SERVICE on behalf of CASH_SERVICE with response status_code as E9400

    Then I onboard EndCustomerProfile <end_customer_profile_id> of CustomerProfile <customer_profile_id> on payment service on below providers from <request_origin> on behalf of <on_behalf_of> and expect status <status_code>
      | provider_name |
      | DBS Bank Ltd  |

    Examples:
      | customer_profile_id | end_customer_profile_id | status_code | request_origin | on_behalf_of |
      | PSCPID1             | ECPID1                  | PTM_1302    | CASH_SERVICE   | CASH_SERVICE |

  Scenario Outline: Onboard and verify EndCustomerProfile on Payment service from different services except CASH_SERVICE on behalf of CASH_SERVICE with response status_code as E9400

    Then I onboard EndCustomerProfile <end_customer_profile_id> of CustomerProfile <customer_profile_id> on payment service on below providers from <request_origin> on behalf of <on_behalf_of> and expect status <status_code>
      | provider_name |
      | DBS Bank Ltd  |

    Examples:
      | customer_profile_id | end_customer_profile_id | status_code | request_origin | on_behalf_of |
      | PSCPID1             | ECPID1                  | PTM_1303    | CARD           | CUSTOMER     |
      | PSCPID1             | ECPID1                  | PTM_1303    | INVESTMENT     | CUSTOMER     |
