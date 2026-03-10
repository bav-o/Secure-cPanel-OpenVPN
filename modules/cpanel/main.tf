locals {
  common_tags = merge(var.tags, {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  })
}

# --- AMI: AlmaLinux 8 ---

data "aws_ami" "almalinux8" {
  most_recent = true
  owners      = ["679593333241"] # AlmaLinux official

  filter {
    name   = "name"
    values = ["AlmaLinux OS 8*x86_64*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# --- IAM Role for S3 Access ---

resource "aws_iam_role" "cpanel" {
  name = "${var.project_name}-${var.environment}-cpanel-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy" "cpanel_s3" {
  name = "${var.project_name}-${var.environment}-cpanel-s3-policy"
  role = aws_iam_role.cpanel.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:PutObject",
        "s3:GetObject",
        "s3:ListBucket",
        "s3:DeleteObject",
      ]
      Resource = [
        var.s3_backup_bucket_arn,
        "${var.s3_backup_bucket_arn}/*",
      ]
    }]
  })
}

resource "aws_iam_instance_profile" "cpanel" {
  name = "${var.project_name}-${var.environment}-cpanel-profile"
  role = aws_iam_role.cpanel.name

  tags = local.common_tags
}

# --- EC2 Instance ---

resource "aws_instance" "cpanel" {
  ami                    = data.aws_ami.almalinux8.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.key_name
  iam_instance_profile   = aws_iam_instance_profile.cpanel.name

  user_data = file("${path.module}/userdata.sh")

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
    encrypted   = true
  }

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-cpanel"
  })
}
