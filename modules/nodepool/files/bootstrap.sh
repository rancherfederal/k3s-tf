#!/bin/bash

K3S_STATE_PATH="/var/lib/rancher/k3s/state.env"

# Cluster metadata
CLUSTER="${cluster}"
NAME="${name}"

# Shared k3s args
NODE_LABELS="${node_labels}"
NODE_TAINTS="${node_taints}"
KUBELET_ARGS="${kubelet_args}"
EXTERNAL_CLOUD_PROVIDER="cloud-provider=external"

# Server k3s args
TLS_SANS="${tls_sans}"
DISABLES="${disables}"
KUBE_APISERVERS="${kube_apiservers}"
KUBE_SCHEDULERS="${kube_schedulers}"
KUBE_CONTROLLER_MANAGERS="${kube_controller_managers}"
KUBE_CLOUD_CONTROLLER_MANAGERS="${kube_cloud_controller_managers}"

# Agent k3s args
SERVER="${server}"

format_args () {
  IFS=';' read -ra arr <<< "$1"
  for i in "$${arr[@]}"; do
    printf '%s %s ' "$2" "$i"
  done
}

# --- helper functions for logs ---
info()
{
    echo '[INFO] ' "$@"
}
warn()
{
    echo '[WARN] ' "$@" >&2
}
fatal()
{
    echo '[ERROR] ' "$@" >&2
    exit 1
}

node_drain() {
  systemctl daemon-reload
  systemctl enable nodedrain.service
  systemctl start --no-block nodedrain.service
}

rds_ca() {
  # RDS CA Cert
  curl -sL https://s3.us-gov-west-1.amazonaws.com/rds-downloads/rds-ca-us-gov-west-1-2017-root.pem -o /etc/ssl/certs/rds-ca-us-gov-west-1-2017-root.pem
  curl -sL https://s3.amazonaws.com/rds-downloads/rds-combined-ca-bundle.pem -o /etc/ssl/certs/rds-combined-ca-bundle.pem
}

upload() {
  case "$1" in
    "server")
      CONTROLPLANE_LB_DNS="$(aws elb describe-load-balancers --load-balancer-name $${CLUSTER}-k3scp --query 'LoadBalancerDescriptions[*].DNSName' --output text)"

      pushd /etc/rancher/k3s

      sed 's|127.0.0.1|'$CONTROLPLANE_LB_DNS'|g' k3s.yaml > k3s-cp.yaml
      /usr/local/bin/aws s3 cp k3s-cp.yaml s3://${state_bucket}/k3s.yaml
      rm -rf k3s-cp.yaml

      popd
      ;;
    *)
      info 'Skipping kubeconfig upload since we are not a server'
      ;;
  esac

}

bootstrap() {
  export $(grep -v '^#' $K3S_STATE_PATH | xargs)

  node_labels=$(format_args "$NODE_LABELS" "--node-label")
  kubelet_args=$(format_args "$KUBELET_ARGS" "--kubelet-arg")
  node_taints=$(format_args "$NODE_TAINTS" "--node-taint")

  token=$(format_args "$TOKEN" "--token")

  shared_args="$${node_labels} $${kubelet_args} $${node_taints} $${token}"

  if ${cloud_provider}; then
    provider="aws:///$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)/$(curl -s http://169.254.169.254/latest/meta-data/instance-id)"
    shared_args="$${shared_args} --kubelet-arg provider-id=$${provider}"
  fi

  type_args=""

  case "$1" in
    # -- server ---
    "server")
      tls_sans=$(format_args "$TLS_SANS" "--tls-san")
      disables=$(format_args "$DISABLES" "--disable")

      kube_apiservers=$(format_args "$KUBE_APISERVERS" "--kube-apiserver-arg")
      kube_schedulers=$(format_args "$KUBE_SCHEDULERS" "--kube-scheduler-arg")
      kube_controller_managers=$(format_args "$KUBE_CONTROLLER_MANAGERS" "--kube-controller-manager-arg")
      kube_cloud_controller_managers=$(format_args "$KUBE_CONTROLLER_MANAGERS" "--kube-cloud-controller-manager-arg")

      datastore_cafile=$(format_args "/etc/ssl/certs/rds-combined-ca-bundle.pem" "--datastore-cafile")
      datastore_endpoint=$(format_args "$DATASTORE_ENDPOINT" "--datastore-endpoint")

      type_args="server $${tls_sans} $${disables} $${datastore_endpoint} $${kube_apiservers} $${kube_schedulers} $${kube_controller_managers} $${kube_cloud_controller_managers}"

      if ${cloud_provider}; then
        type_args="$${type_args} --disable-cloud-controller --kube-apiserver-arg cloud-provider=external --kube-controller-manager-arg cloud-provider=external --disable traefik --disable local-storage --disable servicelb"
      fi
      ;;
    # -- agent --
    "agent")
      server=$(format_args "$SERVER" "--server")

      type_args="agent $${server}"
      ;;
    *)
      fatal 'Only server and agent are expected for bootstrap'
      ;;
  esac

  # Unset secrets from s3 .env
  unset $(grep -v '^#' $K3S_STATE_PATH  | sed -E 's/(.*)=.*/\1/' | xargs)
  rm -rf /var/lib/k3s/state.env

  cat /usr/local/bin/k3s.sh | sh -s - $${type_args} $${shared_args}

}

{
  export K3S_KUBECONFIG_MODE="0644"
  export INSTALL_K3S_SKIP_DOWNLOAD=true

  # Enable and start the node-drain service
  node_drain

  rds_ca

  # TODO: full selinux support in k3s is still a wip, while most deployments will work, it is not GA
  setenforce 0

  # Boot
  bootstrap ${type}

  # Upload kubeconfig to s3
  upload ${type}
}