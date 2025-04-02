coa_base_url = "/coa/v1"
customer_book = "/customer-book"
general_ledger = "/general-ledger"
transaction_code_mapping = "/mapping"
aggregation = "/aggregation"
transaction = "/transaction"
financial_book = "/financial-book"
core_base_url = "/core/v1"

customer_book_urls = {
    "onboard_customer": coa_base_url + customer_book + "/onboard",
    "level_config": coa_base_url + customer_book + "/level-config",
    "compute_child_code": coa_base_url + customer_book + "/parent/$book-code$/info",
    "create_customer_book": coa_base_url + customer_book,
    "get_node_info": coa_base_url + customer_book + "/$book-code$",
    "get_children_info": coa_base_url
    + customer_book
    + "/parent/$book-code$/list-child-nodes",
    "get_customer_book_tree": coa_base_url + customer_book + "/tree",
}

general_ledger_urls = {
    "onboard_customer": coa_base_url + general_ledger + "/onboard",
    "level_config": coa_base_url + general_ledger + "/level-config",
    "compute_child_code": coa_base_url + general_ledger + "/parent/$book-code$/info",
    "create_general_ledger": coa_base_url + general_ledger,
    "get_node_info": coa_base_url + general_ledger + "/$book-code$",
    "get_children_info": coa_base_url
    + general_ledger
    + "/parent/$book-code$/list-child-nodes",
    "get_general_ledger_tree": coa_base_url + general_ledger + "/tree",
    "get_general_ledger_transactions": coa_base_url
    + general_ledger
    + "/$coa-financial-book-id$/$cb-code$/$gl-code$/transactions",
}

transaction_mapping_urls = {
    "map_transaction_code": coa_base_url + transaction_code_mapping + "/map-txn-code"
}

transaction_urls = {
    "unmapped_transactions": coa_base_url + transaction,
    "remap_transactions": coa_base_url + transaction + "/remap-txn",
    "add_transactions": coa_base_url + transaction + "/add-txn",
}

aggregation_urls = {
    "get_aggregated_customer_book": coa_base_url
    + aggregation
    + "/$coa-financial-book-id$/$cb-code$",
    "get_aggregated_general_ledger": coa_base_url
    + aggregation
    + "/$coa-financial-book-id$/$cb-code$/$gl-code$",
    "get_aggregated_customer_book_tree": coa_base_url
    + aggregation
    + "/$coa-financial-book-id$/tree",
    "get_aggregated_general_ledger_tree": coa_base_url
    + aggregation
    + "/$coa-financial-book-id$/tree/$cb-code$",
}

coa_book_urls = {
    "get_current_book_status": coa_base_url + financial_book + "/active",
    "get_book_status_list": coa_base_url + financial_book + "/list",
}

core_helper_urls = {"add_transaction_codes": core_base_url + "/transaction-code"}

status_codes = {
    "Invalid node type in onboard request": "COSM_9401",
    "Invalid level config in onboard request": "COSM_9402",
    "Invalid gl code length in onboard request": "COSM_9403",
    "Invalid gl code compute request": "COSM_9404",
    "Invalid txn code mapping request": "COSM_9405",
    "Invalid node type in level config request": "COSM_9406",
    "GL not found": "COSM_9407",
    "CoA Config not found": "COSM_9408",
    "CoA Level config not found": "COSM_9409",
    "Txn code to GL code mapping not found": "COSM_9410",
    "Invalid level config request": "COSM_9411",
    "GL code length mismatch with the configured gl code length": "COSM_9412",
    "CoA Customer book not found": "COSM_9413",
    "Node level is incorrect in GL creation request": "COSM_9414",
    "GL Creation failed": "COSM_9415",
    "Invalid gl prefix": "COSM_9416",
    "Invalid gl code": "COSM_9417",
    "Book Creation failed": "COSM_9418",
    "Invalid book prefix": "COSM_9419",
    "Invalid book code": "COSM_9420",
    "Node level is incorrect in Book creation request": "COSM_9421",
    "Invalid parent GL code in GL creation request": "COSM_9422",
    "Invalid parent Book code in GL creation request": "COSM_9423",
    "Manual mapping of transaction to GL code failed": "COSM_9424",
    "Manual mapping forbidden for provided GL code": "COSM_9425",
}


def get_headers(customer_profile_id, origin="CUSTOMER"):
    headers = {
        "x-customer-profile-id": customer_profile_id,
    }
    if origin:
        headers["x-origin-id"] = origin

    return headers


def assert_values(name, id, expected, actual):
    assert expected == actual, (
        f"\nId: {id}" f"\nExpected {name}: {expected}" f"\nActual {name}: {actual}"
    )
