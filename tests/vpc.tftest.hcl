mock_provider "aws" {}

variables {
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b"]
  vpn_client_cidr    = "10.8.0.0/24"
  project_name       = "vcode"
  environment        = "test"
}

run "vpc_creates_expected_resources" {
  command = plan

  module {
    source = "./modules/vpc"
  }

  assert {
    condition     = aws_vpc.this.cidr_block == "10.0.0.0/16"
    error_message = "VPC CIDR block should be 10.0.0.0/16"
  }

  assert {
    condition     = aws_vpc.this.enable_dns_support == true
    error_message = "DNS support should be enabled"
  }

  assert {
    condition     = aws_vpc.this.enable_dns_hostnames == true
    error_message = "DNS hostnames should be enabled"
  }
}

run "vpc_creates_public_subnets" {
  command = plan

  module {
    source = "./modules/vpc"
  }

  assert {
    condition     = length(aws_subnet.public) == 2
    error_message = "Should create 2 public subnets"
  }
}

run "vpc_creates_private_subnets" {
  command = plan

  module {
    source = "./modules/vpc"
  }

  assert {
    condition     = length(aws_subnet.private) == 2
    error_message = "Should create 2 private subnets"
  }
}

run "vpc_has_flow_logs" {
  command = plan

  module {
    source = "./modules/vpc"
  }

  assert {
    condition     = aws_flow_log.this.traffic_type == "ALL"
    error_message = "VPC Flow Logs should capture ALL traffic"
  }

  assert {
    condition     = aws_flow_log.this.log_destination_type == "cloud-watch-logs"
    error_message = "Flow logs should go to CloudWatch"
  }
}

run "vpc_has_s3_endpoint" {
  command = plan

  module {
    source = "./modules/vpc"
  }

  assert {
    condition     = length(aws_vpc_endpoint.s3.route_table_ids) == 2
    error_message = "S3 endpoint should be associated with both route tables"
  }
}

run "vpc_has_nacls" {
  command = plan

  module {
    source = "./modules/vpc"
  }

  assert {
    condition     = length(aws_network_acl.public.subnet_ids) == 2
    error_message = "Public NACL should cover 2 subnets"
  }

  assert {
    condition     = length(aws_network_acl.private.subnet_ids) == 2
    error_message = "Private NACL should cover 2 subnets"
  }
}

run "vpc_tags_are_correct" {
  command = plan

  module {
    source = "./modules/vpc"
  }

  assert {
    condition     = aws_vpc.this.tags["Project"] == "vcode"
    error_message = "VPC should have correct Project tag"
  }

  assert {
    condition     = aws_vpc.this.tags["Environment"] == "test"
    error_message = "VPC should have correct Environment tag"
  }
}