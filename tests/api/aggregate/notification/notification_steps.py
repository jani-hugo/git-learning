from datetime import datetime
import time

from hugoutils.utilities.dataclass_util import DataClassParser

from tests.api.aggregate.notification.notification_callback_steps import (
    notification_customer_callback_url,
)
from tests.api.aggregate.notification.notification_dataclass import (
    CallbackDTO,
    CreateUpdateCallbackRequestDTO,
    NotificationDTO,
)
from behave import *

from tests.util.common_util import check_status


@Step("I create Callback for the Customer-Profile")
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
        data["endpoint"] = (
            context.data["config_data"]["AGGREGATE_ENDPOINT"]
            + "/notification/v1/dev/notification/receive"
        )
        response = request.hugoserve_post_request(
            notification_customer_callback_url,
            data,
            headers={"x-customer-profile-id": customer_profile_id},
        )
        check_status(response, "200")

        context.data[callback_dto_list.callback_identifier] = (
            callback_dto_list  # Save callback against identifier
        )


@Then("I validate Callback is set with values")
def verify_callback_endpoint(context):
    request = context.request
    callbacks = DataClassParser.parse_rows(context.table.rows, data_class=CallbackDTO)

    for callback in callbacks:
        callback.endpoint = (
            context.data["config_data"]["AGGREGATE_ENDPOINT"]
            + "/notification/v1/dev/notification/receive"
        )
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


@Then("I push dummy notification")
def push_dummy_notification(context):
    request = context.request

    notification_dto_list = DataClassParser.parse_rows(
        context.table.rows, data_class=NotificationDTO
    )

    context.data = {} if context.data is None else context.data
    for notification_dto in notification_dto_list:
        data = notification_dto.get_dict()
        customer_profile_id = context.data[
            data["customer_profile_identifier"]
        ].customer_profile_id
        endpoint = (
            "/notification/v1/dev/notification/customer-profile-id/"
            + customer_profile_id
        )
        response = request.hugoserve_get_request(endpoint)
        check_status(response, "200")


@Then("I fetch notifications for customer profile id and check status")
def check_notification_status(context):
    request = context.request

    notification_dto_list = DataClassParser.parse_rows(
        context.table.rows, data_class=NotificationDTO
    )

    context.data = {} if context.data is None else context.data

    for notification_dto in notification_dto_list:
        data = notification_dto.get_dict()
        customer_profile_id = context.data[
            data["customer_profile_identifier"]
        ].customer_profile_id
        endpoint = "/notification/v1/customer-profile/notifications"
        time.sleep(int(notification_dto.wait_time))
        response = request.hugoserve_get_request(
            endpoint,
            {
                "to-date": str(datetime.utcnow()),
                "from-date": "2022-01-04 13:08:36.505605",
            },
            headers={"x-customer-profile-id": customer_profile_id},
        )
        check_status(response, "200")

        actual_dto = DataClassParser.dict_to_object(
            response["data"]["notifications"][0], data_class=NotificationDTO
        )

        assert actual_dto.status == notification_dto.status, (
            f"\nExpect status: {notification_dto.status}"
            f"\nActual status: {actual_dto.status}"
        )
