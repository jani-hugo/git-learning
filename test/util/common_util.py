def check_status(response, expected_status):
    status_code = response['headers']['status_code']
    assert status_code == str(expected_status), (
        f"\nExpect headers.status_code: {expected_status}"
        f"\nActual headers.status_code: {status_code}"
    )
