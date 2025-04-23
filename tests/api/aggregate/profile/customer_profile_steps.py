from hugoutils.utilities.dataclass_util import DataClassParser

from tests.api.aggregate.profile.profile_dataclass import (
    CreateUpdateCustomerProfileDTO,
    CustomerProfileDTO,
)
from behave import *

from tests.util.common_util import check_status

use_step_matcher("re")
profile_customer_profile_url = "/profile/v1/admin/customer-profile/"


@Then("I create below Customer-Profile")
def create_customer_profile(context):
    request = context.request

    customer_profile_dto_list = DataClassParser.parse_rows(
        context.table.rows, data_class=CreateUpdateCustomerProfileDTO
    )
    context.data = {} if context.data is None else context.data

    for customer_profile_dto in customer_profile_dto_list:
        data = customer_profile_dto.get_dict()
        customer_id = context.data[customer_profile_dto.customer_identifier].customer_id
        data["customer_id"] = customer_id

        response = request.hugoserve_post_request(
            "/profile/v1/admin/customer-profile", data
        )
        check_status(response, "200")
        customer_profile_dto.customer_profile_id = response["data"][
            "customer_profile_id"
        ]  # Save customer_id in object

        assert (
            customer_profile_dto.customer_profile_id not in context.data
        ), f"An existing customer_profile_id: {customer_profile_dto.customer_profile_id} found while creating customers"
        context.data[customer_profile_dto.customer_profile_identifier] = (
            customer_profile_dto  # Save customer_profile_dto against identifier
        )

        customer_profiles = context.data.get("customer_profiles", {})
        customer_profiles[customer_profile_dto.customer_profile_identifier] = (
            customer_profile_dto
        )
        context.data["customer_profiles"] = (
            customer_profiles  # Save customer_profile in customer_profile map too
        )


@Then("I verify Customer-Profile exist with values")
def verify_customer_profile_exist(context):
    request = context.request

    customer_profile_dto_list = DataClassParser.parse_rows(
        context.table.rows, data_class=CustomerProfileDTO
    )

    for expected_customer_profile_dto in customer_profile_dto_list:
        customer_profile_id = context.data[
            expected_customer_profile_dto.customer_profile_identifier
        ].customer_profile_id
        response = request.hugoserve_get_request(
            "/profile/v1/customer-profile",
            params=None,
            headers={"x-customer-profile-id": customer_profile_id},
        )
        check_status(response, "200")
        data = response["data"]

        actual_customer_profile_dto = DataClassParser.dict_to_object(
            data, data_class=CustomerProfileDTO
        )

        sanitized_expected = CustomerProfileDTO.sanitize_customer_profile_dto(
            expected_customer_profile_dto
        )
        sanitized_actual = CustomerProfileDTO.sanitize_customer_profile_dto(
            actual_customer_profile_dto
        )
        assert sanitized_expected == sanitized_actual, (
            f"\nExpect customer_profile_dto: {sanitized_expected}"
            f"\nActual customer_profile_dto: {sanitized_actual}"
        )


@Then(
    "I attempt to create Customer-Profile with invalid datatype and verify create failed"
)
def create_customer_profile_with_incorrect_data_verify_fail(context):
    request = context.request
    customer_profile_dto = DataClassParser.parse_rows(
        context.table.rows, data_class=CreateUpdateCustomerProfileDTO
    )[0]

    data = customer_profile_dto.get_dict()
    data["customer_id"] = context.data[
        customer_profile_dto.customer_identifier
    ].customer_id
    response = request.hugoserve_post_request(profile_customer_profile_url[:-1], data)
    check_status(response, "PSM_E9409")


@Step("I delete the above created Customer-Profile")
def delete_customer(context):
    request = context.request

    customers_to_delete = DataClassParser.row_to_dict(context.table.rows)

    for customer_profile_to_delete in customers_to_delete:
        customer_profile_identifier = customer_profile_to_delete["identifier"]
        customer_profile_id = context.data[
            customer_profile_identifier
        ].customer_profile_id
        uri = profile_customer_profile_url + customer_profile_id
        response = request.hugoserve_delete_request(uri)
        check_status(response, 200)


@Step("I verify Customer-Profile doesn't exist")
def verify_customer_profile_not_exist(context):
    request = context.request

    deleted_customers = DataClassParser.row_to_dict(context.table.rows)

    for deleted_customer in deleted_customers:
        identifier = deleted_customer["identifier"]
        customer_profile_id = context.data[identifier].customer_profile_id

        response = request.hugoserve_get_request(
            profile_customer_profile_url + customer_profile_id
        )
        # TODO Re check this @Mudassir
        check_status(response, "200")

        assert (
            "data" not in response
        ), f"\nExpect response.data: <empty> \nActual response.data: {response['data']}"
        assert "Customer Id:  not found" == response["headers"]["message"], (
            f"\nExpect response.headers.message: 'Customer Id:  not found'"
            f"\nActual response.headers.message: {response['headers']['message']}"
        )


@Then("I try to create a second Customer-Profile in same region")
def fail_profile_in_same_region(context):
    request = context.request
    customer_profile_dto_list = DataClassParser.parse_rows(
        context.table.rows, data_class=CreateUpdateCustomerProfileDTO
    )
    context.data = {} if context.data is None else context.data

    for customer_profile_dto in customer_profile_dto_list:
        data = customer_profile_dto.get_dict()
        customer_id = context.data[customer_profile_dto.customer_identifier].customer_id
        data["customer_id"] = customer_id
        data.pop("customer_identifier", None)

        response = request.hugoserve_post_request(
            profile_customer_profile_url[:-1], data
        )
        check_status(response, "PSM_E9601")

        assert (
            "data" not in response
        ), f"\nExpect response.data: <empty> \nActual response.data: {response['data']}"

        error_msg = "Customer profile already exists in region"
        assert error_msg.casefold() == response["headers"]["message"].casefold(), (
            f"\nExpect response.headers.message: {error_msg}"
            f"\nActual response.headers.message: {response['headers']['message']}"
        )
