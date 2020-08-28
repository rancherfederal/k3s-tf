variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "internal" {
  type    = bool
  default = true
}

variable "port" {
  type    = number
  default = 6443
}

variable "healthy_threshold" {
  type        = number
  default     = 2
  description = "Number of consecutive health checks successes required before considering a healthy target, must be identical to unhealthy_threshold"
}

variable "unhealthy_threshold" {
  type        = number
  default     = 2
  description = "Number of consecutive health checks successes required before considering a healthy target, must be identical to healthy_threshold"
}

variable "interval" {
  type    = number
  default = 10
}

variable "timeout" {
  type    = number
  default = 10
}

variable "tags" {
  type    = map(string)
  default = {}
}