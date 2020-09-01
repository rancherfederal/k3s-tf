#!/bin/bash
set -eu

K3S_DOWNLOAD_URL="${k3s_download_url}"
K3S_VERSION="${k3s_version}"

yum install -y \
  unzip \
  container-selinux \
  selinux-policy-base \
  k3s-selinux

# working directory
cd /usr/local/bin

# k3s dependencies
curl -OLs "$${K3S_DOWNLOAD_URL}/$${K3S_VERSION}/{k3s,k3s-airgap-images-amd64.tar,k3s-images.txt,sha256sum-amd64.txt}"
sha256sum -c sha256sum-amd64.txt

if [ $? -ne 0 ]
  then
    echo "[ERROR] checksums of k3s files do not match"
    exit 1
fi

chmod 755 k3s*
mkdir -p /var/lib/rancher/k3s/agent/images/ && mv k3s-airgap-images-amd64.tar /var/lib/rancher/k3s/agent/images/
