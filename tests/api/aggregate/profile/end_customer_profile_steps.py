from hugoutils.utilities.dataclass_util import DataClassParser

from tests.api.aggregate.profile.profile_dataclass import (
    CreateUpdateEndCustomerProfileDTO,
    EndCustomerProfileDTO,
)
from behave import *

from tests.util.common_util import check_status

use_step_matcher("re")
profile_end_customer_profile_url = "/profile/v1/end-customer"


@Then("I create below End-Customer-Profile")
def create_end_customer(context):
    request = context.request

    end_customer_profile_dto_list = DataClassParser.parse_rows(
        context.table.rows, data_class=CreateUpdateEndCustomerProfileDTO
    )
    context.data = {} if context.data is None else context.data

    for end_customer_profile_dto in end_customer_profile_dto_list:
        data = end_customer_profile_dto.get_dict()
        customer_profile_id = context.data[
            end_customer_profile_dto.customer_profile_identifier
        ].customer_profile_id
        end_customer_profile_dto.customer_profile_id = customer_profile_id
        response = request.hugoserve_post_request(
            profile_end_customer_profile_url,
            data,
            headers={"x-customer-profile-id": customer_profile_id},
        )
        check_status(response, "200")
        end_customer_profile_dto.end_customer_profile_id = response["data"][
            "end_customer_profile_ids"
        ][
            0
        ]  # Save end customer_id in object

        assert end_customer_profile_dto.end_customer_profile_id not in context.data, (
            f"An existing end_customer_profile_id: {end_customer_profile_dto.end_customer_profile_id} "
            f"found while creating customers"
        )
        context.data[end_customer_profile_dto.end_customer_profile_identifier] = (
            end_customer_profile_dto  # Save end_customer_profile_dto against identifier
        )


@Then("I verify End-Customer-Profile exist with values")
def verify_end_customer_profile_exist(context):
    request = context.request

    end_customer_profile_dto_list = DataClassParser.parse_rows(
        context.table.rows, data_class=EndCustomerProfileDTO
    )

    for expected_end_customer_profile_dto in end_customer_profile_dto_list:
        end_customer_profile_id = context.data[
            expected_end_customer_profile_dto.end_customer_profile_identifier
        ].end_customer_profile_id
        customer_profile_id = context.data[
            expected_end_customer_profile_dto.customer_profile_identifier
        ].customer_profile_id
        response = request.hugoserve_get_request(
            profile_end_customer_profile_url + "-profile/" + end_customer_profile_id,
            headers={"x-customer-profile-id": customer_profile_id},
        )

        data = response["data"]
        check_status(response, "200")

        flattened_data = EndCustomerProfileDTO.flatten_end_customer_data(data)

        actual_end_customer_profile_dto = DataClassParser.dict_to_object(
            flattened_data, data_class=EndCustomerProfileDTO
        )

        sanitized_expected = EndCustomerProfileDTO.sanitize_end_customer_profile_dto(
            expected_end_customer_profile_dto
        )
        sanitized_actual = EndCustomerProfileDTO.sanitize_end_customer_profile_dto(
            actual_end_customer_profile_dto
        )
        assert sanitized_expected == sanitized_actual, (
            f"\nExpect end_customer_profile_dto: {sanitized_expected}"
            f"\nActual end_customer_profile_dto: {sanitized_actual}"
        )


@Step("I delete the above created End-Customer-Profile")
def delete_end_customer_profile(context):
    request = context.request

    customers_to_delete = DataClassParser.row_to_dict(context.table.rows)

    for end_customer_profile_to_delete in customers_to_delete:
        customer_profile_id = context.data[
            end_customer_profile_to_delete["customer_profile_identifier"]
        ].customer_profile_id
        end_customer_profile_id = context.data[
            end_customer_profile_to_delete["end_customer_profile_identifier"]
        ].end_customer_profile_id
        endpoint = (
            profile_end_customer_profile_url + "-profile/" + end_customer_profile_id
        )
        response = request.hugoserve_delete_request(
            endpoint, headers={"x-customer-profile-id": customer_profile_id}
        )
        check_status(response, "200")


@Step("I verify End-Customer-Profile doesn't exist")
def verify_end_customer_profile_not_exist(context):
    request = context.request

    deleted_customers = DataClassParser.row_to_dict(context.table.rows)

    for deleted_customer in deleted_customers:
        customer_profile_id = context.data[
            deleted_customer["customer_profile_identifier"]
        ].customer_profile_id
        end_customer_profile_id = context.data[
            deleted_customer["end_customer_profile_identifier"]
        ].end_customer_profile_id
        response = request.hugoserve_get_request(
            profile_end_customer_profile_url + "-profile/" + end_customer_profile_id,
            headers={"x-customer-profile-id": customer_profile_id},
        )
        check_status(response, "PSM_E9506")

        assert (
            "data" not in response
        ), f"\nExpect response.data: <empty> \nActual response.data: {response['data']}"
        assert "Invalid End customer profile id" == response["headers"]["message"], (
            f"\nExpect response.headers.message: Invalid End customer profile id"
            f"\nActual response.headers.message: {response['headers']['message']}"
        )
