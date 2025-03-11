cms_base_url = '/cms/v1'

payment_provider_ids = {"DBS": "DBS-SG"}

admin_urls = {
    'onboard_customer_profile': cms_base_url + '/admin/customer-profile',
    'onboard_hugohub': cms_base_url + '/admin/initialize/hugohub',
}

dev_urls = {
    'deposit_funds': cms_base_url + '/dev/deposit-funds',
    'collection_balance': cms_base_url + '/dev/collection-balance',
    'ledger_balance': cms_base_url + '/dev/$account_id$/ledger-balance',
}

customer_profile_urls = {
    'get_details': cms_base_url + '/customer-profile',
    'get_fund_accounts': cms_base_url + '/customer-profile/account-info',
}

end_customer_profile_urls = {
    'onboard': cms_base_url + '/end-customer-profile',
    'get_details': cms_base_url + '/end-customer-profile/$end_customer_profile_id$',
}

fund_account_urls = {
    'get_balance': cms_base_url + '/fund-account/$account_type$',
    'withdraw': cms_base_url + '/withdraw',
}

product_urls = {
    'get_param_config': cms_base_url + '/product/config',
    'create': cms_base_url + '/product',
    'approve': cms_base_url + '/product/$product_id$/activate',
    'get_details': cms_base_url + '/product/$product_id$',
    'get_products_for_customer_profile': cms_base_url + '/product',
    'update':cms_base_url+'/product/$product_id$'
}

credit_account_urls = {
    'create': cms_base_url + '/credit-account',
    'get_details': cms_base_url + '/credit-account/$account_id$',
    'balance': cms_base_url + '/credit-account/$account_id$/balance',
}

card_txn_urls = {
    'attach': cms_base_url + '/card/attach',
    'auth': cms_base_url + '/card/transaction/debit/auth',
    'clear': cms_base_url + '/card/transaction/debit/clear',
    'update': cms_base_url + '/card/transaction/debit/update',
    'revert': cms_base_url + '/card/transaction/$transaction_id$/revert',
    'refund_auth': cms_base_url + '/card/transaction/refund-auth',
    'refund_clear': cms_base_url + '/card/transaction/$transaction_id$/refund-clear',
    'reconcile': cms_base_url + '/card/$group_id$/reconcile',
    'send': cms_base_url + '/card/$group_id$/send',
    'get_txn': cms_base_url + '/card/transaction/$transaction_id$',
    'get_txns_for_account': '',
}

status_codes = {
    "txn_rejected_insufficient_credit": "CMSM_9801",
    "cannot_revert_txn": "CMSM_9803",
}

demo_urls = {
    "create_credit_account": cms_base_url + '/credit-account',
    "get_credit_account_details": cms_base_url + '/credit-account/$account_id$',
    "attach_card": cms_base_url + '/card/attach',
    "initiate_transactions": cms_base_url + '/dev/mock-transactions',
    "generate_bill": cms_base_url + '/dev/generate-bill',
    "balance": cms_base_url + '/credit-account/$account_id$/balance',
    "get_transactions": cms_base_url + '/credit-account/$account_id$/transactions',
    "get_latest_bill": cms_base_url + '/credit-account/$account_id$/latest-bill',
    "get_fund_accounts": cms_base_url + '/customer-profile/fund-accounts'
}

PRODUCT_PARAMS = {
    "normal_case_params_group": [
        {"param_name": "ANNUAL_PERCENTAGE_RATE", "data_type": "DOUBLE_RANGE", "value": {"double_range_value": {"value": 42}}},
        {"param_name": "BILLING_DATE", "data_type": "INTEGER_RANGE", "value": {"integer_range_value": {"value": 1}}},
        {"param_name": "BILLING_FREQUENCY", "data_type": "STRING_LIST", "value": {"string_list_value": {"value": "MONTHLY"}}},
        {"param_name": "CAN_ATTACH_CARD", "data_type": "BOOLEAN", "value": {"boolean_value": {"value": True}}},
        {"param_name": "GRACE_PERIOD", "data_type": "INTEGER_RANGE", "value": {"integer_range_value": {"value": 14}}},
        {"param_name": "CREDIT_LIMIT_RANGE", "data_type": "RANGE_INTEGERS", "value": {"range_integers_value": {"min_value": "1", "max_value": "100000000"}}},
        {"param_name": "MIN_AMOUNT_DUE_PERCENTAGE", "data_type": "DOUBLE_RANGE", "value": {"double_range_value": {"value": 10}}},
        {"param_name": "CURRENCY", "data_type": "STRING_LIST", "value": {"string_list_value": {"value": "SGD"}}},
        {"param_name": "COUNTRY", "data_type": "STRING_LIST", "value": {"string_list_value": {"value": "SGP"}}},
    ],
    "update_params_group": [
        {"param_name": "ANNUAL_PERCENTAGE_RATE", "data_type": "DOUBLE_RANGE", "value": {"double_range_value": {"value": 45}}},
        {"param_name": "BILLING_DATE", "data_type": "INTEGER_RANGE", "value": {"integer_range_value": {"value": 1}}},
        {"param_name": "BILLING_FREQUENCY", "data_type": "STRING_LIST", "value": {"string_list_value": {"value": "MONTHLY"}}},
        {"param_name": "CAN_ATTACH_CARD", "data_type": "BOOLEAN", "value": {"boolean_value": {"value": False}}},
        {"param_name": "GRACE_PERIOD", "data_type": "INTEGER_RANGE", "value": {"integer_range_value": {"value": 14}}},
        {"param_name": "CREDIT_LIMIT_RANGE", "data_type": "RANGE_INTEGERS", "value": {"range_integers_value": {"min_value": "10", "max_value": "100000000"}}},
        {"param_name": "MIN_AMOUNT_DUE_PERCENTAGE", "data_type": "DOUBLE_RANGE", "value": {"double_range_value": {"value": 14}}},
    ],
    "invalid_billing_date":[
        {"param_name": "ANNUAL_PERCENTAGE_RATE", "data_type": "DOUBLE_RANGE", "value": {"double_range_value": {"value": 42}}},
        {"param_name": "BILLING_DATE", "data_type": "INTEGER_RANGE", "value": {"integer_range_value": {"value": 22}}},
    ],
    "invalid_annual_percentage_rate":[
        {"param_name": "ANNUAL_PERCENTAGE_RATE", "data_type": "DOUBLE_RANGE", "value": {"double_range_value": {"value": 2000}}},
    ],
    "invalid_billing_frequency":[
        {"param_name": "BILLING_FREQUENCY", "data_type": "STRING_LIST", "value": {"string_list_value": {"value": "wrong"}}},
    ],
    "missing_min_or_max_value_for_range_integers":[
        {"param_name": "CREDIT_LIMIT_RANGE", "data_type": "RANGE_INTEGERS", "value": {"range_integers_value": {"min_value": "1"}}},
    ],
    "empty_string_list":[
        {"param_name": "COUNTRY", "data_type": "STRING_LIST", "value": {"string_list_value": {}}},
    ],
    "insufficient_detail":[
        {"param_name": "ANNUAL_PERCENTAGE_RATE", "data_type": "DOUBLE_RANGE", "value": {"double_range_value": {"value": 42}}},
        {"param_name": "BILLING_DATE", "data_type": "INTEGER_RANGE", "value": {"integer_range_value": {"value": 1}}},
    ]
}

def get_product_params(param_group):
    return PRODUCT_PARAMS[param_group]

def get_headers(customer_profile_id, origin="CUSTOMER"):
    headers = {
        'x-customer-profile-id': customer_profile_id,
    }
    if origin:
        headers['x-origin-id'] = origin

    return headers


def get_payment_provider_id(provider_name):
    return payment_provider_ids.get(provider_name, "UNKNOWN")


def assert_values(name, id, expected, actual):
    assert expected == actual, (
        f"\nId: {id}" f"\nExpected {name}: {expected}" f"\nActual {name}: {actual}"
    )


def get_receiver_details():
    return {
        "account_details": {
            "account_number": "123",
            "account_holder": "123",
            "bank_name": "DBS",
            "country": "SGP",
            "currency": "SGD",
            "code_details": {"sg_code_details": {"swift_bic": "abc"}},
        }
    }