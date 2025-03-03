import uuid

from hugoutils.utilities.dataclass_util import DataClassParser

from test.api.aggregate.payment.payment_dataclass import (
    AccountDTO,
    CreateCustomerProfileAccountDTO,
    CreateEndCustomerProfileAccountDTO,
)
from behave import *
from retry import retry
import test.api.aggregate.payment.helper as payment_helper

use_step_matcher("re")


@Step(
    "I create account for CustomerProfile with customerProfileId ([^']*) from ([^']*) on behalf of ([^']*) with provider ([^']*) and expect the header status ([^']*)"
)
def create_customer_profile_payment_account(
    context,
    customer_profile_identifier: str,
    request_origin: str,
    on_behalf_of: str,
    provider_name: str,
    status_code: str,
):
    request = context.request
    payment_helper.__validate_provider(provider_name)

    cust_profile_payment_acc_dto = DataClassParser.parse_row(
        context.table.rows[0], data_class=CreateCustomerProfileAccountDTO
    )

    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id
    cust_profile_payment_acc_dto.customer_profile_id = customer_profile_id

    cust_profile_payment_acc_dto.provider_id = payment_helper.__get_payment_provider_id(
        context=context,
        provider_name=provider_name,
        customer_profile_id=customer_profile_id,
        request_origin=request_origin,
    )

    response = request.hugoserve_post_request(
        path="/payment/v1/account/customer-profile",
        data=cust_profile_payment_acc_dto.get_dict(),
        headers=payment_helper.__get_default_payment_headers(
            customer_profile_id, request_origin, idempotency_key=str(uuid.uuid4())
        ),
    )
    assert response["headers"]["status_code"] == status_code

    if status_code == "200":
        assert "account_id" in response["data"], (
            f"\nExpected data object contains account_id" f"\nActual data: {response['data']}"
        )

        actual_onboard_status = response["data"]["account_status"]
        assert actual_onboard_status == "ACCOUNT_CREATED", (
            f"\nExpect data.account_status: ACCOUNT_CREATED"
            f"\nActual data.account_status: {response['data']['account_status']}, data: {response['data']}"
        )

        cust_profile_payment_acc_dto.account_id = response["data"]["account_id"]
        context.data[cust_profile_payment_acc_dto.identifier] = cust_profile_payment_acc_dto


@Then(
    "I wait until max time to verify the payment account ([^']*) from ([^']*) on behalf of ([^']*) status as ([^']*) with provider ([^']*) for customerProfileId ([^']*)"
)
def wait_to_create_payment_account(
    context,
    identifier: str,
    request_origin: str,
    on_behalf_of: str,
    onboard_status: str,
    provider_name: str,
    customer_profile_identifier: str,
):
    request = context.request
    payment_helper.__validate_provider(provider_name)
    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id
    payment_account_id = context.data[identifier].account_id

    @retry(
        AssertionError,
        tries=5,
        delay=20,
        logger=None,
    )
    def retry_for_creation_status():
        response = request.hugoserve_get_request(
            f"/payment/v1/account/{payment_account_id}",
            headers=payment_helper.__get_default_payment_headers(
                customer_profile_id, request_origin
            ),
        )
        assert response["headers"]["status_code"] == "200"
        assert response["data"]["account_status"] == onboard_status, print(
            f"\nExpect data.account_status: {onboard_status}"
            f"\nActual data.account_status: {response['data']['account_status']}, data: {response['data']}"
        )

    retry_for_creation_status()


@Then(
    "I verify CustomerProfile with id ([^']*) has payment account ([^']*) from ([^']*) on behalf of ([^']*) exists with provider ([^']*) with values"
)
def verify_payment_account_exist(
    context,
    customer_profile_identifier: str,
    identifier: str,
    request_origin: str,
    on_behalf_of: str,
    provider_name: str,
):
    request = context.request

    expected_payment_acc_dto = DataClassParser.parse_row(
        context.table.rows[0], data_class=AccountDTO
    )
    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id
    expected_payment_acc_dto.profile_id = customer_profile_id
    expected_payment_acc_dto.provider_id = payment_helper.__get_payment_provider_id(
        context=context,
        provider_name=provider_name,
        customer_profile_id=customer_profile_id,
        request_origin=request_origin,
    )
    payment_account_id = context.data[identifier].account_id

    response = request.hugoserve_get_request(
        f"/payment/v1/account/{payment_account_id}",
        headers=payment_helper.__get_default_payment_headers(
            customer_profile_id, request_origin
        ),
    )
    assert response["headers"]["status_code"] == "200"
    actual_payment_acc_dto = DataClassParser.dict_to_object(
        response["data"], data_class=AccountDTO
    )

    expected = AccountDTO.payment_account_dto(expected_payment_acc_dto)
    actual = AccountDTO.payment_account_dto(actual_payment_acc_dto)

    assert expected == actual, (
        f"\nExpect payment_account_dto: {expected}" f"\nActual payment_account_dto: {actual}"
    )

    context.data[identifier] = actual_payment_acc_dto.account_id


@Given(
    "I create account for EndCustomerProfile with id ([^']*) for CustomerProfile ([^']*) from ([^']*) on behalf of ([^']*) with provider ([^']*) and expect the header status ([^']*)"
)
def create_end_customer_profile_payment_account(
    context,
    end_customer_profile_identifier: str,
    customer_profile_identifier: str,
    request_origin: str,
    on_behalf_of: str,
    provider_name: str,
    status_code: str,
):
    request = context.request
    payment_helper.__validate_provider(provider_name)

    end_cust_profile_payment_acc_dto = DataClassParser.parse_row(
        context.table.rows[0], data_class=CreateEndCustomerProfileAccountDTO
    )

    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id
    end_cust_profile_payment_acc_dto.end_customer_profile_id = context.data[
        end_customer_profile_identifier
    ].end_customer_profile_id
    end_cust_profile_payment_acc_dto.customer_profile_id = customer_profile_id
    end_cust_profile_payment_acc_dto.provider_id = payment_helper.__get_payment_provider_id(
        context=context,
        provider_name=provider_name,
        customer_profile_id=customer_profile_id,
        request_origin=request_origin,
    )

    response = request.hugoserve_post_request(
        path="/payment/v1/account/end-customer-profile",
        data=end_cust_profile_payment_acc_dto.get_dict(),
        headers=payment_helper.__get_default_payment_headers(
            customer_profile_id, request_origin
        ),
    )
    assert response["headers"]["status_code"] == status_code

    if status_code == "200":
        assert (
            "data" in response
        ), f"\nExpected non empty data object, found empty. Response:{response}"
        assert "account_id" in response["data"], (
            f"\nExpected data object contains account_id" f"\nActual data: {response['data']}"
        )

        actual_onboard_status = response["data"]["account_status"]
        assert actual_onboard_status == "ACCOUNT_CREATED", (
            f"\nExpect data.account_status: ACCOUNT_CREATED"
            f"\nActual data.account_status: {response['data']['account_status']}, data: {response['data']}"
        )

        end_cust_profile_payment_acc_dto.account_id = response["data"]["account_id"]
        context.data[end_cust_profile_payment_acc_dto.identifier] = (
            end_cust_profile_payment_acc_dto
        )


@Then(
    "I verify EndCustomerProfile with id ([^']*) for CustomerProfile ([^']*) has payment account ([^']*) from ([^']*) on behalf of ([^']*) exists with provider ([^']*) with values"
)
def verify_end_customer_profile_payment_account_exist(
    context,
    end_customer_profile_identifier: str,
    customer_profile_identifier: str,
    identifier: str,
    request_origin: str,
    on_behalf_of: str,
    provider_name: str,
):
    request = context.request
    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id
    expected_payment_acc_dto = DataClassParser.parse_row(
        context.table.rows[0], data_class=AccountDTO
    )
    expected_payment_acc_dto.profile_id = context.data[
        end_customer_profile_identifier
    ].end_customer_profile_id
    expected_payment_acc_dto.provider_id = payment_helper.__get_payment_provider_id(
        context=context,
        provider_name=provider_name,
        customer_profile_id=customer_profile_id,
        request_origin=request_origin,
    )

    identifier = expected_payment_acc_dto.identifier
    payment_account_id = context.data[identifier].account_id

    response = request.hugoserve_get_request(
        f"/payment/v1/account/{payment_account_id}",
        headers=payment_helper.__get_default_payment_headers(
            customer_profile_id, request_origin
        ),
    )
    assert response["headers"]["status_code"] == "200"
    actual_payment_acc_dto = DataClassParser.dict_to_object(
        response["data"], data_class=AccountDTO
    )

    expected = AccountDTO.payment_account_dto(expected_payment_acc_dto)
    actual = AccountDTO.payment_account_dto(actual_payment_acc_dto)

    assert expected == actual, (
        f"\nExpect payment_account_dto: {expected}" f"\nActual payment_account_dto: {actual}"
    )

    context.data[identifier] = actual_payment_acc_dto.account_id


@Then(
    "I retrieve the payment account ([^']*) from ([^']*) on behalf of ([^']*) status as ([^']*) with provider ([^']*) for customerProfileId ([^']*)"
)
def retrieve_payment_account(
    context,
    identifier: str,
    request_origin: str,
    on_behalf_of: str,
    account_status: str,
    provider_name: str,
    customer_profile_identifier: str,
):
    request = context.request
    payment_helper.__validate_provider(provider_name)
    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id
    payment_account_id = context.data[identifier]

    response = request.hugoserve_get_request(
        f"/payment/v1/account/{payment_account_id}",
        headers=payment_helper.__get_default_payment_headers(
            customer_profile_id, request_origin
        ),
    )
    assert response["headers"]["status_code"] == "200"
    assert response["data"]["account_status"] == account_status, print(
        f"\nExpect data.account_status: {account_status}"
        f"\nActual data.account_status: {response['data']['account_status']}, data: {response['data']}"
    )
    context.data[identifier] = response['data']


@Then(
    "I wait until max time to verify master account ([^']*) with an available balance of ([^']*) and total balance of ([^']*) for customerProfileId ([^']*)"
)
def verify_account_balance(
    context,
    identifier,
    expected_available_balance: float,
    expected_total_balance: float,
    customer_profile_identifier: str,
):
    request = context.request
    master_account_id = context.data[identifier].master_account_id
    customer_profile_id = context.data[customer_profile_identifier].customer_profile_id

    @retry(
        AssertionError,
        tries=payment_helper.cash_providers_config["DBS Bank Ltd"]["max_wait_time"] / 5,
        delay=20,
        logger=None,
    )
    def retry_for_account_status():
        response = request.hugoserve_get_request(
            path=f"/payment/v1/account/master-account/{master_account_id}/balance",
            headers=payment_helper.__get_default_payment_headers(
                customer_profile_id, request_origin='CASH_SERVICE'
            ),
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

    retry_for_account_status()
