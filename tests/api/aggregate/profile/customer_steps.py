import uuid as uuid

from hugoutils.utilities.dataclass_util import DataClassParser

from tests.api.aggregate.profile.profile_dataclass import (
    CreateUpdateCustomerDTO,
    CustomerDTO,
    CustomerProfileDTO,
)
from behave import *

from tests.util.common_util import check_status

use_step_matcher("re")
profile_customer_admin_url = "/profile/v1/admin/customer/"


@Given("I set and verify customer ([^']*), customer profile ([^']*) in the context")
def setup_customer_profile(
    context, customer_identifier: str, customer_profile_identifier: str
):
    request = context.request
    customer_profile_dict = {
        "customer_identifier": customer_identifier,
        "customer_id": context.data["config_data"]["customer_id"],
        "customer_profile_id": context.data["config_data"]["customer_profile_id"],
        "region": "SGP",
        "name": "Integration test",
        "email": "admin@hugosave.com",
        "phone_number": "+65 1234567890",
        "status": "SUCCESS",
    }

    customer_profile_dto = DataClassParser.dict_to_object(
        data=customer_profile_dict, data_class=CustomerProfileDTO
    )
    context.data[customer_identifier] = customer_profile_dto
    context.data[customer_profile_identifier] = customer_profile_dto


@Given("I create below Customer")
def create_customer(context):
    request = context.request

    customer_dto_list = DataClassParser.parse_rows(
        context.table.rows, data_class=CreateUpdateCustomerDTO
    )
    context.data = {} if context.data is None else context.data

    for customer_dto in customer_dto_list:
        customer_dto.name = str(uuid.uuid1())
        response = request.hugoserve_post_request(
            profile_customer_admin_url[:-1], data=customer_dto.get_dict()
        )
        check_status(response, 200)
        customer_dto.customer_id = response["data"][
            "customer_id"
        ]  # Save customer_id in object

        assert (
            customer_dto.customer_id not in context.data
        ), f"An existing customer_id: {customer_dto.customer_id} found while creating customers"
        context.data[customer_dto.customer_identifier] = (
            customer_dto  # Save customer_dto against identifier
        )

        customers = context.data.get("customers", {})
        customers[customer_dto.customer_identifier] = customer_dto
        context.data["customers"] = customers  # Save customer_dto in customers map too


@Then("I verify customers exist with values")
def verify_customer_exist(context):
    request = context.request

    customer_dto_list = DataClassParser.parse_rows(
        context.table.rows, data_class=CustomerDTO
    )

    for expected_customer_dto in customer_dto_list:
        customer_id = context.data[
            expected_customer_dto.customer_identifier
        ].customer_id
        expected_customer_dto.name = context.data[
            expected_customer_dto.customer_identifier
        ].name
        response = request.hugoserve_get_request(
            profile_customer_admin_url + customer_id
        )
        data = response["data"]
        check_status(response, "200")

        actual_customer_dto = DataClassParser.dict_to_object(
            data, data_class=CustomerDTO
        )

        sanitized_expected = CustomerDTO.sanitize_customer_dto(expected_customer_dto)
        sanitized_actual = CustomerDTO.sanitize_customer_dto(actual_customer_dto)
        assert sanitized_expected == sanitized_actual, (
            f"\nExpect customer_dto: {sanitized_expected}"
            f"\nActual customer_dto: {sanitized_actual}"
        )


@Given("I attempt to create customer with missing datatype and verify create failed")
def create_customer_with_incorrect_data_verify_fail(context):
    request = context.request
    customer_dto = DataClassParser.parse_rows(
        context.table.rows, data_class=CreateUpdateCustomerDTO
    )[0]

    response = request.hugoserve_post_request(
        profile_customer_admin_url[:-1], data=customer_dto.get_dict()
    )

    check_status(response, "PSM_E9401")


@Step("I delete the above created customer")
def delete_customer(context):
    request = context.request

    customers_to_delete = DataClassParser.row_to_dict(context.table.rows)

    for customer_to_delete in customers_to_delete:
        identifier = customer_to_delete["customer_identifier"]
        customer_id = context.data[identifier].customer_id
        response = request.hugoserve_delete_request(
            profile_customer_admin_url + customer_id
        )
        check_status(response, "200")


@Step("I verify customer doesn't exist")
def verify_customer_not_exist(context):
    request = context.request
    deleted_customers = DataClassParser.row_to_dict(context.table.rows)

    for deleted_customer in deleted_customers:
        identifier = deleted_customer["identifier"]
        customer_id = context.data[identifier].customer_id

        response = request.hugoserve_get_request(
            profile_customer_admin_url + customer_id
        )
        check_status(response, "200")

        assert (
            "data" not in response
        ), f"\nExpect response.data: <empty> \nActual response.data: {response['data']}"
        assert "Customer Id:  not found" == response["headers"]["message"], (
            f"\nExpect response.headers.message: 'Customer Id:  not found'"
            f"\nActual response.headers.message: {response['headers']['message']}"
        )
