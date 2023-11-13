#!/usr/bin/env bash

COPY_SHARED_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
log_info "setup cli to specific version"

user=$(echo $RANDOM | md5sum | head -c 2; echo;)
alias=$BUILD_QUEUEDBY
alias=$(echo ${alias// })
alias=$(echo ${alias:0:9})
alias=$(echo "$alias" | tr '[:upper:]' '[:lower:]')
user=$alias$user
echo $user

$acr_out='{
  "passwords": [{
    "name": "password",
    "value": "***"
  }, {
    "name": "password2",
    "value": "IDOIklOmV9ntwmqYZUdV3+LsFXc8/mVs"
  }],
  "username": "serviceacr"
}'

acr_name=$(echo $acr_out | jq -r .username)

resource_group=asconeboxrg$user
keyvault_name=asconeboxkv$user
storage_account=asconeboxsa$user
ensure_region_and_env
dogfood_keyvault=ascdevkvrpeusa
dogfood_acr_rg=azdmss-dogfood
dogfood_acr=serviceac


# output variables
echo "##vso[task.setvariable variable=RESOURCE_GROUP;isOutput=true]$resource_group"
echo "##vso[task.setvariable variable=KEYVAULT_NAME;isOutput=true]$keyvault_name"
echo "##vso[task.setvariable variable=STORAGE_ACCOUNT;isOutput=true]$storage_account"
echo "##vso[task.setvariable variable=USER;isOutput=true]$user"
echo "##vso[task.setvariable variable=ACR_NAME;isOutput=true]$acr_name"

echo "echo '##vso[task.setvariable variable=STORAGE_ACCOUNT;isOutput=true]$storage_account'"

cat <<EOF
================================================================================
"RESOURCE_GROUP": "$resource_group"
"KEYVAULT_NAME": "$keyvault_name"
"STORAGE_ACCOUNT": "$storage_account"
"USER": "$user"
"ACR_NAME": "$acr_name"
================================================================================
EOF