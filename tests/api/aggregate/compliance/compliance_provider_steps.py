from hugoutils.utilities.dataclass_util import DataClassParser

from tests.api.aggregate.compliance.compliance_dataclass import CustomerProfileDTO
from behave import *

from tests.util.common_util import check_status

use_step_matcher("re")
compliance_customer_profile_url = "/compliance/v1"


@Given("I fetch provider with a provider id and check status")
def get_provider(context):
    request = context.request
    customer_profile_dto_list = DataClassParser.parse_rows(
        context.table.rows, data_class=CustomerProfileDTO
    )
    context.data = {} if context.data is None else context.data
    for customer_profile_dto in customer_profile_dto_list:
        data = customer_profile_dto.get_dict()
        provider_id = data["provider_id"]
        status_code = data["status_code"]
        response = request.hugoserve_get_request(
            f"{compliance_customer_profile_url}/providers/{provider_id}"
        )
        check_status(response, status_code)


@Given("I get providers with a provider region and check status")
def step_impl(context):
    request = context.request
    customer_profile_dto_list = DataClassParser.parse_rows(
        context.table.rows, data_class=CustomerProfileDTO
    )
    context.data = {} if context.data is None else context.data
    for customer_profile_dto in customer_profile_dto_list:
        data = customer_profile_dto.get_dict()
        region = data["region"]
        status_code = data["status_code"]
        response = request.hugoserve_get_request(
            f"{compliance_customer_profile_url}/providers/region/{region}"
        )
        check_status(response, status_code)
