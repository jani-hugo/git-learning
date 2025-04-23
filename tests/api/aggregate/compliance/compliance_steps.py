import time
from pathlib import Path
import base64
import os
import random
import time

from hugoutils.utilities.dataclass_util import DataClassParser

from tests.api.aggregate.compliance.compliance_dataclass import (
    ComplianceImageDTO,
    ProcessComplianceDTO,
)
from behave import *
from retry import retry

from tests.util.common_util import check_status

use_step_matcher("re")
compliance_url = "/compliance/v1"
header_customer_profile_id = "x-customer-profile-id"


@Then("I try to verify data with invalid customer profile id")
def step_impl(context):
    request = context.request
    compliance_dto_list = DataClassParser.parse_rows(
        context.table.rows, data_class=ProcessComplianceDTO
    )
    context.data = {} if context.data is None else context.data
    for compliance_dto in compliance_dto_list:
        compliance_data = __get_compliance_data()
        data = compliance_dto.get_dict()
        customer_profile_id = data["customer_profile_id"]
        provider_id = data["provider_id"]
        compliance_data["provider_id"] = provider_id
        compliance_data["end_customer_profile_id"] = provider_id
        compliance_data["compliance_type"] = "IDV_JOURNEY"
        response = request.hugoserve_post_request(
            f"{compliance_url}/check/initiate-compliance",
            data=compliance_data,
            headers={header_customer_profile_id: customer_profile_id},
        )
        check_status(response, "E9400")


@Then("I try to verify user with data")
def step_impl(context):
    request = context.request
    compliance_dto_list = DataClassParser.parse_rows(
        context.table.rows, data_class=ProcessComplianceDTO
    )
    context.data = {} if context.data is None else context.data
    for compliance_dto in compliance_dto_list:
        compliance_data = __get_compliance_data()
        data = compliance_dto.get_dict()
        customer_profile_id = data["customer_profile_id"]
        if compliance_dto.customer_profile_identifier is not None:
            if context.data[compliance_dto.customer_profile_identifier] is not None:
                customer_profile_id = context.data[
                    compliance_dto.customer_profile_identifier
                ].customer_profile_id
        end_customer_profile_id = data["end_customer_profile_id"]
        if compliance_dto.end_customer_profile_identifier is not None:
            if context.data[compliance_dto.end_customer_profile_identifier] is not None:
                end_customer_profile_id = context.data[
                    compliance_dto.end_customer_profile_identifier
                ].end_customer_profile_id
        provider_id = data["provider_id"]
        compliance_type = data["compliance_type"]
        compliance_data["provider_id"] = (
            provider_id if provider_id is not None else "nonsense"
        )
        compliance_data["end_customer_profile_id"] = (
            end_customer_profile_id
            if end_customer_profile_id is not None
            else "nonsense"
        )
        compliance_data["compliance_type"] = (
            compliance_type if compliance_type is not None else "nonsense"
        )

        initiate_request = {
            "end_customer_profile_id": (
                end_customer_profile_id
                if end_customer_profile_id is not None
                else "nonsense"
            ),
            "provider_id": (
                data["provider_id"] if provider_id is not None else "nonsense"
            ),
            "compliance_type": (
                compliance_type if compliance_type is not None else "nonsense"
            ),
            "compliance_mode": "COMPLIANCE_MODE_OFFLINE",
        }
        response = request.hugoserve_post_request(
            f"{compliance_url}/check/initiate-compliance",
            data=initiate_request,
            headers={header_customer_profile_id: customer_profile_id},
        )
        check_status(response, data["status_code"])


@Then("I process compliance for the end customer")
def step_impl(context):
    request = context.request
    compliance_dto_list = DataClassParser.parse_rows(
        context.table.rows, data_class=ProcessComplianceDTO
    )
    context.data = {} if context.data is None else context.data
    for compliance_dto in compliance_dto_list:
        customer_profile_id = context.data[
            compliance_dto.customer_profile_identifier
        ].customer_profile_id
        end_customer_profile_id = context.data[
            compliance_dto.end_customer_profile_identifier
        ].end_customer_profile_id
        data = compliance_dto.get_dict()
        provider_id = data["provider_id"]
        compliance_type = data["compliance_type"]
        compliance_data = __get_compliance_data()
        compliance_data["end_customer_profile_id"] = end_customer_profile_id
        compliance_data["provider_id"] = provider_id
        compliance_data["compliance_type"] = compliance_type
        response = process_compliance_with_new_apis(
            context, compliance_data, customer_profile_id
        )
        check_status(response, data["status_code"])
        context.data[compliance_dto.compliance_identifier] = response["data"]

        time.sleep(5)

        @retry(Exception, tries=300 // 5, delay=5, logger=None)
        def verify_referred(compliance_id):
            response = request.hugoserve_get_request(
                f"{compliance_url}/check/{compliance_id}",
                headers={header_customer_profile_id: customer_profile_id},
            )
            assert response["headers"]["status_code"] == "200"
            comp_status = response["data"]["status"]
            status = "REFERRED"
            assert status == comp_status, (
                f"[TraceId: {response['headers']['trace_id']}]\n"
                f"Expect status: {status}\n"
                f"Actual status: {comp_status}"
            )

        verify_referred(response["data"]["compliance_id"])


@Then("I verify compliance details")
def verify(context):
    request = context.request

    compliance_dto_list = DataClassParser.parse_rows(
        context.table.rows, data_class=ComplianceImageDTO
    )
    context.data = {} if context.data is None else context.data

    for compliance_dto in compliance_dto_list:
        customer_profile_id = context.data[
            compliance_dto.customer_profile_identifier
        ].customer_profile_id
        end_customer_profile_id = context.data[
            compliance_dto.end_customer_profile_identifier
        ].end_customer_profile_id

        compliance_data = __get_compliance_data()
        compliance_data["end_customer_profile_id"] = end_customer_profile_id
        compliance_data["provider_id"] = compliance_dto.provider_id
        compliance_data["compliance_type"] = compliance_dto.compliance_type

        missing_param = compliance_dto.missing_param
        status_code = compliance_dto.status_code

        compliance_data = remove_parameter(missing_param, compliance_data)

        initiate_request = {
            "end_customer_profile_id": compliance_data["end_customer_profile_id"],
            "provider_id": compliance_data["provider_id"],
            "compliance_type": compliance_data["compliance_type"],
            "compliance_mode": "COMPLIANCE_MODE_OFFLINE",
        }
        initiate_response = context.request.hugoserve_post_request(
            f"{compliance_url}/check/initiate-compliance",
            data=initiate_request,
            headers={header_customer_profile_id: customer_profile_id},
        )
        compliance_id = initiate_response["data"]["complianceId"]

        submit_request = {"data": compliance_data["data"]}
        response = context.request.hugoserve_put_request(
            f"{compliance_url}/check/{compliance_id}/submit-compliance",
            data=submit_request,
            headers={header_customer_profile_id: customer_profile_id},
        )
        check_status(response, status_code)


@Then("I push dev webhook with status")
def step_impl(context):
    request = context.request
    compliance_dto_list = DataClassParser.parse_rows(
        context.table.rows, data_class=ProcessComplianceDTO
    )
    context.data = {} if context.data is None else context.data
    for compliance_dto in compliance_dto_list:
        customer_profile_id = context.data[
            compliance_dto.customer_profile_identifier
        ].customer_profile_id
        data = compliance_dto.get_dict()
        compliance_id = context.data[compliance_dto.compliance_identifier][
            "compliance_id"
        ]
        status = data["status"]
        response = request.hugoserve_put_request(
            f"{compliance_url}/dev/{compliance_id}/status/{status}",
            headers={header_customer_profile_id: customer_profile_id},
        )
        check_status(response, 200)


@Then("I fetch compliance status and verify")
def step_impl(context):
    request = context.request
    compliance_dto_list = DataClassParser.parse_rows(
        context.table.rows, data_class=ProcessComplianceDTO
    )
    context.data = {} if context.data is None else context.data
    for compliance_dto in compliance_dto_list:

        @retry(AssertionError, tries=300 // 5, delay=5, logger=None)
        def retry_compliance_status():
            customer_profile_id = context.data[
                compliance_dto.customer_profile_identifier
            ].customer_profile_id
            data = compliance_dto.get_dict()
            compliance_id = context.data[compliance_dto.compliance_identifier][
                "compliance_id"
            ]
            response = request.hugoserve_get_request(
                f"{compliance_url}/check/{compliance_id}",
                headers={header_customer_profile_id: customer_profile_id},
            )
            check_status(response, 200)
            comp_decision = response["data"]["decision"]
            decision = data["decision"]
            assert decision == comp_decision, (
                f"[TraceId: {response['headers']['trace_id']}]\n"
                f"Expect decision: {decision}\n"
                f"Actual decision: {comp_decision}"
            )

        retry_compliance_status()


def remove_parameter(missing_param: str, data: dict):
    if (
        missing_param == "first_name"
        or missing_param == "last_name"
        or missing_param == "date_of_birth"
        or missing_param == "email"
        or missing_param == "phone_number"
    ):
        data["data"]["input_fields"].pop(missing_param)
    elif (
        missing_param == "address_line_1"
        or missing_param == "address_line_2"
        or missing_param == "city"
        or missing_param == "country_code"
    ):
        data["data"]["input_fields"]["address"]["address_value"].pop(missing_param)
    return data


def __get_compliance_data():
    test_images_path = os.path.join(Path(os.path.abspath(__file__)).parent, "test-docs")
    with open(f"{test_images_path}/doc1.jpg", "rb") as img_file1:
        doc1 = base64.b64encode(img_file1.read()).decode("utf-8")
        img_file1.close()

    with open(f"{test_images_path}/doc2.jpg", "rb") as img_file2:
        doc2 = base64.b64encode(img_file2.read()).decode("utf-8")
        img_file2.close()
    with open(f"{test_images_path}/face.jpg", "rb") as img_file3:
        face = base64.b64encode(img_file3.read()).decode("utf-8")
        img_file3.close()

    random_str = str(random.randrange(111111, 999999, 6))
    compliance_data = {
        "end_customer_profile_id": "",
        "provider_id": "",
        "compliance_type": "",
        "data": {
            "input_fields": {
                "first_name": {"string_value": "Int" + random_str},
                "last_name": {"string_value": "Tester" + random_str},
                "date_of_birth": {"string_value": "1998-12-19"},
                "nationality": {"string_value": "SGP"},
                "email": {"string_value": "test" + random_str + "@hugosave.com"},
                "phone_number": {
                    "string_value": "+919515" + random_str,
                },
                "selfie": {
                    "page_value": {
                        "tag": "SELFIE",
                        "base64_source": {
                            "base64": "face",
                            "content_type": "image/png",
                        },
                    }
                },
                # No need of sending images on integration test environment
                "document": {
                    "document_value": {
                        "type": "id",
                        "pages": [
                            {
                                "tag": "FRONT",
                                "base64_source": {
                                    "base64": "doc1",
                                    "content_type": "image/png",
                                },
                            },
                            {
                                "tag": "BACK",
                                "base64_source": {
                                    "base64": "doc2",
                                    "content_type": "image/png",
                                },
                            },
                        ],
                    }
                },
                "address": {
                    "address_value": {
                        "address_line_1": "line1" + random_str,
                        "address_line_2": "line2" + random_str,
                        "address_line_3": "line3" + random_str,
                        "address_line_4": "lin4" + random_str,
                        "city": "city1" + random_str,
                        "state": "state2" + random_str,
                        "country": "Singapore",
                        "country_code": "SGP",
                        "local_code": random_str,
                    }
                },
            }
        },
    }
    return compliance_data


def process_compliance_with_new_apis(
    context, compliance_data: dict, customer_profile_id: str
):
    initiate_request = {
        "end_customer_profile_id": compliance_data["end_customer_profile_id"],
        "provider_id": compliance_data["provider_id"],
        "compliance_type": compliance_data["compliance_type"],
        "compliance_mode": "COMPLIANCE_MODE_OFFLINE",
    }
    initiate_response = context.request.hugoserve_post_request(
        f"{compliance_url}/check/initiate-compliance",
        data=initiate_request,
        headers={header_customer_profile_id: customer_profile_id},
    )
    compliance_id = initiate_response["data"]["complianceId"]

    submit_request = {"data": compliance_data["data"]}
    context.request.hugoserve_put_request(
        f"{compliance_url}/check/{compliance_id}/submit-compliance",
        data=submit_request,
        headers={header_customer_profile_id: customer_profile_id},
    )
    context.request.hugoserve_put_request(
        f"{compliance_url}/check/{compliance_id}/process-compliance",
        headers={header_customer_profile_id: customer_profile_id},
    )

    return context.request.hugoserve_get_request(
        f"{compliance_url}/check/{compliance_id}",
        headers={header_customer_profile_id: customer_profile_id},
    )
