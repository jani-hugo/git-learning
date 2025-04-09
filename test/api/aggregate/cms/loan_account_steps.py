import uuid

from behave import *
from hugoutils.utilities.dataclass_util import DataClassParser
from retry import retry

from test.api.aggregate.cms import cms_helper
from test.api.aggregate.cms.cms_dataclass import CreateLoanAccountRequestDTO
from test.util.common_util import check_status

use_step_matcher("re")
@Then("I create below loan accounts and verify account status is ([^']*) and status code is ([^']*)")
def create_loan_account(context,expected_account_status,creation_status_code):
    request = context.request
    context.data = {} if context.data is None else context.data
    customer_profile_id = context.data['config_data']['customer_profile_id']

    loan_account_list = DataClassParser.parse_rows(
        context.table.rows, data_class=CreateLoanAccountRequestDTO
    )

    for loan_account in loan_account_list:
        data = loan_account.get_dict()

        if loan_account.product_id in context.data:
            data['product_id'] = context.data[loan_account.product_id]
        else:
            data['product_id'] = str(uuid.uuid4())

        if loan_account.end_customer_profile_id in context.data:
            data['end_customer_profile_id'] = context.data[
                loan_account.end_customer_profile_id
            ].end_customer_profile_id
        else:
            data['end_customer_profile_id'] = str(uuid.uuid4())

        data['account_param'] = {
            "approved_amount": int(data.pop("approved_amount")),
            "tenure": int(data.pop("tenure")),
            "interest_rate": float(data.pop("interest_rate")),
        }

        response = request.hugoserve_post_request(
            cms_helper.loan_account_urls['create'],
            data=data,
            headers=cms_helper.get_headers(customer_profile_id),
        )

        check_status(response, creation_status_code)

        if creation_status_code == 200 :
            assert (
                    response['data']['account_status'] == 'ACCOUNT_INITIATED'
                    or response['data']['account_status'] == expected_account_status
            )
            # setting loan account id in the context
            loan_account_id = response['data']['account_id']
            context.data[loan_account.account_id] = loan_account_id

            @retry(exceptions=AssertionError, tries=30, delay=2, logger=None)
            def retry_for_loan_account_creation():
                details_response = request.hugoserve_get_request(
                    cms_helper.loan_account_urls['get_details'].replace(
                        "$account_id$", loan_account_id
                    ),
                    headers=cms_helper.get_headers(customer_profile_id),
                )
                print("detail response",details_response)
                check_status(details_response, '200')
                cms_helper.assert_values(
                    "Loan Account Status",
                    loan_account_id,
                    expected_account_status,
                    details_response['data']['account_status'],
                )

            if response['data']['account_status'] != expected_account_status:
                retry_for_loan_account_creation()
