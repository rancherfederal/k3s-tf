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

output "lb_target_group_arn" {
  description = "Load balancer target group arn used for attaching server nodes to the control plane network load balancer"
  value       = module.controlplane_lb.targetgroup_arn
}

#
# K3S Outputs
#
output "name" {
  value = var.name
}

output "token" {
  value = random_password.token.result
}