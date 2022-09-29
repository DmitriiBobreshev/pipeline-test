#!/bin/bash
if ! security find-identity | grep -q "\"CanaryTestCertificateCommonName\""; then
  echo "Certificate is not installed" >>/dev/stderr
fi
