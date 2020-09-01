#!/bin/bash
set -eu

# Poll for state to exist, error if no state exists after 20 checks with 5 second internals (100 seconds)
/usr/local/bin/aws s3api wait object-exists --bucket ${state_bucket} --key ${state_key}

mkdir -p /var/lib/rancher/k3s
/usr/local/bin/aws s3 cp "s3://${state_bucket}/${state_key}" /var/lib/rancher/k3s/state.env