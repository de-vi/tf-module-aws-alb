variable "sg_ids" {}
variable "name" {}
variable "access_log_bucket" {}
variable "ssl_cert_arn" {}

variable "subnet_ids" {
  description = "A list of subnet ids"
  type        = list(string)
}

variable "tags" {
  description = "A list of tags"
  type        = map(string)
  default     = {}
}

variable "target_groups" {
  description = "A list of target group maps"
  type        = list(map(string))
  default     = []
  validation {
    condition     = length(var.target_groups) > 0
    error_message = "At least one target_group must be provided."
  }
}

variable "target_group_health_checks" {
  description = "A list of target group health check"
  type        = list(map(string))
  default     = []
}

variable "vpc_id" {
  description = "VPC id"
  type        = string
}
