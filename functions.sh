# Common functions used by scripts in this project

#
# Get unique names of non-audit activities on the given resource group.
# Expect 3 arguments: 1: subscription Id; 2: resource group Id; 3:how long ago to check
# 
get-non-audit-activities() {
  #set -x
  az monitor activity-log list --subscription $1 -g $2 --offset $3 \
    --query "[?"'!'"contains(operationName.value, 'Microsoft.Authorization/policies/audit')].{op:operationName.value}" -o tsv \
    | sort | uniq
  #set +x
}
