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

variable "disk_threshold" {
  description = "Disk utilization threshold percentage"
  type        = number
  default     = 85
}

variable "memory_threshold" {
  description = "Memory utilization threshold percentage"
  type        = number
  default     = 85
}

variable "disk_monitor_instance_ids" {
  description = "Map of instance name to instance ID for disk/memory monitoring (requires CloudWatch Agent)"
  type        = map(string)
  default     = {}
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
