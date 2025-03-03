from aggregate.payment import helper as payment_helper
from behave import *
from common.utils import parse_rows_as_dict
from retry import retry

use_step_matcher("re")


@Step(
    "I onboard EndCustomerProfile ([^']*) of CustomerProfile ([^']*) on payment service on below providers from ([^']*) on behalf of ([^']*) and expect status ([^']*)"
)
def onboard_end_customer_profile_on_payment(
    context,
    end_customer_profile_identifier: str,
    customer_profile_identifier: str,
    request_origin: str,
    on_behalf_of: str,
    status_code: str,
):
    request = context.request
    end_customer_profile_id = context.data[
        end_customer_profile_identifier
    ].end_customer_profile_id
    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id
    provider_name_list = parse_rows_as_dict(context.table.rows)
    provider_name_id_list = []
    provider_id_list = []
    for each_provider in provider_name_list:
        provider_name = each_provider["provider_name"]
        payment_helper.__validate_provider(provider_name)
        provider_id = payment_helper.__get_payment_provider_id(
            context=context,
            provider_name=provider_name,
            customer_profile_id=customer_profile_id,
            request_origin=request_origin,
        )
        provider_id_list.append(provider_id)
        provider_name_id_list.append(
            {"provider_name": provider_name, "provider_id": provider_id}
        )

    response = request.hugoserve_post_request(
        path="/payment/v1/end-customer-profile",
        data={
            "end_customer_profile_id": end_customer_profile_id,
            "provider_id": provider_id_list,
            "on_behalf_of": on_behalf_of,
        },
        headers=payment_helper.__get_default_payment_headers(customer_profile_id, request_origin),
    )

    assert response["headers"]["status_code"] == status_code
    context.data["status_code"] = status_code

    if response["headers"]["status_code"] == "200":
        for each_provider_response in response["data"]["status"]:
            actual_onboard_status = each_provider_response["onboard_status"]
            assert actual_onboard_status == "ONBOARD_SUCCESS", (
                f"\nExpect data.onboard_status.status: ONBOARD_SUCCESS"
                f"\nActual data.onboard_status.status: {each_provider_response['onboard_status']}"
            )

        context.data[end_customer_profile_id] = provider_name_id_list

    elif response["headers"]["status_code"] == "PSM_1200":
        assert (
            response["headers"]["message"]
            == "EndCustomerProfile not found or Invalid EndCustomerProfile is passed"
        )


@Then(
    "I wait until max time to verify EndCustomerProfile ([^']*) of CustomerProfile ([^']*) from ([^']*) onboard status as ([^']*) onto Payment Service"
)
def wait_to_onboard_end_customer_profile(
    context,
    end_customer_profile_identifier: str,
    customer_profile_identifier: str,
    on_behalf_of: str,
    expected_onboard_status: str,
):
    request = context.request
    end_customer_profile_id = context.data[
        end_customer_profile_identifier
    ].end_customer_profile_id

    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id
    if context.data["status_code"] == "200":
        max_wait_time = 0
        for provider in context.data[end_customer_profile_id]:
            max_wait_time = max(
                payment_helper.payment_providers_config[provider["provider_name"]][
                    "max_wait_time"
                ],
                max_wait_time,
            )

        @retry(exceptions=AssertionError, tries=max_wait_time / 5, delay=5, logger=None)
        def retry_for_onboard_status():
            response = request.hugoserve_get_request(
                f"/payment/v1/end-customer-profile/{end_customer_profile_id}",
                headers=payment_helper.__get_default_payment_headers(
                    customer_profile_id, on_behalf_of
                ),
            )
            # Below assertion fails because payment aren't creating db entries right away and so api call returns
            # 'EndCustomerProfile not found.'
            assert "data" in response, print(
                f"\nExpect response.data but no data found: {response}"
            )
            for each_provider_onboard_status in response["data"]["status"]:
                actual_onboard_status = each_provider_onboard_status["onboard_status"]
                assert actual_onboard_status == expected_onboard_status, print(
                    f"\nExpect data.account_status: {expected_onboard_status}"
                    f"\nActual data.account_status: {each_provider_onboard_status['onboard_status']}"
                )

        retry_for_onboard_status()
