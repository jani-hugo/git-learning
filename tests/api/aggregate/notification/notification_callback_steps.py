from hugoutils.utilities.dataclass_util import DataClassParser

from tests.api.aggregate.notification.notification_dataclass import (
    CallbackDTO,
    CreateUpdateCallbackRequestDTO,
)
from behave import *

from tests.util.common_util import check_status

use_step_matcher("re")
notification_customer_callback_url = "/notification/v1/customer-profile/callback"


@Then("I set Callback for the Customer-Profile")
def set_callback_for_customer(context):
    request = context.request

    callback_dto_list = DataClassParser.parse_rows(
        context.table.rows, data_class=CreateUpdateCallbackRequestDTO
    )

    context.data = {} if context.data is None else context.data

    for callback_dto_list in callback_dto_list:
        data = callback_dto_list.get_dict()
        customer_profile_id = context.data[
            callback_dto_list.customer_profile_identifier
        ].customer_profile_id

        response = request.hugoserve_post_request(
            notification_customer_callback_url,
            data,
            headers={"x-customer-profile-id": customer_profile_id},
        )
        check_status(response, "200")

        context.data[callback_dto_list.callback_identifier] = (
            callback_dto_list  # Save callback against identifier
        )


@Then("I verify Callback is set with values")
def verify_callback_endpoint(context):
    request = context.request
    callbacks = DataClassParser.parse_rows(context.table.rows, data_class=CallbackDTO)

    for callback in callbacks:
        customer_profile_id = context.data[
            callback.customer_profile_identifier
        ].customer_profile_id

        response = request.hugoserve_get_request(
            notification_customer_callback_url,
            params=None,
            headers={"x-customer-profile-id": customer_profile_id},
        )
        check_status(response, "200")
        data = response["data"]
        actual_end_customer_profile_dto = DataClassParser.dict_to_object(
            data, data_class=CallbackDTO
        )

        sanitized_expected = CallbackDTO.sanitize_callback_dto(callback)
        sanitized_actual = CallbackDTO.sanitize_callback_dto(
            actual_end_customer_profile_dto
        )
        assert sanitized_expected == sanitized_actual, (
            f"\nExpect end_customer_profile_dto: {sanitized_expected}"
            f"\nActual end_customer_profile_dto: {sanitized_actual}"
        )


@Then("I try to set Callback for the Customer-Profile and fail")
def fail_invalid_callback(context):
    request = context.request

    callback_dto_list = DataClassParser.parse_rows(
        context.table.rows, data_class=CreateUpdateCallbackRequestDTO
    )

    context.data = {} if context.data is None else context.data

    for callback_dto_list in callback_dto_list:
        data = callback_dto_list.get_dict()
        customer_profile_id = context.data[
            callback_dto_list.customer_profile_identifier
        ].customer_profile_id

        response = request.hugoserve_post_request(
            notification_customer_callback_url,
            data,
            headers={"x-customer-profile-id": customer_profile_id},
        )
        check_status(response, "NSM_E9507")


@Then("I update Callback with new endpoint")
def update_callback_endpoint(context):
    request = context.request

    callback_dto_list = DataClassParser.parse_rows(
        context.table.rows, data_class=CreateUpdateCallbackRequestDTO
    )

    context.data = {} if context.data is None else context.data

    for callback_dto_list in callback_dto_list:
        data = callback_dto_list.get_dict()
        customer_profile_id = context.data[
            callback_dto_list.customer_profile_identifier
        ].customer_profile_id

        response = request.hugoserve_put_request(
            notification_customer_callback_url,
            data,
            headers={"x-customer-profile-id": customer_profile_id},
        )
        check_status(response, "200")
        context.data[callback_dto_list.callback_identifier] = (
            callback_dto_list  # Save callback against identifier
        )
