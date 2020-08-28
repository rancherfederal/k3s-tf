#
# K3S resources
#
resource "random_password" "token" {
  length  = 32
  special = false
}

#
# Control plane Lb
#
module "controlplane_lb" {
  source = "./modules/controlplane-lb"

  name    = var.name
  vpc_id  = var.vpc_id
  subnets = var.subnets

  # AWS CCM Tagging
  tags = merge({
    "kubernetes.io/cluster/${var.name}" = "owned"
  }, var.tags)
}