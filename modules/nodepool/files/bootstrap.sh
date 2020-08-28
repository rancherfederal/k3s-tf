#!/bin/bash

{
  export INSTALL_K3S_SKIP_DOWNLOAD=true
  export K3S_KUBECONFIG_MODE="0644"

  # Boot
  /usr/local/bin/install.sh
}