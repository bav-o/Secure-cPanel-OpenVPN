variable "subnet_id" {
  description = "Private subnet ID for the cPanel instance"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID for the cPanel instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for cPanel server"
  type        = string
  default     = "c5.xlarge"
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
}

variable "root_volume_size" {
  description = "Size of root EBS volume in GB"
  type        = number
  default     = 100
}

variable "root_volume_iops" {
  description = "Provisioned IOPS for gp3 root volume"
  type        = number
  default     = 3000
}

variable "root_volume_throughput" {
  description = "Provisioned throughput (MiB/s) for gp3 root volume"
  type        = number
  default     = 125
}

variable "hostname" {
  description = "Hostname for the cPanel server (used for cPanel license)"
  type        = string
}

variable "s3_backup_bucket_arn" {
  description = "ARN of the S3 bucket for cPanel backups"
  type        = string
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
