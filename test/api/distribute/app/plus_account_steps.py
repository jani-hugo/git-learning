import os
import requests
import time
from behave import *
from pathlib import Path
from retry import retry

import test.api.distribute.app.app_helper as ah
from test.api.distribute.app.app_dataclass import (
    ComplianceInitiateRequestDTO,
    ComplianceSubmitRequestDTO,
)
from test.util.common_util import check_status_distribute

use_step_matcher("re")


@Step("I update ([^']*) status of ([^']*) as ([^']*)")
def manual_upgrade(context, compliance_type: str, user, status: str):
    request = context.request

    user_profile_id = context.data["users"].get(user)["userProfileId"]
    body = {"complianceType": compliance_type, "status": status}
    time.sleep(10)

    response = request.hugosave_put_request(
        path=ah.dev_urls["compliance"],
        headers=ah.get_user_header(user_profile_id, context),
        data=body,
    )

    if not check_status_distribute(response, "200"):
        assert False, f"Manual User verification failed.\nReceived : {response}"


@Step("I check if user ([^']*) account type is ([^']*)")
def check_acc_type(context, user, acc_type):
    request = context.request
    user_profile_identifier = user
    user_profile_id = context.data["users"].get(user)["userProfileId"]

    @retry(AssertionError, tries=30, delay=10, logger=None)
    def retry_for_plus_status():
        response = request.hugosave_get_request(
            ah.user_profile_urls["details"],
            headers=ah.get_user_header(user_profile_id, context),
        )

        assert response["data"]["userState"]["accountStage"] == acc_type
        context.data["users"][user_profile_identifier] = response["data"]
        premium_map_count = 0
        user_state = response["data"]["userState"]["accountStage"]
        for map in response["data"]["userMaps"]:
            if map["mapType"] == "PM_GOLD_VAULT":
                context.data["users"][user]["gold-map"] = map
            elif map["mapType"] == "PM_SILVER_VAULT" and user_state == "PREMIUM":
                context.data["users"][user]["silver-map"] = map
                premium_map_count += 1
            elif map["mapType"] == "PM_PLATINUM_VAULT" and user_state == "PREMIUM":
                context.data["users"][user]["platinum-map"] = map
                premium_map_count += 1
            elif map["mapType"] == "ETF_BALANCED_VAULT" and user_state == "PREMIUM":
                context.data["users"][user]["etf-balanced-map"] = map
                premium_map_count += 1
            elif map["mapType"] == "ETF_GROWTH_VAULT" and user_state == "PREMIUM":
                context.data["users"][user]["etf-growth-map"] = map
                premium_map_count += 1
            elif map["mapType"] == "ETF_CAUTIOUS_VAULT" and user_state == "PREMIUM":
                context.data["users"][user]["etf-cautious-map"] = map
                premium_map_count += 1
            elif map["mapType"] == "ETF_MONEY_MARKET_VAULT" and user_state == "PREMIUM":
                context.data["users"][user]["etf-mmf-map"] = map
                premium_map_count += 1

        if user_state == "PREMIUM":
            assert premium_map_count == 5

    retry_for_plus_status()


@Step("I check if demo user ([^']*) account type is ([^']*)")
def check_acc_type(context, user, acc_type):
    request = context.request
    user_profile_identifier = user
    user_profile_id = context.data["users"].get(user)["userProfileId"]

    @retry(AssertionError, tries=30, delay=10, logger=None)
    def retry_for_premium_status():
        response = request.hugosave_get_request(
            ah.user_profile_urls["details"],
            headers=ah.get_user_header(user_profile_id, context),
        )

        assert response["data"]["userState"]["accountStage"] == acc_type
        context.data["users"][user_profile_identifier] = response["data"]
        for map in response["data"]["userMaps"]:
            if map["mapType"] == "PM_GOLD_VAULT":
                context.data["users"][user]["gold-map"] = map

    retry_for_premium_status()


@Step("I request to process user ([^']*) trust compliance")
def process_trust_success(context, user_profile_identifier):
    request = context.request
    user_profile_identifier = user_profile_identifier
    user_profile_id = context.data["users"].get(user_profile_identifier)[
        "userProfileId"
    ]

    response = request.hugosave_post_request(
        path=ah.compliance_urls["trust-compliance"],
        headers=ah.get_user_header(user_profile_id, context),
    )

    if not check_status_distribute(response, "200"):
        assert False, f"Unable to process trust compliance.\nReceived : {response}"


@then(
    "I initiate ([^']*) for user ([^']*) with content type as ([^']*) and expect status ([^']*)"
)
def initiate_compliance_success(
    context, compliance_type, user_profile_identifier, content_type, status_code
):
    request = context.request
    user_profile_identifier = user_profile_identifier
    user_profile_id = context.data["users"].get(user_profile_identifier)[
        "userProfileId"
    ]

    request_dto = ComplianceInitiateRequestDTO(compliance_type, content_type).get_dict()

    initiate_compliance_response = request.hugosave_post_request(
        path=ah.compliance_urls["initiate-compliance"],
        headers=ah.get_user_header(user_profile_id, context),
        data=request_dto,
    )

    assert check_status_distribute(
        initiate_compliance_response, status_code
    ), f"""
            \nExpected Status: {status_code}\n
            Actual Status: {initiate_compliance_response["headers"]["statusCode"]}
            """

    #     get response object and store in context
    context.data["users"][user_profile_identifier]["initiate-compliance-response"] = (
        initiate_compliance_response["data"]
    )


def get_presigned_url(document_type, documents):
    for document in documents:
        if document["documentName"] == document_type:
            return document["preSignedUrl"]

    assert (
        False
    ), f"Presigned url not found for document : {document_type} in \n {documents}"


@then(
    "I upload document ([^']*) using presigned URL for user ([^']*) and expect status ([^']*)"
)
def step_impl(context, document_type, user_profile_identifier, status_code):
    presigned_url = get_presigned_url(
        document_type,
        context.data["users"].get(user_profile_identifier)[
            "initiate-compliance-response"
        ]["documents"],
    )

    document_file_path = os.path.join(
        Path(os.path.abspath(__file__)).parent, "test-docs"
    )
    if "SELFIE" in document_type:
        document_file_path = f"{document_file_path}/Selfie.png"
    elif "FRONT" in document_type:
        document_file_path = f"{document_file_path}/Front.png"
    elif "BACK" in document_type:
        document_file_path = f"{document_file_path}/Back.png"

    with open(document_file_path, "rb") as file1:
        files = {"file": (document_file_path, file1.read())}
        upload_response = requests.put(
            presigned_url, files=files, headers={"Content-type": "image/png"}
        )

        if upload_response.status_code != status_code:
            print(f"Expected: {status_code} received: {upload_response}")


@then("I submit ([^']*) document for ([^']*) for user ([^']*)")
def initiate_compliance_success(
    context, document_type, compliance_type, user_profile_identifier
):
    request = context.request
    user_profile_identifier = user_profile_identifier
    user_profile_id = context.data["users"].get(user_profile_identifier)[
        "userProfileId"
    ]
    compliance_id = context.data["users"].get(user_profile_identifier)[
        "initiate-compliance-response"
    ]["complianceId"]
    compliance_type = context.data["users"].get(user_profile_identifier)[
        "initiate-compliance-response"
    ]["complianceType"]

    request_dto = ComplianceSubmitRequestDTO(
        compliance_id, compliance_type, document_type
    ).get_dict()

    submit_compliance_response = request.hugosave_post_request(
        path=ah.compliance_urls["submit-compliance"],
        headers=ah.get_user_header(user_profile_id, context),
        data=request_dto,
    )

    if not check_status_distribute(submit_compliance_response, "200"):
        assert (
            False
        ), f"Unable to initiate compliance.Received :\n {submit_compliance_response}"
