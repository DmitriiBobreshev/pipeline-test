#!/bin/bash

# Wiki page:
# https://msazure.visualstudio.com/AzureDMSS/_wiki/wikis/AzureDMSS.wiki/595117/Certificates-ServiceRuntime-SysIngressController

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
source "$SCRIPT_DIR/../lib/logging.sh"

set -x

declare -A runtime_cert_postfix=(
    ["Azure-DEV"]="asc-test.net"
    ["Azure-ONEBOX"]="asc-test.net"
    ["Azure-PROD"]="azuremicroservices.io"
    ["CHINA-DEV"]="microservices-test.azure.cn"
    ["CHINA-PROD"]="microservices.azure.cn"
    ["GOVERNMENT-DEV"]="microservices-test.azure.us"
    ["GOVERNMENT-PROD"]="microservices.azure.us"
)

declare -A runtime_cert_prefix=(
    ["runtime-customer"]="*"
    ["runtime-svc"]="*.svc"
    ["runtime-test"]="*.test"
    ["runtime-customer-private"]="*.private"
    ["runtime-svc-private"]="*.svc.private"
    ["runtime-test-private"]="*.test.private"
)

function ensure_public_ca()
{
    local keyvault_name="$1"
    log_info "Ensure OneCertV2-PublicCA in keyvault $keyvault_name"
    az keyvault certificate issuer create --vault-name "$keyvault_name" --issuer-name OneCertV2-PublicCA --provider-name OneCertV2-PublicCA
}

function ensure_runtime_certificates()
{
    local cloud="$1"
    local environment="$2"
    local region="$3"
    local vault_name="$4"

    for name in "${!runtime_cert_prefix[@]}"; do
        log_info "Ensuring runtime certificates $cloud/$environment/$region, keyvault=$vault_name, name=$name"
        ensure_single_runtime_certificate "$cloud" "$environment" "$region" "$vault_name" "$name"
    done
}

function ensure_single_runtime_certificate()
{
    local cloud="$1"
    local environment="$2"
    local region="$3"
    local vault_name="$4"
    local name="$5"

    id=$(az keyvault certificate show --vault-name "$vault_name" -n "$name" --query "id" -o tsv 2>/dev/null) || true
    if [[ -n "$id" ]]; then
        log_info "runtime certificate $name already exists, id=$id."
        return
    fi

    log_info "Creating runtime certificate $vault_name/$name"
    prefix=${runtime_cert_prefix["$name"]}
    [[ -z "$prefix" ]] && log_fatal "Unsupported certificate name: $name"

    postfix=${runtime_cert_postfix["$cloud-$environment"]}
    [[ -z "$postfix" ]] && log_fatal "Unsupported environment: $environment"

    CA_ISSUER="OneCertV2-PublicCA"
    SUBJECT_NAME="$prefix.$postfix"
    REGIONAL_SUBJECT_NAME="$prefix.$region.$postfix"

    export CA_ISSUER SUBJECT_NAME REGIONAL_SUBJECT_NAME
    policy=$(envsubst < "$SCRIPT_DIR/certificate-policy.json")
    az keyvault certificate create --vault-name "$vault_name" -n "$name" -p "$policy"
    az keyvault certificate show --vault-name "$vault_name" -n "$name"

    unset CA_ISSUER SUBJECT_NAME REGIONAL_SUBJECT_NAME
}