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

#
# Cluster Shared Security Group
#
resource "aws_security_group" "shared" {
  name        = "${var.name}-k3s-shared-sg"
  vpc_id      = var.vpc_id
  description = "Shared k3s server/agent security group"

  tags = merge({
    "shared" = "true",
  }, var.tags)
}

# TODO: Trim these down
resource "aws_security_group_rule" "all-self" {
  description       = "All traffic between nodes"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.shared.id
  type              = "ingress"

  self = true
}
