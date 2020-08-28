provider "aws" {
  version = "~> 3.0"
}

locals {
  pre_userdata = base64encode(templatefile("fetchdeps.sh", {
    k3s_binary_download_url = "${var.fileserver_url}/k3s"
    k3s_images_download_url = "${var.fileserver_url}/k3s-airgap-images-amd64.tar"
  }))
}

module "k3s" {
  source = "../../"

  name = var.name

  vpc_id  = var.vpc_id
  subnets = var.subnets

  tags = var.tags
}

# Primary server nodepool
module "servers" {
  source     = "../../modules/nodepool"
  depends_on = [module.k3s]

  vpc_id  = var.vpc_id
  subnets = var.subnets

  name                 = "primary-servers"
  cluster              = module.k3s.cluster
  ami                  = var.ami
  iam_instance_profile = var.iam_instance_profile
  pre_userdata         = local.pre_userdata

  k3s_token    = module.k3s.token
  k3s_tls_sans = [module.k3s.tls_san]

  tags = var.tags
}

# Generic agent nodepool
module "generic_agents" {
  source     = "../../modules/nodepool"
  depends_on = [module.k3s]

  vpc_id  = var.vpc_id
  subnets = var.subnets

  name                 = "generic-agents"
  cluster              = module.k3s.cluster
  ami                  = var.ami
  iam_instance_profile = var.iam_instance_profile
  pre_userdata         = local.pre_userdata

  k3s_token = module.k3s.token
  k3s_url   = module.k3s.url

  tags = var.tags
}

# NOTE: Nothing with the bootstrap process requires ssh, but for this example we open ssh on the server nodes for example purposes
resource "aws_security_group_rule" "ssh" {
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = module.k3s.shared_security_group
  type              = "ingress"

  cidr_blocks = ["0.0.0.0/0"]
}