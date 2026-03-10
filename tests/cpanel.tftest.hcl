mock_provider "aws" {}

variables {
  subnet_id            = "subnet-mock456"
  security_group_id    = "sg-mock456"
  instance_type        = "c5.xlarge"
  key_name             = "test-key"
  root_volume_size     = 100
  s3_backup_bucket_arn = "arn:aws:s3:::vcode-test-cpanel-backups"
  project_name         = "vcode"
  environment          = "test"
}

run "cpanel_instance_type" {
  command = plan

  module {
    source = "./modules/cpanel"
  }

  assert {
    condition     = aws_instance.cpanel.instance_type == "c5.xlarge"
    error_message = "Instance type should be c5.xlarge"
  }
}

run "cpanel_root_volume_100gb" {
  command = plan

  module {
    source = "./modules/cpanel"
  }

  assert {
    condition     = aws_instance.cpanel.root_block_device[0].volume_size == 100
    error_message = "Root volume should be 100GB"
  }

  assert {
    condition     = aws_instance.cpanel.root_block_device[0].encrypted == true
    error_message = "Root volume should be encrypted"
  }
}

run "cpanel_has_iam_profile" {
  command = plan

  module {
    source = "./modules/cpanel"
  }

  assert {
    condition     = aws_instance.cpanel.iam_instance_profile == "vcode-test-cpanel-profile"
    error_message = "cPanel should have IAM instance profile"
  }
}

run "cpanel_imdsv2_required" {
  command = plan

  module {
    source = "./modules/cpanel"
  }

  assert {
    condition     = aws_instance.cpanel.metadata_options[0].http_tokens == "required"
    error_message = "IMDSv2 should be required"
  }
}

run "cpanel_s3_policy_scoped" {
  command = plan

  module {
    source = "./modules/cpanel"
  }

  assert {
    condition     = aws_iam_role.cpanel.name == "vcode-test-cpanel-role"
    error_message = "IAM role should have correct name"
  }
}
