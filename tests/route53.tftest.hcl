mock_provider "aws" {}

variables {
  domain_name       = "test.example.com"
  vpn_public_ip     = "1.2.3.4"
  cpanel_private_ip = "10.0.101.10"
  create_zone       = true
}

run "route53_creates_zone" {
  command = plan

  module {
    source = "./modules/route53"
  }

  assert {
    condition     = length(aws_route53_zone.this) == 1
    error_message = "Should create hosted zone when create_zone is true"
  }

  assert {
    condition     = aws_route53_zone.this[0].name == "test.example.com"
    error_message = "Zone name should match domain_name"
  }
}

run "route53_vpn_record" {
  command = plan

  module {
    source = "./modules/route53"
  }

  assert {
    condition     = aws_route53_record.vpn.name == "vpn.test.example.com"
    error_message = "VPN record should be vpn.domain"
  }

  assert {
    condition     = aws_route53_record.vpn.type == "A"
    error_message = "VPN record should be type A"
  }

  assert {
    condition     = contains(aws_route53_record.vpn.records, "1.2.3.4")
    error_message = "VPN record should point to VPN public IP"
  }
}

run "route53_cpanel_record" {
  command = plan

  module {
    source = "./modules/route53"
  }

  assert {
    condition     = aws_route53_record.cpanel.name == "cpanel.test.example.com"
    error_message = "cPanel record should be cpanel.domain"
  }

  assert {
    condition     = contains(aws_route53_record.cpanel.records, "10.0.101.10")
    error_message = "cPanel record should point to private IP"
  }
}

run "route53_skip_zone_creation" {
  command = plan

  variables {
    create_zone = false
    zone_id     = "Z1234567890"
  }

  module {
    source = "./modules/route53"
  }

  assert {
    condition     = length(aws_route53_zone.this) == 0
    error_message = "Should not create zone when create_zone is false"
  }
}
