from typing import Optional
import dataclasses


@dataclasses.dataclass
class CustomerProfileDTO:
    customer_identifier: Optional[str]
    customer_profile_identifier: Optional[str]
    provider_id: Optional[str]
    status_code: Optional[str]
    region: Optional[str]

    @classmethod
    def sanitize_data(cls, customer_profile_dto):
        customer_profile_dto.customer_identifier = None
        customer_profile_dto.customer_profile_identifier = None
        return customer_profile_dto

    def get_dict(self):
        return {
            "provider_id": self.provider_id,
            "status_code": self.status_code,
            "region": self.region,
        }


@dataclasses.dataclass
class ProcessComplianceDTO:
    customer_identifier: Optional[str]
    customer_profile_identifier: Optional[str]
    end_customer_profile_identifier: Optional[str]
    compliance_identifier: Optional[str]
    customer_profile_id: Optional[str]
    end_customer_profile_id: Optional[str]
    provider_id: Optional[str]
    status_code: Optional[str]
    compliance_type: Optional[str]
    status: Optional[str]
    decision: Optional[str]

    def get_dict(self):
        return {
            "customer_profile_id": self.customer_profile_id,
            "end_customer_profile_id": self.end_customer_profile_id,
            "provider_id": self.provider_id,
            "compliance_type": self.compliance_type,
            "status_code": self.status_code,
            "status": self.status,
            "decision": self.decision,
        }


@dataclasses.dataclass
class ComplianceImageDTO:
    customer_profile_identifier: Optional[str]
    end_customer_profile_identifier: Optional[str]
    compliance_identifier: Optional[str]
    customer_profile_id: Optional[str]
    end_customer_profile_id: Optional[str]
    provider_id: Optional[str]
    status_code: Optional[str]
    compliance_type: Optional[str]
    missing_param: Optional[str]

    def get_dict(self):
        return {
            "customer_profile_id": self.customer_profile_id,
            "end_customer_profile_id": self.end_customer_profile_id,
            "provider_id": self.provider_id,
            "compliance_type": self.compliance_type,
            "status_code": self.status_code,
            "missing_param": self.missing_param,
        }
