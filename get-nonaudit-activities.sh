#!/usr/bin/env bash

set -euo pipefail

IFS=$'\n'

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source ${DIR}/functions.sh

print-usage() {
  echo "
    This script shows non audit activities on the given resource group of the given subscription in the given length of time.
    It takes 3 arguments: subscription id, resource group name and length of time. If length of time is not supplied, it is default to 7 days. 
    e.g. 
    $0 my-sub my-test-rg
    $0 my-sub my-test-rg 30d 
    $0 my-sub my-test-rg 1h
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


