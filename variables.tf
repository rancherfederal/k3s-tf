variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "state_bucket" {
  type    = string
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}