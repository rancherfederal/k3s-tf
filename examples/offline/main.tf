provider "aws" {
  version = "~> 3.0"
}

locals {
  download_dependencies = file(var.download_dependencies)
}

module "k3s" {
  source = "../../"

  name = var.name

  vpc_id       = var.vpc_id
  subnets      = var.subnets
  state_bucket = var.state_bucket

  rds_ca_cert_identifier = var.rds_ca_cert_identifier

  tags = var.tags
}

# Primary server nodepool
module "servers" {
  source = "../../modules/nodepool"

  # Node variables
  name                 = "primary-servers"
  vpc_id               = var.vpc_id
  subnets              = var.subnets
  ami                  = var.ami
  ssh_authorized_keys  = var.public_keys
  iam_instance_profile = var.iam_instance_profile
  asg                  = { min : 1, max : 3, desired : 2 }

  # Cluster variables
  cluster                   = module.k3s.cluster
  cluster_security_group    = module.k3s.cluster_security_group
  extra_security_groups     = [module.k3s.shared_server_security_group]
  controlplane_loadbalancer = module.k3s.controlplane_loadbalancer
  state_bucket              = module.k3s.state_bucket

  dependencies_script = local.download_dependencies

  # K3S Variables
  k3s_tls_sans    = [module.k3s.tls_san]
  k3s_node_labels = ["type=primary-server"]

  tags = var.tags
}

# Generic agent nodepool
module "generic_agents" {
  source = "../../modules/nodepool"

  # Node Variables
  name                 = "generic-agents"
  vpc_id               = var.vpc_id
  subnets              = var.subnets
  ami                  = var.ami
  ssh_authorized_keys  = var.public_keys
  iam_instance_profile = var.iam_instance_profile
  asg                  = { min : 1, max : 2, desired : 1 }

  # Cluster Variables
  cluster                = module.k3s.cluster
  cluster_security_group = module.k3s.cluster_security_group
  state_bucket           = module.k3s.state_bucket

  dependencies_script = local.download_dependencies

  # K3S Variables
  k3s_node_labels = ["type=generic-agent"]
  k3s_url         = module.k3s.url

  tags = var.tags
}

# NOTE: Nothing with the bootstrap process requires ssh, but for this example we open ssh on the server nodes for example purposes
resource "aws_security_group_rule" "ssh" {
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = module.k3s.cluster_security_group
  type              = "ingress"

  cidr_blocks = ["0.0.0.0/0"]
}