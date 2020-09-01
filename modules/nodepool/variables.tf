variable "name" {
  type = string
}

variable "cluster" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "ami" {
  type = string
}

variable "ssh_authorized_keys" {
  type    = list(string)
  default = []
}

variable "auto_deployed_manifests" {
  type    = list(string)
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

variable "pre_userdata" {
  type        = string
  default     = null
  description = "base64 encoded custom userdata pre k3s boot"
}

variable "post_userdata" {
  type        = string
  default     = null
  description = "base64 encoded custom userdata post k3s boot"
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

variable "enable_cloud_provider" {
  type    = bool
  default = true
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

#
# Download urls for dependencies
#   Used for external dependencies that need to be pulled on boot (extremely minimal amount of dependencies)
#
variable "k3s_download_url" {
  type    = string
  default = "https://github.com/rancher/k3s/releases/download"
}

variable "rancher_rpm_repo_baseurl" {
  type    = string
  default = "https://rpm.rancher.io"
}

variable "aws_download_url" {
  type    = string
  default = "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
}