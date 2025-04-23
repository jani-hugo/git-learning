from behave import *
from retry import retry
import tests.api.distribute.app.app_helper as ah
import json
import requests
from tests.util.common_util import check_status_distribute

use_step_matcher("re")


@Step(
    "I initiate progress onboarding for the user ([^']*) to upgrade account to PREMIUM"
)
def initiate_onboarding(context, uid):
    request = context.request
    user_profile_id = ah.get_user_profile_id(uid, context)
    initiate_onboarding_response = request.hugosave_post_request(
        path=ah.progress_onboarding_urls["initiate-progress-onboarding"],
        headers=ah.get_user_header(user_profile_id, context),
        data={"accountLevel": "L3"},
    )
    if not check_status_distribute(initiate_onboarding_response, "200"):
        assert (
            False
        ), f"unable to initiate onboarding: \t {initiate_onboarding_response}"
    context.data["users"][uid]["initiate_onboarding_response"] = (
        initiate_onboarding_response["data"]
    )


@Step("I initiate ([^']*) for the user ([^']*) and expect a status code of ([^']*)")
def initiate_journey(context, journey_type, uid, expected_status):
    request = context.request
    user_profile_id = ah.get_user_profile_id(uid, context)
    context.data["users"][uid]["current_journey_index"] = 0
    jid = ah.get_journey_id(context, uid, journey_type)
    journey_id = jid[0]
    url = ah.progress_onboarding_urls["initiate-onboarding-journey"].format(
        **{"journey-id": journey_id}
    )
    initiate_journey_response = request.hugosave_post_request(
        path=url, headers=ah.get_user_header(user_profile_id, context), data={}
    )
    if not check_status_distribute(initiate_journey_response, expected_status):
        assert (
            False
        ), f"unable to initiate {journey_type} journey:\t{initiate_journey_response}"
    context.data["users"][uid]["initiate_journey_response"] = initiate_journey_response[
        "data"
    ]


@Step("I submit ([^']*) for the user ([^']*) and expect a status code of ([^']*)")
def submit_journey(context, journey_type, uid, expected_status):
    request = context.request
    user_profile_id = ah.get_user_profile_id(uid, context)
    jid = ah.get_journey_id(context, uid, journey_type)
    journey_id = jid[0]
    url = ah.progress_onboarding_urls["submit-onboarding-journey"].format(
        **{"journey-id": journey_id}
    )
    json_string = json.dumps(context.data["users"][uid]["initiate_journey_response"]["data"])

    request_body = {
        "data": json_string
    }
    journey_submit_response = request.hugosave_post_request(
        path=url, headers=ah.get_user_header(user_profile_id, context), data=request_body
    )
    if not check_status_distribute(journey_submit_response, expected_status):
        assert (
            False
        ), f"unable to submit {journey_type} journey:\t {journey_submit_response}"


@Step("I check status of ([^']*) for the user ([^']*)")
def check_journey_status(context, journey_type, uid):
    request = context.request
    user_profile_id = ah.get_user_profile_id(uid, context)
    jid = ah.get_journey_id(context, uid, journey_type)
    journey_id = jid[0]
    url = ah.progress_onboarding_urls["onboarding-journey-status"].format(
        **{"journey-id": journey_id}
    )

    @retry(AssertionError, tries=30, delay=5, logger=None)
    def retry_journey_status():
        journey_status_response = request.hugosave_get_request(
            path=url, headers=ah.get_user_header(user_profile_id, context)
        )
        if journey_status_response["data"]["journeyStatus"] == "JOURNEY_SUCCESSFUL":
            context.data["users"][uid]["current_journey_index"] += 1
        else:
            assert (
                False
            ), f"unable to get status for {journey_type} journey:\t {journey_status_response}"

    retry_journey_status()


def get_presignd_url(context, uid, document_type, document_list):
    for document in document_list:
        if "FRONT" in document_type:
            return context.data["users"][uid]["initiate_journey_response"]["data"][
                "documentFrontUrl"
            ]
        elif "BACK" in document_type:
            return context.data["users"][uid]["initiate_journey_response"]["data"][
                "documentBackUrl"
            ]
        elif "SELFIE" in document_type:
            return context.data["users"][uid]["initiate_journey_response"]["data"][
                "documentSelfieUrl"
            ]
    assert (
        False
    ), f"No pre-signed urls found for document type{document_type} in {document_list}"


@Step("I upload document ([^']*) for the user ([^']*)")
def upload_documents(context, document_type, uid):
    presigned_url = get_presignd_url(
        context,
        uid,
        document_type,
        context.data["users"][uid]["initiate_journey_response"]["data"],
    )

    if "FRONT" in document_type:
        document_file_path = "test/api/distribute/app/test-docs/Selfie.png"
    elif "BACK" in document_type:
        document_file_path = "test/api/distribute/app/test-docs/Back.png"
    elif "SELFIE" in document_type:
        document_file_path = "test/api/distribute/app/test-docs/Front.png"

    with open(document_file_path, "rb") as file1:
        upload_document_response = requests.put(
            presigned_url,
            data=file1,
            headers={"Content-Type": "image/jpg"},
        )
        if not upload_document_response.status_code == 200:
            assert (
                False
            ), f"Unable to upload {document_type} file to the presigned url, the returned response is: {upload_document_response}"


@Step("I submit ([^']*) for the user ([^']*) so we can convert the account to PREMIUM")
def submit_journey_selfie(context, journey_type, uid):
    request = context.request
    user_profile_id = ah.get_user_profile_id(uid, context)
    jid = ah.get_journey_id(context, uid, journey_type)
    journey_id = jid[0]
    url = ah.progress_onboarding_urls["submit-onboarding-journey"].format(
        **{"journey-id": journey_id}
    )
    request_body = {
        "address": {
            "addressLine1": "277",
            "addressLine2": "ORCHARD ROAD",
            "addressLine3": "# 01-01 ORCHARD GATEWAY",
            "addressLine4": "",
            "city": "Singapore",
            "state": "",
            "country_code": "SGP",
            "local_code": "238858",
        },
        "dob": "22-03-2000",
        "legalName": "John Doe",
        "nationality": "Singapore",
        "document_front_url": context.data["users"][uid]["initiate_journey_response"][
            "data"
        ]["documentFrontUrl"],
        "document_back_url": context.data["users"][uid]["initiate_journey_response"][
            "data"
        ]["documentBackUrl"],
        "document_selfie_url": context.data["users"][uid]["initiate_journey_response"][
            "data"
        ]["documentSelfieUrl"],
        "document_type": "NRIC",
        "document_number": "S9048874J",
        "document_expiry_date": "30-01-2035",
        "tax_id_number": "S9048874J",
        "additional_documents": [],
    }
    data = json.dumps(request_body)
    journey_submit_response = request.hugosave_post_request(
        path=url,
        headers=ah.get_user_header(user_profile_id, context),
        data={"data": data},
    )
    if not check_status_distribute(journey_submit_response, 200):
        assert (
            False
        ), f"Failed to submit the HUGOSAVE_SELFIE_AND_SCAN_ID journey, the returned response is: {journey_submit_response}"


@Step("I upgrade the user ([^']*) account level to L3")
def status_update(context, uid):
    request = context.request
    user_profile_id = ah.get_user_profile_id(uid, context)
    url = ah.dev_urls["compliance_update"]
    status_update_response = request.hugosave_put_request(
        path=url,
        headers=ah.get_user_header(user_profile_id, context),
        params={"level": "L3"},
    )


@Step("I submit the progress onboarding for user ([^']*)")
def submit_progress_onboarding(context, uid):
    request = context.request
    user_profile_id = ah.get_user_profile_id(uid, context)
    onboarding_id = ah.get_progress_onboarding_id(context, uid)
    submit_onboarding_response = request.hugosave_post_request(
        path=ah.progress_onboarding_urls["submit-progress-onboarding"],
        headers=ah.get_user_header(user_profile_id, context),
        data={"onboarding_id": onboarding_id},
    )


@Step("I check the status of ([^']*) for the user ([^']*)")
def check_journey_status(context, journey_type, uid):
    request = context.request
    user_profile_id = ah.get_user_profile_id(uid, context)
    jid = ah.get_journey_id(context, uid, journey_type)
    journey_id = jid[0]
    url = ah.progress_onboarding_urls["onboarding-journey-status"].format(
        **{"journey-id": journey_id}
    )

    @retry(AssertionError, tries=30, delay=5, logger=None)
    def retry_journey_status():
        journey_status_response = request.hugosave_get_request(
            path=url, headers=ah.get_user_header(user_profile_id, context)
        )
        if journey_status_response["data"]["journeyStatus"] == "JOURNEY_SUBMITTED":
            context.data["users"][uid]["current_journey_index"] += 1
        else:
            assert (
                False
            ), f"unable to get status for {journey_type} journey:\t {journey_status_response}"

    retry_journey_status()


@Step("I check progress onboarding status for the user ([^']*)")
def check_initial_onboarding_status(context, uid):
    request = context.request
    user_profile_id = ah.get_user_profile_id(uid, context)

    @retry(AssertionError, tries=40, delay=25, logger=None)
    def retry_initial_onboarding_status():
        initial_onboarding_status_response = request.hugosave_get_request(
            path=ah.progress_onboarding_urls["progress-onboarding-status"],
            headers=ah.get_initial_onboarding_headers(user_profile_id, context, uid),
        )
        if not check_status_distribute(initial_onboarding_status_response, 200):
            assert (
                False
            ), f"Failed to fetch initial onboarding status. \nReceived{initial_onboarding_status_response}"

        assert (
            initial_onboarding_status_response["data"]["onboardingStatus"]
            == "IN_PROGRESS"
        )

    retry_initial_onboarding_status()


@Step("I check the user details to confirm if user ([^']*) is premium")
def check_user_details(context, uid):
    request = context.request
    user_profile_id = ah.get_user_profile_id(uid, context)

    @retry(AssertionError, tries=30, delay=5, logger=None)
    def retry_user_details():
        user_details_response = request.hugosave_get_request(
            path=ah.user_profile_urls["details"],
            headers=ah.get_user_header(user_profile_id, context),
        )
        if not (user_details_response["data"]["userState"]["accountLevel"] == "L3"):
            assert False, f"retrying account details"
        else:
            context.data["users"][uid]["user_details_response"] = user_details_response[
                "data"
            ]

    retry_user_details()
