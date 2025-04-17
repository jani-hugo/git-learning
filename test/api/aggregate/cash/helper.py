from typing import Optional
import random

from hugoutils.utilities.dataclass_util import DataClassParser

from test.api.aggregate.cash.cash_dataclass import (
    AccountDTO,
    BeneficiaryDataTable,
    BeneficiaryDataTableWithBankAccountDetails,
    BeneficiaryRequestDTO,
)

cash_providers_config = {
    "DBS Bank Ltd": {"supports_integration_test": True, "max_wait_time": 360},
    "Pseudo Provider": {"supports_integration_test": True, "max_wait_time": 360},
    "HugoBank Limited": {"supports_integration_test": True, "max_wait_time": 120},
}


def __get_provider_id(context, provider_name: str, customer_profile_id: str):
    provider_region = "SG"
    if provider_name == "HugoBank Limited":
        provider_region = "PK"

    provider_list = context.request.hugoserve_get_request(
        path="/cash/v1/provider",
        params={"region": provider_region},
        headers=__get_default_cash_headers(customer_profile_id),
    )["data"]["providers"]

    return next(
        provider["provider_id"]
        for provider in provider_list
        if provider["name"] == provider_name
    )


def __get_account_type_id(
    context, provider_id: str, account_type: str, customer_profile_id: str
):
    account_type_list = context.request.hugoserve_get_request(
        path=f"/cash/v1/provider/{provider_id}/account-types",
        headers=__get_default_cash_headers(customer_profile_id),
    )["data"]["account_types"]

    return next(
        each_account_type["account_type_id"]
        for each_account_type in account_type_list
        if each_account_type["account_type_name"] == account_type
    )


def __get_account_details(
        context,account_id: str, customer_profile_id: str
):
    account_details=context.request.hugoserve_get_request(
        path=f"/cash/v1/account/{account_id}/details",
        headers=__get_default_cash_headers(customer_profile_id),
    )["data"]["account_details"]

    return account_details



def __get_corporate_account_type_id(
    context, provider_id: str, account_type: str, customer_profile_id: str
):
    account_type_list = context.request.hugoserve_get_request(
        path=f"/cash/v1/provider/{provider_id}/account-types/corporate",
        headers=__get_default_cash_headers(customer_profile_id),
    )["data"]["account_types"]

    return next(
        each_account_type["account_type_id"]
        for each_account_type in account_type_list
        if each_account_type["account_type_name"] == account_type
    )


def __validate_provider(provider_name):
    if provider_name not in cash_providers_config:
        raise RuntimeError(f"No such provider found. Provider name: {provider_name}")

    if not cash_providers_config[provider_name]["supports_integration_test"]:
        raise RuntimeError(
            f"Integration tests are not supported for provider {provider_name}"
        )


def __get_default_cash_headers(
    customer_profile_id: str,
    idempotency_key: Optional[str] = None,
    customer_access_key: str = None,
    origin: Optional[str] = "CUSTOMER",
):
    if origin == "" or origin is None:
        origin = "CUSTOMER"

    if idempotency_key is None:
        idempotency_key = str(random.randint(1, 99999999))

    return {
        "x-customer-profile-id": customer_profile_id,
        "x-customer-access-key": customer_access_key,
        "x-idempotency-key": idempotency_key,
        "x-origin-id": origin,  # need to send this dynamically
    }


def __fetch_bank_account(customer_profile_id, context, bank_account_id: str):
    response = context.request.hugoserve_get_request(
        f"/cash/v1/account/{bank_account_id}/details",
        headers=__get_default_cash_headers(customer_profile_id),
    )
    return DataClassParser.dict_to_object(response["data"], AccountDTO)


def __build_beneficiary_request_dto_for_internal_account(
    beneficiary_datatable_details: BeneficiaryDataTable,
    beneficiary_account: AccountDTO,
    self_bank_account_id: str,
):
    return BeneficiaryRequestDTO(
        beneficiary_id=None,
        account_id=self_bank_account_id,
        beneficiary_name=beneficiary_datatable_details.beneficiary_name,
        beneficiary_account_details=beneficiary_account.account_details,
        address=beneficiary_datatable_details.address,
        beneficiary_email=beneficiary_datatable_details.beneficiary_email,
        is_hidden=beneficiary_datatable_details.is_hidden,
        metadata=beneficiary_datatable_details.metadata,
        is_overdraft_allowed=beneficiary_datatable_details.is_overdraft_allowed,
        overdraft_funding_account_id=beneficiary_datatable_details.overdraft_funding_account_id,
    )


def __build_beneficiary_request_dto_for_external_account(
    beneficiary_datatable_details: BeneficiaryDataTableWithBankAccountDetails,
    self_bank_account_id: str,
):
    return BeneficiaryRequestDTO(
        beneficiary_id=None,
        account_id=self_bank_account_id,
        beneficiary_name=beneficiary_datatable_details.beneficiary_name,
        beneficiary_account_details=beneficiary_datatable_details.beneficiary_account_details,
        address=beneficiary_datatable_details.address,
        beneficiary_email=beneficiary_datatable_details.beneficiary_email,
        is_hidden=beneficiary_datatable_details.is_hidden,
        metadata=beneficiary_datatable_details.metadata,
        overdraft_funding_account_id=beneficiary_datatable_details.overdraft_funding_account_id,
        is_overdraft_allowed=beneficiary_datatable_details.is_overdraft_allowed,
    )
