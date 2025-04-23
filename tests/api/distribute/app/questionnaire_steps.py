import random

from behave import *
from yaml import SafeLoader
import tests.api.distribute.app.app_helper as ah
import yaml

from tests.util.common_util import check_status_distribute

use_step_matcher("re")


@Given("I fetch list of questionnaire")
def list_questionnaire_success(context):
    request = context.request
    response = request.hugosave_get_request(
        path=ah.questionnaire_urls["list"],
        headers=ah.get_user_header("HUGOSAVE_SG", context),
    )
    assert check_status_distribute(
        response, "200"
    ), f"""
        \nExpected Status: 200\n
        Actual Status: {response["headers"]["statusCode"]}
        """


@Given(
    "I check if questionnaire exists with name ([^']*) else create new questionnaire"
)
def create_questionnaire_success(context, questionnaire_name: str):
    request = context.request
    list_response = request.hugosave_get_request(
        path=ah.questionnaire_urls["list"],
        headers=ah.get_user_header("HUGOSAVE_SG", context),
    )
    assert check_status_distribute(list_response, "200")

    questionnaire_created = False
    for questionnaire_dto in list_response["data"]["questionnaires"]:
        if questionnaire_dto["questionnaireName"] == questionnaire_name:
            context.data[questionnaire_name] = questionnaire_dto
            questionnaire_created = True

    if not questionnaire_created:
        with open(
            f"scripts/app/hugosave_sg/questionnaire/suitability_questionnaire.yaml"
        ) as f:
            data = yaml.load(f, Loader=SafeLoader)

        questionnaire = data.get("questionnaire")
        questionnaire_name = questionnaire.get("questionnaire_name")
        questions = questionnaire.get("questions")

        questions_dto = []
        for question in questions:
            question_description = question["question_description"]
            question_mode = question["question_mode"]
            question_type = question["question_type"]

            options_dto = []
            for option in question["options"]:
                option_dto = {"score": option["score"]}
                if question_type == "OPTION_TEXT":
                    option_dto["text"] = option["text"]
                elif question_type == "OPTION_RANGE":
                    option_dto["range"] = option["range"]

                if "option_desc" in option:
                    option_dto["option_desc"] = option["option_desc"]

                options_dto.append(option_dto)

            question_dto = {
                "question_description": question_description,
                "question_mode": question_mode,
                "question_type": question_type,
                "options": options_dto,
            }
            questions_dto.append(question_dto)

        questionnaire_dto = {
            "questionnaire_name": questionnaire["questionnaire_name"],
            "questions": questions_dto,
        }

        response = request.hugosave_post_request(
            path=ah.dev_urls["questionnaire"], data=questionnaire_dto
        )
        assert check_status_distribute(list_response, "200")
        context.data[questionnaire_name] = response["data"]


@then("I fetch questionnaire ([^']*) and check status as ([^']*)")
def get_questionnaire_success(context, questionnaire_name: str, questionnaire_status):
    request = context.request
    questionnaire_id = context.data[questionnaire_name]["questionnaireName"]
    response = request.hugosave_get_request(
        headers=ah.get_user_header("HUGOSAVE_SG", context),
        path=ah.questionnaire_urls["details"].replace(
            "questionnaire-name", questionnaire_id
        ),
    )

    assert check_status_distribute(response, "200")
    if "data" in response:
        assert (
            response["data"]["questionnaireStatus"] == questionnaire_status
        ), f"Questionnaire status mismatch. Expected {questionnaire_status}\n Received : {response['data']}"


@given("I create questionnaire ([^']*) for user ([^']*) - questionnaire ([^']*)")
def create_user_questionnaire_success(
    context,
    user_questionnaire_identifier: str,
    user_profile_identifier: str,
    questionnaire_name: str,
):
    request = context.request
    questionnaire_id = context.data[questionnaire_name]["questionnaireName"]
    user_profile_id = context.data["users"].get(user_profile_identifier)[
        "userProfileId"
    ]
    response = request.hugosave_post_request(
        headers=ah.get_user_header(user_profile_id, context),
        path=ah.questionnaire_urls["user-questionnaire"],
        data={"questionnaire_name": questionnaire_id},
    )

    assert check_status_distribute(response, "200")
    if "data" in response:
        context.data["users"][user_profile_identifier][
            user_questionnaire_identifier
        ] = response["data"]


@then("I request to get user questionnaire ([^']*) for user ([^']*)")
def step_impl(
    context, user_questionnaire_identifier: str, user_profile_identifier: str
):
    request = context.request
    user_questionnaire_id = context.data["users"][user_profile_identifier][
        user_questionnaire_identifier
    ]["userQuestionnaireId"]
    user_profile_id = context.data["users"].get(user_profile_identifier)[
        "userProfileId"
    ]

    response = request.hugosave_get_request(
        headers=ah.get_user_header(user_profile_id, context),
        path=ah.questionnaire_urls["update"].replace(
            "user-questionnaire-id", user_questionnaire_id
        ),
    )

    assert check_status_distribute(response, "200")


@then(
    "I request to update and verify user questionnaire answer ([^']*) for user ([^']*) - questionnaire ([^']*)"
)
def step_impl(
    context,
    user_questionnaire_identifier: str,
    user_profile_identifier: str,
    questionnaire_name: str,
):
    request = context.request
    user_questionnaire_id = context.data["users"][user_profile_identifier][
        user_questionnaire_identifier
    ]["userQuestionnaireId"]
    user_profile_id = context.data["users"].get(user_profile_identifier)[
        "userProfileId"
    ]
    # get questionnaire and user-questionnaire
    get_user_questionnaire_response = request.hugosave_get_request(
        headers=ah.get_user_header(user_profile_id, context),
        path=ah.questionnaire_urls["update"].replace(
            "user-questionnaire-id", user_questionnaire_id
        ),
    )

    assert check_status_distribute(get_user_questionnaire_response, "200")
    user_questionnaire_dto = get_user_questionnaire_response["data"]

    get_questionnaire_response = request.hugosave_get_request(
        path=ah.questionnaire_urls["details"].replace(
            "questionnaire-name", questionnaire_name
        ),
        headers=ah.get_user_header("HUGOSAVE_SG", context),
    )
    assert check_status_distribute(get_user_questionnaire_response, "200")
    questionnaire_dto = get_questionnaire_response["data"]

    # update answer, check if client answer then answer
    score = 0
    for question_id, option_id in user_questionnaire_dto["questions"].items():
        question = questionnaire_dto["questions"].get(question_id)
        if question["questionMode"] == "CLIENT_ANSWER":
            random_option_id = random.randrange(1, len(question["options"]))
            option = question["options"][random_option_id]
            score = round(score + option["score"], 2)
            user_questionnaire_dto["questions"][question_id] = option["optionId"]
            # call app to update
            response = request.hugosave_put_request(
                headers=ah.get_user_header(user_profile_id, context),
                path=ah.questionnaire_urls["update"].replace(
                    "user-questionnaire-id", user_questionnaire_id
                ),
                data=user_questionnaire_dto,
            )
            assert check_status_distribute(response, "200")
        else:
            score = round(score + question["options"][int(option_id) - 1]["score"], 2)

    # store above dto
    user_questionnaire_dto["score"] = round(
        score / len(user_questionnaire_dto["questions"]), 2
    )
    context.data["users"][user_profile_identifier][
        user_questionnaire_identifier
    ] = user_questionnaire_dto


@then("I request to submit user questionnaire ([^']*) for user ([^']*)")
def step_impl(
    context, user_questionnaire_identifier: str, user_profile_identifier: str
):
    request = context.request
    user_questionnaire_id = context.data["users"][user_profile_identifier][
        user_questionnaire_identifier
    ]["userQuestionnaireId"]
    user_profile_id = context.data["users"].get(user_profile_identifier)[
        "userProfileId"
    ]
    response = request.hugosave_post_request(
        headers=ah.get_user_header(user_profile_id, context),
        path=ah.questionnaire_urls["submit"].replace(
            "user-questionnaire-id", user_questionnaire_id
        ),
    )
    assert check_status_distribute(response, "200")


@then("I verify score ([^']*) for user ([^']*)")
def step_impl(
    context, user_questionnaire_identifier: str, user_profile_identifier: str
):
    request = context.request
    user_questionnaire_id = context.data["users"][user_profile_identifier][
        user_questionnaire_identifier
    ]["userQuestionnaireId"]
    user_profile_id = context.data["users"].get(user_profile_identifier)[
        "userProfileId"
    ]
    # get questionnaire and user-questionnaire
    get_user_questionnaire_response = request.hugosave_get_request(
        headers=ah.get_user_header(user_profile_id, context),
        path=ah.questionnaire_urls["update"].replace(
            "user-questionnaire-id", user_questionnaire_id
        ),
    )

    assert check_status_distribute(get_user_questionnaire_response, "200")
    user_questionnaire_dto = get_user_questionnaire_response["data"]
    stored_user_questionnaire_dto = context.data["users"][user_profile_identifier][
        user_questionnaire_identifier
    ]

    assert (
        user_questionnaire_dto["score"] == stored_user_questionnaire_dto["score"]
    ), f"Score mismatch. Expected : {stored_user_questionnaire_dto['score']}.\nReceived : {user_questionnaire_dto['score']}"

    assert user_questionnaire_dto["submitTs"]
