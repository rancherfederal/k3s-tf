#!/bin/bash
set -eu

while true
  do
    echo "Checking ${state_bucket} for ${state_key}..."
    /usr/local/bin/aws s3api head-object --bucket "${state_bucket}" --key "${state_key}" 2>/dev/null
    if [[ ! $? -ne 0 ]]; then
      echo "found"
      break
    fi
    echo "Going to sleep for 10 seconds..."
    sleep 10
done

mkdir -p /var/lib/rancher/k3s
/usr/local/bin/aws s3 cp "s3://${state_bucket}/${state_key}" /var/lib/rancher/k3s/state.env