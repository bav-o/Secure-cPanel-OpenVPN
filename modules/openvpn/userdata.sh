#!/bin/bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

# Update system
apt-get update -y
apt-get upgrade -y

# Install OpenVPN and Easy-RSA
apt-get install -y openvpn easy-rsa iptables-persistent

# Set up Easy-RSA
make-cadir /etc/openvpn/easy-rsa
cd /etc/openvpn/easy-rsa

cat > vars <<'VARS'
set_var EASYRSA_ALGO        ec
set_var EASYRSA_DIGEST      sha512
set_var EASYRSA_CURVE       secp384r1
set_var EASYRSA_CA_EXPIRE   3650
set_var EASYRSA_CERT_EXPIRE 825
VARS

./easyrsa init-pki
./easyrsa --batch build-ca nopass
./easyrsa --batch gen-req server nopass
./easyrsa --batch sign-req server server
./easyrsa gen-dh
openvpn --genkey secret /etc/openvpn/ta.key

# Generate initial client certificate
./easyrsa --batch gen-req client1 nopass
./easyrsa --batch sign-req client client1

# Create server config
cat > /etc/openvpn/server.conf <<'SERVERCONF'
port 1194
proto udp
dev tun
ca /etc/openvpn/easy-rsa/pki/ca.crt
cert /etc/openvpn/easy-rsa/pki/issued/server.crt
key /etc/openvpn/easy-rsa/pki/private/server.key
dh /etc/openvpn/easy-rsa/pki/dh.pem
tls-auth /etc/openvpn/ta.key 0
server ${vpn_client_cidr}
cipher AES-256-GCM
auth SHA384
tls-version-min 1.2
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 1.1.1.1"
push "dhcp-option DNS 8.8.8.8"
keepalive 10 120
persist-key
persist-tun
status /var/log/openvpn-status.log
log-append /var/log/openvpn.log
verb 3
user nobody
group nogroup
SERVERCONF

# Push routes for private subnets
for cidr in ${private_subnet_cidrs}; do
  IFS='/' read -r network prefix <<< "$cidr"
  # Convert prefix to netmask
  mask=$(python3 -c "import ipaddress; print(ipaddress.IPv4Network('$cidr', strict=False).netmask)")
  echo "push \"route $network $mask\"" >> /etc/openvpn/server.conf
done

# Enable IP forwarding
echo "net.ipv4.ip_forward = 1" > /etc/sysctl.d/99-openvpn.conf
sysctl -p /etc/sysctl.d/99-openvpn.conf

# Configure NAT
IFACE=$(ip route show default | awk '{print $5}')
iptables -t nat -A POSTROUTING -s ${vpn_client_cidr} -o "$IFACE" -j MASQUERADE
iptables -A FORWARD -i tun0 -o "$IFACE" -j ACCEPT
iptables -A FORWARD -i "$IFACE" -o tun0 -m state --state RELATED,ESTABLISHED -j ACCEPT
netfilter-persistent save

# Start OpenVPN
systemctl enable openvpn@server
systemctl start openvpn@server
