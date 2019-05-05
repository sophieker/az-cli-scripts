# az-cli-scripts

A set of bash scripts to perform common but sometimes tedious tasks using Azure command line tool. 

## Set 1: resource cleanup scripts
I often face big bills due to resources left behind after testing by different teams. 
This set of scripts is to find such resources, starting with resource groups. 
If there is no activities on the resource group for 7 days, delete them.

1. cleanup_sub_rg.sh
This script exams all resource groups in a subscription and delete all that have no real activities in last 7 days. No real activity is currently determined by running `az monitor activity-log` and filtering out audit activities.
Example: `./cleanup_sub_rg.sh my-test-subscrioption` to dry run. And 
`./cleanup_sub_rg.sh my-test-subscrioption realrun` to actually delete.

1. functions.sh
Contains shared functions used by other scripts.

1. get-nonaudit-activities.sh
Get real activities on the given resource group in the given length of time. The script runs `az monitor activity-log` and filtering out audit activities.
Example: `./get-nonaudit-activities.sh my-test-rg-eastus` will get activities in last 7 days for the given resource group. 
`./get-nonaudit-activities.sh my-test-rg-eastus 1h` will get activities in last 1 hour.

1. delete_rg_by_pattern.sh
Sometimes test programs create new resource groups constantly and we can not wait for 7 days to clean them up. Using this script we can delete resource groups whose names match a given pattern. To start simple, regular expression is not supported. The pattern has to be contained in the name of the resource group.
Example: `./delete_rg_by_pattern.sh 'my-test-subscrioption' 'pattern in rg's name'` to dry run. And 
`./delete_rg_by_pattern.sh 'my-test-subscrioption' 'pattern in rg's name' realrun` to delete.
