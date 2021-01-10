variable "sg_ids" {}
variable "listeners" {
  description = "A list of ALB listeners"
  type        = list(map(string))
  default     = []
}

variable "listeners_count" {
  description = "Number of listeners in the listeners variable"
  type        = number
  default     = 0
}

variable "name" {}

variable "subnet_ids" {
  description = "A list of subnet ids"
  type        = list(string)
}

variable "tags" {
  description = "A list of tags"
  type        = (map(string))
  default     = {}
}

variable "target_groups" {
  description = "A list of target group maps"
  type        = list(map(string))
  default     = []
}

variable "target_groups_count" {
  description = "Number of target groups"
  type        = number
  default     = 0
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
