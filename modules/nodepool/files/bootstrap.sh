#!/bin/bash
provision() {
  cat /usr/local/bin/install.sh | sh -s - %{ if is_server }server%{ else }agent%{ endif } \
    --token "${token}" \
%{ for arg in kubelet_args }--kubelet-arg "${arg}" %{ endfor } \
%{ for arg in node_labels }--node-label "${arg}" %{ endfor } \
%{ for arg in node_taints }--node-taint "${arg}" %{ endfor } \

%{~ if is_server ~}
# TODO: Once perms are fixed
#    --datastore-endpoint "${datastore_endpoint}" \
%{ for arg in tls_sans }--tls-san "${arg}" %{ endfor }

%{~ else ~}
    --server "${server}"

%{~ endif }
}

{
  export INSTALL_K3S_SKIP_DOWNLOAD=true
  export K3S_KUBECONFIG_MODE="0644"

  # TODO: This
  export INSTALL_K3S_SELINUX_WARN="true"

  # Boot
  provision
}