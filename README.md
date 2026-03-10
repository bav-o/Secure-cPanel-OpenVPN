# Secure cPanel & OpenVPN on AWS

Production-grade Terraform project for WHM/cPanel with VPN-only admin access on AWS.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│  VPC (10.0.0.0/16)                                          │
│                                                             │
│  ┌──────────────────────┐    ┌───────────────────────────┐  │
│  │  Public Subnet        │    │  Private Subnet            │  │
│  │                       │    │                            │  │
│  │  ┌─────────────────┐  │    │  ┌──────────────────────┐  │  │
│  │  │  OpenVPN Server  │──────│──│  cPanel/WHM Server   │  │  │
│  │  │  (t3.small)      │  │    │  │  (c5.xlarge)         │  │  │
│  │  │  EIP + UDP 1194  │  │    │  │  AlmaLinux 8         │  │  │
│  │  └─────────────────┘  │    │  │  No public IP         │  │  │
│  │         │              │    │  └──────────────────────┘  │  │
│  └─────────│──────────────┘    └───────────│───────────────┘  │
│             │                               │                 │
│         IGW ▼                           NAT GW ▼              │
└─────────────────────────────────────────────────────────────┘
                    │
        VPN Clients (10.8.0.0/24)
```

**Key security principle:** cPanel/WHM is in a private subnet, reachable ONLY through OpenVPN.

## Project Structure

```
vcode/
├── modules/
│   ├── vpc/               # VPC, subnets, IGW, NAT GW, route tables
│   ├── security_groups/   # SGs for OpenVPN and cPanel
│   ├── openvpn/           # OpenVPN EC2 in public subnet
│   ├── cpanel/            # cPanel EC2 in private subnet
│   ├── s3_backup/         # Encrypted S3 bucket with lifecycle
│   ├── route53/           # DNS records
│   └── monitoring/        # CloudWatch alarms + SNS
├── environments/
│   ├── dev/               # c5.large cPanel
│   └── prod/              # c5.xlarge cPanel
├── tests/                 # Native Terraform tests
└── README.md
```

## Prerequisites

- Terraform >= 1.6.0
- AWS CLI configured with appropriate credentials
- An EC2 key pair in your target region
- A domain name (for Route 53 records)

## Quick Start

```bash
# 1. Configure your environment
cd environments/dev
cp terraform.tfvars terraform.tfvars.local
# Edit terraform.tfvars.local with your values:
#   - admin_cidr: your IP/32
#   - key_name: your EC2 key pair
#   - domain_name: your domain
#   - alert_emails: your email

# 2. Initialize
terraform init \
  -backend-config="bucket=your-state-bucket" \
  -backend-config="key=vcode/dev/terraform.tfstate" \
  -backend-config="region=us-east-1"

# 3. Plan and apply
terraform plan -var-file=terraform.tfvars.local
terraform apply -var-file=terraform.tfvars.local
```

## Security Design

| Decision | Detail |
|----------|--------|
| cPanel in private subnet | No public IP, SG allows traffic only from VPN CIDR (10.8.0.0/24) |
| SSH to OpenVPN restricted | `admin_cidr` variable — set to your IP, not 0.0.0.0/0 |
| NAT Gateway | Private subnet outbound for cPanel license, updates, installer |
| `source_dest_check = false` | Required on VPN instance for routing VPN traffic |
| IAM instance profile | S3 access without static credentials on cPanel server |
| IMDSv2 required | Both instances enforce Instance Metadata Service v2 |
| Encrypted volumes | EBS volumes encrypted at rest on all instances |
| S3 public access blocked | All four public access block settings enabled |
| S3 KMS encryption | Server-side encryption with AWS KMS |

## Modules

| Module | Purpose | Key Variables |
|--------|---------|---------------|
| `vpc` | VPC, 2 AZ subnets, IGW, NAT GW | `vpc_cidr`, `availability_zones` |
| `security_groups` | OpenVPN SG + cPanel SG | `admin_cidr`, `vpn_client_cidr` |
| `openvpn` | EC2, EIP, userdata | `instance_type`, `key_name` |
| `cpanel` | EC2, IAM role, userdata | `instance_type`, `s3_backup_bucket_arn` |
| `s3_backup` | Versioned, encrypted bucket | `project_name`, `environment` |
| `route53` | Hosted zone + A records | `domain_name`, `vpn_public_ip` |
| `monitoring` | CloudWatch alarms, SNS | `instance_ids`, `alert_emails` |

## Testing

```bash
# Format check
terraform fmt -recursive -check

# Validate
cd environments/dev && terraform validate

# Run native tests (plan-mode, no real resources)
cd ../.. && terraform test
```

## Post-Deployment

1. **Connect to VPN**: SSH into the OpenVPN server, retrieve client config from `/etc/openvpn/easy-rsa/pki/`
2. **Access WHM**: Connect via VPN, then browse to `https://cpanel.yourdomain.com:2087`
3. **Configure backups**: In WHM, set up S3 backups using the IAM role (no credentials needed)
4. **Confirm alerts**: Check email for SNS subscription confirmation

## Environments

| | Dev | Prod |
|---|-----|------|
| cPanel instance | c5.large | c5.xlarge |
| OpenVPN instance | t3.small | t3.small |
| Root volume | 100 GB | 100 GB |
