import dataclasses
from datetime import datetime, timedelta
from typing import Optional

from test.api.aggregate.card.card_helper import (
    get_currency_precision,
    is_valid_fp_tx_id,
    is_valid_uuid,
    round_down,
)


@dataclasses.dataclass
class CardAccountCreateRequestDTO:
    card_account_identifier: str
    end_customer_profile_identifier: str
    card_account_product_id: Optional[str]
    provider_name: str
    bank_account_identifier: str
    end_customer_profile_id: Optional[str]
    provider_id: Optional[str]
    bank_account_id: Optional[str]
    customer_address: dict

    def get_dict(self):
        return {
            "end_customer_profile_id": self.end_customer_profile_id,
            "card_account_product_id": self.card_account_product_id,
            "provider_id": self.provider_id,
            "bank_account_id": self.bank_account_id,
            "customer_address": self.customer_address,
        }


@dataclasses.dataclass
class CardIssueRequestDTO:
    card_identifier: str
    card_account_identifier: Optional[str]
    card_product_id: Optional[str]
    card_account_id: Optional[str]
    card_type: str
    card_config_id: Optional[str]
    emboss_name: str
    validity_in_months: int
    three_d_secure_config: dict
    delivery_address: dict

    def get_dict(self):
        return {
            "card_account_id": self.card_account_id,
            "card_product_id": self.card_product_id,
            "card_type": self.card_type,
            "card_config_id": self.card_config_id,
            "emboss_name": self.emboss_name,
            "validity_in_months": self.validity_in_months,
            "delivery_address": self.delivery_address,
            "three_d_secure_config": self.three_d_secure_config
        }


@dataclasses.dataclass
class UpdateCardStatusDTO:
    card_identifier: Optional[str]
    card_status: str

    def get_dict(self):
        return {"card_status": self.card_status}


@dataclasses.dataclass
class ActivateCardRequestDTO:
    card_identifier: str
    card_token: Optional[str]

    def get_dict(self):
        return {"card_token": self.card_token}


@dataclasses.dataclass
class DynamicDataStreamResponseDTO:
    transaction_identifier: str
    message_type: Optional[str]
    authorized_tx_amount: Optional[str]
    transaction_currency_code: Optional[str]
    cardholder_billing_currency_code: Optional[str]
    transaction_currency: Optional[str]
    cardholder_billing_currency: Optional[str]
    response_code: Optional[str]
    response_reason: Optional[str]
    is_empty_service_tx_id: Optional[bool]
    error_code: Optional[str]
    case_type: str


@dataclasses.dataclass
class BankAccount:
    customer_card_float_account_id: str
    customer_clearing_account_id: str
    customer_settlement_account_id: str
    customer_interchange_fee_account_id: str


@dataclasses.dataclass
class CardDTO:
    transaction_identifier: Optional[str]
    card_identifier: Optional[str]
    card_id: Optional[str]
    card_form_factor: str
    card_status: Optional[str]
    card_prev_status: Optional[str]
    card_status_change_reason: Optional[str]

    def get_dict(self):
        card_dict = {
            "card_id": self.card_id,
            "card_form_factor": self.card_form_factor,
            "card_status": self.card_status,
            "card_prev_status": self.card_prev_status,
            "card_status_change_reason": self.card_status_change_reason,
        }

        # Filtering out fields which are not set
        card_dict = {k: v for k, v in card_dict.items() if v is not None and len(str(v)) != 0}
        return card_dict

    @classmethod
    def sanitize_card(cls, card_dto):
        card_dto.transaction_identifier = None
        card_dto.card_identifier = None
        return card_dto

    def __eq__(self, actual_dto):
        if not isinstance(actual_dto, self.__class__):
            return False

        return (
            (
                self.card_form_factor == actual_dto.card_form_factor
                or self.card_form_factor.lower() == actual_dto.card_form_factor.lower()
            )
            and self.card_id == actual_dto.card_id
            and (
                self.card_prev_status == actual_dto.card_prev_status
                or self.card_prev_status.lower() == actual_dto.card_prev_status.lower()
            )
            and (
                self.card_status == actual_dto.card_status
                or self.card_status.lower() == actual_dto.card_status.lower()
            )
            and self.card_status_change_reason == actual_dto.card_status_change_reason
        )


@dataclasses.dataclass
class CustomerDTO:
    transaction_identifier: Optional[str]
    customer_identifier: Optional[str]
    customer_id: Optional[str]

    def get_dict(self):
        return {"customer_id": self.customer_id, "customer_external_ref": self.customer_id}

    @classmethod
    def sanitize_customer(cls, customer_dto):
        customer_dto.transaction_identifier = None
        customer_dto.customer_identifier = None
        return customer_dto


@dataclasses.dataclass
class ThreeDSAdditionalDataDTO:
    three_ds_provider: str
    three_ds_authentication_method: str
    three_ds_otp_delivery_method: str
    three_ds_reference_number: str

    def get_dict(self):
        return {
            "three_ds_provider": self.three_ds_provider,
            "three_ds_authentication_method": self.three_ds_authentication_method,
            "three_ds_otp_delivery_method": self.three_ds_otp_delivery_method,
            "three_ds_reference_number": self.three_ds_reference_number,
        }

    @classmethod
    def sanitize_three_ds(cls, three_ds_additional_data_dto):
        pass  # Noop

    def __get_expected_three_ds_otp_delivery_method(self):
        three_ds_otp_delivery_method_dict = {
            "C9 SMS": "C9_SMS",
            "C9 email": "C9_EMAIL",
            "Company API": "COMPANY_API",
        }
        return three_ds_otp_delivery_method_dict.get(
            self.three_ds_otp_delivery_method, "UNKNOWN_DELIVERY_METHOD"
        )

    def __eq__(self, actual_dto):
        if not isinstance(actual_dto, self.__class__):
            return False

        return (
            self.three_ds_provider == actual_dto.three_ds_provider
            and self.three_ds_authentication_method == actual_dto.three_ds_authentication_method
            and self.__get_expected_three_ds_otp_delivery_method()
            == actual_dto.three_ds_otp_delivery_method
            and self.three_ds_reference_number == actual_dto.three_ds_reference_number
        )


@dataclasses.dataclass
class UpdateDTO:
    transaction_identifier: Optional[str]
    original_message_type: str
    original_message_qualifier: str
    original_transaction_id: str
    original_system_trace_audit_number: str
    original_retrieval_reference_number: str
    original_transmission_date: str
    original_transmission_time: str
    original_transaction_amount: str
    actual_transaction_amount: Optional[str]

    def get_dict(self):
        update_dict = {
            "original_message_type": self.original_message_type,
            "original_message_qualifier": self.original_message_qualifier,
            "original_transaction_id": self.original_transaction_id,
            "original_system_trace_audit_number": self.original_system_trace_audit_number,
            "original_retrieval_reference_number": self.original_retrieval_reference_number,
            "original_transmission_date": self.original_transmission_date,
            "original_transmission_time": self.original_transmission_time,
            "original_transaction_amount": self.original_transaction_amount,
            "actual_transaction_amount": self.actual_transaction_amount,
        }

        # Filtering out fields which are not set
        update_dict = {
            k: v for k, v in update_dict.items() if v is not None and len(str(v)) != 0
        }
        return update_dict

    @classmethod
    def sanitize_update(cls, update_dto):
        update_dto.transaction_identifier = None
        return update_dto

    def __eq__(self, actual_dto):
        if not isinstance(actual_dto, self.__class__):
            return False

        # TODO: Validate original amounts and actual amounts
        return (
            self.original_message_type.lower() == actual_dto.original_message_type.lower()
            and self.original_transaction_id == actual_dto.original_transaction_id
            and self.original_system_trace_audit_number
            == actual_dto.original_system_trace_audit_number
            and self.original_retrieval_reference_number
            == actual_dto.original_retrieval_reference_number
        )


@dataclasses.dataclass
class StatusDTO:
    transaction_identifier: Optional[str]
    response_code: str
    response_source: str
    response_reason: str
    authorization_id_response: Optional[str]

    def get_dict(self):
        return {
            "response_code": self.response_code,
            "response_source": self.response_source,
            "response_reason": self.response_reason,
            "authorization_id_response": self.authorization_id_response,
        }

    @classmethod
    def sanitize_status(cls, status_dto):
        status_dto.transaction_identifier = None
        return status_dto

    def __eq__(self, actual_dto):
        if not isinstance(actual_dto, self.__class__):
            return False

        return (
            self.response_code == actual_dto.response_code
            and self.response_source.lower() == actual_dto.response_source.lower()
            and self.authorization_id_response == actual_dto.authorization_id_response
        )


@dataclasses.dataclass
class TransactionDTO:
    transaction_identifier: Optional[str]
    auth_type: Optional[str]
    reversal_type: Optional[str]
    transaction_type: str
    transaction_id: str
    system_trace_audit_number: str
    retrieval_reference_number: str
    network_transaction_id: Optional[str]
    transmission_date: Optional[str]
    transmission_time: Optional[str]
    transaction_local_date: Optional[str]
    transaction_local_time: Optional[str]

    transaction_amount: str
    transaction_currency_code: Optional[str]
    transaction_currency: Optional[str]
    cardholder_billing_amount: str
    cardholder_billing_currency_code: Optional[str]
    cardholder_billing_currency: Optional[str]
    cardholder_billing_conversion_rate: Optional[str]

    from_account: Optional[str]
    eci: Optional[str]
    dcc_indicator: str
    chip_indicator: str
    pin_indicator: str
    three_ds_indicator: str
    credential_on_file: Optional[str]
    avs_outcome: Optional[str]
    partial_approval_supported: str
    cardholder_condition: Optional[str]

    three_ds_additional_data: Optional[ThreeDSAdditionalDataDTO]
    update: Optional[UpdateDTO]
    status: Optional[StatusDTO]

    def get_dict(self):
        transaction_dict = {
            "auth_type": self.auth_type,
            "reversal_type": self.reversal_type,
            "transaction_type": self.transaction_type,
            "transaction_id": self.transaction_id,
            "system_trace_audit_number": self.system_trace_audit_number,
            "retrieval_reference_number": self.retrieval_reference_number,
            "network_transaction_id": self.network_transaction_id,
            "transmission_date": self.transmission_date,
            "transmission_time": self.transmission_time,
            "transaction_local_date": self.transaction_local_date,
            "transaction_local_time": self.transaction_local_time,
            "transaction_amount": self.transaction_amount,
            "transaction_currency_code": self.transaction_currency_code,
            "transaction_currency": self.transaction_currency,
            "cardholder_billing_amount": self.cardholder_billing_amount,
            "cardholder_billing_currency_code": self.cardholder_billing_currency_code,
            "cardholder_billing_currency": self.cardholder_billing_currency,
            "cardholder_billing_conversion_rate": self.cardholder_billing_conversion_rate,
            "from_account": self.from_account,
            "eci": self.eci,
            "dcc_indicator": self.dcc_indicator,
            "chip_indicator": self.chip_indicator,
            "pin_indicator": self.pin_indicator,
            "3ds_indicator": self.three_ds_indicator,
            "credential_on_file": self.credential_on_file,
            "avs_outcome": self.avs_outcome,
            "partial_approval_supported": self.partial_approval_supported,
            "cardholder_condition": self.cardholder_condition,
            "three_ds_additional_data": (
                self.three_ds_additional_data.get_dict()
                if self.three_ds_additional_data is not None
                else self.three_ds_additional_data
            ),
            "update": self.update.get_dict() if self.update is not None else self.update,
            "status": self.status.get_dict() if self.status is not None else self.status,
        }

        # Filtering out fields which are not set
        transaction_dict = {
            k: v for k, v in transaction_dict.items() if v is not None and len(str(v)) != 0
        }
        return transaction_dict

    @classmethod
    def sanitize_transaction(cls, transaction_dto):
        transaction_dto.transaction_identifier = None
        transaction_dto.three_ds_additional_data = (
            None
            if transaction_dto.three_ds_additional_data is None
            else ThreeDSAdditionalDataDTO.sanitize_three_ds(
                transaction_dto.three_ds_additional_data
            )
        )
        transaction_dto.update = (
            None
            if transaction_dto.update is None
            else UpdateDTO.sanitize_update(transaction_dto.update)
        )
        transaction_dto.status = (
            None
            if transaction_dto.status is None
            else StatusDTO.sanitize_status(transaction_dto.status)
        )
        return transaction_dto

    def __get_expected_eci(self):
        eci_dict = {
            "1": "SINGLE_TRANSACTION_OF_MAIL_PHONE_ORDER",
            "2": "RECURRING_TRANSACTION",
            "3": "INSTALMENT_PAYMENT",
            "4": "MAIL_TELEPHONE_ORDER_TYPE_UNKNOWN_EDITED",
            "5": "FULLY_AUTHENTICATED",
            "6": "AUTHENTICATION_ATTEMPTED_BUT_UNSUCCESSFUL",
            "7": "AUTHENTICATION_NOT_ATTEMPTED",
            "8": "NON_SECURE_TRANSACTION",
        }
        return eci_dict.get(self.eci, "NOT_APPLICABLE_TO_THE_TRANSACTION")

    def __get_expected_chip_indicator(self):
        chip_indicator_dict = {
            "n": "NOT_USED",
            "contact": "CONTACT",
            "contactless": "CONTACTLESS",
        }
        return chip_indicator_dict.get(self.chip_indicator, "UNKNOWN_CHIP_INDICATOR")

    def __get_pin_indicator(self):
        pin_indicator_dict = {
            "n": "PIN_NOT_CHECKED",
            "offline_passed": "OFFLINE_PASSED",
            "offline_failed": "OFFLINE_FAILED",
            "online_passed": "ONLINE_PASSED",
            "online_failed": "ONLINE_FAILED",
        }
        return pin_indicator_dict.get(self.pin_indicator, "UNKNOWN_PIN_INDICATOR")

    def __get_expected_avs_outcome(self):
        avs_outcome_dict = {
            "m": "BOTH_MATCH",
            "a": "ADDRESS_MATCH_ONLY",
            "p": "POST_CODE_MATCH_ONLY",
            "n": "NEITHER_MATCH",
            "r": "ERROR_WHILE_PROCESSING",
        }
        return avs_outcome_dict.get(self.avs_outcome, "UNKNOWN_AVS_OUTCOME")

    def __get_cardholder_condition(self):
        cardholder_condition_dict = {
            "00": "CARD_HOLDER_PRESENT",
            "01": "CARD_HOLDER_NOT_PRESENT",
            "02": "CARD_HOLDER_PRESENT",
            "03": "CARD_PRESENT_SUSPICIOUS_ACTIVITY",
            "05": "CARD_HOLDER_PRESENT",
            "08": "CARD_HOLDER_NOT_PRESENT_MAIL_OR_TELEPHONE_ORDER",
            "59": "CARD_HOLDER_NOT_PRESENT_ELECTRONIC_ORDER",
            "71": "CARD_HOLDER_PRESENT_US_ONLY",
        }
        return (
            None
            if self.cardholder_condition is None
            else cardholder_condition_dict.get(
                self.cardholder_condition, "UNKNOWN_CARD_HOLDER_CONDITION"
            )
        )

    def __get_transaction_type(self):
        transaction_type_dict = {
            "00": "GOODS_AND_SERVICES",
            "01": "CASH_WITHDRAWAL_ATM",
            "02": "CASH_WITHDRAWAL_MANUAL_DISBURSEMENT",
            "09": "GOODS_AND_SERVICE_WITH_CASH_DISBURSEMENT",
            "10": "ACCOUNT_FUNDING",
            "11": "QUASI_CASH",
            "20": "RETURNS_AND_REFUNDS",
            "21": "ENVELOPE_DEPOSIT",
            "22": "CHEQUE_DEPOSIT",
            "23": "CASH_DEPOSIT",
            "25": "CREDIT_ADJUSTMENT",
            "26": "ORIGINAL_CREDIT",
            "28": "PREPAID_LOAN_AND_ACTIVATION",
            "30": "BALANCE_INQUIRY",
            "34": "MINI_STATEMENT",
            "39": "ELIGIBILITY_INQUIRY",
            "40": "CARDHOLDER_ACCOUNT_TRANSFER",
            "50": "BILL_PAYMENT",
            "53": "PAYMENT",
            "70": "PIN_CHANGE",
            "71": "PIN_UNBLOCK",
            "72": "PIN_CHECK",
            "84": "FUNDS_DISBURSEMENT",
            "92": "ADDRESS_VERIFICATION",
        }
        return transaction_type_dict.get(self.transaction_type, "UNKNOWN_TRANSACTION_TYPE")

    def __eq__(self, actual_dto):
        if not isinstance(actual_dto, self.__class__):
            return False

        if self.three_ds_additional_data != actual_dto.three_ds_additional_data:
            return False

        if self.update != actual_dto.update:
            return False

        if self.status != actual_dto.status:
            return False

        # TODO: Validate transaction_amount, transaction_currency_code, billing_amount,
        #  billing_currency_code
        #  and conversion rate
        return (
            (
                None
                if self.auth_type is not None and len(self.auth_type) == 0
                else self.auth_type
            )
            == actual_dto.auth_type
            and (
                None
                if self.reversal_type is not None and len(self.reversal_type) == 0
                else self.reversal_type
            )
            == actual_dto.reversal_type
            and self.__get_transaction_type() == actual_dto.transaction_type
            and self.transaction_id == actual_dto.transaction_id
            and self.system_trace_audit_number == actual_dto.system_trace_audit_number
            and self.transaction_currency == actual_dto.transaction_currency
            and self.cardholder_billing_currency == actual_dto.cardholder_billing_currency
            and self.retrieval_reference_number == actual_dto.retrieval_reference_number
            and self.network_transaction_id == actual_dto.network_transaction_id
            and self.__get_expected_eci() == actual_dto.eci
            and self.__get_expected_chip_indicator() == actual_dto.chip_indicator
            and self.__get_pin_indicator() == actual_dto.pin_indicator
            and (self.dcc_indicator.lower() == 'y') == actual_dto.dcc_indicator
            and (self.three_ds_indicator.lower() == 'y') == actual_dto.three_ds_indicator
            and (self.credential_on_file.lower() == 'y') == actual_dto.credential_on_file
            and (self.partial_approval_supported.lower() == 'y')
            == actual_dto.partial_approval_supported
            and self.__get_cardholder_condition() == actual_dto.cardholder_condition
        )


@dataclasses.dataclass
class AcquirerDTO:
    transaction_identifier: Optional[str]
    acquiring_institution_id_code: str
    acquiring_institution_country_code: str
    merchant_category_code: str
    card_acceptor_terminal_id: str
    card_acceptor_id: str
    card_acceptor_name: str
    card_acceptor_city: str
    card_acceptor_country_code: str

    def get_dict(self):
        return {
            "acquiring_institution_id_code": self.acquiring_institution_id_code,
            "acquiring_institution_country_code": self.acquiring_institution_country_code,
            "merchant_category_code": self.merchant_category_code,
            "card_acceptor_terminal_id": self.card_acceptor_terminal_id,
            "card_acceptor_id": self.card_acceptor_id,
            "card_acceptor_name": self.card_acceptor_name,
            "card_acceptor_city": self.card_acceptor_city,
            "card_acceptor_country_code": self.card_acceptor_country_code,
        }

    @classmethod
    def sanitize_acquirer(cls, acquirer_dto):
        acquirer_dto.transaction_identifier = None
        return acquirer_dto


@dataclasses.dataclass
class ClearingDTO:
    @dataclasses.dataclass
    class ClearingAuthDTO:
        transaction_identifier: Optional[str]
        auth_transaction_id: str
        system_trace_audit_number: str
        retrieval_reference_number: str

        def get_dict(self):
            return {
                "auth_transaction_id": self.auth_transaction_id,
                "system_trace_audit_number": self.system_trace_audit_number,
                "retrieval_reference_number": self.retrieval_reference_number,
            }

        @classmethod
        def sanitize_clearing_auth(cls, clearing_auth_dto):
            clearing_auth_dto.transaction_identifier = None
            return clearing_auth_dto

    transaction_identifier: Optional[str]
    record_id_clearing: str
    clearing_category: str
    transaction_type: str
    reason_code: str
    reference_number: str
    sequence_number: str
    clearing_date: str
    authorization_code: str
    authorizations: Optional[list[ClearingAuthDTO]]
    transaction_amount: str
    transaction_currency_code: str
    transaction_currency: Optional[str]
    billing_amount: str
    billing_currency_code: str
    billing_currency: Optional[str]
    cashback_amount: Optional[str]
    interchange_fee: str
    transaction_to_base_currency_rate: Optional[str]
    base_to_billing_currency_rate: Optional[str]
    merchant_name: Optional[str]
    card_id: Optional[str]
    clearing_outcome: Optional[str]

    def get_dict(self):
        clearing_dict = {
            "record_id_clearing": self.record_id_clearing,
            "clearing_category": self.clearing_category,
            "transaction_type": self.transaction_type,
            "reason_code": self.reason_code,
            "reference_number": self.reference_number,
            "sequence_number": self.sequence_number,
            "date": self.clearing_date,
            "authorization_code": self.authorization_code,
            "authorizations": (
                list(map(lambda authorization: authorization.get_dict(), self.authorizations))
                if self.authorizations is not None
                else []
            ),
            "cardholder_billing_amount": self.billing_amount,
            "cardholder_billing_currency_code": self.billing_currency_code,
            "cardholder_billing_currency": self.billing_currency,
            "transaction_amount": self.transaction_amount,
            "cashback_amount": self.cashback_amount,
            "transaction_currency_code": self.transaction_currency_code,
            "transaction_currency": self.transaction_currency,
            "interchange_fee": self.interchange_fee,
            "transaction_to_base_currency_rate": self.transaction_to_base_currency_rate,
            "base_to_billing_currency_rate": self.base_to_billing_currency_rate,
            "merchant_name": self.merchant_name,
            "card_id": self.card_id,
            "clearing_outcome": self.clearing_outcome,
        }

        # Filtering out fields which are not set
        clearing_dict = {
            k: v for k, v in clearing_dict.items() if v is not None and len(str(v)) != 0
        }
        return clearing_dict

    @classmethod
    def sanitize_clearing(cls, clearing_dto):
        clearing_dto.transaction_identifier = None
        clearing_dto.authorizations = (
            None
            if clearing_dto.authorizations is None
            else [
                ClearingDTO.ClearingAuthDTO.sanitize_clearing_auth(auth)
                for auth in clearing_dto.authorizations
            ]
        )
        return clearing_dto

    def __get_expected_clearing_outcome(self):
        clearing_outcome_dict = {
            "0": "AUTH_FOUND_AMOUNT_MATCH",
            "1": "AUTH_FOUND_AMOUNT_MISMATCH_WITHIN_SCHEME_RULE",
            "8": "AUTH_FOUND_AMOUNT_MISMATCH_OUTSIDE_SCHEME_RULE",
            "9": "MATCHING_AUTH_NOT_FOUND",
        }
        return clearing_outcome_dict.get(self.clearing_outcome, "UNKNOWN_CLEARING_OUTCOME")

    def __eq__(self, actual_dto):
        if not isinstance(actual_dto, self.__class__):
            return False

        expected_card_id = self.card_id
        if self.card_id is None:
            expected_card_id = 'UNKNOWN_CARD_ID'

        # TODO: Validate transaction_amount, billing_amount and interchange_fee
        return (
            self.record_id_clearing == actual_dto.record_id_clearing
            and self.clearing_category.lower() == actual_dto.clearing_category.lower()
            and ("FIRST_CLEARING" if self.transaction_type == '1' else "DISPUTE")
            == actual_dto.transaction_type
            and self.reason_code == actual_dto.reason_code
            and self.reference_number == actual_dto.reference_number
            and self.sequence_number == actual_dto.sequence_number
            and self.authorization_code == actual_dto.authorization_code
            and self.authorizations
            == (None if len(actual_dto.authorizations) == 0 else actual_dto.authorizations)
            and self.transaction_currency == actual_dto.transaction_currency
            and self.billing_currency == actual_dto.billing_currency
            and self.cashback_amount == actual_dto.cashback_amount
            and self.merchant_name == actual_dto.merchant_name
            and expected_card_id == actual_dto.card_id
            and (
                self.clearing_outcome == actual_dto.clearing_outcome
                or self.__get_expected_clearing_outcome() == actual_dto.clearing_outcome
            )
        )


@dataclasses.dataclass
class DynamicDataStreamDTO:
    transaction_identifier: Optional[str]
    message_type: str
    message_qualifier: str
    source: Optional[str]
    card: Optional[CardDTO]
    customer: Optional[CustomerDTO]
    transaction: Optional[TransactionDTO]
    acquirer: Optional[AcquirerDTO]
    clearing: Optional[ClearingDTO]

    # Fields only present in table as columns, adding these here instead of creating a separate
    # dataclass.
    # Creating these fields as Optional to avoid issues while parsing the feature file tabulated
    # data to dataclass
    # as these fields won't be present there
    customer_id: Optional[str]
    card_id: Optional[str]
    clowd9_transaction_id: Optional[str]
    service_transaction_id: Optional[str]
    processing_status: Optional[str]
    status_reason: Optional[str]
    transaction_type: Optional[str]
    retrieval_reference_number: Optional[str]
    source: Optional[str]
    transmission_ts: Optional[str]
    transaction_local_ts: Optional[str]

    def get_dict(self):
        request_dict = {
            "message_type": self.message_type,
            "message_qualifier": self.message_qualifier,
            "source": self.source,
            "card": self.card.get_dict() if self.card is not None else self.card,
            "customer": (
                self.customer.get_dict() if self.customer is not None else self.customer
            ),
            "transaction": (
                self.transaction.get_dict()
                if self.transaction is not None
                else self.transaction
            ),
            "acquirer": (
                self.acquirer.get_dict() if self.acquirer is not None else self.acquirer
            ),
            "clearing": (
                self.clearing.get_dict() if self.clearing is not None else self.clearing
            ),
        }

        # Filtering out fields which are not set
        request_dict = {
            k: v for k, v in request_dict.items() if v is not None and len(str(v)) != 0
        }
        return request_dict

    @classmethod
    def sanitize_dynamic_data_stream(cls, dto):
        dto.transaction_identifier = None
        dto.card = None if dto.card is None else CardDTO.sanitize_card(dto.card)
        dto.customer = (
            None if dto.customer is None else CustomerDTO.sanitize_customer(dto.customer)
        )
        dto.transaction = (
            None
            if dto.transaction is None
            else TransactionDTO.sanitize_transaction(dto.transaction)
        )
        dto.acquirer = (
            None if dto.acquirer is None else AcquirerDTO.sanitize_acquirer(dto.acquirer)
        )
        dto.clearing = (
            None if dto.clearing is None else ClearingDTO.sanitize_clearing(dto.clearing)
        )
        return dto

    def __is_clearing(self):
        return self.message_type.lower() == 'clearing'

    def __get_expected_rrn(self):
        if self.__is_clearing():
            if self.clearing.authorizations is None or len(self.clearing.authorizations) == 0:
                return 'UNKNOWN_RETRIEVAL_REFERENCE_NUMBER'
            else:
                return self.clearing.authorizations[0].retrieval_reference_number

        return self.transaction.retrieval_reference_number

    def __get_transaction_type(self):
        transaction_type_dict = {
            "00": "GOODS_AND_SERVICES",
            "01": "CASH_WITHDRAWAL_ATM",
            "02": "CASH_WITHDRAWAL_MANUAL_DISBURSEMENT",
            "09": "GOODS_AND_SERVICE_WITH_CASH_DISBURSEMENT",
            "10": "ACCOUNT_FUNDING",
            "11": "QUASI_CASH",
            "20": "RETURNS_AND_REFUNDS",
            "21": "ENVELOPE_DEPOSIT",
            "22": "CHEQUE_DEPOSIT",
            "23": "CASH_DEPOSIT",
            "25": "CREDIT_ADJUSTMENT",
            "26": "ORIGINAL_CREDIT",
            "28": "PREPAID_LOAN_AND_ACTIVATION",
            "30": "BALANCE_INQUIRY",
            "34": "MINI_STATEMENT",
            "39": "ELIGIBILITY_INQUIRY",
            "40": "CARDHOLDER_ACCOUNT_TRANSFER",
            "50": "BILL_PAYMENT",
            "53": "PAYMENT",
            "70": "PIN_CHANGE",
            "71": "PIN_UNBLOCK",
            "72": "PIN_CHECK",
            "84": "FUNDS_DISBURSEMENT",
            "92": "ADDRESS_VERIFICATION",
        }
        return transaction_type_dict.get(
            self.transaction.transaction_type, "UNKNOWN_TRANSACTION_TYPE"
        )

    def __eq__(self, actual_dto):
        if not isinstance(actual_dto, self.__class__):
            return False

        if self.card != actual_dto.card:
            return False

        if self.customer != actual_dto.customer:
            return False

        if self.acquirer != actual_dto.acquirer:
            return False

        if self.transaction != actual_dto.transaction:
            return False

        if self.clearing != actual_dto.clearing:
            return False

        expected_customer_id = '' if self.__is_clearing() else self.customer.customer_id
        expected_card_id = (
            ('UNKNOWN_CARD_ID' if self.clearing.card_id is None else self.clearing.card_id)
            if self.__is_clearing()
            else self.card.card_id
        )
        expected_transaction_type = (
            ("FIRST_CLEARING" if self.clearing.transaction_type == '1' else "DISPUTE")
            if self.__is_clearing()
            else self.__get_transaction_type()
        )
        expected_rrn = self.__get_expected_rrn()
        expected_source = (
            None
            if self.__is_clearing()
            else (None if self.source is not None and len(self.source) == 0 else self.source)
        )
        # expected_transmission_ts

        # TODO: Conditionally check processing status to either be COMPLETE or FAILED
        return (
            expected_customer_id == actual_dto.customer_id
            and expected_card_id == actual_dto.card_id
            and (
                self.clearing.record_id_clearing
                if self.__is_clearing()
                else self.transaction.transaction_id
            )
            == actual_dto.clowd9_transaction_id
            and is_valid_uuid(actual_dto.service_transaction_id)
            and (
                actual_dto.processing_status == 'COMPLETE'
                or actual_dto.processing_status == 'FAILED'
            )
            and self.message_type.lower() == actual_dto.message_type.lower()
            and self.message_qualifier.lower() == actual_dto.message_qualifier.lower()
            and expected_transaction_type == actual_dto.transaction_type
            and expected_rrn == actual_dto.retrieval_reference_number
            and expected_source == actual_dto.source
        )


@dataclasses.dataclass
class NymcardTransactionDTO:
    transaction_identifier: Optional[str]
    id: Optional[str]
    parent_transaction_identifier: Optional[str]
    parent_transaction_id: Optional[str]
    sms_clearing_transaction_id: Optional[str]
    transaction_timestamp: Optional[str]
    network: Optional[str]
    message_type: Optional[str]
    transaction_type: Optional[str]
    transaction_description: Optional[str]
    transmission_timestamp: Optional[str]
    date_time_acquirer: Optional[str]

    card_identifier: Optional[str]
    user_identifier: Optional[str]
    card_id: Optional[str]
    card_product_id: Optional[str]
    card_first6_digits: Optional[str]
    card_last4_digits: Optional[str]
    card_expiry_date: Optional[str]
    user_id: Optional[str]

    acquirer_id: Optional[str]
    merchant_id: Optional[str]
    mcc: Optional[str]
    merchant_name: Optional[str]
    merchant_city: Optional[str]
    merchant_country: Optional[str]
    terminal_id: Optional[str]

    rrn_identifier: Optional[str]
    rrn: Optional[str]
    stan: Optional[str]
    network_transaction_id: Optional[str]

    transaction_amount: Optional[float]
    transaction_currency: Optional[str]
    billing_amount: Optional[float]
    billing_currency: Optional[str]
    original_transaction_amount: Optional[float]
    original_billing_amount: Optional[float]
    fee_amount: Optional[str]
    fee_details: Optional[dict]

    incremental_transaction: Optional[bool]
    is_pre_auth: Optional[bool]
    eci: Optional[str]
    card_entry: Optional[str]
    pos_environment: Optional[str]
    pin_present: Optional[bool]
    settlement_status: Optional[str]
    moto: Optional[bool]
    performed_operation_type: Optional[str]
    processing_code: Optional[str]
    three_DS_indicator: Optional[bool]

    interchange_fee: Optional[float]
    interchange_fee_indicator: Optional[str]

    clearing_ts: Optional[str]
    cleared_ts: Optional[str]

    status_code: Optional[str]
    status_description: Optional[str]

    create_ts: Optional[str]
    update_ts: Optional[str]

    def get_dict(self):
        nymcard_transaction_dict = {
            "transaction_identifier": self.transaction_identifier,
            "id": self.id,
            "parent_transaction_identifier": self.parent_transaction_identifier,
            "parent_transaction_id": self.parent_transaction_id,
            "sms_clearing_transaction_id": self.sms_clearing_transaction_id,
            "transaction_timestamp": self.transaction_timestamp,
            "network": self.network,
            "message_type": self.message_type,
            "transaction_type": self.transaction_type,
            "transaction_description": self.transaction_description,
            "transmission_timestamp": self.transmission_timestamp,
            "date_time_acquirer": self.date_time_acquirer,
            "card_identifier": self.card_identifier,
            "user_identifier": self.user_identifier,
            "card_id": self.card_id,
            "user_id": self.user_id,
            "card_product_id": self.card_product_id,
            "card_first6_digits": self.card_first6_digits,
            "card_last4_digits": self.card_last4_digits,
            "card_expiry_date": self.card_expiry_date,
            "acquirer_id": self.acquirer_id,
            "merchant_id": self.merchant_id,
            "mcc": self.mcc,
            "merchant_name": self.merchant_name,
            "merchant_city": self.merchant_city,
            "merchant_country": self.merchant_country,
            "terminal_id": self.terminal_id,
            "stan": self.stan,
            "rrn": self.rrn,
            "network_transaction_id": self.network_transaction_id,
            "transaction_amount": self.transaction_amount,
            "transaction_currency": self.transaction_currency,
            "billing_amount": self.billing_amount,
            "billing_currency": self.billing_currency,
            "original_transaction_amount": self.original_transaction_amount,
            "original_billing_amount": self.original_billing_amount,
            "fee_amount": self.fee_amount,
            "fee_details": self.fee_details,
            "incremental_transaction": self.incremental_transaction,
            "is_pre_auth": self.is_pre_auth,
            "eci": self.eci,
            "card_entry": self.card_entry,
            "pos_environment": self.pos_environment,
            "pin_present": self.pin_present,
            "settlement_status": self.settlement_status,
            "moto": self.moto,
            "performed_operation_type": self.performed_operation_type,
            "processing_code": self.processing_code,
            "three_DS_indicator": self.three_DS_indicator,
            "interchange_fee": self.interchange_fee,
            "interchange_fee_indicator": self.interchange_fee_indicator,
            "clearing_ts": self.clearing_ts,
            "cleared_ts": self.cleared_ts,
            "status_code": self.status_code,
            "status_description": self.status_description,
            "create_ts": self.create_ts,
            "update_ts": self.update_ts,
        }

        # Filtering out fields which are not set
        nymcard_transaction_dict = {
            k: v
            for k, v in nymcard_transaction_dict.items()
            if v is not None and len(str(v)) != 0
        }
        return nymcard_transaction_dict

    def update(self, updated_nymcard_transaction_dto):
        for key, value in updated_nymcard_transaction_dto.get_dict().items():
            if value is not None:
                setattr(self, key, value)

    def __get_performed_operation_type(self):
        performed_operation_type_mapping = {"D": "DEBIT_OPERATION", "C": "CREDIT_OPERATION"}

        return performed_operation_type_mapping.get(self.performed_operation_type)

    def __check_clearing_ts(self, actual_ts):
        clearing_ts_obj = datetime.strptime(actual_ts.clearing_ts, "%Y-%m-%dT%H:%M:%S.%fZ")
        create_ts_ts_obj = datetime.strptime(actual_ts.create_ts, "%Y-%m-%dT%H:%M:%S.%fZ")

        if self.clearing_ts.startswith("T+"):
            return clearing_ts_obj >= create_ts_ts_obj + timedelta(minutes=30)
        else:
            return clearing_ts_obj >= create_ts_ts_obj

    def __get_parsed_interchange_fee_indicator(self):
        interchange_fee_indicator_mapping = {
            "D": "DEBIT_INTERCHANGE_FEE",
            "C": "CREDIT_INTERCHANGE_FEE"
        }

        return interchange_fee_indicator_mapping.get(self.interchange_fee_indicator)

    @classmethod
    def sanitize_nymcard_transaction(cls, nymcard_transaction):
        return nymcard_transaction

    def __eq__(self, actual_nymcard_transaction):
        # if not isinstance(actual_nymcard_transaction, self.__class__):
        #     return False

        parsed_performed_operation_type = self.__get_performed_operation_type()
        if (
            actual_nymcard_transaction.performed_operation_type
            != parsed_performed_operation_type
        ):
            return False

        if self.clearing_ts is not None and not self.__check_clearing_ts(
            actual_nymcard_transaction
        ):
            return False

        parsed_interchange_fee_indicator = self.__get_parsed_interchange_fee_indicator()
        if actual_nymcard_transaction.interchange_fee_indicator != parsed_interchange_fee_indicator:
            return False

        return (
            actual_nymcard_transaction.id == self.id
            and actual_nymcard_transaction.parent_transaction_id == self.parent_transaction_id
            and actual_nymcard_transaction.sms_clearing_transaction_id
            == self.sms_clearing_transaction_id
            and actual_nymcard_transaction.transaction_timestamp == self.transaction_timestamp
            and actual_nymcard_transaction.network == self.network
            and actual_nymcard_transaction.message_type == self.message_type
            and actual_nymcard_transaction.transaction_type == self.transaction_type
            and actual_nymcard_transaction.transaction_description
            == self.transaction_description
            and actual_nymcard_transaction.transmission_timestamp == self.transmission_timestamp
            and actual_nymcard_transaction.date_time_acquirer == self.date_time_acquirer
            and actual_nymcard_transaction.card_id == self.card_id
            and actual_nymcard_transaction.card_product_id == self.card_product_id
            and actual_nymcard_transaction.card_first6_digits == self.card_first6_digits
            and actual_nymcard_transaction.card_last4_digits == self.card_last4_digits
            and actual_nymcard_transaction.card_expiry_date == self.card_expiry_date
            and actual_nymcard_transaction.user_id == self.user_id
            and actual_nymcard_transaction.acquirer_id == self.acquirer_id
            and actual_nymcard_transaction.merchant_id == self.merchant_id
            and actual_nymcard_transaction.mcc == self.mcc
            and actual_nymcard_transaction.merchant_name == self.merchant_name
            and actual_nymcard_transaction.merchant_city == self.merchant_city
            and actual_nymcard_transaction.merchant_country == self.merchant_country
            and actual_nymcard_transaction.terminal_id == self.terminal_id
            and actual_nymcard_transaction.rrn == self.rrn
            and actual_nymcard_transaction.stan == self.stan
            and actual_nymcard_transaction.network_transaction_id == self.network_transaction_id
            and actual_nymcard_transaction.transaction_amount == self.transaction_amount
            and actual_nymcard_transaction.transaction_currency == self.transaction_currency
            and actual_nymcard_transaction.billing_amount == self.billing_amount
            and actual_nymcard_transaction.billing_currency == self.billing_currency
            and actual_nymcard_transaction.original_transaction_amount
            == self.original_transaction_amount
            and actual_nymcard_transaction.original_billing_amount
            == self.original_billing_amount
            and actual_nymcard_transaction.incremental_transaction
            == self.incremental_transaction
            and actual_nymcard_transaction.is_pre_auth == self.is_pre_auth
            and actual_nymcard_transaction.eci == self.eci
            and actual_nymcard_transaction.card_entry == self.card_entry
            and actual_nymcard_transaction.pos_environment == self.pos_environment
            and actual_nymcard_transaction.pin_present == self.pin_present
            and actual_nymcard_transaction.settlement_status == self.settlement_status
            and actual_nymcard_transaction.moto == self.moto
            and actual_nymcard_transaction.processing_code == self.processing_code
            and actual_nymcard_transaction.three_DS_indicator == self.three_DS_indicator
            and actual_nymcard_transaction.interchange_fee == self.interchange_fee
            and actual_nymcard_transaction.cleared_ts == self.cleared_ts
        )


@dataclasses.dataclass
class TransactionLogDetail:
    transaction_identifier: Optional[str]
    transaction_amount: str
    billing_amount: str

    def get_dict(self):
        transaction_log_detail_dict = {
            "transaction_amount": self.transaction_amount,
            "billing_amount": self.billing_amount,
        }
        # Filtering out fields which are not set
        transaction_log_detail_dict = {
            k: v
            for k, v in transaction_log_detail_dict.items()
            if v is not None and len(str(v)) != 0
        }
        return transaction_log_detail_dict


@dataclasses.dataclass
class TransactionLog:
    transaction_identifier: Optional[str]
    transaction_amount: str
    billing_amount: str

    def get_dict(self):
        transactionLog = {
            "transaction_amount": self.transaction_amount,
            "billing_amount": self.billing_amount,
        }
        # Filtering out fields which are not set
        transactionLog = {
            k: v for k, v in transactionLog.items() if v is not None and len(str(v)) != 0
        }
        return transactionLog


@dataclasses.dataclass
class TransactionLogDTO:
    @dataclasses.dataclass
    class ClearingDTO:
        interchange_fee: float
        interchange_type: str
        clearing_outcome: str

    # Identifiers
    transaction_identifier: Optional[str]
    transaction_id: Optional[str]
    card_id: Optional[str]
    auth_transaction_ids: Optional[str]
    linked_transaction_ids: Optional[str]
    fp_transaction_id: Optional[str]
    bank_deposit_transaction_id: Optional[str]
    # Amounts
    transaction_amount: str
    billing_amount: Optional[str]
    buffered_bill_amount: Optional[str]
    conversion_rate: Optional[str]
    tx_currency_code: Optional[str]
    transaction_currency: Optional[str]
    billing_currency_code: Optional[str]
    billing_currency: Optional[str]
    # Types & Statuses
    transaction_type: str
    transaction_status: str
    clearing: Optional[ClearingDTO]
    release_auth_ts: Optional[str]
    initiated_ts: Optional[str]
    release_type: Optional[str]

    @classmethod
    def sanitize_transaction_log(cls, dto):
        dto.transaction_identifier = None
        dto.linked_transaction_ids = (
            str(list())
            if dto.linked_transaction_ids == '' or dto.linked_transaction_ids is None
            else dto.linked_transaction_ids
        )
        dto.release_type = None if dto.release_type == '' else dto.release_type
        dto.buffered_bill_amount = (
            dto.billing_amount
            if "DEBIT_CLEAR" in dto.transaction_type
            or "CREDIT_CLEAR" in dto.transaction_type
            or dto.tx_currency_code == dto.billing_currency_code
            else round(
                float(dto.billing_amount),
                get_currency_precision(str(dto.billing_currency_code)),
            )
        )
        return dto

    def __eq__(self, actual_dto):
        if not isinstance(actual_dto, self.__class__):
            return False

        if self.fp_transaction_id == 'VALID_UUID' and not is_valid_fp_tx_id(
            actual_dto.fp_transaction_id
        ):
            return False

        if (
            self.release_auth_ts != actual_dto.release_auth_ts
            and not self.release_auth_ts.startswith('T+')
            and datetime.fromisoformat(actual_dto.initiated_ts[:-1] + '+00:00')
            + timedelta(days=int(self.release_auth_ts.split('+')[1]))
            == datetime.fromisoformat(actual_dto.release_auth_ts[:-1] + '+00:00')
        ):
            return False

        if (
            actual_dto.linked_transaction_ids == '[]'
            and self.linked_transaction_ids != actual_dto.linked_transaction_ids
        ):
            return False

        return (
            self.transaction_id == actual_dto.transaction_id
            and self.linked_transaction_ids == actual_dto.linked_transaction_ids
            and self.card_id == actual_dto.card_id
            and float(self.transaction_amount) == float(actual_dto.transaction_amount)
            and float(self.billing_amount) == float(actual_dto.billing_amount)
            and float(self.buffered_bill_amount) == float(actual_dto.buffered_bill_amount)
            and self.transaction_currency == actual_dto.transaction_currency
            and self.billing_currency == actual_dto.billing_currency
            and self.transaction_type == actual_dto.transaction_type
            and self.transaction_status == actual_dto.transaction_status
            and self.clearing == actual_dto.clearing
            and self.release_type == actual_dto.release_type
        )


@dataclasses.dataclass
class TransactionLogDetailDTO:
    # Identifiers
    transaction_identifier: Optional[str]
    transaction_id: Optional[str]
    idempotency_key: Optional[str]
    # Amounts
    transaction_amount: str
    billing_amount: str
    buffered_billing_amount: Optional[str]
    delta_buffered_bill_amount: Optional[str]
    tx_currency_code: Optional[str]
    billing_currency_code: Optional[str]
    conversion_rate: Optional[str]
    cleared_ts: Optional[str]
    # Transaction statuses
    transaction_type: Optional[str]
    transaction_status: Optional[str]

    @classmethod
    def sanitize_transaction_log_detail(cls, dto):
        dto.transaction_identifier = None
        dto.idempotency_key = None if dto.idempotency_key == '' else dto.idempotency_key
        dto.buffered_billing_amount = (
            dto.billing_amount
            if "DEBIT_CLEAR" in dto.transaction_type
            or "CREDIT_CLEAR" in dto.transaction_type
            or dto.tx_currency_code == dto.billing_currency_code
            else round(
                float(dto.billing_amount),
                get_currency_precision(str(dto.billing_currency_code)),
            )
        )

        if dto.transaction_type == "DEBIT_CLEAR":
            dto.conversion_rate = 0
        elif dto.transaction_amount != '0':
            dto.conversion_rate = str(
                round_down(float(dto.billing_amount) / float(dto.transaction_amount), 8)
            )
        else:
            dto.conversion_rate = 1
        return dto

    def __eq__(self, actual_dto):
        if not isinstance(actual_dto, self.__class__):
            return False

        if self.cleared_ts is not None and datetime.fromisoformat(
            actual_dto.cleared_ts[:-1] + '+00:00'
        ):
            return False

        return (
            self.transaction_id == actual_dto.transaction_id
            and self.idempotency_key == actual_dto.idempotency_key
            and float(self.transaction_amount) == float(actual_dto.transaction_amount)
            and float(self.billing_amount) == float(actual_dto.billing_amount)
            and float(self.buffered_billing_amount) == float(actual_dto.buffered_billing_amount)
            and self.transaction_type == actual_dto.transaction_type
            and self.transaction_status == actual_dto.transaction_status
        )
