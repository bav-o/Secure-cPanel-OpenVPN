aws_region         = "us-east-1"
project_name       = "vcode"
environment        = "dev"
availability_zones = ["us-east-1a", "us-east-1b"]
admin_cidr         = "0.0.0.0/0" # CHANGE: set to your admin IP/32
vpn_client_cidr    = "10.8.0.0/24"
key_name           = "dev-keypair"     # CHANGE: your EC2 key pair
domain_name        = "dev.example.com" # CHANGE: your domain

openvpn_instance_type   = "t3.small"
cpanel_instance_type    = "c5.large"
cpanel_root_volume_size = 100
alert_emails            = ["admin@example.com"] # CHANGE: your email
