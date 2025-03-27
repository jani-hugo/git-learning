import json

from behave import *
from retry import retry

use_step_matcher("re")
import test.api.distribute.app.app_helper as ah
from test.util.common_util import check_status_distribute

@Step("I initiate the initial user authorisation token for ([^']*) of user ([^']*)")
def get_initial_authentication_token(context, action, user_profile_identifier):
    request = context.request
    user_prof_id = ah.get_user_profile_id(user_profile_identifier, context)
    response = request.hugosave_post_request(
        path=ah.get_user_authorisation_token_urls["initial-initiate"],
        headers=ah.get_user_header(user_prof_id, context),
        params={"action": action}
    )
    context.data["users"][user_profile_identifier]["user_initial_authorisation_token_response"] = response["data"]
    context.data["users"][user_profile_identifier]["user_authorisation_token"] = response["data"]["userAuthorisationToken"]
    check_status_distribute(response, "200")


@then("I initiate the final user authorisation token for ([^']*) of user ([^']*)")
def step_impl(context, action, user_profile_identifier):
    request = context.request
    user_prof_id = ah.get_user_profile_id(user_profile_identifier, context)
    headers=ah.get_user_header(user_prof_id, context)
    headers["x-initial-user-authorisation-token"] = context.data["users"][user_profile_identifier]["user_initial_authorisation_token_response"]["userAuthorisationToken"]
    response = request.hugosave_post_request(
        path=ah.get_user_authorisation_token_urls["final-initiate"],
        headers=headers,
        params={"action": action},
        data={}
    )
    context.data["users"][user_profile_identifier]["user_final_authentication_token_response"] = response["data"]
    check_status_distribute(response, "200")


@step("I initiate otp journey for user ([^']*)")
def step_impl(context, user_profile_identifier):
    request = context.request
    user_prof_id = ah.get_user_profile_id(user_profile_identifier, context)
    journeys = context.data["users"][user_profile_identifier]["user_final_authentication_token_response"]["journeys"]
    headers=ah.get_user_header(user_prof_id, context)
    journey_id = journeys[0]["journeyId"]
    response = request.hugosave_post_request(
        path=ah.get_user_authorisation_token_urls["journey-initiate"].replace("journey-id",journey_id),
        headers=headers,
        data={}
    )
    context.data["users"][user_profile_identifier]["journey_initiate_response"] = response["data"]
    check_status_distribute(response, "200")


@step("I submit otp journey for user ([^']*)")
def step_impl(context, user_profile_identifier):
    request = context.request
    user_prof_id = ah.get_user_profile_id(user_profile_identifier, context)
    journeys = context.data["users"][user_profile_identifier]["user_final_authentication_token_response"]["journeys"]
    headers=ah.get_user_header(user_prof_id, context)
    journey_id = journeys[0]["journeyId"]
    submit_session_id = context.data["users"][user_profile_identifier]["journey_initiate_response"]["data"]["sessionId"]
    body = {
        "data": json.dumps({
            "submit_session_id": submit_session_id,
            "submitted_otp": 123456
        })
    }

    response = request.hugosave_post_request(
        path=ah.get_user_authorisation_token_urls["journey-submit"].replace("journey-id",journey_id),
        headers=headers,
        data=body
    )
    context.data["users"][user_profile_identifier]["journey_submit_response"] = response["data"]
    check_status_distribute(response, "200")


@step("I submit the final user authorisation for ([^']*) of user ([^']*)")
def step_impl(context, action, user_profile_identifier):
    request = context.request
    user_prof_id = ah.get_user_profile_id(user_profile_identifier, context)
    session_id = context.data["users"][user_profile_identifier]["user_final_authentication_token_response"]["authorisationSessionId"]
    headers=ah.get_user_header(user_prof_id, context)
    response = request.hugosave_put_request(
        path=ah.get_user_authorisation_token_urls["final-submit"].replace("session-id",session_id),
        headers=headers,
    )
    check_status_distribute(response, "200")


@step("I get the final user authorisation token for ([^']*) of user ([^']*)")
def step_impl(context, action, user_profile_identifier):
    request = context.request
    user_prof_id = ah.get_user_profile_id(user_profile_identifier, context)
    session_id = context.data["users"][user_profile_identifier]["user_final_authentication_token_response"]["authorisationSessionId"]
    headers=ah.get_user_header(user_prof_id, context)
    @retry(AssertionError, tries=30, delay=10, logger=None)
    def retry_for_authorisation_token():
        response = request.hugosave_get_request(
            path=ah.get_user_authorisation_token_urls["final-status"].replace("session-id",session_id),
            headers=headers,
        )
        if response["headers"]["statusCode"] == "200" and "userAuthorisationToken" in response["data"]:
            context.data["users"][user_profile_identifier]["user_authorisation_token"] = response["data"]["userAuthorisationToken"]
            assert True
        else:
            assert False, "userAuthorisationToken is missing or status code is not 200"

    retry_for_authorisation_token()




