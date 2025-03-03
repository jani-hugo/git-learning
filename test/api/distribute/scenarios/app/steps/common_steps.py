import time

from behave import Step, use_step_matcher

use_step_matcher("re")

import test.api.distribute.app.account_steps
import test.api.distribute.app.admin_steps
import test.api.distribute.app.cash_map_steps
import test.api.distribute.app.device_tokens_steps
import test.api.distribute.app.gold_vault_steps
import test.api.distribute.app.intent_steps
import test.api.distribute.app.map_schedule_steps
import test.api.distribute.app.note_steps
import test.api.distribute.app.payee_steps
import test.api.distribute.app.physical_card_steps
import test.api.distribute.app.plus_account_steps
import test.api.distribute.app.questionnaire_steps
import test.api.distribute.app.reward_gold_steps
import test.api.distribute.app.roundups_steps
import test.api.distribute.app.update_details_steps
import test.api.distribute.app.credit_account_steps


@Step("I wait for ([^']*) seconds")
def wait_for(context, seconds):
    time.sleep(int(seconds))


# By default, behave ONLY look for step definitions in the root feature/steps directory
# If we put our files in subdirectories or directory outside feature/steps then behave will not recognize them
# As a work-around we can import all steps from all feature/<modules> in this file
# So the unused imports are not meant for removal from this common step module
