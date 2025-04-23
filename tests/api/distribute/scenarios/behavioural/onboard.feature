Feature:  Onboard Scenarios

  Background: Onboard User to Cognito
    Given I open user account
      | user_profile_identifier | phone_number | email                     | legal_name   | status              |
      | UID1                    | random       | testaccounts@hugosave.com | IndraKaranam | PROFILE_IN_PROGRESS |
    Then I check account status
      | user_profile_identifier | status         |
      | UID1                    | PROFILE_ACTIVE |
    Then Verify Onboard Details
      | user_profile_identifier | email                     | first_name   | account_type | time_zone      | roundups_enabled | profile_status |
      | UID1                    | testaccounts@hugosave.com | IndraKaranam | LITE         | Asia/Singapore | true             | PROFILE_ACTIVE | 
    Then Verify User Quest Profile Details
      | user_profile_identifier | account_type | quest_version | time_zone      | roundups_enabled | profile_status |
      | UID1                    | LITE         | 1             | Asia/Singapore | true             | PROFILE_ACTIVE | 

  Scenario: Onboard User and Update First Name and Last Name
    Given Onboard the User to Behavioural and User Engaging Platforms
      | user_profile_identifier | first_name | last_name |
      | UID1                    | Indra      | Karanam   |
    Then Verify Onboard Details
      | user_profile_identifier | email                     | first_name | last_name | account_type | time_zone      | roundups_enabled | profile_status |
      | UID1                    | testaccounts@hugosave.com | Indra      | Karanam   | LITE         | Asia/Singapore | true             | PROFILE_ACTIVE | 
    Then Verify User Quest Profile Details
      | user_profile_identifier | account_type | quest_version | time_zone      | roundups_enabled | profile_status |
      | UID1                    | LITE         | 1             | Asia/Singapore | true             | PROFILE_ACTIVE | 

  Scenario: Onboard User and Update First, Last Name and Email with Empty Spaces Before and After
    Given Onboard Users with Spaces in Fields
      | user_profile_identifier | first_name | last_name |
      | UID1                    | Indra      | Karanam   |
    Then Verify Onboard Details
      | user_profile_identifier | email                     | first_name | last_name | account_type | time_zone      | roundups_enabled | profile_status |
      | UID1                    | testaccounts@hugosave.com | Indra      | Karanam   | LITE         | Asia/Singapore | true             | PROFILE_ACTIVE | 
    Then Verify User Quest Profile Details
      | user_profile_identifier | account_type | quest_version | time_zone      | roundups_enabled | profile_status |
      | UID1                    | LITE         | 1             | Asia/Singapore | true             | PROFILE_ACTIVE | 

  Scenario: Onboard User and update account type
    Given Onboard the User to Behavioural and User Engaging Platforms
      | user_profile_identifier | account_type |
      | UID1                    | PLUS         |
    Then Verify Onboard Details
      | user_profile_identifier | email                     | first_name   | account_type | time_zone      | roundups_enabled | profile_status |
      | UID1                    | testaccounts@hugosave.com | IndraKaranam | PLUS         | Asia/Singapore | true             | PROFILE_ACTIVE | 
    Then Verify User Quest Profile Details
      | user_profile_identifier | account_type | quest_version | time_zone      | roundups_enabled | profile_status |
      | UID1                    | PLUS         | 1             | Asia/Singapore | true             | PROFILE_ACTIVE | 

  Scenario: Onboard User and update time zone
    Given Onboard the User to Behavioural and User Engaging Platforms
      | user_profile_identifier | time_zone      |
      | UID1                    | Asia/Hong_Kong |
    Then Verify Onboard Details
      | user_profile_identifier | email                     | first_name   | account_type | time_zone      | roundups_enabled | profile_status |
      | UID1                    | testaccounts@hugosave.com | IndraKaranam | LITE         | Asia/Hong_Kong | true             | PROFILE_ACTIVE | 
    Then Verify User Quest Profile Details
      | user_profile_identifier | account_type | quest_version | time_zone      | roundups_enabled | profile_status |
      | UID1                    | LITE         | 1             | Asia/Hong_Kong | true             | PROFILE_ACTIVE | 


  Scenario: Onboard User and update profile status
    Given Onboard the User to Behavioural and User Engaging Platforms
      | user_profile_identifier | profile_status  |
      | UID1                    | PROFILE_BLOCKED |
    Then Verify Onboard Details
      | user_profile_identifier | email                     | first_name   | account_type | time_zone      | roundups_enabled | profile_status  |
      | UID1                    | testaccounts@hugosave.com | IndraKaranam | LITE         | Asia/Singapore | true             | PROFILE_BLOCKED | 
    Then Verify User Quest Profile Details
      | user_profile_identifier | account_type | quest_version | time_zone      | roundups_enabled | profile_status  |
      | UID1                    | LITE         | 1             | Asia/Singapore | true             | PROFILE_BLOCKED | 

  Scenario: Onboard User and update user profile version
    Given Onboard the User to Behavioural and User Engaging Platforms
      | user_profile_identifier |
      | UID1                    | 
    Then Verify Onboard Details
      | user_profile_identifier | email                     | first_name   | account_type | time_zone      | roundups_enabled | profile_status |
      | UID1                    | testaccounts@hugosave.com | IndraKaranam | LITE         | Asia/Singapore | true             | PROFILE_ACTIVE | 
    Then Verify User Quest Profile Details
      | user_profile_identifier | account_type | quest_version | time_zone      | roundups_enabled | profile_status |
      | UID1                    | LITE         | 1             | Asia/Singapore | true             | PROFILE_ACTIVE | 

  Scenario: Onboard User and round ups
    Given Onboard the User to Behavioural and User Engaging Platforms
      | user_profile_identifier | roundups_enabled |
      | UID1                    | false            |
    Then Verify Onboard Details
      | user_profile_identifier | email                     | first_name   | account_type | time_zone      | roundups_enabled | profile_status |
      | UID1                    | testaccounts@hugosave.com | IndraKaranam | LITE         | Asia/Singapore | false            | PROFILE_ACTIVE | 
    Then Verify User Quest Profile Details
      | user_profile_identifier | account_type | quest_version | time_zone      | roundups_enabled | profile_status |
      | UID1                    | LITE         | 1             | Asia/Singapore | false            | PROFILE_ACTIVE | 

  Scenario: Onboard User and Update fields Multiple Times
    Given Onboard the User to Behavioural and User Engaging Platforms
      | user_profile_identifier | first_name | last_name |
      | UID1                    | Karanam    | Test      |
    Then Verify Onboard Details
      | user_profile_identifier | email          | first_name | last_name | account_type | time_zone      | roundups_enabled | profile_status |
      | UID1                    | test@gmail.com | Karanam    | Test      | LITE         | Asia/Singapore | true             | PROFILE_ACTIVE | 
    Then Verify User Quest Profile Details
      | user_profile_identifier | account_type | quest_version | time_zone      | roundups_enabled | profile_status |
      | UID1                    | LITE         | 1             | Asia/Singapore | true             | PROFILE_ACTIVE | 
    Then Onboard the User to Behavioural and User Engaging Platforms
      | user_profile_identifier | roundups_enabled |
      | UID1                    | false            |
    Then Verify Onboard Details
      | user_profile_identifier | email           | first_name | last_name | account_type | time_zone      | roundups_enabled | profile_status |
      | UID1                    | test2@gmail.com | Karanam    | Test      | LITE         | Asia/Singapore | false            | PROFILE_ACTIVE | 
    Then Verify User Quest Profile Details
      | user_profile_identifier | account_type | quest_version | time_zone      | roundups_enabled | profile_status |
      | UID1                    | LITE         | 1             | Asia/Singapore | false            | PROFILE_ACTIVE | 
    Then Onboard the User to Behavioural and User Engaging Platforms
      | user_profile_identifier | first_name | time_zone      | profile_status  |
      | UID1                    | RANDOM     | Asia/Hong_Kong | PROFILE_BLOCKED |
    Then Verify Onboard Details
      | user_profile_identifier | email           | first_name | last_name | account_type | time_zone      | roundups_enabled | profile_status  |
      | UID1                    | test2@gmail.com | RANDOM     | Test      | LITE         | Asia/Hong_Kong | false            | PROFILE_BLOCKED | 
    Then Verify User Quest Profile Details
      | user_profile_identifier | account_type | quest_version | time_zone      | roundups_enabled | profile_status  |
      | UID1                    | LITE         | 1             | Asia/Hong_Kong | false            | PROFILE_BLOCKED | 

  Scenario: Onboard User and Update Any Field with Empty Spaces should not change values
    Given Onboard Users with Spaces in Fields
      | user_profile_identifier | first_name | email |
      | UID1                    |            |       |
    Then Verify Onboard Details
      | user_profile_identifier | email                     | first_name   | account_type | time_zone      | roundups_enabled | profile_status |
      | UID1                    | testaccounts@hugosave.com | IndraKaranam | LITE         | Asia/Singapore | true             | PROFILE_ACTIVE | 
    Then Verify User Quest Profile Details
      | user_profile_identifier | account_type | quest_version | time_zone      | roundups_enabled | profile_status |
      | UID1                    | LITE         | 1             | Asia/Singapore | true             | PROFILE_ACTIVE | 

