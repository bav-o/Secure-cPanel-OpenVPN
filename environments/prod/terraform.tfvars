aws_region         = "us-east-1"
project_name       = "vcode"
environment        = "prod"
availability_zones = ["us-east-1a", "us-east-1b"]
admin_cidr         = "203.0.113.0/32" # TODO: set to your admin IP/32
vpn_client_cidr    = "10.8.0.0/24"
key_name           = "prod-keypair" # CHANGE: your EC2 key pair
domain_name        = "example.com"  # CHANGE: your domain

openvpn_instance_type   = "t3.small"
cpanel_instance_type    = "c5.xlarge"
cpanel_root_volume_size = 100
alert_emails            = ["admin@example.com"] # CHANGE: your email
