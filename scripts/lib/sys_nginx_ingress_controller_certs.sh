 #!/usr/bin/env bash   

service_runtime_sys_ingress_certs=(
    AzureMss-ServiceRuntime-SysIngressController-Customer-Cert
    AzureMss-ServiceRuntime-SysIngressController-Customer-Key
    AzureMss-ServiceRuntime-SysIngressController-Svc-Cert
    AzureMss-ServiceRuntime-SysIngressController-Svc-Key
    AzureMss-ServiceRuntime-SysIngressController-Test-Cert
    AzureMss-ServiceRuntime-SysIngressController-Test-Key

    AzureMss-ServiceRuntime-SysIngressController-Private-Customer-Cert
    AzureMss-ServiceRuntime-SysIngressController-Private-Customer-Key
    AzureMss-ServiceRuntime-SysIngressController-Private-Svc-Cert
    AzureMss-ServiceRuntime-SysIngressController-Private-Svc-Key
    AzureMss-ServiceRuntime-SysIngressController-Private-Test-Cert
    AzureMss-ServiceRuntime-SysIngressController-Private-Test-Key
)

declare -A secret_certificate_names_map=(
    ["AzureMss-ServiceRuntime-SysIngressController-Customer"]="customer-application-https"
    ["AzureMss-ServiceRuntime-SysIngressController-Svc"]="service-runtime-https"
    ["AzureMss-ServiceRuntime-SysIngressController-Test"]="test-endpoint-https"
    # for vnet, add private label
    ["AzureMss-ServiceRuntime-SysIngressController-Private-Customer"]="customer-application-private-https"
    ["AzureMss-ServiceRuntime-SysIngressController-Private-Svc"]="service-runtime-private-https"
    ["AzureMss-ServiceRuntime-SysIngressController-Private-Test"]="test-endpoint-private-https"
)