variable "name" {
  type    = string
  default = "k3s-ha-offline"
}

variable "vpc_id" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "ami" {
  default = "ami-02354e95b39ca8dec"
}

variable "iam_instance_profile" {
  default = ""
}

variable "rds_ca_cert_identifier" {
  default = "rds-ca-2017"
}

variable "download_dependencies" {
  type    = string
  default = "../../modules/nodepool/files/download_dependencies.sh"
}

variable "state_bucket" {
  type = string
}

variable "public_keys" {
  type    = list(string)
  default = []
}

variable "tags" {
  default = {}
}