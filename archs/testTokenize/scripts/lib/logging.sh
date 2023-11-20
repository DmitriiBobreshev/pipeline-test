#!/usr/bin/env bash

if [[ -z "$LOG_LEVEL" ]]; then
    # set to 0 to suppress logging
    # default logging info and above
    export LOG_LEVEL=4
fi

# level 5
function log_trace() {
    ((LOG_LEVEL < 5)) && return
    IFS=' ' echo -e "$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ) \033[37mTRACE\033[0m: $*" >&2
}

# level 4
function log_info() {
    ((LOG_LEVEL < 4)) && return
    IFS=' ' echo -e "$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)  \033[32mINFO\033[0m: $*" >&2
}

# level 3
function log_warn() {
    ((LOG_LEVEL < 3)) && return
    IFS=' ' echo -e "$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)  \033[33mWARN\033[0m: $*" >&2
}

# level 2
function log_error() {
    ((LOG_LEVEL < 2)) && return
    IFS=' ' echo -e "$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ) \033[31mERROR\033[0m: $*" >&2
}

# level 1
function log_fatal() {
    ((LOG_LEVEL < 1)) && exit 1
    IFS=' ' echo -e "$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ) \033[31mFATAL\033[0m: $*" >&2
    exit 1
}
