data "aws_vpc" "this" {
  id = var.vpc_id
}

data "aws_s3_bucket_object" "kube-config-yaml" {
    bucket = module.k3s.state_bucket
    key = "k3s.yaml"
}