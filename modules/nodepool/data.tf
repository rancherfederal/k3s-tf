data "template_cloudinit_config" "this" {
  gzip          = true
  base64_encode = true

  # Main cloud-init config file
  part {
    filename     = "cloud-config-base.yaml"
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/files/cloud-config-base.yaml", {
      # get.k3s.io install script
      k3s_install = filebase64("${path.module}/files/install.sh")

      ssh_authorized_keys = var.ssh_authorized_keys

      # Manifests to autodeploy on boot
      manifests = var.auto_deployed_manifests
    })
  }

  # pre k3s bootstrap userdata
  part {
    filename     = "00_pre_bootstrap.sh"
    content_type = "text/x-shellscript"
    content      = var.pre_userdata == null ? "" : base64decode(var.pre_userdata)
  }

  # k3s bootstrap script
  part {
    filename     = "01_bootstrap.sh"
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/files/bootstrap.sh", {
      # Server if no k3s_url is specified
      is_server = var.k3s_url == null ? true : false

      # Server K3S Variables
      datastore_endpoint = var.k3s_datastore_endpoint
      tls_sans           = var.k3s_tls_sans

      # Agent K3S Variables
      server = var.k3s_url

      # Shared K3S Variables
      token        = var.k3s_token
      kubelet_args = var.k3s_kubelet_args
      node_labels  = var.k3s_node_labels
      node_taints  = var.k3s_node_taints
    })
  }

  # post k3s bootstrap userdata
  part {
    filename     = "02_post_bootstrap.sh"
    content_type = "text/x-shellscript"
    content      = var.post_userdata == null ? "" : base64decode(var.post_userdata)
  }
}