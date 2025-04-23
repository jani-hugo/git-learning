#!/bin/bash

# required env vars
# TEST_OUTCOME
# TEST_RESULTS_BUCKET
# PRODUCT
# APP_NAME
# SLACK_TOKEN
# SLACK_CHANNEL_ID
# TEST_TYPE

export RESULTS_FOLDER=allure-test-results

mkdir -p $RESULTS_FOLDER
export TEST_OUTCOME_SYMBOL=$([[ "$TEST_OUTCOME" == "success" ]] && echo ":white_check_mark:" || echo ":warning:")
echo $TEST_OUTCOME
echo $TEST_OUTCOME_SYMBOL
export TEST_NAME=$(date +%Y/%m/%d/$PRODUCT/$APP_NAME/%H-%M-%S)
export TEST_NAME_LATEST=latest/$PRODUCT/$APP_NAME
export S3_URI=s3://$TEST_RESULTS_BUCKET

# get history folder from previous report
#aws s3 cp $S3_URI/$TEST_NAME_LATEST/history --profile $AWS_PROFILE history --recursive
# copy to RESULTS_FOLDER before generating report
#mv history/ $RESULTS_FOLDER/
# then generate report
allure generate $RESULTS_FOLDER --clean -o report > /dev/null

# upload to s3
#aws s3 rm $S3_URI/$TEST_NAME_LATEST --profile $AWS_PROFILE --recursive > /dev/null
#aws s3 cp report $S3_URI/$TEST_NAME_LATEST --profile $AWS_PROFILE --recursive > /dev/null
aws s3 cp report $S3_URI/$TEST_NAME --profile $AWS_PROFILE --recursive > /dev/null

export PASSED=$(cat $(pwd)/tests/api/$PRODUCT/scenarios/$APP_NAME/passed.txt)
export TOTAL=$(cat $(pwd)/tests/api/$PRODUCT/scenarios/$APP_NAME/total.txt)

# post to slack
echo \"*$APP_NAME* : $TEST_OUTCOME_SYMBOL\nPassed: $PASSED/$TOTAL\nCoverage: $PERCENTAGE% \nhttps://reports.hugohub.com/$TEST_NAME/index.html\"
curl --location 'https://slack.com/api/chat.postMessage' \
--header 'Content-Type: application/json' \
--header "Authorization: Bearer $SLACK_TOKEN" \
--data "{
\"channel\": \"$SLACK_CHANNEL_ID\",
\"text\": \"*$APP_NAME* : $TEST_OUTCOME_SYMBOL\nPassed : $PASSED/$TOTAL\nBranch : $BRANCH\nhttps://reports.hugohub.com/$TEST_NAME/index.html\"
}"
