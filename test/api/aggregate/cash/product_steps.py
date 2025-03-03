import random
import string

from hugoutils.utilities.dataclass_util import DataClassParser
from retry import retry

from test.api.aggregate.cash.cash_dataclass import ProductRequestDTO, DoubleList, Double

from behave import *

import test.api.aggregate.cash.helper as cash_helper
from test.api.aggregate.cash.cash_dataclass import (
    ParamRequestDTO,
    Value,
    StringList,
    MultiString,
    Boolean,
)

use_step_matcher("re")


@Step(
    "I create a product with customer profile ([^']*) provider as ([^']*) and expect product_status ([^']*)"
)
def create_product(
    context, customer_profile_identifier: str, provider_name: str, expected_status: str
):
    cash_helper.__validate_provider(provider_name)

    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id

    product_request_dto = DataClassParser.parse_row(
        context.table.rows[0], data_class=ProductRequestDTO
    )

    provider_id = cash_helper.__get_provider_id(
        context=context, provider_name=provider_name, customer_profile_id=customer_profile_id
    )

    @retry(AssertionError, tries=60 / 5, delay=5, logger=None)
    def retry_for_creation_status():
        product_request_dto.provider_name = provider_name
        product_request_dto.product_name = ''.join(random.choices(string.digits, k=9))
        allowed_chars = string.ascii_letters + string.digits + '_'
        product_request_dto.product_code = ''.join(
            random.choices(allowed_chars, k=random.randint(8, 9))
        )
        product_request_dto.provider_id = provider_id
        product_request_dict = product_request_dto.get_dict()

        currency_param = ParamRequestDTO(
            param_name="CURRENCY",
            value=Value(
                multi_string_value=MultiString(
                    values=product_request_dto.currency.split(",")
                ).to_dict()
            ),
        ).to_dict()

        country_param = ParamRequestDTO(
            param_name="COUNTRY",
            value=Value(
                string_list_value=StringList(value=product_request_dto.country).to_dict()
            ),
        ).to_dict()

        balance_policy_limit_param = ParamRequestDTO(
            param_name="BALANCE_POLICY_LIMIT",
            value=Value(
                double_value=Double(value=product_request_dto.balance_policy_limit).to_dict()
            ),
        ).to_dict()

        balance_policy_type_param = ParamRequestDTO(
            param_name="BALANCE_POLICY_TYPE",
            value=Value(
                string_list_value=StringList(
                    value=product_request_dto.balance_policy_type
                ).to_dict()
            ),
        ).to_dict()

        account_type_param = ParamRequestDTO(
            param_name="ACCOUNT_TYPE",
            value=Value(
                string_list_value=StringList(value=product_request_dto.account_type).to_dict()
            ),
        ).to_dict()

        product_request_dict['product_params'] = [
            currency_param,
            country_param,
            balance_policy_limit_param,
            balance_policy_type_param,
            account_type_param,
        ]

        response = context.request.hugoserve_post_request(
            path="/cash/v1/product",
            data=product_request_dict,
            headers=cash_helper.__get_default_cash_headers(customer_profile_id),
        )

        assert response["headers"]["status_code"] == "200", (
            f"Expect status_code: {200}\n"
            f"Actual status_code: {response['headers']['status_code']}"
        )

        assert (
            "product_id" in response["data"]
        ), f"Expected data object to contain product_id\nActual data: {response['data']}"
        context.data[product_request_dto.identifier] = response["data"]["product_id"]
        context.data[response["data"]["product_id"]] = product_request_dto

        actual_product_status = response["data"]["product_status"]
        assert actual_product_status == expected_status, (
            f"Expect data.product_status: {expected_status}\n"
            f"Actual data.product_status: {actual_product_status}, data: {response['data']}"
        )

    retry_for_creation_status()


@Step(
    "I approve the product ([^']*) and verify status as ([^']*) with provider ([^']*) for customerProfileId ([^']*)"
)
def approve_and_verify_product(
    context,
    product_identifier: str,
    expected_status: str,
    provider_name: str,
    customer_profile_identifier: str,
):
    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id
    product_id = context.data[product_identifier]
    requests = context.request

    response = requests.hugoserve_put_request(
        path=f"/cash/v1/product/{product_id}/activate",
        headers=cash_helper.__get_default_cash_headers(customer_profile_id),
    )

    status_code = "200"
    assert (
        response["headers"]["status_code"] == status_code
    ), f"Expected status_code: {status_code}, Actual: {response['headers']['status_code']}"

    actual_status = response["data"]["product_status"]
    assert (
        actual_status == expected_status
    ), f"Expected product_status: {expected_status}, Actual: {actual_status}"
