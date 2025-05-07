Feature: Signup: Create a New Account

  Scenario: Disable "Get OTP" Button for Invalid Mobile Number
    Given I verify that I have entered the signup screen
    Given I enter the mobile number 373
    Then I verify that the Get OTP button is disabled

  Scenario: Enter an Invalid OTP After a Valid Mobile Number
    Given I verify that I have entered the signup screen
    Given I enter the mobile number Ph2
    Then I verify that the Get OTP button is enabled
    Then I tap on the Get OTP button
    Then I verify that I have entered the OTP screen
    Then I enter the OTP 123453

  Scenario: Enter a valid OTP and enter Invalid User Details During Account Creation
    Given I verify that I have entered the signup screen
    Given I enter the mobile number Ph2
    Then I verify that the Get OTP button is enabled
    Then I tap on the Get OTP button
    Then I verify that I have entered the OTP screen
    Then I enter the OTP 123456
    Then I verify that I have entered the Create Account screen

    Given I enter a casual name, a legal name, an email, and tick the checkbox
      | casual_name | legal_name | email             | tick_check_box |
      | John2       | Doe1       | John@gmail.com | true           |
    Then I verify the user details and validate error messages for invalid inputs
    Then I verify the continue button is disabled
    Then I clear the fields

    Given I enter a casual name, a legal name, an email, and tick the checkbox
      | casual_name | legal_name | email         | tick_check_box |
      | John        | Doe        | @hn_gmail.com | true           |
    Then I verify the user details and validate error messages for invalid inputs
    Then I verify the continue button is disabled
    Then I clear the fields

    Given I enter a casual name, a legal name, an email, and tick the checkbox
      | casual_name | legal_name | email             | tick_check_box |
      | sai         |            | jane123@gmail.com | true           |
    Then I verify the user details and validate error messages for invalid inputs
    Then I verify the continue button is disabled
    Then I clear the fields

    Given I enter a casual name, a legal name, an email, and tick the checkbox
      | casual_name | legal_name | email  | tick_check_box |
      | Alex 23     | Doe        |        | false           |
    Then I verify the user details and validate error messages for invalid inputs
    Then I verify the continue button is disabled
    Then I clear the fields

    Scenario: Enter Mismatched Passcodes During Passcode Setup
      Given I verify that I have entered the signup screen
      Given I enter the mobile number Ph2
      Then I verify that the Get OTP button is enabled
      Then I tap on the Get OTP button
      Then I verify that I have entered the OTP screen
      Then I enter the OTP 123456
      Then I verify that I have entered the Create Account screen
     Given I enter a casual name, a legal name, an email, and tick the checkbox
      | casual_name | legal_name | email         | tick_check_box |
      | John        | Doe        | john@mail.com | true          |
      Then I verify the continue button is enabled
      Then I click on the continue button
      Then I check whether I have reached the Set Passcode screen
      Given I enter passcodes in both fields
      | passcode_field1 | passcode_field2 |
      | 111111          | 1111222          |
      Then I verify that the create account button is disabled
      Then I check for the error message
      Then I clear the passcode fields

  Scenario: Complete Onboarding With Mixed Valid and Invalid Inputs
    Given I enter the mobile number 34343
    Then I verify that the Get OTP button is disabled
    Given I enter the mobile number Ph1
    Then I verify that the Get OTP button is  enabled
    Then I tap on the Get OTP button
    Then I verify that I have entered the OTP screen
    Then I enter the OTP 123456
    Then I verify that I have entered the Create Account screen

    Given I enter a casual name, a legal name, an email, and tick the checkbox
      | casual_name | legal_name | email  | tick_check_box |
      | Alex 23     | Doe        |        | true           |
    Then I verify the user details and validate error messages for invalid inputs
    Then I verify the continue button is disabled
    Then I clear the fields

    Given I enter a casual name, a legal name, an email, and tick the checkbox
      | casual_name | legal_name | email         | tick_check_box |
      | John        | Doe        | john@mail.com | true          |
    Then I verify the continue button is enabled
    Then I click on the continue button
    Then I check whether I have reached the Set Passcode screen

    Given I enter passcodes in both fields
      | passcode_field1 | passcode_field2 |
      | 111111          | 111112          |
    Then I verify that the create account button is disabled
    Then I check for the error message
    Then I clear the passcode fields

    Given I enter passcodes in both fields
      | passcode_field1 | passcode_field2 |
      | 111111          | 1111111        |
    Then I verify that the create account button is enabled
    Then I click on the Create account button
    Then I verify if I am directed to the Allow Notifications screen and check the text elements and button
    Given I tap on the allow notification button
    Then I verify that i have reached the Home screen

    Scenario: onboard to cash account dashboard
      Given I verify that I have entered the signup screen
      Given I enter the mobile number Ph2
      Then I verify that the Get OTP button is enabled
      Then I tap on the Get OTP button
      Then I verify that I have entered the OTP screen
      Then I enter the OTP 123456
      Then I verify that I have entered the Create Account screen
     Given I enter a casual name, a legal name, an email, and tick the checkbox
      | casual_name | legal_name | email         | tick_check_box |
      | John        | Doe        | john@mail.com | true          |
      Then I verify the continue button is enabled
      Then I click on the continue button
      Then I check whether I have reached the Set Passcode screen
     Given I enter passcodes in both fields
      | passcode_field1 | passcode_field2 |
      | 111111          | 1111111         |
    Then I verify that the create account button is enabled
    Then I click on the Create account button
    Then I verify if I am directed to the Allow Notifications screen and check the text elements and button
    Given I tap on the allow notification button
    Then I verify that i have reached the Home screen

    And I close the 'Show Me Around' modal on the home screen
    And I dismiss the MMF popup by tapping the 'Maybe Later' button
    And I dismiss the EDDA popup by tapping the 'Maybe Later' button
    And I dismiss the My QR Code! popup by tapping the 'Maybe Later' button

    And I scroll down the home screen and then scroll back up
    Then I verify the text elements on the Cash Account banner on the Home screen

    Given I verify I am on the Home screen
    Then I tap on the profile icon on the home screen
    Then I scroll down the menu screen
    Then I tap on the nonprod option in the menu
    Then I tap on the Transaction activities option in the non-prod options screen
    Then I enter the amount 100
    Then I tap on the Deposit to your account button
    Then I tap on the back button on the nonprod screen
    Then I go back to home screen

    Given I tap on the Cash account banner on the home screen
    Then I tap on the Cash Account Dashboard button

    Given I verify that My QR code pop-up is displayed
    Given I verify that i have reached the Cash account dashboard
    Then I tap on the back button on the cash account dashboard
    Then I tap on the back button to navigate away from the Cash Account learning screen

    Given I tap on the Cash account banner on the home screen
    Given I verify that i have reached the Cash account dashboard
    Then I scroll up the Cash Account Dashboard screen
    Then I tap on the Add Payee button on the cash account dashboard

