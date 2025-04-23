import tests.api.aggregate.investment.customer_profile_steps
import tests.api.aggregate.investment.end_customer_profile_steps
import tests.api.aggregate.investment.portfoilo_steps
import tests.api.aggregate.investment.transaction_steps
import tests.api.aggregate.profile.customer_steps
import tests.api.aggregate.profile.customer_profile_steps
import tests.api.aggregate.profile.end_customer_profile_steps

# By default, behave ONLY look for step definitions in the root feature/steps directory
# If we put our files in subdirectories or directory outside feature/steps then behave will not recognize them
# As a work-around we can import all steps from all feature/<modules> in this file
# So the unused imports are not meant for removal from this common step module
