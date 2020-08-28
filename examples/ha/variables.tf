variable "name" {}

variable "vpc_id" {
  default = null
}

variable "subnets" {
  default = null
}

variable "ami" {
  default = null
}

variable "tags" {
  default = {}
}