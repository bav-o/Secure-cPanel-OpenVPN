output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "openvpn_public_ip" {
  description = "OpenVPN server public IP"
  value       = module.openvpn.public_ip
}

output "cpanel_private_ip" {
  description = "cPanel server private IP"
  value       = module.cpanel.private_ip
}

output "s3_backup_bucket" {
  description = "S3 backup bucket name"
  value       = module.s3_backup.bucket_name
}

output "vpn_fqdn" {
  description = "VPN DNS name"
  value       = module.route53.vpn_fqdn
}

output "cpanel_fqdn" {
  description = "cPanel DNS name"
  value       = module.route53.cpanel_fqdn
}

output "sns_topic_arn" {
  description = "SNS alerts topic ARN"
  value       = module.monitoring.sns_topic_arn
}
