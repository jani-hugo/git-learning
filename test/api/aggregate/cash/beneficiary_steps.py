from hugoutils.utilities.dataclass_util import DataClassParser

from test.api.aggregate.cash import helper
from test.api.aggregate.cash.cash_dataclass import (
    BeneficiaryDataTable,
    BeneficiaryDataTableWithBankAccountDetails,
    BeneficiaryRequestDTO,
    BeneficiaryRequestDTOs,
)
from behave import *
from retry import retry

use_step_matcher("re")


@When(
    "I add bank account ([^']*) as beneficiary to bank account ([^']*) of CustomerProfile ([^']*) for provider ([^']*) and expect status ([^']*)"
)
def create_internal_beneficiary(
    context,
    beneficiary_bank_account_identifier: str,
    self_bank_account_identifier: str,
    customer_profile_identifier: str,
    provider_name: str,
    status_code: str,
):
    request = context.request
    beneficiary_datatable_details = DataClassParser.parse_row(
        context.table.rows[0], BeneficiaryDataTable
    )
    if (
        beneficiary_datatable_details.overdraft_funding_account_id is not None
        and beneficiary_datatable_details.overdraft_funding_account_id != ""
    ):
        beneficiary_datatable_details.overdraft_funding_account_id = context.data[
            beneficiary_datatable_details.overdraft_funding_account_id
        ].account_id
    helper.__validate_provider(provider_name)
    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id

    beneficiary_account_id = context.data[beneficiary_bank_account_identifier].account_id
    self_bank_account_id = context.data[self_bank_account_identifier].account_id

    beneficiary_account = helper.__fetch_bank_account(
        customer_profile_id, context, beneficiary_account_id
    )
    beneficiary_request_dto = helper.__build_beneficiary_request_dto_for_internal_account(
        beneficiary_datatable_details, beneficiary_account, self_bank_account_id
    )

    create_beneficiary(
        beneficiary_datatable_details,
        beneficiary_request_dto,
        context,
        customer_profile_id,
        request,
        status_code,
    )


@Then(
    "I wait until max time to verify beneficiary ([^']*) create status as ([^']*) with provider ([^']*) for customerProfileId ([^']*)"
)
def wait_to_create_beneficiary(
    context,
    identifier: str,
    beneficiary_create_status: str,
    provider_name: str,
    customer_profile_identifier: str,
):
    request = context.request
    helper.__validate_provider(provider_name)
    if context.data["status_code"] == "200":
        beneficiary_id = context.data[identifier].beneficiary_id
        customer_profile_id = context.data[customer_profile_identifier].customer_profile_id

        @retry(
            AssertionError,
            tries=helper.cash_providers_config[provider_name]["max_wait_time"] / 5,
            delay=15,
            logger=None,
        )
        def retry_for_beneficiary_create_status():
            response = request.hugoserve_get_request(
                path=f"/cash/v1/beneficiary/{beneficiary_id}",
                headers=helper.__get_default_cash_headers(customer_profile_id),
            )
            assert response["data"]["beneficiary_status"] == beneficiary_create_status, print(
                f"\nExpect data.beneficiary_status: {beneficiary_create_status}"
                f"\nActual data.beneficiary_status: {response['data']['beneficiary_status']}, data: {response['data']}"
            )

        retry_for_beneficiary_create_status()


@Then(
    "I verify bank account ([^']*) has bank account ([^']*) as beneficiary on provider ([^']*) with values for customerProfileId ([^']*)"
)
def verify_internal_beneficiary(
    context,
    self_bank_account_identifier: str,
    beneficiary_bank_account_identifier: str,
    provider_name: str,
    customer_profile_identifier: str,
):
    request = context.request
    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id
    beneficiary_datatable_details = DataClassParser.parse_row(
        context.table.rows[0], BeneficiaryDataTable
    )
    helper.__validate_provider(provider_name)

    beneficiary_account_id = context.data[beneficiary_bank_account_identifier].account_id
    self_bank_account_id = context.data[self_bank_account_identifier].account_id

    beneficiary_account = helper.__fetch_bank_account(
        customer_profile_id, context, beneficiary_account_id
    )
    expected_beneficiary = helper.__build_beneficiary_request_dto_for_internal_account(
        beneficiary_datatable_details, beneficiary_account, self_bank_account_id
    )
    verify_beneficiary(
        customer_profile_id,
        beneficiary_datatable_details,
        context,
        expected_beneficiary,
        request,
    )


def verify_beneficiary(
    customer_profile_id,
    beneficiary_datatable_details,
    context,
    expected_beneficiary,
    request,
):
    if context.data["status_code"] == "200":
        beneficiary_id = context.data[beneficiary_datatable_details.identifier].beneficiary_id
        # Sanitizing as below information cannot be deduced or is present in datatable or response
        expected_beneficiary.beneficiary_id = beneficiary_id

        response = request.hugoserve_get_request(
            f"/cash/v1/beneficiary/{beneficiary_id}",
            headers=helper.__get_default_cash_headers(customer_profile_id),
        )
        actual_beneficiary = DataClassParser.dict_to_object(
            response["data"], BeneficiaryRequestDTO
        )

        assert expected_beneficiary == actual_beneficiary, (
            f"\nExpect beneficiary dto: {expected_beneficiary}"
            f"\nActual beneficiary dto: {actual_beneficiary}"
        )


@When(
    "I add External Bank Account as beneficiary to bank account ([^']*) of CustomerProfile ([^']*) for provider ([^']*) and expect status ([^']*)"
)
def create_external_beneficiary(
    context,
    bank_account: str,
    customer_profile_identifier: str,
    provider_name: str,
    status_code: str,
):
    request = context.request
    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id
    beneficiary_datatable_details = DataClassParser.parse_row(
        context.table.rows[0], BeneficiaryDataTableWithBankAccountDetails
    )
    if (
        beneficiary_datatable_details.overdraft_funding_account_id is not None
        and beneficiary_datatable_details.overdraft_funding_account_id != ""
    ):
        beneficiary_datatable_details.overdraft_funding_account_id = context.data[
            beneficiary_datatable_details.overdraft_funding_account_id
        ].account_id
    else:
        beneficiary_datatable_details.overdraft_funding_account_id = None
    helper.__validate_provider(provider_name)

    self_bank_account_id = context.data[bank_account].account_id

    beneficiary_request_dto = helper.__build_beneficiary_request_dto_for_external_account(
        beneficiary_datatable_details, self_bank_account_id
    )

    create_beneficiary(
        beneficiary_datatable_details,
        beneficiary_request_dto,
        context,
        customer_profile_id,
        request,
        status_code,
    )


@Then(
    "I verify hugoserve bank account ([^']*) has bank account External Bank Account as beneficiary with provider ([^']*) with values for customerProfileId ([^']*)"
)
def verify_external_beneficiary(
    context,
    self_bank_account_identifier: str,
    provider_name: str,
    customer_profile_identifier: str,
):
    request = context.request
    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id
    beneficiary_datatable_details = DataClassParser.parse_row(
        context.table.rows[0], BeneficiaryDataTableWithBankAccountDetails
    )
    helper.__validate_provider(provider_name)

    self_bank_account_id = context.data[self_bank_account_identifier].account_id

    expected_beneficiary = helper.__build_beneficiary_request_dto_for_external_account(
        beneficiary_datatable_details, self_bank_account_id
    )
    verify_beneficiary(
        customer_profile_id,
        beneficiary_datatable_details,
        context,
        expected_beneficiary,
        request,
    )


def create_beneficiary(
    beneficiary_datatable_details,
    beneficiary_request_dto,
    context,
    customer_profile_id,
    request,
    status_code,
):
    response = request.hugoserve_post_request(
        path=f"/cash/v1/beneficiary",
        data=beneficiary_request_dto.get_dict(),
        headers=helper.__get_default_cash_headers(customer_profile_id),
    )
    assert response["headers"]["status_code"] == status_code, (
        f"[TraceId: {response['headers']['trace_id']}]\n"
        f"Expect status_code: {status_code}\n"
        f"Actual status_code: {response['headers']['status_code']}"
    )
    context.data["status_code"] = response["headers"]["status_code"]
    if response["headers"]["status_code"] == "200":
        assert (
            "data" in response
        ), f"\nExpected non empty data object, found empty. Response:{response}"
        assert "beneficiary_id" in response["data"], (
            f"\nExpected data object contains beneficiary_id"
            f"\nActual data: {response['data']}"
        )
        beneficiary_request_dto.beneficiary_id = response["data"]["beneficiary_id"]
        context.data[beneficiary_datatable_details.identifier] = beneficiary_request_dto


@Then(
    "I verify hugoserve bank account ([^']*) has ([^']*) beneficiaries created with provider ([^']*) with values for customerProfileId ([^']*)"
)
def verify_beneficiaries_for_an_account(
    context,
    bank_account_id: str,
    number_of_beneficiaries: str,
    provider_name: str,
    customer_profile_identifier: str,
):
    request = context.request
    helper.__validate_provider(provider_name)
    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id

    self_bank_account_id = context.data[bank_account_id].account_id

    response = request.hugoserve_get_request(
        f"/cash/v1/account/{self_bank_account_id}/beneficiaries",
        headers=helper.__get_default_cash_headers(customer_profile_id),
    )
    beneficiaries_response = DataClassParser.dict_to_object(
        response["data"], BeneficiaryRequestDTOs
    )
    assert len(beneficiaries_response.beneficiaries) == int(number_of_beneficiaries)


@Given(
    "I add External Bank Account as beneficiary to hugoserve bank account ([^']*) of CustomerProfile ([^']*) for provider ([^']*) and expect status ([^']*)"
)
def create_beneficiary_with_invalid_account(
    context,
    self_bank_account_identifier: str,
    customer_profile_identifier: str,
    provider_name: str,
    status_code: str,
):
    request = context.request
    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id
    beneficiary_datatable_details = DataClassParser.parse_row(
        context.table.rows[0], BeneficiaryDataTableWithBankAccountDetails
    )
    helper.__validate_provider(provider_name)

    beneficiary_request_dto = helper.__build_beneficiary_request_dto_for_external_account(
        beneficiary_datatable_details, self_bank_account_identifier
    )

    create_beneficiary(
        beneficiary_datatable_details,
        beneficiary_request_dto,
        context,
        customer_profile_id,
        request,
        status_code,
    )
