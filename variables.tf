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

variable "rds_ca_cert_identifier" {
  type    = string
  default = "rds-ca-2017"
}

variable "tags" {
  type    = map(string)
  default = {}
}