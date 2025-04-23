Then I wait until max time to verify bank account CashWalletId with an available balance of -50 and total balance of -50 for customerProfileId BCPID1

Then I wait until max time to verify cash account FloatAccID with an available balance of 100 and total balance of 100 for customerProfileId BCPID1

Scenario: Apply Tax on Card with amount < balance and no overdraft required

Given I deposit an amount of 50 into CashWalletId using cash DevDeposit and expect the header status 200
| identifier           | customer_profile_id | purpose  | currency | transaction_rail |
| DevDepositIdentifier | BCPID1              | TRANSFER | SGD      | FAST             |

Then I wait until max time to verify bank account CashWalletId with an increased balance of 50 for customerProfileId BCPID1

Then I attach a card onto the cash wallet CashWalletId and CustomerProfileId BCPID1 and expect request status 200 and attach status SUCCESS

Then I initiate a Apply Tax on Card Transaction TX1 on cash wallet CashWalletId and CustomerProfileId BCPID1 and expect request status 200 and txn status APPLY_TAX_PENDING
| currency | amount | push_overdraft |
| SGD      | 50    | true           |

Then I wait until max time to verify the Card transaction TX1 status as TRANSACTION_SETTLED for customerProfileId BCPID1

Then I wait until max time to verify bank account CashWalletId with an available balance of 0 and total balance of 0 for customerProfileId BCPID1

Then I wait until max time to verify cash account FloatAccID with an available balance of 150 and total balance of 150 for customerProfileId BCPID1

Scenario: Apply Tax on Card with amount > balance and overdraft required

Given I deposit an amount of 50 into CashWalletId using cash DevDeposit and expect the header status 200
| identifier           | customer_profile_id | purpose  | currency | transaction_rail |
| DevDepositIdentifier | BCPID1              | TRANSFER | SGD      | FAST             |

Then I wait until max time to verify bank account CashWalletId with an increased balance of 50 for customerProfileId BCPID1

Then I attach a card onto the cash wallet CashWalletId and CustomerProfileId BCPID1 and expect request status 200 and attach status SUCCESS

Then I initiate a Apply Tax on Card Transaction TX1 on cash wallet CashWalletId and CustomerProfileId BCPID1 and expect request status 200 and txn status APPLY_TAX_PENDING
| currency | amount | push_overdraft |
| SGD      | 100    | true           |

Then I wait until max time to verify the Card transaction TX1 status as TRANSACTION_SETTLED for customerProfileId BCPID1

Then I wait until max time to verify bank account CashWalletId with an available balance of -50 and total balance of -50 for customerProfileId BCPID1

Then I wait until max time to verify cash account FloatAccID with an available balance of 200 and total balance of 200 for customerProfileId BCPID1

Scenario: Apply Yield on Card

Then I attach a card onto the cash wallet CashWalletId and CustomerProfileId BCPID1 and expect request status 200 and attach status SUCCESS

Then I initiate a Apply Yield on Card Transaction TX1 on cash wallet CashWalletId and CustomerProfileId BCPID1 and expect request status 200 and txn status APPLY_YIELD_PENDING
| currency | amount | push_overdraft |
| SGD      | 50    | true           |

Then I wait until max time to verify the Card transaction TX1 status as TRANSACTION_SETTLED for customerProfileId BCPID1

Then I wait until max time to verify bank account CashWalletId with an available balance of 50 and total balance of 50 for customerProfileId BCPID1

Then I wait until max time to verify cash account FloatAccID with an available balance of 150 and total balance of 150 for customerProfileId BCPID1
