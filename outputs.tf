#
# Database Outputs
#
output "datastore_endpoint" {
  value = module.db.datastore_endpoint
}

#
# Controlplane Load Balancer Outputs
#
output "controlplane_loadbalancer" {
  value = module.controlplane_lb.name
}

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
output "cluster_security_group" {
  value = aws_security_group.cluster.id
}

output "shared_server_security_group" {
  value = aws_security_group.shared_server.id
}

output "shared_agent_security_group" {
  value = aws_security_group.shared_agent.id
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

#
# State Bucket Resources
#
output "state_bucket" {
  value = var.state_bucket == null ? module.state[0].bucket : var.state_bucket
}

output "state_key" {
  value = aws_s3_bucket_object.state.key
}