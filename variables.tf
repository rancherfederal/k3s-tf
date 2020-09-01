variable "name" {
  type        = string
  description = "Name of the cluster, will be prepended to cluster resources"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID of the cluster"
}

variable "subnets" {
  type        = list(string)
  description = "List of subnet ids of the shared cluster resources such as load balancers and RDS.  Generally set to private subnets"
}

variable "state_bucket" {
  type        = string
  default     = null
  description = "Name of existing S3 bucket to store cluster state/secrets in, will create bucket if left blank"
}

variable "rds_ca_cert_identifier" {
  type        = string
  default     = "rds-ca-2017"
  description = "RDS CA Certificate Identifier"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Common tags to attach to all created resources"
}