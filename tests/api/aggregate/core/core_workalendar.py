from behave import *
from hugoutils.utilities.dataclass_util import DataClassParser

from tests.api.aggregate.core.core_dataclass import AddHoliday, GetHoliday, RemoveHoliday
from tests.util.common_util import check_status

workalendar_callback_url = "/core/v1/workalendar"
header_customer_profile_id = "x-customer-profile-id"
calendar_name = "test-calendar"


@When("I try to add a holiday")
def add_holiday_dto_step(context):
    request = context.request
    add_holiday_dto_list = DataClassParser.parse_rows(
        context.table.rows, data_class=AddHoliday
    )

    context.data = {} if context.data is None else context.data
    for add_holiday_dto in add_holiday_dto_list:
        data = add_holiday_dto.get_dict()
        status_code = data["status_code"]
        customer_profile_id = data["customer_profile_id"]
        response = request.hugoserve_put_request(
            path=f"{workalendar_callback_url}",
            headers={header_customer_profile_id: customer_profile_id},
            data=data,
        )
        check_status(response, status_code)


@When("I try to fetch holidays")
def get_holiday_dto_step(context):
    request = context.request
    get_holiday_dto_list = DataClassParser.parse_rows(
        context.table.rows, data_class=GetHoliday
    )

    context.data = {} if context.data is None else context.data
    for get_holiday_dto in get_holiday_dto_list:
        data = get_holiday_dto.get_dict()
        status_code = data["status_code"]
        customer_profile_id = data["customer_profile_id"]
        response = request.hugoserve_get_request(
            path=f"{workalendar_callback_url}",
            headers={header_customer_profile_id: customer_profile_id},
            params={
                key: value
                for key, value in data.items()
                if key != "status_code" and key != "customer_profile_id"
            },
        )
        check_status(response, status_code)


@When("I try to delete a holiday")
def remove_holiday_dto_step(context):
    request = context.request
    remove_holiday_dto_list = DataClassParser.parse_rows(
        context.table.rows, data_class=RemoveHoliday
    )

    context.data = {} if context.data is None else context.data
    for remove_holiday_dto in remove_holiday_dto_list:
        data = remove_holiday_dto.get_dict()
        status_code = data["status_code"]
        customer_profile_id = data["customer_profile_id"]
        print(type(data["holidayDTO"]))
        response = request.hugoserve_delete_request(
            path=f"{workalendar_callback_url}",
            headers={header_customer_profile_id: customer_profile_id},
            params={"calendar-name": data["calender_name"]},
            data={"holidayDTO": data["holidayDTO"].get_dict()},
        )
        check_status(response, status_code)
