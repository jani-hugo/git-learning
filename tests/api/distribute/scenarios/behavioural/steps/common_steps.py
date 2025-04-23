import time

from behave import Step, use_step_matcher

use_step_matcher("re")

import tests.api.distribute.app.account_steps
import tests.api.distribute.app.plus_account_steps
import tests.api.distribute.app.update_details_steps
import tests.api.distribute.behavioural.daily_task_scheduler_steps
import tests.api.distribute.behavioural.onboard_steps
import tests.api.distribute.behavioural.quest_steps


@Step("I wait for ([^']*) seconds")
def wait_for(context, seconds):
    time.sleep(int(seconds))


# By default, behave ONLY look for step definitions in the root feature/steps directory
# If we put our files in subdirectories or directory outside feature/steps then behave will not recognize them
# As a work-around we can import all steps from all feature/<modules> in this file
# So the unused imports are not meant for removal from this common step module
