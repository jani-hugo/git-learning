import uuid

from hugoutils.utilities.dataclass_util import DataClassParser

from test.api.aggregate.cms import cms_helper
from test.api.aggregate.cms.cms_dataclass import CreateAccountRequestDTO
from behave import *
from retry import retry

from test.util.common_util import check_status

use_step_matcher("re")
@Then("I create below credit accounts and verify account status is ([^']*) and status code is ([^']*)")
def create_credit_account(context, expected_account_status,expected_status_code):
    request = context.request
    create_account_req_list = DataClassParser.parse_rows(
        context.table.rows, data_class=CreateAccountRequestDTO
    )
    context.data = {} if context.data is None else context.data
    customer_profile_id = context.data['config_data']['customer_profile_id']
    for create_account_req in create_account_req_list:
        print("expected status code ",expected_status_code)
        data = create_account_req.get_dict()
        if not create_account_req.product_id in context.data:
            data['product_id']= str(uuid.uuid4())
        else:
            data['product_id'] = context.data[create_account_req.product_id]
        if create_account_req.end_customer_profile_id in context.data:
            data['end_customer_profile_id'] = context.data[
                create_account_req.end_customer_profile_id
            ].end_customer_profile_id
        else:
            data['end_customer_profile_id'] = str(uuid.uuid4())
        response = request.hugoserve_post_request(
            cms_helper.credit_account_urls['create'],
            data=data,
            headers=cms_helper.get_headers(customer_profile_id),
        )
        check_status(response, expected_status_code)
        if expected_status_code == '200':
            assert (
                response['data']['account_status'] == 'ACCOUNT_INITIATED'
                or response['data']['account_status'] == expected_account_status
            )
            account_id = response['data']['credit_account_id']
            context.data[create_account_req.account_id] = account_id
        @retry(exceptions=AssertionError, tries=30, delay=2, logger=None)
        def retry_for_account_creation():
            response = request.hugoserve_get_request(
                cms_helper.credit_account_urls["get_details"].replace(
                    '$account_id$', account_id
                ),
                headers=cms_helper.get_headers(customer_profile_id),
            )
            check_status(response, '200')
            cms_helper.assert_values(
                "Account Status",
                account_id,
                expected_account_status,
                response['data']['account_status'],
            )
        if expected_status_code == '200' and response['data']['account_status'] != expected_account_status:
             retry_for_account_creation()

