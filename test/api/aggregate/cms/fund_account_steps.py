from aggregate.cms import cms_helper
from aggregate.cms.cms_dataclass import DevDepositRequestDTO
from behave import *
from common.utils import DataClassParser, check_status
from retry import retry

use_step_matcher("re")


def get_fund_account_balance(request, customer_profile_id, account_type):
    response = request.hugoserve_get_request(
        cms_helper.fund_account_urls['get_balance'].replace('$account_type$', account_type),
        headers=cms_helper.get_headers(customer_profile_id),
    )
    check_status(response, '200')
    return response['data']


@Then("I deposit funds into the following funding account for Customer Profile")
def deposit_funds(context):
    request = context.request
    dev_deposit_req_list = DataClassParser.parse_rows(context.table.rows, DevDepositRequestDTO)

    customer_profile_id = context.data['config_data']['customer_profile_id']
    for dev_deposit_req in dev_deposit_req_list:
        data = dev_deposit_req.get_dict()
        prev_float_balance = get_fund_account_balance(
            request, customer_profile_id, data['account_type']
        )['total_amount']
        data.update({'customer_profile_id': customer_profile_id})
        response = request.hugoserve_post_request(
            cms_helper.dev_urls["deposit_funds"],
            data=data,
        )
        check_status(response, '200')

        @retry(exceptions=AssertionError, tries=30, delay=2, logger=None)
        def wait_for_ledger_settled():
            actual_float_balance = get_fund_account_balance(
                request, customer_profile_id, data['account_type']
            )['total_amount']
            expected_float_balance = round(prev_float_balance + data['amount'], 2)

            cms_helper.assert_values(
                "Total amount",
                customer_profile_id,
                expected_float_balance,
                actual_float_balance,
            )

        wait_for_ledger_settled()
