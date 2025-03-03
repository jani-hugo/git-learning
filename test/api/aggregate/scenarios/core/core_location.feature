Feature: Testing the location service

    Scenario Outline: Trying to verify location service
        When I try to verify location
            | longitude   | latitude   | result   |
            | <longitude> | <latitude> | <result> |

        Examples:
            | longitude | latitude | result    |
            | 67.0011   | 24.8607  | 200       |
            | -181.0    | 24.8607  | COSM_9501 |
            | 181.0     | 24.8607  | COSM_9501 |
            | 67.0011   | -90.1    | COSM_9501 |
            | 67.0011   | 90.1     | COSM_9501 |
            | 50.0011   | 20.1     | COSM_9502 |
