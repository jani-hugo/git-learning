import dataclasses


@dataclasses.dataclass
class OnboardRequestDTO:
    customer_profile_id: str
    node_code_length: int
    number_of_levels: int
    base_currency: str
    node_type: str
    start_date: str
    duration: int
    duration_unit: str
    status_code: str

    # Only add values that would be sent to create object using REST call
    def get_dict(self):
        return {
            "customer_profile_id": self.customer_profile_id,
            "node_code_length": self.node_code_length,
            "number_of_levels": self.number_of_levels,
            "base_currency": self.base_currency,
            "node_type": self.node_type,
            "start_date": self.start_date,
            "duration": self.duration,
            "duration_unit": self.duration_unit,
        }


@dataclasses.dataclass
class LevelConfigDTO:
    customer_profile_id: str
    node_type: str
    level_config: dict
    status_code: str

    # Only add values that would be sent to create object using REST call
    def get_dict(self):
        return {
            "customer_profile_id": self.customer_profile_id,
            "node_type": self.node_type,
            "level_config": self.level_config,
        }


@dataclasses.dataclass
class CustomerBookDTO:
    customer_profile_id: str
    parent_cb_code: str
    cb_attribute_value: str
    cb_description: str
    status_code: str

    # Only add values that would be sent to create object using REST call
    def get_dict(self):
        return {
            "customer_profile_id": self.customer_profile_id,
            "parent_cb_code": self.parent_cb_code,
            "cb_attribute_value": self.cb_attribute_value,
            "cb_description": self.cb_description,
        }


@dataclasses.dataclass
class GeneralLedgerDTO:
    customer_profile_id: str
    parent_gl_code: str
    gl_name: str
    gl_type: str
    gl_description: str
    is_manual_entry_allowed: bool
    gl_cumulative_balance_type: str
    gl_allowed_txn_type: str
    # profile_info: dict
    # mappedTxnCodes: dict
    status_code: str

    # Only add values that would be sent to create object using REST call
    def get_dict(self):
        return {
            "customer_profile_id": self.customer_profile_id,
            "parent_gl_code": self.parent_gl_code,
            "gl_name": self.gl_name,
            "gl_type": self.gl_type,
            "gl_description": self.gl_description,
            "is_manual_entry_allowed": self.is_manual_entry_allowed,
            "gl_cumulative_balance_type": self.gl_cumulative_balance_type,
            "gl_allowed_txn_type": self.gl_allowed_txn_type,
            # "profile_info": self.profile_info
        }


@dataclasses.dataclass
class TxnCodeToLedgerRelationDTO:
    customer_profile_id: str
    txn_code: str
    gl_code: str
    product_id: str
    status_code: str

    # Only add values that would be sent to create object using REST call
    def get_dict(self):
        return {
            "customer_profile_id": self.customer_profile_id,
            "txn_code": self.txn_code,
            "gl_code": self.gl_code,
            "product_id": self.product_id,
        }


@dataclasses.dataclass
class RemapTransactionDTO:
    txn_id: str
    customer_profile_id: str
    source: str
    mapped_cb_code: str
    mapped_gl_code: str
    value_ts: str
    status_code: str

    # Only add values that would be sent to create object using REST call
    def get_dict(self):
        return {
            "txn_id": self.txn_id,
            "customer_profile_id": self.customer_profile_id,
            "source": self.source,
            "mapped_cb_code": self.mapped_cb_code,
            "mapped_gl_code": self.mapped_gl_code,
            "value_ts": self.value_ts,
        }


@dataclasses.dataclass
class CoATransactionDTO:
    txn_id: str
    product_id: str
    txn_code: str
    customer_profile_id: str
    end_customer_profile_id: str
    transaction_type: str
    txn_amount: float
    currency: str
    base_currency_rate_per_unit: float
    source: str
    booking_ts: str
    value_ts: str

    # Only add values that would be sent to create object using REST call
    def get_dict(self):
        return {
            "txn_id": self.txn_id,
            "product_id": self.product_id,
            "txn_code": self.txn_code,
            "customer_profile_id": self.customer_profile_id,
            "end_customer_profile_id": self.end_customer_profile_id,
            "currency": self.currency,
            "transaction_type": self.transaction_type,
            "txn_amount": self.txn_amount,
            "source": self.source,
            "base_currency_rate_per_unit": self.base_currency_rate_per_unit,
            "booking_ts": self.booking_ts,
            "value_ts": self.value_ts,
        }


@dataclasses.dataclass
class CoAFinancialEntryDTO:
    financial_entry_id: str
    transactions: dict
    metadata: dict
    coa_transaction_message_type: str
    status_code: str

    # Only add values that would be sent to create object using REST call
    def get_dict(self):
        return {
            "financial_entry_id": self.financial_entry_id,
            "transactions": self.transactions,
            "metadata": self.metadata,
            "co_transaction_message_type": self.coa_transaction_message_type,
            "status_code": self.status_code,
        }


@dataclasses.dataclass
class TransactionCodeDTO:
    customer_profile_id: str
    transaction_code: str
    iso_code: str
    description: str
    status_code: str

    def get_dict(self):
        return {
            "transaction_code": self.transaction_code,
            "iso_code": self.iso_code,
            "description": self.description,
        }
