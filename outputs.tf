#
# Controlplane Load Balancer Outputs
#
output "tls_san" {
  value = module.controlplane_lb.dns
}

output "url" {
  description = "Formatted load balancer url used for --server on agent node pools"
  value       = "https://${module.controlplane_lb.dns}:${module.controlplane_lb.port}"
}

#
# Shared Resource Outputs
#
output "shared_security_group" {
  value = aws_security_group.shared.id
}

output "shared_server_security_group" {
  value = aws_security_group.shared_server.id
}

#
# K3S Outputs
#
output "cluster" {
  value = var.name
}

output "token" {
  value = random_password.token.result
}