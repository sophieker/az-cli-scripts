#!/usr/bin/env bash

set -euo pipefail

IFS=$'\n'

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source ${DIR}/functions.sh

print-usage() {
  echo "
    This script shows non audit activities on the given resource group of the given subscription in the given length of time.
    It takes 3 arguments: subscription id, resource group name and length of time. If length of time is not supplied, it is default to 7 days. 
    It returns a list of activities in reverse chronological order of submissionTimestamp.
    e.g. 
    $0 my-sub my-test-rg
    $0 my-sub my-test-rg 30d 
    $0 my-sub my-test-rg 1h

2019-05-10T00:33:19.104266+00:00        Microsoft.Resources/subscriptions/resourcegroups/delet
2019-05-09T23:06:30.036889+00:00        Microsoft.ContainerService/managedClusters/write
2019-05-09T22:50:20.044987+00:00        Microsoft.Resources/deployments/validate/action
2019-05-09T22:50:17.080585+00:00        Microsoft.Resources/subscriptions/resourcegroups/write
2019-05-09T22:50:17.080585+00:00        Microsoft.ContainerService/managedClusters/write
2019-05-09T22:50:10.032257+00:00        Microsoft.Resources/deployments/validate/action
  "
}
# Errors
INVALID_ARGS=8001

if (( $# < 2 )); then
  print-usage
  exit ${INVALID_ARGS}
fi

subId=$1
rgId=$2

length='7d'
if (( $# == 3 )); then
  length=$3
fi

get-non-audit-activities $subId $rgId $length


