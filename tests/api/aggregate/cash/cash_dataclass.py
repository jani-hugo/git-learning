import dataclasses
from dataclasses import field
from enum import Enum
from typing import Optional, List, Dict


@dataclasses.dataclass
class CreateCustomerProfileAccountDTO:
    identifier: Optional[str]
    account_id: Optional[str]
    account_type_id: Optional[str]
    customer_profile_id: str
    provider_id: Optional[str]
    product_id: Optional[str]
    currency: str
    country: str
    in_trust: bool
    is_overdraft_allowed: Optional[bool]
    on_behalf_of: Optional[str]
    metadata: Optional[dict]
    cash_account_id: Optional[str] = ""

    # Only add values that would be sent to create an object using REST call
    def get_dict(self):
        return {
            "customer_profile_id": self.customer_profile_id,
            "provider_id": self.provider_id,
            "account_type_id": self.account_type_id,
            "currency": self.currency,
            "product_id": self.product_id,
            "country": self.country,
            "in_trust": self.in_trust,
            "is_overdraft_allowed": self.is_overdraft_allowed,
            "on_behalf_of": self.on_behalf_of,
            "metadata": self.metadata,
            "cash_account_id": self.cash_account_id,
        }


@dataclasses.dataclass
class ProductRequestDTO:
    identifier: Optional[str]
    product_code: Optional[str]
    product_name: Optional[str]
    provider_id: Optional[str]
    profile_type: str
    product_class: str
    product_type: str
    currency: Optional[str]
    country: Optional[str]
    is_overdraft_allowed: Optional[bool]
    balance_policy_limit: Optional[float]
    balance_policy_type: Optional[str]
    account_type: Optional[str]
    num_of_active_account: Optional[int] = None

    # Only add values that would be sent to create an object using REST call
    def get_dict(self):
        result = {
            "product_code": self.product_code,
            "product_name": self.product_name,
            "profile_type": self.profile_type,
            "product_class": self.product_class,
            "product_type": self.product_type,
            "currency": self.currency,
            "country": self.country,
            "is_overdraft_allowed": self.is_overdraft_allowed,
            "account_type": self.account_type,
            "provider_id": self.provider_id,
        }
        if self.num_of_active_account:
            result["num_of_active_account"] = self.num_of_active_account
        return result


@dataclasses.dataclass
class CashAccountRequestDTO:
    cash_account_product_id: str
    end_customer_profile_id: Optional[str] = ""

    def get_dict(self):
        return {
            "cash_account_product_id": self.cash_account_product_id,
            "end_customer_profile_id": self.end_customer_profile_id,
        }


@dataclasses.dataclass
class SGBank:
    swift_bic: str
    iban: Optional[str]
    account_number: Optional[str]


@dataclasses.dataclass
class BankCodeDetailsDTO:
    sg_code_details: Optional[SGBank]


@dataclasses.dataclass
class BankAccountDetailsDTO:
    account_number: Optional[str]
    account_holder_name: Optional[str]
    bank_name: str
    currency: str
    country: str
    code_details: Optional[BankCodeDetailsDTO]


@dataclasses.dataclass
class AccountDTO:
    identifier: Optional[str]
    account_id: Optional[str]
    customer_profile_id: Optional[str]
    end_customer_profile_id: Optional[str]
    account_status: str
    account_details: BankAccountDetailsDTO
    metadata: Optional[dict]

    @classmethod
    def sanitize_bank_account_dto(cls, expected_bank_acc_dto):
        other = dataclasses.replace(expected_bank_acc_dto)
        other.identifier = None
        other.account_id = None
        other.on_behalf_of = None
        other.account_details.account_holder_name = None
        other.account_details.code_details = None
        other.account_details.account_number = None
        return other


@dataclasses.dataclass
class CreateEndCustomerProfileAccountDTO:
    identifier: Optional[str]
    account_id: Optional[str]
    customer_profile_id: Optional[str]
    end_customer_profile_id: Optional[str]
    provider_id: Optional[str]
    product_id: Optional[str]
    account_type_id: Optional[str]
    currency: str
    country: str
    in_trust: bool
    is_overdraft_allowed: Optional[bool]
    on_behalf_of: Optional[str]
    metadata: Optional[dict]
    cash_account_id: Optional[str] = ""

    # Only add values that would be sent to create object using REST call
    def get_dict(self):
        return {
            "customer_profile_id": self.customer_profile_id,
            "end_customer_profile_id": self.end_customer_profile_id,
            "provider_id": self.provider_id,
            "product_id": self.product_id,
            "account_type_id": self.account_type_id,
            "currency": self.currency,
            "country": self.country,
            "in_trust": self.in_trust,
            "is_overdraft_allowed": self.is_overdraft_allowed,
            "on_behalf_of": self.on_behalf_of,
            "metadata": self.metadata,
            "cash_account_id": self.cash_account_id,
        }


@dataclasses.dataclass
class CreatePlatformAccountDTO:
    identifier: Optional[str]
    account_id: Optional[str]
    profile_id: str
    profile_type: str
    region: str
    created_by: str
    currency: str
    metadata: Optional[dict]

    def get_dict(self):
        return {
            "profile_id": self.profile_id,
            "profile_type": self.profile_type,
            "region": self.region,
            "created_by": self.created_by,
            "currency": self.currency,
            "metadata": self.metadata,
        }


@dataclasses.dataclass
class Address:
    address_line_1: str
    address_line_2: str
    address_line_3: str
    address_line_4: str
    city: str
    state: str
    country: Optional[str]
    country_code: str
    local_code: str


@dataclasses.dataclass
class BeneficiaryDataTableWithBankAccountDetails:
    identifier: str
    beneficiary_name: str
    address: Address
    beneficiary_email: str
    is_hidden: bool
    metadata: dict
    is_overdraft_allowed: bool
    beneficiary_account_details: BankAccountDetailsDTO
    overdraft_funding_account_id: Optional[str]


@dataclasses.dataclass
class BeneficiaryDataTable:
    identifier: str
    beneficiary_name: str
    address: Address
    beneficiary_email: str
    is_hidden: bool
    metadata: dict
    is_overdraft_allowed: bool
    overdraft_funding_account_id: Optional[str]


@dataclasses.dataclass
class BeneficiaryRequestDTO:
    account_id: str
    beneficiary_name: str
    beneficiary_account_details: BankAccountDetailsDTO
    address: Address
    beneficiary_email: str
    is_hidden: bool
    metadata: dict
    is_overdraft_allowed: Optional[bool]
    overdraft_funding_account_id: Optional[str]

    def get_dict(self):
        beneficiary_request_dict = dataclasses.asdict(self)
        return beneficiary_request_dict


@dataclasses.dataclass
class BeneficiaryRequestDTOs:
    beneficiaries: list[BeneficiaryRequestDTO]


@dataclasses.dataclass
class AttachCardRequestDTO:
    account_id: str
    customer_profile_id: str
    is_overdraft_allowed: bool
    in_trust: bool
    on_behalf_of: Optional[str]

    def get_dict(self):
        return {
            "account_id": self.account_id,
            "is_overdraft_allowed": self.is_overdraft_allowed,
        }


@dataclasses.dataclass
class UpdateAccountDTO:
    account_id: str
    customer_profile_id: str
    is_overdraft_allowed: bool

    def get_dict(self):
        return {
            "account_id": self.account_id,
            "is_overdraft_allowed": self.is_overdraft_allowed,
        }


@dataclasses.dataclass
class SgBankDetails:
    account_number: str
    swift_bic: str


@dataclasses.dataclass
class TransferOutCodeDetails:
    sg_bank_details: SgBankDetails


@dataclasses.dataclass
class TransferOutAccountDetails:
    account_holder_name: str
    country: str
    currency: str
    code_details: TransferOutCodeDetails

    def get_dict(self):
        return {
            "account_holder_name": self.account_holder_name,
            "country": self.country,
            "currency": self.currency,
            "code_details": {
                "sg_bank_details": {
                    "account_number": self.code_details.sg_bank_details.account_number,
                    "swift_bic": self.code_details.sg_bank_details.swift_bic,
                }
            },
        }


@dataclasses.dataclass
class TransactionInitiationRequestDTO:
    identifier: str
    account_id: str
    amount: float
    purpose: str
    is_overdraft_allowed: bool
    metadata: str
    sub_txn_type: str

    def get_dict(self):
        return {
            "account_id": self.account_id,
            "amount": self.amount,
            "purpose": self.purpose,
            "is_overdraft_allowed": self.is_overdraft_allowed,
            "metadata": self.metadata,
            "sub_txn_type": self.sub_txn_type,
        }


@dataclasses.dataclass
class Sender:
    account_number: str
    bank_name: str
    bank_code: str
    bank_country: str
    name: str

    def get_dict(self):
        return {
            "account_number": self.account_number,
            "bank_name": self.bank_name,
            "bank_code": self.bank_code,
            "bank_country": self.bank_country,
            "name": self.name,
        }


@dataclasses.dataclass
class DepositRequestDTO:
    identifier: str
    account_id: str
    amount: float
    purpose: str
    metadata: dict
    sender_details: Sender
    currency: str

    def get_dict(self):
        return {
            "account_id": self.account_id,
            "amount": self.amount,
            "purpose": self.purpose,
            "metadata": self.metadata,
            "sender_details": self.sender_details.get_dict(),
            "currency": self.currency,
        }


@dataclasses.dataclass
class InitiateTransactionRequestDTO:
    identifier: str
    amount: float
    currency: str
    purpose: str
    is_overdraft_allowed: bool
    metadata: dict
    sub_txn_type: str
    customer_profile_id: str
    idempotency_key: Optional[str]
    transfer_out_details: Optional[TransferOutAccountDetails] = None
    account_id: Optional[str] = ""
    cash_account_id: Optional[str] = ""

    def get_dict(self):
        result = {
            "amount": self.amount,
            "currency": self.currency,
            "purpose": self.purpose,
            "is_overdraft_allowed": self.is_overdraft_allowed,
            "metadata": self.metadata,
            "sub_txn_type": self.sub_txn_type,
            "transfer_out_details": self.transfer_out_details
        }
        if self.account_id:
            result["account_id"] = self.account_id
        else:
            result["cash_account_id"] = self.cash_account_id
        return result


@dataclasses.dataclass
class UpdateTransactionRequestDTO:
    transaction_id: str
    amount: float
    is_overdraft_allowed: bool
    metadata: dict
    customer_profile_id: str

    def get_dict(self):
        return {
            "transaction_id": self.transaction_id,
            "amount": self.amount,
            "is_overdraft_allowed": self.is_overdraft_allowed,
            "metadata": self.metadata,
        }


@dataclasses.dataclass
class CancelTransactionRequestDTO:
    transaction_id: str
    metadata: dict
    purpose: str
    customer_profile_id: str

    def get_dict(self):
        return {
            "transaction_id": self.transaction_id,
            "purpose": self.purpose,
            "metadata": self.metadata,
        }


@dataclasses.dataclass
class CloseTransactionRequestDTO:
    transaction_id: str
    metadata: dict
    purpose: str
    customer_profile_id: str

    def get_dict(self):
        return {
            "transaction_id": self.transaction_id,
            "purpose": self.purpose,
            "metadata": self.metadata,
        }


@dataclasses.dataclass
class SettleTransactionRequestDTO:
    transaction_id: str
    amount: float
    transaction_rail: Optional[str]
    is_overdraft_allowed: bool
    metadata: dict
    overdraft_funding_account_id: Optional[str]
    customer_profile_id: str
    idempotency_key: Optional[str]

    def get_dict(self):
        return {
            "transaction_id": self.transaction_id,
            "amount": self.amount,
            "transaction_rail": self.transaction_rail,
            "is_overdraft_allowed": self.is_overdraft_allowed,
            "metadata": self.metadata,
            "overdraft_funding_account_id": self.overdraft_funding_account_id,
            "purpose": "Integration_Test",
        }


@dataclasses.dataclass
class BeneficiaryTransactionRequestDTO:
    identifier: str
    customer_profile_id: str
    account_id: str
    amount: float
    purpose: str
    transaction_rail: str
    is_overdraft_allowed: bool
    overdraft_funding_account_id: str
    metadata: dict
    currency: str

    def get_dict(self):
        result = {
            "account_id": self.account_id,
            "amount": self.amount,
            "purpose": self.purpose,
            "transaction_rail": self.transaction_rail,
            "is_overdraft_allowed": self.is_overdraft_allowed,
            "overdraft_funding_account_id": self.overdraft_funding_account_id,
            "metadata": self.metadata,
            "currency": self.currency,
        }


@dataclasses.dataclass
class RefundRequestDTO:
    original_transaction_id: str
    customer_profile_id: str
    refund_amount: float
    purpose: str
    metadata: dict

    def get_dict(self):
        return {
            "refund_amount": self.refund_amount,
            "original_transaction_id": self.original_transaction_id,
            "purpose": self.purpose,
            "metadata": self.metadata,
        }


@dataclasses.dataclass
class DBSHeader:
    msgId: str
    orgId: str
    ctry: str
    timeStamp: str

    def get_dict(self):
        return {
            "msg_id": self.msgId,
            "org_id": self.orgId,
            "ctry": self.ctry,
            "timeStamp": self.timeStamp,
        }


@dataclasses.dataclass
class SenderParty:
    name: Optional[str]
    account_no: Optional[str]
    sender_bank_id: Optional[str]
    sender_bank_name: Optional[str]
    sender_bank_code: Optional[str]
    sender_branch_code: Optional[str]

    def get_dict(self):
        return {"name": self.name, "sender_bank_id": self.sender_bank_id}


@dataclasses.dataclass
class CreditAmtDetails:
    txn_ccy: str
    txn_amt: float

    def get_dict(self):
        return {"txn_ccy": self.txn_ccy, "txn_amt": self.txn_amt}


@dataclasses.dataclass
class ICNRmtInf:
    payment_details: Optional[str]
    addtl_inf: Optional[str]
    purpose_code: Optional[str]

    def get_dict(self):
        return {
            "payment_details": self.payment_details,
            "addtl_inf": self.addtl_inf,
            "purpose_code": self.purpose_code,
        }


@dataclasses.dataclass
class ICNReceivingParty:
    name: Optional[str]
    account_no: str
    virtual_account_no: Optional[str]
    virtual_account_name: Optional[str]

    def get_dict(self):
        return {"name": self.name, "account_no": self.account_no}


@dataclasses.dataclass
class ICNTxnInfo:
    txn_type: str
    customer_reference: str
    txn_ref_id: str
    txn_date: str
    value_dt: str
    receiving_party: ICNReceivingParty
    amt_dtls: CreditAmtDetails
    sender_party: Optional[SenderParty]
    rmt_inf: Optional[ICNRmtInf]

    def get_dict(self):
        return {
            "txnType": self.txn_type,
            "customerReference": self.customer_reference,
            "txnRefId": self.txn_ref_id,
            "txnDate": self.txn_date,
            "valueDt": self.value_dt,
            "receivingParty": self.receiving_party.get_dict(),
            "amtDtls": self.amt_dtls.get_dict(),
            "senderParty": self.sender_party.get_dict(),
            "rmtInf": self.rmt_inf,
        }


@dataclasses.dataclass
class InstantCreditNotification:
    identifier: str
    header: DBSHeader
    txn_info: ICNTxnInfo
    customer_profile_id: str

    def get_dict(self):
        return {"header": self.header.get_dict(), "txnInfo": self.txn_info.get_dict()}


@dataclasses.dataclass
class DevDepositRequestDTO:
    identifier: str
    account_id: str
    amount: str
    purpose: str
    payment_type: str
    currency: str
    metadata: dict
    customer_profile_id: str
    transaction_id: Optional[str]

    def get_dict(self):
        return {
            "account_id": self.account_id,
            "amount": self.amount,
            "purpose": self.purpose,
            "payment_type": self.payment_type,
            "currency": self.currency,
            "metadata": self.metadata,
        }


@dataclasses.dataclass
class CashDevDepositRequestDTO:
    identifier: str
    account_id: Optional[str]
    amount: Optional[float]
    purpose: str
    currency: str
    transaction_rail: Optional[str]
    metadata: Optional[dict]
    customer_profile_id: Optional[str]

    def get_dict(self):
        return {
            "account_id": self.account_id,
            "amount": self.amount,
            "purpose": self.purpose,
            "currency": self.currency,
            "transaction_rail": self.transaction_rail,
            "metadata": self.metadata
        }


@dataclasses.dataclass
class ICNRmtInf:
    payment_details: Optional[str]
    addtl_inf: Optional[str]
    purpose_code: Optional[str]

    def get_dict(self):
        return {
            "payment_details": self.payment_details,
            "addtl_inf": self.addtl_inf,
            "purpose_code": self.purpose_code,
        }


@dataclasses.dataclass
class IDNReceivingParty:
    name: Optional[str]
    account_no: str
    virtual_account_no: Optional[str]
    virtual_account_name: Optional[str]

    def get_dict(self):
        return {"name": self.name, "account_no": self.account_no}


@dataclasses.dataclass
class IDNTxnInfo:
    txn_type: str
    customer_reference: str
    txn_ref_id: str
    txn_date: str
    value_dt: str
    receiving_party: IDNReceivingParty
    amt_dtls: CreditAmtDetails
    sender_party: Optional[SenderParty]
    rmt_inf: Optional[ICNRmtInf]

    def get_dict(self):
        return {
            "txnType": self.txn_type,
            "customerReference": self.customer_reference,
            "txnRefId": self.txn_ref_id,
            "txnDate": self.txn_date,
            "valueDt": self.value_dt,
            "receivingParty": self.receiving_party.get_dict(),
            "amtDtls": self.amt_dtls.get_dict(),
            "senderParty": self.sender_party.get_dict(),
            "rmtInf": self.rmt_inf,
        }


@dataclasses.dataclass
class IntraDayCreditNotification:
    identifier: str
    header: DBSHeader
    txn_info: IDNTxnInfo
    customer_profile_id: str

    def get_dict(self):
        return {"header": self.header.get_dict(), "txnInfo": self.txn_info.get_dict()}


# Enums based on your protobuf definitions
@dataclasses.dataclass
class Class(Enum):
    CLASS_UNKNOWN = 0
    STANDARD = 1
    SHARIAH = 2


@dataclasses.dataclass
class ProductType(Enum):
    PRODUCT_TYPE_UNKNOWN = 0
    CASH_ACCOUNT = 1


# ParamRequestDTO.Value nested types
@dataclasses.dataclass
class IntegerList:
    value: int


@dataclasses.dataclass
class IntegerRange:
    value: int


@dataclasses.dataclass
class Integer:
    value: int

    def to_dict(self):
        return {"value": self.value}


@dataclasses.dataclass
class RangeIntegers:
    min_value: int
    max_value: int


@dataclasses.dataclass
class DoubleList:
    value: float

    def to_dict(self):
        return {"value": self.value}


@dataclasses.dataclass
class DoubleRange:
    value: float


@dataclasses.dataclass
class Double:
    value: float

    def to_dict(self):
        return {"value": self.value}


@dataclasses.dataclass
class StringList:
    value: str

    def to_dict(self):
        return {"value": self.value}


@dataclasses.dataclass
class String:
    value: str


@dataclasses.dataclass
class Boolean:
    value: bool

    def to_dict(self):
        return {"value": self.value}


@dataclasses.dataclass
class MultiInteger:
    values: List[int]


@dataclasses.dataclass
class MultiDouble:
    values: List[float]


@dataclasses.dataclass
class MultiString:
    values: List[str]

    def to_dict(self):
        return {"values": self.values}


@dataclasses.dataclass
class Timestamp:
    value: str


@dataclasses.dataclass
class Value:
    integer_list_value: Optional[IntegerList] = None
    integer_range_value: Optional[IntegerRange] = None
    integer_value: Optional[Integer] = None
    range_integers_value: Optional[RangeIntegers] = None
    double_list_value: Optional[DoubleList] = None
    double_range_value: Optional[DoubleRange] = None
    double_value: Optional[Double] = None
    string_list_value: Optional[StringList] = None
    string_value: Optional[String] = None
    boolean_value: Optional[Boolean] = None
    multi_integer_value: Optional[MultiInteger] = None
    multi_double_value: Optional[MultiDouble] = None
    multi_string_value: Optional[MultiString] = None
    timestamp_value: Optional[Timestamp] = None


@dataclasses.dataclass
class ParamRequestDTO:
    param_name: str
    value: Value
    metadata: Optional[Dict[str, str]] = field(default_factory=dict)

    def to_dict(self):
        def clean_dict(d):
            if isinstance(d, dict):
                return {k: clean_dict(v) for k, v in d.items() if v is not None}
            elif isinstance(d, list):
                return [clean_dict(i) for i in d if i is not None]
            elif hasattr(d, "to_dict"):
                return d.to_dict()
            elif hasattr(d, "value"):
                return d.value
            return d

        # Convert the ParamRequestDTO to a dictionary and clean None values
        return clean_dict(
            {
                "param_name": self.param_name,
                "value": clean_dict(
                    self.value.__dict__
                ),  # Clean nested Value dataclass
                "metadata": self.metadata,
            }
        )

@dataclasses.dataclass
class PayRequestDTO:
    amount: float
    purpose: str
    currency: str
    push_overdraft: bool
    source_account_id: Optional[String] = ''
    transfer_out_account_details: Optional[TransferOutAccountDetails] = None

    def get_dict(self):
        return {
            "source_account_id": self.source_account_id,
            "amount": self.amount,
            "purpose": self.purpose,
            "currency": self.currency,
            "push_overdraft": self.push_overdraft,
            "transfer_out_account_details": self.transfer_out_account_details
        }

@dataclasses.dataclass
class FloatAccountResponseDTO:
    account_id: str

    def get_dict(self):
        return {
            "account_id": self.account_id
        }

@dataclasses.dataclass
class ApplyFeeRequestDTO:
    amount: float
    currency: str
    push_overdraft: bool
    account_id: Optional[str]

    def get_dict(self):
        return {
            "amount": self.amount,
            "currency": self.currency,
            "push_overdraft": self.push_overdraft,
            "account_id": self.account_id
        }
