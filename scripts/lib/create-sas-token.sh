#!/bin/bash

# https://docs.microsoft.com/en-us/azure/key-vault/secrets/overview-storage-keys
# please apply for keyvault permisison in step 2
function create_sas_token() {
    keyvault_objectid=$1
    storage_account_id=$2
    keyvault_name=$3
    sas_entity_name=$4
    storage_account_name=$5
    sas_definition=$6
    regeneration_period=$7
    validity_period=$8
    expiry=$9
    create_sas_uri_func=${10}

    # 1. Give Key Vault access to the storage accounts
    echo "Giving Key Vault access to the storage accounts..."
    grant_storage_account_key_operator_service_role $keyvault_objectid "$storage_account_id"

    # 2. Give your user account permission to managed storage accounts
    # user_account=$(az account show --query user.name -o tsv)

    # echo "Giving user account $user_account permission to managed storage accounts..."
    # Please run this separately and apply for this permission through JIT
    # az keyvault set-policy -g $keyvault_resource_group --name $keyvault_name --upn $user_account --storage-permissions get list delete set update regeneratekey getsas listsas deletesas setsas recover backup restore purge

    # 3. Create Key Vault Managed storage accounts
    echo "Creating Key Vault Managed storage accounts..."
    az keyvault storage add --vault-name $keyvault_name -n $storage_account_name --active-key-name key1 --resource-id "$storage_account_id" --auto-regenerate-key true --regeneration-period $regeneration_period

    # 4. Create shared access signature tokens
    echo "Create shared access signature tokens..."
    sas_uri=$($create_sas_uri_func $expiry $sas_entity_name $storage_account_name)

    # 5. Generate a shared access signature definition
    echo "Generating SAS definitions in akv..."
    az keyvault storage sas-definition create --vault-name $keyvault_name --account-name $storage_account_name -n $sas_definition --validity-period $validity_period --sas-type service --template-uri $sas_uri
}