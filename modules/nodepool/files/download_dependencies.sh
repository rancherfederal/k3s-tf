#!/bin/bash
set -eu

K3S_VERSION="${k3s_version}"

yum_dependencies() {
  yum install -y \
    unzip \
    container-selinux \
    selinux-policy-base \
    k3s-selinux
}

k3s() {
  # k3s dependencies
  curl -OLs "https://github.com/rancher/k3s/releases/download/$${K3S_VERSION}/{k3s,k3s-airgap-images-amd64.tar,k3s-images.txt,sha256sum-amd64.txt}"
  sha256sum -c sha256sum-amd64.txt

  if [ $? -ne 0 ]
    then
      echo "[ERROR] checksums of k3s files do not match"
      exit 1
  fi

  chmod 755 k3s*
  mkdir -p /var/lib/rancher/k3s/agent/images/ && mv k3s-airgap-images-amd64.tar /var/lib/rancher/k3s/agent/images/
}

aws_cli() {
  # AWS CLI
  curl -sL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip && unzip -qq -d /tmp /tmp/awscliv2.zip && /tmp/aws/install
  rm -rf /tmp/aws*

  # Set default region for cli as current instances region
  /usr/local/bin/aws configure set default.region $(curl -s http://169.254.169.254/latest/meta-data/placement/region)
}

rancher_yum_repo() {
  tee /etc/yum.repos.d/rpm.rancher.io.repo >/dev/null << EOF
[rancher]
name=Rancher
baseurl=https://rpm.rancher.io
enabled=1
gpgcheck=1
gpgkey=https://rpm.rancher.io/public.key
EOF
}

{
  # working directory
  cd /usr/local/bin

  # Add official rancher yum repo
  rancher_yum_repo

  # Install dependencies with yum
  yum_dependencies

  # Install k3s binary and images
  k3s

  # Install aws cli
  aws_cli
}