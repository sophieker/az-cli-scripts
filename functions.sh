# Common functions used by scripts in this project

#
# Get a list of non-audit activities on the given resource group in reverse chronological order.
# Expect 3 arguments: 1: subscription Id; 2: resource group Id; 3:how long ago to check
# 
get-non-audit-activities() {
  #set -x
  az monitor activity-log list --subscription $1 -g $2 --offset $3 \
    --query "[?"'!'"contains(operationName.value, 'Microsoft.Authorization/policies/audit')].{ts:submissionTimestamp, op:operationName.value}" -o tsv \
    | sort -k 2 -r
  #set +x
}
