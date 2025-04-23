from hugoutils.utilities.dataclass_util import DataClassParser

from tests.api.aggregate.compliance.compliance_dataclass import CustomerProfileDTO
from behave import *

from tests.util.common_util import check_status

use_step_matcher("re")
compliance_customer_profile_url = "/compliance/v1"
header_customer_profile_id = "x-customer-profile-id"


@Then("I onboard below Customer-Profile onto Compliance Provider Id")
def onboard_customer_profile(context):
    request = context.request
    customer_profile_dto_list = DataClassParser.parse_rows(
        context.table.rows, data_class=CustomerProfileDTO
    )
    context.data = {} if context.data is None else context.data
    for customer_profile_dto in customer_profile_dto_list:
        data = customer_profile_dto.get_dict()
        customer_profile_id = context.data[
            customer_profile_dto.customer_profile_identifier
        ].customer_profile_id
        customer_id = context.data[customer_profile_dto.customer_identifier].customer_id
        provider_id = data["provider_id"]
        data["provider_id"] = [provider_id]
        data["customer_id"] = customer_id
        data["customer_profile_id"] = customer_profile_id
        response = request.hugoserve_post_request(
            f"{compliance_customer_profile_url}/admin/customer-profile", data
        )
        check_status(response, data["status_code"])


@Then("I verify Customer-Profile onboarded with provider Id")
def verify_customer_profile_onboarding(context):
    request = context.request
    customer_profile_dto_list = DataClassParser.parse_rows(
        context.table.rows, data_class=CustomerProfileDTO
    )
    context.data = {} if context.data is None else context.data
    for customer_profile_dto in customer_profile_dto_list:
        data = customer_profile_dto.get_dict()
        customer_profile_id = context.data[
            customer_profile_dto.customer_profile_identifier
        ].customer_profile_id
        provider_id = data["provider_id"]
        response = request.hugoserve_get_request(
            f"{compliance_customer_profile_url}/customer-profile/provider/{provider_id}",
            headers={header_customer_profile_id: customer_profile_id},
        )
        check_status(response, "200")


# @Then("I try to onboard Customer-Profile with invalid data")
# def onboard_customer_profile_with_invalid_data(context):


@Then("I delete the provider for Customer-Profile")
def delete_customer_profile_for_provider(context):
    request = context.request
    customer_profile_dto_list = DataClassParser.parse_rows(
        context.table.rows, data_class=CustomerProfileDTO
    )
    context.data = {} if context.data is None else context.data
    for customer_profile_dto in customer_profile_dto_list:
        data = customer_profile_dto.get_dict()
        customer_profile_id = context.data[
            customer_profile_dto.customer_profile_identifier
        ].customer_profile_id
        provider_id = data["provider_id"]
        response = request.hugoserve_delete_request(
            f"{compliance_customer_profile_url}/admin/customer-profile/{customer_profile_id}?provider-id={provider_id}",
            headers={header_customer_profile_id: customer_profile_id},
        )
        check_status(response, "200")


@Then("I verify Customer-Profile doesn't exist for provider id")
def verify_profile_doesnt_exist(context):
    request = context.request
    customer_profile_dto_list = DataClassParser.parse_rows(
        context.table.rows, data_class=CustomerProfileDTO
    )
    context.data = {} if context.data is None else context.data
    for customer_profile_dto in customer_profile_dto_list:
        data = customer_profile_dto.get_dict()
        customer_profile_id = context.data[
            customer_profile_dto.customer_profile_identifier
        ].customer_profile_id
        provider_id = data["provider_id"]
        response = request.hugoserve_get_request(
            f"{compliance_customer_profile_url}/providers/{provider_id}",
            headers={header_customer_profile_id: customer_profile_id},
        )
        check_status(response, "200")
