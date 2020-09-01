terraform {
  required_version = ">= 0.13.0"

  required_providers {
    aws      = "~> 3.0"
    local    = "~> 1.0"
    tls      = "~> 2.0"
    template = "~> 2.0"
  }
}