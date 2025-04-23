from behave import *

from tests.api.aggregate.payment import helper as payment_helper

use_step_matcher("re")


@Then(
    "I retrieve providers supporting for region ([^']*) from ([^']*) and expect the header status ([^']*) and fetch provider ([^']*)"
)
def fetch_providers_by_region(
    context, region: str, request_origin: str, status_code: str, provider_id: str
):
    provider_list = context.request.hugoserve_get_request(
        path="/payment/v1/providers",
        params={"region": region},
        headers=payment_helper.__get_default_payment_headers(
            context.data["config_data"]["customer_profile_id"], request_origin
        ),
    )["data"]["providers"]

    for provider in provider_list:
        if provider["provider_id"] == provider_id:
            assert f"\nProvider Details: {provider}"
        else:
            assert f"\nExpected provider not found in region: {region}"


@Then(
    "I retrieve transaction modes supported by provider ([^']*) from ([^']*) and expect the header status ([^']*) and check if txn mode ([^']*) supported by provider"
)
def fetch_txn_modes_by_provider(
    context, provider_id: str, request_origin: str, status_code: str, txn_mode: str
):
    txn_mode_list = context.request.hugoserve_get_request(
        path=f"/payment/v1/providers/{provider_id}/transaction-modes",
        headers=payment_helper.__get_default_payment_headers(
            context.data["config_data"]["customer_profile_id"], request_origin
        ),
    )["data"]["txn_mode"]

    for actual_txn_mode in txn_mode_list:
        if actual_txn_mode == txn_mode:
            assert f"\nTxn Mode: {txn_mode} supported by provider: {provider_id}"
        else:
            assert f"\nExpected txn mode: {txn_mode} not supported by provider: {provider_id}"
