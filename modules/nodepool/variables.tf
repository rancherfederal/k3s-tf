variable "name" {
  type        = string
  description = "Name of the node pool, to be appended to all resources"
}

variable "cluster" {
  type        = string
  description = "Name of the cluster the nodepool belongs to, sourced from k3s module"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID the nodepool is deployed to"
}

variable "subnets" {
  type        = list(string)
  description = "List of subnet ids the nodepool is deployed to"
}

variable "ami" {
  type        = string
  description = "AMI of all EC2 instances within the nodepool"
}

variable "ssh_authorized_keys" {
  type        = list(string)
  default     = []
  description = "List of public keys that are added to nodes authorized hosts.  This is not required for cluster bootstrap, and should only be allowed for development environments where ssh access is beneficial"
}

variable "auto_deployed_manifests" {
  type = list(object({
    name    = string
    content = string
  }))
  default = []
}

variable "extra_security_groups" {
  type    = list(string)
  default = []
}

variable "instance_type" {
  type    = string
  default = "t3.medium"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "iam_instance_profile" {
  type    = string
  default = null
}

variable "spot" {
  type    = bool
  default = false
}

variable "block_device_mappings" {
  type = object({
    size      = number
    encrypted = bool
  })

  default = {
    size      = 32
    encrypted = true
  }
}

variable "asg" {
  type = object({
    min     = number
    max     = number
    desired = number
  })

  default = {
    min     = 1
    max     = 2
    desired = 1
  }

  description = "Autoscaling group scale, requires min, max, and desired"
}

variable "controlplane_loadbalancer" {
  type    = string
  default = null
}

variable "cluster_security_group" {
  type = string
}

variable "shared_server_security_group" {
  type    = string
  default = null
}

variable "shared_agent_security_group" {
  type    = string
  default = null
}

variable "external_cloud_provider" {
  type        = bool
  default     = true
  description = "Toggle creation of k3s cluster with builtin cloud provider disabled and cloud-provider=external, used in conjuction with deploy_cloud_controller_manager"
}

variable "deploy_cloud_controller_manager" {
  type        = bool
  default     = true
  description = "Toggle deployment of aws cloud controller manager, disable when still requiring --cloud-provider=external but deploying with custom manfiests"
}

variable "enable_ebs_csi_driver" {
  type        = bool
  default     = true
  description = "Toggle deployment of ebs csi driver"
}

variable "state_bucket" {
  type    = string
  default = null
}

variable "state_key" {
  type    = string
  default = "state.env"
}

#
# K3S  Variables
#
variable "k3s_version" {
  type    = string
  default = "v1.18.8+k3s1"
}

variable "k3s_url" {
  type    = string
  default = ""
}

variable "k3s_disables" {
  type        = list(string)
  default     = ["traefik", "local-storage", "servicelb"]
  description = "k3s services to disable, defaults to traefik, local-storage, and servicelb since we're in the cloud"
}

variable "k3s_tls_sans" {
  type    = list(string)
  default = []
}

variable "k3s_kubelet_args" {
  type        = list(string)
  default     = []
  description = "--kubelet-arg key=value"
}

variable "k3s_kube_apiservers" {
  type        = list(string)
  default     = []
  description = "--kube-apiserver-arg key=value"
}

variable "k3s_kube_schedulers" {
  type        = list(string)
  default     = []
  description = "--kube-scheduler-arg key=value"
}

variable "k3s_kube_controller_managers" {
  type        = list(string)
  default     = []
  description = "--kube-controller-manager-arg key=value"
}

variable "k3s_kube_cloud_controller_managers" {
  type        = list(string)
  default     = []
  description = "--kube-cloud-controller-manager-arg key=value"
}

variable "k3s_node_labels" {
  type        = list(string)
  default     = []
  description = "--node-label key=value"
}

variable "k3s_node_taints" {
  type        = list(string)
  default     = []
  description = "--node-taint key=value"
}

variable "k3s_registries" {
  type        = string
  default     = ""
  description = "k3s registries.yaml to define registry configuration, see https://rancher.com/docs/k3s/latest/en/installation/private-registry/"
}

#
# Download urls for dependencies
#   Used for external dependencies that need to be pulled on boot (extremely minimal amount of dependencies)
#
variable "dependencies_script" {
  type        = string
  default     = null
  description = "Dependencies script responsible for any pre-node setup, overriding this overrides the default setup and requires AT LEAST the k3s binary and aws cli downloaded before proceeding"
}