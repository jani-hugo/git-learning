from typing import Optional
import dataclasses


@dataclasses.dataclass
class CustomerProfileDTO:
    customer_id: Optional[str]
    customer_profile_id: Optional[str]
    credit_provider_id: Optional[str]

    # Only add values that would be sent to create object using REST call
    def get_dict(self):
        return {
            "customer_id": self.customer_id,
            "customer_profile_id": self.customer_profile_id,
        }
