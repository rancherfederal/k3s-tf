provider "aws" {
  version = "~> 3.0"
}

locals {
  pre_userdata = templatefile("fetchdeps.sh", {
    k3s_binary_download_url = "${var.fileserver_url}/k3s"
    k3s_images_download_url = "${var.fileserver_url}/k3s-airgap-images-amd64.tar"
  })
}

module "k3s" {
  source = "../../"

  name = var.name

  vpc_id  = var.vpc_id != null ? var.vpc_id : data.aws_vpc.default.id
  subnets = var.subnets != null ? var.subnets : data.aws_subnet_ids.all.ids

  tags = var.tags
}

# Primary server nodepool
module "servers" {
  source = "../../modules/nodepool"

  vpc_id  = var.vpc_id != null ? var.vpc_id : data.aws_vpc.default.id
  subnets = var.subnets != null ? var.subnets : data.aws_subnet_ids.all.ids

  name    = "primary-servers"
  cluster = module.k3s.cluster

  ami          = var.ami != null ? var.ami : data.aws_ami.rhel8.id
  pre_userdata = local.pre_userdata

  tags = var.tags
}

# Generic a gent nodepool
module "generic_agents" {
  source = "../../modules/nodepool"

  vpc_id  = var.vpc_id != null ? var.vpc_id : data.aws_vpc.default.id
  subnets = var.subnets != null ? var.subnets : data.aws_subnet_ids.all.ids

  name    = "generic-agents"
  cluster = module.k3s.cluster

  ami          = var.ami != null ? var.ami : data.aws_ami.rhel8.id
  pre_userdata = local.pre_userdata

  tags = var.tags
}