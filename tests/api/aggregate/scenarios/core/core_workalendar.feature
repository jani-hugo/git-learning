Feature: Testing the workalendar service

    Scenario Outline: Trying to add a holiday on date not present in a month
        When I try to add a holiday
            | customer_profile_id   | calendar_name   | holidays   | status_code   |
            | <customer_profile_id> | <calendar_name> | <holidays> | <status_code> |

        Examples:
            | customer_profile_id | calendar_name | holidays                                                     | status_code |
            | ndalwer832ruo       | calendar_name | [{"title": "2025Cal", "date": 30, "month": 2, "year": 2025}] | COSM_9101   |

    Scenario Outline: Trying to add a holiday on date that is earlier than today's date.
        When I try to add a holiday
            | customer_profile_id   | calendar_name   | holidays   | status_code   |
            | <customer_profile_id> | <calendar_name> | <holidays> | <status_code> |

        Examples:
            | customer_profile_id | calendar_name | holidays                                                    | status_code |
            | ndalwer832ruo       | calendar_name | [{"title": "2025Cal", "date": 9, "month": 6, "year": 2020}] | 200         |

    Scenario Outline: Trying to create a holiday on a today's date
        When I try to add a holiday
            | customer_profile_id   | calendar_name   | holidays   | status_code   |
            | <customer_profile_id> | <calendar_name> | <holidays> | <status_code> |

        Examples:
            | customer_profile_id | calendar_name | holidays                                                     | status_code |
            | ndalwer832ruo       | calendar_name | [{"title": "2025Cal", "date": 25, "month": 2, "year": 2025}] | 200         |

    Scenario Outline: Trying to create a holiday on a valid day which comes after today
        When I try to add a holiday
            | customer_profile_id   | calendar_name   | holidays   | status_code   |
            | <customer_profile_id> | <calendar_name> | <holidays> | <status_code> |

        Examples:
            | customer_profile_id | calendar_name | holidays                                                    | status_code |
            | ndalwer832ruo       | calendar_name | [{"title": "2025Cal", "date": 9, "month": 6, "year": 2025}] | 200         |

    Scenario Outline: Trying to fetch holidays for a year that has been completed.
        When I try to fetch holidays
            | customer_profile_id   | calendar_name   | year   | status_code   |
            | <customer_profile_id> | <calendar_name> | <year> | <status_code> |

        Examples:
            | customer_profile_id | calendar_name | year | status_code |
            | ndalwer832ruo       | 2025Cal       | 2025 | 200         |

    Scenario Outline: Trying to fetch holidays for the current year.
        When I try to fetch holidays
            | customer_profile_id   | calendar_name   | year   | status_code   |
            | <customer_profile_id> | <calendar_name> | <year> | <status_code> |

        Examples:
            | customer_profile_id | calendar_name | year | status_code |
            | ndalwer832ruo       | 2025Cal       | 2025 | 200         |

    Scenario Outline: Trying to fetch holidays for a year in future.
        When I try to fetch holidays
            | customer_profile_id   | calendar_name   | year   | status_code   |
            | <customer_profile_id> | <calendar_name> | <year> | <status_code> |

        Examples:
            | customer_profile_id | calendar_name | year | status_code |
            | ndalwer832ruo       | 2025Cal       | 2025 | 200         |

    Scenario Outline: Trying to delete a holiday on invalid date
        When I try to delete a holiday
            | customer_profile_id   | calendar_name   | holidayDTO   | status_code   |
            | <customer_profile_id> | <calendar_name> | <holidayDTO> | <status_code> |

        Examples:
            | customer_profile_id | calendar_name | holidayDTO                                        | status_code |
            | ndalwer832ruo       | calendar_name | {"title":"title","date":30,"month":1,"year":2025} | 200         |

    Scenario Outline: Trying to delete a holiday on a day that has passed by.
        When I try to delete a holiday
            | customer_profile_id   | calendar_name   | holidayDTO   | status_code   |
            | <customer_profile_id> | <calendar_name> | <holidayDTO> | <status_code> |

        Examples:
            | customer_profile_id | calendar_name | holidayDTO                                        | status_code |
            | ndalwer832ruo       | calendar_name | {"title":"title","date":30,"month":1,"year":2025} | 200         |

    Scenario Outline: Trying to delete a holiday on a day in future.
        When I try to delete a holiday
            | customer_profile_id   | calendar_name   | holidayDTO   | status_code   |
            | <customer_profile_id> | <calendar_name> | <holidayDTO> | <status_code> |

        Examples:
            | customer_profile_id | calendar_name | holidayDTO                                       | status_code |
            | ndalwer832ruo       | calendar_name | {"title":"title","date":9,"month":6,"year":2025} | 200         |
