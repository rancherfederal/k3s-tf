#
# Database Outputs
#
output "datastore_endpoint" {
  value       = module.db.datastore_endpoint
  description = "Formatted output for k3s --datastore-endpoint.  This is output for verbosity and does not need to be passed into node pools, it will be fetched from the cluster state bucket on node boot"
}

#
# Controlplane Load Balancer Outputs
#
output "controlplane_loadbalancer" {
  value       = module.controlplane_lb.name
  description = "Name of the controlplane load balancer"
}

output "tls_san" {
  value       = module.controlplane_lb.dns
  description = "DNS of the control plane load balancer, used for passing --tls-san to server nodepools"
}

output "url" {
  value       = "https://${module.controlplane_lb.dns}:${module.controlplane_lb.port}"
  description = "Formatted load balancer url used for --server on agent node pools"
}

#
# Shared Resource Outputs
#
output "cluster_security_group" {
  value       = aws_security_group.cluster.id
  description = "Shared cluster security group required to be passed into all node pools"
}

output "shared_server_security_group" {
  value       = aws_security_group.shared_server.id
  description = "Shared server security group required to be passed into all server node pools"
}

output "shared_agent_security_group" {
  value       = aws_security_group.shared_agent.id
  description = "Shared agent security group optional to be passed into all agent node pools"
}

#
# K3S Outputs
#
output "cluster" {
  value       = var.name
  description = "Name of the cluster to be passed into all node pools"
}

output "token" {
  value       = random_password.token.result
  description = "Token used for k3s --token registration, added for brevity, does not need to be passed to module, it is loaded via S3 state bucket"
}

#
# State Bucket Resources
#
output "state_bucket" {
  value       = var.state_bucket == null ? module.state[0].bucket : var.state_bucket
  description = "Name of the bucket used to store k3s cluster state, required to be passed in to node pools"
}

output "state_bucket_arn" {
  value       = var.state_bucket == null ? module.state[0].arn : null
  description = "ARN of the bucket used to store k3s cluster state, if it was created. Null will be outputted if the module did not create the bucket."
}

output "state_key" {
  value       = aws_s3_bucket_object.state.key
  description = "Name of the state object used to store k3s cluster state"
}
