resource "aws_s3_bucket" "state" {
  bucket        = "${var.name}-k3s-cluster"
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
    }
  }

  tags = var.tags
}
