from typing import Optional
import dataclasses


@dataclasses.dataclass
class CreateUpdateCallbackRequestDTO(object):
    endpoint: str
    type: str
    auth_token: str
    callback_identifier: Optional[str]
    customer_identifier: Optional[str]
    customer_profile_identifier: Optional[str]

    def get_dict(self):
        return {
            "endpoint": self.endpoint,
            "type": self.type,
            "auth_token": self.auth_token,
        }


@dataclasses.dataclass
class CallbackDTO(object):
    endpoint: str
    type: str
    auth_token: str
    customer_identifier: Optional[str]
    customer_profile_identifier: Optional[str]
    callback_identifier: Optional[str]

    def get_dict(self):
        return {
            "endpoint": self.endpoint,
            "type": self.type,
            "auth_token": self.auth_token,
        }

    @classmethod
    def sanitize_callback_dto(cls, callback_dto):
        callback_dto.customer_identifier = None
        callback_dto.customer_profile_identifier = None
        callback_dto.callback_identifier = None
        return callback_dto


@dataclasses.dataclass
class NotificationDTO(object):
    customer_profile_identifier: Optional[str]
    customer_profile_id: Optional[str]
    status: Optional[str]
    wait_time: Optional[str]

    def get_dict(self):
        return {
            "customer_profile_identifier": self.customer_profile_identifier,
            "customer_profile_id": self.customer_profile_id,
            "status": self.status,
            "wait_time": self.wait_time,
        }

    @classmethod
    def sanitize_notification_dto(cls, notification_dto):
        notification_dto.customer_profile_identifier = None
        notification_dto.wait_time = None
        return notification_dto
