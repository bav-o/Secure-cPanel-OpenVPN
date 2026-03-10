mock_provider "aws" {}

# Integration test: verify the security model holds across modules.
# cPanel SG only allows VPN CIDR, OpenVPN has source_dest_check=false.

variables {
  # VPC
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b"]
  project_name       = "vcode"
  environment        = "test"
}

run "vpc_foundation" {
  command = plan

  module {
    source = "./modules/vpc"
  }

  assert {
    condition     = aws_vpc.this.cidr_block == "10.0.0.0/16"
    error_message = "VPC CIDR must be set correctly"
  }

  assert {
    condition     = length(aws_subnet.public) == 2
    error_message = "Must have 2 public subnets"
  }

  assert {
    condition     = length(aws_subnet.private) == 2
    error_message = "Must have 2 private subnets"
  }
}

run "security_groups_vpn_only_access" {
  command = plan

  variables {
    vpc_id          = "vpc-integration"
    admin_cidr      = "198.51.100.0/32"
    vpn_client_cidr = "10.8.0.0/24"
  }

  module {
    source = "./modules/security_groups"
  }

  # Verify no cPanel ingress rule allows 0.0.0.0/0
  assert {
    condition     = aws_vpc_security_group_ingress_rule.cpanel_whm.cidr_ipv4 != "0.0.0.0/0"
    error_message = "cPanel WHM must NOT be open to the internet"
  }

  assert {
    condition     = aws_vpc_security_group_ingress_rule.cpanel_ssh.cidr_ipv4 != "0.0.0.0/0"
    error_message = "cPanel SSH must NOT be open to the internet"
  }

  assert {
    condition     = aws_vpc_security_group_ingress_rule.cpanel_http.cidr_ipv4 != "0.0.0.0/0"
    error_message = "cPanel HTTP must NOT be open to the internet"
  }

  assert {
    condition     = aws_vpc_security_group_ingress_rule.cpanel_https.cidr_ipv4 != "0.0.0.0/0"
    error_message = "cPanel HTTPS must NOT be open to the internet"
  }

  # Verify OpenVPN SSH is restricted
  assert {
    condition     = aws_vpc_security_group_ingress_rule.openvpn_ssh.cidr_ipv4 == "198.51.100.0/32"
    error_message = "OpenVPN SSH must be restricted to admin CIDR"
  }
}

run "s3_backup_security" {
  command = plan

  module {
    source = "./modules/s3_backup"
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.backups.block_public_acls == true
    error_message = "S3 backups must block public access"
  }

  assert {
    condition     = aws_s3_bucket_versioning.backups.versioning_configuration[0].status == "Enabled"
    error_message = "S3 backups must have versioning enabled"
  }
}
