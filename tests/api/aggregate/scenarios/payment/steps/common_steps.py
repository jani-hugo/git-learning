import tests.api.aggregate.payment.account_steps
import tests.api.aggregate.payment.customer_profile_steps
import tests.api.aggregate.payment.dbssg_deposit_steps
import tests.api.aggregate.payment.end_customer_profile_steps
import tests.api.aggregate.payment.paysyspk_deposit_steps
import tests.api.aggregate.payment.transaction_steps
import tests.api.aggregate.payment.virtual_id_steps
import tests.api.aggregate.payment.inquiry_steps
import tests.api.aggregate.payment.provider_steps
import tests.api.aggregate.payment.paysyspk_settlement_steps
import tests.api.aggregate.payment.paysyspk_inbound_title_fetch
import tests.api.aggregate.profile.customer_profile_steps
import tests.api.aggregate.profile.customer_steps
import tests.api.aggregate.profile.end_customer_profile_steps

# By default, behave ONLY look for step definitions in the root feature/steps directory
# If we put our files in subdirectories or directory outside feature/steps then behave will not recognize them
# As a work-around we can import all steps from all feature/<modules> in this file
# So the unused imports are not meant for removal from this common step module
