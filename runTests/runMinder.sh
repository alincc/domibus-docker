#!/bin/bash -xe

set -x

# SUITES=( "7:Domibus_basic_connectivity"
#          "5:Domibus_esens_specific_as4"
#          "4:Domibus_generic_as4" )

SUITES=( "7:Domibus_basic_connectivity" )

runSuite() {
	RUN_SUITE_DATA="<suiteRunRequest xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:noNamespaceSchemaLocation=\"restRunRequestResponseTypes.xsd\"><suiteId>$1</suiteId></suiteRunRequest>"
	SUITE_RUN_ID=`curl -s --data "$RUN_SUITE_DATA" --digest --user root@minder:retset1 -X POST http://13.93.127.140:9000/rest/run/runSuite | awk -F "</suiteRunId>" '{print $1}' | awk -F "<suiteRunId>" '{print $2}'`
	echo $SUITE_RUN_ID
}

suiteRunStatus() {
    # Wait for runSuite to end and get the status
    SUITE_RUN_STATUS_DATA="<suiteRunStatusRequest xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:noNamespaceSchemaLocation=\"restRunRequestResponseTypes.xsd\"><suiteRunId>$1</suiteRunId></suiteRunStatusRequest>"
    STATUS=`curl -s --data "$SUITE_RUN_STATUS_DATA" --digest --user root@minder:retset1 -X POST http://13.93.127.140:9000/rest/run/suiteRunStatus | awk -F "</status>" '{print $1}' | awk -F "<status>" '{print $2}'`
    echo $STATUS
}

##### main starts here #####

RESULT=PASSED

for SUITE in "${SUITES[@]}"
do
	SUITE_ID="${SUITE%%:*}"
	SUITE_NAME="${SUITE##*:}"
	echo Running suite $SUITE_ID - $SUITE_NAME .

	# Run suite and get the run id as the result
	SUITE_RUN_ID=`runSuite $SUITE_ID`
 	echo Result is: $SUITE_RUN_ID

    # Get suite run status, wait until is ready
    STATUS=`suiteRunStatus $SUITE_RUN_ID`
    echo $STATUS

    # Wait for runSuite to end
    NEXT_WAIT_TIME=0
    while ([ "$STATUS" == "IN_PROGRESS" ] || [ "$STATUS" == "" ] ) && [ $NEXT_WAIT_TIME -ne 40 ]; do
      echo  "Retrying after $NEXT_WAIT_TIME."
      sleep 10
      STATUS=`suiteRunStatus $SUITE_RUN_ID`
      echo $STATUS
      let NEXT_WAIT_TIME=NEXT_WAIT_TIME+1
    done

    echo Status of suite $SUITE_ID is $STATUS

	# If at least one suite failed, the plan will fail
    if [ "$STATUS" != "SUCCESS" ]; then
      echo Suite "$SUITE_ID" - "$SUITE_NAME" has status \"$STATUS\".
      RESULT="FAILED"
    fi
done

echo  "RESULT: $RESULT"

if [ "$RESULT" != "PASSED" ]; then
	exit 1
fi
exit 0



