import dataclasses
from typing import Optional, List


@dataclasses.dataclass
class CreateCustomerProfileAccountDTO:
    identifier: str
    currency: str
    country: str
    on_behalf_of: str
    metadata: Optional[dict]

    # Only add values that would be sent to create object using REST call
    def get_dict(self):
        return {
            "customer_profile_id": self.customer_profile_id,
            "provider_id": self.provider_id,
            "on_behalf_of": self.on_behalf_of,
            "currency": self.currency,
            "country": self.country,
            "metadata": self.metadata,
        }


@dataclasses.dataclass
class VirtualIdDetails:
    virtual_id_type: str
    virtual_id_value: str

    def get_dict(self):
        return {
            "virtual_id_type": self.virtual_id_type,
            "virtual_id_value": self.virtual_id_value,
        }


@dataclasses.dataclass
class SGCodeDetailsDTO:
    account_number: Optional[str]
    swift_bic: str
    virtual_id_details: List[VirtualIdDetails]

    def get_dict(self):
        return {
            "account_number": self.account_number,
            "swift_bic": self.swift_bic,
            "virtual_id_details": [vid.get_dict() for vid in self.virtual_id_details],
        }


@dataclasses.dataclass
class PKCodeDetailsDTO:
    account_number: Optional[str]
    bank_bic: Optional[str]
    bank_imd: Optional[str]
    iban: Optional[str]
    swift_bic: Optional[str]
    virtual_id_details: List[VirtualIdDetails]

    def get_dict(self):
        return {
            "account_number": self.account_number,
            "bank_bic": self.bank_bic,
            "bank_imd": self.bank_imd,
            "iban": self.iban,
            "swift_bic": self.swift_bic,
            "virtual_id_details": [vid.get_dict() for vid in self.virtual_id_details],
        }


@dataclasses.dataclass
class CodeDetailsDTO:
    sg_code_details: Optional[SGCodeDetailsDTO]
    pk_code_details: Optional[PKCodeDetailsDTO]

    def get_dict(self):
        return {
            "sg_code_details": (
                self.sg_code_details.get_dict() if self.sg_code_details else None
            ),
            "pk_code_details": (
                self.pk_code_details.get_dict() if self.pk_code_details else None
            ),
        }


@dataclasses.dataclass
class AccountDetailsDTO:
    account_holder_name: Optional[str]
    bank_name: Optional[str]
    country: Optional[str]
    currency: Optional[str]
    code_details: Optional[CodeDetailsDTO]

    def get_dict(self):
        return {
            "account_holder_name": self.account_holder_name,
            "bank_name": self.bank_name,
            "country": self.country,
            "currency": self.currency,
            "code_details": self.code_details.get_dict() if self.code_details else None,
        }


@dataclasses.dataclass
class SGTransferInBankDetailsDTO:
    account_number: Optional[str]
    swift_bic: str

    def get_dict(self):
        return {
            "account_number": self.account_number,
            "swift_bic": self.swift_bic,
        }


@dataclasses.dataclass
class PKTransferInBankDetailsDTO:
    account_number: Optional[str]
    bank_bic: Optional[str]
    bank_imd: Optional[str]
    iban: Optional[str]

    def get_dict(self):
        return {
            "account_number": self.account_number,
            "bank_bic": self.bank_bic,
            "bank_imd": self.bank_imd,
            "iban": self.iban,
        }


@dataclasses.dataclass
class TransferInCodeDetailsDTO:
    sg_bank_details: Optional[SGTransferInBankDetailsDTO] = None
    pk_bank_details: Optional[PKTransferInBankDetailsDTO] = None

    def get_dict(self):
        if self.sg_bank_details:
            return {
                "sg_bank_details": self.sg_bank_details.get_dict(),
            }
        elif self.pk_bank_details:
            return {
                "pk_bank_details": self.pk_bank_details.get_dict(),
            }
        return {}


@dataclasses.dataclass
class TransferInAccountDetailsDTO:
    account_holder_name: str
    country: Optional[str]
    currency: Optional[str]
    code_details: Optional[TransferInCodeDetailsDTO]
    bank_name: Optional[str] = None

    def get_dict(self):
        return {
            "account_holder_name": self.account_holder_name,
            "country": self.country,
            "currency": self.currency,
            "code_details": self.code_details.get_dict() if self.code_details else None,
            "bank_name": self.bank_name,
        }


@dataclasses.dataclass
class SGTransferOutBankDetailsDTO:
    account_number: str
    swift_bic: str
    virtual_id_details: Optional[VirtualIdDetails] = None

    def get_dict(self):
        return {
            "account_number": self.account_number,
            "swift_bic": self.swift_bic,
            "virtual_id_details": (
                self.virtual_id_details.get_dict() if self.virtual_id_details else None
            ),
        }


@dataclasses.dataclass
class PKTransferOutBankDetailsDTO:
    account_number: Optional[str] = None
    bank_bic: Optional[str] = None
    bank_imd: Optional[str] = None
    iban: Optional[str] = None
    virtual_id_details: Optional[VirtualIdDetails] = None

    def get_dict(self):
        return {
            "account_number": self.account_number,
            "bank_bic": self.bank_bic,
            "bank_imd": self.bank_imd,
            "iban": self.iban,
            "virtual_id_details": (
                self.virtual_id_details.get_dict() if self.virtual_id_details else None
            ),
        }


@dataclasses.dataclass
class TransferOutCodeDetailsDTO:
    sg_bank_details: Optional[SGTransferOutBankDetailsDTO] = None
    pk_bank_details: Optional[PKTransferOutBankDetailsDTO] = None

    def get_dict(self):
        if self.sg_bank_details:
            return {"sg_bank_details": self.sg_bank_details.get_dict()}
        elif self.pk_bank_details:
            return {"pk_bank_details": self.pk_bank_details.get_dict()}
        return {}


@dataclasses.dataclass
class TransferOutAccountDetailsDTO:
    account_holder_name: str
    country: str
    currency: str
    code_details: TransferOutCodeDetailsDTO
    bank_name: Optional[str] = None

    def get_dict(self):
        return {
            "account_holder_name": self.account_holder_name,
            "country": self.country,
            "currency": self.currency,
            "code_details": self.code_details.get_dict(),
            "bank_name": self.bank_name,
        }


@dataclasses.dataclass
class BillerDetails:
    biller_category: str
    biller_id: str
    biller_name: Optional[str]
    consumer_id: str

    def get_dict(self):
        return {
            "biller_category": self.biller_category,
            "biller_id": self.biller_id,
            "biller_name": self.biller_name,
            "consumer_id": self.consumer_id,
        }


@dataclasses.dataclass
class ReceiverDetails:
    account_details: AccountDetailsDTO

    def get_dict(self):
        return {"account_details": self.account_details.get_dict()}


@dataclasses.dataclass
class AccountDTO:
    identifier: Optional[str]
    account_id: Optional[str]
    provider_id: Optional[str]
    account_status: str
    account_details: Optional[AccountDetailsDTO]
    on_behalf_of: Optional[str]
    metadata: Optional[dict]

    @classmethod
    def payment_account_dto(cls, expected_acc_dto):
        other = dataclasses.replace(expected_acc_dto)
        other.identifier = None
        other.account_id = None
        other.account_details = None
        return other


@dataclasses.dataclass
class MasterAccountDTO:
    identifier: Optional[str]
    master_account_id: Optional[str]
    customer_profile_id = Optional[str]
    provider_id: Optional[str]
    account_details: Optional[AccountDetailsDTO]

    def get_dict(self):
        return {
            "master_account_id": self.master_account_id,
            "customer_profile_id": self.customer_profile_id,
            "provider_id": self.provider_id,
            "account_details": self.account_details.get_dict(),
        }


@dataclasses.dataclass
class CreateEndCustomerProfileAccountDTO:
    identifier: Optional[str]
    account_id: Optional[str]
    customer_profile_id: Optional[str]
    end_customer_profile_id: Optional[str]
    provider_id: Optional[str]
    currency: str
    country: str
    on_behalf_of: str
    metadata: Optional[dict]

    def get_dict(self):
        return {
            "customer_profile_id": self.customer_profile_id,
            "end_customer_profile_id": self.end_customer_profile_id,
            "provider_id": self.provider_id,
            "currency": self.currency,
            "country": self.country,
            "on_behalf_of": self.on_behalf_of,
            "metadata": self.metadata,
        }


@dataclasses.dataclass
class TransferOutRequestDTO:
    identifier: str
    customer_profile_id: str
    account_id: str
    receiver_account_id: Optional[str]
    transfer_out_account_details: TransferOutAccountDetailsDTO
    txn_amount: float
    purpose: str
    metadata: dict
    txn_currency: str
    txn_mode: Optional[str]

    def get_dict(self):
        return {
            "account_id": self.account_id,
            "txn_amount": self.txn_amount,
            "purpose": self.purpose,
            "metadata": self.metadata,
            "txn_currency": self.txn_currency,
            "txn_mode": self.txn_mode,
            "transfer_out_account_details": self.transfer_out_account_details.get_dict(),
        }


@dataclasses.dataclass
class BillPaymentRequestDTO:
    identifier: str
    customer_profile_id: str
    account_id: str
    biller_details: BillerDetails
    txn_amount: float
    purpose: Optional[str]
    metadata: dict
    country: str
    txn_currency: str

    def get_dict(self):
        return {
            "account_id": self.account_id,
            "txn_amount": self.txn_amount,
            "purpose": self.purpose,
            "metadata": self.metadata,
            "country": self.country,
            "txn_currency": self.txn_currency,
            "biller_details": self.biller_details.get_dict(),
        }


@dataclasses.dataclass
class DevDepositRequestDTO:
    identifier: str
    name: str
    account_id: str
    txn_amount: str
    purpose: str
    txn_mode: str
    currency: str
    metadata: dict
    customer_profile_id: str
    transaction_id: Optional[str]

    def get_dict(self):
        return {
            "name": self.name,
            "account_id": self.account_id,
            "txn_amount": self.txn_amount,
            "purpose": self.purpose,
            "txn_mode": self.txn_mode,
            "currency": self.currency,
            "metadata": self.metadata,
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


@dataclasses.dataclass
class CreditPostingInfo:
    rrn: str
    stan: str
    txndate: str
    txntime: str

    def get_dict(self):
        return {
            "rrn": self.rrn,
            "stan": self.stan,
            "txndate": self.txndate,
            "txntime": self.txntime,
        }


@dataclasses.dataclass
class CreditPostingReceiverInfo:
    to_account: str
    to_account_title: Optional[str]

    def get_dict(self):
        return {
            "to_account": self.to_account,
            "to_account_title": self.to_account_title,
        }


@dataclasses.dataclass
class CreditPostingSenderInfo:
    sender_bank_iMD: Optional[str]
    sender_bank_bIC: Optional[str]
    from_account: Optional[str]
    from_account_title: str
    from_account_cnic: Optional[str]

    def get_dict(self):
        return {
            "sender_bank_iMD": self.sender_bank_iMD,
            "sender_bank_bIC": self.sender_bank_bIC,
            "from_account": self.from_account,
            "from_account_title": self.from_account_title,
            "from_account_cnic": self.from_account_cnic,
        }


@dataclasses.dataclass
class CreditPostingPaymentInfo:
    purpose_code: str
    narration: str
    amount: float
    instr_id: str
    end_to_end_id: str
    tx_id: str
    msg_id: str

    def get_dict(self):
        return {
            "purpose_code": self.purpose_code,
            "narration": self.narration,
            "amount": self.amount,
            "instr_id": self.instr_id,
            "end_to_end_id": self.end_to_end_id,
            "tx_id": self.tx_id,
            "msg_id": self.msg_id,
        }


@dataclasses.dataclass
class CreditPostingTxnInfo:
    info: CreditPostingInfo
    receiverinfo: CreditPostingReceiverInfo
    senderinfo: CreditPostingSenderInfo
    payment_info: CreditPostingPaymentInfo

    def get_dict(self):
        return {
            "info": self.info.get_dict(),
            "receiverinfo": self.receiverinfo.get_dict(),
            "senderinfo": self.senderinfo.get_dict(),
            "payment_info": self.payment_info.get_dict(),
        }


@dataclasses.dataclass
class CreditPostingRequest:
    identifier: str
    customer_profile_id: str
    txn_info: CreditPostingTxnInfo

    def get_dict(self):
        return {"txnInfo": self.txn_info.get_dict()}


@dataclasses.dataclass
class CreditAdviseInfo:
    rrn: str
    stan: str
    txndate: str
    txntime: str
    initiator: str
    txn_type: str

    def get_dict(self):
        return {
            "rrn": self.rrn,
            "stan": self.stan,
            "txndate": self.txndate,
            "txntime": self.txntime,
            "initiator": self.initiator,
            "txn_type": self.txn_type,
        }


@dataclasses.dataclass
class CreditAdviseReceiverInfo:
    to_account: str
    to_account_title: Optional[str] = None

    def get_dict(self):
        return {
            "to_account": self.to_account,
            "to_account_title": self.to_account_title,
        }


@dataclasses.dataclass
class CreditAdviseSenderInfo:
    from_account: str
    from_account_title: str
    sender_bank_iMD: Optional[str] = None
    sender_bank_bIC: Optional[str] = None
    from_account_cnic: Optional[str] = None

    def get_dict(self):
        return {
            "sender_bank_iMD": self.sender_bank_iMD,
            "sender_bank_bIC": self.sender_bank_bIC,
            "from_account": self.from_account,
            "from_account_title": self.from_account_title,
            "from_account_cnic": self.from_account_cnic,
        }


@dataclasses.dataclass
class CreditAdvisePaymentInfo:
    purpose_code: str
    amount: float
    narration: Optional[str] = None
    instr_id: Optional[str] = None
    end_to_end_id: Optional[str] = None
    tx_id: Optional[str] = None
    msg_id: Optional[str] = None
    one_linkrrn: Optional[str] = None
    one_linkstan: Optional[str] = None

    def get_dict(self):
        return {
            "purpose_code": self.purpose_code,
            "narration": self.narration,
            "amount": self.amount,
            "instr_id": self.instr_id,
            "end_to_end_id": self.end_to_end_id,
            "tx_id": self.tx_id,
            "msg_id": self.msg_id,
            "one_linkrrn": self.one_linkrrn,
            "one_linkstan": self.one_linkstan,
        }


@dataclasses.dataclass
class CreditAdviseOrgTxnInfo:
    orgtxndate: Optional[str] = None
    orgtxntime: Optional[str] = None
    orginstr_id: Optional[str] = None
    orgend_to_end_id: Optional[str] = None
    orgtx_id: Optional[str] = None
    orgmsg_id: Optional[str] = None

    def get_dict(self):
        return {
            "orgtxndate": self.orgtxndate,
            "orgtxntime": self.orgtxntime,
            "orginstr_id": self.orginstr_id,
            "orgend_to_end_id": self.orgend_to_end_id,
            "orgtx_id": self.orgtx_id,
            "orgmsg_id": self.orgmsg_id,
        }


@dataclasses.dataclass
class CreditAdviseTxnInfo:
    info: CreditAdviseInfo
    receiver_info: CreditAdviseReceiverInfo
    sender_info: CreditAdviseSenderInfo
    payment_info: CreditAdvisePaymentInfo
    org_txn_info: Optional[CreditAdviseOrgTxnInfo] = None

    def get_dict(self):
        return {
            "info": self.info.get_dict(),
            "receiverInfo": self.receiver_info.get_dict(),
            "senderInfo": self.sender_info.get_dict(),
            "paymentInfo": self.payment_info.get_dict(),
            "org_txn_info": self.org_txn_info.get_dict() if self.org_txn_info else None,
        }


@dataclasses.dataclass
class CreditAdviseRequest:
    identifier: str
    customer_profile_id: str
    txn_info: CreditAdviseTxnInfo

    def get_dict(self):
        return {"txnInfo": self.txn_info.get_dict()}


@dataclasses.dataclass
class CreditInquiryInfo:
    rrn: str
    stan: str
    txndate: str
    txntime: str

    def get_dict(self):
        return {
            "rrn": self.rrn,
            "stan": self.stan,
            "txndate": self.txndate,
            "txntime": self.txntime,
        }


@dataclasses.dataclass
class CreditInquiryOrgTxnInfo:
    orgtxnrrn: str
    orgtxnstan: str
    orgtxndate: str
    orgtxntime: str

    def get_dict(self):
        return {
            "orgtxnrrn": self.orgtxnrrn,
            "orgtxnstan": self.orgtxnstan,
            "orgtxndate": self.orgtxndate,
            "orgtxntime": self.orgtxntime,
        }


@dataclasses.dataclass
class CreditInquiryTxnInfo:
    info: CreditInquiryInfo
    orgTxnInfo: CreditInquiryOrgTxnInfo

    def get_dict(self):
        return {"info": self.info.get_dict(), "orgTxnInfo": self.orgTxnInfo.get_dict()}


@dataclasses.dataclass
class CreditInquiryRequest:
    identifier: str
    txn_info: CreditInquiryTxnInfo

    def get_dict(self):
        return {"txnInfo": self.txn_info.get_dict()}


@dataclasses.dataclass
class VirtualIdRequestDTO:
    customer_profile_id: str
    account_id: str
    virtual_id_details: VirtualIdDetails

    def get_dict(self):
        return {
            "customer_profile_id": self.customer_profile_id,
            "account_id": self.account_id,
            "virtual_id_details": self.virtual_id_details.get_dict(),
        }


@dataclasses.dataclass
class PKInquiryAccount:
    account_number: Optional[str] = None
    bank_bic: Optional[str] = None
    bank_imd: Optional[str] = None
    iban: Optional[str] = None
    virtual_id_details: Optional[VirtualIdDetails] = None

    def get_dict(self):
        return {
            "account_number": self.account_number,
            "bank_bic": self.bank_bic,
            "bank_imd": self.bank_imd,
            "iban": self.iban,
            "virtual_id_details": (
                self.virtual_id_details.get_dict() if self.virtual_id_details else None
            ),
        }


@dataclasses.dataclass
class ReceiverCodeDetails:
    pk_account: Optional[PKInquiryAccount] = None

    def get_dict(self):
        return {"pk_account": self.pk_account.get_dict() if self.pk_account else None}


@dataclasses.dataclass
class InquiryRequestReceiverDetails:
    country: str
    code_details: ReceiverCodeDetails

    def get_dict(self):
        return {
            "country": self.country,
            "code_details": self.code_details.get_dict() if self.code_details else None,
        }


@dataclasses.dataclass
class InquiryRequestDTO:
    identifier: str
    customer_profile_id: str
    account_id: str
    receiver_details: InquiryRequestReceiverDetails
    amount: Optional[float] = None
    txn_mode: Optional[str] = None

    def get_dict(self):
        return {
            "identifier": self.identifier,
            "customer_profile_id": self.customer_profile_id,
            "account_id": self.account_id,
            "receiver_details": self.receiver_details.get_dict(),
            "amount": self.amount,
            "txn_mode": self.txn_mode,
        }


@dataclasses.dataclass
class BillInquiryRequestDTO:
    identifier: str
    customer_profile_id: str
    account_id: str
    biller_category: str
    biller_id: str
    consumer_id: str

    def get_dict(self):
        return {
            "identifier": self.identifier,
            "customer_profile_id": self.customer_profile_id,
            "account_id": self.account_id,
            "biller_category": self.biller_category,
            "biller_id": self.biller_id,
            "consumer_id": self.consumer_id,
        }


@dataclasses.dataclass
class PaysysPKSettlementTransactionRequestDTO:
    identifier: str
    customer_profile_id: str
    settlement_txn_type: str
    txn_amount: float
    purpose: Optional[str]
    metadata: Optional[dict]

    def get_dict(self):
        return {
            "identifier": self.identifier,
            "customer_profile_id": self.customer_profile_id,
            "settlement_txn_type": self.settlement_txn_type,
            "txn_amount": self.txn_amount,
            "purpose": self.purpose,
            "metadata": self.metadata,
        }


@dataclasses.dataclass
class InboundTitleFetchInfo:
    rrn: str
    stan: str
    txndate: str
    txntime: str
    initiator: str

    def get_dict(self):
        return {
            "rrn": self.rrn,
            "stan": self.stan,
            "txndate": self.txndate,
            "txntime": self.txntime,
            "initiator": self.initiator,
        }


@dataclasses.dataclass
class InboundTitleFetchReceiverInfo:
    to_account: str

    def get_dict(self):
        return {"to_account": self.to_account}


@dataclasses.dataclass
class InboundTitleFetchPaymentInfo:
    amount: float

    def get_dict(self):
        return {"amount": self.amount}


@dataclasses.dataclass
class InboundTitleFetch:
    info: InboundTitleFetchInfo
    receiverinfo: InboundTitleFetchReceiverInfo
    payment_info: InboundTitleFetchPaymentInfo

    def get_dict(self):
        return {
            "info": self.info.get_dict(),
            "receiverinfo": self.receiverinfo.get_dict(),
            "payment_info": self.payment_info.get_dict(),
        }


@dataclasses.dataclass
class PaysysPKInboundTitleFetchRequest:
    identifier: str
    txn_info: InboundTitleFetch

    def get_dict(self):
        return {"txnInfo": self.txn_info.get_dict()}
