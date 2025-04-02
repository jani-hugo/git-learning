from behave import *

use_step_matcher("re")


@Step(
    "I initiate to create platform settlement accounts expect the header status ([^']*)"
)
def create_platform_settlement_accounts(
    context,
    status_code: str,
):
    request = context.request
    response = request.hugoserve_post_request(
        path="/payment/paysys/pk/admin/settlement/account",
    )
    assert response["headers"]["status_code"] == status_code


@Step(
    "I initiate to create customerprofile platform settlement account for customerProfileId ([^']*) expect the header status ([^']*)"
)
def create_customerprofile_platform_settlement_account(
    context, customer_profile_identifier: str, status_code: str
):
    request = context.request
    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id
    response = request.hugoserve_post_request(
        path=f"/payment/paysys/pk/admin/settlement/account/customer-profile/{customer_profile_id}",
    )
    assert response["headers"]["status_code"] == status_code
