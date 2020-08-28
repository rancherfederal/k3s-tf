variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "internal" {
  default = true
}

variable "port" {
  default = 6443
}

variable "tags" {
  default = {}
}