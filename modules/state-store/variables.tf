variable "name" {
  type = string
}

variable "key" {
  type        = string
  default     = "state.json"
  description = "Key in S3 bucket to store cluster state data as json"
}

variable "tags" {
  type    = map(string)
  default = {}
}