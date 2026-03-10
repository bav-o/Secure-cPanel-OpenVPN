output "openvpn_security_group_id" {
  description = "ID of the OpenVPN security group"
  value       = aws_security_group.openvpn.id
}

output "cpanel_security_group_id" {
  description = "ID of the cPanel security group"
  value       = aws_security_group.cpanel.id
}

output "openvpn_security_group_name" {
  description = "Name of the OpenVPN security group"
  value       = aws_security_group.openvpn.name
}

output "cpanel_security_group_name" {
  description = "Name of the cPanel security group"
  value       = aws_security_group.cpanel.name
}
