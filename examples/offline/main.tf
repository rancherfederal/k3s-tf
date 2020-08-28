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

  k3s_token = module.k3s.token

  tags = var.tags
}

# Generic a gent nodepool
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