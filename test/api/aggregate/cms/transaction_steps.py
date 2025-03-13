from behave import *
from hugoutils.utilities.dataclass_util import DataClassParser
from retry import retry

from test.api.aggregate.cms import cms_helper
from test.api.aggregate.cms.cms_dataclass import (
    TransactionRequestDTO
)
from test.util.common_util import check_status


def get_credit_account_balance(request, customer_profile_id, account_id):
    response = request.hugoserve_get_request(
        cms_helper.credit_account_urls['balance'].replace('$account_id$', account_id),
        headers=cms_helper.get_headers(customer_profile_id),
    )
    check_status(response, '200')
    return response['data']


def assert_balance_settlement_status(response, settled_amount, approved_limit):
    available_credit_balance = approved_limit - settled_amount

    cms_helper.assert_values("settled_amount_check", "", response['settled_amount'], settled_amount)
    cms_helper.assert_values("unsettled_amount_check", "", 0, response['unsettled_amount'])
    cms_helper.assert_values("credit_balance_check", "", response['available_credit'],
                             available_credit_balance)


use_step_matcher("re")


@Given("I fetch and set approved limit for the below credit account")
def set_approved_limit(context):
    request = context.request
    customer_profile_id = context.data['config_data']['customer_profile_id']
    account_id = ""

    for row in context.table:
        account_id = context.data[row['credit_account_id']]

    response = get_credit_account_balance(request, customer_profile_id, account_id)

    if 'account_id' not in context.data:
        context.data['account_id'] = {}

    if account_id not in context.data['account_id']:
        context.data['account_id'][account_id] = {}

    if 'approved_limit' not in context.data['account_id'][account_id]:
        context.data['account_id'][account_id]['approved_limit'] = response['available_credit']


@Then("I create below transaction and verify the transaction status as ([^']*) and status code as ([^']*)")
def create_transaction(context, expected_txn_status, expected_status_code):
    request = context.request
    customer_profile_id = context.data['config_data']['customer_profile_id']
    transaction_data = DataClassParser.parse_rows(context.table.rows, data_class=TransactionRequestDTO)
    account_id = ""

    for row in context.table:
        if row['credit_account_id'] != 'EMPTY':
            account_id = row['credit_account_id']

    for transaction in transaction_data:
        if transaction.credit_account_id in context.data and context.data[transaction.credit_account_id]:
            account_id = context.data[transaction.credit_account_id]
        data = transaction.get_dict(cms_helper.get_txn_receiver_group(transaction.receiver), account_id)

        response = request.hugoserve_post_request(
            cms_helper.txn_urls["create"],
            data=data,
            headers=cms_helper.get_headers(customer_profile_id),
        )

        if expected_status_code != "200":
            check_status(response, expected_status_code)
        else:
            txn_id = response['data']['transaction_id']
            if txn_id:
                if 'transactions' not in context.data['account_id'][account_id]:
                    context.data['account_id'][account_id]['transactions'] = []

                context.data['account_id'][account_id]['transactions'].append({
                    "txn_id": txn_id,
                    "amount": transaction.amount
                })
            else:
                raise Exception("Transaction ID not found in the response")

            check_status(response, expected_status_code)

            @retry(exceptions=AssertionError, tries=60, delay=2, logger=None)
            def retry_for_txn_get_status():
                get_response = request.hugoserve_get_request(
                    cms_helper.txn_urls["get"].replace('$transaction_id$', txn_id),
                    headers=cms_helper.get_headers(customer_profile_id),
                )
                cms_helper.assert_values(
                    "transaction_status",
                    txn_id,
                    expected_txn_status,
                    get_response['data']['txn_status'],
                )

            if expected_status_code == '200':
                retry_for_txn_get_status()


@Then("I verify the credit account balance after the transaction and status code as ([^']*)")
def verify_latest_credit_account_balance(context, expected_status_code):
    request = context.request
    customer_profile_id = context.data['config_data']['customer_profile_id']
    account_id = ""

    for row in context.table:
        account_id = context.data[row['credit_account_id']]

    approved_limit = context.data['account_id'][account_id]['approved_limit']

    transactions = list(context.data['account_id'][account_id]['transactions'])
    settled_amount = sum(txn['amount'] for txn in transactions)

    response = get_credit_account_balance(request, customer_profile_id, account_id)
    assert_balance_settlement_status(response, settled_amount, approved_limit)
