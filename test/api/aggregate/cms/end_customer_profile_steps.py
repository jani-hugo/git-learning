from aggregate.cms import cms_helper
from behave import *
from common.utils import check_status
from retry import retry

use_step_matcher("re")


@Then(
    "I onboard End Customer Profile ([^']*) to CMS with ([^']*) and verify onboard status as ([^']*)"
)
def onboard_end_customer_profile(
    context, end_customer_profile_id, payment_provider, expected_onboard_status
):
    request = context.request

    customer_profile_id = context.data['config_data']['customer_profile_id']
    end_customer_profile_id = context.data[end_customer_profile_id].end_customer_profile_id
    data = {
        'payment_provider_id': cms_helper.get_payment_provider_id(payment_provider),
        'end_customer_profile_id': end_customer_profile_id,
    }

    response = request.hugoserve_post_request(
        cms_helper.end_customer_profile_urls["onboard"],
        data=data,
        headers=cms_helper.get_headers(customer_profile_id),
    )
    check_status(response, '200')
    assert (
        response['data']['onboard_status'] == 'ONBOARD_PENDING'
        or response['data']['onboard_status'] == expected_onboard_status
    )

    @retry(exceptions=AssertionError, tries=30, delay=2, logger=None)
    def retry_for_onboarding():
        response = request.hugoserve_get_request(
            cms_helper.end_customer_profile_urls["get_details"].replace(
                '$end_customer_profile_id$', end_customer_profile_id
            ),
            headers=cms_helper.get_headers(customer_profile_id),
        )
        check_status(response, '200')
        cms_helper.assert_values(
            "End Customer Profile Onboard Status",
            end_customer_profile_id,
            expected_onboard_status,
            response['data']['onboard_status'],
        )

    if response['data']['onboard_status'] != expected_onboard_status:
        retry_for_onboarding()
