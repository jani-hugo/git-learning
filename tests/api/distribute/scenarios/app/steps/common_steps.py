import time

from behave import Step, use_step_matcher

use_step_matcher("re")

import tests.api.distribute.app.verify_mobile_number_steps
import tests.api.distribute.app.account_steps
import tests.api.distribute.app.admin_steps
import tests.api.distribute.app.cash_map_steps
import tests.api.distribute.app.device_tokens_steps
import tests.api.distribute.app.gold_vault_steps
import tests.api.distribute.app.intent_steps
import tests.api.distribute.app.map_schedule_steps
import tests.api.distribute.app.note_steps
import tests.api.distribute.app.payee_steps
import tests.api.distribute.app.physical_card_steps
import tests.api.distribute.app.plus_account_steps
import tests.api.distribute.app.questionnaire_steps
import tests.api.distribute.app.reward_gold_steps
import tests.api.distribute.app.roundups_steps
import tests.api.distribute.app.update_details_steps
import tests.api.distribute.app.credit_account_steps
import tests.api.distribute.app.create_account_steps
import tests.api.distribute.app.premium_account_steps


@Step("I wait for ([^']*) seconds")
def wait_for(context, seconds):
    time.sleep(int(seconds))


# By default, behave ONLY look for step definitions in the root feature/steps directory
# If we put our files in subdirectories or directory outside feature/steps then behave will not recognize them
# As a work-around we can import all steps from all feature/<modules> in this file
# So the unused imports are not meant for removal from this common step module
