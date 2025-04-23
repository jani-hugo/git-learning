import copy
from json.decoder import JSONDecodeError

from behave import *
from hugoutils.utilities.dataclass_util import DataClassParser
from retry import retry

from test.api.aggregate.cms import cms_helper
from test.api.aggregate.cms.cms_dataclass import DevCARepaymentRequestDTO
from test.api.aggregate.cms.cms_dataclass import TransactionRequestDTO, CreateTransactionLimitDTO
from test.util.common_util import check_status


def get_credit_account_balance(request, customer_profile_id, account_id):
    response = request.hugoserve_get_request(
        cms_helper.credit_account_urls["balance"].replace("$account_id$", account_id),
        headers=cms_helper.get_headers(customer_profile_id),
    )
    check_status(response, "200")
    return response["data"]


def assert_balance_settlement_status(response, settled_amount, approved_limit):
    available_credit_balance = approved_limit - settled_amount

    cms_helper.assert_values(
        "settled_amount_check", "", response["settled_amount"], settled_amount
    )
    cms_helper.assert_values(
        "unsettled_amount_check", "", 0, response["unsettled_amount"]
    )
    cms_helper.assert_values(
        "credit_balance_check",
        "",
        response["available_credit"],
        available_credit_balance,
    )


def update_balance(ledger, amount, sign):
    if sign:
        ledger['total_balance'] += amount
        ledger['available_balance'] += amount
    else:
        ledger['total_balance'] = amount
        ledger['available_balance'] = amount
    return ledger


def adjust_ledger(key, is_credit, modified, remaining_amount, case):
    if key in modified:
        ledger = modified[key]
        if is_credit:
            ledger = update_balance(ledger, remaining_amount, True)
        else:
            if case == "no_dues":
                ledger = update_balance(ledger, -remaining_amount, False)
            else:
                diff = ledger['available_balance'] - remaining_amount
                ledger = update_balance(ledger, max(0, diff), False)
                remaining_amount = max(0, -diff)
        modified[key] = ledger
    return remaining_amount


def update_ledgers(ledgers, case, amount):
    modified = copy.deepcopy(ledgers)
    remaining_amount = amount

    if case == "highest_priority" or case == "dues_spread_across_buckets":
        adjust_ledger('CA_AVAILABLE', True, modified, remaining_amount, case)
        remaining_amount = adjust_ledger('STD_001', False, modified, remaining_amount, case)
        adjust_ledger('IMD_002', False, modified, remaining_amount, case)
    elif case == "no_dues":
        adjust_ledger('CA_AVAILABLE', True, modified, remaining_amount, case)
        adjust_ledger('STD_001', False, modified, remaining_amount, case)
    elif case == "excess_repayment":
        adjust_ledger('CA_AVAILABLE', True, modified, remaining_amount, case)
        remaining_amount = adjust_ledger('STD_001', False, modified, remaining_amount, case)
        remaining_amount = adjust_ledger('IMD_002', False, modified, remaining_amount, case)
        if 'STD_001' in modified:
            modified['STD_001']['available_balance'] = -remaining_amount
            modified['STD_001']['total_balance'] = -remaining_amount

    return modified


use_step_matcher("re")


@Given("I fetch and set approved limit for the below credit account")
def set_approved_limit(context):
    request = context.request
    customer_profile_id = context.data["config_data"]["customer_profile_id"]
    account_id = ""

    for row in context.table:
        account_id = context.data[row["credit_account_id"]]

    response = get_credit_account_balance(request, customer_profile_id, account_id)

    if "account_id" not in context.data:
        context.data["account_id"] = {}

    if account_id not in context.data["account_id"]:
        context.data["account_id"][account_id] = {}

    if "approved_limit" not in context.data["account_id"][account_id]:
        context.data["account_id"][account_id]["approved_limit"] = response[
            "available_credit"
        ]


@Then(
    "I create below transaction and verify the transaction status as ([^']*) and status code as ([^']*)"
)
def create_transaction(context, expected_txn_status, expected_status_code):
    request = context.request
    customer_profile_id = context.data["config_data"]["customer_profile_id"]
    transaction_data = DataClassParser.parse_rows(
        context.table.rows, data_class=TransactionRequestDTO
    )
    account_id = ""

    for row in context.table:
        if row["credit_account_id"] != "EMPTY":
            account_id = row["credit_account_id"]

    for transaction in transaction_data:
        if (
                transaction.credit_account_id in context.data
                and context.data[transaction.credit_account_id]
        ):
            account_id = context.data[transaction.credit_account_id]

        data = transaction.get_dict(
            cms_helper.get_txn_receiver_group(transaction.receiver), account_id
        )

        response = request.hugoserve_post_request(
            cms_helper.txn_urls["create"],
            data=data,
            headers=cms_helper.get_headers(customer_profile_id),
        )

        if expected_status_code != "200":
            check_status(response, expected_status_code)
        else:
            txn_id = response["data"]["transaction_id"]
            if txn_id:
                if "transactions" not in context.data["account_id"][account_id]:
                    context.data["account_id"][account_id]["transactions"] = []

                context.data["account_id"][account_id]["transactions"].append(
                    {"txn_id": txn_id, "amount": transaction.amount}
                )
            else:
                raise Exception("Transaction ID not found in the response")

            check_status(response, expected_status_code)

            @retry(exceptions=AssertionError, tries=60, delay=2, logger=None)
            def retry_for_txn_get_status():
                get_response = request.hugoserve_get_request(
                    cms_helper.txn_urls["get"].replace("$transaction_id$", txn_id),
                    headers=cms_helper.get_headers(customer_profile_id),
                )
                cms_helper.assert_values(
                    "transaction_status",
                    txn_id,
                    expected_txn_status,
                    get_response["data"]["txn_status"],
                )

            if expected_status_code == "200":
                retry_for_txn_get_status()


@Then(
    "I verify the credit account balance after the transaction and status code as ([^']*)"
)
def verify_latest_credit_account_balance(context, expected_status_code):
    request = context.request
    customer_profile_id = context.data["config_data"]["customer_profile_id"]
    account_id = ""

    for row in context.table:
        account_id = context.data[row["credit_account_id"]]

    approved_limit = context.data["account_id"][account_id]["approved_limit"]

    transactions = list(context.data["account_id"][account_id]["transactions"])
    settled_amount = sum(txn["amount"] for txn in transactions)

    response = get_credit_account_balance(request, customer_profile_id, account_id)
    assert_balance_settlement_status(response, settled_amount, approved_limit)


@Then(
    "I create below transaction limit and verify the transaction status code as ([^']*)"
)
def create_transaction_limit(context, expected_status_code):
    request = context.request
    customer_profile_id = context.data["config_data"]["customer_profile_id"]
    transaction_limit_data = DataClassParser.parse_rows(
        context.table.rows, data_class=CreateTransactionLimitDTO
    )
    product_id = ""

    for row in context.table:
        if row["product_id"] != "EMPTY":
            product_id = row["product_id"]

    for transaction in transaction_limit_data:
        if (
                transaction.product_id in context.data
                and context.data[transaction.product_id]
        ):
            product_id = context.data[transaction.product_id]
        data = transaction.get_dict(
            cms_helper.get_txn_rule_group(transaction.rule_group), product_id
        )

        response = request.hugoserve_post_request(
            cms_helper.txn_limit_urls["create"],
            data=data,
            headers=cms_helper.get_headers(customer_profile_id),
        )

        if expected_status_code != "200":
            check_status(response, expected_status_code)
        else:
            limit_id = response["data"]["limit_id"]
            if limit_id:

                if product_id not in context.data:
                    context.data[product_id] = []

                context.data[product_id].append(
                    {"limit_id": limit_id}
                )
            else:
                raise Exception("Limit ID not found in the response")

            check_status(response, expected_status_code)

            @retry(exceptions=AssertionError, tries=60, delay=2, logger=None)
            def retry_for_txn_limit_get_status():
                request.hugoserve_get_request(
                    cms_helper.txn_limit_urls["get"].replace("$transaction-limit-id$", limit_id),
                    headers=cms_helper.get_headers(customer_profile_id),
                )
                check_status(response, expected_status_code)

            if expected_status_code == "200":
                retry_for_txn_limit_get_status()


@Then(
    "I Initiate Dev CA Repayment and verify transaction status as ([^']*) and status code as ([^']*)"
)
def verify_payment_dev_deposit_repayment(context, expected_txn_status, expected_status_code):
    request = context.request
    customer_profile_id = ""
    credit_account_id = ""
    amount = context.table[0]["amount"]

    if context.table[0]["customer_profile_id"] != "EMPTY":
        customer_profile_id = context.data["config_data"]["customer_profile_id"]

    if context.table[0]["credit_account_id"] != "EMPTY":
        credit_account_id = context.data.get(context.table[0]["credit_account_id"])

    dev_deposit_repayment_data_rows = DataClassParser.parse_rows(
        context.table.rows, data_class=DevCARepaymentRequestDTO
    )

    for dev_deposit_repayment_data in dev_deposit_repayment_data_rows:
        if dev_deposit_repayment_data:
            response = request.hugoserve_post_request(
                cms_helper.dev_urls["credit_account_repayment"],
                data=dev_deposit_repayment_data.get_dict(credit_account_id, customer_profile_id),
            )

            check_status(response, expected_status_code)

            if expected_status_code == "200":
                context.data.setdefault("fund_account", {})["payment_txn_id"] = response["data"]["payment_transaction_id"]
                context.data["fund_account"]["fund_txn_amount"] = amount
                cms_helper.assert_values(
                    "Transaction Status", "PAYMENT_TXN_ID",
                    expected_txn_status,
                    response["data"]["txn_status"]
                )


@Then(
    "I fetch and verify the service transaction from fund transaction and verify status code as ([^']*)"
)
def verify_fund_service_txn(context, expected_status_code):
    request = context.request
    expected_prefix = "RCT-TXN##"
    payment_txn_id = context.data["fund_account"]["payment_txn_id"]

    @retry(exceptions=AssertionError, tries=60, delay=2, logger=None)
    def retry_for_txn_get_status():
        url = cms_helper.dev_urls["get_fund_txn"].replace(
            "$payment-transaction-id$", payment_txn_id
        )
        response = request.hugoserve_get_request(url)

        check_status(response, expected_status_code)

        service_txn_id = response["data"].get("service_transaction_id")
        assert service_txn_id, "service_transaction_id not present in response data"

        context.data["fund_account"]["txn_id"] = service_txn_id[9:]

        cms_helper.assert_values(
            "Service Txn", "Prefix", expected_prefix, service_txn_id[:9]
        )

    retry_for_txn_get_status()


@Then(
    "I fetch the credit repayment transaction and verify transaction status as ([^']*) and status code as ([^']*)"
)
def verify_rc_repayment_txn(context, expected_txn_status, expected_status_code):
    request = context.request
    customer_profile_id = context.data["config_data"]["customer_profile_id"]
    txn_id = context.data["fund_account"]["txn_id"]

    @retry(exceptions=(AssertionError, JSONDecodeError), tries=120, delay=2, logger=None)
    def retry_for_txn_get_status():
        url = cms_helper.txn_urls["get"].replace("$transaction_id$", txn_id)
        headers = cms_helper.get_headers(customer_profile_id)

        response = request.hugoserve_get_request(url, headers=headers)

        check_status(response, expected_status_code)

        actual_status = response["data"].get("txn_status")
        cms_helper.assert_values("RC_REPAYMENT_TXN", "TXN", expected_txn_status, actual_status)

    retry_for_txn_get_status()


@Given("I fetch the original ledgers balances for credit account and verify status code as ([^']*)")
def fetch_original_ledger_balances(context, expected_status_code):
    request = context.request
    customer_profile_id = context.data["config_data"]["customer_profile_id"]
    credit_account_id = context.data.get(context.table[0]["credit_account_id"])

    @retry(exceptions=(AssertionError, JSONDecodeError), tries=120, delay=2, logger=None)
    def retry_for_ledger_balance():
        url = cms_helper.dev_urls["ledger_balance"].replace("$account_id$", credit_account_id)
        headers = cms_helper.get_headers(customer_profile_id)
        response = request.hugoserve_get_request(url, headers=headers)

        check_status(response, expected_status_code)

        ledgers_dict = {
            ledger['ledger_type']: {
                'ledger_id': ledger['ledger_id'],
                'total_balance': float(ledger['total_balance']),
                'available_balance': float(ledger['available_balance'])
            } for ledger in response['data']['ledger_balances']
        }

        context.data['ledgers'] = ledgers_dict

    retry_for_ledger_balance()


@Then("I fetch and verify the latest ledgers balances for credit account and verify status code as ([^']*)")
def fetch_latest_ledger_balances(context, expected_status_code):
    request = context.request
    customer_profile_id = context.data["config_data"]["customer_profile_id"]
    credit_account_id = context.data.get(context.table[0]["credit_account_id"])
    case = context.table[0]["case"]

    @retry(exceptions=(AssertionError, JSONDecodeError), tries=2, delay=2, logger=None)
    def retry_for_ledger_balance():
        url = cms_helper.dev_urls["ledger_balance"].replace("$account_id$", credit_account_id)
        headers = cms_helper.get_headers(customer_profile_id)
        response = request.hugoserve_get_request(url, headers=headers)

        check_status(response, expected_status_code)

        old_ledgers = copy.deepcopy(context.data['ledgers'])
        amount = float(context.data["fund_account"]["fund_txn_amount"])
        updated_ledgers = update_ledgers(old_ledgers, case, amount)

        latest_ledgers = {
            ledger['ledger_type']: {
                'ledger_id': ledger['ledger_id'],
                'total_balance': float(ledger['total_balance']),
                'available_balance': float(ledger['available_balance'])
            } for ledger in response['data']['ledger_balances']
        }

        for key in ['CA_AVAILABLE', 'STD_001', 'IMD_002']:
            if key in updated_ledgers:
                cms_helper.assert_values('total_balance', "tb", updated_ledgers[key]['total_balance'],
                                         latest_ledgers[key]['total_balance'])
                cms_helper.assert_values('available_balance', "ab", updated_ledgers[key]['available_balance'],
                                         latest_ledgers[key]['available_balance'])

    retry_for_ledger_balance()
