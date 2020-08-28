output "dns" {
  value = aws_elb.this.dns_name
}

output "port" {
  value = aws_elb.this.listener.lb_port
}
