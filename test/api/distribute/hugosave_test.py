import json
import logging
import subprocess
import time

from test.api.distribute.app.app_helper import compliance_urls
import requests
import yaml

default_headers = {
    "Content-Type": "application/json",
    "Accept": "application/json",
}

MAX_RETRY_SERVER_ERROR = 6
WAIT_TIME = 10

logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)


class HugosaveTest:
    def __init__(self, config_file):
        self.params = self.__read_yaml(config_file)
        self.tokens = {}

        self.hugosave_base_url = self.params["DISTRIBUTE_ENDPOINT"]

    def hugosave_post_request(
        self, path: str, data: dict = None, headers: dict = None, params: dict = None
    ):
        """To make post requests to Hugosave endpoints"""
        return HugosaveTest.__do_post(
            HugosaveTest.__make_hugo_url(self, path), data, headers, params
        )

    def hugosave_get_request(
        self, path: str, params: dict = None, headers: dict = None
    ):
        """To make get requests to Hugosave endpoints"""
        return HugosaveTest.__do_get(
            HugosaveTest.__make_hugo_url(self, path), params, headers
        )

    def hugosave_delete_request(
        self, path: str, params: dict = None, headers: dict = None
    ):
        """To make delete requests to Hugosave endpoints"""
        return HugosaveTest.__do_delete(
            HugosaveTest.__make_hugo_url(self, path), params, headers
        )

    def hugosave_put_request(
        self, path: str, data: dict = None, params: dict = None, headers: dict = None
    ):
        """To make put requests to Hugosave endpoints"""
        return HugosaveTest.__do_put(
            HugosaveTest.__make_hugo_url(self, path), data, params, headers
        )

    @staticmethod
    def __run_command(command):
        res = subprocess.run(command, shell=True, capture_output=True)
        res.check_returncode()
        return res.stdout.decode()

    @staticmethod
    def __read_yaml(yaml_file: str):
        with open(yaml_file, "r") as file:
            yaml_file = yaml.safe_load(file)
        return dict(yaml_file.items())

    @staticmethod
    def __make_hugo_url(self, path: str):
        return self.hugosave_base_url + path

    @staticmethod
    def __do_post(
        url: str, body: dict = None, headers: dict = None, params: dict = None
    ):
        if headers is not None:
            headers = {**default_headers, **headers}
        else:
            headers = default_headers

        if compliance_urls["root"] not in url:
            print(f"POST URL:{url}, Headers: {headers}, Body: {body}")

        response = None
        for _ in range(MAX_RETRY_SERVER_ERROR):
            response = requests.post(
                url, data=json.dumps(body), headers=headers, params=params
            )
            print(response.status_code)
            print(response.text)

            if response.status_code < 500:
                break
            time.sleep(WAIT_TIME)
        response.raise_for_status()

        json_response = json.loads(response.text)
        if compliance_urls["root"] not in url:
            print(f"POST URL:{url}, Response: {json_response}")
        return json_response

    @staticmethod
    def __do_get(url: str, params: dict = None, headers: dict = None):
        if headers is not None:
            headers = {**default_headers, **headers}
        else:
            headers = default_headers

        print(f"GET URL:{url}, headers: {headers}, Params: {params}")

        response = None
        for i in range(MAX_RETRY_SERVER_ERROR):
            response = requests.get(url, params=params, headers=headers)
            if response.status_code < 500:
                break
            time.sleep(WAIT_TIME)
        response.raise_for_status()

        json_response = json.loads(response.text)
        print(f"GET URL:{url}, Response: {json_response}")
        return json_response

    @staticmethod
    def __do_delete(url: str, params: dict, headers: dict = None):
        if headers is not None:
            headers = {**default_headers, **headers}
        else:
            headers = default_headers

        print(f"DELETE URL:{url}, Headers: {headers}, params: {params}")

        response = None
        for i in range(MAX_RETRY_SERVER_ERROR):
            response = requests.delete(url, params=params, headers=headers)
            if response.status_code < 500:
                break
            time.sleep(WAIT_TIME)
        response.raise_for_status()

        json_response = json.loads(response.text)
        print(f"DELETE URL:{url}, Response: {json_response}")
        return json_response

    @staticmethod
    def __do_put(
        url: str,
        body: dict = None,
        params: dict = None,
        headers: dict = None,
    ):
        if headers is not None:
            headers = {**default_headers, **headers}
        else:
            headers = default_headers
        if compliance_urls["root"] not in url:
            print(f"PUT URL:{url}, Headers: {headers}, Params: {params}")

        response = None
        for i in range(MAX_RETRY_SERVER_ERROR):
            response = requests.put(
                url, data=json.dumps(body), params=params, headers=headers
            )
            if response.status_code < 500:
                break
            time.sleep(WAIT_TIME)
        response.raise_for_status()

        json_response = json.loads(response.text)
        if compliance_urls["root"] not in url:
            print(f"PUT URL:{url}, Response: {json_response}")
        return json_response
