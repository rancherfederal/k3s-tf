data "template_cloudinit_config" "this" {
  gzip          = true
  base64_encode = true

  # Main cloud-init config file
  part {
    filename     = "cloud-config-base.yaml"
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/files/cloud-config-base.yaml", {
      ssh_authorized_keys = var.ssh_authorized_keys

      # Manifests to autodeploy on boot
      manifests = var.auto_deployed_manifests
    })
  }

  # pre k3s bootstrap userdata
  part {
    filename     = "00_pre_bootstrap.sh"
    content_type = "text/x-shellscript"
    content      = base64decode(var.pre_userdata)
  }

  # k3s bootstrap script
  part {
    filename     = "01_bootstrap.sh"
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/files/install.sh", {

    })
  }

  # post k3s bootstrap userdata
  part {
    filename     = "02_post_bootstrap.sh"
    content_type = "text/x-shellscript"
    content      = base64decode(var.post_userdata)
  }
}