from aggregate.setup_customer import SetupCustomer


class OnboardCustomer:
    def __init__(self, context, services):
        self.context = context
        self.services = services

    def run(self):
        customer_id = self.context.data.get("config_data").get("customer_id", None)
        if not customer_id:
            data = SetupCustomer(None).setup(False, self.services)
            for k, v in data.items():
                self.context.data["config_data"][k] = v

        return self.context
