#
# K3S resources
#
resource "random_password" "token" {
  length  = 32
  special = false
}

resource "random_password" "db" {
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
# Database
#
module "db" {
  source = "./modules/database"

  name     = var.name
  vpc_id   = var.vpc_id
  subnets  = var.subnets
  password = random_password.db.result

  ca_cert_identifier = var.rds_ca_cert_identifier

  tags = var.tags
}

#
# Cluster Shared Security Group
#
resource "aws_security_group" "cluster" {
  name        = "${var.name}-k3s-cluster-sg"
  vpc_id      = var.vpc_id
  description = "Shared cluster k3s server/agent security group"

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
  security_group_id = aws_security_group.cluster.id
  type              = "ingress"

  self = true
}

resource "aws_security_group_rule" "all_self_egress" {
  description       = "Allow all egress traffic"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.cluster.id
  type              = "egress"

  cidr_blocks = ["0.0.0.0/0"]
}

#
# Shared Security Groups
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
  security_group_id = aws_security_group.shared_server.id
  type              = "ingress"

  cidr_blocks = [data.aws_vpc.this.cidr_block]
}

resource "aws_security_group_rule" "server_db_ingress" {
  description       = "Allow servers to connect to DB"
  from_port         = module.db.port
  to_port           = module.db.port
  protocol          = "tcp"
  security_group_id = module.db.sg
  type              = "ingress"

  source_security_group_id = aws_security_group.shared_server.id
}

resource "aws_security_group" "shared_agent" {
  name        = "${var.name}-k3s-shared-agent-sg"
  vpc_id      = var.vpc_id
  description = "Shared k3s agent security group"

  tags = merge({
    "shared" = "true",
  }, var.tags)
}

#
# State Storage
#
module "state" {
  source = "./modules/state-store"

  count = var.state_bucket == null ? 1 : 0

  name = var.name
}

resource "aws_s3_bucket_object" "state" {
  bucket = var.state_bucket == null ? module.state[0].bucket : var.state_bucket
  key    = "state.env"

  content_type = "text/plain"
  content      = <<-EOT
TOKEN=${random_password.token.result}
DATASTORE_ENDPOINT=${module.db.datastore_endpoint}
EOT
}