# --- VPC ---

module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  vpn_client_cidr    = var.vpn_client_cidr
  project_name       = var.project_name
  environment        = var.environment
}

# --- Security Groups ---

module "security_groups" {
  source = "../../modules/security_groups"

  vpc_id          = module.vpc.vpc_id
  admin_cidr      = var.admin_cidr
  vpn_client_cidr = var.vpn_client_cidr
  project_name    = var.project_name
  environment     = var.environment
}

# --- S3 Backup ---

module "s3_backup" {
  source = "../../modules/s3_backup"

  project_name = var.project_name
  environment  = var.environment
}

# --- OpenVPN ---

module "openvpn" {
  source = "../../modules/openvpn"

  subnet_id            = module.vpc.public_subnet_id_list[0]
  security_group_id    = module.security_groups.openvpn_security_group_id
  vpn_client_cidr      = var.vpn_client_cidr
  instance_type        = var.openvpn_instance_type
  key_name             = var.key_name
  private_subnet_cidrs = module.vpc.private_subnet_cidr_list
  s3_backup_bucket     = module.s3_backup.bucket_name
  vpc_dns_ip           = cidrhost(var.vpc_cidr, 2)
  project_name         = var.project_name
  environment          = var.environment

  depends_on = [module.vpc, module.security_groups]
}

# --- cPanel ---

module "cpanel" {
  source = "../../modules/cpanel"

  subnet_id            = module.vpc.private_subnet_id_list[0]
  security_group_id    = module.security_groups.cpanel_security_group_id
  instance_type        = var.cpanel_instance_type
  key_name             = var.key_name
  root_volume_size     = var.cpanel_root_volume_size
  s3_backup_bucket_arn = module.s3_backup.bucket_arn
  hostname             = "cpanel.${var.domain_name}"
  project_name         = var.project_name
  environment          = var.environment

  depends_on = [module.vpc, module.security_groups, module.s3_backup]
}

# --- VPN Route (private subnet → OpenVPN for return traffic) ---

resource "aws_route" "vpn_return" {
  route_table_id         = module.vpc.private_route_table_id
  destination_cidr_block = var.vpn_client_cidr
  network_interface_id   = module.openvpn.network_interface_id
}

# --- Route 53 ---

module "route53" {
  source = "../../modules/route53"

  domain_name       = var.domain_name
  vpn_public_ip     = module.openvpn.public_ip
  cpanel_private_ip = module.cpanel.private_ip
}

# --- Monitoring ---

module "monitoring" {
  source = "../../modules/monitoring"

  instance_ids = {
    openvpn = module.openvpn.instance_id
    cpanel  = module.cpanel.instance_id
  }
  disk_monitor_instance_ids = {
    cpanel = module.cpanel.instance_id
  }
  alert_emails = var.alert_emails
  project_name = var.project_name
  environment  = var.environment
}
