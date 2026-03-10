# Secure cPanel & OpenVPN on AWS

Production-grade Terraform project for WHM/cPanel with VPN-only admin access on AWS.

## Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│  VPC (10.0.0.0/16)  [Flow Logs → CloudWatch]                    │
│                                                                  │
│  ┌────────────────────────┐    ┌──────────────────────────────┐  │
│  │  Public Subnet (NACL)   │    │  Private Subnet (NACL)       │  │
│  │                         │    │                              │  │
│  │  ┌───────────────────┐  │    │  ┌────────────────────────┐  │  │
│  │  │  OpenVPN Server    │──────│──│  cPanel/WHM Server     │  │  │
│  │  │  (t3.small)        │  │    │  │  (c5.xlarge)           │  │  │
│  │  │  EIP + UDP 1194    │  │    │  │  AlmaLinux 8           │  │  │
│  │  │  Split tunnel VPN  │  │    │  │  HTTP/HTTPS: public    │  │  │
│  │  └───────────────────┘  │    │  │  WHM/SSH: VPN-only      │  │  │
│  │         │                │    │  └────────────────────────┘  │  │
│  └─────────│────────────────┘    └──────────│─────────────────┘  │
│             │                                │                    │
│         IGW ▼                            NAT GW ▼                │
│                      S3 Gateway Endpoint                         │
└──────────────────────────────────────────────────────────────────┘
         │                              │
  VPN Clients (10.8.0.0/24)    Public Web Traffic (80/443)
```

**Key security principle:** cPanel admin interfaces (WHM:2087, cPanel:2083, SSH:22) are reachable ONLY through OpenVPN. Web hosting traffic (HTTP/HTTPS) is publicly accessible for hosted websites.

## Project Structure

```
vcode/
├── modules/
│   ├── vpc/               # VPC, subnets, IGW, NAT GW, NACLs, Flow Logs, S3 Endpoint
│   ├── security_groups/   # SGs for OpenVPN and cPanel (admin VPN-only, web public)
│   ├── openvpn/           # OpenVPN EC2 with split tunnel, PKI backup to S3
│   ├── cpanel/            # cPanel EC2 with parametrized hostname, gp3 IOPS tuning
│   ├── s3_backup/         # Encrypted S3 bucket with lifecycle + SSL-only policy
│   ├── route53/           # DNS records
│   └── monitoring/        # CloudWatch alarms (CPU, status, disk, memory) + SNS
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
- S3 bucket + DynamoDB table for Terraform state locking

## Quick Start

```bash
# 1. Configure your environment
cd environments/dev
cp terraform.tfvars terraform.tfvars.local
# Edit terraform.tfvars.local with your values:
#   - admin_cidr: your IP/32 (validation rejects 0.0.0.0/0)
#   - key_name: your EC2 key pair
#   - domain_name: your domain
#   - alert_emails: your email

# 2. Initialize with state locking
terraform init \
  -backend-config="bucket=your-state-bucket" \
  -backend-config="key=vcode/dev/terraform.tfstate" \
  -backend-config="region=us-east-1" \
  -backend-config="dynamodb_table=your-lock-table" \
  -backend-config="encrypt=true"

# 3. Plan and apply
terraform plan -var-file=terraform.tfvars.local
terraform apply -var-file=terraform.tfvars.local
```

## Security Design

| Decision | Detail |
|----------|--------|
| cPanel admin VPN-only | WHM (2087), cPanel (2083), SSH (22) restricted to VPN CIDR |
| Web traffic public | HTTP (80), HTTPS (443) open for hosted websites |
| admin_cidr validation | Terraform rejects `0.0.0.0/0` — must be a specific IP |
| VPN return route | Private route table routes VPN CIDR → OpenVPN ENI |
| Split tunnel VPN | Only private subnet traffic routed through VPN (not all traffic) |
| VPC DNS for VPN clients | VPN pushes VPC resolver (10.0.0.2) for private DNS resolution |
| PKI backup to S3 | OpenVPN certificates backed up to S3 on initial setup |
| VPC Flow Logs | All traffic logged to CloudWatch for audit/troubleshooting |
| Network ACLs | Defense-in-depth on public and private subnets |
| S3 VPC Endpoint | Direct S3 access without NAT Gateway (free, faster) |
| S3 SSL-only policy | Bucket policy denies non-HTTPS requests |
| State locking | DynamoDB table prevents concurrent Terraform operations |
| IMDSv2 required | Both instances enforce Instance Metadata Service v2 |
| Encrypted volumes | EBS gp3 with configurable IOPS/throughput, encrypted at rest |
| S3 KMS encryption | Server-side encryption with AWS managed KMS key |

## Modules

| Module | Purpose | Key Variables |
|--------|---------|---------------|
| `vpc` | VPC, subnets, IGW, NAT GW, NACLs, Flow Logs, S3 Endpoint | `vpc_cidr`, `availability_zones`, `vpn_client_cidr` |
| `security_groups` | OpenVPN SG + cPanel SG (admin VPN-only, web public) | `admin_cidr`, `vpn_client_cidr` |
| `openvpn` | EC2, EIP, split tunnel, PKI backup | `instance_type`, `s3_backup_bucket`, `vpc_dns_ip` |
| `cpanel` | EC2, IAM role, parametrized hostname, gp3 tuning | `hostname`, `root_volume_iops`, `root_volume_throughput` |
| `s3_backup` | Versioned, encrypted bucket with SSL-only policy | `project_name`, `environment` |
| `route53` | Hosted zone + A records | `domain_name`, `vpn_public_ip` |
| `monitoring` | CPU, status, disk, memory alarms + SNS | `instance_ids`, `disk_monitor_instance_ids` |

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
4. **Install CloudWatch Agent**: On cPanel instance for disk/memory monitoring alarms
5. **Confirm alerts**: Check email for SNS subscription confirmation

## Environments

| | Dev | Prod |
|---|-----|------|
| cPanel instance | c5.large | c5.xlarge |
| OpenVPN instance | t3.small | t3.small |
| Root volume | 100 GB, gp3 (3000 IOPS) | 100 GB, gp3 (3000 IOPS) |