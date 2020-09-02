# nodepool

Shared module for creating k3s server and agent nodepools.
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| template | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ami | AMI of all EC2 instances within the nodepool | `string` | n/a | yes |
| cluster | Name of the cluster the nodepool belongs to, sourced from k3s module | `string` | n/a | yes |
| cluster\_security\_group | n/a | `string` | n/a | yes |
| name | Name of the node pool, to be appended to all resources | `string` | n/a | yes |
| subnets | List of subnet ids the nodepool is deployed to | `list(string)` | n/a | yes |
| vpc\_id | VPC ID the nodepool is deployed to | `string` | n/a | yes |
| asg | Autoscaling group scale, requires min, max, and desired | <pre>object({<br>    min     = number<br>    max     = number<br>    desired = number<br>  })</pre> | <pre>{<br>  "desired": 1,<br>  "max": 2,<br>  "min": 1<br>}</pre> | no |
| auto\_deployed\_manifests | n/a | `list(string)` | `[]` | no |
| block\_device\_mappings | n/a | <pre>object({<br>    size      = number<br>    encrypted = bool<br>  })</pre> | <pre>{<br>  "encrypted": true,<br>  "size": 32<br>}</pre> | no |
| controlplane\_loadbalancer | n/a | `string` | `null` | no |
| dependencies\_script | Dependencies script responsible for any pre-node setup, overriding this overrides the default setup and requires AT LEAST the k3s binary and aws cli downloaded before proceeding | `string` | `null` | no |
| enable\_cloud\_provider | n/a | `bool` | `true` | no |
| extra\_security\_groups | n/a | `list(string)` | `[]` | no |
| iam\_instance\_profile | n/a | `string` | `null` | no |
| instance\_type | n/a | `string` | `"t3.medium"` | no |
| k3s\_disables | k3s services to disable, defaults to traefik, local-storage, and servicelb since we're in the cloud | `list(string)` | <pre>[<br>  "traefik",<br>  "local-storage",<br>  "servicelb"<br>]</pre> | no |
| k3s\_kube\_apiservers | --kube-apiserver-arg key=value | `list(string)` | `[]` | no |
| k3s\_kube\_cloud\_controller\_managers | --kube-cloud-controller-manager-arg key=value | `list(string)` | `[]` | no |
| k3s\_kube\_controller\_managers | --kube-controller-manager-arg key=value | `list(string)` | `[]` | no |
| k3s\_kube\_schedulers | --kube-scheduler-arg key=value | `list(string)` | `[]` | no |
| k3s\_kubelet\_args | --kubelet-arg key=value | `list(string)` | `[]` | no |
| k3s\_node\_labels | --node-label key=value | `list(string)` | `[]` | no |
| k3s\_node\_taints | --node-taint key=value | `list(string)` | `[]` | no |
| k3s\_tls\_sans | n/a | `list(string)` | `[]` | no |
| k3s\_url | n/a | `string` | `""` | no |
| k3s\_version | K3S  Variables | `string` | `"v1.18.8+k3s1"` | no |
| shared\_agent\_security\_group | n/a | `string` | `null` | no |
| shared\_server\_security\_group | n/a | `string` | `null` | no |
| spot | n/a | `bool` | `false` | no |
| ssh\_authorized\_keys | List of public keys that are added to nodes authorized hosts.  This is not required for cluster bootstrap, and should only be allowed for development environments where ssh access is beneficial | `list(string)` | `[]` | no |
| state\_bucket | n/a | `string` | `null` | no |
| state\_key | n/a | `string` | `"state.env"` | no |
| tags | n/a | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| autoscaling\_group\_name | n/a |
| security\_group | n/a |

