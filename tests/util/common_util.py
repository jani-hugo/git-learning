def check_status(response, expected_status):
    status_code = response["headers"]["status_code"]
    assert status_code == str(expected_status), (
        f"\nExpect headers.status_code: {expected_status}"
        f"\nActual headers.status_code: {status_code}"
    )


def check_status_distribute(response, expected_status, match_equal=True):
    status_code = response["headers"]["statusCode"]
    check = status_code == str(expected_status)
    if not match_equal:
        check = not check
    assert check, (
        f"\nExpect headers.statusCode: {expected_status}"
        f"\nActual headers.statusCode: {status_code}"
        f"\nResponse: {response}"
    )
    return check
