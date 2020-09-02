locals {
  gzip_manifests = [for manifest in var.auto_deployed_manifests : { name : manifest.name, content : base64gzip(manifest.content) }]
}

data "template_cloudinit_config" "this" {
  gzip          = true
  base64_encode = true

  # Main cloud-init config file
  part {
    filename     = "cloud-config-base.yaml"
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/files/cloud-config-base.yaml", {
      k3s_install       = base64gzip(file("${path.module}/files/k3s.sh"))
      nodedrain         = base64gzip(file("${path.module}/files/nodedrain.sh"))
      nodedrain_service = base64gzip(file("${path.module}/files/nodedrain.service"))
      ccm               = var.enable_cloud_provider ? base64gzip(file("${path.module}/files/aws-ccm.yaml")) : ""
      ebs               = var.enable_cloud_provider ? base64gzip(file("${path.module}/files/aws-ebs.yaml")) : ""

      ssh_authorized_keys = var.ssh_authorized_keys

      # Manifests to autodeploy on boot
      manifests = local.gzip_manifests
    })
  }

  # downloader (NOTE: In a production deployment, this is usually replaced by custom AMIs)
  part {
    filename     = "00_download_dependencies.sh"
    content_type = "text/x-shellscript"
    content = var.dependencies_script != null ? var.dependencies_script : templatefile("${path.module}/files/download_dependencies.sh", {
      k3s_version = var.k3s_version
    })
  }

  # secrets fetcher script
  part {
    filename     = "01_secrets.sh"
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/files/secrets.sh", {
      state_bucket = var.state_bucket
      state_key    = var.state_key
    })
  }

  # k3s bootstrap script
  part {
    filename     = "02_bootstrap.sh"
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/files/bootstrap.sh", {
      state_bucket = var.state_bucket
      state_key    = var.state_key

      # Server if no k3s_url is specified
      type = local.is_server ? "server" : "agent"

      # Server K3S Variables
      tls_sans                       = join(";", var.k3s_tls_sans)
      disables                       = join(";", var.k3s_disables)
      kube_apiservers                = join(";", var.k3s_kube_apiservers)
      kube_schedulers                = join(";", var.k3s_kube_schedulers)
      kube_controller_managers       = join(";", var.k3s_kube_controller_managers)
      kube_cloud_controller_managers = join(";", var.k3s_kube_cloud_controller_managers)

      # Agent K3S Variables
      server = var.k3s_url

      # Shared K3S Variables
      cloud_provider = var.enable_cloud_provider
      k3s_version    = var.k3s_version
      kubelet_args   = join(";", var.k3s_kubelet_args)
      node_labels    = join(";", var.k3s_node_labels)
      node_taints    = join(";", var.k3s_node_taints)
    })
  }
}