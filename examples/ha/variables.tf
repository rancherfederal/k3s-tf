variable "name" {
  type    = string
  default = "k3s-ha"
}

variable "vpc_id" {
  type = string
}

variable "subnets" {
  type = string
}

variable "ami" {
  default = "ami-02354e95b39ca8dec"
}

variable "tags" {
  default = {
    "terraform" = "true",
    "env"       = "demo",
  }
}