import dataclasses
from datetime import datetime
from typing import Optional


@dataclasses.dataclass
class DevDepositRequestDTO:
    account_type: Optional[str]
    amount: Optional[float]
    currency: Optional[str]
    txn_mode: Optional[str]

    def get_dict(self):
        return {
            "account_type": self.account_type,
            "amount": self.amount,
            "currency": self.currency,
            "txn_mode": self.txn_mode,
        }


@dataclasses.dataclass
class ProductDTO:
    product_id: Optional[str]
    product_code: Optional[str]
    product_name: Optional[str]
    product_class: Optional[str]
    product_type: Optional[str]
    profile_type: Optional[str]
    product_category: Optional[str]
    description: Optional[str]
    param_group: Optional[str]

    def get_dict(self, product_code):
        return {
            "product_id": self.product_id,
            "product_name": self.product_name,
            "product_type": self.product_type,
            "description": self.description,
            "product_code": product_code,
            "product_class": self.product_class,
            "profile_type": self.profile_type,
            "product_category": self.product_category,
            "param_group": self.param_group,
        }


@dataclasses.dataclass
class ProductIdDTO:
    product_id: Optional[str]
    expected_status_code: Optional[str]

    def get_dict(self):
        return {"product_id": self.product_id, "status_code": self.expected_status_code}


@dataclasses.dataclass
class UpdateProductDTO:
    product_id: str
    product_code: Optional[str] = None
    product_name: Optional[str] = None
    product_description: Optional[str] = None
    product_class: Optional[str] = None
    profile_type: Optional[str] = None
    param_group: Optional[str] = None
    expected_status_code: Optional[str] = None

    def get_dict(self):
        return {k: v for k, v in self.__dict__.items() if v is not None}


@dataclasses.dataclass
class CreateAccountRequestDTO:
    end_customer_profile_id: Optional[str]
    account_id: Optional[str]
    product_id: Optional[str]
    country: Optional[str]
    currency: Optional[str]
    approved_limit: Optional[float]

    # Only add values that would be sent to create object using REST call
    def get_dict(self):
        return {
            "end_customer_profile_id": self.end_customer_profile_id,
            "product_id": self.product_id,
            "currency": self.currency,
            "country": self.country,
            "approved_limit": self.approved_limit,
        }


@dataclasses.dataclass
class AttachCardRequest:
    end_customer_profile_id: Optional[str]
    account_id: Optional[str]


@dataclasses.dataclass
class TransactionRequest:
    transaction_id: str
    account_id: str
    advice: bool
    currency: str
    transaction_amount: float
    metadata: dict
    status_code: str
    status: str

    def get_dict(self, credit_account_id, sub_txn_type, card_txn_type=None):
        data = {
            "credit_account_id": credit_account_id,
            "amount": self.transaction_amount,
            "currency": self.currency,
            "purpose": "random_str_here",
            "metadata": self.metadata,
            "sub_txn_type": sub_txn_type,
        }

        if card_txn_type is not None:
            data["card_transaction_type"] = card_txn_type

        return data


@dataclasses.dataclass
class ClearTransactionRequest:
    transaction_id: str
    group_id: str
    clearing_amount: float
    status_code: str
    status: str

    # Only add values that would be sent to create object using REST call
    def get_dict(self):
        return {
            "group_id": self.group_id,
            "amount": self.clearing_amount,
            "metadata": {"some-random": "value"},
        }


@dataclasses.dataclass
class UpdateTransactionRequest:
    transaction_id: str
    account_id: str
    advice: bool
    updated_txn_amount: float
    status_code: str
    status: str

    # Only add values that would be sent to create object using REST call
    def get_dict(self):
        return {"updated_amount": self.updated_txn_amount}


@dataclasses.dataclass
class RevertTransactionRequest:
    transaction_id: str
    status_code: str
    status: str
    refund: bool


@dataclasses.dataclass
class ReconcileClearingRequest:
    group_id: str
    total_amount: float
    txn_count: int


@dataclasses.dataclass
class SendRequest:
    group_id: str
    total_amount: float
    status_code: str
    transaction_status: str

    def get_dict(self):
        return {"total_amount": self.total_amount}


@dataclasses.dataclass
class AuthorizationDTO:
    transaction_id: str
    message_type: str
    account_id: str
    amount: float
    currency: str
    metadata: dict
    status_code: str
    status: str

    def get_dict(self, credit_account_id):
        return {
            "account_id": credit_account_id,
            "message_type": self.message_type,
            "amount": self.amount,
            "currency": self.currency,
            "metadata": self.metadata,
        }


@dataclasses.dataclass
class AuthorizationUpdateDTO:
    transaction_id: str
    message_type: str
    account_id: str
    amount: float
    metadata: dict
    status_code: str
    status: str

    def get_dict(self, credit_account_id, transaction_id):
        return {
            "account_id": credit_account_id,
            "transaction_id": transaction_id,
            "message_type": self.message_type,
            "amount": self.amount,
            "metadata": self.metadata,
        }


@dataclasses.dataclass
class ClearingRequestDTO:
    transaction_id: str
    clearing_group_id: str
    amount: float
    status_code: str
    status: str

    # Only add values that would be sent to create object using REST call
    def get_dict(self):
        return {
            "transaction_id: str": self.transaction_id,
            "clearing_group_id": self.clearing_group_id,
            "amount": self.amount,
        }


@dataclasses.dataclass
class ContextParams:
    customer_profile_id: str
    product_id: str
    end_customer_profile_id: str


@dataclasses.dataclass
class DevTransaction:
    txn_time: str
    txn_type: str
    txn_code: str
    amount: float

    def get_dict(self):
        print(self.txn_time + datetime.now().strftime("T%H:%M:%S.%fZ"))
        return {
            "txn_time": self.txn_time + datetime.now().strftime("T%H:%M:%S.%fZ"),
            "txn_type": self.txn_type,
            "txn_code": self.txn_code,
            "amount": self.amount,
            "category": 1,
        }


@dataclasses.dataclass
class TransactionRequestDTO:
    credit_account_id: str
    amount: float
    txn_code: str
    currency: str
    receiver: Optional[str]

    def get_dict(self, receiver, account_id):
        return {
            "credit_account_id": account_id,
            "amount": self.amount,
            "txn_code": self.txn_code,
            "currency": self.currency,
            "receiver": receiver,
        }
