variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "vcode"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
}

variable "admin_cidr" {
  description = "Admin IP CIDR for SSH access to VPN server"
  type        = string
}

variable "vpn_client_cidr" {
  description = "VPN client CIDR"
  type        = string
  default     = "10.8.0.0/24"
}

variable "key_name" {
  description = "EC2 SSH key pair name"
  type        = string
}

variable "domain_name" {
  description = "Domain name for Route 53"
  type        = string
}

variable "alert_emails" {
  description = "Email addresses for alerts"
  type        = list(string)
  default     = []
}

variable "openvpn_instance_type" {
  description = "Instance type for OpenVPN server"
  type        = string
  default     = "t3.small"
}

variable "cpanel_instance_type" {
  description = "Instance type for cPanel server"
  type        = string
  default     = "c5.xlarge"
}

variable "cpanel_root_volume_size" {
  description = "Root volume size for cPanel in GB"
  type        = number
  default     = 100
}
