output "name" {
  value = aws_elb.this.name
}

output "dns" {
  value = aws_elb.this.dns_name
}

output "port" {
  value = var.port
}
