mock_provider "aws" {}

variables {
  subnet_id         = "subnet-mock123"
  security_group_id = "sg-mock123"
  vpn_client_cidr   = "10.8.0.0/24"
  instance_type     = "t3.small"
  key_name          = "test-key"
  project_name      = "vcode"
  environment       = "test"
}

run "openvpn_source_dest_check_disabled" {
  command = plan

  module {
    source = "./modules/openvpn"
  }

  assert {
    condition     = aws_instance.openvpn.source_dest_check == false
    error_message = "source_dest_check must be false for VPN routing"
  }
}

run "openvpn_instance_type" {
  command = plan

  module {
    source = "./modules/openvpn"
  }

  assert {
    condition     = aws_instance.openvpn.instance_type == "t3.small"
    error_message = "Instance type should be t3.small"
  }
}

run "openvpn_has_eip" {
  command = plan

  module {
    source = "./modules/openvpn"
  }

  assert {
    condition     = aws_eip.openvpn.domain == "vpc"
    error_message = "OpenVPN should have a VPC EIP"
  }
}

run "openvpn_imdsv2_required" {
  command = plan

  module {
    source = "./modules/openvpn"
  }

  assert {
    condition     = aws_instance.openvpn.metadata_options[0].http_tokens == "required"
    error_message = "IMDSv2 should be required"
  }
}

run "openvpn_root_volume_encrypted" {
  command = plan

  module {
    source = "./modules/openvpn"
  }

  assert {
    condition     = aws_instance.openvpn.root_block_device[0].encrypted == true
    error_message = "Root volume should be encrypted"
  }
}
