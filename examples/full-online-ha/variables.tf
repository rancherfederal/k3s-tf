variable "name" {
  type    = string
  default = "k3s-ha"
}

variable "ssh_authorized_keys" {
  type    = list(string)
  default = []
}

variable "tags" {
  default = {
    "terraform" = "true",
    "env"       = "demo",
  }
}