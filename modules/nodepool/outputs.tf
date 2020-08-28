output "autoscaling_group_name" {
  value = aws_autoscaling_group.this.name
}

output "security_group" {
  value = aws_security_group.this.id
}