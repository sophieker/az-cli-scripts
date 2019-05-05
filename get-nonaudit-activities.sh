#!/usr/bin/env bash

set -euo pipefail

IFS=$'\n'

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source ${DIR}/functions.sh

print-usage() {
  echo "
    This script shows non audit activities on the given resource group in the given length of time.
    It takes 2 arguments: resource group name and length of time. If the second argument is missing, length is default to 7 days. 
    e.g. 
    $0 my-test-rg-eastus 30d 
    $0 my-test-rg-eastus 1h
  "
}
# Errors
INVALID_ARGS=8001

if [ $# == 0 ]; then
  print-usage
  exit ${INVALID_ARGS}
fi

subId=$1

length='7d'
if [ $# == 2 ]; then
  length=$2
fi

get-non-audit-activities $subId $length


