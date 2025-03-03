from aggregate.cms import cms_helper
from aggregate.cms.cms_dataclass import ProductDTO, ProductIdDTO
from behave import *
from common.utils import DataClassParser, check_status
from retry import retry
import uuid

use_step_matcher("re")


@then("I create following products and verify product status to be ([^']*)")
def create_product(context, expected_product_status):
    request = context.request
    product_dto_list = DataClassParser.parse_rows(context.table.rows, data_class=ProductDTO)

    context.data = {} if context.data is None else context.data

    for product_dto in product_dto_list:
        product_code = str(uuid.uuid4())
        data = product_dto.get_dict(product_code)
        customer_profile_id = context.data['config_data']['customer_profile_id']
        data['customer_profile_id'] = customer_profile_id

        param_config_response = request.hugoserve_get_request(
            cms_helper.product_urls['get_param_config']
            + "?product-type="
            + data['product_type']
        )

        param_config_list = param_config_response['data']['provider_product_configs'][0][
            'param_configs'
        ]
        data['provider_id'] = param_config_response['data']['provider_product_configs'][0][
            'provider_id'
        ]
        product_params = []
        for param_config in param_config_list:
            value = {}
            if param_config['data_type'] == 'INTEGER_RANGE':
                value = {
                    'integer_range_value': {
                        'value': param_config['value']['integer_range_value']['max_value']
                    }
                }
            elif param_config['data_type'] == 'DOUBLE_RANGE':
                value = {
                    'double_range_value': {
                        'value': param_config['value']['double_range_value']['max_value']
                    }
                }
            elif param_config['data_type'] == 'BOOLEAN':
                value = {
                    'boolean_value': {
                        'value': (
                            True
                            if param_config['param_config_name'] == 'CAN_ATTACH_CARD'
                            else param_config['value']['boolean_value']['default_value']
                        )
                    }
                }
            elif param_config['data_type'] == 'STRING_LIST':
                value = {
                    'string_list_value': {
                        'value': param_config['value']['string_list_value']['default_value']
                    }
                }

            product_params.append(
                {
                    'param_name': param_config['param_config_name'],
                    'data_type': param_config['data_type'],
                    'value': value,
                }
            )

        data['product_params'] = product_params
        product_response = request.hugoserve_post_request(
            cms_helper.product_urls['create'],
            data=data,
            headers=cms_helper.get_headers(customer_profile_id),
        )
        check_status(product_response, '200')
        context.data[product_dto.product_id] = product_response['data']['product_id']
        product_id = product_response['data']['product_id']

        @retry(exceptions=AssertionError, tries=60, delay=2, logger=None)
        def retry_for_product_status():
            response = request.hugoserve_get_request(
                cms_helper.product_urls['get_details'].replace('$product_id$', product_id),
                headers=cms_helper.get_headers(customer_profile_id),
            )
            cms_helper.assert_values(
                "Product Status",
                product_id,
                expected_product_status,
                response['data']['product_status'],
            )

        retry_for_product_status()


@then("I approve following products and verify product status to be ([^']*)")
def approve_product(context, expected_product_status):
    request = context.request
    product_dto_list = DataClassParser.parse_rows(context.table.rows, data_class=ProductIdDTO)
    customer_profile_id = context.data['config_data']['customer_profile_id']

    for product_dto in product_dto_list:
        data = product_dto.get_dict()
        product_id = context.data[product_dto.product_id]

        product_response = request.hugoserve_put_request(
            cms_helper.product_urls['approve'].replace('$product_id$', product_id),
            data=data,
            headers=cms_helper.get_headers(customer_profile_id),
        )

        check_status(product_response, '200')

        @retry(exceptions=AssertionError, tries=60, delay=2, logger=None)
        def retry_for_product_status():
            response = request.hugoserve_get_request(
                cms_helper.product_urls['get_details'].replace('$product_id$', product_id),
                headers=cms_helper.get_headers(customer_profile_id),
            )
            cms_helper.assert_values(
                "Product Status",
                product_id,
                expected_product_status,
                response['data']['product_status'],
            )

        retry_for_product_status()
