variable "domain_name" {
  description = "Domain name for the hosted zone"
  type        = string
}

variable "create_zone" {
  description = "Whether to create the hosted zone (false to use existing)"
  type        = bool
  default     = true
}

variable "zone_id" {
  description = "Existing hosted zone ID (required if create_zone is false)"
  type        = string
  default     = ""
}

variable "vpn_public_ip" {
  description = "Public IP of the OpenVPN server"
  type        = string
}

variable "cpanel_private_ip" {
  description = "Private IP of the cPanel server"
  type        = string
}

variable "ttl" {
  description = "TTL for DNS records"
  type        = number
  default     = 300
}

variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
}
