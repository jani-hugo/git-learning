import decimal

from hugoutils.utilities.dataclass_util import DataClassParser

from test.api.aggregate.cash.cash_dataclass import (
    AccountDTO,
    AttachCardRequestDTO,
    CreateCustomerProfileAccountDTO,
    CreateEndCustomerProfileAccountDTO,
    CreatePlatformAccountDTO,
    UpdateAccountDTO,
)
from behave import *
from retry import retry
import test.api.aggregate.cash.helper as cash_helper

use_step_matcher("re")


@Step(
    "I create account for CustomerProfile with id ([^']*) with product id as ([^']*) with bank "
    "account type as ([^']*) with provider ([^']*) and expect the header status ([^']*)"
)
def create_customer_profile_bank_account(
    context,
    customer_profile_identifier: str,
    product_id_identifier: str,
    account_type: str,
    provider_name: str,
    status_code: str,
):
    request = context.request
    cash_helper.__validate_provider(provider_name)

    cust_profile_bank_acc_dto = DataClassParser.parse_row(
        context.table.rows[0], data_class=CreateCustomerProfileAccountDTO
    )

    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id
    cust_profile_bank_acc_dto.customer_profile_id = customer_profile_id

    cust_profile_bank_acc_dto.provider_id = cash_helper.__get_provider_id(
        context=context,
        provider_name=provider_name,
        customer_profile_id=customer_profile_id,
    )

    cust_profile_bank_acc_dto.account_type_id = cash_helper.__get_corporate_account_type_id(
        context=context,
        provider_id=cust_profile_bank_acc_dto.provider_id,
        account_type=account_type,
        customer_profile_id=customer_profile_id,
    )

    cust_profile_bank_acc_dto.product_id = context.data[product_id_identifier]

    assert context.data[cust_profile_bank_acc_dto.product_id].profile_type == "CUSTOMER", (
        f"Expect profile_type: CUSTOMER\n"
        f"Actual status_code: {context.data[cust_profile_bank_acc_dto.product_id].profile_type}"
    )

    response = request.hugoserve_post_request(
        path="/cash/v1/account/customer-profile",
        data=cust_profile_bank_acc_dto.get_dict(),
        headers=cash_helper.__get_default_cash_headers(customer_profile_id),
    )

    assert response["headers"]["status_code"] == status_code, (
        f"Expect status_code: {status_code}\n"
        f"Actual status_code: {response['headers']['status_code']}"
    )

    if status_code == "200":
        assert "account_id" in response["data"], (
            f"\nExpected data object contains account_id" f"\nActual data: {response['data']}"
        )

        # Change the status to "ACCOUNT_PENDING" after changing the apis implementation to async
        # in Banking
        actual_onboard_status = response["data"]["account_status"]
        assert actual_onboard_status == "ACCOUNT_CREATED", (
            f"\nExpect data.account_status: ACCOUNT_PENDING"
            f"\nActual data.account_status: {response['data']['account_status']}, "
            f"data: {response['data']}"
        )

        cust_profile_bank_acc_dto.account_id = response["data"]["account_id"]
        context.data[cust_profile_bank_acc_dto.identifier] = cust_profile_bank_acc_dto


@Then(
    "I wait until max time to verify the bank account ([^']*) status as ([^']*) with provider (["
    "^']*) for customerProfileId ([^']*)"
)
def wait_to_create_bank_account(
    context,
    identifier: str,
    onboard_status: str,
    provider_name: str,
    customer_profile_identifier: str,
):
    request = context.request
    cash_helper.__validate_provider(provider_name)
    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id
    bank_account_id = context.data[identifier].account_id

    @retry(
        AssertionError,
        tries=5,
        delay=20,
        logger=None,
    )
    def retry_for_creation_status():
        response = request.hugoserve_get_request(
            f"/cash/v1/account/{bank_account_id}/details",
            headers=cash_helper.__get_default_cash_headers(customer_profile_id),
        )
        assert response["headers"]["status_code"] == "200", (
            f"[TraceId: {response['headers']['trace_id']}]\n"
            f"Expect status_code: 200\n"
            f"Actual status_code: {response['headers']['status_code']}"
        )
        assert response["data"]["account_status"] == onboard_status, print(
            f"\nExpect data.account_status: {onboard_status}"
            f"\nActual data.account_status: {response['data']['account_status']}, "
            f"data: {response['data']}"
        )

    retry_for_creation_status()


@Then(
    "I verify CustomerProfile with id ([^']*) has bank account ([^']*) of account type ([^']*) "
    "exists with provider ([^']*) with values"
)
def verify_bank_account_exist(
    context,
    customer_profile_identifier: str,
    identifier: str,
    account_type: str,
    provider_name: str,
):
    request = context.request

    expected_bank_acc_dto = DataClassParser.parse_row(
        context.table.rows[0], data_class=AccountDTO
    )
    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id
    expected_bank_acc_dto.customer_profile_id = customer_profile_id
    expected_bank_acc_dto.provider_id = cash_helper.__get_provider_id(
        context=context,
        provider_name=provider_name,
        customer_profile_id=customer_profile_id,
    )
    expected_bank_acc_dto.account_type_id = cash_helper.__get_corporate_account_type_id(
        context=context,
        provider_id=expected_bank_acc_dto.provider_id,
        account_type=account_type,
        customer_profile_id=customer_profile_id,
    )

    bank_account_id = context.data[identifier].account_id

    response = request.hugoserve_get_request(
        f"/cash/v1/account/{bank_account_id}/details",
        headers=cash_helper.__get_default_cash_headers(customer_profile_id),
    )

    assert response["headers"]["status_code"] == "200", (
        f"[TraceId: {response['headers']['trace_id']}]\n"
        f"Expect status_code: 200\n"
        f"Actual status_code: {response['headers']['status_code']}"
    )

    actual_bank_acc_dto = DataClassParser.dict_to_object(
        response["data"], data_class=AccountDTO
    )

    sanitized_expected = AccountDTO.sanitize_bank_account_dto(expected_bank_acc_dto)
    sanitized_actual = AccountDTO.sanitize_bank_account_dto(actual_bank_acc_dto)

    assert sanitized_expected == sanitized_actual, (
        f"\nExpect bank_account_dto: {sanitized_expected}"
        f"\nActual bank_account_dto: {sanitized_actual}"
    )

    context.data[identifier] = actual_bank_acc_dto


@Given(
    "I create account for EndCustomerProfile with id ([^']*) for CustomerProfile ([^']*) with "
    "product id ([^']*) with bank account type as ([^']*) with provider ([^']*) and expect the "
    "header status ([^']*)"
)
def create_end_customer_profile_bank_account(
    context,
    end_customer_profile_identifier: str,
    customer_profile_identifier: str,
    product_id_identifier: str,
    account_type: str,
    provider_name: str,
    status_code: str,
):
    request = context.request
    cash_helper.__validate_provider(provider_name)

    end_cust_profile_bank_acc_dto = DataClassParser.parse_row(
        context.table.rows[0], data_class=CreateEndCustomerProfileAccountDTO
    )

    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id
    end_cust_profile_bank_acc_dto.end_customer_profile_id = context.data[
        end_customer_profile_identifier
    ].end_customer_profile_id
    end_cust_profile_bank_acc_dto.customer_profile_id = customer_profile_id
    end_cust_profile_bank_acc_dto.provider_id = cash_helper.__get_provider_id(
        context=context,
        provider_name=provider_name,
        customer_profile_id=customer_profile_id,
    )

    end_cust_profile_bank_acc_dto.account_type_id = cash_helper.__get_account_type_id(
        context=context,
        provider_id=end_cust_profile_bank_acc_dto.provider_id,
        account_type=account_type,
        customer_profile_id=customer_profile_id,
    )

    end_cust_profile_bank_acc_dto.product_id = context.data[product_id_identifier]

    assert (
        context.data[end_cust_profile_bank_acc_dto.product_id].profile_type == "END_CUSTOMER"
    ), (
        f"Expect profile_type: END_CUSTOMER\n"
        f"Actual status_code: {context.data[end_cust_profile_bank_acc_dto.product_id].profile_type}"
    )

    data = end_cust_profile_bank_acc_dto.get_dict()
    response = request.hugoserve_post_request(
        path="/cash/v1/account/end-customer-profile",
        data=data,
        headers=cash_helper.__get_default_cash_headers(
            customer_profile_id, None, None, data["on_behalf_of"]
        ),
    )

    assert response["headers"]["status_code"] == status_code, (
        f"[TraceId: {response['headers']['trace_id']}]\n"
        f"Expect status_code: {status_code}\n"
        f"Actual status_code: {response['headers']['status_code']}"
    )

    if status_code == "200":
        assert (
            "data" in response
        ), f"\nExpected non empty data object, found empty. Response:{response}"
        assert "account_id" in response["data"], (
            f"\nExpected data object contains account_id" f"\nActual data: {response['data']}"
        )

        # Change the status to "ACCOUNT_PENDING" after changing the apis implementation to async
        # in Banking
        actual_onboard_status = response["data"]["account_status"]
        assert actual_onboard_status == "ACCOUNT_CREATED", (
            f"\nExpect data.account_status: ACCOUNT_CREATED"
            f"\nActual data.account_status: {response['data']['account_status']}, "
            f"data: {response['data']}"
        )

        end_cust_profile_bank_acc_dto.account_id = response["data"]["account_id"]
        context.data[end_cust_profile_bank_acc_dto.identifier] = end_cust_profile_bank_acc_dto


@Then(
    "I verify EndCustomerProfile with id ([^']*) for CustomerProfile ([^']*) has bank account (["
    "^']*) of account type ([^']*) exists with provider ([^']*) with values"
)
def verify_end_customer_profile_bank_account_exist(
    context,
    end_customer_profile_identifier: str,
    customer_profile_identifier: str,
    identifier: str,
    account_type: str,
    provider_name: str,
):
    request = context.request
    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id
    expected_bank_acc_dto = DataClassParser.parse_row(
        context.table.rows[0], data_class=AccountDTO
    )
    expected_bank_acc_dto.profile_id = context.data[
        end_customer_profile_identifier
    ].end_customer_profile_id
    expected_bank_acc_dto.provider_id = cash_helper.__get_provider_id(
        context=context, provider_name=provider_name, customer_profile_id=""
    )
    expected_bank_acc_dto.account_type_id = cash_helper.__get_account_type_id(
        context=context,
        provider_id=expected_bank_acc_dto.provider_id,
        account_type=account_type,
        customer_profile_id="",
    )

    identifier = expected_bank_acc_dto.identifier
    bank_account_id = context.data[identifier].account_id

    response = request.hugoserve_get_request(
        f"/cash/v1/account/{bank_account_id}/details",
        headers=cash_helper.__get_default_cash_headers(customer_profile_id),
    )
    assert response["headers"]["status_code"] == "200", (
        f"[TraceId: {response['headers']['trace_id']}]\n"
        f"Expect status_code: 200\n"
        f"Actual status_code: {response['headers']['status_code']}"
    )

    actual_bank_acc_dto = DataClassParser.dict_to_object(
        response["data"], data_class=AccountDTO
    )

    sanitized_expected = AccountDTO.sanitize_bank_account_dto(expected_bank_acc_dto)
    sanitized_actual = AccountDTO.sanitize_bank_account_dto(actual_bank_acc_dto)

    if (sanitized_expected.on_behalf_of) is None or len(sanitized_expected.on_behalf_of) == 0:
        sanitized_expected.on_behalf_of = "CUSTOMER"
    assert sanitized_expected == sanitized_actual, (
        f"\nExpect bank_account_dto: {sanitized_expected}"
        f"\nActual bank_account_dto: {sanitized_actual}"
    )

    context.data[identifier] = actual_bank_acc_dto


@retry(
    AssertionError,
    tries=cash_helper.cash_providers_config["DBS Bank Ltd"]["max_wait_time"] / 5,
    delay=5,
    logger=None,
)
@Then(
    "I verify for bank account ([^']*) total balance is ([^']*) and available balance is ([^']*) "
    "for customerProfileId ([^']*)"
)
def verify_bank_account_balance(
    context,
    identifier,
    expected_total_balance,
    expected_available_balance,
    customer_profile_identifier,
):
    request = context.request

    expected_total_balance = float(expected_total_balance)
    expected_available_balance = float(expected_available_balance)
    bank_account_id = context.data[identifier].account_id
    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id

    @retry(
        AssertionError,
        tries=cash_helper.cash_providers_config["DBS Bank Ltd"]["max_wait_time"] / 5,
        delay=5,
        logger=None,
    )
    def retry_for_bank_account_balance():
        response = request.hugoserve_get_request(
            path=f"/cash/v1/account/{bank_account_id}/balance",
            headers=cash_helper.__get_default_cash_headers(customer_profile_id),
        )
        actual_total_balance = response["data"]["total_balance"]
        actual_available_balance = response["data"]["available_balance"]

        assert expected_total_balance == actual_total_balance, (
            f"\nExpect total_balance: {expected_total_balance}"
            f"\nActual total_balance: {actual_total_balance}"
        )
        assert expected_available_balance == actual_available_balance, (
            f"\nExpect available_balance: {expected_available_balance}"
            f"\nActual available_balance: {actual_available_balance}"
        )

    retry_for_bank_account_balance()


@Then(
    "I provide the Bank Account Id ([^']*) for the customer profile id ([^']*) with the negative "
    "balance allowed as ([^']*) and with the trust as ([^']*) and expect the status code ([^']*)"
)
def attach_card(
    context,
    account_id: str,
    customer_profile_id: str,
    is_overdraft_allowed: bool,
    to_be_in_trust: bool,
    status_code: str,
):
    request = context.request

    attach_card_dto = DataClassParser.parse_row(
        context.table.rows[0], data_class=AttachCardRequestDTO
    )
    attach_card_dto.account_id = context.data[attach_card_dto.account_id].account_id
    attach_card_dto.is_overdraft_allowed = is_overdraft_allowed
    attach_card_dto.to_be_in_trust = to_be_in_trust
    customer_profile_id = context.data[attach_card_dto.customer_profile_id].customer_profile_id
    response = request.hugoserve_post_request(
        path="/cash/v1/platform/account/" + attach_card_dto.account_id + "/attach-card",
        data=attach_card_dto.get_dict(),
        headers=cash_helper.__get_default_cash_headers(customer_profile_id),
    )

    assert response["headers"]["status_code"] == status_code, (
        f"[TraceId: {response['headers']['trace_id']}]\n"
        f"Expect status_code: {status_code}\n"
        f"Actual status_code: {response['headers']['status_code']}"
    )


@Then(
    "I update an account with Id ([^']*) and negative balance allowed set to ([^']*) and expect a "
    "status code ([^']*)"
)
def update_bank_account(context, account_id: str, is_overdraft_allowed: bool, status_code: str):
    request = context.request

    bank_acc_dto = DataClassParser.parse_row(context.table.rows[0], data_class=UpdateAccountDTO)
    bank_acc_dto.account_id = context.data[bank_acc_dto.account_id].account_id

    customer_profile_id = context.data[bank_acc_dto.customer_profile_id].customer_profile_id

    response = request.hugoserve_put_request(
        path=f"/cash/v1/account/" + bank_acc_dto.account_id,
        data=bank_acc_dto.get_dict(),
        headers=cash_helper.__get_default_cash_headers(customer_profile_id),
    )

    assert response["headers"]["status_code"] == status_code, (
        f"[TraceId: {response['headers']['trace_id']}]\n"
        f"Expect status_code: {status_code}\n"
        f"Actual status_code: {response['headers']['status_code']}"
    )


@Given(
    "I create Platform bank account with id ([^']*) with profile type as ([^']*) onBehalfOf (["
    "^']*) and expect the header status ([^']*)"
)
def create_platform_bank_account(
    context,
    customer_profile_identifier: str,
    profile_type: str,
    created_by: str,
    status_code: str,
):
    request = context.request

    platform_bank_account_dto = DataClassParser.parse_row(
        context.table.rows[0], data_class=CreatePlatformAccountDTO
    )
    platform_bank_account_dto.profile_id = context.data[
        customer_profile_identifier
    ].customer_profile_id

    origin = 'CUSTOMER'
    if created_by == 'CARD_SERVICE':
        origin = 'CARD'
    elif created_by == 'INVESTMENT_SERVICE':
        origin = 'INVESTMENT'

    request.hugoserve_post_request(
        path="/cash/v1/internal/customer-profile",
        data={"customer_profile_id": platform_bank_account_dto.profile_id},
        headers=cash_helper.__get_default_cash_headers("", "", "", origin),
    )

    response = request.hugoserve_post_request(
        path="/cash/v1/platform/account/" + platform_bank_account_dto.profile_id,
        data=platform_bank_account_dto.get_dict(),
        headers=cash_helper.__get_default_cash_headers("", "", "", origin),
    )

    assert response["headers"]["status_code"] == status_code, (
        f"[TraceId: {response['headers']['trace_id']}]\n"
        f"Expect status_code: {status_code}\n"
        f"Actual status_code: {response['headers']['status_code']}"
    )

    if status_code == "200":
        assert (
            "data" in response
        ), f"\nExpected non empty data object, found empty. Response:{response}"
        assert "account_id" in response["data"], (
            f"\nExpected data object contains account_id" f"\nActual data: {response['data']}"
        )
        assert response["data"]["account_status"] == "ACCOUNT_FAILED", (
            f"\nExpect data.account_status: ACCOUNT_PENDING"
            f"\nActual data.account_status: {response['data']['account_status']}, "
            f"data: {response['data']}"
        )

        platform_bank_account_dto.account_id = response["data"]["account_id"]
        context.data[platform_bank_account_dto.identifier] = platform_bank_account_dto


@Then(
    "I wait until max time to verify bank account ([^']*) total balance is ([^']*) and available "
    "balance is ([^']*) for customerProfileId ([^']*)"
)
def wait_and_verify_bank_account_balance(
    context,
    identifier,
    expected_total_balance,
    expected_available_balance,
    customer_profile_identifier,
):
    request = context.request

    expected_total_balance = float(expected_total_balance)
    expected_available_balance = float(expected_available_balance)
    bank_account_id = context.data[identifier].account_id
    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id

    @retry(
        AssertionError,
        tries=cash_helper.cash_providers_config["DBS Bank Ltd"]["max_wait_time"] / 5,
        delay=5,
        logger=None,
    )
    def retry_for_bank_account_balance():
        response = request.hugoserve_get_request(
            path=f"/cash/v1/account/{bank_account_id}/balance",
            headers=cash_helper.__get_default_cash_headers(customer_profile_id),
        )
        assert (
            "data" in response
        ), f"\nExpected non empty data object, found empty. Response:{response}"

        actual_total_balance = response["data"]["total_balance"]
        actual_available_balance = response["data"]["available_balance"]

        assert expected_total_balance == actual_total_balance, (
            f"\nExpect total_balance: {expected_total_balance}"
            f"\nActual total_balance: {actual_total_balance}"
        )
        assert expected_available_balance == actual_available_balance, (
            f"\nExpect available_balance: {expected_available_balance}"
            f"\nActual available_balance: {actual_available_balance}"
        )

    retry_for_bank_account_balance()


@Then(
    "I wait until max time to verify bank account ([^']*) with an available balance of ([^']*) "
    "and total balance of ([^']*) for customerProfileId ([^']*)"
)
def verify_bank_account_balance(
    context,
    identifier,
    expected_available_balance: decimal,
    expected_total_balance: decimal,
    customer_profile_identifier: str,
):
    request = context.request

    bank_account_id = context.data[identifier].account_id
    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id

    @retry(
        AssertionError,
        tries=cash_helper.cash_providers_config["DBS Bank Ltd"]["max_wait_time"] / 20,
        delay=5,
        logger=None,
    )
    def retry_for_bank_account_status():
        response = request.hugoserve_get_request(
            path=f"/cash/v1/account/{bank_account_id}/balance",
            headers=cash_helper.__get_default_cash_headers(customer_profile_id),
        )
        assert (
            "data" in response
        ), f"\nExpected non empty data object, found empty. Response:{response}"

        actual_total_balance = response["data"]["total_balance"]
        actual_available_balance = response["data"]["available_balance"]

        assert float(expected_total_balance) == actual_total_balance, (
            f"\nExpect total_balance: {expected_total_balance}"
            f"\nActual total_balance: {actual_total_balance}"
        )
        assert float(expected_available_balance) == actual_available_balance, (
            f"\nExpect available_balance: {expected_available_balance}"
            f"\nActual available_balance: {actual_available_balance}"
        )

    retry_for_bank_account_status()


@Then(
    "I wait until max time to verify bank account ([^']*) with lent recovery available balance of "
    "([^']*) and total balance of ([^']*) for customerProfileId ([^']*)"
)
def verify_bank_account_balance(
    context,
    identifier,
    expected_available_balance: decimal,
    expected_total_balance: decimal,
    customer_profile_identifier: str,
):
    request = context.request

    bank_account_id = context.data[identifier].account_id
    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id

    @retry(
        AssertionError,
        tries=cash_helper.cash_providers_config["DBS Bank Ltd"]["max_wait_time"] / 5,
        delay=5,
        logger=None,
    )
    def retry_for_bank_account_status():
        response = request.hugoserve_get_request(
            path=f"/cash/v1/account/{bank_account_id}/balance",
            headers=cash_helper.__get_default_cash_headers(customer_profile_id),
        )
        assert (
            "data" in response
        ), f"\nExpected non empty data object, found empty. Response:{response}"

        actual_total_balance = response["data"]["total_balance"]
        actual_available_balance = response["data"]["available_balance"]

        assert float(expected_total_balance) == actual_total_balance, (
            f"\nExpect total_balance: {expected_total_balance}"
            f"\nActual total_balance: {actual_total_balance}"
        )
        assert float(expected_available_balance) == actual_available_balance, (
            f"\nExpect available_balance: {expected_available_balance}"
            f"\nActual available_balance: {actual_available_balance}"
        )

    retry_for_bank_account_status()
