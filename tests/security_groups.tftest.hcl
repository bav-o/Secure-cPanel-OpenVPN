mock_provider "aws" {}

variables {
  vpc_id          = "vpc-mock123"
  admin_cidr      = "203.0.113.10/32"
  vpn_client_cidr = "10.8.0.0/24"
  project_name    = "vcode"
  environment     = "test"
}

run "openvpn_sg_allows_udp_1194" {
  command = plan

  module {
    source = "./modules/security_groups"
  }

  assert {
    condition     = aws_vpc_security_group_ingress_rule.openvpn_udp.from_port == 1194
    error_message = "OpenVPN SG should allow UDP 1194"
  }

  assert {
    condition     = aws_vpc_security_group_ingress_rule.openvpn_udp.ip_protocol == "udp"
    error_message = "OpenVPN rule should be UDP protocol"
  }

  assert {
    condition     = aws_vpc_security_group_ingress_rule.openvpn_udp.cidr_ipv4 == "0.0.0.0/0"
    error_message = "OpenVPN UDP should be open to all"
  }
}

run "openvpn_ssh_restricted_to_admin" {
  command = plan

  module {
    source = "./modules/security_groups"
  }

  assert {
    condition     = aws_vpc_security_group_ingress_rule.openvpn_ssh.cidr_ipv4 == "203.0.113.10/32"
    error_message = "SSH should be restricted to admin CIDR"
  }

  assert {
    condition     = aws_vpc_security_group_ingress_rule.openvpn_ssh.from_port == 22
    error_message = "SSH port should be 22"
  }
}

run "cpanel_whm_restricted_to_vpn" {
  command = plan

  module {
    source = "./modules/security_groups"
  }

  assert {
    condition     = aws_vpc_security_group_ingress_rule.cpanel_whm.cidr_ipv4 == "10.8.0.0/24"
    error_message = "WHM should be restricted to VPN CIDR"
  }

  assert {
    condition     = aws_vpc_security_group_ingress_rule.cpanel_whm.from_port == 2087
    error_message = "WHM port should be 2087"
  }
}

run "cpanel_all_ports_vpn_only" {
  command = plan

  module {
    source = "./modules/security_groups"
  }

  assert {
    condition     = aws_vpc_security_group_ingress_rule.cpanel_cpanel.cidr_ipv4 == "10.8.0.0/24"
    error_message = "cPanel port should be VPN-only"
  }

  assert {
    condition     = aws_vpc_security_group_ingress_rule.cpanel_http.cidr_ipv4 == "10.8.0.0/24"
    error_message = "HTTP should be VPN-only"
  }

  assert {
    condition     = aws_vpc_security_group_ingress_rule.cpanel_https.cidr_ipv4 == "10.8.0.0/24"
    error_message = "HTTPS should be VPN-only"
  }

  assert {
    condition     = aws_vpc_security_group_ingress_rule.cpanel_ssh.cidr_ipv4 == "10.8.0.0/24"
    error_message = "SSH should be VPN-only"
  }
}
