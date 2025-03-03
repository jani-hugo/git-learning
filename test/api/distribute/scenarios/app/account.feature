Feature: Open Hugosave Account

  Scenario: Open User Account
    Given I open user account
      | user_profile_identifier | phone_number | email          | legal_name | name   | status              | prefix_ph_num |
      | UID1                    | random       | test@gmail.com | John Doe   | Johhny | PROFILE_IN_PROGRESS | +3731         |

    Then I check account status
      | user_profile_identifier | status         |
      | UID1                    | PROFILE_ACTIVE |

  Scenario: Open User Account with Valid Referral Code
    Given I open user account
      | user_profile_identifier | phone_number | email          | legal_name | status              |
      | UID1                    | random       | test@gmail.com | John Doe   | PROFILE_IN_PROGRESS |

    Then I check account status
      | user_profile_identifier | status         |
      | UID1                    | PROFILE_ACTIVE |

    Then I open user account with referral code of user with identifier UID1
      | user_profile_identifier | phone_number | email        | legal_name | status              | referral_code |
      | UID2                    | random       | test@def.com | John Glenn | PROFILE_IN_PROGRESS | UID1          |

    Then I check account status
      | user_profile_identifier | status         |
      | UID2                    | PROFILE_ACTIVE |

    Then I check the referral status of user UID2 with referee user as UID1

  Scenario: Open User Account with Invalid Referral Code

    Then I open user account with invalid referral code
      | user_profile_identifier | phone_number | email        | legal_name | status              | referral_code |
      | UID1                    | random       | test@def.com | Mark Blanc | PROFILE_IN_PROGRESS | invalid       |

    Then I check account status
      | user_profile_identifier | status         |
      | UID1                    | PROFILE_ACTIVE |

    Then I check the referral status of user UID1 with referee user as invalid
