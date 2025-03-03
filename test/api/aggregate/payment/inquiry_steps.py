from hugoutils.utilities.dataclass_util import DataClassParser

from test.api.aggregate.payment import helper as payment_helper
from test.api.aggregate.payment.payment_dataclass import InquiryRequestDTO, BillInquiryRequestDTO
from behave import *

use_step_matcher("re")


@Then(
    "I initiate a request to inquiry an internal account ([^']*) from ([^']*) and expect the header status ([^']*) in Paysys"
)
def internal_account_inquiry(
    context, receiver_account_identifier: str, request_origin: str, status_code: str
):
    request = context.request
    inquiry_request_dto = DataClassParser.parse_row(context.table.rows[0], InquiryRequestDTO)

    receiver_account = context.data[receiver_account_identifier]['account_id']
    customer_profile_id = context.data[
        inquiry_request_dto.customer_profile_id
    ].customer_profile_id

    account_details = payment_helper.__fetch_payment_account(
        customer_profile_id, context, receiver_account
    )
    inquiry_request_dto.account_id = context.data[inquiry_request_dto.account_id]

    virtual_id_details = (
        inquiry_request_dto.receiver_details.code_details.pk_account.virtual_id_details
    )

    if virtual_id_details is None:
        inquiry_request_dto.receiver_details.code_details.pk_account.account_number = (
            account_details.account_details.code_details.pk_code_details.account_number
        )
        inquiry_request_dto.receiver_details.code_details.pk_account.bank_bic = (
            account_details.account_details.code_details.pk_code_details.bank_bic
        )
        inquiry_request_dto.receiver_details.code_details.pk_account.bank_imd = (
            account_details.account_details.code_details.pk_code_details.bank_imd
        )
        inquiry_request_dto.receiver_details.code_details.pk_account.iban = (
            account_details.account_details.code_details.pk_code_details.iban
        )

    process_inquiry_request(
        context, inquiry_request_dto, customer_profile_id, request_origin, status_code
    )


@Then(
    "I initiate a request to inquiry an external account from ([^']*) and expect the header status ([^']*) in Paysys"
)
def external_account_inquiry(context, request_origin: str, status_code: str):
    request = context.request
    inquiry_request_dto = DataClassParser.parse_row(context.table.rows[0], InquiryRequestDTO)

    customer_profile_id = context.data[
        inquiry_request_dto.customer_profile_id
    ].customer_profile_id
    virtual_id_details = (
        inquiry_request_dto.receiver_details.code_details.pk_account.virtual_id_details
    )

    if virtual_id_details is None:
        inquiry_request_dto.account_id = context.data[inquiry_request_dto.account_id]
    else:
        inquiry_request_dto.account_id = context.data[inquiry_request_dto.account_id][
            'account_id'
        ]

    process_inquiry_request(
        context, inquiry_request_dto, customer_profile_id, request_origin, status_code
    )


@Then(
    "I initiate a request to inquiry bill details on consumerId ([^']*) under category ([^']*) and billerId ([^']*) from ([^']*) and expect the header status ([^']*) and bill status ([^']*) in Paysys"
)
def bill_inquiry_success(
    context,
    consumer_id,
    biller_category,
    biller_id,
    request_origin: str,
    status_code: str,
    bill_status,
):
    request = context.request
    bill_inquiry_request_dto = DataClassParser.parse_row(
        context.table.rows[0], BillInquiryRequestDTO
    )

    customer_profile_id = context.data[
        bill_inquiry_request_dto.customer_profile_id
    ].customer_profile_id

    bill_inquiry_request_dto.account_id = context.data[bill_inquiry_request_dto.account_id][
        'account_id'
    ]

    response = request.hugoserve_post_request(
        path=f"/payment/v1/inquiry/bill",
        data=bill_inquiry_request_dto.get_dict(),
        headers=payment_helper.__get_default_payment_headers(
            customer_profile_id, request_origin
        ),
    )

    if status_code == "200":
        actual_bill_status = response["data"]["bill_status"]
        assert actual_bill_status == bill_status, (
            f"\nExpect data.bill_status: {bill_status}"
            f"\nActual data.bill_status: {response['data']['bill_status']}"
        )

    assert (
        response["headers"]["status_code"] == status_code
    ), f"\nExpected status code: {status_code}, but received: {response['headers']['status_code']}"


@Then(
    "I initiate a request to inquiry bill details on mobile prepaid consumerId ([^']*) under category ([^']*) and billerId ([^']*) from ([^']*) and expect the header status ([^']*) in Paysys"
)
def bill_inquiry_failure(
    context,
    consumer_id,
    biller_category,
    biller_id,
    request_origin: str,
    status_code: str,
):
    request = context.request
    bill_inquiry_request_dto = DataClassParser.parse_row(
        context.table.rows[0], BillInquiryRequestDTO
    )

    customer_profile_id = context.data[
        bill_inquiry_request_dto.customer_profile_id
    ].customer_profile_id

    bill_inquiry_request_dto.account_id = context.data[bill_inquiry_request_dto.account_id][
        'account_id'
    ]

    response = request.hugoserve_post_request(
        path=f"/payment/v1/inquiry/bill",
        data=bill_inquiry_request_dto.get_dict(),
        headers=payment_helper.__get_default_payment_headers(
            customer_profile_id, request_origin
        ),
    )

    assert (
        response["headers"]["status_code"] == status_code
    ), f"\nExpected status code: {status_code}, but received: {response['headers']['status_code']}"


@Then(
    "I initiate a request to inquiry bill details on consumerId ([^']*) under category ([^']*) and billerId ([^']*) from ([^']*) and expect the header status ([^']*) in Paysys"
)
def bill_inquiry_failure(
    context,
    consumer_id,
    biller_category,
    biller_id,
    request_origin: str,
    status_code: str,
):
    request = context.request
    bill_inquiry_request_dto = DataClassParser.parse_row(
        context.table.rows[0], BillInquiryRequestDTO
    )

    customer_profile_id = context.data[
        bill_inquiry_request_dto.customer_profile_id
    ].customer_profile_id

    bill_inquiry_request_dto.account_id = context.data[bill_inquiry_request_dto.account_id][
        'account_id'
    ]

    response = request.hugoserve_post_request(
        path=f"/payment/v1/inquiry/bill",
        data=bill_inquiry_request_dto.get_dict(),
        headers=payment_helper.__get_default_payment_headers(
            customer_profile_id, request_origin
        ),
    )

    assert (
        response["headers"]["status_code"] == status_code
    ), f"\nExpected status code: {status_code}, but received: {response['headers']['status_code']}"


def process_inquiry_request(
    context,
    inquiry_request_dto,
    customer_profile_id,
    request_origin,
    status_code,
):
    request = context.request
    response = request.hugoserve_post_request(
        path=f"/payment/v1/inquiry/account",
        data=inquiry_request_dto.get_dict(),
        headers=payment_helper.__get_default_payment_headers(
            customer_profile_id, request_origin
        ),
    )

    assert (
        response["headers"]["status_code"] == status_code
    ), f"\nExpected status code: {status_code}, but got: {response['headers']['status_code']}"
