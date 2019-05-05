#!/usr/bin/env bash

set -euo pipefail

IFS=$'\n'

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

source ${DIR}/functions.sh

print-usage() {
  echo "
    This script deletes inactive resource groups on the given subscription.
    Inactive resource groups are the ones with no non-audit activity in last 7 days.
    The script takes 2 arguments: Id of the subscription to work on and/or whether it's a 'realrun'. 
    In dryrun mode, resource groups will be examed but not deleted. Any string other than 'realrun' will result in dryrun.
    e.g. 
    $0 my-test-subscrioption  --> dry run
    $0 my-test-subscrioption realrun --> real run
    $0 my-test-subscrioption realrun | tee ./log  --> real run with logs recorded
  "
}

# Errors
INVALID_ARGS=8001

if [ $# == 0 ]; then
  print-usage
  exit ${INVALID_ARGS}
fi

subId=$1
realRun=0
if [ $# == 2 ] && [ $2 == 'realrun' ]; then
  realRun=1
fi
echo "Clean up subscription "$subId" 'realrun'=${realRun}"

cmd="az group list --subscription ${subId} --query \"[].{name:name, location:location, managedBy:managedBy, state:properties.provisioningState, tags:tags}\" -o tsv"
echo "$cmd"
rgs=`eval ${cmd}`

rgCnt=$(echo "$rgs" | wc -l)
echo "FOUND "${rgCnt}" RESOURCE GROUPS IN SUBSCRIPTION "${subId}

for line in ${rgs}
do
  #echo ${line}
  #readarray -t -d $'\t' f <<< $line
  IFS=$'\t'  read -r -a f <<< $line
  #echo ${#f[@]}, ${f[0]}, ${f[1]}, ${f[2]}, ${f[3]}
  echo
  echo "+++++++++++++PROCESS RG: "${f[0]}"+++++++++++++"
  # skip managed rg and rg in Deleting state
  if [ ${f[2]} != 'None' ]; then
    echo "SKIP MANAGED RG: "${f[0]}" IS MANAGED BY "${f[2]}
    continue
  elif [ ${f[3]} == 'Deleting' ]; then
    echo "SKIP RG UNDER DELETION: "${f[0]}
    continue
  fi
  activities="$(get-non-audit-activities ${f[0]} 7d)"
  if [ -z "${activities}" ]; then
    echo "NO NON-AUDIT ACTIVITIES IN LAST 7 DAYS. SHOULD DELETE: "${f[0]}
    if [ ${#f[@]} == 5 ] && [ ${f[4]} != 'None' ]; then
      echo "FOUND TAGS: "${f[4]}" ON RG: "${f[0]}" SKIP DELETE"
    else
      cmd="time az group delete --no-wait -y --subscription ${subId} -n ${f[0]}"
      echo $cmd
      if [ $realRun == 1 ]; then
        eval $cmd
      fi
    fi
  else
    echo "ACTIVITY DETECTED ON RG: "${f[0]}
    echo "${activities}"
  fi
done 
# reset IFS
IFS=$'\n'


