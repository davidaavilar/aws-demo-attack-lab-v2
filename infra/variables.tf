resource "random_string" "unique_id" {
  length    = 5
  min_lower = 5
  special   = false
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "deployment_name" {
  default = "davila-eks"
}