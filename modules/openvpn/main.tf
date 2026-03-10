locals {
  common_tags = merge(var.tags, {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  })
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# --- IAM Role for S3 PKI Backup ---

resource "aws_iam_role" "openvpn" {
  count = var.s3_backup_bucket != "" ? 1 : 0
  name  = "${var.project_name}-${var.environment}-openvpn-role"

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

resource "aws_iam_role_policy" "openvpn_s3" {
  count = var.s3_backup_bucket != "" ? 1 : 0
  name  = "${var.project_name}-${var.environment}-openvpn-s3-policy"
  role  = aws_iam_role.openvpn[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:PutObject",
        "s3:GetObject",
      ]
      Resource = "arn:aws:s3:::${var.s3_backup_bucket}/openvpn-pki/*"
    }]
  })
}

resource "aws_iam_instance_profile" "openvpn" {
  count = var.s3_backup_bucket != "" ? 1 : 0
  name  = "${var.project_name}-${var.environment}-openvpn-profile"
  role  = aws_iam_role.openvpn[0].name

  tags = local.common_tags
}

resource "aws_instance" "openvpn" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.key_name
  source_dest_check      = false
  iam_instance_profile   = var.s3_backup_bucket != "" ? aws_iam_instance_profile.openvpn[0].name : null

  user_data = templatefile("${path.module}/userdata.sh", {
    vpn_client_cidr      = var.vpn_client_cidr
    private_subnet_cidrs = join(" ", var.private_subnet_cidrs)
    s3_backup_bucket     = var.s3_backup_bucket
    vpc_dns_ip           = var.vpc_dns_ip
  })

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-openvpn"
  })
}

resource "aws_eip" "openvpn" {
  instance = aws_instance.openvpn.id
  domain   = "vpc"

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-openvpn-eip"
  })
}
