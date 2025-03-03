Feature: Testing the tracker service

    Scenario Outline: Trying to create a tracker with all unknown enum values
        When I try to create a tracker
            | customer_profile_id   | idempotency   | trackerRequestDTO   | response_code   |
            | <customer_profile_id> | <idempotency> | <trackerRequestDTO> | <response_code> |

        Examples:
            | customer_profile_id | idempotency       | trackerRequestDTO                                                                                                                                                                                                             | response_code |
            | profileid           | idempotency_key_1 | {"trackerName":"tracker_name_1","trackerDescription":"tracker 1 description","entityRequest": [],"frequency":{"type":"UNKNOWN_TRACKER_FREQUENCY","value":10},"timezone":"KARACHI","referenceType":"UNKNOWN_TRAKER_REFERENCE"} | E9400         |
            | profileid           | idempotency_key_2 | {"trackerName":"tracker_name_2","trackerDescription":"tracker 2 description","entityRequest": [],"frequency":{"type":"UNKNOWN_TRACKER_FREQUENCY","value":10},"timezone":"KARACHI","referenceType":"CASH_ACCOUNT"}             | E9400         |
            | profileid           | idempotency_key_3 | {"trackerName":"tracker_name_3","trackerDescription":"tracker 3 description","entityRequest": [],"frequency":{"type":"MINUTE","value":10},"timezone":"KARACHI","referenceType":"UNKNOWN_TRAKER_REFERENCE"}                    | E9400         |

    Scenario Outline: Trying to create a tracker for different frequencies and reference type
        When I try to create a tracker
            | customer_profile_id   | x_idempotency_key   | trackerRequestDTO   | response_code   |
            | <customer_profile_id> | <x_idempotency_key> | <trackerRequestDTO> | <response_code> |

        Examples:
            | customer_profile_id | x_idempotency_key | trackerRequestDTO                                                                                                                                                                                      | response_code |
            | profileid           | idempotency_key_4 | {"trackerName":"tracker_name_4","trackerDescription":"tracker 4 description","entityRequest": [],"frequency":{"type":"MINUTE","value":10},"timezone":"KARACHI","referenceType":"CASH_ACCOUNT"}         | 200           |
            | profileid           | idempotency_key_5 | {"trackerName":"tracker_name_5","trackerDescription":"tracker 5 description","entityRequest": [],"frequency":{"type":"HOUR","value":10},"timezone":"KARACHI","referenceType":"CASH_ACCOUNT"}           | 200           |
            | profileid           | idempotency_key_6 | {"trackerName":"tracker_name_6","trackerDescription":"tracker 6 description","entityRequest": [],"frequency":{"type":"CALENDER_DAY","value":10},"timezone":"KARACHI","referenceType":"CASH_ACCOUNT"}   | 200           |
            | profileid           | idempotency_key_7 | {"trackerName":"tracker_name_7","trackerDescription":"tracker 7 description","entityRequest": [],"frequency":{"type":"CALENDER_WEEK","value":10},"timezone":"KARACHI","referenceType":"CASH_ACCOUNT"}  | 200           |
            | profileid           | idempotency_key_8 | {"trackerName":"tracker_name_8","trackerDescription":"tracker 8 description","entityRequest": [],"frequency":{"type":"CALENDER_MONTH","value":10},"timezone":"KARACHI","referenceType":"CASH_ACCOUNT"} | 200           |
            | profileid           | idempotency_key_9 | {"trackerName":"tracker_name_9","trackerDescription":"tracker 9 description","entityRequest": [],"frequency":{"type":"CALENDER_YEAR","value":10},"timezone":"KARACHI","referenceType":"CASH_ACCOUNT"}  | 200           |

    Scenario Outline: Trying to create a tracker for different reference types and valid frequency
        When I try to create a tracker
            | customer_profile_id   | x_idempotency_key   | trackerRequestDTO   | response_code   |
            | <customer_profile_id> | <x_idempotency_key> | <trackerRequestDTO> | <response_code> |

        Examples:
            | customer_profile_id | x_idempotency_key  | trackerRequestDTO                                                                                                                                                                                        | response_code |
            | profileid           | idempotency_key_10 | {"trackerName":"tracker_name_10","trackerDescription":"tracker 10 description","entityRequest": [],"frequency":{"type":"MINUTE","value":10},"timezone":"KARACHI","referenceType":"END_CUSTOMER_PROFILE"} | 200           |
            | profileid           | idempotency_key_11 | {"trackerName":"tracker_name_11","trackerDescription":"tracker 11 description","entityRequest": [],"frequency":{"type":"MINUTE","value":10},"timezone":"KARACHI","referenceType":"CASH_ACCOUNT"}         | 200           |
            | profileid           | idempotency_key_12 | {"trackerName":"tracker_name_12","trackerDescription":"tracker 12 description","entityRequest": [],"frequency":{"type":"MINUTE","value":10},"timezone":"KARACHI","referenceType":"CREDIT_ACCOUNT"}       | 200           |
            | profileid           | idempotency_key_13 | {"trackerName":"tracker_name_13","trackerDescription":"tracker 13 description","entityRequest": [],"frequency":{"type":"MINUTE","value":10},"timezone":"KARACHI","referenceType":"CARD_ACCOUNT"}         | 200           |
            | profileid           | idempotency_key_14 | {"trackerName":"tracker_name_14","trackerDescription":"tracker 14 description","entityRequest": [],"frequency":{"type":"MINUTE","value":10},"timezone":"KARACHI","referenceType":"CARD"}                 | 200           |

    Scenario Outline: Trying to create a valid tracker
        When I try to create a tracker
            | customer_profile_id   | idempotency   | trackerRequestDTO   | response_code   |
            | <customer_profile_id> | <idempotency> | <trackerRequestDTO> | <response_code> |

        Examples:
            | customer_profile_id | idempotency        | trackerRequestDTO                                                                                                                                                                                | response_code |
            | profileid           | idempotency_key_15 | {"trackerName":"tracker_name_15","trackerDescription":"tracker 15 description","entityRequest": [],"frequency":{"type":"MINUTE","value":10},"timezone":"KARACHI","referenceType":"CASH_ACCOUNT"} | 200           |

    Scenario Outline: Trying to get the Tracker Details
        When I try to fetch a tracker's details
            | customer_profile_id   | tracker_id   | response_code   |
            | <customer_profile_id> | <tracker_id> | <response_code> |

        Examples:
            | customer_profile_id | tracker_id                           | response_code |
            | profile-id          | c66cb3a8-a157-491a-9a78-7a5959cc6f31 | 200           |

    Scenario Outline: Trying to get the Details of Tracker from reference id
        When I try to fetch a details of tracker of a particular reference_id
            | customer_profile_id   | tracker_id   | reference_id   | response_code   |
            | <customer_profile_id> | <tracker_id> | <reference_id> | <response_code> |

        Examples:
            | customer_profile_id | tracker_id                           | reference_id | response_code |
            | profile-id          | c66cb3a8-a157-491a-9a78-7a5959cc6f31 | referenceId  | 200           |

    Scenario Outline: Trying to add tracker entity details
        When I try to add a tracker entity details
            | customer_profile_id   | tracker_id   | entityRequestDTO   | response_code   |
            | <customer_profile_id> | <tracker_id> | <entityRequestDTO> | <response_code> |

        Examples:
            | customer_profile_id | tracker_id                           | entityRequestDTO                                                                                                                                                     | response_code |
            | profile-id          | c66cb3a8-a157-491a-9a78-7a5959cc6f31 | {"entity_id":"string","entity_type":"ENTITY_PRODUCT","transaction_codes":["code1"],"status_code":"string","transaction_type":"string","service_name":"CARD_SERVICE"} | 200           |

    Scenario Outline:  Trying to update entity transaction codes
        When I try to update entity transaction codes
            | customer_profile_id   | tracker_entity_id   | transaction_codes   | response_code   |
            | <customer_profile_id> | <tracker_entity_id> | <transaction_codes> | <response_code> |

        Examples:
            | customer_profile_id | tracker_entity_id                    | transaction_codes    | response_code |
            | profile-id          | 0d6ff5b2-318b-4a8b-8d05-8193d8eab2fb | ["code_1", "code_2"] | 200           |

    Scenario Outline: Trying to get the list of tracker references details
        When I try to get the list of tracker references details
            | customer_profile_id   | tracker_vs_reference | response_code   |
            | <customer_profile_id> | <trackerVsReference> | <response_code> |

        Examples:
            | customer_profile_id | trackerVsReference                                     | response_code |
            | profile-id          | {"c66cb3a8-a157-491a-9a78-7a5959cc6f31": "reference1"} | 200           |

    Scenario Outline: Trying to get all the tracker details of a customer profile
        When I try to get the all the tracker details
            | customer_profile_id   | response_code   |
            | <customer_profile_id> | <response_code> |

        Examples:
            | customer_profile_id | response_code |
            | profileid           | 200           |