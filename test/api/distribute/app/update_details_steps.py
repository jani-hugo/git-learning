from behave import *
import test.api.distribute.app.app_helper as ah
from test.util.common_util import check_status

use_step_matcher("re")


@Step("I update ([^']*) of user ([^']*) and check if updated correctly")
def update_user_details(context, fields: str, user_identifier: str):
    request = context.request
    user_profile_id = ah.get_user_prof_id(context, user_identifier)

    field_list = fields.split(',')
    data = ah.get_dummy_user_data(field_list)

    url = ah.user_profile_urls["root"]
    if "client_flags" in fields:
        url = ah.user_profile_urls["client_flags"]

    response = request.hugosave_put_request(
        url,
        data=data,
        headers=ah.get_user_header(user_profile_id, context),
    )

    passed = check_status(response, "200")
    if not passed:
        print(f"Expected: 200 received: {response['data']['status']}")
    else:
        updated_data = request.hugosave_get_request(
            ah.user_profile_urls["details"],
            headers=ah.get_user_header(user_profile_id, context),
        )['data']

        for field in field_list:
            updated_data[field] = data[field]

        context.data['users'][user_identifier] = updated_data
