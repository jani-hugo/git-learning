from hugoutils.utilities.dataclass_util import DataClassParser

from tests.api.aggregate.cos import cos_helper
from tests.api.aggregate.cos.cos_dataclass import CustomerProfileDTO
from behave import *
from retry import retry

from tests.util.common_util import check_status

use_step_matcher("re")


@given("I onboard below Customer-Profile onto COS")
def onboard_customer_profile(context):
    request = context.request
    customer_profile_dto_list = DataClassParser.parse_rows(
        context.table.rows, data_class=CustomerProfileDTO
    )
    context.data = {} if context.data is None else context.data
    for customer_profile_dto in customer_profile_dto_list:
        data = customer_profile_dto.get_dict()
        customer_profile_id = context.data["config_data"]["customer_profile_id"]
        customer_id = context.data["config_data"]["customer_id"]
        data["customer_id"] = customer_id
        data["customer_profile_id"] = customer_profile_id
        response = request.hugoserve_post_request(
            f'{cos_helper.customer_profile_urls["post_customer_profile"]}',
            data=data,
            headers={
                cos_helper.header_parameters[
                    "customer_profile_id"
                ]: customer_profile_id,
                cos_helper.header_parameters["origin_id"]: "CUSTOMER",
            },
        )
        check_status(response, "200")
