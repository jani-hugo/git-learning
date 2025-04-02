import math
import random
import re
import uuid

from datetime import datetime, timezone, timedelta

card_providers_config = {
    "Clowd9": {
        "supports_integration_test": True,
        "max_wait_time": 180,
        "txn_check_max_wait_time": 180,
    },
    "Nymcard": {
        "supports_integration_test": True,
        "max_wait_time": 180,
        "txn_check_max_wait_time": 180,
    },
    "Pseudo": {
        "supports_integration_test": True,
        "max_wait_time": 180,
        "txn_check_max_wait_time": 180,
    },
}

CARD_PROVIDER_CLOWD9 = "CLOWD9"
CARD_PROVIDER_NYMCARD = "NYMCARD"
CARD_PROVIDER_PSEUDO = "PSEUDO"

supported_currency = {
    ("108", "152"): 0,
    ("702", "826", "356", "586"): 2,
    ("368", "400"): 3,
}


def get_currency_precision(currency_code):
    for currency_tuple, precision in supported_currency.items():
        if currency_code in currency_tuple:
            return precision
    return None


def calculate_precision(currency_code: str, amount: str):
    num_of_digits = get_currency_precision(currency_code=currency_code)
    return float(amount) * int(pow(10, num_of_digits))


def validate_provider(provider_name: str):
    if provider_name not in card_providers_config:
        raise RuntimeError(f"No such provider found. Provider name: {provider_name}")

    if not card_providers_config[provider_name]["supports_integration_test"]:
        raise RuntimeError(
            f"Integration tests are not supported for provider {provider_name}"
        )


def fetch_card_provider_id(context, provider_name: str, customer_profile_id: str):
    provider_region = "SG"
    if provider_name == "Nymcard" or provider_name == "Pseudo":
        provider_region = "PK"

    provider_list = context.request.hugoserve_get_request(
        path="/card/v1/providers",
        params={"region": provider_region},
        headers=get_default_card_headers(customer_profile_id),
    )["data"]["providers"]

    return next(
        provider["provider_id"]
        for provider in provider_list
        if provider["provider_name"] == provider_name
    )


def get_default_card_headers(
    customer_profile_id: str,
    idempotency_key: str = None,
    customer_access_key: str = None,
):
    headers = {
        "x-customer-profile-id": customer_profile_id,
        "x-customer-access-key": customer_access_key,
    }
    if idempotency_key is not None:
        headers["x-idempotency-key"] = str(uuid.uuid4())
    return headers


def generate_random_number(length):
    return "".join(random.choices("0123456789", k=length))


def get_current_timestamp():
    return (
        datetime.now(timezone.utc).isoformat(timespec="seconds").replace("+00:00", "Z")
    )


def is_valid_uuid(value: str):
    try:
        uuid.UUID(str(value))
        return True
    except ValueError:
        return False


def is_valid_fp_tx_id(value: str):
    return len(value) == 36


def round_up(number: float, precision: int = 2):
    """
    Returns a value rounded up to a specific number of decimal places.
    """
    if not isinstance(precision, int):
        raise TypeError("decimal places must be an integer")
    elif precision < 0:
        raise ValueError("decimal places has to be 0 or more")
    elif precision == 0:
        return math.ceil(number)

    factor = 10**precision
    return math.ceil(number * factor) / factor


def round_down(number: float, precision: int = 2):
    """
    Returns a value rounded down to a specific number of decimal places.
    """
    if not isinstance(precision, int):
        raise TypeError("decimal places must be an integer")
    elif precision < 0:
        raise ValueError("decimal places has to be 0 or more")
    elif precision == 0:
        return math.floor(number)

    factor = 10**precision
    return math.floor(number * factor) / factor


def convert_time_expression_to_offset(ts_exp: str):
    minutes = 0
    seconds = 0
    if not ts_exp.startswith("T+"):
        return timedelta(minutes=minutes, seconds=seconds)

    offset_str = ts_exp[2:]  # Remove "T+"
    minute_match = re.search(r"m(\d+)", offset_str)
    if minute_match:
        minutes = int(minute_match.group(1))

    second_match = re.search(r"s(\d+)", offset_str)
    if second_match:
        seconds = int(second_match.group(1))

    return timedelta(minutes=minutes, seconds=seconds)


def is_second_ts_smaller(first_ts: datetime, second_ts: datetime):
    return second_ts < first_ts
