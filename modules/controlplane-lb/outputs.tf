output "dns" {
  value = aws_elb.this.dns_name
}

output "port" {
  value = var.port
}
