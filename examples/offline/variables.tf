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

variable "state_bucket" {
  type = string
}

variable "tags" {
  default = {}
}