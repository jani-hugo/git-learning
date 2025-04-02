import json
import logging
import subprocess
import time

import requests
import yaml

logger = logging.getLogger(__name__)
logger.setLevel(logging.NOTSET)

default_headers = {
    "Content-Type": "application/json",
    "Accept": "application/json",
}

MAX_RETRY_SERVER_ERROR = 3


def check_compliance_url(url: str):
    return "/compliance/" in url


class HugoserveTest:
    def __init__(self, config_file):
        self.params = self.__read_yaml(config_file)
        self.tokens = {}

        self.hugoserve_base_url = self.params["AGGREGATE_ENDPOINT"]

    def hugoserve_post_request(
        self, path: str, data: dict = None, headers: dict = None
    ):
        """To make post requests to Hugoserve endpoints"""
        return HugoserveTest.__do_post(
            HugoserveTest.__make_hugo_url(self, path), data, headers
        )

    def hugoserve_get_request(
        self, path: str, params: dict = None, headers: dict = None
    ):
        """To make get requests to Hugoserve endpoints"""
        return HugoserveTest.__do_get(
            HugoserveTest.__make_hugo_url(self, path), params, headers
        )

    def hugoserve_delete_request(
        self, path: str, data: dict = None, params: dict = None, headers: dict = None
    ):
        """To make delete requests to Hugoserve endpoints"""
        return HugoserveTest.__do_delete(
            HugoserveTest.__make_hugo_url(self, path), data, params, headers
        )

    def hugoserve_put_request(self, path: str, data: dict = None, headers: dict = None):
        """To make put requests to Hugoserve endpoints"""
        return HugoserveTest.__do_put(
            HugoserveTest.__make_hugo_url(self, path), data, headers
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
        return self.hugoserve_base_url + path

    @staticmethod
    def __do_post(url: str, body: dict = None, headers: dict = None):
        if headers is not None:
            headers = {**default_headers, **headers}
        else:
            headers = default_headers
        if not check_compliance_url(url):
            logger.debug(f"POST URL:{url}, Headers: {headers}, Body: {body}")

        response = None
        for i in range(MAX_RETRY_SERVER_ERROR):
            response = requests.post(url, data=json.dumps(body), headers=headers)
            if response.status_code < 500:
                break
            time.sleep(5)
        response.raise_for_status()

        json_response = json.loads(response.text)
        if not check_compliance_url(url):
            logger.debug(f"POST URL:{url}, Response: {json_response}")
        return json_response

    @staticmethod
    def __do_get(url: str, params: dict = None, headers: dict = None):
        if headers is not None:
            headers = {**default_headers, **headers}
        else:
            headers = default_headers
        if not check_compliance_url(url):
            logger.debug(f"GET URL:{url}, headers: {headers}, Params: {params}")

        response = None
        for i in range(MAX_RETRY_SERVER_ERROR):
            response = requests.get(url, params=params, headers=headers)
            if response.status_code < 500:
                break
            time.sleep(5)
        response.raise_for_status()

        json_response = json.loads(response.text)
        if not check_compliance_url(url):
            logger.debug(f"GET URL:{url}, Response: {json_response}")
        return json_response

    @staticmethod
    def __do_delete(
        url: str, body: dict = None, params: dict = None, headers: dict = None
    ):
        if headers is not None:
            headers = {**default_headers, **headers}
        else:
            headers = default_headers
        if not check_compliance_url(url):
            logger.debug(
                f"DELETE URL:{url}, Headers: {headers}, Body: {body}, params: {params}"
            )

        response = None
        for i in range(MAX_RETRY_SERVER_ERROR):
            response = requests.delete(
                url, data=json.dumps(body), params=params, headers=headers
            )
            if response.status_code < 500:
                break
            time.sleep(5)
        response.raise_for_status()

        json_response = json.loads(response.text)
        if not check_compliance_url(url):
            logger.debug(f"DELETE URL:{url}, Response: {json_response}")
        return json_response

    @staticmethod
    def __do_put(url: str, body: dict = None, headers: dict = None):
        if headers is not None:
            headers = {**default_headers, **headers}
        else:
            headers = default_headers
        if not check_compliance_url(url):
            logger.debug(f"PUT URL:{url}, Headers: {headers}, Body: {body}")

        response = None
        for i in range(MAX_RETRY_SERVER_ERROR):
            response = requests.put(url, data=json.dumps(body), headers=headers)
            if response.status_code < 500:
                break
            time.sleep(5)
        response.raise_for_status()

        json_response = json.loads(response.text)
        if not check_compliance_url(url):
            logger.debug(f"PUT URL:{url}, Response: {json_response}")
        return json_response
