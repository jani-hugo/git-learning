from behave import *
import test.api.distribute.app.app_helper as ah
from test.util.common_util import check_status_distribute
from hugoutils.utilities.dataclass_util import DataClassParser
from test.api.distribute.app.app_dataclass import VerifyMobileNumberDTO
import hashlib
import hmac

use_step_matcher("re")

SECRET_MODULUS = 3


@Step("The user ([^']*) provides a valid mobile number")
def verify_mobile_number(context, uid):
    print(f"context is {context.data}")
    print(f"uid is {uid}")
    request = context.request
    verify_mobile_list = DataClassParser.parse_rows(
        context.table.rows, data_class=VerifyMobileNumberDTO
    )
    device_info = context.data["device_info"]
    x_initiation_signature = get_initiation_signature(device_info)
    print(x_initiation_signature)
    context.data = {} if context.data is None else context.data
    context.data["users"] = (
        {} if context.data.get("users", None) is None else context.data["users"]
    )
    for verify_mobile_dto in verify_mobile_list:
        data = verify_mobile_dto.get_dict()

    if data["mobile_number"] == "random":
        data["mobile_number"] = ah.get_rand_number(10)

    mobile_prefix = "+65"
    if data["ph_prefix"] is not None:
        mobile_prefix = data["ph_prefix"]

    generated_mobile_number = mobile_prefix + data["mobile_number"]
    print(f"the generated number is:{generated_mobile_number}")
    context.data["users"][uid] = {}
    context.data["users"][uid]["mobile_number"] = generated_mobile_number
    context.data["users"][uid]["initiation_signature"] = x_initiation_signature
    initiate_mobile_verification_response = request.hugosave_get_request(
        path=ah.verify_mobile_urls["initiate-verification"],
        headers=ah.get_mobile_verification_header(
            x_initiation_signature, device_info, context
        ),
        params={"user-name": generated_mobile_number},
    )
    if not check_status_distribute(initiate_mobile_verification_response, 200):
        assert (
            False
        ), f"the received response is {initiate_mobile_verification_response}"
    context.data["users"][uid]["initiate_mobile_verification_response"] = (
        initiate_mobile_verification_response["data"]
    )


@Step("The user ([^']*) submits OTP to proceed with verification")
def submit_otp(context, uid):
    request = context.request
    submit_mobile_verification_response = request.hugosave_post_request(
        path=ah.verify_mobile_urls["initiate-verification"],
        headers=ah.get_mobile_verification_header(
            context.data["users"][uid]["initiation_signature"],
            context.data["device_info"],
            context,
        ),
        data={
            "session_id": context.data["users"][uid][
                "initiate_mobile_verification_response"
            ]["sessionId"],
            "user_name": context.data["users"][uid][
                "initiate_mobile_verification_response"
            ]["userName"],
            "code": "123456",
        },
    )
    if not check_status_distribute(submit_mobile_verification_response, 200):
        assert False, f"the response receiver is {submit_mobile_verification_response}"
    context.data["users"][uid]["submit_mobile_verification_response"] = (
        submit_mobile_verification_response["data"]
    )


def concatenated_header_values(device_info):
    concatenated_headers = ""
    headers_order_list = [
        "os",
        "os-build-number",
        "os-version",
        "device-brand-name",
        "device-type",
        "app-first-install-time",
        "app-version",
        "app-bundle-identifier",
        "app-build-version",
        "x-epoch",
    ]
    for i, header in enumerate(headers_order_list):
        if header == "x-epoch":
            currentEpoch = device_info["x-epoch"]
            nearest600Epoch = getNearest600Epoch(currentEpoch)
            concatenated_headers += str(nearest600Epoch)
        else:
            concatenated_headers += device_info[header]
        if i != len(headers_order_list) - 1:
            concatenated_headers += ":"
    return concatenated_headers


def getNearest600Epoch(currentEpoch):
    secondsElapsedAfter600 = currentEpoch % (600 * 1000)
    return currentEpoch - secondsElapsedAfter600


def get_initiation_signature(device_info):
    concatenated_header = concatenated_header_values(device_info)
    encryptionSaltSecret = generateSecret(concatenated_header)
    secret_key = str(encryptionSaltSecret).encode("utf-8")
    message = concatenated_header.encode("utf-8")
    hmac_hash = hmac.new(secret_key, message, hashlib.sha256).hexdigest()
    return hmac_hash


def generateSecret(str):
    byte_sum = sum(ord(c) for c in str)
    return byte_sum % SECRET_MODULUS
