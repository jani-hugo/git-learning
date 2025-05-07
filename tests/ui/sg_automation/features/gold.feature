Feature: Gold module

  Scenario: Buy Gold
    #Given The user signups
    When User deposits amount 500
    And User purchases the Gold S$ 100
    Then Validate the Transaction record on Transactions tab on Homepage
    Then Validate the Transaction record on Cash Account Dashboard
    Then Validate the Gold on Networth Dashboard
    Then Validate the Transacion record on Gold Dashboard

    
  Scenario: Sell Gold
    When User sells gold

  

    