#!/usr/bin/env bash

# common.sh is build based on the following two variables
# * DEPLOY_ENVIRONMENT - the target environment, should be the normalized result of normalize_environment
# * REGION - the target region, should be the result of region_normalize_to_short (in region.sh)
#
# Scripts that include this library should provide the above two variables, and call ensure_region_and_env before
# proceeding to the actual logic.

shopt -s lastpipe   # run the last segment of a pipeline in the current shell
shopt -so pipefail  # reflect a pipeline's first failing command's exit code in $?

COMMON_SH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
source "$COMMON_SH_DIR/logging.sh"
source "$COMMON_SH_DIR/region.sh"
source "$COMMON_SH_DIR/create-sas-token.sh"

export NEW_RP=true
export PREFIX=asc
CLOUD=Azure

export CLOUD_CONFIGURATION_VOLUME_PATH="/etc/config"

function get_aad_group_object_id() {
    # Now we can assume all productions are in AME
    if is_ame; then
        echo "c0c0ae30-6425-4773-b95a-ad665bec86ba" # ESGJIT-AzDMSS
    elif is_azure; then
        echo "17b08a03-876b-43e6-bf60-d5c98d4ebee3" # Azure Spring Cloud SG
    elif is_china && is_prod; then
        echo "f2a4d205-e363-4159-9030-21ffc3a25dd8"
    elif is_china; then
        echo "f4d9f971-2cfc-471b-a3cc-d72454165e7b"
    elif is_government && is_prod; then
        echo "dc923571-bd62-4375-b212-ffc54b3bdc3a" # ESGJIT-AzDMSS for Fairfax
    elif is_government; then
        echo "a71bb29c-45c3-4601-a5c5-e167378fbfaa" # Azure Spring Cloud
    fi
}

# Get the subscription for the resource provider specific resources
function get_rp_subscription() {
    if is_prod; then
        if is_ame; then
            echo "203dfa53-bfa1-47c6-945d-16119dff147e"
        elif is_china; then
            echo "75d194aa-ea10-43fc-bb9d-31d8ace06d14"
        elif is_government; then
            echo "bc747765-f999-47c8-9b47-be31585acb28"
        else
            echo "5e64a996-7e77-40a1-9ae2-76947a4750a9"
        fi
    elif is_oneBox; then
        echo "799c12ba-353c-44a1-883d-84808ebb2216"
    else
        if is_china; then
            echo "2f4bac9c-21fa-4a5e-a5fd-ae959117b574"
        elif is_government; then
            echo "d8706dee-19b4-4962-803e-f73e101d2375"
        else
            echo "d51e3ffe-6b84-49cd-b426-0dc4ec660356"
        fi
    fi
}

# Get the resource subscriptions (space separated) for the user resources.
function get_resource_subscription_list() {
    if is_prod; then
        get_user_subscription_ids $REGION
    else
        if is_china; then
            echo "2f4bac9c-21fa-4a5e-a5fd-ae959117b574" # Azure Spring Cloud Mooncake Test
        elif is_government; then
            echo "d8706dee-19b4-4962-803e-f73e101d2375" # Azure Spring Cloud Dogfood Hosting Fairfax
        else
            # for DogFood (dev)
            # Azure Spring Cloud DevINT
            echo "d51e3ffe-6b84-49cd-b426-0dc4ec660356"
        fi
    fi
}

function get_rp_certificate_thumbprints() {
    local vault_name
    vault_name=$(get_shared_keyvault)
    get_secret "$vault_name" "AzureMss-Rp-CertificateThumbprints"
}

function get_ev2_identity_id() {
    if is_ame; then
        echo "26b50feb-95c1-4c6a-9e21-062ea0682bb1"
    elif is_china && is_prod; then
        echo "676d9836-3b62-4ecc-b956-1169448432e5"
    elif is_china; then
        echo "ef120474-2509-4502-b337-cfe679c7b7c7"
    elif is_government && is_prod; then
        echo "74136ec5-3475-4c52-9669-50fd79731140"
    elif is_government; then
        echo "e0e68b72-6d80-4819-8b33-cff726ffa8fc"
    else
        echo "f878b85b-1e88-4ff5-9185-d7100afb5059"
    fi
}

function get_tenant_id() {
    if is_ame; then
        echo "33e01921-4d64-4f8c-a055-5bdaffd5e33d"
    elif is_china && is_prod; then
        echo "a55a4d5b-9241-49b1-b4ff-befa8db00269"
    elif is_china; then
        echo "3d0a72e2-8b06-4528-98df-1391c6f12c11"
    elif is_government && is_prod; then
        echo "cab8a31a-1906-4287-a0d8-4eef66b95f6e"
    elif is_government; then
        echo "63296244-ce2c-46d8-bc36-3e558792fbee"
    else
        echo "72f988bf-86f1-41af-91ab-2d7cd011db47"
    fi
}

# The default verified domain for the hosting Tenant. This is the primary domain in
#     Azure Active Directory -> Custom domain names
# It's used to setup multi-tenant enabled service principal.
function get_verified_tenant_domain() {
    if is_ame; then
        echo msazurecloud.onmicrosoft.com
    elif is_china && is_prod; then
        echo ChinaGovCloud.partner.onmschina.cn
    elif is_china; then
        echo mcdevops.partner.onmschina.cn
    elif is_government && is_prod; then
        echo USGovCloud.onmicrosoft.com
    elif is_government; then
        echo fairfaxdevops.onmicrosoft.com
    else
        echo microsoft.onmicrosoft.com
    fi
}

# Some of the configuration are shared for all regions and we store them in a shared KeyVault.
# During deployment, we copy the data from the shared KeyVault to the regional target KeyVault.
function get_shared_keyvault() {
    if is_prod; then
        if is_ame || is_china || is_government; then
            echo "${PREFIX}prodkvshareda"
        else
            echo "${PREFIX}prodkvsharedmsa"
        fi
    else
        echo ascdevkvshareda
    fi
}

function get_arm_cert_uri() {
    if is_china; then
        echo "https://management.chinacloudapi.cn:24582/metadata/authentication?api-version=2015-01-01"
    elif is_government; then
        echo "https://management.usgovcloudapi.net:24582/metadata/authentication?api-version=2015-01-01"
    elif is_prod; then
        echo "https://management.azure.com:24582/metadata/authentication?api-version=2015-01-01"
    else
        echo "https://api-dogfood.resources.windows-int.net:24582/metadata/authentication?api-version=2015-01-01"
    fi
}

function get_dns_zone_name() {
    if is_china && is_prod; then
        echo "microservices.azure.cn"
    elif is_china; then
        echo "microservices-test.azure.cn"
    elif is_azure && is_prod; then
        echo "azuremicroservices.io"
    elif is_government && is_prod; then
        echo "microservices.azure.us"
    elif is_government; then
        echo "microservices-test.azure.us"
    else
        echo "asc-test.net"
    fi
}

function get_graph_endpoint() {
    if is_china; then
        echo "microsoftgraph.chinacloudapi.cn"
    elif is_government; then
        echo "graph.microsoft.us" # dod-graph.microsoft.us if US Government L5 (DOD)
    elif is_azure; then
        echo "graph.microsoft.com"
    else
        log_fatal "Unknown env '$CLOUD'" >&2
    fi
}

function get_rp_dns_zone_name() {
    if is_china && is_prod; then
        echo "appplatform.azure.cn"
    elif is_china; then
        echo "appplatform-test.azure.cn"
    elif is_government && is_prod; then
        echo "appplatform.azure.us"
    elif is_government; then
        echo "appplatform-test.azure.us"
    elif is_dev; then
        echo "test.azureappplatform.io"
    else
        echo "azureappplatform.io"
    fi
}

function get_dns_zone_resource_group() {
    if is_prod; then
        if is_government; then
            echo "ascprodrgshareda"
        else
            echo "amss-rp-shared"
        fi
    else
        if is_government; then
            echo "ascdevrgshareda"
        else
            echo "azdmss-dogfood"
        fi
    fi
}

function get_dns_zone_resource_id {
    local subscription rg dns_name
    subscription=$(get_rp_subscription)
    rg=$(get_dns_zone_resource_group)
    dns_name=$(get_dns_zone_name)
    echo "/subscriptions/${subscription}/resourceGroups/${rg}/providers/Microsoft.Network/dnszones/${dns_name}"
}

function get_legion_dns_zone_resource_id {
    local subscription rg dns_name region
    subscription=$(get_rp_subscription)
    rg=$(get_dns_zone_resource_group)
    dns_name="$LONG_REGION.$(get_dns_zone_name)"
    echo "/subscriptions/${subscription}/resourceGroups/${rg}/providers/Microsoft.Network/dnszones/${dns_name}"
}

function get_custom_domain_fpa_client_id() {
    local client_id
    if is_prod; then
        client_id=03b39d0f-4213-4864-a245-b1476ec03169
    else
        client_id=584a29b4-7876-4445-921e-71e427d4f4b3
    fi
    echo $client_id
}

function get_resource_provider_fpa_client_id() {
    local client_id
    if is_prod; then
        client_id=e8de9221-a19c-4c81-b814-fd37c6caf9d2
    else
        client_id=584a29b4-7876-4445-921e-71e427d4f4b3
    fi
    echo $client_id
}

function add_cname_record() {
    local cname_value=$1
    local infix=${2:-resourceprovider}
    local rg dns_name record_name
    log_info "add cname for $cname_value"
    if is_prod || is_china || is_government; then
        rg=$(get_dns_zone_resource_group)
        dns_name=$(get_rp_dns_zone_name)
        log_trace "add_cname_record LONG_REGION = $LONG_REGION"
        log_trace "add_cname_record infix = $infix"
        record_name="${LONG_REGION}.${infix}"
        log_trace "add_cname_record record_name = $record_name"
        # Create an empty CNAME record set
        fqdn=$(az network dns record-set cname create -g "${rg}" -z "${dns_name}" -n "${record_name}" --query fqdn -o tsv)
        log_trace "add_cname_record fqdn1 = $fqdn"
        # Set the value of a CNAME record
        fqdn=$(az network dns record-set cname set-record -g "${rg}" -z "${dns_name}" -n "${record_name}" -c "${cname_value}" --query fqdn -o tsv)
        log_trace "add_cname_record fqdn2 = $fqdn"
        normalized_fqdn=$(sed -e 's/\.$//g' <<<"${fqdn}") # It return fqdn like "a.com.", need to remove the last dot
        log_trace "add_cname_record normalized_fqdn = $normalized_fqdn"
        echo "${normalized_fqdn}"
    else
        log_warn "Add CNAME record $LONG_REGION.$infix.test.azureappplatform.io -> ${cname_value} in AME tenant"
        echo "$LONG_REGION.$infix.test.azureappplatform.io"
    fi
}

# migrate domain azureapps.io -> azuremicroservice.io
function get_legacy_dns_zone_resource_id {
    if is_china; then
        echo "" # no legacy domain in mooncake
    elif is_government; then
        echo "" # no legacy domain in fairfax
    elif is_prod; then
        echo "/subscriptions/203dfa53-bfa1-47c6-945d-16119dff147e/resourceGroups/amss-rp-shared/providers/Microsoft.Network/dnszones/azureapps.io"
    else
        echo "/subscriptions/d51e3ffe-6b84-49cd-b426-0dc4ec660356/resourceGroups/azdmss-dogfood/providers/Microsoft.Network/dnszones/azdmss-test.net"
    fi
}

# we only support v2 in 4 regions + 2 test regions
# test region, "eastus2euap", "westcentralus"
# customer facing region, "eastus", "eastus2", "westeurope", "westus2"
function is_supported_v2_region() {
    local region=$1
    local region_array=("eastus2euap" "westcentralus" "eastus" "eastus2" "westeurope" "westus2")
    for r in "${region_array[@]}"; do
        if [[ "$r" == "$region" ]]; then
            return 0
        fi
    done
    return 1
}

function v2_supported() {
    local region=$1
    if is_azure; then
        if is_prod; then
            return $(is_supported_v2_region "$region")
        else
            return 0 # true, for public dogfood
        fi
    fi
    return 1 # false, for non-public cloud
}

function prepare_acr_properties() {
    log_info "Prepare ACR properties"
    if is_prod && is_china; then
        acr_name=ascprodacrglobalrp
        acr_resource_group=amss-rp-shared
        acr_subscription=75d194aa-ea10-43fc-bb9d-31d8ace06d14
        acr_region=chinaeast2
        acr_suffix=azurecr.cn
        public_acr_and_repo_prefix=$acr_name.$acr_suffix
    elif is_china; then
        acr_name=ascdevacrglobalrp
        acr_resource_group=amss-rp-shared
        acr_subscription=2f4bac9c-21fa-4a5e-a5fd-ae959117b574
        acr_region=chinaeast2
        acr_suffix=azurecr.cn
        public_acr_and_repo_prefix=$acr_name.$acr_suffix
    elif is_prod && is_government; then
        acr_name=ascprodacrglobalrp
        acr_resource_group=ascprodrgshareda
        acr_subscription=bc747765-f999-47c8-9b47-be31585acb28
        acr_region=usgovvirginia
        acr_suffix=azurecr.us
        public_acr_and_repo_prefix=$acr_name.$acr_suffix
    elif is_government; then
        acr_name=ascdevacrglobalrp
        acr_resource_group=ascdevrgshareda
        acr_subscription=d8706dee-19b4-4962-803e-f73e101d2375
        acr_region=usgovvirginia
        acr_suffix=azurecr.us
        public_acr_and_repo_prefix=$acr_name.$acr_suffix
    elif is_prod && is_azure; then
        acr_name=ascprodacrglobalrp
        acr_resource_group=amss-rp-shared
        acr_subscription=203dfa53-bfa1-47c6-945d-16119dff147e
        acr_region=eastus
        acr_suffix=azurecr.io
        public_acr_and_repo_prefix=mcr.microsoft.com/azurespringapps # we use mcr in public cloud
    else
        # single ACR for local / dogfood
        acr_name=serviceacr
        acr_resource_group=azdmss-dogfood
        acr_subscription=d51e3ffe-6b84-49cd-b426-0dc4ec660356
        acr_region=eastus
        acr_suffix=azurecr.io
        public_acr_and_repo_prefix=mcr.microsoft.com/azurespringapps
    fi
    
    if is_prod && is_azure; then
        control_plane_acr_name=asaprodacrcontrolplane
    else
        control_plane_acr_name=$acr_name
    fi
    log_info "public_acr_and_repo_prefix $public_acr_and_repo_prefix, control_plane_acr_name $control_plane_acr_name, acr_name: $acr_name, resource group: $acr_resource_group, subscription: $acr_subscription"
}

function prepare_vault_name() {
    VAULT_NAME=$(generate_resource_name kv rp)
    log_info "KeyVault: $VAULT_NAME"
}

function get_keyvault_suffix() {
    if is_china; then
        echo "vault.azure.cn"
    elif is_government; then
        if is_prod; then
            echo "vault.azure.us"
        else
            echo "vault.usgovcloudapi.net"
        fi
    else
        echo "vault.azure.net"
    fi
}

function prepare_e2e_properties() {
    E2E_VAULT_NAME=$(generate_resource_name kv e2e)
    E2E_SECRET_NAME=e2epat
    log_info "KeyVault: $E2E_VAULT_NAME, E2E secrete name: $E2E_SECRET_NAME"
}

function normalize_environment() {
    local env
    # shellcheck disable=SC2018
    # shellcheck disable=SC2019
    env=$(tr a-z A-Z <<<"$1")
    case "$env" in
    PROD | PRODUCTION)
        echo PROD
        ;;
    DOGFOOD | INT | DEV)
        echo DEV
        ;;
    LOCAL)
        echo LOCAL
        ;;
    ONEBOX)
        echo ONEBOX
        ;;
    *)
        log_fatal "Unknown environment: $1"
        ;;
    esac
}

function normalize_cloud() {
    local cloud
    # shellcheck disable=SC2018
    # shellcheck disable=SC2019
    cloud=$(tr a-z A-Z <<<"$1")
    case $cloud in
    GOVERNMENT)
        echo GOVERNMENT
        ;;
    CHINA | MOONCAKE)
        echo CHINA
        ;;
    *)
        echo Azure
        ;;
    esac
}

function normalize_service() {
    local service
    # shellcheck disable=SC2018
    # shellcheck disable=SC2019
    service=$(tr A-Z a-z <<<"$1")
    case $service in
    acis)
        echo acis
        ;;
    *)
        echo rp
        ;;
    esac
}

# Keyvault Service Princial application IDs
# https://docs.microsoft.com/en-us/azure/key-vault/secrets/overview-storage-keys#service-principal-application-id
# 1. Azure AD
#    Azure Government
#    7e7c393b-45d0-48b1-a35e-2905ddf8183c
#
# 2. Azure AD
#    Azure public
#    cfa8b339-82a2-471a-a3c9-0fc0be7a4093
#
# 3. Other
#    Any
#    cfa8b339-82a2-471a-a3c9-0fc0be7a4093

function get_keyvault_service_object_id() {
    local application_id
    if is_government; then
        application_id=7e7c393b-45d0-48b1-a35e-2905ddf8183c
    else
        application_id=cfa8b339-82a2-471a-a3c9-0fc0be7a4093
    fi

    az ad sp show --id $application_id --query id -o tsv
}

function grant_storage_account_key_operator_service_role() {
    local assignee="$1"
    local scope="$2"
    az role assignment create --role "Storage Account Key Operator Service Role" --assignee "$assignee" --scope "$scope" >/dev/null
    log_info "Successfully granted Storage Account Key Operator Service Role for $scope"
}

function is_prod() {
    # Production
    [[ "$DEPLOY_ENVIRONMENT" == "PROD" ]]
}

function is_dev() {
    # DogFood
    [[ "$DEPLOY_ENVIRONMENT" == "DEV" ]]
}

function is_local() {
    # Local development
    [[ "$DEPLOY_ENVIRONMENT" == "LOCAL" ]]
}

function is_oneBox() {
    [[ "$DEPLOY_ENVIRONMENT" == "ONEBOX" ]]
}

function is_azure() {
    [[ "$CLOUD" == "Azure" ]]
}

function is_china() {
    [[ "$CLOUD" == "CHINA" ]]
}

function is_government() {
    [[ "$CLOUD" == "GOVERNMENT" ]]
}

function is_ame() {
    # AME tenant
    is_prod && is_azure && [[ "$PREFIX" == asc ]]
}

function ensure_region_and_env() {
    log_info "Ensure region and deploy environment"
    if [[ -z "$REGION" ]]; then
        log_fatal "Region is not specified"
    fi
    if [[ -z "$DEPLOY_ENVIRONMENT" ]]; then
        log_fatal "Deploy environment is not specified"
    fi
    LONG_REGION=$(region_short_to_long "$REGION")
    export REGION DEPLOY_ENVIRONMENT LONG_REGION
    log_info "Deploy environment: $DEPLOY_ENVIRONMENT, region: $REGION / $LONG_REGION"
}

function ensure_dependencies() {
    for exe in "$@"; do
        log_info "Checking if $exe is available"
        if ! command -v "$exe" >/dev/null; then
            log_fatal "$exe is not installed"
        fi
    done
}

function generate_resource_name() {
    local resource_type="$1"
    local usage="$2"
    local index="$3"
    local skip_region="$4"
    if [[ -z "$index" ]]; then
        index=a
    fi
    local env=dev
    if is_prod; then
        env=prod
    elif is_local; then
        env="loc${USER}"
    elif is_oneBox; then
        env="onebox${USER}"
    fi

    if [[ -z $skip_region ]]; then
        echo "${PREFIX}${env}${resource_type}${usage}${REGION}${index}"
    else
        echo "${PREFIX}${env}${resource_type}${usage}${index}"
    fi
}

function generate_resource_name_with_given_region() {
    local resource_type="$1"
    local usage="$2"
    local index="$3"
    local given_region="$4"
    if [[ -z "$index" ]]; then
        index=a
    fi
    local env=dev
    if is_prod; then
        env=prod
    elif is_local; then
        env="loc${USER}"
    elif is_oneBox; then
        env="onebox${USER}"
    fi

    echo "${PREFIX}${env}${resource_type}${usage}${given_region}${index}"
}

# We switch the indexes from a to b to enable AAD
# For eastus/eus dogfood we rebuild aks using vmss and switch indexes from b to c
# For westcentralus/wcus we rebuild aks for aks upgrade and switch indexes from c to d
# For eus2euap/eastus2euap/cus/centralus/wus2/westus2/eus/eastus/neu/northeurope/eus2/eastus2/aue/australiaeast/
# weu/westeurope/scus/southcentralus/uks/uksouth/sea/southeastasia we rebuild aks for aks upgrade and switch indexes
# from b to c
declare -A RP_CLUSTER_UPGRADE_NAMES=(
    [eus2euap]=eastus2euap
    [cus]=centralus
    [wus2]=westus2
    [eus]=eastus
    [neu]=northeurope
    [eus2]=eastus2
    [aue]=australiaeast
    [weu]=westeurope
    [scus]=southcentralus
    [uks]=uksouth
    [sea]=southeastasia
    [wcus]=westcentralus
    [cnn2]=chinanorth2
    [cne2]=chinaeast2
)
function generate_aks_name_for_rp() {
    if [[ "$REGION" == "westcentralus" || "$REGION" == "wcus" ]]; then
        generate_resource_name aks rp d
    elif is_dev && [[ "$REGION" == "chinanorth2" || "$REGION" == "cnn2" ]]; then
        generate_resource_name aks rp c
    elif is_prod && [[ -n "${RP_CLUSTER_UPGRADE_NAMES[$REGION]}" ]]; then
        generate_resource_name aks rp c
    elif is_dev && [[ "$REGION" == "eastus" || "$REGION" == "eus" ]]; then
        generate_resource_name aks rp c
    else
        generate_resource_name aks rp b
    fi
}

# For eastus/eus dogfood we rebuild public ip and switch indexes from b to c
# For eus2euap/eastus2euap/cus/centralus/wus2/westus2/eus/eastus/neu/northeurope/eus2/eastus2/aue/australiaeast/
# weu/westeurope/scus/southcentralus/uks/uksouth/sea/southeastasia/wcus/westcentralus we rebuild public ip and
# switch indexes from b to c
function generate_public_ip_for_rp() {
    if is_dev && [[ "$REGION" == "eastus" || "$REGION" == "eus" ]]; then
        generate_resource_name ip rp c
    elif is_dev && [[ "$REGION" == "chinanorth2" || "$REGION" == "cnn2" ]]; then
        generate_resource_name ip rp c
    elif is_prod && [[ -n "${RP_CLUSTER_UPGRADE_NAMES[$REGION]}" ]]; then
        generate_resource_name ip rp c
    else
        generate_resource_name ip rp b
    fi
}

# For eastus/eus dogfood we rebuild dns name and switch indexes from b to c
# For eus2euap/eastus2euap/cus/centralus/wus2/westus2/eus/eastus/neu/northeurope/eus2/eastus2/aue/australiaeast/
# weu/westeurope/scus/southcentralus/uks/uksouth/sea/southeastasia/wcus/westcentralus we rebuild dns name and
# switch indexes from b to c
function generate_dns_name_for_rp() {
    if is_dev && [[ "$REGION" == "eastus" || "$REGION" == "eus" ]]; then
        generate_resource_name '' rp c true
    elif is_dev && [[ "$REGION" == "chinanorth2" || "$REGION" == "cnn2" ]]; then
        generate_resource_name '' rp c true
    elif is_prod && [[ -n "${RP_CLUSTER_UPGRADE_NAMES[$REGION]}" ]]; then
        generate_resource_name '' rp c true
    else
        generate_resource_name '' rp b true
    fi
}

# Adjust the replicas number according to environment and region
# For DogFood / Canary / Pilot, the maximum replicas is limited to 2
# Specially, for MoonCake DogFood and Fairfax Dogfood, the maximum replicas is limited to 1 because we only have 100 cores quota in total
# in this region, which needs to be shared among RP cluster, service runtime clusters, system clusters and user clusters.
function adjust_replicas() {
    local replicas_hint replicas

    replicas_hint="$1"
    if [[ -z "$replicas_hint" ]]; then
        replicas_hint=1
    fi

    if is_dev && [[ "$REGION" == cnn2 ]] || is_government; then
        # MoonCake and Fairfax DogFood
        replicas=1
    elif is_dev || [[ "$REGION" == eus2euap || "$REGION" == wcus ]]; then
        # DogFood / Canary / Pilot
        replicas=$(( replicas_hint > 2 ? 2 : replicas_hint ))
    elif is_china || is_government; then
        # Mooncake and Fairfax prod
        replicas=$(( replicas_hint > 4 ? 4 : replicas_hint ))
    else
        # Other production regions
        replicas="$replicas_hint"
    fi

    echo "$replicas"
}

# Adjust the replicas number according to environment and region
# For eastus2 (special conf for morgan)lifecycle memory will be set to 6GB, others will set to 4GB
function adjust_lc_mem() {
    local mem_hint mem

    mem_hint="$1"
    if [[ -z "$mem_hint" ]]; then
        mem_hint="4000Mi"
    fi

    if is_prod && [[ "$REGION" == eastus2 ]]; then
        mem="6000Mi"
    else
        # Other regions
        mem="$mem_hint"
    fi

    echo "$mem"
}

function get_configmap_name() {
    if [[ "$SERVICE" == "rp" ]]; then
        echo "appsettings-configmap"
    else
        echo "acis-appsettings-configmap"
    fi
}

function set_secret() {
    local vault_name="$1"
    local name="$2"
    local value="$3"
    local fallback_name="$4"

    if [[ -f "$value" ]]; then
        az keyvault secret set --vault-name "$vault_name" --name "$name" --file "$value"
        if [[ -n $fallback_name ]]; then
            az keyvault secret set --vault-name "$vault_name" --name "$fallback_name" --file "$value"
        fi
    else
        az keyvault secret set --vault-name "$vault_name" --name "$name" --value "$value"
        if [[ -n $fallback_name ]]; then
            az keyvault secret set --vault-name "$vault_name" --name "$fallback_name" --value "$value"
        fi
    fi
}

function get_secret() {
    local vault_name="$1"
    local name="$2"
    local fallback_name="$3"

    local value
    value="$(az keyvault secret show --vault-name "$vault_name" --name "$name" --query value -o tsv 2>/dev/null)"
    if [[ $? != 0 || -z $value ]]; then
        value="$(az keyvault secret show --vault-name "$vault_name" --name "$fallback_name" --query value -o tsv)"
        [[ $? != 0 || -z $value ]] && exit $?
    fi

    echo "$value"
}

function length_limit() {
    local name="$1"
    local value="$2"
    local limit="$3"

    local length="${#value}"
    if [[ "$length" -gt "$limit" ]]; then
        log_fatal "Parameter '$name' exceeds length limit $limit (was $length)"
    fi
}

function download_keyvault_cert_and_append_ca() {
    local vault_name=$1
    local cert_name=$2
    local dir="$3"

    download_keyvault_cert $vault_name $cert_name $dir

    # Most Linux servers like Nginx requires intermediate CA also bundled in the certificate
    local ISSUER CA_INDEX
    ISSUER=$(openssl x509 -issuer -in "$dir/cert.pem" -noout)
    CA_CN=$(echo "$ISSUER" | awk -F= '{print $NF}' | xargs)
    local INTERMEDIATE_CA="$COMMON_SH_DIR/intermediate-ca/$CA_CN.pem"

    if [ ! -f "$INTERMEDIATE_CA" ]; then
        log_fatal "Intermediate CA for issuer $ISSUER not found. Check your certificate chain."
        return 1
    fi

    log_info "Appending intermediate CA: $INTERMEDIATE_CA"
    cat "$INTERMEDIATE_CA" >>"$dir/cert.pem"
}

function download_keyvault_cert() {
    local vault_name=$1
    local cert_name=$2
    local dir="$3"
    if [[ -z "$dir" ]]; then
        dir="."
    else
        mkdir -p "$dir"
    fi

    # Fetch certificate from KeyVault and convert to cert.pem and cert.key
    local CERT_FORMAT
    CERT_FORMAT=$(az keyvault secret show --vault-name "$vault_name" -n "$cert_name" --query contentType)
    log_info "Certificate format of $vault_name/$cert_name is: $CERT_FORMAT"
    if [[ $CERT_FORMAT == "\"application/x-pkcs12\"" ]]; then
        # Got a PKCS12 file
        az keyvault secret download --vault-name "$vault_name" -n "$cert_name" --encoding base64 -f "$dir/cert.pfx"
        openssl pkcs12 -in "$dir/cert.pfx" -out "$dir/cert.key" -nocerts -nodes -passin pass:
        # "-nokeys -nodes" results in a chain with reversed order. Here just unpack client cert and append ca cert with intermediate-ca/*
        openssl pkcs12 -in "$dir/cert.pfx" -out "$dir/cert-with-bag.pem" -clcerts -nokeys -passin pass:
        openssl x509 -in "$dir/cert-with-bag.pem" -out "$dir/cert.pem"
        openssl rsa -in "$dir/cert.key" -out "$dir/cert.key"
        rm -f -- "$dir/cert-with-bag.pem"
    elif [[ $CERT_FORMAT == "\"application/x-pem-file\"" ]]; then
        # Got a PEM file with certificate and private key concatenated together
        az keyvault secret download --vault-name "$vault_name" -n "$cert_name" -f "$dir/cert-bundle.pem"
        openssl x509 -in "$dir/cert-bundle.pem" -out "$dir/cert.pem"
        openssl rsa -in "$dir/cert-bundle.pem" -out "$dir/cert.key"
        rm -f -- "$dir/cert-bundle.pem"
    else
        log_fatal "Unknown certificate format: $CERT_FORMAT"
        return 1
    fi
}

function prepare_aad_properties() {
    log_info "Prepare AAD properties"
    # Copy secret from shared keyvault to regional keyvault
    local dest=${1:-$VAULT_NAME}

    secrets_in_shared_keyvault=(
        AzureMss-Deploy-Aks-Aad-Group-ObjectId
        AzureMss-Deploy-Aks-Aad-Client-AppId
        AzureMss-Deploy-Aks-Aad-Server-AppId
        AzureMss-Deploy-Aks-Aad-Server-AppSecret
    )
    for secret in "${secrets_in_shared_keyvault[@]}"; do
        copy_secret_from_shared_keyvault "$secret" "$dest"
    done
}

function get_nginx_client_trust_ca() {
    log_info "Prepare Nginx client trusted root certificates"
    ROOT_CA_DIR="$COMMON_SH_DIR/root-ca"
    CLIENT_CERT_CA=$(cat "$ROOT_CA_DIR/ameroot.pem" "$ROOT_CA_DIR/DigiCertGlobalRootG2.pem" | base64 -w0)

    echo $CLIENT_CERT_CA
}

function get_rp_image_configmap_name() {
    local release_tag="$1"
    if [[ -z $release_tag || $release_tag == "latest" ]]; then
        echo "rp-image-env"
    else
        local normalized_tag
        normalized_tag=$(sed -e 's/[^0-9a-zA-Z]\+/-/g' <<<"$release_tag")
        echo "rp-image-env-$normalized_tag"
    fi
}

function copy_secret_from_shared_keyvault() {
    local source_name="$1"
    local target_keyvault="$2"
    local target_name="$3"
    local source_keyvault
    source_keyvault=$(get_shared_keyvault)
    if [[ "$source_keyvault" == "$target_keyvault" ]]; then
        # this may happen for dogfood
        return
    fi
    if [[ -z "$target_name" ]]; then
        target_name="$source_name"
    fi
    log_info "copy secret $source_keyvault/$source_name to $target_keyvault/$target_name"
    local source_value
    source_value=$(az keyvault secret show --vault-name "$source_keyvault" --name "$source_name" --query value -o tsv)
    if [[ $? != 0 || -z "$source_value" ]]; then
        log_fatal "Secret $source_name is not found in KeyVault $source_keyvault"
    fi

    local target_value
    target_value=$(az keyvault secret show --vault-name "$target_keyvault" --name "$target_name" --query value -o tsv 2>/dev/null) || true
    if [[ $? == 0 && "$target_value" == "$source_value" ]]; then
        # We won't copy if the source value is equal to target
        log_info "Skip copy as secret $source_keyvault/$source_name is equal to $target_keyvault/$target_name"
        return
    fi

    az keyvault secret set --vault-name "$target_keyvault" --name "$target_name" --value "$source_value" >/dev/null
}

function copy_secret_file_from_shared_keyvault() {
    local source_name="$1"
    local target_keyvault="$2"
    local encoding="$3"
    local target_name="$4"
    local source_keyvault
    source_keyvault=$(get_shared_keyvault)
    if [[ "$source_keyvault" == "$target_keyvault" ]]; then
        # this may happen for dogfood
        return
    fi
    if [[ -z "$encoding" ]]; then
        encoding=base64
    fi
    if [[ -z "$target_name" ]]; then
        target_name="$source_name"
    fi
    file=$(mktemp secret.tmp.XXXX)
    rm -f -- "$file"
    az keyvault secret download --vault-name "$source_keyvault" --name "$source_name" --file "$file"
    if [[ $? != 0 ]]; then
        log_fatal "Secret $source_name is not found in KeyVault $source_keyvault"
    fi
    az keyvault secret set --vault-name "$target_keyvault" --name "$target_name" --file "$file" --encoding "$encoding" >/dev/null
    rm -f -- "$file"
}

function copy_certificate_from_shared_keyvault() {
    local source_name="$1"
    local target_keyvault="$2"
    local encoding="$3"
    local target_name="$4"
    local source_keyvault
    source_keyvault=$(get_shared_keyvault)
    if [[ "$source_keyvault" == "$target_keyvault" ]]; then
        # this may happen for dogfood
        return
    fi
    if [[ -z "$target_name" ]]; then
        target_name="$source_name"
    fi
    if [[ -z "$encoding" ]]; then
        encoding=base64
    fi
    file=$(mktemp secret.tmp.XXXX.pfx)
    rm -f -- "$file"
    az keyvault secret download --vault-name "$source_keyvault" --name "$source_name" --file "$file" --encoding "$encoding"
    if [[ $? != 0 ]]; then
        log_fatal "Secret $source_name is not found in KeyVault $source_keyvault"
    fi
    az keyvault certificate import --vault-name "$target_keyvault" --name "$target_name" --file "$file" >/dev/null
    rm -f -- "$file"
}

function download_lckeyvault_jks_cert() {
    local dir="$1"
    local cert_name=lc-svc-https-prod-jks
    local keyvault_name
    keyvault_name=$(get_shared_keyvault)
    if ! is_prod; then
       cert_name=lc-svc-https-dev-jks
    fi

    secret="$(az keyvault secret show --vault-name $keyvault_name --name lc-cert-pw --query value -o tsv 2>/dev/null)"
    az keyvault secret download --vault-name $keyvault_name -n ${cert_name} --encoding base64 -f "$dir/cert.jks"
    echo $secret
}

function download_lckeyvault_pfx_cert() {
    local dir="$1"
    local cert_name=lifecycle-https
    local keyvault_name=$(get_shared_keyvault)

    az keyvault secret download --vault-name "$keyvault_name" -n "$cert_name" --encoding base64 -f "$dir/lchttps.pfx"
}

function download_srkeyvault_cert() {
    local dir="$1"
    local cert_name=lifecycleclient
    local keyvault_name
    keyvault_name=$(get_shared_keyvault)
    az keyvault secret download --vault-name "$keyvault_name" -n "$cert_name" --encoding base64 -f "$dir/srcert.pfx"
}

function download_customdomainfpa_cert() {
    local dir="$1"
    local cert_name="custom-domain-fpa"
    local keyvault_name
    keyvault_name=$(get_shared_keyvault)
    az keyvault secret download --vault-name "$keyvault_name" -n "$cert_name" --encoding base64 -f "$dir/lcdomainfpa.pfx"
}

function download_resource_provider_fpa_cert() {
    local dir="$1"
    local cert_name
    if is_prod; then
        cert_name="multi-tenant-app-mgmt-fpa"
    else
        cert_name="custom-domain-fpa"
    fi

    local keyvault_name
    keyvault_name=$(get_shared_keyvault)
    az keyvault secret download --vault-name "$keyvault_name" -n "$cert_name" --encoding base64 -f "$dir/lcrpfpa.pfx"
}

function download_testkeyvault_cert_and_generatecrtandkey() {
    local dir="$1"
    local cert_name=test-endpoint-https
    local keyvault_name=$(get_shared_keyvault)

    download_keyvault_cert_and_append_ca $keyvault_name $cert_name $dir
}

function download_customerkeyvault_cert_and_generatecrtandkey() {
    local dir="$1"
    local cert_name=customer-application-https
    local keyvault_name=$(get_shared_keyvault)

    download_keyvault_cert_and_append_ca $keyvault_name $cert_name $dir
}

function get_cert_secret() {
    local keyvault_name="$1"
    secret="$(az keyvault secret show --vault-name "$keyvault_name" --name lc-cert-pw --query value -o tsv 2>/dev/null)"
    if [[ $? != 0 || -z "$secret" ]]; then
        secret=$((RANDOM + 100000))
        az keyvault secret set --vault-name "$keyvault_name" \
            --name lc-cert-pw --value "$secret" >/dev/null
    fi
    echo $secret
}

# Create or replace an Kubernetes resource. Useful for ConfigMap.
#
# Arguments
#   1 - Namespace
#   2 - Resource Type
#   3 - Resource Name
#   4 - Resource config file path. If left empty, read from STDIN.
function k8s_create_or_replace() {
    local ns="$1"
    local type="$2"
    local name="$3"
    local config_file="$4"

    ns_args=""
    if [[ -n "$ns" ]]; then
        ns_args="--namespace $ns"
    fi

    local action=replace
    if ! kubectl get "$type" $ns_args "$name" >/dev/null 2>&1; then
        action=create
    fi

    log_info "$action $type $ns/$name"
    if [[ -z "$config_file" ]]; then
        kubectl "$action" $ns_args -f -
    else
        kubectl "$action" $ns_args -f "$config_file"
    fi
}

function prepare_temp_dir() {
    if [[ -n "$TEMP_DIR" ]]; then
        log_info "Reuse temporary directory '$TEMP_DIR'"
    else
        TEMP_DIR=$(mktemp -d deploy.tmp.XXXX)
        # shellcheck disable=SC2064
        trap "rm -rf -- '$TEMP_DIR'" EXIT
        log_info "Prepared temporary directory at: $TEMP_DIR"
    fi
    export TEMP_DIR
}

function add_shutdown_hook() {
    local hook
    hook="$1"

    # shellcheck disable=SC2034
    existing="$(
        extract_trap_cmd() { printf '%s' "$3"; }
        eval "extract_trap_cmd $(trap -p EXIT)"
    )"
    if [[ -n "$existing" ]]; then
        hook=$(printf "%s\n%s" "$existing" "$hook")
    fi
    # shellcheck disable=SC2064
    trap "$hook" EXIT
}

function get_public_image() {
    local name="$1"
    local tag="$2"

    if [[ -z $tag ]]; then
        tag=latest
    fi
    prepare_acr_properties
    echo "$public_acr_and_repo_prefix/$name:$tag"
}

function get_control_plane_image() {
    local name="$1"
    local tag="$2"

    if [[ -z $tag ]]; then
        tag=latest
    fi
    prepare_acr_properties
    echo "$control_plane_acr_name.$acr_suffix/$name:$tag"
}

function get_slo_namespace() {
    if is_prod; then
        echo "slo"
    else
        echo "testslo"
    fi
}

function get_netcore_environment() {
    if is_china; then
        if is_prod; then
            echo "Mooncake"
        else
            echo "MooncakeStaging"
        fi
    elif is_government; then
        if is_prod; then
            echo "Fairfax"
        else
            echo "FairfaxStaging"
        fi
    elif is_prod; then
        echo "Production"
    elif is_dev; then
        echo "Staging"
    elif is_oneBox; then
        echo "Staging"
    else
        echo "Development"
    fi
}

# Get Kubernetes resource with retry (5 times, 5 seconds interval)
# Arguments:
#   $1      namespace
#   $2      type
#   <rest arguments>    e.g., name, or "--selector selector"
function safe_get_k8s_resource_json() {
    local namespace="$1"
    local type="$2"
    shift 2

    local json
    for i in $(seq 1 5); do
        json=$(kubectl get --namespace "$namespace" "$type" "$@" -o json) && break
        args="$(IFS=' ' echo "$*")"
        log_error "[$i] failed to get $type in namespace $namespace, args: $args, retry after 5 seconds"
        sleep 5
    done
    if [[ -z "$json" ]]; then
        return 1
    else
        echo -E "$json"
    fi
}

# Verify Kubernetes resource health based on replica status, and optionally, pod restarting state.
#
# Arguments
#   -t type                     resource type, deployment|daemonset|statefulset, default: deployment
#   -n name         [required]  resource name
#   -p namespace                resource namespace, default: default
#   -s selector                 pod selector, to find all the pods belonging to the resource, default: app=$name
#   -r retry                    retry count, should be greater or equal to 1, default: 12
#   -i retry_interval           retry interval in seconds, default: 10
#   -v                          verbose check, check pod restarting status as well
function verify_k8s_resource_health() {
    local type=deployment
    local name=
    local namespace=default
    local selector=
    local retry=12
    local retry_interval=10
    local check_pod_restart=false
    OPTIND=1 # reset getopts current checking index
    while getopts ":t:n:p:s:r:i:v" opt; do
        case "$opt" in
        t) type="$OPTARG" ;;
        n) name="$OPTARG" ;;
        p) namespace="$OPTARG" ;;
        s) selector="$OPTARG" ;;
        r) retry="$OPTARG" ;;
        i) retry_interval="$OPTARG" ;;
        v) check_pod_restart=true ;;
        \?)
            log_fatal "invalid option: $OPTARG"
            ;;
        :)
            log_fatal "resource name was not specified"
            ;;
        esac
    done

    if [[ -z "$name" ]]; then
        log_fatal "resource name was not specified"
    fi

    type=$(tr "[:upper:]" "[:lower:]" <<<"$type")
    if [[ "$type" != deployment && "$type" != daemonset && "$type" != statefulset ]]; then
        log_fatal "invalid resource type $type"
    fi

    if [[ -z "$selector" ]]; then
        selector="app=$name"
    fi

    log_info "checking desired state for $type $namespace/$name, current $type state:"
    kubectl get --namespace "$namespace" "$type" "$name" -o wide

    local json
    local resource_ready=false
    for i in $(seq "$retry"); do
        json=$(safe_get_k8s_resource_json "$namespace" "$type" "$name") || exit 1
        if [[ "$type" == daemonset ]]; then
            read -r desired replicas ready_replicas updated_replicas < <(jq -r '.status | "\(.desiredNumberScheduled) \(.numberAvailable) \(.numberReady) \(.updatedNumberScheduled)"' <<<"$json")
        else # deployment / statefulset
            read -r desired replicas ready_replicas updated_replicas < <(jq -r '.spec.replicas as $desired | .status | "\($desired) \(.replicas) \(.readyReplicas) \(.updatedReplicas)"' <<<"$json")
        fi
        if ((replicas > 0)); then
            if [[ "$desired" != null && "$desired" == "$replicas" && "$replicas" == "$ready_replicas" && "$replicas" == "$updated_replicas" ]]; then
                log_info "[$i] reached desired state for $type $namespace/$name: desired=$desired current=$replicas updated=$updated_replicas ready=$ready_replicas"
                resource_ready=true
                break
            fi
        fi
        log_info "[$i] state for $type $namespace/$name is not ready: desired=$desired current=$replicas updated=$updated_replicas ready=$ready_replicas, retry after $retry_interval seconds"
        sleep "$retry_interval"
    done

    if [[ "$resource_ready" != true ]]; then
        log_error "ERROR: state for $type $namespace/$name is not ready after $retry retry"
        return 1
    fi

    if [[ "$check_pod_restart" == false ]]; then
        return 0
    fi

    log_info "checking pod state for $type $namespace/$name with selector $selector"
    local pod_check_pass=false
    local pod_count
    for i in $(seq "$retry"); do
        json=$(safe_get_k8s_resource_json "$namespace" pods --selector "$selector") || exit 1
        pod_count=$(jq -r '.items | length' <<<"$json")
        if ((pod_count > 0)); then
            local has_restart=false
            while read -r pod_name; do
                log_info "[$i] checking container restarting state for pod $namespace/$pod_name"
                while read -r container_name restart_count; do
                    if ((restart_count > 0)); then
                        log_warn "[$i] container $container_name in pod $namespace/$pod_name has restarted $restart_count times"
                        echo -e "\n\n========== [$i] Dump logs for container $container_name in pod $namespace/$pod_name =========="
                        kubectl logs --container "$container_name" --namespace "$namespace" --since 10m "$pod_name" | tail -n200
                        echo -e "========== [$i] Completed dumping logs for container $container_name in pod $namespace/$pod_name ==========\n\n"
                        has_restart=true
                    else
                        log_info "[$i] container $container_name in pod $namespace/$pod_name has not restarted"
                    fi
                done < <(jq -r --arg pod_name "$pod_name" '.items[] | select(.metadata.name == $pod_name).status.containerStatuses[] | "\(.name) \(.restartCount)"' <<<"$json")
            done < <(jq -r '.items[].metadata.name' <<<"$json")

            if [[ "$has_restart" == false ]]; then
                pod_check_pass=true
                break
            fi

            log_info "[$i] restarting pods found for $type $namespace/$name with selector $selector, retry after $retry_interval seconds"
        else
            log_error "[$i] no pods found for $type $namespace/$name with selector $selector, retry after $retry_interval seconds"
        fi
        sleep "$retry_interval"
    done

    if [[ "$pod_check_pass" != true ]]; then
        log_error "ERROR: pod state check for $type $namespace/$name with selector $selector failed"
        return 1
    fi

    log_info "INFO: no pods for $type $namespace/$name is restarting"
    return 0
}

function assign_access_for_shared_keyvault {
    local service_principal_id=$1

    if [[ -z "${service_principal_id}" ]]; then
        log_fatal "Service principal id cannot be empty."
    fi

    local shared_keyvault_name shared_resource_group

    shared_keyvault_name=$(get_shared_keyvault)
    shared_resource_group=$(get_shared_keyvault_resource_group_name)

    az keyvault set-policy --name "${shared_keyvault_name}" --spn "${service_principal_id}" \
        --resource-group ${shared_resource_group} \
        --secret-permissions get list set \
        --certificate-permissions get list \
        --key-permissions get list encrypt decrypt
}

function get_shared_keyvault_resource_group_name {
    if is_government; then
        if is_prod; then
            echo "ascprodrgshareda"
        else
            echo "ascdevrgshareda"
        fi
    elif is_prod || is_china; then
        echo "amss-rp-shared"
    else
        echo "ascdevshareda"
    fi
}

# USAGE: create_keyvault $resource_group_name $keyvault_name <$enable_soft_delete>
# NOTE: $enable_soft_delete is true by default, it will also enable purge protection, and for now you cannot disable soft delete once it is enabled
function create_keyvault {
    local resource_group_name=$1
    local keyvault_name=$2
    local enable_soft_delete=${3:-true}

    if [[ -z "${resource_group_name}" ]]; then
        log_fatal "Resource group name cannot be empty."
    fi

    if [[ -z "${keyvault_name}" ]]; then
        log_fatal "Keyvault name cannot be empty."
    fi

    keyvault_uri=$(az keyvault show --resource-group ${resource_group_name} --name ${keyvault_name} \
        --query properties.vaultUri -o tsv 2>/dev/null || : )
    if [[ -z $keyvault_uri ]]; then
        if ${enable_soft_delete}; then
            az keyvault create -g "${resource_group_name}" -n "${keyvault_name}" --enable-purge-protection true
        else
            az keyvault create -g "${resource_group_name}" -n "${keyvault_name}"
        fi
    fi

    az keyvault set-policy --name ${keyvault_name} --spn $(get_ev2_identity_id) \
        --resource-group ${resource_group_name} \
        --certificate-permissions setissuers \
        --secret-permissions set
}

function create_keyvault_with_builtin_access_policy {
    local resource_group_name=$1
    local keyvault_name=$2
    create_keyvault "$resource_group_name" "$keyvault_name"
    az keyvault update -g "${resource_group_name}" -n "${keyvault_name}" --enabled-for-deployment --enabled-for-disk-encryption --enabled-for-template-deployment
}

function get_active_normalized_region_list() {
    if is_prod; then
        local normalized_regions=("eus2euap" "wcus" "sea" "wus2" "aue" "uks" "neu" "scus" "cus" "eus2" "weu" "eus")
        echo "${normalized_regions[@]}"
    else
        local normalized_regions=("eus" "weu")
        echo "${normalized_regions[@]}"
    fi
}

function copy_secret {
    local src="$1"
    local name="$2"
    local dest="$3"
    local new_name="$4"
    if [[ -z "$new_name" ]]; then
        new_name="$name"
    fi

    value=$(az keyvault secret show --vault-name "$src" --name "$name" --query value -o tsv)
    if [[ -n "$value" ]]; then
        log_info "COPY: $src/$name ---> $dest/$new_name"
        az keyvault secret set --vault-name "$dest" --name "$new_name" --value "$value" >/dev/null
    else
        log_error "ERROR: $src/$name is not found"
    fi
}

function copy_secret_file {
    local src="$1"
    local name="$2"
    local dest="$3"

    if [[ ! -f "$temp_dir/$name" ]]; then
        az keyvault secret download --vault-name "$src" --name "$name" --file "$temp_dir/$name"
        if (( $? != 0 )); then
            echo "ERROR: $src/$name is not found"
            return 1
        fi
    fi

    echo "COPY: $src/$name ---> $dest"
    az keyvault secret set --vault-name "$dest" --name "$name" --file "$temp_dir/$name" >/dev/null
}

function load_cloud_configuration_file {
    local cloud_configuration_file

    local ns="${1:-default}"

    case $CLOUD in
    "CHINA")
        cloud_configuration_file=cloud_configuration_mooncake.json
        ;;
    "GOVERNMENT")
        cloud_configuration_file=cloud_configuration_fairfax.json
        ;;
    *)
        cloud_configuration_file=cloud_configuration_azure.json
        ;;
    esac

    kubectl create configmap cloud-configuration-configmap -n $ns --from-file="$COMMON_SH_DIR/../$cloud_configuration_file" -o yaml --dry-run=client \
        | k8s_create_or_replace $ns ConfigMap cloud-configuration-configmap

    export CLOUD_CONFIGURATION_FILEPATH="$CLOUD_CONFIGURATION_VOLUME_PATH/$cloud_configuration_file"
}

function get_cloud_configuration_file {
    local cloud_configuration_file

    case $CLOUD in
    "CHINA")
        cloud_configuration_file=cloud_configuration_mooncake.json
        ;;
    "GOVERNMENT")
        cloud_configuration_file=cloud_configuration_fairfax.json
        ;;
    *)
        cloud_configuration_file=cloud_configuration_azure.json
        ;;
    esac

    export CLOUD_CONFIGURATION_FILEPATH="$CLOUD_CONFIGURATION_VOLUME_PATH/$cloud_configuration_file"
}

function load_application_insights_connection_string() {
    local vault_name=$(get_shared_keyvault)
    connection_string=$(az keyvault secret show --vault-name "$vault_name" --name appinsights-connection-string --query value -o tsv 2>/dev/null || : )
    echo "$connection_string"
}


function prepare_ms_openjdk8_base_image() {
    local ms_openjdk_image_name="java/jdk"
    local ms_openjdk_iamge_tag="8u282-msopenjdk-alpine"
    MS_OPENJDK_BASE_IMAGE=$acr_name.$acr_suffix/$ms_openjdk_image_name:$ms_openjdk_iamge_tag
    log_info "ms openjdk base image: $MS_OPENJDK_BASE_IMAGE"
}

function prepare_ms_openjdk11_base_image() {
    local ms_openjdk_image_name="java/jdk"
    local ms_openjdk_iamge_tag="11u10-jre-msopenjdk-alpine"
    MS_OPENJDK_BASE_IMAGE=$acr_name.$acr_suffix/$ms_openjdk_image_name:$ms_openjdk_iamge_tag
    log_info "ms openjdk base image: $MS_OPENJDK_BASE_IMAGE"
}

function get_image_cleanup_image() {
    local image_cleanup_img=$(get_public_image distroless-crictl "v1.27.1-20230716")
    log_info "daemonset image-cleanup image: $image_cleanup_img"
    echo $image_cleanup_img
}

function export_configuration_environment_variables {
    export APPSETTINGS_VOLUME_PATH="/etc/appsettings"
    export MULTIVERSION_CONFIG_VOLUME_PATH="/etc/multiversion-config"
    export ENABLE_APPSETTINGS_CONFIGMAP
    log_info "APPSETTINGS_VOLUME_PATH: $APPSETTINGS_VOLUME_PATH, ENABLE_APPSETTINGS_CONFIGMAP: $ENABLE_APPSETTINGS_CONFIGMAP"
    log_info "MULTIVERSION_CONFIG_VOLUME_PATH: $MULTIVERSION_CONFIG_VOLUME_PATH"
}

function prepare_shared_encryption_key_if_not_exists {
    local encryption_key_name=$1
    local shared_keyvault_name=$(generate_resource_name kv shared '' true)
    local dest=${2:-$shared_keyvault_name}
    local key_id=$(az keyvault key show --name ${encryption_key_name} \
        --vault-name ${dest} \
        --query key.kid -o tsv 2> /dev/null || echo "")

    if [[ "${key_id}" == "" ]]; then
        log_info "Shared encryption key ${encryption_key_name} doesn't exist, will create new one."
        # Note the "scripts/region/deploy.sh:116" granted the encrypt/decrypt authority to sp already for each region.
        az keyvault key create --name ${encryption_key_name} \
            --vault-name ${dest} \
            --query key.kid -o tsv
    else
        log_info "Found shared encryption key ${encryption_key_name} with id ${key_id}, do nothing here."
    fi
}

# Delete resource group without confirmation
function delete_rp_rg {
    local sub="$1"
    local rg="$2"

    rg_exists=$(az group exists -n $rg --subscription $sub)
    if $rg_exists; then
        echo "The legacy resource group ${rg} still exists in the ${sub} subscription. This script will delete the whole resource group and its related resources."
        az group delete -n $rg --subscription $sub --yes
    fi
}

# Insert data into dev table
function insert_table {
    local table="$1"
    local key="$2"
    local value="$3"
    local az_storage_connection_string="$4"

    az storage entity insert --connection-string "${az_storage_connection_string}" \
        --if-exists replace -t $table -e \
            PartitionKey="" \
            Deleted=false Deleted@odata.type=Edm.Boolean \
            KeyName=${key} \
            KeyValue=$value KeyValue@odata.type=Edm.String \
            RowKey="${key}"
}

function prepare_regional_rsa4096_encryption_key_if_not_exists {
    local encryption_key_name=$1
    local regional_keyvault_name=$2

    local key_id=$(az keyvault key show --name ${encryption_key_name} \
        --vault-name ${regional_keyvault_name} \
        --query key.kid -o tsv 2> /dev/null || echo "")

    if [[ "${key_id}" == "" ]]; then
        log_info "RSA encryption key ${encryption_key_name} doesn't exist, will create new one."
        az keyvault key create --name ${encryption_key_name} \
            --vault-name ${regional_keyvault_name} \
            --kty RSA --size 4096
    else
        log_info "Found RSA encryption key ${encryption_key_name} with id ${key_id}, do nothing here."
    fi
}

function export_azure_cloud_environment_variables {
    case $CLOUD in
    "CHINA")
        export AZURE_CLOUD="AzureChinaCloud"
        ;;
    "GOVERNMENT")
        export AZURE_CLOUD="AzureUSGovernment"
        ;;
    *)
        export AZURE_CLOUD="AzureCloud"
        ;;
    esac
}

function create_servicebus_queue {
    local resource_group=$1
    local servicebus_ns=$2
    local queue_name=$3

    az servicebus queue show -g ${resource_group} --namespace-name ${servicebus_ns} -n ${queue_name} > /dev/null 2>&1
    if [[ $? != 0 ]]; then
        log_info "Service Bus queue '${queue_name}' does not exist. Creating it now..."
        az servicebus queue create -g ${resource_group} --namespace-name ${servicebus_ns} -n ${queue_name} \
            --enable-batched-operations true --enable-session true --enable-dead-lettering-on-message-expiration true \
            --lock-duration PT5M --enable-partitioning false
    else
        log_info "Service Bus queue '${queue_name}' exists already."
    fi
}

function login_to_onebox_sp {
    OneboxServicePrincipalLoginUsername=$(az keyvault secret show --vault-name ascdevkvshareda -n AscServicePrincipalLoginUsername --query value -o tsv)
    OneboxServicePrincipalLoginPassword=$(az keyvault secret show --vault-name ascdevkvshareda -n AscServicePrincipalLoginPassword --query value -o tsv)
    OneboxServicePrincipalLoginTenant=$(az keyvault secret show --vault-name ascdevkvshareda -n AscServicePrincipalLoginTenant --query value -o tsv)

    az login --service-principal --username $OneboxServicePrincipalLoginUsername --password $OneboxServicePrincipalLoginPassword --tenant $OneboxServicePrincipalLoginTenant -o none
}

function create_cosmosdb_containers {
    local cosmosdb_containers=$1
    local rg=$2
    local cosmosdb_name=$3
    for varible in ${cosmosdb_containers[@]}
    do
        existCollection=$(az cosmosdb sql container exists -n $varible -d lifecycle -g ${rg} -a ${cosmosdb_name} -o tsv)
        echo $existCollection $varible
        if [[ $existCollection == "false" ]]; then
            az cosmosdb sql container create -n $varible -d lifecycle --resource-group ${rg} -a ${cosmosdb_name} --partition-key-path "/serviceId"
        fi
    done
}

function create_cosmosdb {
    local rg=$1
    local cosmosdb_name=$2
    cosmosdb_id=$(az cosmosdb show --resource-group $rg --name $cosmosdb_name \
    --query id -o tsv 2>/dev/null || : )
    if [[ -z $cosmosdb_id ]]; then
        cosmosdb_id=$(az cosmosdb create --name ${cosmosdb_name} \
                          --resource-group ${rg} \
                          --default-consistency-level "Session" \
                          --kind GlobalDocumentDB \
                          --query id -o tsv)
    fi
}

function create_child_dns_zone {
    local parent_dns_rg=$1
    local parent_dns_name=$2
    local user=$3
    local dogfood_subscription=$4
    local rg=$5
    local dns_name=$6
    dns_ns_record=$(az network dns record-set ns show -g $parent_dns_rg -z $parent_dns_name -n $user --subscription $dogfood_subscription)
    if [ ${#dns_ns_record} -ne 0 ]; then
        az network dns record-set ns delete -g $parent_dns_rg -z $parent_dns_name  -n $user --subscription $dogfood_subscription --yes
    fi
    az network dns zone create -g $rg -n $dns_name -p "/subscriptions/d51e3ffe-6b84-49cd-b426-0dc4ec660356/resourceGroups/azdmss-dogfood/providers/Microsoft.Network/dnszones/asc-test.net"
}

function create_byoc_encryption_key_if_not_exist {
    local kv_name=$1
    key_type=$(az keyvault key show --vault-name $kv_name --name BYOC-ENCRYPTION-KEY --query key.kty -o tsv)

    if [[ $? != 0 || -z "$key_type" ]]; then
        echo "The key with name BYOC-ENCRYPTION-KEY not exists, will create the key"
        az keyvault key create --vault-name $kv_name --name BYOC-ENCRYPTION-KEY --kty RSA --size 4096 > /dev/null
    else
        echo "The key with name BYOC-ENCRYPTION-KEY exists, will skip the key creation"
    fi
}

function create_servicebus_ns_if_not_exist {
    local rg=$1
    local servicebus_ns=$2
    SERVICE_BUS_RESOURCE_ID=$(az servicebus namespace show -g ${rg} -n ${servicebus_ns} --query id -o tsv)
    if [[ -z $SERVICE_BUS_RESOURCE_ID ]]; then
        az servicebus namespace create --resource-group $rg --name $servicebus_ns --location $LONG_REGION --sku Standard
        SERVICE_BUS_RESOURCE_ID=$(az servicebus namespace show -g ${rg} -n ${servicebus_ns} --query id -o tsv)
    fi
}

function get_aks_resource_id {
    local resource_group=$1
    local aks_name=$2
    az aks show --resource-group "$resource_group" --name "$aks_name" --query id -o tsv
}

function get_aks_control_plane_addr {
    # sed: to remove ANSI color codes from text stream
    kubectl cluster-info | grep "control plane" | awk '{print $NF}' | sed 's/\x1b\[[0-9;]*m//g'
}

function create_secrets_from_certs {
    local keyvault_name="$1"
    local cert_name="$2"
    local secret_name_prefix="$3"
    local append_ca="$4"

    local cert_id=$(az keyvault secret show --vault-name "$shared_kv" -n "$cert_name" --query id -o tsv)
    local sec_tag=$(az keyvault secret show --vault-name "$keyvault_name" -n "$secret_name_prefix-Cert" --query tags.cert_id -o tsv)

    if [[ "$cert_id" == "$sec_tag" ]]; then
        log_info "The secret with prefix $secret_name_prefix in kv $keyvault_name is the latest one, skip"
        return
    fi

    prepare_temp_dir
    local working_dir="$TEMP_DIR/$cert_name"

    if [[ "$append_ca" == true ]]; then
        download_keyvault_cert_and_append_ca "$shared_kv" "$cert_name" "$working_dir"
    else
        download_keyvault_cert "$shared_kv" "$cert_name" "$working_dir"
    fi

    base64_pem_file="$working_dir/base64_cert_pem"
    base64_key_file="$working_dir/base64_cert_key"

    base64 -w0 "$working_dir/cert.pem" > "$base64_pem_file"
    base64 -w0 "$working_dir/cert.key" > "$base64_key_file"

    log_info "Creating secrets with prefix $secret_name_prefix from cert $cert_name in kv $keyvault_name"
    az keyvault secret set --vault-name "$keyvault_name" --name "$secret_name_prefix-Cert" --file "$base64_pem_file" \
        --tags cert_id="$cert_id"
    az keyvault secret set --vault-name "$keyvault_name" --name "$secret_name_prefix-Key" --file "$base64_key_file" \
        --tags cert_id="$cert_id"
}

# download certificate, extract cert & key, save it to secrets with given prefix name + '-Cert' / '-Key'
function sync_certificate_to_secrets {
    local cert_kv="$1"              # src certificate keyvault
    local cert_name="$2"            # src certificate name
    local secret_kv="$3"            # dst secrets keyvault
    local secret_prefix="$4"        # dst secrets name prefix
    local append_ca="$5"

    local cert_id=$(az keyvault secret show --vault-name "$cert_kv" -n "$cert_name" --query id -o tsv)
    local sec_tag=$(az keyvault secret show --vault-name "$secret_kv" -n "$secret_prefix-Cert" --query tags.cert_id -o tsv)

    if [[ "$cert_id" == "$sec_tag" ]]; then
        log_info "The secret $secret_kv/$secret_prefix is already the latest from $cert_kv/$cert_name, skip"
        return
    fi

    prepare_temp_dir
    local working_dir="$TEMP_DIR/$cert_name"

    if [[ "$append_ca" == true ]]; then
        download_keyvault_cert_and_append_ca "$cert_kv" "$cert_name" "$working_dir"
    else
        download_keyvault_cert "$cert_kv" "$cert_name" "$working_dir"
    fi

    base64_pem_file="$working_dir/base64_cert_pem"
    base64_key_file="$working_dir/base64_cert_key"

    base64 -w0 "$working_dir/cert.pem" > "$base64_pem_file"
    base64 -w0 "$working_dir/cert.key" > "$base64_key_file"

    log_info "Syncing secrets $secret_kv/$secret_prefix from $cert_kv/$cert_name"
    az keyvault secret set --vault-name "$secret_kv" --name "$secret_prefix-Cert" --file "$base64_pem_file" \
        --tags cert_id="$cert_id"
    az keyvault secret set --vault-name "$secret_kv" --name "$secret_prefix-Key" --file "$base64_key_file" \
        --tags cert_id="$cert_id"
}


function is_az_enabled {
  local az_available_regions="eus2euap cus wus2 eus aue neu eus2 cac krc jpe zan weu scus uks wus3 brs frc sea dewc ae sec aen inc"
  local region="$1"
  if [[ $az_available_regions =~ (^|[[:space:]])"$region"($|[[:space:]]) ]] ; then
        echo true
  else
        echo false
  fi
}

# Add or update record in onebox dns zone onebox.resourceprovider.test.azureappplatform.io. Records are for rp ingress or lifecycle service.
function set_onebox_dns_record {
    local RECORD_NAME=$1
    local IP_ADDRESS=$2
    local ONEBOX_DNS_ZONE="onebox.resourceprovider.test.azureappplatform.io"
    local ONEBOX_DNS_ZONE_RG="ascdevshareda"

    record_exists=$(az network dns record-set a list -z $ONEBOX_DNS_ZONE -g $ONEBOX_DNS_ZONE_RG --query "[?name=='$RECORD_NAME']" -o tsv)

    if [[ -z $record_exists ]]; then
        log_info "Adding A Name Record $RECORD_NAME in $ONEBOX_DNS_ZONE rg $ONEBOX_DNS_ZONE_RG ip $IP_ADDRESS"
        az network dns record-set a add-record -n $RECORD_NAME -g $ONEBOX_DNS_ZONE_RG -z $ONEBOX_DNS_ZONE -a $IP_ADDRESS
    else
        log_info "DNS Record $RECORD_NAME already exists, updating ip address to $IP_ADDRESS"
        az network dns record-set a update -n $RECORD_NAME -g $ONEBOX_DNS_ZONE_RG -z $ONEBOX_DNS_ZONE --set aRecords[0].ipv4Address=$IP_ADDRESS
    fi
}

# Get name of aks cluster in rg
function get_aks_name() {
    local onebox_rg=$1
    local subscription=$2
    local count=0
    local AKS_NAME

    log_info "Getting RG for AKS in $onebox_rg"
    while true
    do
        AKS_NAME=$(az aks list --resource-group "$onebox_rg" -o json --query '[].name' -o tsv)

    if [[ ${count} -gt 30 ]]; then
        echo "K8s cluster not found in rg within 15 minutes, deleting rg and exiting."
        delete_rp_rg $subscription $onebox_rg
        exit 1
    elif [[ -z ${AKS_NAME} ]]; then
        echo "Waiting System Cluster Provision Ready, count ${count} ..."
        sleep 30
    else
        break
    fi
        count=$((count+1))
    done

    echo $AKS_NAME
}

function get_nginx_ingress_image() {
    echo "$public_acr_and_repo_prefix/kubernetes-ingress-controller:1.7.1-20230810"
}

function read_certificates {
    local keyvault_name="$1"
    local cert_name="$2"

    log_info "Get content from certificate $keyvault_name/$cert_name"
    prepare_temp_dir
    local working_dir="$TEMP_DIR/$cert_name"

    download_keyvault_cert "$keyvault_name" "$cert_name" "$working_dir"
    echo $(base64 -w0 "$working_dir/cert.pem") $(base64 -w0 "$working_dir/cert.key")
}

# The data plane components are still using the data in secrets -Cert/-Key
# for onebox/dev environment, this sync step is required
# TODO: (sonwan) remove related code after RP updates
geneva_cert_names=("Geneva-Metric" "Geneva-Log")
function sync_geneva_certs_to_secrets {
    local shared_kv="$1"
    local keyvault_name="$2"
    log_info "Sync Geneva Certificate from $shared_kv/certificates to $keyvault_name/secrets"
    for name in "${geneva_cert_names[@]}"; do
        log_info "Sync Geneva Certificate $name"
        sync_certificate_to_secrets "$shared_kv" $name "$keyvault_name" $name false
    done
    log_info "Sync Geneva Certificate finished"
}

# this function is to install the specific version azure cli, in case latest version has bug
function install_azure_cli_specific_version {
    # Uninstall the current version of Azure CLI
    sudo apt-get remove -y azure-cli
    sudo apt-get install ca-certificates curl apt-transport-https lsb-release gnupg
    # Download and install the specific version
    curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null
    AZ_REPO=$(lsb_release -cs)
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | sudo tee /etc/apt/sources.list.d/azure-cli.list
    sudo apt-get update
    sudo apt-get install -y azure-cli=2.49.0-1~jammy
}
