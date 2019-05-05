#!/usr/bin/env bash

set -euo pipefail

IFS=$'\n'

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source ${DIR}/functions.sh

print-usage() {
  echo "
    This script deletes resource groups whose name matches given pattern on the given subscription.
    The script takes 3 arguments: Id of the subscription to work on, pattern to match resource group's name for deletion and/or whether it's a 'realrun'. 
    In dryrun mode, resource groups will be examed but not deleted. Any string other than 'realrun' will result in dryrun.
    e.g. 
    $0 'my-test-subscrioption' 'test-resource-group'  --> dry run
    $0 'my-test-subscrioption' 'pattern' realrun --> real run
    $0 'my-test-subscrioption' 'pattern' realrun | tee ./log  --> real run with logs recorded
  "
}

# Errors
INVALID_ARGS=8001

if (( $# < 2 )); then
  print-usage
  exit ${INVALID_ARGS}
fi

subId=$1
pattern=$2
realRun=0
if (( $# == 3 )) && [ $3 == 'realrun' ]; then
  realRun=1
fi
echo "Delete resource groups matching "${pattern}" in subscription "$subId" 'realrun'=${realRun}"

cmd="az group list --subscription ${subId} --query \"[?contains(name, '$pattern')].{name:name, location:location, managedBy:managedBy, state:properties.provisioningState, preserve:tags.preserve}\" -o tsv"
echo "$cmd"
rgs=`eval ${cmd}`

rgCnt=$(echo "$rgs" | wc -l)
echo "FOUND "${rgCnt}" RGs MATCHING ''"${pattern}"' IN SUBSCRIPTION "${subId}

for line in ${rgs}
do
  #echo ${line}
  #readarray -t -d $'\t' f <<< $line
  IFS=$'\t'  read -r -a f <<< $line
  echo
  echo "+++++++++++++PROCESS RG: "${f[0]}"+++++++++++++"
  # skip managed rg and rg in Deleting state
  if [ ${f[3]} == 'Deleting' ]; then
    echo "SKIP RG UNDER DELETION: "${f[0]}
    continue
  fi
  if [  ${f[4]} != 'None' ]; then
    echo "SKIP PRESERVED RG: "${f[0]}
  else
    cmd="time az group delete --no-wait -y --subscription ${subId} -n ${f[0]}"
    echo $cmd
    if [ $realRun == 1 ]; then
      eval $cmd
    fi
  fi
done 
# reset IFS
IFS=$'\n'


