from typing import Optional
import dataclasses


@dataclasses.dataclass
class CreateUpdateCustomerDTO:
    customer_identifier: Optional[str]
    name: Optional[str]
    date: Optional[str]

    # Only add values that would be sent to create object using REST call
    def get_dict(self):
        return {
            "name": self.name,
            "date": self.date,
        }


@dataclasses.dataclass
class CustomerDTO(object):
    customer_identifier: Optional[str]
    customer_id: Optional[str]
    name: str
    date: str

    @classmethod
    def sanitize_customer_dto(cls, customer_dto):
        customer_dto.customer_identifier = None
        customer_dto.customer_id = None
        customer_dto.date = sanitize_date(customer_dto.date)
        return customer_dto


@dataclasses.dataclass
class CreateUpdateCustomerProfileDTO:
    customer_profile_identifier: Optional[str]
    customer_identifier: Optional[str]
    region: Optional[str]
    name: Optional[str]
    email: Optional[str]
    phone_number: Optional[str]
    customer_id: Optional[str]

    # Only add values that would be sent to create object using REST call
    def get_dict(self):
        return {
            "region": self.region,
            "name": self.name,
            "email": self.email,
            "phone_number": self.phone_number,
            "customer_id": self.customer_id,
            # Address addressTobeAdded
        }


@dataclasses.dataclass
class CustomerProfileDTO(object):
    customer_profile_identifier: Optional[str]
    customer_identifier: Optional[str]
    customer_profile_id: Optional[str]
    api_key: Optional[str]
    customer_id: Optional[str]
    region: str
    name: str
    email: str
    phone_number: str
    status: str

    @classmethod
    def sanitize_customer_profile_dto(cls, customer_profile_dto):
        customer_profile_dto.customer_profile_identifier = None
        customer_profile_dto.customer_profile_id = None
        customer_profile_dto.api_key = None
        customer_profile_dto.customer_identifier = None
        customer_profile_dto.customer_id = None
        return customer_profile_dto


@dataclasses.dataclass
class CreateUpdateEndCustomerProfileDTO:
    customer_identifier: Optional[str]
    customer_profile_identifier: Optional[str]
    end_customer_profile_identifier: Optional[str]
    customer_profile_id: Optional[str]
    first_name: Optional[str]
    last_name: Optional[str]
    email: Optional[str]
    phone_number: Optional[str]

    # Only add values that would be sent to create object using REST call
    def get_dict(self):
        return {
            "first_name": self.first_name,
            "last_name": self.last_name,
            "email": self.email,
            "phone_number": self.phone_number,
            "customer_profile_id": self.customer_profile_id,
        }


@dataclasses.dataclass
class EndCustomerProfileDTO(object):
    end_customer_profile_identifier: Optional[str]
    customer_profile_identifier: Optional[str]
    end_customer_profile_id: Optional[str]
    customer_profile_identifier: Optional[str]
    customer_profile_id: Optional[str]
    first_name: str
    last_name: str
    email: str
    phone_number: str
    status: str

    @classmethod
    def sanitize_end_customer_profile_dto(cls, end_customer_profile_dto):
        end_customer_profile_dto.identifier = None
        end_customer_profile_dto.customer_id = None
        end_customer_profile_dto.customer_profile_id = None
        end_customer_profile_dto.end_customer_profile_id = None
        end_customer_profile_dto.customer_profile_identifier = None
        end_customer_profile_dto.end_customer_profile_identifier = None
        return end_customer_profile_dto

    @staticmethod
    def flatten_end_customer_data(data):
        if 'end_customer_details' in data:
            end_customer_details = data.pop('end_customer_details', {})
            data['first_name'] = end_customer_details.get('first_name')
            data['last_name'] = end_customer_details.get('last_name')
            data['email'] = end_customer_details.get('email')
            data['phone_number'] = end_customer_details.get('phone_number')
        return data


def sanitize_date(date):
    if len(date) > 10:
        split = date.split(' ')
        yyyy_mm_dd_date = split[0]
        date_split = yyyy_mm_dd_date.split('-')
        return date_split[2] + '-' + date_split[1] + '-' + date_split[0]
    return date
