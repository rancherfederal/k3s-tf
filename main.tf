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
resource "aws_security_group_rule" "all_self_ingress" {
  description       = "Allow all ingress traffic between cluster nodes"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.shared.id
  type              = "ingress"

  self = true
}

resource "aws_security_group_rule" "all_self_egress" {
  description       = "Allow all egress traffic"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.shared.id
  type              = "egress"

  cidr_blocks = ["0.0.0.0/0"]
}

#
# Cluster Servers Shared Security Group
#
resource "aws_security_group" "shared_server" {
  name        = "${var.name}-k3s-shared-server-sg"
  vpc_id      = var.vpc_id
  description = "Shared k3s server security group"

  tags = merge({
    "shared" = "true",
  }, var.tags)
}

resource "aws_security_group_rule" "controlplane_ingress" {
  description       = "All traffic between nodes"
  from_port         = module.controlplane_lb.port
  to_port           = module.controlplane_lb.port
  protocol          = "tcp"
  security_group_id = aws_security_group.shared.id
  type              = "ingress"

  cidr_blocks = [data.aws_vpc.this.cidr_block]
}
