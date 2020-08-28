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

variable "fileserver_url" {
  type = string

  # In practice, this is replaced with the airgapped file server
  default = "https://github.com/rancher/k3s/releases/download/v1.18.8%2Bk3s1"
}

variable "tags" {
  default = {}
}