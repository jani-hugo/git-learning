import json
from hugoutils.utilities.dataclass_util import DataClassParser

from test.api.aggregate.cms import cms_helper
from test.api.aggregate.cms.cms_dataclass import (
    ProductDTO,
    ProductIdDTO,
    UpdateProductDTO,
)
from behave import *
from retry import retry
import uuid

from test.util.common_util import check_status

use_step_matcher("re")


@then(
    "I create following products and verify product status to be ([^']*) and status code is ([^']*)"
)
def create_product(context, expected_product_status, status_code):
    request = context.request
    product_dto_list = DataClassParser.parse_rows(
        context.table.rows, data_class=ProductDTO
    )
    context.data = {} if context.data is None else context.data
    customer_profile_id = context.data["config_data"]["customer_profile_id"]
    for product_dto in product_dto_list:
        product_response = product_creation_check_status(
            context, product_dto, status_code
        )
        if status_code == "200":
            product_id = product_response["data"]["product_id"]
            context.data[product_dto.product_id] = product_response["data"][
                "product_id"
            ]

        @retry(exceptions=AssertionError, tries=60, delay=2, logger=None)
        def retry_for_product_status():
            response = request.hugoserve_get_request(
                cms_helper.product_urls["get_details"].replace(
                    "$product_id$", product_id
                ),
                headers=cms_helper.get_headers(customer_profile_id),
            )
            cms_helper.assert_values(
                "Product Status",
                product_id,
                expected_product_status,
                response["data"]["product_status"],
            )

        if status_code == "200":
            retry_for_product_status()


@then(
    "I approve following products and verify product status to be ([^']*) and status code is ([^']*)"
)
def approve_product(context, expected_product_status, expected_status_code):
    request = context.request
    product_dto_list = DataClassParser.parse_rows(
        context.table.rows, data_class=ProductIdDTO
    )
    customer_profile_id = context.data["config_data"]["customer_profile_id"]

    for product_dto in product_dto_list:
        data = product_dto.get_dict()
        product_id = context.data[product_dto.product_id]

        product_response = request.hugoserve_put_request(
            cms_helper.product_urls["approve"].replace("$product_id$", product_id),
            data=data,
            headers=cms_helper.get_headers(customer_profile_id),
        )

        check_status(product_response, expected_status_code)

        @retry(exceptions=AssertionError, tries=60, delay=2, logger=None)
        def retry_for_product_status():
            response = request.hugoserve_get_request(
                cms_helper.product_urls["get_details"].replace(
                    "$product_id$", product_id
                ),
                headers=cms_helper.get_headers(customer_profile_id),
            )
            cms_helper.assert_values(
                "Product Status",
                product_id,
                expected_product_status,
                response["data"]["product_status"],
            )

        if expected_status_code == "200":
            retry_for_product_status()


@then("I update the following products and verify the response status is ([^']*)")
def update_product(context, expected_status_code):
    request = context.request
    product_dto_list = DataClassParser.parse_rows(
        context.table.rows, data_class=UpdateProductDTO
    )
    customer_profile_id = context.data["config_data"].get("customer_profile_id", None)

    if not customer_profile_id:
        raise ValueError("Customer Profile ID is missing in context data")

    for product_dto in product_dto_list:
        if not any(
            [
                product_dto.product_name,
                product_dto.product_description,
                product_dto.product_class,
                product_dto.product_code,
                product_dto.profile_type,
                product_dto.param_group,
            ]
        ):
            continue  # Skip completely empty rows

        product_id = context.data.get(product_dto.product_id)
        if not product_id:
            raise ValueError(
                f"Product ID {product_dto.product_id} not found in context data"
            )

        update_data = {}
        if product_dto.product_name:
            update_data["product_name"] = product_dto.product_name
        if product_dto.product_description:
            update_data["product_description"] = product_dto.product_description
        if product_dto.product_class:
            update_data["product_class"] = product_dto.product_class
        if product_dto.product_code:
            update_data["product_code"] = product_dto.product_code

        if product_dto.param_group:
            update_data["product_params"] = cms_helper.get_product_params(
                product_dto.param_group
            )

        update_response = request.hugoserve_put_request(
            cms_helper.product_urls["update"].replace("$product_id$", product_id),
            data=update_data,
            headers=cms_helper.get_headers(customer_profile_id),
        )

        check_status(update_response, expected_status_code)


@then("I fetch and verify the updated products given the status code is ([^']*)")
def fetch_and_verify_updated_products(context, status_code):
    if status_code == 200:
        request = context.request
        product_id = context.data.get(context.table[0]["product_id"])
        get_response = request.hugoserve_get_request(
            cms_helper.product_urls["get_details"].replace("$product_id$", product_id),
            headers=cms_helper.get_headers(
                context.data["config_data"]["customer_profile_id"]
            ),
        )
        check_status(get_response, 200)
        updated_product = get_response["data"]
        expected_values = context.table[0]
        params = cms_helper.get_product_params(context.table[0]["param_group"])
        expected_keys = {param["param_name"] for param in params}
        expected_normalized = normalize_param_group(params, expected_keys)
        actual_normalized = normalize_param_group(
            updated_product.get("product_params", []), expected_keys
        )
        assert json.dumps(actual_normalized, sort_keys=True) == json.dumps(
            expected_normalized, sort_keys=True
        ), f"Mismatch in param_group:\nExpected: {json.dumps(expected_normalized, indent=2)}\nGot: {json.dumps(actual_normalized, indent=2)}"
        for key, expected_value in expected_values.items():
            if (
                key != "product_id"
                and key != "param_group"
                and expected_value not in [None, ""]
            ):
                assert (
                    updated_product.get(key) == expected_value
                ), f"Mismatch in {key}: Expected {expected_value}, Got {updated_product.get(key)}"


def product_creation_check_status(context, product_dto, expected_status_code):
    product_code = str(uuid.uuid4()).replace("-", "")[:8]
    data = product_dto.get_dict(product_code)
    customer_profile_id = context.data["config_data"]["customer_profile_id"]
    data["customer_profile_id"] = customer_profile_id

    param_config_response = context.request.hugoserve_get_request(
        cms_helper.product_urls["get_param_config"]
        + "?product-type="
        + data["product_type"]
    )
    data["provider_id"] = param_config_response["data"]["provider_product_configs"][0][
        "provider_id"
    ]
    data["product_params"] = cms_helper.get_product_params(product_dto.param_group)
    product_response = context.request.hugoserve_post_request(
        cms_helper.product_urls["create"],
        data=data,
        headers=cms_helper.get_headers(customer_profile_id),
    )
    check_status(product_response, expected_status_code)
    return product_response


def normalize_param_group(param_group, expected_keys):
    normalized = []

    for param in param_group:
        if param["param_name"] not in expected_keys:
            continue

        value_dict = param.get("value", {})  # Ensure value exists
        processed_value_dict = {}

        for key, val in value_dict.items():
            if not isinstance(val, dict) or "value" not in val:
                continue

            raw_value = val["value"]
            if isinstance(raw_value, float) and raw_value.is_integer():
                raw_value = int(raw_value)  # Convert float to int
            elif isinstance(raw_value, str) and raw_value.isdigit():
                raw_value = int(raw_value)  # Convert string numbers to int

            processed_value_dict[key] = {"value": raw_value}

        normalized.append(
            {"param_name": param["param_name"], "value": processed_value_dict}
        )

    return sorted(normalized, key=lambda x: x["param_name"])
