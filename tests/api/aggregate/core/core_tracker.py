from behave import *
from hugoutils.utilities.dataclass_util import DataClassParser

from tests.api.aggregate.core.core_dataclass import (
    CreateTracker,
    GetTrackerReferenceDetails,
    GetTrackerDetails,
    AddTrackerEntityDetails,
    UpdateEntityTransactionCodes,
    GetAllTrackerDetails,
    GetListTrackerReferencesDetails,
)
from tests.util.common_util import check_status

tracker_callback_url = "/core/v1/tracker"
header_customer_profile_id = "x-customer-profile-id"
header_idempotency_key = "x-idempotency-key"


@When("I try to create a tracker")
def create_tracker_step(context):
    request = context.request
    create_tracker_list = DataClassParser.parse_rows(
        context.table.rows, data_class=CreateTracker
    )

    context.data = {} if context.data is None else context.data
    for create_tracker in create_tracker_list:
        data = create_tracker.get_dict()
        response_code = data["response_code"]
        customer_profile_id = data["customer_profile_id"]
        idempotency_key = data["idempotency"]
        response = request.hugoserve_post_request(
            path=f"{tracker_callback_url}",
            headers={
                header_customer_profile_id: customer_profile_id,
                header_idempotency_key: idempotency_key,
            },
            data=data["trackerRequestDTO"],
        )
        check_status(response, response_code)


@When("I try to fetch a details of tracker of a particular reference_id")
def fetch_tracker_step(context):
    request = context.request
    fetch_tracker_list = DataClassParser.parse_rows(
        context.table.rows, data_class=GetTrackerReferenceDetails
    )

    context.data = {} if context.data is None else context.data
    for fetch_tracker in fetch_tracker_list:
        data = fetch_tracker.get_dict()
        response_code = data["response_code"]
        customer_profile_id = data["customer_profile_id"]
        tracker_id = data["tracker_id"]
        reference_id = data["reference_id"]
        response = request.hugoserve_get_request(
            path=f"{tracker_callback_url}/{tracker_id}/reference/{reference_id}",
            headers={header_customer_profile_id: customer_profile_id},
            params=data,
        )
        check_status(response, response_code)


@When("I try to fetch a tracker's details")
def step_impl(context):
    request = context.request
    fetch_tracker_details_list = DataClassParser.parse_rows(
        context.table.rows, data_class=GetTrackerDetails
    )

    context.data = {} if context.data is None else context.data
    for fetch_tracker_details in fetch_tracker_details_list:
        data = fetch_tracker_details.get_dict()
        response_code = data["response_code"]
        customer_profile_id = data["customer_profile_id"]
        tracker_id = data["tracker_id"]
        path = f"{tracker_callback_url}/{tracker_id}"
        response = request.hugoserve_get_request(
            path=f"{tracker_callback_url}/{tracker_id}",
            headers={header_customer_profile_id: customer_profile_id},
            params={"tracker_id": data["tracker_id"]},
        )
        check_status(response, response_code)


@When("I try to add a tracker entity details")
def add_tracker_entity_step(context):
    request = context.request
    add_tracker_entity_list = DataClassParser.parse_rows(
        context.table.rows, data_class=AddTrackerEntityDetails
    )

    context.data = {} if context.data is None else context.data
    for add_tracker_entity in add_tracker_entity_list:
        data = add_tracker_entity.get_dict()
        response_code = data["response_code"]
        customer_profile_id = data["customer_profile_id"]
        tracker_id = data["tracker_id"]
        response = request.hugoserve_put_request(
            path=f"{tracker_callback_url}/{tracker_id}/entity",
            headers={header_customer_profile_id: customer_profile_id},
            data=data["entityRequestDTO"],
        )
        check_status(response, response_code)


@When("I try to update entity transaction codes")
def update_entity_transaction_codes_step(context):
    request = context.request
    update_entity_transaction_codes_list = DataClassParser.parse_rows(
        context.table.rows, data_class=UpdateEntityTransactionCodes
    )

    context.data = {} if context.data is None else context.data
    for update_entity_transaction_codes in update_entity_transaction_codes_list:
        data = update_entity_transaction_codes.get_dict()
        response_code = data["response_code"]
        customer_profile_id = data["customer_profile_id"]
        tracker_entity_id = data["trackerEntityId"]
        response = request.hugoserve_put_request(
            path=f"{tracker_callback_url}/entity/{tracker_entity_id}/transaction-codes",
            headers={header_customer_profile_id: customer_profile_id},
            data=data,
        )
        check_status(response, response_code)


@When("I try to get the list of tracker references details")
def list_tracker_reference_details_step(context):
    request = context.request
    list_tracker_reference_details_list = DataClassParser.parse_rows(
        context.table.rows, data_class=GetListTrackerReferencesDetails
    )

    context.data = {} if context.data is None else context.data
    for list_tracker_reference_details in list_tracker_reference_details_list:
        data = list_tracker_reference_details.get_dict()
        response_code = data["response_code"]
        customer_profile_id = data["customer_profile_id"]
        response = request.hugoserve_get_request(
            path=f"{tracker_callback_url}",
            headers={header_customer_profile_id: customer_profile_id},
            params=data["trackerVsReference"],
        )
        check_status(response, response_code)


@When("I try to get the all the tracker details")
def fetch_all_tracker_details_step(context):
    request = context.request
    fetch_all_tracker_details_list = DataClassParser.parse_rows(
        context.table.rows, data_class=GetAllTrackerDetails
    )

    context.data = {} if context.data is None else context.data
    for fetch_all_tracker_details in fetch_all_tracker_details_list:
        data = fetch_all_tracker_details.get_dict()
        response_code = data["response_code"]
        customer_profile_id = data["customer_profile_id"]
        response = request.hugoserve_get_request(
            path=f"{tracker_callback_url}/all",
            headers={header_customer_profile_id: customer_profile_id},
        )
        check_status(response, response_code)
