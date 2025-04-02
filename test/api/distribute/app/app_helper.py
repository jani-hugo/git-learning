import base64
import os
import random
import uuid
from os import device_encoding
from pathlib import Path

ORG_ID_HUGOBANK_PK = "HUGOBANK_PK"
ORG_ID_HUGOSAVE_SG = "HUGOSAVE_SG"


app_base_url = "/app/v2"
auth_base_url = "/auth/v2"
notification_base_url = "/notification/v1"
progress_onboarding_base_url = "/onboard/progress"
initial_onboarding_base_url = "/onboard/initial"

auth_user_urls = {
    "root": auth_base_url + "/user",
    "create": auth_base_url + "/user/create-user",
}

account_urls = {
    "root": app_base_url + "/account",
}

dev_urls = {
    "root": app_base_url + "/dev",
    "deposit": app_base_url + "/dev/transaction/deposit",
    "compliance": app_base_url + "/dev/compliance/status/update",
    "compliance_update": app_base_url + "/dev/user/account-level/update",
    "schedule_trigger": app_base_url + "/dev/tickle/schedule/schedule-id",
    "mock_card_transaction": app_base_url + "/dev/card/mock-transaction",
    "settle_investment_txn": app_base_url + "/dev/investment/intent-id",
    "deposit_hugosave_account": app_base_url + "/dev/hugosave/deposit",
    "list_hugo_balances": app_base_url + "/dev/hugo",
    "card_activation_token": app_base_url + "/dev/card/card-id/activation-token",
    "block_deposits": app_base_url + "/dev/block/deposits",
    "unblock_deposits": app_base_url + "/internal/block/credits",
    "block_merchant_transactions": app_base_url + "/internal/block/debits",
    "unblock_merchant_transactions": app_base_url + "/internal/block/debits",
    "clear_roundup_schedule": app_base_url + "/dev/clear-roundups",
    "settle-all-txn": app_base_url + "/dev/investment/settle-withdraw",
    "questionnaire": app_base_url + "/internal/questionnaire",
    "credit_mock_txn": app_base_url + "/dev/credit/mock-transactions",
    "generate_credit_bills": app_base_url + "/dev/credit/generate-bill",
}

cms_urls = {
    "root": app_base_url + "/credit-account",
    "balance": app_base_url + "/credit-account/account-id/balance",
    "bills": app_base_url + "/credit-account/account-id/bills",
}

user_profile_urls = {
    "root": app_base_url + "/user-profile",
    "details": app_base_url + "/user-profile",
    "status": app_base_url + "/user-profile/status",
    "client_flags": app_base_url + "/user-profile/client-flags",
    "map-list": app_base_url + "/user-profile/maps",
    "card_name": app_base_url + "/user-profile/card-names",
    "cards": app_base_url + "/user-profile/cards",
    "credit-account-list": app_base_url + "/user-profile/credit-accounts",
}

payee_urls = {
    "root": app_base_url + "/payee",
    "list": app_base_url + "/payee/list",
    "pay_payee": app_base_url + "/payee/payee-id/pay",
    "payee": app_base_url + "/payee/payee-id",
    "submit-otp": app_base_url + "/payee/payee-id/submit-otp",
}

map_urls = {
    "root": app_base_url + "/map",
    "update": app_base_url + "/map/map-id",
    "invest": app_base_url + "/map/map-id/invest",
    "withdraw": app_base_url + "/map/map-id/withdraw",
    "rate": app_base_url + "/map/map-id/rate",
}

map_schedule_urls = {
    "root": app_base_url + "/schedule",
    "list": app_base_url + "/schedule",
    "detail": app_base_url + "/schedule/schedule-id",
    "update-status": app_base_url + "/schedule/schedule-id/status",
    "amount": app_base_url + "/schedule/amount",
    "history": app_base_url + "/schedule/schedule-id/history",
    "skip": app_base_url + "schedule/skip",
}

balance_urls = {
    "root": app_base_url + "/balance",
    "account": app_base_url + "/balance/cash/acc-id",
    "map": app_base_url + "/balance/map/map-id",
}

compliance_urls = {
    "root": app_base_url + "/compliance",
    "trust-compliance": app_base_url + "/compliance/trust",
    "initiate-compliance": app_base_url + "/compliance/initiate",
    "submit-compliance": app_base_url + "/compliance/submit",
}

progress_onboarding_urls = {
    "initiate-progress-onboarding": app_base_url
    + progress_onboarding_base_url
    + "/initiate",
    "initiate-onboarding-journey": app_base_url
    + progress_onboarding_base_url
    + f"/journey/{{journey-id}}/initiate",
    "onboarding-journey-status": app_base_url
    + progress_onboarding_base_url
    + f"/journey/{{journey-id}}/status",
    "submit-onboarding-journey": app_base_url
    + progress_onboarding_base_url
    + f"/journey/{{journey-id}}/submit",
    "submit-progress-onboarding": app_base_url
    + progress_onboarding_base_url
    + f"/submit",
    "progress-onboarding-status": app_base_url
    + progress_onboarding_base_url
    + f"/status",
}

initial_onboarding_urls = {
    "initiate-initial-onboarding": app_base_url
    + initial_onboarding_base_url
    + "/initiate",
    "initial-onboarding-status": app_base_url + initial_onboarding_base_url + "/status",
    "submit-initial-onboarding": app_base_url + initial_onboarding_base_url + "/submit",
}


asset_ids = {
    "CASH": "dc3a889c-8199-4683-be3a-7061bb8624c8",
    "GOLD": "524d466e-28a7-44db-b1c4-175953277629",
}

card_urls = {
    "root": app_base_url + "/card",
    "order_card": app_base_url + "/card-account/card-ac-id/issue-card",
    "activation_token": app_base_url + "/card/card-id/activation-token",
    "activate_card": app_base_url + "/card/card-id/activate",
    "update_status": app_base_url + "/card/card-id/status",
    "card_details": app_base_url + "/card/card-id",
    "secure_card_details": app_base_url + "/card/card-id/secure-details",
    "replace_card": app_base_url + "/card/replace",
    "auto_top_up": app_base_url + "/card/card-account-id/auto-top-up",
}

roundup_urls = {
    "root": app_base_url + "/roundup",
    "update_sweep_vault": app_base_url + "/roundup/sweep-details",
}

intent_urls = {
    "root": app_base_url + "/intent",
    "list_intents_for_map": app_base_url + "/intent/map/map-id",
    "list_spend_view_intents": app_base_url + "/intent/spend",
    "list_intents_for_account": app_base_url + "/intent/cash/account-type",
}

device_urls = {
    "root": notification_base_url + "/pn",
    "list": notification_base_url + "/pn/list",
    "delete": notification_base_url + "/pn/token",
}

note_urls = {
    "root": app_base_url + "/note",
    "get_note": app_base_url + "/note/intent-id/intent_id",
}

reward_urls = {
    "gold": app_base_url + "/dev/reward-gold",
    "cash": app_base_url + "/dev/reward-cash",
}

questionnaire_urls = {
    "root": app_base_url + "/questionnaire",
    "list": app_base_url + "/questionnaire/list",
    "details": app_base_url + "/questionnaire/questionnaire-name",
    "user-questionnaire": app_base_url + "/questionnaire/user-questionnaire",
    "update": app_base_url + "/questionnaire/user-questionnaire/user-questionnaire-id",
    "submit": app_base_url
    + "/questionnaire/user-questionnaire/user-questionnaire-id/submit",
    "list-user-questionnaire": app_base_url + "/questionnaire/list-user-questionnaire",
}

verify_mobile_urls = {"initiate-verification": auth_base_url + "/verify/verify-mobile"}


def get_user_header(uid, context):
    return {"x-user-profile-id": uid, "x-enforce-auth": "false"}


def get_mobile_verification_header(x_initiation_signature, device_info, context):
    return {
        "os": device_info["os"],
        "os-build-number": device_info["os-build-number"],
        "os-version": device_info["os-version"],
        "device-brand-name": device_info["device-brand-name"],
        "x-device-id": device_info["x-device-id"],
        "device-type": device_info["device-type"],
        "app-first-install-time": device_info["app-first-install-time"],
        "app-version": device_info["app-version"],
        "app-bundle-identifier": device_info["app-bundle-identifier"],
        "app-build-version": device_info["app-build-version"],
        "x-epoch": str(device_info["x-epoch"]),
        "x-initiation-signature": x_initiation_signature,
    }


def get_create_account_header(context, uid):
    return {
        "x-verification-token": context.data["users"][uid][
            "submit_mobile_verification_response"
        ]["verificationToken"],
        "x-device-id": context.data["device_info"]["x-device-id"],
    }


def get_initial_onboarding_headers(user_profile_id, context, uid):
    return {
        "x-user-profile-id": user_profile_id,
        "x-authentication-token": context.data["users"][uid][
            "create_new_user_response"
        ]["authenticationToken"],
    }


def get_header(context):
    return {
        "app-build-version": context.data["config_data"]["app-build-version"],
    }


def get_user_prof_id(context, user_profile_identifier):
    try:
        return context.data["users"].get(user_profile_identifier)["userProfileId"]
    except Exception:
        return ""


def get_uuid():
    return str(uuid.uuid1())


def get_rand_number(n):
    return str(random.randint(pow(10, n - 1), pow(10, n) - 1))


def get_account_field(field, user_details, acc_subtype):
    account = None
    for acc in user_details["userAccounts"]:
        if acc["accountSubtype"] == acc_subtype:
            account = acc

    return account[field]


def get_dummy_user_data(req):
    random_number = get_rand_number(5)
    update_account_data = {
        "client_flags": {"LITE": "True"} if "client_flags" in req else None,
        "address": (
            {
                "address_line_1": "line1" + random_number,
                "address_line_2": "line2" + random_number,
                "address_line_3": "line3" + random_number,
                "address_line_4": "line4" + random_number,
                "city": "city" + random_number,
                "state": "state" + random_number,
                "country_code": "SGP",
                "local_code": random_number,
            }
            if "address" in req
            else None
        ),
        "dob": "01-02-19" + get_rand_number(2) if "dob" in req else None,
        "first_name": "First" + random_number if "first_name" in req else None,
        "last_name": "Last" + random_number if "last_name" in req else None,
        "nationality": "SGP" if "nationality" in req else None,
        "document_number": (
            "T" + get_rand_number(7) + "S" if "document_number" in req else None
        ),
        "document_expiry_date": (
            "14-09-203" + get_rand_number(1) + " 00:00:00"
            if "document_expiry_date" in req
            else None
        ),
        "tax_id_number": get_rand_number(6) if "tax_id_number" in req else None,
    }

    update_account_data = {
        k: v for k, v in update_account_data.items() if v is not None
    }
    return update_account_data


def get_add_payee_data(name, account_number, email, case):
    req = {
        "name": name,
        "account_number": account_number,
        "bank_name": "DBS Bank Ltd",
        "currency": "SGD",
        "country": "HUGO_SG",
        "bank_code": {"sg_bank_code_details": {"swift_bic": "DBSSSGSGXXX", "iban": ""}},
        "email": email,
    }
    if case == "invalid_swift_bic":
        req["bank_code"]["sg_bank_code_details"]["swift_bic"] = "DBSSSGSGXYX"
    if case == "invalid_currency":
        req["currency"] = "ABC"
    return req


def filter_gold_vault(maps):
    return list(filter(lambda c: c["map_name"] != "GOLD_VAULT", maps))


def get_user_map_id(context, map_identifier, user_profile_identifier):
    if "GOLD" in map_identifier:
        return context.data["users"][user_profile_identifier]["gold-map"]["userMapId"]
    elif "SILVER" in map_identifier:
        return context.data["users"][user_profile_identifier]["silver-map"]["userMapId"]
    elif "PLATINUM" in map_identifier:
        return context.data["users"][user_profile_identifier]["platinum-map"][
            "userMapId"
        ]
    elif "GROWTH" in map_identifier:
        return context.data["users"][user_profile_identifier]["etf-growth-map"][
            "userMapId"
        ]
    elif "BALANCED" in map_identifier:
        return context.data["users"][user_profile_identifier]["etf-balanced-map"][
            "userMapId"
        ]
    elif "CAUTIOUS" in map_identifier:
        return context.data["users"][user_profile_identifier]["etf-cautious-map"][
            "userMapId"
        ]
    else:
        return context.data["users"][user_profile_identifier][map_identifier][
            "userMapId"
        ]


def get_user_profile_id(uid, context):
    try:
        return context.data["users"][uid]["create_new_user_response"]["userProfileId"]
    except Exception:
        return ""


def get_initial_onboarding_id(uid, context):
    try:
        return context.data["users"][uid][
            "initiate_onboarding_initial_onboarding_response"
        ]["onboardingId"]
    except Exception:
        return ""


def get_journey_id(context, uid, journey_type):
    response = context.data["users"][uid]["initiate_onboarding_response"]["journeys"]
    journeys = [journey for journey in response if journey["journey"] == journey_type]
    if context.data["users"][uid]["current_journey_index"] < len(journeys):
        journey_id = [journey["journeyId"] for journey in journeys]
        return journey_id


def get_progress_onboarding_id(context, uid):
    try:
        return context.data["users"][uid]["initiate_onboarding_response"][
            "onboardingId"
        ]
    except Exception:
        return "Could not find progress onboarding Id"
