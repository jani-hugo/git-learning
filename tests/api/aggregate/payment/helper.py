from typing import Optional

from hugoutils.utilities.dataclass_util import DataClassParser

from tests.api.aggregate.payment.payment_dataclass import AccountDTO, MasterAccountDTO

payment_providers_config = {
    "DBS Bank Ltd": {"supports_integration_test": True, "max_wait_time": 120},
    "PAYSYS": {"supports_integration_test": True, "max_wait_time": 120},
}


def __get_payment_provider_id(
    context, provider_name: str, customer_profile_id: str, request_origin: str
):
    region = None
    if provider_name == "DBS Bank Ltd":
        region = "SG"
    elif provider_name == "PAYSYS":
        region = "PK"

    provider_list = context.request.hugoserve_get_request(
        path="/payment/v1/providers",
        params={"region": region},
        headers=__get_default_payment_headers(customer_profile_id, request_origin),
    )["data"]["providers"]

    for provider in provider_list:
        if provider["provider_name"] == provider_name:
            return provider["provider_id"]


def __validate_provider(provider_name):
    if provider_name not in payment_providers_config:
        raise RuntimeError(f"No such provider found. Provider name: {provider_name}")

    if not payment_providers_config[provider_name]["supports_integration_test"]:
        raise RuntimeError(
            f"Integration tests are not supported for provider {provider_name}"
        )


def __validate_payment_provider(provider_name):
    if provider_name not in payment_providers_config:
        assert True, f"No such provider found. Provider name: {provider_name}"


def __get_default_payment_headers(
    customer_profile_id: str = None,
    request_origin: str = None,
    idempotency_key: Optional[str] = None,
    customer_access_key: str = None,
):
    return {
        "x-customer-profile-id": customer_profile_id,
        "x-customer-access-key": customer_access_key,
        "x-idempotency-key": idempotency_key,
        "x-origin-id": request_origin,
    }


def __fetch_payment_account(customer_profile_id, context, account_id: str):
    response = context.request.hugoserve_get_request(
        f"/payment/v1/account/{account_id}",
        headers=__get_default_payment_headers(
            customer_profile_id, request_origin="CASH_SERVICE"
        ),
    )
    return DataClassParser.dict_to_object(response["data"], AccountDTO)


def __fetch_master_account(customer_profile_id, context, account_id: str):
    response = context.request.hugoserve_get_request(
        f"/payment/v1/account/master-account/{account_id}",
        headers=__get_default_payment_headers(
            customer_profile_id, request_origin="CASH_SERVICE"
        ),
    )
    return DataClassParser.dict_to_object(response["data"], MasterAccountDTO)
