import uuid

from tests.api.aggregate.cms import cms_helper
from behave import *
from retry import retry

from tests.util.common_util import check_status

use_step_matcher("re")


@Then(
    "I onboard End Customer Profile ([^']*) to CMS and verify onboard status as ([^']*) and status code as ([^']*)"
)
def onboard_end_customer_profile(
    context, end_customer_profile_id, expected_onboard_status, expected_status_code
):
    request = context.request

    customer_profile_id = context.data["config_data"]["customer_profile_id"]
    if end_customer_profile_id in context.data:
        end_customer_profile_id = context.data[
            end_customer_profile_id
        ].end_customer_profile_id
    else:
        end_customer_profile_id = str(uuid.uuid4())
    data = {
        "end_customer_profile_id": end_customer_profile_id,
    }

    response = request.hugoserve_post_request(
        cms_helper.end_customer_profile_urls["onboard"],
        data=data,
        headers=cms_helper.get_headers(customer_profile_id),
    )
    check_status(response, expected_status_code)
    if "data" in response:
        assert (
            response["data"]["onboard_status"] == "ONBOARD_PENDING"
            or response["data"]["onboard_status"] == expected_onboard_status
        )

    @retry(exceptions=AssertionError, tries=30, delay=2, logger=None)
    def retry_for_onboarding():
        response = request.hugoserve_get_request(
            cms_helper.end_customer_profile_urls["get_details"].replace(
                "$end_customer_profile_id$", end_customer_profile_id
            ),
            headers=cms_helper.get_headers(customer_profile_id),
        )
        print(response)
        check_status(response, expected_status_code)
        cms_helper.assert_values(
            "End Customer Profile Onboard Status",
            end_customer_profile_id,
            expected_onboard_status,
            response["data"]["onboard_status"],
        )
        if (
            "data" in response
            and response["data"]["onboard_status"] != expected_onboard_status
        ):
            retry_for_onboarding()
