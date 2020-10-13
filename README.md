# k3s-tf

__Warning__: This repo is still a WIP.  While it contains ready deployments, many of the components are still subject to change.

Terraform IAC for HA K3S on Commercial, GovCloud, or (T)C2S AWS regions.

Since k3s doesn't enforce an installation approach, there are many approaches to cluster bootstrapping.  This repository demonstrates _one_ of the many ways to go from 0 to infrastructure + HA cluster in just a few minutes.  

This repo is tailored to deploy on all AWS regions, and uses only the cloud services that exist on all environments.  As such, the following services are required:

* Autoscaling Groups
* RDS MySQL
* Classic Load Balancers (C2S compatibility)
* S3 (C2S compatibility)

TODO: More docs on architecture, inputs, etc...## Requirements

## Examples

Examples are provided in the `examples/` directory for common use cases:

* `full-ha`: Zero to hero full environment + cluster.  Will create network (vpc, subnets, etc...) resources and HA cluster in an online environment.  This is default use case and is tested against commercial and govcloud AWS.
* `offline`: Restricted privilage airgapped cluster.  Will use existing resources to deploy cluster in an entirely airgapped environment.  This is tested against C2S.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the cluster, will be prepended to cluster resources | `string` | n/a | yes |
| subnets | List of subnet ids of the shared cluster resources such as load balancers and RDS.  Generally set to private subnets | `list(string)` | n/a | yes |
| vpc\_id | VPC ID of the cluster | `string` | n/a | yes |
| rds\_ca\_cert\_identifier | RDS CA Certificate Identifier | `string` | `"rds-ca-2017"` | no |
| state\_bucket | Name of existing S3 bucket to store cluster state/secrets in, will create bucket if left blank | `string` | `null` | no |
| tags | Common tags to attach to all created resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster | Name of the cluster to be passed into all node pools |
| cluster\_security\_group | Shared cluster security group required to be passed into all node pools |
| controlplane\_loadbalancer | Name of the controlplane load balancer |
| datastore\_endpoint | Formatted output for k3s --datastore-endpoint.  This is output for verbosity and does not need to be passed into node pools, it will be fetched from the cluster state bucket on node boot |
| shared\_agent\_security\_group | Shared agent security group optional to be passed into all agent node pools |
| shared\_server\_security\_group | Shared server security group required to be passed into all server node pools |
| state\_bucket | Name of the bucket used to store k3s cluster state, required to be passed in to node pools |
| state\_bucket\_arn | ARN of the bucket used to store k3s cluster state, if it was created. Null will be outputted if the module did not create the bucket. |
| state\_key | Name of the state object used to store k3s cluster state |
| tls\_san | DNS of the control plane load balancer, used for passing --tls-san to server nodepools |
| token | Token used for k3s --token registration, added for brevity, does not need to be passed to module, it is loaded via S3 state bucket |
| url | Formatted load balancer url used for --server on agent node pools |

