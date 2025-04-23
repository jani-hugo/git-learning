from concurrent.futures import ALL_COMPLETED, ThreadPoolExecutor, wait
from glob import glob
from pathlib import Path
import os
import subprocess
import sys
import time


class ParallelBehave:
    def __init__(self, product, app, parallel):
        self.product = product
        self.app = app
        self.parallel = parallel

        self.scenarios_path = str(
            os.path.join(Path(__file__).parent, product, "scenarios", app)
        )
        self.features = glob(f"{self.scenarios_path}/**/*.feature", recursive=True)

        self.failed_tests = 0
        self.total_tests = 0

    def run_test_case(self, tc_name, feature_file_index):
        result = subprocess.run(
            [
                "behave",
                "--no-skipped",
                "-f",
                "allure_behave.formatter:AllureFormatter",
                "-o",
                "allure-test-results",
                self.features[feature_file_index],
                "-n",
                tc_name,
            ],
        )
        self.total_tests += 1
        if result.returncode != 0:
            self.failed_tests += 1
        return result.stdout.decode()

    def run(self):
        s = time.time()
        test_cases = []

        i = 0
        for feature in self.features:
            file = open(feature, 'r+')
            lines = file.readlines()

            sc_outline = False
            sc_outline_name = ""
            l_no = 0
            stop_l = len(lines)
            while l_no < stop_l:
                line = lines[l_no].strip()
                if sc_outline:
                    if line.startswith("Examples:"):
                        l_no += 2
                        j = 1
                        curr_line = lines[l_no].strip()
                        while curr_line.startswith("|") and l_no < stop_l:
                            test_cases.append([f"{sc_outline_name} -- @1.{j}", i])
                            l_no += 1
                            j += 1
                            if l_no < stop_l:
                                curr_line = lines[l_no].strip()
                        sc_outline = False
                        sc_outline_name = ""
                    else:
                        l_no += 1
                else:
                    if line.startswith("Scenario Outline"):
                        sc_outline = True
                        sc_outline_name = line.split(":")[1].strip()
                    elif line.startswith("Scenario"):
                        test_case = [line.split(":")[1].strip(), i]
                        test_cases.append(test_case)
                    l_no += 1

            i += 1
        print(test_cases)
        print(len(test_cases))

        executor = ThreadPoolExecutor(self.parallel)
        futures = [
            executor.submit(self.run_test_case, each_case[0], each_case[1])
            for each_case in test_cases
        ]
        wait(futures, return_when=ALL_COMPLETED)

        e = time.time()
        print(f"Took {int(e - s)} Seconds")
        passed_tests = self.total_tests - self.failed_tests
        print(f"Coverage: {passed_tests}/{self.total_tests}")
        percentage = round(passed_tests / self.total_tests, 2)
        print(percentage)

        with open(os.path.join(self.scenarios_path, "passed.txt"), "w+") as f:
            f.write(str(passed_tests) + "\n")
            f.close()
        with open(os.path.join(self.scenarios_path, "total.txt"), "w+") as f:
            f.write(str(self.total_tests) + "\n")
            f.close()

        if self.failed_tests == 0:
            sys.exit(0)
        else:
            sys.exit(1)


if __name__ == "__main__":
    tests_path = str(Path(__file__).parent)

    usage = (
        "python3 tests/integrations/parallel_behave.py <product> <app_name> <no_of_processes>"
    )

    if len(sys.argv) != 4:
        print(usage)
        exit(1)

    product = sys.argv[len(sys.argv) - 3]
    app = sys.argv[len(sys.argv) - 2]
    parallel = int(sys.argv[len(sys.argv) - 1])

    ParallelBehave(product, app, parallel).run()
