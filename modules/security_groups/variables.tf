variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "admin_cidr" {
  description = "CIDR block allowed to SSH into the OpenVPN server (must not be 0.0.0.0/0)"
  type        = string

  validation {
    condition     = var.admin_cidr != "0.0.0.0/0"
    error_message = "admin_cidr must not be 0.0.0.0/0 — set it to your specific admin IP (e.g., 203.0.113.10/32)."
  }
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
