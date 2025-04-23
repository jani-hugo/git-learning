from tests.api.aggregate.cms import cms_helper
from behave import *
from retry import retry

from tests.util.common_util import check_status

use_step_matcher("re")


@Given(
    "I onboard HUGOHUB Customer Profile for CMS and verify onboard status as ([^']*)"
)
def onboard_hugohub(context, expected_onboard_status):
    request = context.request
    response = request.hugoserve_post_request(
        cms_helper.admin_urls["onboard_hugohub"],
    )
    check_status(response, "200")
    assert (
        response["data"]["onboard_status"] == "ONBOARD_PENDING"
        or response["data"]["onboard_status"] == expected_onboard_status
    )

    @retry(exceptions=AssertionError, tries=30, delay=2, logger=None)
    def retry_for_onboarding():
        response = request.hugoserve_post_request(
            cms_helper.admin_urls["onboard_hugohub"],
        )
        check_status(response, "200")
        cms_helper.assert_values(
            "Customer Profile Onboard Status",
            "HUGOHUB",
            expected_onboard_status,
            response["data"]["onboard_status"],
        )

    if response["data"]["onboard_status"] != expected_onboard_status:
        retry_for_onboarding()


@then("I onboard Customer Profile ([^']*) to CMS and verify onboard status as ([^']*)")
def onboard_customer_profile(context, customer_identifier, expected_onboard_status):
    request = context.request
    customer_profile_dto = context.data.get(customer_identifier)
    customer_id = customer_profile_dto.customer_id
    customer_profile_id = customer_profile_dto.customer_profile_id

    data = {
        "customer_id": customer_id,
        "customer_profile_id": customer_profile_id,
    }

    response = request.hugoserve_post_request(
        cms_helper.admin_urls["onboard_customer_profile"],
        data=data,
        headers=cms_helper.get_headers(customer_profile_id),
    )
    check_status(response, "200")
    assert (
        response["data"]["onboard_status"] == "ONBOARD_PENDING"
        or response["data"]["onboard_status"] == expected_onboard_status
    )

    @retry(exceptions=AssertionError, tries=30, delay=2, logger=None)
    def retry_for_onboarding():
        response = request.hugoserve_get_request(
            cms_helper.customer_profile_urls["get_details"],
            headers=cms_helper.get_headers(customer_profile_id),
        )
        check_status(response, "200")
        cms_helper.assert_values(
            "Customer Profile Onboard Status",
            customer_profile_id,
            expected_onboard_status,
            response["data"]["onboard_status"],
        )

    if response["data"]["onboard_status"] != expected_onboard_status:
        retry_for_onboarding()
