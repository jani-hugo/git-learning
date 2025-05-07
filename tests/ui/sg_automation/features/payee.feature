Feature: PAYEE

  Background: Initialize context for  Allow notification screen

  Scenario: Adding Payee with invalid name
      Given I verify that i reached the Add New Payee Screen
      Then I check all the text elements on the Add New Payee screen
      Given I enter Payee Name, Select Bank and Account Number
        | payee_name | bank_name   | account_no |
        | br2o    | State Bank of India | 2344323  |
        #To add an external bank, enter the bank name as 'Trust Bank Singapore Limited'
        #To add an internal bank, enter the bank name as 'DBS Bank Ltd'
      Then I verify the payee br2o details and validate error messages for invalid inputs
      Then I verify the confirm button is disabled

  Scenario: Adding Payee without selecting bank name
    Given I verify that i reached the Add New Payee Screen
    Then I check all the text elements on the Add New Payee screen
    Given I enter Payee Name, Select Bank and Account Number
      | payee_name | bank_name | account_no |
      | devil        |           | 234423    |
    Then I verify the payee devil details and validate error messages for invalid inputs
    Then I verify the confirm button is disabled

  Scenario: Adding Payee without giving account number
    Given I verify that i reached the Add New Payee Screen
    Then I check all the text elements on the Add New Payee screen
    Given I enter Payee Name, Select Bank and Account Number
      | payee_name | bank_name    | account_no |
      | devil      | State Bank of India |            |
    Then I verify the payee devil details and validate error messages for invalid inputs
    Then I verify the confirm button is disabled

  Scenario: Adding Payee without giving payee name
    Given I verify that i reached the Add New Payee Screen
    Then I check all the text elements on the Add New Payee screen
    Given I enter Payee Name, Select Bank and Account Number
      | payee_name | bank_name    | account_no |
      |            | State Bank of India | 4323232323 |
    Then I verify the payee devil details and validate error messages for invalid inputs
    Then I verify the confirm button is disabled

  Scenario: Adding Payee with invalid OTP
    Given I verify that i reached the Add New Payee Screen
    Then I check all the text elements on the Add New Payee screen
    Given I enter Payee Name, Select Bank and Account Number
      | payee_name | bank_name    | account_no |
      |     devil       | DBS Bank Ltd | 4323232323 |
    Then I verify the payee devil details and validate error messages for invalid inputs
    Then I verify the confirm button is enabled
    Then I click on the confirm button
    Then I verify that i reached the OTP Screen
    Then I enter the OTP 123436 to add payee
    Then I check for then error message for incorrect OTP while adding payee
    Then I wait for the 15-second timer to reach 0 and verify the presence of the Resend OTP button

  Scenario: Adding Payee: Leave the name/Account number/bank name field empty
    Given I verify that i reached the Add New Payee Screen
    Then I check all the text elements on the Add New Payee screen
    Given I enter Payee Name, Select Bank and Account Number
      | payee_name | bank_name    | account_no   |
      |            | State Bank of India | 132334903364 |
      #To add an external bank, enter the bank name as 'Trust Bank Singapore Limited'
      #To add an internal bank, enter the bank name as 'DBS Bank Ltd'
    Then I verify the payee None details and validate error messages for invalid inputs
    Then I verify the confirm button is disabled
    Then I tap on the back button on the Add New Payee screen

    Then I tap on the Add Payee button on the cash account dashboard
    Given I verify that i reached the Add New Payee Screen
    Then I check all the text elements on the Add New Payee screen
    Given I enter Payee Name, Select Bank and Account Number
      | payee_name | bank_name | account_no   |
      | ram        |           | 132334903364 |
    Then I verify the payee ram details and validate error messages for invalid inputs
    Then I verify the confirm button is disabled
    Then I tap on the back button on the Add New Payee screen

    Then I tap on the Add Payee button on the cash account dashboard
    Given I verify that i reached the Add New Payee Screen
    Then I check all the text elements on the Add New Payee screen
    Given I enter Payee Name, Select Bank and Account Number
      | payee_name | bank_name    | account_no |
      | ram1       | State Bank of India |            |
    Then I verify the payee ram1 details and validate error messages for invalid inputs
    Then I verify the confirm button is disabled
    Then I tap on the back button on the Add New Payee screen

  Scenario: Adding payee with valid user details and with invalid OTP
    Given I verify that i reached the Add New Payee Screen
    Then I check all the text elements on the Add New Payee screen
    Given I enter Payee Name, Select Bank and Account Number
      | payee_name | bank_name    | account_no |
      | ram        | DBS Bank Ltd | 6334903364 |
      #To add an external bank, enter the bank name as 'Trust Bank Singapore Limited'
      #To add an internal bank, enter the bank name as 'DBS Bank Ltd'
    Then I click on the Favourite icon on the Add New Payee screen
    Then I verify the payee ram details and validate error messages for invalid inputs
    Then I verify the confirm button is enabled
    Then I click on the confirm button
    Then I verify that i reached the OTP Screen
    Then I enter the OTP 123455 to add payee
    Then I check for then error message for incorrect OTP while adding payee
    Then I wait for the 15-second timer to reach 0 and verify the presence of the Resend OTP button
    Then I tap on the back button on the Payee OTP screen
    Given I verify that i reached the Add New Payee Screen
    Then I click on the confirm button
    Then I verify that i reached the OTP Screen
    Then I enter the OTP 123455 to add payee


  Scenario: Adding Payee with valid OTP and verifying cash account dashboard and all payees screen
    Given I verify that i reached the Add New Payee Screen
    Then I check all the text elements on the Add New Payee screen
    Given I enter Payee Name, Select Bank and Account Number
      | payee_name | bank_name    | account_no    |
      | Jane      | DBS Bank Ltd | 9418237341424 |
      #To add an external bank, enter the bank name as 'Trust Bank Singapore Limited'
      #To add an internal bank, enter the bank name as 'DBS Bank Ltd'
    Then I verify the payee Jane details and validate error messages for invalid inputs
    Then I verify the confirm button is enabled
    Then I click on the confirm button
    Then I verify that i reached the OTP Screen
    Then I enter the OTP 123456 to add payee
    Then I verify the payee's addition by checking the payee Jane account number on the auto-directed individual screen after OTP entry
    Then I check the text elements and buttons on the Jane payee individual screen
    Then I tap on the back button on the payee individual screen
    Then I check if the newly added payee Jane is appearing on the cash account dashboard
    Then I tap on the See All text link on the Cash account dashboard
    Then I verify that i reached the All Payees Screen
    Then I check if the newly added payee Jane is appearing on the All payees screen


  Scenario: Adding Payee and Editing payee details
    Given I verify that i reached the Add New Payee Screen
    Then I check all the text elements on the Add New Payee screen
    Given I enter Payee Name, Select Bank and Account Number
      | payee_name | bank_name    | account_no  |
      | Mark      | DBS Bank Ltd | 23131523124 |
    Then I verify the payee Mark details and validate error messages for invalid inputs
    Then I verify the confirm button is enabled
    Then I click on the confirm button
    Then I verify that i reached the OTP Screen
    Then I enter the OTP 123456 to add payee
    Then I verify the payee's addition by checking the payee Mark account number on the auto-directed individual screen after OTP entry
    Then I check the text elements and buttons on the Mark payee individual screen
    Then I tap on the back button on the payee individual screen
    Then I verify that i reached the All Payees Screen
    Then I check if the newly added payee Mark is appearing on the All payees screen
    Then I tap on the payee name Mark on the All payees screen
    Then I click on the payee name Mark on the Payee individual screen
    Then I check the payee details on the Mark payee edit screen
    Then I click on the Favourite icon
    Then I verify the save button is enabled
    Then I tap on the save button on the payee edit screen
    Then I verify if i auto-directed to the payee Mark individual screen
    Then I tap on the back button on the payee individual screen
    Then I verify that i reached the All Payees Screen
    Then I tap on the back button on the All Payees screen


  Scenario: Add internal and external payee, edit payee, make a transaction and delete a payee
    Given I verify that i reached the Add New Payee Screen
    Then I check all the text elements on the Add New Payee screen
    Given I enter Payee Name, Select Bank and Account Number
      | payee_name | bank_name    | account_no    |
      | Jane      | DBS Bank Ltd | 941823734142 |
    Then I verify the payee Jane details and validate error messages for invalid inputs
    Then I verify the confirm button is enabled
    Then I click on the confirm button
    Then I verify that i reached the OTP Screen
    Then I enter the OTP 123456 to add payee
    Then I verify the payee's addition by checking the payee Jane account number on the auto-directed individual screen after OTP entry
    Then I check the text elements and buttons on the Jane payee individual screen
    Then I tap on the back button on the payee individual screen
    Then I scroll up the Cash Account Dashboard screen
    Then I check if the newly added payee Jane is appearing on the cash account dashboard
    Then I tap on the See All text link on the Cash account dashboard
    Then I verify that i reached the All Payees Screen
    Then I check if the newly added payee Jane is appearing on the All payees screen

    Then I tap on the Add Payee button on the All payees screen
    Given I enter Payee Name, Select Bank and Account Number
      | payee_name | bank_name    | account_no  |
      | Mark       | State Bank of India | 2313152312 |
    Then I verify the payee Mark details and validate error messages for invalid inputs
    Then I verify the confirm button is enabled
    Then I click on the confirm button
    Then I verify that i reached the OTP Screen
    Then I enter the OTP 123456 to add payee
    Then I verify the payee's addition by checking the payee Mark account number on the auto-directed individual screen after OTP entry
    Then I check the text elements and buttons on the Mark payee individual screen
    Then I tap on the back button on the payee individual screen
    Then I verify that i reached the All Payees Screen
    Then I check if the newly added payee Mark is appearing on the All payees screen
    Then I tap on the payee name Mark on the All payees screen
    Then I click on the payee name Mark on the Payee individual screen
    Then I check the payee details on the Mark payee edit screen
    Then I click on the Favourite icon
    Then I verify the save button is enabled
    Then I tap on the save button on the payee edit screen
    Then I verify if i auto-directed to the payee Mark individual screen

    Then I tap on the New Payment button on the payee individual screen
    Then I verify if i directed to the new payment screen
    Then I check the text elements and buttons on the Mark payee New Payment screen
    Then I enter the payee amount 1 on the New Payment screen
    Then I select the reason chip Insurance on the Mark payee New payment screen
    Then I verify the Preview button is enabled on the New Payment screen
    Then I tap on the Preview button on the New Payment screen
    Then I check the text elements and buttons on the Mark payee New Payment Preview screen
    Then I verify the Pay button is enabled on the New Payment Preview screen
    Then I tap on the Pay button on the New Payment Preview screen
    Then I verify if i auto-directed to the payee Mark individual screen
    Then I verify the latest transaction record appears for the Mark payee
    Then I click on the latest transaction record appears for the Mark payee
    Then I verify the latest transaction is settled for the Mark payee
    Then I tap on the back button on the Transaction details screen
    Then I verify if i auto-directed to the payee Mark individual screen
    Then I click on the payee name Mark on the Payee individual screen
    Then I check the payee details on the Mark payee edit screen
    Then I tap on the three vertical dots on the payee edit screen
    Then I click on the delete payee option
    Then I verify if confirmation pop-up appeared
    Then I click on the Yes button on the confirmation pop-up appeared
    Then I verify that i reached the All Payees Screen


  Scenario: END TO END
    Given I verify that i reached the Add New Payee Screen
    Then I check all the text elements on the Add New Payee screen

#    sc1 invalid payee name
    Given I enter Payee Name, Select Bank and Account Number
      | payee_name | bank_name   | account_no |
      | br2o    | State Bank of India | 2344323  |
    Then I verify the payee br2o details and validate error messages for invalid inputs
    Then I verify the confirm button is disabled
    Then I tap on the back button on the Add New Payee screen

#    sc2 dont select bank name
     Then I tap on the Add Payee button on the cash account dashboard
     Given I verify that i reached the Add New Payee Screen
     Given I enter Payee Name, Select Bank and Account Number
      | payee_name | bank_name | account_no |
      | devil        |           | 234423    |
    Then I verify the payee devil details and validate error messages for invalid inputs
    Then I verify the confirm button is disabled
    Then I tap on the back button on the Add New Payee screen

#    sc3 dont select bank account number
    Then I tap on the Add Payee button on the cash account dashboard
    Given I verify that i reached the Add New Payee Screen
    Given I enter Payee Name, Select Bank and Account Number
      | payee_name | bank_name    | account_no |
      | devil        | State Bank of India |            |
    Then I verify the payee devil details and validate error messages for invalid inputs
    Then I verify the confirm button is disabled
    Then I tap on the back button on the Add New Payee screen
#
#    sc4  dont enter payee name
    Then I tap on the Add Payee button on the cash account dashboard
    Given I verify that i reached the Add New Payee Screen
    Given I enter Payee Name, Select Bank and Account Number
      | payee_name | bank_name    | account_no |
      |            | State Bank of India | 4323232323 |
    Then I verify the payee None details and validate error messages for invalid inputs
    Then I verify the confirm button is disabled
    Then I tap on the back button on the Add New Payee screen

#    sc5 enter invalid otp and wait 15secs
    Then I tap on the Add Payee button on the cash account dashboard
    Given I verify that i reached the Add New Payee Screen
    Given I enter Payee Name, Select Bank and Account Number
      | payee_name | bank_name    | account_no |
      |     Jane       | DBS Bank Ltd | 4323832323 |
    Then I verify the payee Jane details and validate error messages for invalid inputs
    Then I verify the confirm button is enabled
    Then I click on the confirm button
    Then I verify that i reached the OTP Screen
    Then I enter the OTP 123436 to add payee
    Then I check for then error message for incorrect OTP while adding payee
    Then I wait for the 15-second timer to reach 0 and verify the presence of the Resend OTP button
    Then I tap on the back button on the Payee OTP screen

#    sc5  enter valid otp
    Then I verify the confirm button is enabled
    Then I click on the confirm button
    Then I verify that i reached the OTP Screen
    Then I enter the OTP 123456 to add payee
    Then I verify the payee's addition by checking the payee Jane account number on the auto-directed individual screen after OTP entry
    Then I check the text elements and buttons on the Jane payee individual screen
    Then I tap on the back button on the payee individual screen
    Then I scroll up the Cash Account Dashboard screen
    Then I check if the newly added payee Jane is appearing on the cash account dashboard
    Then I tap on the See All text link on the Cash account dashboard
    Then I verify that i reached the All Payees Screen
    Then I check if the newly added payee Jane is appearing on the All payees screen

    Then I tap on the Add Payee button on the All payees screen
    Given I enter Payee Name, Select Bank and Account Number
      | payee_name | bank_name    | account_no  |
      | Mark       | State Bank of India | 2313152312 |
    Then I verify the payee Mark details and validate error messages for invalid inputs
    Then I verify the confirm button is enabled
    Then I click on the confirm button
    Then I verify that i reached the OTP Screen
    Then I enter the OTP 123456 to add payee
    Then I verify the payee's addition by checking the payee Mark account number on the auto-directed individual screen after OTP entry
    Then I check the text elements and buttons on the Mark payee individual screen
    Then I tap on the back button on the payee individual screen
    Then I verify that i reached the All Payees Screen
    Then I check if the newly added payee Mark is appearing on the All payees screen
    Then I tap on the payee name Mark on the All payees screen
    Then I click on the payee name Mark on the Payee individual screen
    Then I check the payee details on the Mark payee edit screen
    Then I click on the Favourite icon
    Then I verify the save button is enabled
    Then I tap on the save button on the payee edit screen
    Then I verify if i auto-directed to the payee Mark individual screen

    Then I tap on the New Payment button on the payee individual screen
    Then I verify if i directed to the new payment screen
    Then I check the text elements and buttons on the Mark payee New Payment screen
    Then I enter the payee amount 1 on the New Payment screen
    Then I select the reason chip Insurance on the Mark payee New payment screen
    Then I verify the Preview button is enabled on the New Payment screen
    Then I tap on the Preview button on the New Payment screen
    Then I check the text elements and buttons on the Mark payee New Payment Preview screen
    Then I verify the Pay button is enabled on the New Payment Preview screen
    Then I tap on the Pay button on the New Payment Preview screen
    Then I verify if i auto-directed to the payee Mark individual screen
    Then I verify the latest transaction record appears for the Mark payee
    Then I click on the latest transaction record appears for the Mark payee
    Then I verify the latest transaction is settled for the Mark payee
    Then I tap on the back button on the Transaction details screen
    Then I verify if i auto-directed to the payee Mark individual screen
    Then I click on the payee name Mark on the Payee individual screen
    Then I check the payee details on the Mark payee edit screen
    Then I tap on the three vertical dots on the payee edit screen
    Then I click on the delete payee option
    Then I verify if confirmation pop-up appeared
    Then I click on the Yes button on the confirmation pop-up appeared
    Then I verify that i reached the All Payees Screen

