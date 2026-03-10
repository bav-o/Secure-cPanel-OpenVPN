variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "admin_cidr" {
  description = "CIDR block allowed to SSH into the OpenVPN server"
  type        = string
}

variable "vpn_client_cidr" {
  description = "CIDR block for VPN clients (e.g., 10.8.0.0/24)"
  type        = string
  default     = "10.8.0.0/24"
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
