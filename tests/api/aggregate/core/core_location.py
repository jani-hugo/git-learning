from behave import *
from hugoutils.utilities.dataclass_util import DataClassParser

from tests.api.aggregate.core.core_dataclass import FetchLocation
from tests.util.common_util import check_status

location_callback_url = "/core/v1/internal"
header_customer_profile_id = "x-customer-profile-id"
header_idempotency_key = "x-idempotency-key"


@When("I try to verify location")
def find_location_step(context):
    request = context.request
    find_location_list = DataClassParser.parse_rows(
        context.table.rows, data_class=FetchLocation
    )

    context.data = {} if context.data is None else context.data
    for find_location in find_location_list:
        data = find_location.get_dict()
        result = data["result"]
        response = request.hugoserve_get_request(
            path=f"{location_callback_url}/location",
            params={"latitude": data["latitude"], "longitude": data["longitude"]},
        )
        check_status(response, result)
