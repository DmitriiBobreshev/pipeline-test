#!/usr/bin/env bash

# We've seen cases where deployments were applied either to the wrong ACS, or with some inconsistent configurations.
# The main cause is that we need to specify the KUBECONFIG and the cluster configurations separately, which may
# introduce human error when processing multiple cluster deployments.
#
# This region helper library is introduced to help parse the region and cluster information in a consistent way,
# eliminating the needs to specify cluster information manually.
#
# Terms:
#     * short name - abbreviated region names such as aue, scus, etc.
#     * long name - lower cased, concatenated region names such as australiaeast, southcentralus, etc.
#     * full name - human friendly region names in capitalized words, such as Australia East, South Central US, etc.
#     * index - alphabetic cluster index, a-z.
#     * numeric index - numeric cluster index, 1-26.
REGION_SH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

if ! which kubectl >/dev/null 2>&1 || ! which jq >/dev/null 2>&1; then
    echo "ERROR: kubectl or jq was not found"
    exit 1
fi

regionInput=$(cat "$REGION_SH_DIR/regions.json")

declare -A REGION_SHORT_TO_FULL=()
declare -A REGION_SHORT_TO_LONG=()
declare -A REGION_LONG_TO_FULL=()
declare -A REGION_LONG_TO_SHORT=()
declare -A REGION_VM_SIZE=()
declare -A REGION_VM_COUNT=()
declare -A REGION_VM_FAMILY=()

# construct the region list from regions.json
# REGION_SHORT_TO_FULL=(
#     [eus]='East US'
# )
# REGION_SHORT_TO_LONG=(
#     [eus]='eastus'
# )
# REGION_LONG_TO_FULL(
#     [eastus]='East US'
# )
# REGION_LONG_TO_SHORT=(
#     [eastus]='eus'
# )
for short in $(jq -r 'keys[]' <<<"$regionInput"); do
    short=$(echo $short | sed 's/ *$//g')
    jqstr=".$short.fullName"
    full=$(jq -r "$jqstr" <<< "$regionInput")
    long=$(echo "$full" | tr -d ' ' | tr 'A-Z' 'a-z')
    REGION_SHORT_TO_FULL[$short]="$full"
    REGION_SHORT_TO_LONG[$short]="$long"
    REGION_LONG_TO_FULL[$long]="$full"
    REGION_LONG_TO_SHORT[$long]="$short"
done

# load vm count and vm size for regions
for item in $(jq -r 'keys[]' <<<"$regionInput"); do
    item=$(echo $item | sed 's/ *$//g')
    vmCount=$(jq -r ".$item.vmCount" <<< "$regionInput")
    vmSize=$(jq -r ".$item.vmSize" <<< "$regionInput")
    vmFamily=$(jq -r ".$item.vmFamily" <<< "$regionInput")
    REGION_VM_SIZE[$item]="$vmSize"
    REGION_VM_COUNT[$item]="$vmCount"
    REGION_VM_FAMILY[$item]="$vmFamily"
done

# get vm size of region
function region_vm_size {
    if ! region_valid_short "$1"; then
        echo "ERROR: '$1' is not a valid short region name" >&2
        return 1
    fi
    echo ${REGION_VM_SIZE[$1]}
}

# get vm count of region
function region_vm_count {
    if ! region_valid_short "$1"; then
        echo "ERROR: '$1' is not a valid short region name" >&2
        return 1
    fi
    echo ${REGION_VM_COUNT[$1]}
}

# get vm family of region
function region_vm_family {
    if ! region_valid_short "$1"; then
        echo "ERROR: '$1' is not a valid short region name" >&2
        return 1
    fi
    echo ${REGION_VM_FAMILY[$1]}
}

# return 0 (true) if parsed in argument is a valid short region name.
function region_valid_short {
    [[ -n "${REGION_SHORT_TO_FULL[$1]}" ]]
}

# return 0 (true) if parsed in argument is a valid long region name.
function region_valid_long {
    [[ -n "${REGION_LONG_TO_FULL[$1]}" ]]
}

# output the long region name of the passed in short name
# return false if the short name is not valid
function region_short_to_long {
    if ! region_valid_short "$1"; then
        echo "ERROR: '$1' is not a valid short region name" >&2
        return 1
    fi
    echo "${REGION_SHORT_TO_LONG[$1]}"
}

# output the full region name of the passed in short name
# return false if the short name is not valid
function region_short_to_full {
    if ! region_valid_short "$1"; then
        echo "ERROR: '$1' is not a valid short region name" >&2
        return 1
    fi
    echo "${REGION_SHORT_TO_FULL[$1]}"
}

# output the short region name of the passed in long name
# return false if the long name is not valid
function region_long_to_short {
    if ! region_valid_long "$1"; then
        echo "ERROR: '$1' is not a valid long region name" >&2
        return 1
    fi
    echo "${REGION_LONG_TO_SHORT[$1]}"
}

# output the full region name of the passed in long name
# return false if the long name is not valid
function region_long_to_full {
    if ! region_valid_long "$1"; then
        echo "ERROR: '$1' is not a valid long region name" >&2
        return 1
    fi
    echo "${REGION_LONG_TO_FULL[$1]}"
}


# output the subscriptions where the aks for user will be created in
function get_user_subscription_ids {
    if ! region_valid_short "$1"; then
        echo "ERROR: '$1' is not a valid short region name" >&2
        return 1
    fi
    echo $(jq -r ".$1.subscriptions[]" <<<"$regionInput")
}

function region_normalize_to_short {
    local region=$(tr A-Z a-z < <(tr -d ' ' <<< "$1"))
    if [[ -n "${REGION_SHORT_TO_LONG[$region]}" ]]; then
        echo "$region"
    elif [[ -n "${REGION_LONG_TO_SHORT[$region]}" ]]; then
        echo "${REGION_LONG_TO_SHORT[$region]}"
    else
        echo "ERROR: Unknown region $1" >&2
        exit 1
    fi
}

# parse the cluster name and output the following 3 parts in space separated string
#
# * Environment: INT or PROD
# * Short region: e.g., weu
# * Cluster index, a-z
#
# E.g, given ${PREFIX}prodakseus2c, outputs
# prod eus2 c
#
# You can use the following construct to read the parsed values:
# $ read -r env short_region index_char <<<$(parse_cluster ${PREFIX}prodakseus2c)
function parse_cluster {
    local cluster="$1"
    local length=${#cluster}
    local env=
    local start=
    case "$cluster" in
    *localaks*)
        # use INT for local development cluster
        env=LOCAL
        start=11
        ;;
    *devaks*)
        env=DEV
        start=9
        ;;
    *prodaks*)
        env=PROD
        start=10
        ;;
    *)
        echo "ERROR: Unknown cluster name format: $cluster" >&2
        return 1
    esac
    local region_length=$(($length - $start - 1))
    local region="${cluster:$start:$region_length}"
    local index="${cluster:$(($length-1)):1}"
    echo "$env $region $index"
}

function get_environment_from_cluster {
    parse_cluster "$1" | awk '{print $1}'
}
export -f get_environment_from_cluster

# Get the friendly cluster name in <location><index> format from the cluster resource name
function get_friendly_cluster_name {
    local parts=( $(parse_cluster "$1") )
    [[ ${#parts[@]} != 3 ]] && return 1
    local long
    long="$(region_short_to_long "${parts[1]}")"
    [[ -z $long ]] && return 1
    echo "$long${parts[2]}"
}

# Get the cluster name (i.e., resource group, such as ${PREFIX}prodakseus2a) from the active kubeconfig
function get_cluster_from_kubeconfig {
    local cluster
    cluster=$(kubectl config view -o json | jq -r '.["current-context"] as $c | .contexts[] | select(.name==$c).context.cluster')
    if [[ -z $cluster ]]; then
        echo "ERROR: Cannot find cluster information from KUBECONFIG=$KUBECONFIG" >&2
        return 1
    fi
    echo "$cluster"
}

function index_to_alphabetic {
    if [[ ! "$1" =~ ^[0-9]+$ ]] || (( "$1" < 1 || "$1" > 26)); then
        echo "ERROR: '$1' is not a valid numeric index" >&2
        return 1
    else
        awk "BEGIN{printf \"%c\", $(("$1" + 96))}"
    fi
}

function index_to_numeric {
    if [[ ! "$1" =~ ^[a-z]$ ]]; then
        echo "ERROR: '$1' is not a valid alphabetic index" >&2
        return 1
    else
        value=$(printf "%d" "'$1")
        echo -n $(($value - 96))
    fi
}

# Parse and export ACS cluster related information from K8s.
# Exit the script on any error.
# If the function returns successfully, we should have the following environment variables ready (weux as an example)
#   ACS_CLUSTER=${PREFIX}prodaksweux
#   KUBE_ENV=PROD     (or INT)
#   SHORT_LOCATION=weu
#   INDEX_CHAR=x
#   LOCATION=westeurope
#   FULL_LOCATION="West Europe"
#   CLUSTER_NAME=westeuropex
function ensure_regional_info_from_k8s {
    if [[ -n "$ACS_CLUSTER" && -n "$KUBE_ENV" && -n "$FULL_LOCATION" && -n "$INDEX_CHAR" && -n "$CLUSTER_NAME" ]]; then
        # we have already parsed the regional information and the environment variables are ready.
        return
    elif [[ -n "$CLUSTER_NAME" && "$CLUSTER_NAME" =~ ^.*(local|dev|prod)acs ]]; then
        # When the script is executed as K8s jobs via the ACIS "Run Configuration Script" command,
        # we cannot get the cluster information through the "kubectl config view" result.
        # The cluster name aka resource group name will be passed in as environment variable CLUSTER_NAME, e.g.,
        #   CLUSTER_NAME=${PREFIX}prodaksweux
        #   LOCATION=westeurope
        # In this case, we use the environment variables instead.
        # Note that the CLUSTER_NAME will be adjusted to the long name after this call, e.g.
        #   ACS_CLUSTER=${PREFIX}prodaksweux
        #   CLUSTER_NAME=westeuropex
        ACS_CLUSTER="$CLUSTER_NAME"
    else
        if [[ -z "$KUBECONFIG" || ! -e "$KUBECONFIG" ]]; then
            echo "ERROR: KUECONFIG ($KUBECONFIG) was not found or not exported" >&2
            exit 1
        fi
        ACS_CLUSTER=$(get_cluster_from_kubeconfig)
        (( $? != 0 )) && exit 1
    fi
    read -r KUBE_ENV SHORT_LOCATION INDEX_CHAR <<<"$(parse_cluster "$ACS_CLUSTER")"
    if [[ -z "$KUBE_ENV" || -z "$SHORT_LOCATION" || -z "$INDEX_CHAR" ]]; then
        echo "ERROR: Failed to parse cluster information for '$ACS_CLUSTER'" >&2
        exit 1
    fi
    LOCATION=$(region_short_to_long "$SHORT_LOCATION")
    (( $? != 0 )) && exit 1
    FULL_LOCATION=$(region_short_to_full "$SHORT_LOCATION")
    CLUSTER_NAME="${LOCATION}${INDEX_CHAR}"

    export ACS_CLUSTER KUBE_ENV SHORT_LOCATION INDEX_CHAR LOCATION FULL_LOCATION CLUSTER_NAME
}
