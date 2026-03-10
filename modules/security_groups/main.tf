locals {
  common_tags = merge(var.tags, {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  })
}

# --- OpenVPN Security Group ---

resource "aws_security_group" "openvpn" {
  name        = "${var.project_name}-${var.environment}-openvpn-sg"
  description = "Security group for OpenVPN server"
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-openvpn-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "openvpn_udp" {
  security_group_id = aws_security_group.openvpn.id
  description       = "OpenVPN UDP from anywhere"
  from_port         = 1194
  to_port           = 1194
  ip_protocol       = "udp"
  cidr_ipv4         = "0.0.0.0/0"

  tags = merge(local.common_tags, { Name = "openvpn-udp" })
}

resource "aws_vpc_security_group_ingress_rule" "openvpn_ssh" {
  security_group_id = aws_security_group.openvpn.id
  description       = "SSH from admin IP only"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = var.admin_cidr

  tags = merge(local.common_tags, { Name = "openvpn-ssh" })
}

resource "aws_vpc_security_group_egress_rule" "openvpn_all_out" {
  security_group_id = aws_security_group.openvpn.id
  description       = "Allow all outbound traffic"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"

  tags = merge(local.common_tags, { Name = "openvpn-egress" })
}

# --- cPanel Security Group ---

resource "aws_security_group" "cpanel" {
  name        = "${var.project_name}-${var.environment}-cpanel-sg"
  description = "Security group for cPanel server - VPN access only"
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-cpanel-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "cpanel_whm" {
  security_group_id = aws_security_group.cpanel.id
  description       = "WHM from VPN clients only"
  from_port         = 2087
  to_port           = 2087
  ip_protocol       = "tcp"
  cidr_ipv4         = var.vpn_client_cidr

  tags = merge(local.common_tags, { Name = "cpanel-whm" })
}

resource "aws_vpc_security_group_ingress_rule" "cpanel_cpanel" {
  security_group_id = aws_security_group.cpanel.id
  description       = "cPanel from VPN clients only"
  from_port         = 2083
  to_port           = 2083
  ip_protocol       = "tcp"
  cidr_ipv4         = var.vpn_client_cidr

  tags = merge(local.common_tags, { Name = "cpanel-cpanel" })
}

resource "aws_vpc_security_group_ingress_rule" "cpanel_http" {
  security_group_id = aws_security_group.cpanel.id
  description       = "HTTP from VPN clients only"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = var.vpn_client_cidr

  tags = merge(local.common_tags, { Name = "cpanel-http" })
}

resource "aws_vpc_security_group_ingress_rule" "cpanel_https" {
  security_group_id = aws_security_group.cpanel.id
  description       = "HTTPS from VPN clients only"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = var.vpn_client_cidr

  tags = merge(local.common_tags, { Name = "cpanel-https" })
}

resource "aws_vpc_security_group_ingress_rule" "cpanel_ssh" {
  security_group_id = aws_security_group.cpanel.id
  description       = "SSH from VPN clients only"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = var.vpn_client_cidr

  tags = merge(local.common_tags, { Name = "cpanel-ssh" })
}

resource "aws_vpc_security_group_egress_rule" "cpanel_all_out" {
  security_group_id = aws_security_group.cpanel.id
  description       = "Allow all outbound traffic"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"

  tags = merge(local.common_tags, { Name = "cpanel-egress" })
}
