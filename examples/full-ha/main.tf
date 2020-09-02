provider "aws" {
  version = "~> 3.0"
}

data "aws_ami" "rhel8" {
  owners      = [219670896067]
  most_recent = true

  filter {
    name   = "name"
    values = ["RHEL-8.3*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "tls_private_key" "global_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "local_file" "ssh_private_key_pem" {
  filename          = "${path.module}/id_rsa"
  sensitive_content = tls_private_key.global_key.private_key_pem
  file_permission   = "0600"
}

resource "local_file" "ssh_public_key_openssh" {
  filename = "${path.module}/id_rsa.pub"
  content  = tls_private_key.global_key.public_key_openssh
}

module "network" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.48.0"

  name = "full-online-ha-k3s"
  cidr = "10.188.0.0/16"

  azs             = ["us-gov-west-1a", "us-gov-west-1b", "us-gov-west-1c"]
  public_subnets  = ["10.188.1.0/24", "10.188.2.0/24", "10.188.3.0/24"]
  private_subnets = ["10.188.101.0/24", "10.188.102.0/24", "10.188.103.0/24"]

  enable_nat_gateway   = true
  enable_vpn_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

module "k3s" {
  source = "../../"

  name = var.name

  vpc_id  = module.network.vpc_id
  subnets = module.network.public_subnets

  tags = var.tags
}

# Primary server nodepool
module "servers" {
  source = "../../modules/nodepool"

  # Node variables
  name                  = "primary-servers"
  vpc_id                = module.network.vpc_id
  subnets               = module.network.public_subnets
  ami                   = data.aws_ami.rhel8.id
  ssh_authorized_keys   = [tls_private_key.global_key.public_key_openssh]
  iam_instance_profile  = "InstanceOpsRole"
  asg                   = { min : 1, max : 3, desired : 2 }
  block_device_mappings = { size : 64, encrypted : true }

  # Cluster join variables
  cluster                   = module.k3s.cluster
  cluster_security_group    = module.k3s.cluster_security_group
  extra_security_groups     = [module.k3s.shared_server_security_group]
  controlplane_loadbalancer = module.k3s.controlplane_loadbalancer
  state_bucket              = module.k3s.state_bucket

  # K3S Variables
  k3s_tls_sans            = [module.k3s.tls_san]
  k3s_node_labels         = ["type=primary-server"]
  auto_deployed_manifests = []

  tags = var.tags
}

# Generic agent nodepool
module "generic_agents" {
  source = "../../modules/nodepool"

  name                 = "generic-agents"
  vpc_id               = module.network.vpc_id
  subnets              = module.network.public_subnets
  ami                  = data.aws_ami.rhel8.id
  ssh_authorized_keys  = [tls_private_key.global_key.public_key_openssh]
  iam_instance_profile = "InstanceOpsRole"
  asg                  = { min : 1, max : 2, desired : 1 }

  # Cluster join variables
  cluster                = module.k3s.cluster
  cluster_security_group = module.k3s.cluster_security_group
  state_bucket           = module.k3s.state_bucket

  # K3S Variabels
  k3s_node_labels = ["type=generic-agent"]
  k3s_url         = module.k3s.url

  tags = var.tags
}

# Open ssh for demo demonstrations, ssh is not a required part of cluster bootstrapping
resource "aws_security_group_rule" "demo_ssh" {
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = module.k3s.cluster_security_group
  type              = "ingress"

  cidr_blocks = ["0.0.0.0/0"]
}