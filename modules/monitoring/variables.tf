variable "instance_ids" {
  description = "Map of instance name to instance ID for monitoring"
  type        = map(string)
}

variable "alert_emails" {
  description = "List of email addresses for alarm notifications"
  type        = list(string)
}

variable "cpu_threshold" {
  description = "CPU utilization threshold percentage"
  type        = number
  default     = 80
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, prod)"
  type        = string
}

variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
}
