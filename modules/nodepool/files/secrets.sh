#!/bin/bash
set -eu

mkdir -p /var/lib/rancher/k3s

until /usr/local/bin/aws s3 cp s3://${state_bucket}/${state_key} /var/lib/rancher/k3s/state.env; do
  echo "Waiting for ${state_key} to exist within ${state_bucket}"
  sleep 10
done
