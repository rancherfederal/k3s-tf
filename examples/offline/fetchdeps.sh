#!/bin/bash

K3S_BINARY_DOWNLOAD_URL="${k3s_binary_download_url}"
K3S_IMAGES_DOWNLOAD_URL="${k3s_images_download_url}"
K3S_IMAGES_PRELOAD_DIR="/var/lib/rancher/k3s/agent/images"

setup_binary() {
  curl -sfL -o /usr/local/bin/k3s $K3S_BINARY_DOWNLOAD_URL
  chmod +x /usr/local/bin/k3s
}

setup_images() {
  mkdir -p $K3S_IMAGES_PRELOAD_DIR
  curl -sfL -o $K3S_IMAGES_PRELOAD_DIR/k3s-images.tar $K3S_IMAGES_DOWNLOAD_URL
}

{
  setup_binary
  setup_images
}