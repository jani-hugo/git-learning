import uuid
from behave import *
from hugoutils.utilities.dataclass_util import DataClassParser
from retry import retry

from tests.api.aggregate.cms import cms_helper
from tests.api.aggregate.cms.cms_dataclass import (
    AttachCardRequest,
    AuthorizationDTO,
    TransactionRequest,
    ClearTransactionRequest,
    ClearingRequestDTO,
    AuthorizationUpdateDTO,
    RevertTransactionRequest,
    ReconcileClearingRequest,
    SendRequest,
)
from tests.util.common_util import check_status

use_step_matcher("re")

balance_context_key = "-BALANCE"
ledger_context_key = "-LEDGER-BALANCES"


def get_credit_account_balance(request, customer_profile_id, account_id):
    response = request.hugoserve_get_request(
        cms_helper.credit_account_urls["balance"].replace("$account_id$", account_id),
        headers=cms_helper.get_headers(customer_profile_id),
    )
    check_status(response, "200")
    return response["data"]


def get_collection_account_balance(request):
    response = request.hugoserve_get_request(cms_helper.dev_urls["collection_balance"])
    check_status(response, "200")
    return response["data"]


def get_ledger_balances(request, customer_profile_id, account_id):
    response = request.hugoserve_get_request(
        cms_helper.dev_urls["ledger_balance"].replace("$account_id$", account_id),
        headers=cms_helper.get_headers(customer_profile_id),
    )
    check_status(response, "200")
    return response["data"]


def filter_ledger_balance(data, category):
    for balance in data:
        if balance["ledger_type"] == category:
            return balance


def get_expected_ledger_balance(context, account_id):
    return {
        "0": filter_ledger_balance(
            context.data[account_id + ledger_context_key], "AVAILABLE"
        ),
        "1": filter_ledger_balance(
            context.data[account_id + ledger_context_key],
            "LENT_STANDARD_INTEREST",
        ),
        "2": filter_ledger_balance(
            context.data[account_id + ledger_context_key],
            "LENT_CASH",
        ),
        "3": filter_ledger_balance(
            context.data[account_id + ledger_context_key],
            "LENT_NO_INTEREST",
        ),
    }


def get_actual_ledger_balance(ledger_balance_response):
    return {
        "0": filter_ledger_balance(
            ledger_balance_response["ledger_balances"], "AVAILABLE"
        ),
        "1": filter_ledger_balance(
            ledger_balance_response["ledger_balances"], "LENT_STANDARD_INTEREST"
        ),
        "2": filter_ledger_balance(
            ledger_balance_response["ledger_balances"], "LENT_CASH"
        ),
        "3": filter_ledger_balance(
            ledger_balance_response["ledger_balances"], "LENT_NO_INTEREST"
        ),
    }


def get_prev_balance(context, account_id):
    return context.data.get(account_id + balance_context_key, {})


def get_transaction_details(request, customer_profile_id, transaction_id):
    response = request.hugoserve_get_request(
        cms_helper.card_txn_urls["get_txn"].replace("$transaction_id$", transaction_id),
        headers=cms_helper.get_headers(customer_profile_id, "CARD"),
    )
    check_status(response, "200")
    return response["data"]


@Then("I attach card to below credit accounts")
def attach_card_to_account(context):
    request = context.request
    customer_profile_id = context.data["config_data"]["customer_profile_id"]
    attach_card_list = DataClassParser.parse_rows(
        context.table.rows, data_class=AttachCardRequest
    )

    for attach_card_req in attach_card_list:
        response = request.hugoserve_post_request(
            cms_helper.card_txn_urls["attach"],
            data={
                "customer_profile_id": customer_profile_id,
                "account_id": context.data[attach_card_req.account_id],
                # 'end_customer_profile_id': context.data[
                #     attach_card_req.end_customer_profile_id
                # ].end_customer_profile_id,
                # 'funding_account_id': context.data[attach_card_req.account_id],
            },
            headers=cms_helper.get_headers(customer_profile_id, "CARD"),
        )
        check_status(response, "200")


@Then("I create below auth transactions and verify balances")
def create_transaction(context):
    request = context.request
    customer_profile_id = context.data["config_data"]["customer_profile_id"]
    transaction_list = DataClassParser.parse_rows(
        context.table.rows, data_class=AuthorizationDTO
    )

    for transaction in transaction_list:
        account_id = context.data[transaction.account_id]
        data = transaction.get_dict(account_id)

        # caching here only because its not present in cache yet
        balance_response = get_credit_account_balance(
            request, customer_profile_id, account_id
        )
        context.data[account_id + balance_context_key] = balance_response
        ledger_balance_response = get_ledger_balances(
            request, customer_profile_id, account_id
        )
        context.data[account_id + ledger_context_key] = ledger_balance_response[
            "ledger_balances"
        ]
        response = request.hugoserve_post_request(
            cms_helper.card_txn_urls["auth"],
            data=data,
            headers=cms_helper.get_headers(customer_profile_id, "CARD"),
        )
        check_status(response, transaction.status_code)

        if (
            transaction.status_code
            == cms_helper.status_codes["txn_rejected_insufficient_credit"]
        ):
            balance_response = get_credit_account_balance(
                request, customer_profile_id, account_id
            )
            cms_helper.assert_values(
                "Available credit",
                "N/A",
                get_prev_balance(context, account_id).get("available_credit", 0),
                balance_response["available_credit"],
            )
            return

        # TODO: Get transaction by id and check txn amount equal
        cms_helper.assert_values(
            "Transaction status",
            transaction.transaction_id,
            transaction.status,
            response["data"]["transaction_status"],
        )

        balance_response = get_credit_account_balance(
            request, customer_profile_id, account_id
        )
        ledger_balance_response = get_ledger_balances(
            request, customer_profile_id, account_id
        )

        expected_available_credit = round(
            get_prev_balance(context, account_id).get("available_credit", 0)
            - transaction.amount,
            2,
        )
        cms_helper.assert_values(
            "Available credit",
            transaction.transaction_id,
            expected_available_credit,
            balance_response["available_credit"],
        )

        expected_unsettled_amount = round(
            get_prev_balance(context, account_id).get("unsettled_amount", 0)
            + transaction.amount,
            2,
        )
        cms_helper.assert_values(
            "Unsettled Amount",
            transaction.transaction_id,
            expected_unsettled_amount,
            balance_response["unsettled_amount"],
        )

        expected_ledger_balance = get_expected_ledger_balance(context, account_id)
        actual_ledger_balance = get_actual_ledger_balance(ledger_balance_response)
        expected_ledger_balance["0"]["available_balance"] = round(
            expected_ledger_balance["0"]["available_balance"] - transaction.amount,
            2,
        )
        expected_ledger_balance[transaction.metadata["Category"]]["total_balance"] = (
            round(
                expected_ledger_balance[transaction.metadata["Category"]][
                    "total_balance"
                ]
                + transaction.amount,
                2,
            )
        )
        cms_helper.assert_values(
            "Ledger_balances",
            account_id,
            expected_ledger_balance,
            actual_ledger_balance,
        )
        collection_balance_response = get_collection_account_balance(request)
        context.data["collection_account" + balance_context_key] = (
            collection_balance_response
        )
        context.data[account_id + balance_context_key] = balance_response
        context.data[account_id + ledger_context_key] = ledger_balance_response[
            "ledger_balances"
        ]
        context.data[transaction.transaction_id] = {
            "transaction_id": response["data"]["transaction_id"],
            "account_id": account_id,
            "amount": transaction.amount,
            "txn_category": transaction.metadata["Category"],
        }


@Then("I clear below transactions")
def clear_transaction(context):
    request = context.request
    customer_profile_id = context.data["config_data"]["customer_profile_id"]
    clear_txn_list = DataClassParser.parse_rows(
        context.table.rows, data_class=ClearingRequestDTO
    )

    for clear_txn in clear_txn_list:
        transaction_details = context.data[clear_txn.transaction_id]
        data = clear_txn.get_dict()

        data["transaction_id"] = transaction_details["transaction_id"]
        if data["clearing_group_id"] not in context.data:
            context.data[data["clearing_group_id"]] = str(uuid.uuid4())
        data["clearing_group_id"] = context.data[data["clearing_group_id"]]

        response = request.hugoserve_post_request(
            cms_helper.card_txn_urls["clear"],
            data=data,
            headers=cms_helper.get_headers(customer_profile_id, "CARD"),
        )
        check_status(response, clear_txn.status_code)
        if clear_txn.status_code != "200":
            return
        account_id = transaction_details["account_id"]

        @retry(exceptions=AssertionError, tries=30, delay=2, logger=None)
        def wait_for_txn_settled(transaction_id, expected_amount, expected_status):
            data = get_transaction_details(request, customer_profile_id, transaction_id)

            cms_helper.assert_values(
                "Transaction status",
                transaction_id,
                expected_status,
                data["status"],
            )
            cms_helper.assert_values(
                "Transaction amount",
                transaction_id,
                expected_amount,
                data["amount"],
            )

        if clear_txn.amount < transaction_details["amount"]:
            less_amt = round(transaction_details["amount"] - clear_txn.amount, 2)

            # TODO:
            #   (response) will have partial txn id
            #   get txn details and check if amt is same as clear_txn.transaction_amount

            wait_for_txn_settled(
                response["data"]["transaction_id"],
                clear_txn.amount,
                "TRANSACTION_APPROVED",
            )
            wait_for_txn_settled(
                transaction_details["transaction_id"],
                round(transaction_details["amount"] - clear_txn.amount, 2),
                "TRANSACTION_APPROVED",
                # step should pass the expected status of the original txn, not the expected status for the partial txn
            )
        else:
            wait_for_txn_settled(
                transaction_details["transaction_id"],
                clear_txn.amount,
                "TRANSACTION_APPROVED",
            )

        category = context.data[clear_txn.transaction_id]["txn_category"]

        # 1) clearing greater than txn amount
        if clear_txn.amount > transaction_details["amount"]:
            incr_amt = round(clear_txn.amount - transaction_details["amount"], 2)

            @retry(exceptions=AssertionError, tries=30, delay=2, logger=None)
            def wait_for_settled_and_unsettled_amount():
                balance_response = get_credit_account_balance(
                    request, customer_profile_id, account_id
                )
                # here available credit should decrease more than what it was previously, so this check is needed
                cms_helper.assert_values(
                    "Available credit after clearing amount > txn amount",
                    clear_txn.transaction_id,
                    round(
                        get_prev_balance(context, account_id).get("available_credit", 0)
                        - incr_amt,
                        2,
                    ),
                    balance_response["available_credit"],
                )

                cms_helper.assert_values(
                    "Settled amount",
                    clear_txn.transaction_id,
                    round(
                        get_prev_balance(context, account_id).get("settled_amount", 0)
                        + clear_txn.amount,
                        2,
                    ),
                    balance_response["settled_amount"],
                )

                cms_helper.assert_values(
                    "Unsettled amount",
                    clear_txn.transaction_id,
                    round(
                        get_prev_balance(context, account_id).get("unsettled_amount", 0)
                        - transaction_details[
                            "amount"
                        ],  # decreases only by the previously blocked amt
                        2,
                    ),
                    balance_response["unsettled_amount"],
                )
                expected_ledger_balance["0"]["available_balance"] = round(
                    expected_ledger_balance["0"]["available_balance"]
                    + transaction_details["amount"]
                    - clear_txn.amount,
                    2,
                )
                expected_ledger_balance[category]["total_balance"] = round(
                    expected_ledger_balance[category]["total_balance"]
                    - transaction_details["amount"]
                    + clear_txn.amount,
                    2,
                )

        else:
            # here only settled amount check is required because amount is less than what was previously blocked

            expected_ledger_balance = get_expected_ledger_balance(context, account_id)

            expected_ledger_balance["0"]["total_balance"] = round(
                expected_ledger_balance["0"]["total_balance"] - clear_txn.amount,
                2,
            )

            expected_ledger_balance[category]["available_balance"] = round(
                expected_ledger_balance[category]["available_balance"]
                + clear_txn.amount,
                2,
            )

            @retry(exceptions=AssertionError, tries=30, delay=2, logger=None)
            def wait_for_ledger_balances(expected_ledger_balance):
                ledger_balance_response = get_ledger_balances(
                    request, customer_profile_id, account_id
                )
                actual_ledger_balance = get_actual_ledger_balance(
                    ledger_balance_response
                )
                balance_response = get_credit_account_balance(
                    request, customer_profile_id, account_id
                )
                cms_helper.assert_values(
                    "Ledger_balances",
                    account_id,
                    expected_ledger_balance,
                    actual_ledger_balance,
                )

                cms_helper.assert_values(
                    "Settled amount",
                    clear_txn.transaction_id,
                    round(
                        get_prev_balance(context, account_id).get("settled_amount", 0)
                        + clear_txn.amount,
                        2,
                    ),
                    balance_response["settled_amount"],
                )

                cms_helper.assert_values(
                    "Unsettled amount",
                    clear_txn.transaction_id,
                    round(
                        get_prev_balance(context, account_id).get("unsettled_amount", 0)
                        - clear_txn.amount,  # decreases only by the cleared amt
                        2,
                    ),
                    balance_response["unsettled_amount"],
                )

            wait_for_ledger_balances(expected_ledger_balance)

        @retry(exceptions=AssertionError, tries=30, delay=2, logger=None)
        def wait_for_ledger_settled():
            actual_collection_balance_response = get_collection_account_balance(
                request
            )["total_amount"]
            prev_collection_balance_response = context.data[
                "collection_account" + balance_context_key
            ]

            total_clearing_amount = clear_txn.amount
            expected_collection_balance_response = round(
                prev_collection_balance_response["total_amount"]
                + total_clearing_amount,
                2,
            )
            cms_helper.assert_values(
                "Collection Balance",
                clear_txn.transaction_id,
                expected_collection_balance_response,
                actual_collection_balance_response,
            )

        wait_for_ledger_settled()
        balance_response = get_credit_account_balance(
            request, customer_profile_id, account_id
        )
        context.data[account_id + balance_context_key] = balance_response
        context.data["collection_account" + balance_context_key] = (
            get_collection_account_balance(request)
        )
        if clear_txn.amount < transaction_details["amount"]:
            transaction_details.update(
                {
                    "amount": round(
                        transaction_details["amount"] - clear_txn.amount,
                        2,
                    )
                }
            )
            context.data[clear_txn.transaction_id] = transaction_details


@Then("I update below auth transactions and verify balances")
def update_transaction(context):
    request = context.request
    customer_profile_id = context.data["config_data"]["customer_profile_id"]
    update_txn_list = DataClassParser.parse_rows(
        context.table.rows, data_class=AuthorizationUpdateDTO
    )

    for update_txn in update_txn_list:
        transaction_details = context.data[update_txn.transaction_id]
        transaction_id = transaction_details["transaction_id"]
        account_id = transaction_details["account_id"]
        data = update_txn.get_dict(account_id, transaction_id)

        response = request.hugoserve_put_request(
            cms_helper.card_txn_urls["update"],
            data=data,
            headers=cms_helper.get_headers(customer_profile_id, "CARD"),
        )
        check_status(response, update_txn.status_code)

        if (
            update_txn.status_code
            == cms_helper.status_codes["txn_rejected_insufficient_credit"]
        ):
            balance_response = get_credit_account_balance(
                request, customer_profile_id, account_id
            )
            cms_helper.assert_values(
                "Available credit",
                "N/A",
                get_prev_balance(context, account_id).get("available_credit", 0),
                balance_response["available_credit"],
            )
            data = get_transaction_details(request, customer_profile_id, transaction_id)
            cms_helper.assert_values(
                "Transaction Amount",
                transaction_id,
                transaction_details["amount"],
                data["amount"],
            )
            return

        data = get_transaction_details(request, customer_profile_id, transaction_id)
        cms_helper.assert_values(
            "Transaction Amount",
            transaction_id,
            update_txn.amount,
            data["amount"],
        )
        cms_helper.assert_values(
            "Transaction Status",
            transaction_id,
            update_txn.status,
            data["status"],
        )

        balance_response = get_credit_account_balance(
            request, customer_profile_id, account_id
        )
        ledger_balance_response = get_ledger_balances(
            request, customer_profile_id, account_id
        )
        if update_txn.amount < transaction_details["amount"]:
            less_amt = round(transaction_details["amount"] - update_txn.amount, 2)
            expected_available_credit = round(
                get_prev_balance(context, account_id).get("available_credit", 0)
                + less_amt,
                2,
            )
            expected_unsettled_amount = round(
                get_prev_balance(context, account_id).get("unsettled_amount", 0)
                - less_amt,
                2,
            )
        elif update_txn.amount == transaction_details["amount"]:
            expected_available_credit = get_prev_balance(context, account_id).get(
                "available_credit", 0
            )
            expected_unsettled_amount = get_prev_balance(context, account_id).get(
                "unsettled_amount", 0
            )
        else:
            more_amt = round(update_txn.amount - transaction_details["amount"], 2)
            expected_available_credit = round(
                get_prev_balance(context, account_id).get("available_credit", 0)
                - more_amt,
                2,
            )
            expected_unsettled_amount = round(
                get_prev_balance(context, account_id).get("unsettled_amount", 0)
                + more_amt,
                2,
            )

        cms_helper.assert_values(
            "Available Credit",
            transaction_id,
            expected_available_credit,
            balance_response["available_credit"],
        )
        cms_helper.assert_values(
            "Unsettled amount",
            transaction_id,
            expected_unsettled_amount,
            balance_response["unsettled_amount"],
        )

        # Check ledger balance
        expected_ledger_balance = get_expected_ledger_balance(context, account_id)
        actual_ledger_balance = get_actual_ledger_balance(ledger_balance_response)
        category = context.data[update_txn.transaction_id]["txn_category"]
        expected_ledger_balance["0"]["available_balance"] = round(
            expected_ledger_balance["0"]["available_balance"]
            + transaction_details["amount"]
            - update_txn.amount,
            2,
        )
        expected_ledger_balance[category]["total_balance"] = round(
            expected_ledger_balance[category]["total_balance"]
            - transaction_details["amount"]
            + update_txn.amount,
            2,
        )
        cms_helper.assert_values(
            "Ledger_balances",
            account_id,
            expected_ledger_balance,
            actual_ledger_balance,
        )
        context.data[account_id + balance_context_key] = balance_response
        context.data[account_id + ledger_context_key] = ledger_balance_response[
            "ledger_balances"
        ]
        transaction_details.update({"amount": update_txn.amount})
        context.data[update_txn.transaction_id] = transaction_details


@Then("I revert the following transactions")
def revert_transaction(context):
    request = context.request
    customer_profile_id = context.data["config_data"]["customer_profile_id"]
    revert_txn_list = DataClassParser.parse_rows(
        context.table.rows, data_class=RevertTransactionRequest
    )

    for revert_txn in revert_txn_list:
        transaction_details = context.data[revert_txn.transaction_id]
        transaction_id = transaction_details["transaction_id"]
        account_id = transaction_details["account_id"]

        response = request.hugoserve_put_request(
            cms_helper.card_txn_urls["revert"].replace(
                "$transaction_id$", transaction_id
            ),
            headers=cms_helper.get_headers(customer_profile_id, "CARD"),
        )
        check_status(response, revert_txn.status_code)

        @retry(exceptions=AssertionError, tries=30, delay=2, logger=None)
        def wait_for_txn_reverted(transaction_id, expected_status):
            data = get_transaction_details(request, customer_profile_id, transaction_id)
            cms_helper.assert_values(
                "Transaction status",
                transaction_id,
                expected_status,
                data["txn_status"],
            )

        wait_for_txn_reverted(transaction_id, revert_txn.status)

        if revert_txn.status_code != cms_helper.status_codes["cannot_revert_txn"]:
            balance_response = get_credit_account_balance(
                request, customer_profile_id, account_id
            )
            ledger_balance_response = get_ledger_balances(
                request, customer_profile_id, account_id
            )
            txn_details = get_transaction_details(
                request, customer_profile_id, transaction_id
            )
            if revert_txn.refund is False:
                cms_helper.assert_values(
                    "Available Credit",
                    transaction_id,
                    round(
                        get_prev_balance(context, account_id).get("available_credit", 0)
                        + txn_details["amount"],
                        2,
                    ),
                    balance_response["available_credit"],
                )

                cms_helper.assert_values(
                    "Unsettled amount",
                    transaction_id,
                    round(
                        get_prev_balance(context, account_id).get("unsettled_amount", 0)
                        - txn_details["amount"],
                        2,
                    ),
                    balance_response["unsettled_amount"],
                )
                # Check ledger balance
                expected_ledger_balance = get_expected_ledger_balance(
                    context, account_id
                )
                actual_ledger_balance = get_actual_ledger_balance(
                    ledger_balance_response
                )
                category = context.data[revert_txn.transaction_id]["txn_category"]
                expected_ledger_balance["0"]["available_balance"] = round(
                    expected_ledger_balance["0"]["available_balance"]
                    + txn_details["amount"],
                    2,
                )
                expected_ledger_balance[category]["total_balance"] = round(
                    expected_ledger_balance[category]["total_balance"]
                    - txn_details["amount"],
                    2,
                )
                cms_helper.assert_values(
                    "Ledger_balances",
                    account_id,
                    expected_ledger_balance,
                    actual_ledger_balance,
                )
                context.data[account_id + balance_context_key] = balance_response


@Then("I create below refund auth transactions")
def create_refund_auth_transaction(context):
    request = context.request
    customer_profile_id = context.data["config_data"]["customer_profile_id"]
    refund_auth_txn_list = DataClassParser.parse_rows(
        context.table.rows, data_class=TransactionRequest
    )

    for refund_auth_txn in refund_auth_txn_list:
        account_id = context.data[refund_auth_txn.account_id]
        response = request.hugoserve_post_request(
            cms_helper.card_txn_urls["refund_auth"],
            data=refund_auth_txn.get_dict(
                account_id, "CARD_TXN", "CARD_TXN_REFUND_AUTH"
            ),
            headers=cms_helper.get_headers(customer_profile_id, "CARD"),
        )
        check_status(response, refund_auth_txn.status_code)

        cms_helper.assert_values(
            "Transaction status",
            response["data"]["transaction_id"],
            refund_auth_txn.status,
            response["data"]["transaction_status"],
        )

        balance_response = get_credit_account_balance(
            request, customer_profile_id, account_id
        )
        ledger_balance_response = get_ledger_balances(
            request, customer_profile_id, account_id
        )
        context.data[account_id + balance_context_key] = balance_response
        context.data[account_id + ledger_context_key] = ledger_balance_response[
            "ledger_balances"
        ]
        context.data[refund_auth_txn.transaction_id] = {
            "transaction_id": response["data"]["transaction_id"],
            "account_id": account_id,
            "transaction_amount": refund_auth_txn.transaction_amount,
            "txn_category": refund_auth_txn.metadata["Category"],
        }


@Then("I clear below refund auth transactions")
def clear_refund_auth_txns(context):
    request = context.request
    customer_profile_id = context.data["config_data"]["customer_profile_id"]
    clear_refund_txns_list = DataClassParser.parse_rows(
        context.table.rows, data_class=ClearTransactionRequest
    )

    for clear_refund_txn in clear_refund_txns_list:
        transaction_details = context.data[clear_refund_txn.transaction_id]
        transaction_id = transaction_details["transaction_id"]
        account_id = transaction_details["account_id"]
        balance_response = get_credit_account_balance(
            request, customer_profile_id, account_id
        )
        context.data[account_id + balance_context_key] = balance_response
        data = clear_refund_txn.get_dict()
        if data["group_id"] not in context.data:
            context.data[data["group_id"]] = str(uuid.uuid4())
        data["group_id"] = context.data[data["group_id"]]
        response = request.hugoserve_put_request(
            cms_helper.card_txn_urls["refund_clear"].replace(
                "$transaction_id$", transaction_id
            ),
            data=data,
            headers=cms_helper.get_headers(customer_profile_id, "CARD"),
        )
        check_status(response, clear_refund_txn.status_code)

        @retry(exceptions=AssertionError, tries=30, delay=2, logger=None)
        def wait_for_txn_settled(transaction_id, expected_amount, expected_status):
            data = get_transaction_details(request, customer_profile_id, transaction_id)
            cms_helper.assert_values(
                "Transaction status",
                transaction_id,
                expected_status,
                data["txn_status"],
            )
            cms_helper.assert_values(
                "Transaction amount",
                transaction_id,
                expected_amount,
                data["amount"],
            )

        wait_for_txn_settled(
            transaction_id,
            transaction_details["transaction_amount"],
            clear_refund_txn.status,
        )

        balance_response = get_credit_account_balance(
            request, customer_profile_id, account_id
        )
        ledger_balance_response = get_ledger_balances(
            request, customer_profile_id, account_id
        )
        cms_helper.assert_values(
            "Available Credit",
            transaction_id,
            round(
                get_prev_balance(context, account_id).get("available_credit", 0)
                + clear_refund_txn.clearing_amount,
                2,
            ),
            balance_response["available_credit"],
        )
        # Ledger balance check
        expected_ledger_balance = get_expected_ledger_balance(context, account_id)
        actual_ledger_balance = get_actual_ledger_balance(ledger_balance_response)
        category = context.data[clear_refund_txn.transaction_id]["txn_category"]
        expected_ledger_balance["0"]["available_balance"] = round(
            expected_ledger_balance["0"]["available_balance"]
            + clear_refund_txn.clearing_amount,
            2,
        )
        expected_ledger_balance["0"]["total_balance"] = round(
            expected_ledger_balance["0"]["total_balance"]
            + clear_refund_txn.clearing_amount,
            2,
        )
        cms_helper.assert_values(
            "Available_Ledger_balance",
            account_id,
            expected_ledger_balance["0"],
            actual_ledger_balance["0"],
        )
        ledger_available_balance_sum = 0
        ledger_total_balance_sum = 0
        for category in ["1", "2", "3"]:
            ledger_available_balance_sum = round(
                ledger_available_balance_sum
                + expected_ledger_balance[category]["available_balance"]
                - actual_ledger_balance[category]["available_balance"],
                2,
            )
            ledger_total_balance_sum = round(
                ledger_total_balance_sum
                + expected_ledger_balance[category]["total_balance"]
                - actual_ledger_balance[category]["total_balance"],
                2,
            )
        cms_helper.assert_values(
            "Ledger_available_balance_sum",
            account_id,
            ledger_available_balance_sum,
            clear_refund_txn.clearing_amount,
        )
        cms_helper.assert_values(
            "Ledger_total_balance_sum",
            account_id,
            ledger_total_balance_sum,
            clear_refund_txn.clearing_amount,
        )


@Then("I reconcile clearing group and verify amount and transaction count")
def reconcile_clearing_group(context):
    request = context.request
    customer_profile_id = context.data["config_data"]["customer_profile_id"]
    reconcile_clearing_group_list = DataClassParser.parse_rows(
        context.table.rows, data_class=ReconcileClearingRequest
    )

    for reconcile_clearing_group in reconcile_clearing_group_list:
        group_id = context.data[reconcile_clearing_group.group_id]
        response = request.hugoserve_get_request(
            cms_helper.card_txn_urls["reconcile"].replace("$group_id$", group_id),
            headers=cms_helper.get_headers(customer_profile_id, "CARD"),
        )

        balance_response = get_collection_account_balance(request)
        context.data["collection_account" + balance_context_key] = balance_response
        context.data[reconcile_clearing_group.group_id + balance_context_key] = (
            reconcile_clearing_group.total_amount
        )

        cms_helper.assert_values(
            "Total Amount",
            reconcile_clearing_group.group_id,
            reconcile_clearing_group.total_amount,
            response["data"]["total_amount"],
        )

        cms_helper.assert_values(
            "Transaction Count",
            reconcile_clearing_group.group_id,
            reconcile_clearing_group.txn_count,
            response["data"]["txn_count"],
        )


@Then("I send total amount for clearing groups and verify transaction status")
def send_clearing_group_amount(context):
    request = context.request
    customer_profile_id = context.data["config_data"]["customer_profile_id"]
    send_request_list = DataClassParser.parse_rows(
        context.table.rows, data_class=SendRequest
    )
    for send_request in send_request_list:
        actual_group_id = context.data[send_request.group_id]
        data = send_request.get_dict()
        data["receiver_details"] = cms_helper.get_receiver_details()

        @retry(exceptions=AssertionError, tries=50, delay=2, logger=None)
        def wait_for_txn_settled(actual_group_id, expected_status):
            response = request.hugoserve_post_request(
                cms_helper.card_txn_urls["send"].replace("$group_id$", actual_group_id),
                headers=cms_helper.get_headers(customer_profile_id, "CARD"),
                data=data,
            )
            check_status(response, send_request.status_code)
            if send_request.status_code == "200":
                cms_helper.assert_values(
                    "Payment Transaction status",
                    actual_group_id,
                    expected_status,
                    response["data"]["txn_status"],
                )

                collection_account_balance = get_collection_account_balance(request)
                prev_balance_response = context.data[
                    "collection_account" + balance_context_key
                ]
                total_clearing_amount = context.data[
                    send_request.group_id + balance_context_key
                ]
                cms_helper.assert_values(
                    "Collection Account Balance",
                    send_request.group_id,
                    round(
                        prev_balance_response["available_amount"]
                        - total_clearing_amount,
                        2,
                    ),
                    collection_account_balance["available_amount"],
                )
                context.data["collection_account" + balance_context_key] = (
                    collection_account_balance
                )

        wait_for_txn_settled(actual_group_id, send_request.transaction_status)
