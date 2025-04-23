from hugoutils.utilities.dataclass_util import DataClassParser

from tests.api.aggregate.payment import helper as payment_helper
from tests.api.aggregate.payment.payment_dataclass import (
    VirtualIdRequestDTO,
)
from behave import *

use_step_matcher("re")


@Then(
    "I intiate a request to link VirtualId to the account from ([^']*) and expect the header status ([^']*) and status as ([^']*) in Paysys"
)
def virtual_id_link(
    context, request_origin: str, status_code: str, virtual_id_status: str
):
    request = context.request

    virtual_id_out_request_dto = DataClassParser.parse_row(
        context.table.rows[0], VirtualIdRequestDTO
    )
    virtual_id_out_request_dto.account_id = context.data[
        virtual_id_out_request_dto.account_id
    ]["account_id"]

    customer_profile_id = context.data[
        virtual_id_out_request_dto.customer_profile_id
    ].customer_profile_id

    process_virtual_id_link_request(
        context,
        virtual_id_out_request_dto,
        customer_profile_id,
        request_origin,
        status_code,
        virtual_id_status,
    )


def process_virtual_id_link_request(
    context,
    virtual_id_request_dto,
    customer_profile_id,
    request_origin,
    status_code,
    virtual_id_status,
):
    virtual_id_request_dto.customer_profile_id = customer_profile_id
    request = context.request
    response = request.hugoserve_post_request(
        path=f"/payment/v1/virtual-id",
        data=virtual_id_request_dto.get_dict(),
        headers=payment_helper.__get_default_payment_headers(
            customer_profile_id, request_origin
        ),
    )

    assert (
        response["headers"]["status_code"] == status_code
    ), f"\nExpected status code: {status_code}, but got: {response['headers']['status_code']}"

    if response["headers"]["status_code"] == "200":
        assert "account_id" in response["data"], (
            f"\nExpected data object contains account_id"
            f"\nActual data: {response['data']}"
        )
        assert "virtual_id_details" in response["data"], (
            f"\nExpected data object contains virtual_id_details"
            f"\nActual data: {response['data']}"
        )

        assert response["data"]["status"] == virtual_id_status, (
            f"\nExpected status: {virtual_id_status}"
            f"\nActual status: {response['data']['status']}, data: {response['data']}"
        )
        context.data[virtual_id_request_dto.account_id] = response["data"]["account_id"]


@Then(
    "I intiate a request to unlink VirtualId to the account from ([^']*) and expect the header status ([^']*) and status as ([^']*) in Paysys"
)
def virtual_id_unlink(
    context, request_origin: str, status_code: str, virtual_id_status: str
):
    request = context.request

    virtual_id_out_request_dto = DataClassParser.parse_row(
        context.table.rows[0], VirtualIdRequestDTO
    )
    virtual_id_out_request_dto.account_id = context.data[
        virtual_id_out_request_dto.account_id
    ]["account_id"]

    customer_profile_id = context.data[
        virtual_id_out_request_dto.customer_profile_id
    ].customer_profile_id

    process_virtual_id_unlink_request(
        context,
        virtual_id_out_request_dto,
        customer_profile_id,
        request_origin,
        status_code,
        virtual_id_status,
    )


def process_virtual_id_unlink_request(
    context,
    virtual_id_request_dto,
    customer_profile_id,
    request_origin,
    status_code,
    virtual_id_status,
):
    request = context.request
    response = request.hugoserve_delete_request(
        path=f"/payment/v1/virtual-id",
        data=virtual_id_request_dto.get_dict(),
        headers=payment_helper.__get_default_payment_headers(
            customer_profile_id, request_origin
        ),
    )

    assert (
        response["headers"]["status_code"] == status_code
    ), f"\nExpected status code: {status_code}, but got: {response['headers']['status_code']}"

    if response["headers"]["status_code"] == "200":
        assert "account_id" in response["data"], (
            f"\nExpected data object contains account_id"
            f"\nActual data: {response['data']}"
        )
        assert "virtual_id_details" in response["data"], (
            f"\nExpected data object contains virtual_id_details"
            f"\nActual data: {response['data']}"
        )

        assert response["data"]["status"] == virtual_id_status, (
            f"\nExpected status: {virtual_id_status}"
            f"\nActual status: {response['data']['status']}, data: {response['data']}"
        )
        context.data[virtual_id_request_dto.account_id] = response["data"]["account_id"]


@Then(
    "I intiate a request to unlink VirtualId from an account which is not linked from ([^']*) and expect the header status ([^']*) and status as ([^']*) in Paysys"
)
def virtual_id_unlink_failure(
    context, request_origin: str, status_code: str, virtual_id_status: str
):
    request = context.request

    virtual_id_out_request_dto = DataClassParser.parse_row(
        context.table.rows[0], VirtualIdRequestDTO
    )
    virtual_id_out_request_dto.account_id = context.data[
        virtual_id_out_request_dto.account_id
    ]["account_id"]

    customer_profile_id = context.data[
        virtual_id_out_request_dto.customer_profile_id
    ].customer_profile_id

    process_virtual_id_unlink_request(
        context,
        virtual_id_out_request_dto,
        customer_profile_id,
        request_origin,
        status_code,
        virtual_id_status,
    )


def process_virtual_id_unlink_request(
    context,
    virtual_id_request_dto,
    customer_profile_id,
    request_origin,
    status_code,
    virtual_id_status,
):
    request = context.request
    response = request.hugoserve_delete_request(
        path=f"/payment/v1/virtual-id",
        data=virtual_id_request_dto.get_dict(),
        headers=payment_helper.__get_default_payment_headers(
            customer_profile_id, request_origin
        ),
    )

    assert (
        response["headers"]["status_code"] == status_code
    ), f"\nExpected status code: {status_code}, but got: {response['headers']['status_code']}"

    if response["headers"]["status_code"] == "200":
        assert "account_id" in response["data"], (
            f"\nExpected data object contains account_id"
            f"\nActual data: {response['data']}"
        )
        assert "virtual_id_details" in response["data"], (
            f"\nExpected data object contains virtual_id_details"
            f"\nActual data: {response['data']}"
        )

        assert response["data"]["status"] == virtual_id_status, (
            f"\nExpected status: {virtual_id_status}"
            f"\nActual status: {response['data']['status']}, data: {response['data']}"
        )
        context.data[virtual_id_request_dto.account_id] = response["data"]["account_id"]
