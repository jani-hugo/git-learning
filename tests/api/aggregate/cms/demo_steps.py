from behave import *
from hugoutils.utilities.dataclass_util import DataClassParser

from tests.api.aggregate.cms.cms_dataclass import ContextParams, DevTransaction
from tests.api.aggregate.cms import cms_helper
from retry import retry

from tests.util.common_util import check_status

use_step_matcher("re")


@Then("Create a credit account")
def create_credit_account(context):
    request = context.request
    response = request.hugoserve_post_request(
        cms_helper.demo_urls["create_credit_account"],
        data={
            "end_customer_profile_id": context.data["config_data"][
                "end_customer_profile_id"
            ],
            "product_id": context.data["config_data"]["product_id"],
            "currency": "SGD",
            "country": "SGP",
            "approved_limit": 10000,
        },
        headers=cms_helper.get_headers(
            context.data["config_data"]["customer_profile_id"], "CUSTOMER"
        ),
    )

    check_status(response, "200")
    assert (
        response["data"]["account_status"] == "ACCOUNT_INITIATED"
        or response["data"]["account_status"] == "ACCOUNT_CREATED"
    )
    account_id = response["data"]["credit_account_id"]

    @retry(exceptions=AssertionError, tries=60, delay=1, logger=None)
    def assert_account_status_change(context):
        response = request.hugoserve_get_request(
            cms_helper.demo_urls["get_credit_account_details"].replace(
                "$account_id$", account_id
            ),
            headers=cms_helper.get_headers(
                context.data["config_data"]["customer_profile_id"]
            ),
        )
        check_status(response, "200")
        assert response["data"]["account_status"] == "ACCOUNT_CREATED"

    assert_account_status_change(context)

    # response = request.hugoserve_post_request(
    #     cms_helper.demo_urls['attach_card'],
    #     data={
    #         "customer_profile_id": "",
    #         "account_id": account_id,
    #     },
    #     headers=cms_helper.get_headers(
    #         context.data['config_data']['customer_profile_id'], "CUSTOMER"
    #     ),
    # )
    # check_status(response, '200')
    # assert response['data']['status'] == 'SUCCESS'
    print(f"ACCOUNT ID: {account_id}")


@Then("Initiate following transactions for accountId ([^']*)")
def initiate_transactions(context, account_id):
    request = context.request
    txn_list = DataClassParser.parse_rows(context.table.rows, DevTransaction)

    # get fund accounts
    # fund_accounts_response = request.hugoserve_get_request(
    #     cms_helper.demo_urls['get_fund_accounts'],
    #     headers=cms_helper.get_headers(context.data['config_data']['customer_profile_id']),
    # )
    # check_status(fund_accounts_response, '200')
    # print(fund_accounts_response["data"]["accounts"])
    # collection_account = list(filter(lambda a: a["account_type"] == 'REPAYMENT_LA', fund_accounts_response["data"]["accounts"]))[0]
    data = {
        "credit_account_id": account_id,
        "receiver": {
            "account_holder_name": "HUGOHUB",
            "country": "SGP",
            "currency": "SGD",
            "bank_name": "DBS Bank Ltd",
            "code_details": {
                "sg_bank_details": {
                    "swift_bic": "DBSSSGSGXXX",
                    "account_number": "88532699912754149",
                }
            },
        },
        "mock_txns": [txn.get_dict() for txn in txn_list],
    }
    response = request.hugoserve_post_request(
        cms_helper.demo_urls["initiate_transactions"],
        data=data,
        headers=cms_helper.get_headers(
            context.data["config_data"]["customer_profile_id"], "CUSTOMER"
        ),
    )

    check_status(response, "200")


@Then("Generate bill for accountId ([^']*) for bill date ([^']*)")
def generate_bill(context, account_id, bill_date):
    request = context.request
    data = {"account_id": account_id, "bill_date": bill_date + "T00:00:00.000000Z"}
    response = request.hugoserve_post_request(
        cms_helper.demo_urls["generate_bill"],
        data=data,
        headers=cms_helper.get_headers(
            context.data["config_data"]["customer_profile_id"], "CUSTOMER"
        ),
    )
    check_status(response, "200")


@Then("Get balance for accountId ([^']*)")
def get_balance(context, account_id):
    request = context.request
    response = request.hugoserve_get_request(
        cms_helper.demo_urls["balance"].replace("$account_id$", account_id),
        headers=cms_helper.get_headers(
            context.data["config_data"]["customer_profile_id"]
        ),
    )
    check_status(response, "200")
    account = response["data"]
    used_credit = account["settled_amount"] + account["unsettled_amount"]
    print("")
    print(
        "available_limit: "
        + str(account["available_credit"])
        + "\t|   used_limit: "
        + str(used_credit)
    )


@Then("Get transactions for accountId ([^']*)")
def get_transactions(context, account_id):
    request = context.request
    response = request.hugoserve_get_request(
        cms_helper.demo_urls["get_transactions"].replace("$account_id$", account_id),
        headers=cms_helper.get_headers(
            context.data["config_data"]["customer_profile_id"], "CUSTOMER"
        ),
    )
    check_status(response, "200")
    print("")
    for transaction in response["data"]["transactions"]:
        print(
            str(transaction["currency"])
            + "\t|   "
            + str(transaction["amount"])
            + "\t|   "
            + transaction["txn_status"]
            + "\t|   "
            + transaction["run_ts"]
        )


@Then("Get Bill for accountId ([^']*)")
def get_latest_bill(context, account_id):
    request = context.request
    response = request.hugoserve_get_request(
        cms_helper.demo_urls["get_latest_bill"].replace("$account_id$", account_id),
        headers=cms_helper.get_headers(
            context.data["config_data"]["customer_profile_id"], "CUSTOMER"
        ),
    )
    check_status(response, "200")

    bill = response["data"]
    print("")
    print(
        "bill_date: "
        + bill["bill_date"]
        + "\t|   due_date: "
        + bill["due_date"]
        + "\t|   total_amount_due: "
        + str(bill["total_amount_due"])
        + "\t|   bill_status: "
        + bill["bill_status"]
    )
    print("statement_link : \t" + bill["statement_link"])
