Feature: Buy Gold module

Background: I setup for gold buy
  Given I signup
  
Scenario:I verify gold dashboard with zero balance in the cash account and after adding the amount
  
  Given I move to the gold dashboard
  Then I validate buy and sell buttons 
  When I move to the homescreen
  When I add 500 to the cash account
  Then I validate buy and sell buttons state


Scenario: I buy gold with amount greater than cash account balance and validate Insufficient balance text
 When I add 200 to the cash account
 Given I move to the gold dashboard
 When I click on the buy button
 Then I validate static text on the buy screen
 When I enter amount greater than cash account balance 
 Then I validate Insufficient balance text on the screen
 Then I validate cancel and preview buttons on the screen
 When I click on the preview button
 When I click on the buy button
 Then I validate successfully bought message on the screen
  

Scenario: I buy gold with partial amount available in the cash account
 When I add 200 to the cash account
 Given I move to the gold dashboard
 When I click on the buy button
 When I enter amount 50 and click on preview
 When I click on the buy button
 Then I validate successfully bought message on the screen
 

Scenario: I buy gold in grams with amount greater than cash account balance and validate Insufficient balance text
 When I add 200 to the cash account
 Given I move to the gold dashboard
 When I click on the buy button
 When I switch to grams and enter 10 grams
 Then I validate Insufficient balance text on the screen
 When I click on the preview button
 When I click on the buy button
 Then I validate successfully bought message on the screen


Scenario: I buy gold in grams with partial amount available in the cash account
 When I add 200 to the cash account
 Given I move to the gold dashboard
 When I click on the buy button
 When I switch to grams and enter 1 grams
 When I click on the preview button
 When I click on the buy button
 Then I validate successfully bought message on the screen


Scenario: I validate pre defined amount buttons on the buy screen
 When I add 750 to the cash account
 Given I move to the gold dashboard
 When I click on the buy button
 When I select 50 pre defined button and validate input field
 When I select 100 pre defined button and validate input field
 When I select 500 pre defined button and validate input field
 
Scenario: I buy gold 
 Given I move to the gold dashboard
 When I add 350 to the cash account
 When I buy gold of 500