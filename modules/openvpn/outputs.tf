output "instance_id" {
  description = "ID of the OpenVPN EC2 instance"
  value       = aws_instance.openvpn.id
}

output "public_ip" {
  description = "Elastic IP address of the OpenVPN server"
  value       = aws_eip.openvpn.public_ip
}

output "private_ip" {
  description = "Private IP address of the OpenVPN server"
  value       = aws_instance.openvpn.private_ip
}

output "network_interface_id" {
  description = "Primary network interface ID of the OpenVPN instance"
  value       = aws_instance.openvpn.primary_network_interface_id
}
