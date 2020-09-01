variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "instance_class" {
  type    = string
  default = "db.t2.medium"
}

variable "username" {
  type    = string
  default = "k3s"
}

variable "password" {
  type = string
}

variable "allocated_storage" {
  type    = number
  default = 5
}

variable "max_allocated_storage" {
  type    = number
  default = 100
}

variable "ca_cert_identifier" {
  type    = string
  default = "rds-ca-2017" # govcloud default
}

variable "tags" {
  type    = map(string)
  default = {}
}