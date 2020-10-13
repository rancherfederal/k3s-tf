output "bucket" {
  value = aws_s3_bucket.state.bucket
}

output "arn" {
  value = aws_s3_bucket.state.arn
}
