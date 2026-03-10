#!/bin/bash
set -euo pipefail

# cPanel requires a clean, freshly installed OS
# Ensure hostname is set properly
hostnamectl set-hostname server.example.com

# Update system packages
dnf update -y

# Install required dependencies
dnf install -y perl curl wget

# Disable NetworkManager (cPanel recommendation)
systemctl disable --now NetworkManager 2>/dev/null || true
systemctl enable --now network 2>/dev/null || true

# Install cPanel/WHM
cd /home
curl -o latest -L https://securedownloads.cpanel.net/latest
sh latest

# cPanel installer runs in background; WHM will be available on port 2087
# after installation completes (typically 30-60 minutes)
