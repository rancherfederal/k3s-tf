provider "aws" {
  region = "us-gov-west-1"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.default.id
}

data "aws_ami" "rhel8" {
  owners      = ["219670896067"]
  most_recent = true

  filter {
    name   = "name"
    values = ["RHEL-8.3*"]
  }
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

  ami = var.ami != null ? var.ami : data.aws_ami.rhel8.id

  tags = var.tags
}

# Generic a gent nodepool
module "generic_agents" {
  source = "../../modules/nodepool"

  vpc_id  = var.vpc_id != null ? var.vpc_id : data.aws_vpc.default.id
  subnets = var.subnets != null ? var.subnets : data.aws_subnet_ids.all.ids

  name    = "generic-agents"
  cluster = module.k3s.cluster

  ami = var.ami != null ? var.ami : data.aws_ami.rhel8.id

  tags = var.tags
}