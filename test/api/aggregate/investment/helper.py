def __get_investment_provider_map(context):
    provider_list = context.request.hugoserve_get_request(
        path="/investment/v1/providers",
        params={"region": "SG"},
    )["data"]["providers"]

    provider_id_map = {}
    for provider_details in provider_list:
        provider_id_map[provider_details["provider_name"]] = provider_details[
            "provider_id"
        ]

    context.data["provider_id_map"] = provider_id_map


def __get_default_investment_headers(
    customer_profile_id: str, customer_access_key: str = None
):
    return {
        "x-customer-profile-id": customer_profile_id,
        "x-customer-access-key": customer_access_key,
    }
