import dataclasses
from datetime import datetime
import json
from enum import Enum
from typing import Optional

import distribute.app.app_helper as ah

# non prod
# hugosave_profile_id = "375d0aa6-dfe8-4e3d-8a0d-5d6dece088bc"

# dev
hugosave_profile_id = "07651956-706a-47f3-ac69-595b26cd60f8"


@dataclasses.dataclass
class OpenAccountDTO:
    user_profile_identifier: str
    legal_name: str
    name: Optional[str]
    email: str
    phone_number: str
    referral_code: Optional[str]
    status: str
    prefix_ph_num: Optional[str]
    org_id: Optional[str]

    def get_dict(self):
        return {
            "legal_name": self.legal_name,
            "name": self.name,
            "email": self.email,
            "phone_number": self.phone_number,
            "referral_code": self.referral_code,
            "prefix_ph_num": self.prefix_ph_num,
        }


@dataclasses.dataclass
class UserStatusDTO:
    user_profile_identifier: str
    status: str


@dataclasses.dataclass
class CreateMapDTO:
    user_profile_identifier: str
    name: str
    asset_allocation_details: str
    allocation_type: str
    goal_date: str
    goal_amount: float

    def get_dict(self):
        asset_allocation_details = json.loads(self.asset_allocation_details)
        asset_allocation_details = [
            {**a, "asset_id": ah.asset_ids[a["asset_id"]]} for a in asset_allocation_details
        ]

        return {
            "name": ah.get_uuid() if self.name == "random" else self.name,
            "asset_allocation_details": asset_allocation_details,
            "allocation_type": self.allocation_type,
            "goal_date": self.goal_date,
            "goal_amount": self.goal_amount,
        }


@dataclasses.dataclass
class InvestMapDTO:
    user_profile_identifier: str
    transaction_amount: float
    investment_amount: float
    fee_amount: float
    status_code: Optional[str]
    invalid_map: Optional[str]

    def get_dict(self):
        return {
            "transaction_amount": self.transaction_amount,
            "investment_amount": self.investment_amount,
            "fee_amount": self.fee_amount,
            "asset_rates": [],
        }


@dataclasses.dataclass
class WithdrawMapDTO:
    user_profile_identifier: str
    transaction_amount: float
    withdraw_amount: float
    fee_amount: float
    status_code: Optional[str]
    invalid_map: Optional[str]

    def get_dict(self):
        return {
            "transaction_amount": self.transaction_amount,
            "withdraw_amount": self.withdraw_amount,
            "fee_amount": self.fee_amount,
            "asset_rates": [],
        }


@dataclasses.dataclass
class UpdateMapDTO:
    user_profile_identifier: str
    name: str
    goal_date: str
    goal_amount: float
    invalid_map: Optional[str]
    status_code: str

    def get_dict(self):
        return {"name": self.name, "goal_date": self.goal_date, "goal_amount": self.goal_amount}


@dataclasses.dataclass
class ScheduleMapInvest:
    map_id: str
    map_name: str
    map_type: str
    amount: str
    units: float
    payee_account_id: str
    map_category: str
    map_goal_amount: Optional[float]
    map_invested_amount: float

    def get_dict(self):
        return {
            "map_id": self.map_id,
            "map_name": self.map_name,
            "map_type": self.map_type,
            "amount": self.amount,
            "units": self.units,
            "payee_account_id": self.payee_account_id,
            "map_category": self.map_category,
            "map_goal_amount": self.map_goal_amount,
            "map_invested_amount": self.map_invested_amount,
        }


class Frequency(Enum):
    DAILY = 1
    WEEKLY = 2
    MONTHLY = 3


class WeekDay(Enum):
    WEEKDAY_UNKNOWN = 0
    WEEKDAY_MONDAY = 1
    WEEKDAY_TUESDAY = 2
    WEEKDAY_WEDNESDAY = 3
    WEEKDAY_THURSDAY = 4
    WEEKDAY_FRIDAY = 5


@dataclasses.dataclass
class CreateMapScheduleDTO:
    user_profile_identifier: Optional[str]
    schedule_identifier: Optional[str]
    frequency: str
    schedule_type: str
    target_weekdays: str
    target_week: Optional[int]
    schedule_map_invest: Optional[ScheduleMapInvest]
    amount: Optional[float]

    def get_dict(self):
        return {
            "frequency": self.frequency,
            "schedule_type": self.schedule_type,
            "target_weekdays": self.target_weekdays,
            "target_week": self.target_week,
            "schedule_map_invest": self.schedule_map_invest.get_dict(),
        }


@dataclasses.dataclass
class MockTransactionRequestDTO:
    user_profile_identifier: Optional[str]
    transaction_permutation_name: str
    billing_amount: str
    is_foreign_txn: bool

    def get_dict(self):
        return {
            "transaction_permutation_name": self.transaction_permutation_name,
            "billing_amount": self.billing_amount,
            "is_foreign_txn": self.is_foreign_txn,
        }


@dataclasses.dataclass
class CreateUpdateBackwardScheduleDTO:
    action: str
    amount: int
    map_type: str
    target_day: int
    target_weekday: int

    def get_dict(self):
        return {
            "target_day": self.target_day,
            "target_weekday": self.target_weekday,
            "allocations": {},
        }


@dataclasses.dataclass
class SubmitOTPDTO:
    otp: str

    def get_dict(self):
        return {"otp": self.otp}


@dataclasses.dataclass
class UpdateScheduleStatusRequestDTO:
    action: str

    def get_dict(self):
        return {"action": self.action}


@dataclasses.dataclass
class ComplianceInitiateRequestDTO:
    compliance_type: str
    content_type: Optional[str]

    def get_dict(self):
        return {"compliance_type": self.compliance_type, "content_type": self.content_type}


@dataclasses.dataclass
class ComplianceSubmitRequestDTO:
    compliance_id: str
    compliance_type: str
    document_type: str

    def get_dict(self):
        return {
            "compliance_id": self.compliance_id,
            "compliance_type": self.compliance_type,
            "document_type": self.document_type,
        }


@dataclasses.dataclass
class CreditAccountMockTxnRequestDTO:
    amount: float
    txn_type: str
    txn_code: Optional[str]
    category: Optional[str]
    txn_time: Optional[str]

    def get_dict(self):
        return {
            "amount": self.amount,
            "txn_type": self.txn_type,
            "txn_code": self.txn_code,
            "category": self.category,
            "txn_time": self.txn_time + datetime.now().strftime("T%H:%M:%S.%fZ")
        }
