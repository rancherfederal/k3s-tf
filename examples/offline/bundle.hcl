terraform {
  # Version of Terraform to include in the bundle. An exact version number
  # is required.
  version = "0.13.1"
}

# Define which provider plugins are to be included
providers {
  # Include the newest "aws" provider version in the 1.0 series.
  aws = {
    versions = ["~> 3.0"]
  }

  template = {
    versions = ["~> 2.0"]
  }

  random = {
    versions = ["~> 2.0"]
  }
}
