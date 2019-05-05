# Common functions used by scripts in this project

get-non-audit-activities() {
  #set -x
  az monitor activity-log list -g $1 --offset $2 \
    --query "[?"'!'"contains(operationName.value, 'Microsoft.Authorization/policies/audit')].{op:operationName.value}" -o tsv \
    | sort | uniq
  #set +x
}