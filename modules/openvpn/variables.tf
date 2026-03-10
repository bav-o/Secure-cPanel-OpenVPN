variable "subnet_id" {
  description = "Public subnet ID for the OpenVPN instance"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID for the OpenVPN instance"
  type        = string
}

variable "vpn_client_cidr" {
  description = "CIDR block for VPN clients (e.g., 10.8.0.0/24)"
  type        = string
  default     = "10.8.0.0/24"
}

variable "instance_type" {
  description = "EC2 instance type for OpenVPN server"
  type        = string
  default     = "t3.small"
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
}

variable "private_subnet_cidrs" {
  description = "List of private subnet CIDRs to route through VPN"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
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

variable "s3_backup_bucket" {
  description = "S3 bucket name for PKI backup"
  type        = string
  default     = ""
}

variable "vpc_dns_ip" {
  description = "VPC DNS resolver IP (base of VPC CIDR + 2)"
  type        = string
  default     = "10.0.0.2"
}
