output "dns" {
  value = aws_elb.this.dns_name
}

output "port" {
  value = aws_elb.this.listener[0].lb_port
}
