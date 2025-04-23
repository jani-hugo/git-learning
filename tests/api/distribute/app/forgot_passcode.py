import json

from behave import *
import test.api.distribute.app.app_helper as ah
from test.util.common_util import check_status_distribute

use_step_matcher("re")

@Step("I Initiate forgot passcode for user ([^']*)")
def initiate_forgot_passcode(context, user_profile_identifier):
    request = context.request
    user_name = context.data['users'][user_profile_identifier]['submit_mobile_verification_response']['userName']
    verification_token = context.data['users'][user_profile_identifier]['submit_mobile_verification_response']['verificationToken']
    user_name_details = {
        'x-user-name': user_name
    }
    headers=user_name_details
    headers['x-verification-token'] = verification_token
    headers['x-device-id'] = '455636'
    response = request.hugosave_post_request(
        path=ah.forgot_passcode_token_urls['initiate'],
        headers=headers
    )

    check_status_distribute(response, 200)
    context.data['users'][user_profile_identifier]['initiate_forgot_passcode'] = response['data']


@then("I check the status of initiate forgot passcode for user ([^']*)")
def step_impl(context, user_profile_identifier):
    request = context.request
    user_name = context.data['users'][user_profile_identifier]['submit_mobile_verification_response']['userName']
    verification_token = context.data['users'][user_profile_identifier]['submit_mobile_verification_response']['verificationToken']
    session_id = context.data['users'][user_profile_identifier]['initiate_forgot_passcode']['forgotPasscodeSessionId']
    user_name_details = {
        'x-user-name': user_name
    }
    headers=user_name_details
    headers['x-device-id'] = '455636'
    headers['x-verification-token'] = verification_token
    response = request.hugosave_get_request(
        path=ah.forgot_passcode_token_urls['check-initiate-status'].replace('session-id',session_id),
        headers=headers,
    )
    check_status_distribute(response, 200)


@step("I start a passcode reset OTP Journey for ([^']*)")
def step_impl(context, user_profile_identifier):
    request = context.request
    journeys = context.data["users"][user_profile_identifier]["initiate_forgot_passcode"]["journeys"]
    user_name = context.data['users'][user_profile_identifier]['submit_mobile_verification_response']['userName']
    verification_token = context.data['users'][user_profile_identifier]['submit_mobile_verification_response']['verificationToken']
    user_name_details = {
        'x-user-name': user_name
    }
    headers=user_name_details
    headers['x-device-id'] = '455636'
    headers['x-verification-token'] = verification_token

    journey_id = journeys[0]["journeyId"]
    response = request.hugosave_post_request(
        path=ah.forgot_passcode_token_urls["journey-initiate"].replace("journey-id",journey_id),
        headers=headers,
        data={}
    )
    context.data["users"][user_profile_identifier]["journey_initiate_response"] = response["data"]
    check_status_distribute(response, "200")


@step("I submit a passcode reset OTP Journey for ([^']*)")
def step_impl(context, user_profile_identifier):
    request = context.request
    journeys = context.data["users"][user_profile_identifier]["initiate_forgot_passcode"]["journeys"]
    journey_id = journeys[0]["journeyId"]
    submit_session_id = context.data["users"][user_profile_identifier]["journey_initiate_response"]["data"]["sessionId"]
    user_name = context.data['users'][user_profile_identifier]['submit_mobile_verification_response']['userName']
    verification_token = context.data['users'][user_profile_identifier]['submit_mobile_verification_response']['verificationToken']
    user_name_details = {
        'x-user-name': user_name
    }
    headers=user_name_details
    headers['x-device-id'] = '455636'
    headers['x-verification-token'] = verification_token
    body = {
        "data": json.dumps({
            "submit_session_id": submit_session_id,
            "submitted_otp": 123456
        })
    }

    response = request.hugosave_post_request(
        path=ah.forgot_passcode_token_urls["journey-submit"].replace("journey-id",journey_id),
        headers=headers,
        data=body
    )
    context.data["users"][user_profile_identifier]["journey_submit_response"] = response["data"]
    check_status_distribute(response, "200")


@step("I submit the forgot passcode of user ([^']*)")
def step_impl(context, user_profile_identifier):
    request = context.request
    user_name = context.data['users'][user_profile_identifier]['submit_mobile_verification_response']['userName']
    verification_token = context.data['users'][user_profile_identifier]['submit_mobile_verification_response']['verificationToken']
    user_name_details = {
        'x-user-name': user_name
    }
    session_id = context.data["users"][user_profile_identifier]["initiate_forgot_passcode"]["forgotPasscodeSessionId"]
    headers=user_name_details
    headers['x-device-id'] = '455636'
    headers['x-verification-token'] = verification_token
    response = request.hugosave_post_request(
        path=ah.forgot_passcode_token_urls["final-submit"],
        headers=headers,
        data={'forgot_passcode_session_id': session_id, 'forgot_passcode_journey': 'OTP'}
    )
    check_status_distribute(response, "200")


@step("I get the forgot password token of user ([^']*)")
def step_impl(context, user_profile_identifier):
    request = context.request
    user_name = context.data['users'][user_profile_identifier]['submit_mobile_verification_response']['userName']
    verification_token = context.data['users'][user_profile_identifier]['submit_mobile_verification_response']['verificationToken']
    user_name_details = {
        'x-user-name': user_name
    }
    session_id = context.data["users"][user_profile_identifier]["initiate_forgot_passcode"]["forgotPasscodeSessionId"]
    headers=user_name_details
    headers['x-device-id'] = '455636'
    headers['x-verification-token'] = verification_token
    response = request.hugosave_get_request(
        path=ah.forgot_passcode_token_urls["final-status"].replace("session-id",session_id),
        headers=headers,
    )
    context.data["users"][user_profile_identifier]["forgot_passcode_token"] = response["data"]["forgotPasscodeToken"]
    check_status_distribute(response, "200")


@step("I update the password for user ([^']*)")
def step_impl(context, user_profile_identifier):
    request = context.request
    user_name = context.data['users'][user_profile_identifier]['submit_mobile_verification_response']['userName']
    verification_token = context.data['users'][user_profile_identifier]['submit_mobile_verification_response']['verificationToken']
    user_name_details = {
        'x-user-name': user_name
    }
    headers = user_name_details
    headers['x-device-id'] = '455636'
    headers['x-verification-token'] = verification_token
    headers['x-forgot-passcode-token'] = context.data["users"][user_profile_identifier]["forgot_passcode_token"]
    response = request.hugosave_post_request(
        path=ah.forgot_passcode_token_urls["update-passcode"],
        headers=headers,
        data={"passcode": "333333"}
    )
    check_status_distribute(response, "200")
