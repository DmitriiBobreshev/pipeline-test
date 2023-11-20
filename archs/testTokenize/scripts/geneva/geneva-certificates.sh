#!/bin/bash

GENEVA_CERT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
source "$GENEVA_CERT_DIR/../lib/logging.sh"

GENEVA_KEYWORD=".geneva.keyvault"       # geneva certifricates must contain this string

declare -A geneva_certificate_names=(
    ["Geneva-Log"]=get_log_trusted_domain_name
    ["Geneva-Metric"]=get_mdm_trusted_domain_name
)

declare -A geneva_log_trusted_names_map=(
    ["Azure-PROD"]="log.geneva.keyvault.azureappplatform.io"
    ["Azure-DEV"]="test.log.geneva.keyvault.azureappplatform.io"
    ["Azure-ONEBOX"]="test.log.geneva.keyvault.azureappplatform.io"
    ["CHINA-PROD"]="log.geneva.keyvault.appplatform.azure.cn"
    ["CHINA-DEV"]="log.geneva.keyvault.appplatform-test.azure.cn"
    ["GOVERNMENT-PROD"]="log.geneva.keyvault.appplatform.azure.us"
    ["GOVERNMENT-DEV"]="log.geneva.keyvault.appplatform-test.azure.us"
)

declare -A geneva_mdm_trusted_names_map=(
    ["Azure-PROD"]="mdm.geneva.keyvault.azureappplatform.io"
    ["Azure-DEV"]="test.mdm.geneva.keyvault.azureappplatform.io"
    ["Azure-ONEBOX"]="test.mdm.geneva.keyvault.azureappplatform.io"
    ["CHINA-PROD"]="mdm.geneva.keyvault.appplatform.azure.cn"
    ["CHINA-DEV"]="mdm.geneva.keyvault.appplatform-test.azure.cn"
    ["GOVERNMENT-PROD"]="mdm.geneva.keyvault.appplatform.azure.us"
    ["GOVERNMENT-DEV"]="mdm.geneva.keyvault.appplatform-test.azure.us"
)

function get_log_trusted_domain_name()
{
    local cloud="$1"
    local environment="$2"

    key="$cloud-$environment"
    name=${geneva_log_trusted_names_map[$key]}
    log_info "Geneva log trusted name for $cloud/$environment: $name"
    echo "$name"
}

function get_mdm_trusted_domain_name()
{
    local cloud="$1"
    local environment="$2"

    key="$cloud-$environment"
    name=${geneva_mdm_trusted_names_map[$key]}
    log_info "Geneva mdm trusted name for $cloud/$environment: $name"
    echo "$name"
}

function ensure_geneva_certificate()
{
    cloud="$1"
    environment="$2"
    region="$3"
    vault_name="$4"
    name="$5"

    log_info "Ensuring geneva certificate $cloud/$environment/$region, keyvault=$vault_name, name=$name"

    id=$(az keyvault certificate show --vault-name "$vault_name" -n "$name" --query "id" -o tsv 2>/dev/null) || true
    if [[ -n "$id" ]]; then
        log_info "Geneva certificate $name already exists, id=$id."
        return
    fi

    domain_name_selector=${geneva_certificate_names["$name"]}
    [[ -z "$domain_name_selector" ]] && log_fatal "Unsupported certificate name: $name"

    TRUSTED_DOMAIN_NAME=$("$domain_name_selector" "$cloud" "$environment")
    # regional subject name
    SUBJECT_NAME=${TRUSTED_DOMAIN_NAME/$GENEVA_KEYWORD/.$region$GENEVA_KEYWORD}

    export TRUSTED_DOMAIN_NAME SUBJECT_NAME REGIONAL_TRUSTED_DOMAIN_NAME
    policy=$(envsubst < "$GENEVA_CERT_DIR/geneva-certificate-policy.json")
    log_info "Create new certificate $name in keyvault $vault_name:\n $policy"
    az keyvault certificate create --vault-name "$vault_name" -n "$name" -p "$policy"
    az keyvault certificate show --vault-name "$vault_name" -n "$name"
}

geneva_cert_names=("Geneva-Metric" "Geneva-Log")
function ensure_geneva_certificates_in_keyvault()
{
    cloud="$1"
    environment="$2"
    region="$3"
    vault_name="$4"

    for name in "${geneva_cert_names[@]}"; do
        ensure_geneva_certificate "$cloud" "$environment" "$region" "$vault_name" "$name"
    done
}
