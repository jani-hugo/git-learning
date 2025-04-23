import random
from behave import *
from datetime import datetime

from hugoutils.utilities.dataclass_util import DataClassParser

from tests.api.aggregate.payment import helper as payment_helper
from tests.api.aggregate.payment.payment_dataclass import (
    PaysysPKInboundTitleFetchRequest,
)

use_step_matcher("re")


@Then(
    "I initiate a request to inquiry an account ([^']*) to validate the account to initiate a credit payment of amount ([^']*) from initiator ([^']*) and expect the response status ([^']*)"
)
def inbound_title_fetch(
    context, account_identifier: str, amount: float, initiator: str, status_code: str
):
    payment_helper.__validate_provider("PAYSYS")

    account_id = context.data[account_identifier]["account_id"]
    customer_profile_id = context.data[account_identifier]["customer_profile_id"]

    account_details = payment_helper.__fetch_payment_account(
        customer_profile_id, context, account_id
    )
    request = context.request

    inbound_title_fetch_request_dto = DataClassParser.parse_row(
        context.table.rows[0], PaysysPKInboundTitleFetchRequest
    )

    current_date_time = datetime.now()
    inbound_title_fetch_request_dto.txn_info.info.rrn = random.randint(
        10**11, 10**12 - 1
    )
    inbound_title_fetch_request_dto.txn_info.info.stan = current_date_time.strftime(
        "%H%M%S"
    )
    inbound_title_fetch_request_dto.txn_info.info.txndate = current_date_time.strftime(
        "%Y%m%d"
    )
    inbound_title_fetch_request_dto.txn_info.info.txntime = current_date_time.strftime(
        "%H%M%S"
    )
    inbound_title_fetch_request_dto.txn_info.info.initiator = initiator

    inbound_title_fetch_request_dto.txn_info.receiverinfo.to_account = (
        account_details.account_details.code_details.pk_code_details.iban
    )

    inbound_title_fetch_request_dto.txn_info.payment_info.amount = amount

    response = request.hugoserve_post_request(
        path="/payment/paysys/pk/inquiry/title-fetch",
        data=inbound_title_fetch_request_dto.txn_info.get_dict(),
    )

    assert response["response"]["response_code"] == "200"


@Then(
    "I initiate a request to inquiry an account ([^']*) to validate the account to initiate a credit payment of amount ([^']*) from initiator ([^']*) and expect the failure response status ([^']*)"
)
def inbound_title_fetch(
    context, account_identifier: str, amount: float, initiator: str, status_code: str
):
    payment_helper.__validate_provider("PAYSYS")

    request = context.request

    inbound_title_fetch_request_dto = DataClassParser.parse_row(
        context.table.rows[0], PaysysPKInboundTitleFetchRequest
    )

    current_date_time = datetime.now()
    inbound_title_fetch_request_dto.txn_info.info.rrn = random.randint(
        10**11, 10**12 - 1
    )
    inbound_title_fetch_request_dto.txn_info.info.stan = current_date_time.strftime(
        "%H%M%S"
    )
    inbound_title_fetch_request_dto.txn_info.info.txndate = current_date_time.strftime(
        "%Y%m%d"
    )
    inbound_title_fetch_request_dto.txn_info.info.txntime = current_date_time.strftime(
        "%H%M%S"
    )
    inbound_title_fetch_request_dto.txn_info.info.initiator = initiator

    inbound_title_fetch_request_dto.txn_info.payment_info.amount = amount

    response = request.hugoserve_post_request(
        path="/payment/paysys/pk/inquiry/title-fetch",
        data=inbound_title_fetch_request_dto.txn_info.get_dict(),
    )

    assert response["response"]["response_code"] == "001"
