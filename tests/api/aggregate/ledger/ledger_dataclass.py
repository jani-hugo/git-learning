from typing import Optional
import dataclasses
import json


@dataclasses.dataclass
class CreateLedgerDTO:
    ledger_id: Optional[str]
    identifier: Optional[str]
    profile_id: Optional[str]
    profile_type: Optional[str]
    holding_type: str
    initial_units: float
    can_be_negative: bool
    metadata: dict

    # Only add values that would be sent to create object using REST call
    def get_dict(self):
        return {
            "profile_id": self.profile_id,
            "profile_type": self.profile_type,
            "holding_type": self.holding_type,
            "initial_units": self.initial_units,
            "can_be_negative": self.can_be_negative,
            "metadata": self.metadata,
        }


@dataclasses.dataclass
class LedgerDTO(object):
    ledger_id: Optional[str]
    identifier: Optional[str]
    holding_type: str
    total_units: float
    available_units: float
    avg_source_rate_per_unit: float
    avg_destination_rate_per_unit: float
    can_be_negative: bool
    metadata: dict

    @classmethod
    def sanitize_ledger_dto(cls, ledger_dto):
        ledger_dto.identifier = None
        ledger_dto.ledger_id = None
        return ledger_dto


@dataclasses.dataclass
class CreateLedgerTransactionDTO(object):
    identifier: Optional[str]
    transaction_id: Optional[str]
    from_ledger_id: str
    to_ledger_id: str
    units: float
    source_rate_per_unit: float
    destination_rate_per_unit: float
    status: str
    external_transaction_id: str
    reference_data: Optional[str]

    def get_dict(self):
        return {
            "from_ledger_id": self.from_ledger_id,
            "to_ledger_id": self.to_ledger_id,
            "units": self.units,
            "source_rate_per_unit": self.source_rate_per_unit,
            "destination_rate_per_unit": self.destination_rate_per_unit,
            "status": self.status,
            "external_transaction_id": self.external_transaction_id,
            "reference_data": self.reference_data,
        }


@dataclasses.dataclass
class LedgerTransactionDTO(object):
    identifier: Optional[str]
    transaction_id: Optional[str]
    from_ledger_id: str
    to_ledger_id: str
    units: float
    source_rate_per_unit: float
    destination_rate_per_unit: float
    transaction_status: str
    external_transaction_id: str
    reference_data: Optional[str]
    settled_ts: Optional[str]

    @classmethod
    def sanitize_ledger_dto(cls, ledger_transaction_dto):
        ledger_transaction_dto.identifier = None
        ledger_transaction_dto.transaction_id = None
        ledger_transaction_dto.settled_ts = None
        return ledger_transaction_dto


@dataclasses.dataclass
class SplitTransactionRequestDTO:
    identifier: Optional[str]
    transaction_id: str
    original_amount: float
    split_txn: str
    idempotency: str

    def get_dict(self):
        return {
            "transaction_id": self.transaction_id,
            "original_amount": self.original_amount,
            "split_txn": json.loads(self.split_txn),
            "idempotency": self.idempotency,
        }


@dataclasses.dataclass
class UpdateTransactionRequestDTO:
    identifier: Optional[str]
    transaction_id: str
    update_amount: float
    external_transaction_id: str
    acquire_available_balance: bool
    status: str

    def get_dict(self):
        return {
            "transaction_id": self.transaction_id,
            "update_amount": self.update_amount,
            "external_transaction_id": self.external_transaction_id,
            "acquire_available_balance": self.acquire_available_balance,
            "status": self.status,
        }


@dataclasses.dataclass
class MergeLedgerTransactionRequestDTO:
    transaction_id: list[str]
    external_transaction_id: str

    def get_dict(self):
        return {
            "transaction_id": self.transaction_id,
            "external_transaction_id": self.external_transaction_id,
        }
