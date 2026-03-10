terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Configure via: terraform init \
  #   -backend-config="bucket=<state-bucket>" \
  #   -backend-config="key=vcode/dev/terraform.tfstate" \
  #   -backend-config="region=us-east-1" \
  #   -backend-config="dynamodb_table=<lock-table>" \
  #   -backend-config="encrypt=true"
  backend "s3" {}
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
    }
  }
}
