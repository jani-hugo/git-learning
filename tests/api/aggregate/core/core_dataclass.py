from enum import Enum
from typing import Optional
import dataclasses

# Dataclasses for Workalendar services


@dataclasses.dataclass
class HolidayDTO:
    title: Optional[str]
    date: Optional[int]
    month: Optional[int]
    year: Optional[int]

    def __init__(self, title: str, date: int, month: int, year: int):
        self.title = title
        self.date = date
        self.month = month
        self.year = year

    def get_dict(self):
        return {
            "holiday_title": self.title,
            "date": self.date,
            "month": self.month,
            "year": self.year,
        }


@dataclasses.dataclass
class AddHoliday:
    customer_profile_id: Optional[str]
    calendar_name: Optional[str]
    holidays: list[HolidayDTO]
    status_code: str

    def get_dict(self):
        return {
            "customer_profile_id": self.customer_profile_id,
            "calendar_name": self.calendar_name,
            "holidays": list(holiday.get_dict() for holiday in self.holidays),
            "status_code": self.status_code,
        }


@dataclasses.dataclass
class GetHoliday:
    customer_profile_id: Optional[str]
    calendar_name: Optional[str]
    year: Optional[int]
    status_code: str

    def get_dict(self):
        return {
            "customer_profile_id": self.customer_profile_id,
            "calendar-name": self.calendar_name,
            "year": self.year,
            "status_code": self.status_code,
        }


@dataclasses.dataclass
class RemoveHoliday:
    customer_profile_id: Optional[str]
    calendar_name: Optional[str]
    holidayDTO: Optional[HolidayDTO]
    status_code: str

    def get_dict(self):
        return {
            "customer_profile_id": self.customer_profile_id,
            "calender_name": self.calendar_name,
            "holidayDTO": self.holidayDTO,
            "status_code": self.status_code,
        }


# Dataclasses for Transactions services


@dataclasses.dataclass
class CreateTransactionCodeDTO:
    transaction_code: str
    coa_transaction_code: Optional[str]
    description: Optional[str]

    def get_dict(self):
        return {
            "transaction_code": self.transaction_code,
            "coa_transaction_code": self.coa_transaction_code,
            "description": self.description,
        }


@dataclasses.dataclass
class CreateTransactionCode:
    customer_profile_id: Optional[str]
    requestDTO: CreateTransactionCodeDTO
    status_code: str

    def get_dict(self):
        return {
            "customer_profile_id": self.customer_profile_id,
            "requestDTO": self.requestDTO.get_dict(),
            "status_code": self.status_code,
        }


@dataclasses.dataclass
class FetchTransactionCode:
    customer_profile_id: str
    status_code: str

    def get_dict(self):
        return {
            "customer_profile_id": self.customer_profile_id,
            "status_code": self.status_code,
        }


@dataclasses.dataclass
class FetchCoATransactionCode:
    customer_profile_id: str
    txn_code: str
    status_code: str

    def get_dict(self):
        return {
            "customer_profile_id": self.customer_profile_id,
            "txn-code": self.txn_code,
            "status_code": self.status_code,
        }


@dataclasses.dataclass
class TransactionCodeMappingRequestDTO:
    coa_transaction_code: str
    product_id: Optional[str]
    gl_code: Optional[str]
    contra_gl_code: Optional[str]

    def get_dict(self):
        return {
            "coa_transaction_code": self.coa_transaction_code,
            "product_id": self.product_id,
            "gl_code": self.gl_code,
            "contra_gl_code": self.contra_gl_code,
        }


@dataclasses.dataclass
class TransactionCodeMapping:
    customer_profile_id: str
    requestDTO: Optional[TransactionCodeMappingRequestDTO]
    status_code: str

    def get_dict(self):
        return {
            "customer_profile_id": self.customer_profile_id,
            "requestDTO": self.requestDTO.get_dict(),
            "status_code": self.status_code,
        }


@dataclasses.dataclass
class FetchPaginatedTransactionCode:
    customer_profile_id: str
    anchor_id: Optional[str]
    timestamp_from_ts: Optional[str]
    timestamp_to_ts: Optional[str]
    is_forward: Optional[bool]
    limit: Optional[int]

    def get_dict(self):
        return {
            "customer_profile_id": self.customer_profile_id,
            "anchorId": self.anchor_id,
            "timestampFromTs": self.timestamp_from_ts,
            "timestampToTs": self.timestamp_to_ts,
            "isForward": self.is_forward,
            "limit": self.limit,
        }


@dataclasses.dataclass
class UpdateTransactionCodeRequestDTO:
    coa_transaction_code: Optional[str]
    description: Optional[str]

    def get_dict(self):
        return {
            "coa_transaction_code": self.coa_transaction_code,
            "description": self.description,
        }


@dataclasses.dataclass
class UpdateTransactionCodes:
    customer_profile_id: str
    txnCode: str
    transactionCodeDTO: UpdateTransactionCodeRequestDTO
    status_code: str

    def get_dict(self):
        return {
            "customer_profile_id": self.customer_profile_id,
            "txnCode": self.txnCode,
            "transactionCodeDTO": self.transactionCodeDTO.get_dict(),
            "status_code": self.status_code,
        }


# Enums for Tracker services


@dataclasses.dataclass
class FrequencyDTO(Enum):
    UNKNOWN_TRACKER_FREQUENCY = 0
    MINUTE = 1
    HOUR = 2
    CALENDER_DAY = 3
    CALENDER_WEEK = 4
    CALENDER_MONTH = 5
    CALENDER_YEAR = 6


@dataclasses.dataclass
class TrackerEntityType(Enum):
    UNKNOWN_ENTITY_TYPE = 0
    ENTITY_PRODUCT = 1
    ENTITY_END_CUSTOMER_PROFILE = 2


@dataclasses.dataclass
class AGOrigin(Enum):
    UNKNOWN_SERVICE = 0
    CUSTOMER = 1
    ADMIN = 2
    CARD_SERVICE = 12
    CASH_SERVICE = 13
    CDC_SERVICE = 14
    COMPLIANCE_SERVICE = 15
    INVESTMENT_SERVICE = 16
    LEDGER_SERVICE = 17
    NOTIFICATION_SERVICE = 21
    PAYMENT_SERVICE = 18
    PROFILE_SERVICE = 19
    REPORTING_SERVICE = 20
    RISK_SERVICE = 22
    CMS_SERVICE = 23
    CORE_SERVICE = 24
    MAINTENANCE_SERVICE = 25
    COS_SERVICE = 26
    COA_SERVICE = 27
    PORTAL = 500
    CLOWD9 = 1001
    NYMCARD = 1002
    TRUNARRATIVE = 1101
    SILVER_BULLION = 1201
    DBS = 1301
    PAYSYS = 1302


@dataclasses.dataclass
class TrackerReferenceType(Enum):
    UNKNOWN_TRAKER_REFERENCE = 0
    END_CUSTOMER_PROFILE = 1
    CASH_ACCOUNT = 2
    CREDIT_ACCOUNT = 3
    CARD_ACCOUNT = 4
    CARD = 5


# Helper classes for Tracker services


@dataclasses.dataclass
class TrackerFrequencyDTO:
    type: FrequencyDTO
    value: int

    def get_dict(self):
        return {
            "type": self.type,
            "value": self.value,
        }


@dataclasses.dataclass
class TrackerEntityRequestDTO:
    entity_id: str
    entity_type: TrackerEntityType
    transaction_codes: list[str]
    status_code: str
    transaction_type: str
    service_name: AGOrigin

    def get_dict(self):
        return {
            "entity_id": self.entity_id,
            "entity_type": self.entity_type,
            "transaction_codes": self.transaction_codes,
            "status_code": self.status_code,
            "transaction_type": self.transaction_type,
            "service_name": self.service_name,
        }


# Dataclasses for Tracker services


@dataclasses.dataclass
class CreateTrackerDTO:
    trackerName: str
    trackerDescription: Optional[str]
    entityRequest: list[TrackerEntityRequestDTO]
    frequency: TrackerFrequencyDTO
    timezone: Optional[str]
    referenceType: TrackerReferenceType

    def get_dict(self):
        return {
            "trackerName": self.trackerName,
            "trackerDescription": self.trackerDescription,
            "entityRequest": self.entityRequest,
            "frequency": self.frequency.get_dict(),
            "timezone": self.timezone,
            "referenceType": self.referenceType,
        }


@dataclasses.dataclass
class CreateTracker:
    customer_profile_id: str
    idempotency: Optional[str]
    trackerRequestDTO: CreateTrackerDTO
    response_code: str

    def get_dict(self):
        return {
            "customer_profile_id": self.customer_profile_id,
            "idempotency": self.idempotency,
            "trackerRequestDTO": self.trackerRequestDTO.get_dict(),
            "response_code": self.response_code,
        }


@dataclasses.dataclass
class GetTrackerDetails:
    customer_profile_id: str
    tracker_id: str
    response_code: str

    def get_dict(self):
        return {
            "customer_profile_id": self.customer_profile_id,
            "tracker_id": self.tracker_id,
            "response_code": self.response_code,
        }


@dataclasses.dataclass
class AddTrackerEntityDetails:
    customer_profile_id: str
    tracker_id: str
    entityRequestDTO: TrackerEntityRequestDTO
    response_code: str

    def get_dict(self):
        return {
            "customer_profile_id": self.customer_profile_id,
            "tracker_id": self.tracker_id,
            "entityRequestDTO": self.entityRequestDTO.get_dict(),
            "response_code": self.response_code,
        }


@dataclasses.dataclass
class UpdateEntityTransactionCodes:
    customer_profile_id: str
    tracker_entity_id: str
    transaction_codes: list[str]
    response_code: str

    def get_dict(self):
        return {
            "customer_profile_id": self.customer_profile_id,
            "trackerEntityId": self.tracker_entity_id,
            "updateEntityTransactionCodes": self.transaction_codes,
            "response_code": self.response_code,
        }


@dataclasses.dataclass
class GetTrackerReferenceDetails:
    customer_profile_id: str
    tracker_id: str
    reference_id: str
    response_code: str

    def get_dict(self):
        return {
            "customer_profile_id": self.customer_profile_id,
            "tracker_id": self.tracker_id,
            "reference_id": self.reference_id,
            "response_code": self.response_code,
        }


@dataclasses.dataclass
class GetListTrackerReferencesDetails:
    customer_profile_id: str
    tracker_vs_reference: dict
    response_code: str

    def get_dict(self):
        return {
            "customer_profile_id": self.customer_profile_id,
            "trackerVsReference": self.tracker_vs_reference,
            "response_code": self.response_code,
        }


@dataclasses.dataclass
class GetAllTrackerDetails:
    customer_profile_id: str
    response_code: str

    def get_dict(self):
        return {
            "customer_profile_id": self.customer_profile_id,
            "response_code": self.response_code,
        }


@dataclasses.dataclass
class FetchLocation:
    latitude: float
    longitude: float
    result: str

    def get_dict(self):
        return {
            "latitude": self.latitude,
            "longitude": self.longitude,
            "result": self.result,
        }
