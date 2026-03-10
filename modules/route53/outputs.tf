output "zone_id" {
  description = "ID of the Route 53 hosted zone"
  value       = local.zone_id
}

output "vpn_fqdn" {
  description = "FQDN for the VPN server"
  value       = aws_route53_record.vpn.fqdn
}

output "cpanel_fqdn" {
  description = "FQDN for the cPanel server"
  value       = aws_route53_record.cpanel.fqdn
}

output "name_servers" {
  description = "Name servers for the hosted zone (only if zone was created)"
  value       = var.create_zone ? aws_route53_zone.this[0].name_servers : []
}
