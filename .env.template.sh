#!/bin/bash
# Environment configuration template for home lab setup
# Copy this file to .env.sh and fill in your actual values

# Pi-hole Configuration
export PIHOLE_HOST="192.168.1.100"              # IP address of the Pi-hole server
export PIHOLE_USER="pi"                         # SSH user for Pi-hole server
export PIHOLE_PASSWORD="your_admin_password"    # Pi-hole web admin password
export PIHOLE_DNS1="1.1.1.1"                   # Primary DNS server (Cloudflare)
export PIHOLE_DNS2="1.0.0.1"                   # Secondary DNS server (Cloudflare)
export PIHOLE_TIMEZONE="America/New_York"       # Timezone for Pi-hole
export PIHOLE_WEBPORT="80"                      # Web interface port
export PIHOLE_DNSPORT="53"                      # DNS service port

# Network Configuration
export NETWORK_DOMAIN="homelab.local"           # Local domain name
export NETWORK_DHCP_RANGE_START="192.168.1.50" # DHCP range start
export NETWORK_DHCP_RANGE_END="192.168.1.150"  # DHCP range end
export NETWORK_GATEWAY="192.168.1.1"           # Network gateway

# SSH Configuration
export SSH_KEY_PATH="~/.ssh/id_rsa"            # Path to SSH private key
export SSH_PORT="22"                           # SSH port

# Ansible Configuration
export ANSIBLE_USER="ansible"                  # Ansible user (if different from SSH user)
export ANSIBLE_BECOME_PASS=""                  # Sudo password (leave empty if using NOPASSWD)

# Optional: Custom blocklists
export PIHOLE_BLOCKLISTS="https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts,https://someonewhocares.org/hosts/zero/hosts"

# Optional: Whitelist domains (comma-separated)
export PIHOLE_WHITELIST="github.com,githubusercontent.com"

# Logging
export ANSIBLE_LOG_LEVEL="INFO"               # Ansible log level (DEBUG, INFO, WARNING, ERROR)