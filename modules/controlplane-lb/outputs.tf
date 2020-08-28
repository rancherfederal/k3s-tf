output "dns" {
  value = aws_lb.this.dns_name
}

output "port" {
  value = aws_lb_target_group.server_6443.port
}

output "targetgroup_arn" {
  value = aws_lb_target_group.server_6443.arn
}