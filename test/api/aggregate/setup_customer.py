import pprint
import time
from collections import namedtuple

import requests
from hugoutils.telemetry.logger import LogManager

logger = LogManager.get_logger(__name__)

BANKING_PROVIDER_DBS = "DBS-SG"
COMPLIANCE_PROVIDER_TRUN = "TRU-NARRATIVE"
CARD_PROVIDER_CLOWD9 = "CLOWD9"
INVESTMENT_PROVIDER_SB = "SILVER-BULLION"

account_info = namedtuple(
    'Account_Details', ['account_id', 'account_number', 'bank_name', 'bic_swift']
)


class SetupCustomer:
    def __init__(self, hugoserve_cmn_stack_details):
        if hugoserve_cmn_stack_details:
            self.hugoserve_api_base = "https://" + hugoserve_cmn_stack_details.get_prop(
                "LoadBalancerUrl"
            )
        else:
            self.hugoserve_api_base = "http://localhost"
        print(self.hugoserve_api_base)

        self.card_config = {
            "card_manufacturer_id": "d3879b12-89ad-420c-baea-5e021cbd6015",
            "client_id": "7abed700-5aa6-4c66-a63d-d3559a275c7a",
            "product_id": "dfe3878f-d2ce-4760-85dc-9d9149f30227",
        }

        if hugoserve_cmn_stack_details:
            self.param_store_api = hugoserve_cmn_stack_details.get_param_store_api()

        self.test_customer_id = "60363778-896a-4c49-ade5-94823e45ac9e"
        self.test_customer_profile_id = "07651956-706a-47f3-ac69-595b26cd60f8"

    def get_headers(self):
        return {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'x-customer-profile-id': f'{self.test_customer_profile_id}',
            'x-customer-access-key': '',
        }

    @staticmethod
    def __response_200_value_or_raise(response):
        status = response.status_code
        body = response.json()

        if status == 200:
            headers = body.get('headers', {})
            status_code = headers.get('status_code')
            message = headers.get('message')
            if status_code == "200" or status_code == "204" or status_code == "201":
                return body.get('data', {})
            else:
                logger.info(f'Received Error from Server {status}:\n{message}')
                raise ValueError(status)
        elif status < 400:
            logger.info(f'Interesting response status {status}:\n{pprint.pformat(body)}')
            return body
        else:
            logger.info(f'Received Error from Server {status}:\n{pprint.pformat(body)}')
            raise ValueError(status)

    def __onboard_on_account(self):
        url = f'{self.hugoserve_api_base}/account/v1/admin/customer'
        body = {"name": "test_customer", "date": "25-04-2023"}
        response = requests.post(url, json=body, headers=self.get_headers(), verify=False)
        test_customer_id = SetupCustomer.__response_200_value_or_raise(response)['customer_id']

        url = f'{self.hugoserve_api_base}/account/v1/admin/customer-profile'
        body = {
            "customer_id": test_customer_id,
            "region": "SG",
            "name": "test",
            "email": "test@hugo.com",
            "phoneNumber": "+999999999991",
        }
        response = requests.post(url, json=body, headers=self.get_headers(), verify=False)
        test_customer_profile_id = SetupCustomer.__response_200_value_or_raise(response)[
            'customer_profile_id'
        ]

        self.test_customer_id = test_customer_id
        self.test_customer_profile_id = test_customer_profile_id
        return response.json()['headers']['status_code'] == "200"

    def __onboard_on_banking(self):
        url = f'{self.hugoserve_api_base}/banking/v1/admin/customer-profile'
        body = {
            "customer_id": self.test_customer_id,
            "customer_profile_id": self.test_customer_profile_id,
            "provider_id": [BANKING_PROVIDER_DBS],
        }
        requests.post(url, json=body, headers=self.get_headers(), verify=False)
        status = None
        url = f'{self.hugoserve_api_base}/banking/v1/customer-profile'
        for _ in range(8):
            response = requests.get(url, headers=self.get_headers(), verify=False)
            onboard_statuses = SetupCustomer.__response_200_value_or_raise(response)[
                'providers'
            ]
            provider_status_map = {
                val['provider_id']: val['onboard_status'] for val in onboard_statuses
            }
            status = provider_status_map.get(BANKING_PROVIDER_DBS, None)

            logger.debug(f'Banking Onboarding {self.test_customer_profile_id} status: {status}')
            if status == 'ONBOARD_SUCCESS':
                break
            else:
                time.sleep(0.5)

        return status == 'ONBOARD_SUCCESS'

    def __onboard_on_compliance(self):
        url = f'{self.hugoserve_api_base}/compliance/v1/admin/customer-profile'
        body = {
            "customer_id": self.test_customer_id,
            "customer_profile_id": self.test_customer_profile_id,
            "provider_id": [COMPLIANCE_PROVIDER_TRUN],
        }
        requests.post(url, json=body, headers=self.get_headers(), verify=False)

        status = None
        url = f'{self.hugoserve_api_base}/compliance/v1/customer-profile'
        for _ in range(8):
            response = requests.get(f"{url}", headers=self.get_headers(), verify=False)
            onboard_statuses = SetupCustomer.__response_200_value_or_raise(response)[
                'providers'
            ]
            provider_status_map = {
                val['provider_id']: val['onboard_status'] for val in onboard_statuses
            }
            status = provider_status_map.get(COMPLIANCE_PROVIDER_TRUN, None)

            logger.debug(
                f'Compliance Onboarding {self.test_customer_profile_id} status: {status}'
            )
            if status == 'ONBOARD_SUCCESS':
                break
            else:
                time.sleep(0.5)

        return status == 'ONBOARD_SUCCESS'

    def __setup_card_config(self):
        # Initializing Card Config
        url = f'{self.hugoserve_api_base}/card/v1/admin/card-config'
        body = {
            "customer_profile_id": self.test_customer_profile_id,
            "provider_id": CARD_PROVIDER_CLOWD9,
        }
        headers = {**self.get_headers(), **{"x-idempotency-key": "default"}}
        response = requests.post(url, json=body, headers=headers, verify=False)
        card_config_id = SetupCustomer.__response_200_value_or_raise(response)['card_config_id']
        # We need to sleep to ensure provider queue has this card config onboarding request,
        # which is polled only once every 5 seconds.
        time.sleep(10)

        url = f'{self.hugoserve_api_base}/card/v1/admin/clowd9/card-config'
        body = {
            "customer_profile_id": self.test_customer_profile_id,
            "card_config_id": card_config_id,
            "manufacturer_config": {
                "card_manufacturer_id": self.card_config.get("card_manufacturer_id"),
            },
        }
        requests.post(url, json=body, headers=self.get_headers(), verify=False)

        return card_config_id

    def __onboard_on_card(self):
        url = f'{self.hugoserve_api_base}/card/v1/admin/customer-profile'
        body = {
            "customer_id": self.test_customer_id,
            "customer_profile_id": self.test_customer_profile_id,
            "provider_id": CARD_PROVIDER_CLOWD9,
            "fund_provider_id": "CASH",
            "has_bank_accounts": True,
        }

        response = requests.post(url, json=body, headers=self.get_headers(), verify=False)
        # We need to sleep to ensure provider queue has this onboarding request,
        # which is polled only once every 5 seconds.
        time.sleep(10)

        url = f'{self.hugoserve_api_base}/card/v1/admin/clowd9/client'
        body = {
            "customer_profile_id": self.test_customer_profile_id,
            "client_id": self.card_config.get("client_id"),
            "product_id": self.card_config.get("product_id"),
        }
        response = requests.post(url, json=body, headers=self.get_headers(), verify=False)
        status = None
        url = f'{self.hugoserve_api_base}/card/v1/customer-profile'
        for _ in range(10):
            response = requests.get(f"{url}", headers=self.get_headers(), verify=False)
            onboard_statuses = SetupCustomer.__response_200_value_or_raise(response)[
                'providers'
            ]
            provider_status_map = {
                val['provider_id']: val['onboard_status'] for val in onboard_statuses
            }
            status = provider_status_map.get(CARD_PROVIDER_CLOWD9, None)
            logger.debug(f'Card Onboarding {self.test_customer_profile_id} status: {status}')
            if status == 'ONBOARD_SUCCESS':
                break
            else:
                time.sleep(30)

        return status == 'ONBOARD_SUCCESS'

    def __onboard_on_investment(self):
        url = f'{self.hugoserve_api_base}/investment/v1/admin/customer-profile'
        body = {
            "customer_id": self.test_customer_id,
            "customer_profile_id": self.test_customer_profile_id,
            "provider_id": [INVESTMENT_PROVIDER_SB],
        }
        requests.post(url, json=body, headers=self.get_headers(), verify=False)

        status = None
        url = f'{self.hugoserve_api_base}/investment/v1/customer-profile'
        for _ in range(8):
            response = requests.get(url, headers=self.get_headers(), verify=False)
            onboard_statuses = SetupCustomer.__response_200_value_or_raise(response)[
                'providers'
            ]
            provider_status_map = {
                val['provider_id']: val['onboard_status'] for val in onboard_statuses
            }
            status = provider_status_map.get(INVESTMENT_PROVIDER_SB, None)

            logger.debug(
                f'Investment OnBoarding {self.test_customer_profile_id} status: {status}'
            )
            if status == 'ONBOARD_SUCCESS':
                break
            else:
                time.sleep(10)

        return status == 'ONBOARD_SUCCESS'

    def setup(self, upload_param_store=True, services=None):
        if not services:
            services = ["banking", "compliance", "card", "investment"]

        if "account" in services:
            onboarded_account = self.__onboard_on_account()
            if not onboarded_account:
                logger.error("Failed to onboard Test on Account")
                return

        if "banking" in services:
            onboarded_banking = self.__onboard_on_banking()
            if not onboarded_banking:
                logger.error("Failed to onboard Test on Banking")
                return

        if "compliance" in services:
            onboarded_compliance = self.__onboard_on_compliance()
            if not onboarded_compliance:
                logger.error("Failed to onboard Test on Compliance")
                return

        card_config_id = "None"
        if "card" in services:
            onboarded_card = self.__onboard_on_card()
            if not onboarded_card:
                logger.error("Failed to onboard Test on Card")
                return
            card_config_id = self.__setup_card_config()

        if "investment" in services:
            onboarded_investment = self.__onboard_on_investment()
            if not onboarded_investment:
                logger.error("Failed to onboard Test on investment")
                return

        data = {
            "customer_id": self.test_customer_id,
            "customer_profile_id": self.test_customer_profile_id,
            "card_config_id": card_config_id,
        }

        if upload_param_store:
            self.param_store_api.update_store(f"/customer_id", self.test_customer_id)
            self.param_store_api.update_store(
                f"/customer_profile_id", self.test_customer_profile_id
            )
            self.param_store_api.update_store(f"/card_config_id", card_config_id)

        return data


# if __name__ == '__main__':
#     usage = "python3 tests/integrations/aggregate/setup_customer.py \
#                 <hugoserve_cmn_stage_name:hugoserve_cmn_region:hugoserve_cmn_profile> "
#
#     if len(sys.argv) != 2:
#         print(f"Usage: {usage}")
#         exit(1)
#
#     hugoserve_cmn_stg_reg = sys.argv[1].strip()
#
#     (
#         hugoserve_cmn_stg_name,
#         hugoserve_cmn_region,
#         hugoserve_cmn_profile,
#     ) = StackUtils.split_stage_region_profile(hugoserve_cmn_stg_reg)
#
#     hugoserve_cmn_stack_details = CommonStackDetails(
#         hugoserve_cmn_stg_name,
#         Product.HUGO_SERVE,
#         hugoserve_cmn_region,
#         hugoserve_cmn_profile,
#     )
#
#     if hugoserve_cmn_stg_name == "devp":
#         SetupCustomer(hugoserve_cmn_stack_details).setup()
