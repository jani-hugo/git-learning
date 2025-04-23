import uuid
from behave import *
from hugoutils.utilities.dataclass_util import DataClassParser
from retry import retry

from tests.api.aggregate.coa import coa_helper
from tests.api.aggregate.coa.coa_dataclass import (
    TxnCodeToLedgerRelationDTO,
    CoAFinancialEntryDTO,
    RemapTransactionDTO,
    TransactionCodeDTO,
)
from tests.util.common_util import check_status

use_step_matcher("re")


def get_coa_financial_book_id(context, customer_profile_id):
    request = context.request
    response = request.hugoserve_get_request(
        coa_helper.coa_book_urls["get_current_book_status"],
        headers=coa_helper.get_headers(customer_profile_id),
    )
    check_status(response, "200")
    return response["data"]["coa_financial_book_id"]


def fetch_aggregation_value(context, customer_profile_id, gl_code, cb_code):
    request = context.request
    coa_book_id = get_coa_financial_book_id(context, customer_profile_id)
    response = request.hugoserve_get_request(
        coa_helper.aggregation_urls["get_aggregated_general_ledger"]
        .replace("$coa-financial-book-id$", coa_book_id)
        .replace("$gl-code$", gl_code)
        .replace("$cb-code$", cb_code),
        headers=coa_helper.get_headers(customer_profile_id),
    )
    check_status(response, 200)
    return response["data"]


def print_value_tree(tree, indent=0):
    print(" " * indent + tree["node_code"] + ":" + str(tree["amount"]))
    for child in tree["children"]:
        print_value_tree(child, indent + 4)


def show_aggregated_tree_state(context, customer_profile_id, cb_code):
    request = context.request
    coa_financial_book_id = get_coa_financial_book_id(context, customer_profile_id)
    response = request.hugoserve_get_request(
        coa_helper.aggregation_urls["get_aggregated_general_ledger_tree"]
        .replace("$coa-financial-book-id$", coa_financial_book_id)
        .replace("$cb-code$", cb_code),
        headers=coa_helper.get_headers(customer_profile_id),
    )
    check_status(response, 200)
    print_value_tree(response["data"])


@Then("I map transaction to codes for customer")
def map_txn_to_txn_codes(context):
    request = context.request
    txn_code_to_ledger_relation_request_list = DataClassParser.parse_rows(
        context.table.rows, data_class=TxnCodeToLedgerRelationDTO
    )
    for txn_code_to_ledger_relation_request in txn_code_to_ledger_relation_request_list:
        data = txn_code_to_ledger_relation_request.get_dict()
        customer_profile_id = context.data["config_data"][data["customer_profile_id"]]
        data["customer_profile_id"] = customer_profile_id

        response = request.hugoserve_post_request(
            coa_helper.transaction_mapping_urls["map_transaction_code"],
            data=data,
            headers=coa_helper.get_headers(customer_profile_id),
        )
        check_status(response, txn_code_to_ledger_relation_request.status_code)


@Then("I add transactions for customer")
def add_txn(context):
    request = context.request
    coa_financial_entry_list = DataClassParser.parse_rows(
        context.table.rows, data_class=CoAFinancialEntryDTO
    )
    for coa_financial_entry in coa_financial_entry_list:
        data = coa_financial_entry.get_dict()
        customer_profile_id = context.data["config_data"][
            data["transactions"][0]["customer_profile_id"]
        ]
        data["transactions"][0]["customer_profile_id"] = customer_profile_id
        transaction_id = str(uuid.uuid4())
        context.data[data["transactions"][0]["txn_id"]] = transaction_id
        data["transactions"][0]["txn_id"] = transaction_id
        response = request.hugoserve_post_request(
            coa_helper.transaction_urls["add_transactions"],
            data=data,
            headers=coa_helper.get_headers(customer_profile_id),
        )
        check_status(response, coa_financial_entry.status_code)


@Then(
    "I check the General Ledger ([^']*) under Customer Book ([^']*) for Customer with id ([^']*) to ensure the transaction with id ([^']*) is successfully added"
)
def check_txn(context, gl_code, cb_code, customer_profile_id, txn_id):
    request = context.request
    transaction_id = context.data[txn_id]
    customer_profile_id = context.data["config_data"][customer_profile_id]
    context.data[customer_profile_id + "-AGGREGATION"] = fetch_aggregation_value(
        context, customer_profile_id, gl_code, cb_code
    )
    coa_financial_book_id = get_coa_financial_book_id(context, customer_profile_id)

    @retry(exceptions=(AssertionError, IndexError), tries=30, delay=2, logger=None)
    def wait_for_txn():
        response = request.hugoserve_get_request(
            coa_helper.general_ledger_urls["get_general_ledger_transactions"]
            .replace("$coa-financial-book-id$", coa_financial_book_id)
            .replace("$gl-code$", gl_code)
            .replace("$cb-code$", cb_code)
            + "?limit=1&order=DESC",
            headers=coa_helper.get_headers(customer_profile_id),
        )
        check_status(response, 200)
        coa_helper.assert_values(
            "Check transaction",
            customer_profile_id,
            (
                gl_code,
                transaction_id,
            ),
            (
                response["data"]["gl_code"],
                response["data"]["transaction"][0]["txn_id"],
            ),
        )

    wait_for_txn()


@Then(
    "I check the aggregated value at the gl node ([^']*) under Customer Book ([^']*) against transaction of amount ([^']*) and of type ([^']*) for customer ([^']*)"
)
def check_aggregation(context, gl_code, cb_code, amount, txn_type, customer_profile_id):
    customer_profile_id = context.data["config_data"][customer_profile_id]
    final_amount = float(amount)
    if txn_type == "DEBIT":
        final_amount = final_amount * -1

    @retry(exceptions=AssertionError, tries=30, delay=2, logger=None)
    def wait_for_agg():
        actual_data = fetch_aggregation_value(
            context, customer_profile_id, gl_code, cb_code
        )
        previous_data = context.data[customer_profile_id + "-AGGREGATION"]
        coa_helper.assert_values(
            "Check Aggregation",
            customer_profile_id,
            (
                round(
                    previous_data["amount"] + final_amount,
                    2,
                )
            ),
            (actual_data["amount"]),
        )

    wait_for_agg()
    show_aggregated_tree_state(context, customer_profile_id, cb_code)


@Then("I manually remap the transaction to correct General Ledger")
def remap_transaction(context):
    request = context.request

    remap_transaction_list = DataClassParser.parse_rows(
        context.table.rows, data_class=RemapTransactionDTO
    )
    for remap_transaction in remap_transaction_list:
        data = remap_transaction.get_dict()
        customer_profile_id = context.data["config_data"][data["customer_profile_id"]]
        data["customer_profile_id"] = customer_profile_id
        data["txn_id"] = context.data[data["txn_id"]]
        data["coa_book_id"] = get_coa_financial_book_id(context, customer_profile_id)
        response = request.hugoserve_put_request(
            coa_helper.transaction_urls["remap_transactions"],
            data=data,
            headers=coa_helper.get_headers(customer_profile_id),
        )
        check_status(response, remap_transaction.status_code)


@Then("I add transaction codes to CORE module")
def add_txn_code_to_code(context):
    request = context.request
    transaction_code_dto_list = DataClassParser.parse_rows(
        context.table.rows, data_class=TransactionCodeDTO
    )
    for transaction_code_dto in transaction_code_dto_list:
        data = transaction_code_dto.get_dict()
        customer_profile_id = context.data["config_data"][
            transaction_code_dto.customer_profile_id
        ]
        response = request.hugoserve_post_request(
            coa_helper.core_helper_urls["add_transaction_codes"],
            data=data,
            headers=coa_helper.get_headers(customer_profile_id),
        )
        check_status(response, transaction_code_dto.status_code)
