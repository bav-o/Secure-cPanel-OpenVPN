output "instance_id" {
  description = "ID of the cPanel EC2 instance"
  value       = aws_instance.cpanel.id
}

output "private_ip" {
  description = "Private IP address of the cPanel server"
  value       = aws_instance.cpanel.private_ip
}

output "iam_role_arn" {
  description = "ARN of the cPanel IAM role"
  value       = aws_iam_role.cpanel.arn
}

output "iam_instance_profile_name" {
  description = "Name of the cPanel IAM instance profile"
  value       = aws_iam_instance_profile.cpanel.name
}
