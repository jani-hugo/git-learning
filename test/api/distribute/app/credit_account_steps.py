import time
from datetime import datetime

from behave import *
from hugoutils.utilities.dataclass_util import DataClassParser

import test.api.distribute.app.app_helper as ah
from test.api.distribute.app.app_dataclass import CreditAccountMockTxnRequestDTO
from test.util.common_util import check_status_distribute

use_step_matcher("re")

transfer_out_account_numbers = ['']


@Then("I initiate transactions on the credit account for user profile id ([^']*)")
def initiate_mock_transactions(context, user_profile_id):
    request = context.request
    context.data = {} if context.data is None else context.data
    context.data['users'] = (
        {} if context.data.get("users", None) is None else context.data['users']
    )

    user_details_response = request.hugosave_get_request(
        ah.user_profile_urls["details"],
        headers=ah.get_user_header(user_profile_id, context),
    )
    if not check_status_distribute(user_details_response, "200"):
        assert (
            False
        ), f"Error getting user details for user profile id {user_profile_id}"

    context.data['users'][user_profile_id] = user_details_response['data']

    credit_accounts_response = request.hugosave_get_request(
        ah.user_profile_urls["credit-account-list"],
        headers=ah.get_user_header(user_profile_id, context),
    )

    if not check_status_distribute(credit_accounts_response, "200"):
        assert (
            False
        ), f"Error getting user credit account list for user profile id {user_profile_id}"

    context.data['users'][user_profile_id]['credit_account_details'] = \
        credit_accounts_response['data']['creditAccounts'][0]

    credit_account_id = credit_accounts_response['data']['creditAccounts'][0]['creditAccountId']

    create_mock_transaction_dtos = DataClassParser.parse_rows(
        context.table.rows, data_class=CreditAccountMockTxnRequestDTO
    )

    mock_request_dto = {
        "credit_account_id": credit_account_id,
        "mock_txns": [txn.get_dict() for txn in create_mock_transaction_dtos],
        "transfer_out_account_details": {
            "account_holder_name": "Snow",
            "country": "SGP",
            "currency": "SGD",
            "bank_name": "DBS Bank Ltd",
            "code_details": {
                "sg_bank_details": {
                    "swift_bic": "DBSSSGSGXXX",
                    "account_number": "88532600022681613"
                }
            }
        }
    }

    mock_txn_response = request.hugosave_post_request(
        ah.dev_urls['credit_mock_txn'],
        data=mock_request_dto,
        headers=ah.get_user_header(user_profile_id, context),
    )

    check_status_distribute(mock_txn_response, '200')
    time.sleep(7.5)

    # TODO: add steps to check same no of credit txn intents in DB (priyanka@)


@then("I get balance for credit balance")
def step_impl(context):
    request = context.request
    user_profile_id = context.data['users'][list(context.data['users'].keys())[0]]['userProfileId']
    credit_account_id = context.data['users'][user_profile_id]['credit_account_details'][
        'creditAccountId']

    time.sleep(5)
    get_credit_limit_response = request.hugosave_get_request(
        ah.cms_urls["balance"].replace("account-id", credit_account_id),
        headers=ah.get_user_header(user_profile_id, context),
    )

    check_status_distribute(get_credit_limit_response, '200')


@then("I request to generate bill for ([^']*) for date ([^']*)")
def step_impl(context, user_profile_id, bill_date):
    request = context.request
    credit_account_id = context.data['users'][user_profile_id]['credit_account_details'][
        'creditAccountId']

    generate_bill_request_dto = {
        "credit_account_id": credit_account_id,
        "bill_date": bill_date + datetime.now().strftime("T%H:%M:%S.%fZ")
    }

    get_credit_limit_response = request.hugosave_post_request(
        ah.dev_urls["generate_credit_bills"],
        headers=ah.get_user_header(user_profile_id, context),
        data=generate_bill_request_dto
    )

    check_status_distribute(get_credit_limit_response, '200')
    time.sleep(5)


@then("I request to get bills")
def step_impl(context):
    request = context.request
    user_profile_id = context.data['users'][list(context.data['users'].keys())[0]]['userProfileId']
    credit_account_id = context.data['users'][user_profile_id]['credit_account_details'][
        'creditAccountId']

    credit_account_bills_response = request.hugosave_get_request(
        ah.cms_urls["bills"].replace("account-id", credit_account_id),
        headers=ah.get_user_header(user_profile_id, context),
    )

    check_status_distribute(credit_account_bills_response, '200')

    print("Bill for account - ", credit_account_bills_response['data'])
