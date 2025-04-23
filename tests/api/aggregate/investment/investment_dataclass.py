from enum import Enum
from typing import List, Optional, Dict
import dataclasses
from dataclasses import field


@dataclasses.dataclass
class CustomerOnboardRequestDTO:
    identifier: Optional[str]
    customer_id: str
    customer_profile_id: str
    provider_id: str

    def get_dict(self):
        return {
            "customer_id": self.customer_id,
            "customer_profile_id": self.customer_profile_id,
            "provider_id": self.provider_id,
        }


@dataclasses.dataclass
class CustomerOnboardResponseDTO:
    identifier: Optional[str]
    status: str
    error_message: Optional[str]

    @classmethod
    def sanitize_customer_onboard_response_dto(cls, customer_onboard_response_dto):
        customer_onboard_response_dto.identifier = None
        customer_onboard_response_dto.status = customer_onboard_response_dto.status
        customer_onboard_response_dto.error_message = (
            customer_onboard_response_dto.error_message
        )
        return customer_onboard_response_dto


@dataclasses.dataclass
class EndCustomerOnboardRequestDTO:
    identifier: Optional[str]
    end_customer_profile_id: str
    provider_id: str

    def get_dict(self):
        return {
            "provider_id": self.provider_id,
            "end_customer_profile_id": self.end_customer_profile_id,
        }


class OnboardStatus(Enum):
    ONBOARD_UNKNOWN = 0
    ONBOARD_RECEIVED = 1
    ONBOARD_PENDING = 2
    ONBOARD_SUCCESS = 3
    ONBOARD_FAILED = 4
    ONBOARD_ERROR = 5
    ONBOARD_REJECTED = 6
    ONBOARD_PROCESSED = 7


@dataclasses.dataclass
class EndCustomerOnboardResponseDTO:
    identifier: Optional[str]
    status: OnboardStatus
    error_message: Optional[str]

    @classmethod
    def sanitize_end_customer_onboard_response_dto(
        cls, end_customer_onboard_response_dto
    ):
        end_customer_onboard_response_dto.identifier = None
        end_customer_onboard_response_dto.status = (
            end_customer_onboard_response_dto.status
        )
        end_customer_onboard_response_dto.error_message = (
            end_customer_onboard_response_dto.error_message
        )
        return end_customer_onboard_response_dto


@dataclasses.dataclass
class EndCustomerOnboardStatusRequestDTO:
    identifier: Optional[str]
    provider_id: str
    status: str

    def get_dict(self):
        return {"provider_id": self.provider_id, "status": self.status}


@dataclasses.dataclass
class DepositRequestDTO:
    amount: float

    def get_dict(self):
        return {"amount": self.amount}


class Frequency(Enum):
    ONCE = 0
    ONCE_A_YEAR = 1
    ONCE_A_QUARTER = 2
    ONCE_A_MONTH = 3
    ONCE_A_WEEK = 4
    ONCE_A_DAY = 5
    IMMEDIATE = 6


@dataclasses.dataclass
class StrategyDTO:
    frequency: Frequency

    def get_dict(self):
        return {"frequency": self.frequency}


@dataclasses.dataclass
class PortfolioAssetDTO:
    asset_symbol: str
    percentage: float
    provider_id: str

    def get_dict(self):
        return {
            "asset_symbol": self.asset_symbol,
            "percentage": self.percentage,
            "provider_id": self.provider_id,
        }


class AllocationDTO:
    assets: List[PortfolioAssetDTO]

    def get_dict(self):
        return {"assets": [i.get_dict() for i in self.assets]}


@dataclasses.dataclass
class String:
    value: str

    def to_dict(self):
        return {"value": self.value}


@dataclasses.dataclass
class MultiString:
    values: List[str]

    def to_dict(self):
        return {"values": self.values}


@dataclasses.dataclass
class ProductRequestDTO:
    identifier: Optional[str]
    product_code: Optional[str]
    product_name: Optional[str]
    provider_id: Optional[str]
    profile_type: str
    product_class: str
    product_type: str
    allocation: str
    allocation_strategy: str
    re_balance_strategy: str

    # Only add values that would be sent to create an object using REST call
    def get_dict(self):
        return {
            "product_code": self.product_code,
            "product_name": self.product_name,
            "profile_type": self.profile_type,
            "product_class": self.product_class,
            "product_type": self.product_type,
            "provider_id": self.provider_id,
        }


@dataclasses.dataclass
class Value:
    string_value: Optional[String] = None
    multi_string_value: Optional[MultiString] = None


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
class PortfolioDTO:
    end_customer_profile_id: str
    portfolio_name: str
    metadata: dict
    portfolio_allocation: List[AllocationDTO]
    allocation_strategy: StrategyDTO
    re_balancing_strategy: StrategyDTO

    def get_dict(self):
        return {
            "end_customer_profile_id": self.end_customer_profile_id,
            "portfolio_name": self.portfolio_name,
            "portfolio_allocation": [
                i.get_dict() if isinstance(i, AllocationDTO) else i
                for i in self.portfolio_allocation
            ],
            "allocation_strategy": self.allocation_strategy.get_dict(),
            "re_balancing_strategy": self.re_balancing_strategy.get_dict(),
            "metadata": self.metadata,
        }


@dataclasses.dataclass
class PortfolioRequestDTO:
    portfolio_identifier: Optional[str]
    product_id: str
    end_customer_profile_id: Optional[str]

    def get_dict(self):
        return {
            "end_customer_profile_id": self.end_customer_profile_id,
            "product_id": self.product_id,
        }


@dataclasses.dataclass
class PortfolioResponseDTO:
    identifier: Optional[str]
    portfolio_id: str
    status: str
    error_message: Optional[str]

    @classmethod
    def sanitize_portfolio_response_dto(cls, portfolio_response_dto):
        portfolio_response_dto.identifier = None
        portfolio_response_dto.portfolio_id = portfolio_response_dto.portfolio_id
        portfolio_response_dto.status = portfolio_response_dto.status
        portfolio_response_dto.error_message = portfolio_response_dto.error_message

        return portfolio_response_dto


class PortfolioStatus(Enum):
    PORTFOLIO_UNKNOWN = 0
    RECEIVED = 1
    INITIATED = 2
    PENDING = 3
    SUCCESS = 4
    CLOSED = 5
    FAILED = 6
    REJECTED = 7


class AssetUnit(Enum):
    UNKNOWN_UNIT = 0
    GRAMS = 1
    MILLIGRAMS = 2
    OUNCE = 3
    UNITS = 4


class Currency(Enum):
    CURRENCY_UNKNOWN = 0
    SGD = 1


@dataclasses.dataclass
class AssetBalanceDTO:
    provider_id: str
    asset_symbol: str
    quantity: float
    asset_unit: AssetUnit
    networth: float
    source_currency: Currency

    def get_dict(self):
        return {
            "provider_id": self.provider_id,
            "asset_symbol": self.asset_symbol,
            "quantity": self.quantity,
            "asset_unit": self.asset_unit,
            "networth": self.networth,
            "source_currency": self.source_currency,
        }


@dataclasses.dataclass
class PortfolioAccountDTO:
    identifier: Optional[str]
    end_customer_profile_id: str
    status: PortfolioStatus
    portfolio_name: Optional[str]
    metadata: dict
    portfolio_allocation: AllocationDTO
    allocation_strategy: StrategyDTO
    rebalancing_strategy: StrategyDTO
    networth: float
    create_ts: Optional[str]


@dataclasses.dataclass
class PortfolioBalanceDTO:
    identifier: Optional[str]
    networth: float
    asset_networth: AssetBalanceDTO

    @classmethod
    def sanitize_portfolio_asset_balance_dto(cls, portfolio_asset_balance_dto):
        portfolio_asset_balance_dto.identifier = None
        portfolio_asset_balance_dto.networth = portfolio_asset_balance_dto.networth
        portfolio_asset_balance_dto.asset_networth = (
            portfolio_asset_balance_dto.asset_networth
        )

        return portfolio_asset_balance_dto


@dataclasses.dataclass
class AssetRateDTO:
    asset_symbol: str
    offer_price: float
    bid_price: float
    token: str
    timestamp: str
    provider_id: str


@dataclasses.dataclass
class PortfolioRateDTO:
    identifier: Optional[str]
    asset_rates: Optional[list[AssetRateDTO]]


@dataclasses.dataclass
class TransactionRequestDTO:
    transaction_identifier: Optional[str]
    portfolio_id: str
    total_amount: float
    quantity: float
    transaction_type: str
    rate: Optional[PortfolioRateDTO]
    metadata: Optional[dict]
    is_rate_included: Optional[bool]

    def get_dict(self):
        if self.is_rate_included:
            return {
                "portfolio_id": self.portfolio_id,
                "total_amount": self.total_amount,
                "transaction_type": self.transaction_type,
                "quantity": self.quantity,
                "rate": self.rate,
                "metadata": self.metadata,
            }
        else:
            return {
                "portfolio_id": self.portfolio_id,
                "total_amount": self.total_amount,
                "transaction_type": self.transaction_type,
                "quantity": self.quantity,
                "metadata": self.metadata,
            }


@dataclasses.dataclass
class TransactionResponseDTO:
    identifier: Optional[str]
    transaction_id: str
    status: str
    error_message: Optional[str]

    @classmethod
    def sanitize_transaction_response_dto(cls, transaction_response_dto):
        transaction_response_dto.identifier = None
        transaction_response_dto.transaction_id = (
            transaction_response_dto.transaction_id
        )
        transaction_response_dto.status = transaction_response_dto.status
        transaction_response_dto.error_message = transaction_response_dto.error_message

        return transaction_response_dto


class TransactionStatus(Enum):
    TRANSACTION_STATUS_UNKNOWN = 0
    TRANSACTION_STATUS_RECEIVED = 1
    TRANSACTION_STATUS_INITIATING = 2
    TRANSACTION_STATUS_INITIATED = 3
    TRANSACTION_STATUS_PENDING = 4
    TRANSACTION_STATUS_SETTLED = 5
    TRANSACTION_STATUS_FAILED = 6
    TRANSACTION_STATUS_ERROR = 7

    TRANSACTION_STATUS_CASH_INITIATING = 8
    TRANSACTION_STATUS_CASH_INITIATED = 9
    TRANSACTION_STATUS_CASH_PENDING = 10
    TRANSACTION_STATUS_CASH_SETTLED = 11
    TRANSACTION_STATUS_CASH_ERROR = 12
    TRANSACTION_STATUS_CASH_FAILED = 13

    TRANSACTION_STATUS_ASSET_INITIATING = 14
    TRANSACTION_STATUS_ASSET_INITIATED = 15
    TRANSACTION_STATUS_ASSET_PENDING = 16
    TRANSACTION_STATUS_ASSET_SETTLED = 17
    TRANSACTION_STATUS_ASSET_ERROR = 18
    TRANSACTION_STATUS_ASSET_FAILED = 19

    TRANSACTION_STATUS_CANCEL_INITIATING = 20
    TRANSACTION_STATUS_CANCEL_INITIATED = 21
    TRANSACTION_STATUS_CANCEL_PENDING = 2
    TRANSACTION_STATUS_CANCEL_SETTLED = 2


@dataclasses.dataclass
class TransactionDetailsDTO:
    class Details:
        asset_symbol: str
        quantity: float
        asset_unit: AssetUnit
        source_rate_per_unit: float
        destination_rate_per_unit: float
        source_currency: Currency
        destination_currency: Currency

    transaction_id: str
    portfolio_id: str
    end_customer_profile_id: str
    end_customer_profile_id: str
    customer_profile_id: str
    amount: float
    transaction_type: str
    transaction_status: TransactionStatus
    details: List[Details]


def sanitize_date(date):
    if len(date) > 10:
        split = date.split(" ")
        yyyy_mm_dd_date = split[0]
        date_split = yyyy_mm_dd_date.split("-")
        return date_split[2] + "-" + date_split[1] + "-" + date_split[0]
    return date


class TransactionDTO:
    transaction_id: str
    portfolio_id: str
    end_customer_profile_id: str
    customer_profile_id: str
    amount: float
    transaction_type: str
    status: TransactionStatus
    create_ts: Optional[str] = None
    update_ts: Optional[str] = None

    @classmethod
    def sanitize_transaction_dto(cls, transaction_dto):
        transaction_dto.create_ts = sanitize_date(transaction_dto.create_ts)
        transaction_dto.update_ts = sanitize_date(transaction_dto.update_ts)
        return transaction_dto


class TransactionsDTO:
    transactions: List[TransactionDTO]


class PendingSettlementTransactionDetailsDTO:
    id: str
    provider_id: str
    amount: float
    customer_profile_id: str
    end_customer_profile_id: str
    settlement_timestamp: str

    @classmethod
    def sanitize_transaction_dto(cls, transaction_dto):
        transaction_dto.date = sanitize_date(transaction_dto.settlement_timestamp)
        return transaction_dto


@dataclasses.dataclass
class PendingTransactionDetailsDTO:
    transactions: List[PendingSettlementTransactionDetailsDTO]


# dataclass for customer onboarding to account-service
@dataclasses.dataclass
class CreateUpdateCustomerDTO:
    customer_identifier: Optional[str]
    name: str
    date: str

    def get_dict(self):
        return {"name": self.name, "date": self.date}


@dataclasses.dataclass
class CustomerDTO:
    customer_identifier: Optional[str]
    customer_id: str
    name: str
    date: str

    @classmethod
    def from_dict(cls, data: dict):
        return cls(
            customer_identifier=None,
            customer_id=data["customer_id"],
            name=data["name"],
            date=data["date"],
        )


class Address:
    address_line_1: str
    address_line_2: str
    address_line_3: str
    address_line_4: str
    city: str
    state: str
    country: str
    country_code: str
    local_code: str


@dataclasses.dataclass
class CreateUpdateCustomerProfileDTO:
    customer_identifier: Optional[str]
    customer_profile_identifier: Optional[str]
    region: str
    name: str
    email: str
    phone_number: str
    customer_id: str

    def get_dict(self):
        return {
            "region": self.region,
            "name": self.name,
            "email": self.email,
            "phone_number": self.phone_number,
            "customer_id": self.customer_id,
        }


@dataclasses.dataclass
class CustomerProfileDTO:
    identifier: Optional[str]
    customer_profile_id: str
    customer_id: str
    region: str
    name: str
    email: str
    phone_number: str
    address: Address
    status: str


@dataclasses.dataclass
class CreateUpdateEndCustomerProfileDTO:
    end_customer_identifier: Optional[str]
    first_name: str
    last_name: str
    email: str
    phone_number: str

    def get_dict(self):
        return {
            "first_name": self.first_name,
            "last_name": self.last_name,
            "email": self.email,
            "phone_number": self.phone_number,
        }


@dataclasses.dataclass
class EndCustomerProfileDTO:
    end_customer_identifier: Optional[str]
    end_customer_profile_id: str
    customer_profile_id: str
    first_name: str
    last_name: str
    email: str
    phone_number: str
    status: str

    @classmethod
    def from_dict(cls, data: dict):
        return cls(
            end_customer_identifier=None,
            end_customer_profile_id=data["end_customer_profile_id"],
            customer_profile_id=data["customer_profile_id"],
            first_name=data["first_name"],
            last_name=data["last_name"],
            email=data["email"],
            phone_number=data["phone_number"],
            status=data["status"],
        )


@dataclasses.dataclass
class EndCustomerOnboardRequestDTO:
    end_customer_identifier: Optional[str]
    end_customer_profile_id: str
    provider_id: str

    def get_dict(self):
        return {
            "end_customer_profile_id": self.end_customer_profile_id,
            "provider_id": self.provider_id,
        }


@dataclasses.dataclass
class ProviderDataDTO:
    provider_id: str
    provider_name: str
    provider_currency: str
    provider_region: List[str]


@dataclasses.dataclass
class ProviderDTO:
    providers: List[ProviderDataDTO]


class Asset:
    asset_name: str
    asset_symbol: str


@dataclasses.dataclass
class ProviderAssetsDTO:
    class AssetList:
        provider_id: str
        assets: List[Asset]
        provider_type: str

    assets: List[AssetList]
