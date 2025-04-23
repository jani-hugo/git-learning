#!/bin/bash

# required env vars
# STACK_NAME
# PRODUCT
# APP_NAME
# THREADS

export PYTHONPATH=$(pwd)/tests/api/:$PYTHONPATH
python3 tests/api/$PRODUCT/setup.py $STACK_NAME
python3 tests/api/parallel_behave.py $PRODUCT $APP_NAME $THREADS
