from behave import *
import tests.api.distribute.app.app_helper as ah

use_step_matcher("re")


@Step(
    "I add a random note to the latest intent of user ([^']*) and check if note is saved"
)
def create_note(context, user):
    request = context.request
    user_prof_id = ah.get_user_prof_id(context, user)

    response = request.hugosave_get_request(
        ah.intent_urls["list_intents_for_account"].replace("account-type", "cash"),
        headers=ah.get_user_header(user_prof_id, context),
    )

    intent_id = response["data"]["intentViews"][0]["intentId"]
    note_text = ah.get_rand_number(10)

    # create and check
    response = request.hugosave_post_request(
        ah.note_urls["root"],
        data={"intent_id": intent_id, "note": note_text},
        headers=ah.get_user_header(user_prof_id, context),
    )

    response = request.hugosave_get_request(
        ah.note_urls["get_note"].replace("intent_id", intent_id),
        headers=ah.get_user_header(user_prof_id, context),
    )

    assert response["data"]["note"] == note_text

    # update and check
    note_text = ah.get_rand_number(10)
    response = request.hugosave_put_request(
        ah.note_urls["root"],
        data={"intent_id": intent_id, "note": note_text},
        headers=ah.get_user_header(user_prof_id, context),
    )

    response = request.hugosave_get_request(
        ah.note_urls["get_note"].replace("intent_id", intent_id),
        headers=ah.get_user_header(user_prof_id, context),
    )

    assert response["data"]["note"] == note_text
