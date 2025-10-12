#!/bin/bash
# Pi-hole Modern FTL Configuration Deployment Script
# This script demonstrates the complete modernized Pi-hole setup

set -e

echo "🚀 Pi-hole Modern FTL Configuration Deployment"
echo "=============================================="
echo

# Set environment variables for WSL
export ANSIBLE_CONFIG_IGNORE_WORLD_WRITABLE=True
export ANSIBLE_ROLES_PATH=./roles

echo "📋 Pre-deployment Checks"
echo "------------------------"

# Check if .env.yaml exists
if [ ! -f ".env.yaml" ]; then
    echo "❌ .env.yaml not found. Please copy .env.template.yaml to .env.yaml and configure it."
    exit 1
fi

# Test connection
echo "🔍 Testing connection to Pi-hole server..."
if ansible pihole_servers -i inventory/hosts.yml --extra-vars "@.env.yaml" -m ping > /dev/null 2>&1; then
    echo "✅ Connection successful"
else
    echo "❌ Connection failed. Please check your .env.yaml configuration."
    exit 1
fi

echo
echo "🏗️  Deploying Pi-hole with Modern FTL Configuration"
echo "---------------------------------------------------"

# Full deployment
echo "📦 Running full Pi-hole deployment..."
ansible-playbook -i inventory/hosts.yml playbooks/pihole.yml --extra-vars "@.env.yaml"

echo
echo "🧪 Running Comprehensive Tests"
echo "------------------------------"

# Run testing
echo "🔬 Executing API and configuration tests..."
ansible-playbook -i inventory/hosts.yml playbooks/pihole.yml --extra-vars "@.env.yaml" --tags testing

echo
echo "📊 Deployment Summary"
echo "--------------------"

# Get Pi-hole host from .env.yaml
PIHOLE_HOST=$(grep "ssh_host:" .env.yaml | cut -d'"' -f2)

echo "🌐 Pi-hole Access Information:"
echo "   Web Interface: http://$PIHOLE_HOST/admin/"
echo "   DNS Server: $PIHOLE_HOST"
echo

echo "🔧 Modern FTL Configuration Commands Used:"
echo "   • pihole-FTL --config dns.upstreams (JSON array format)"
echo "   • pihole-FTL --config dns.interface"
echo "   • pihole-FTL --config dhcp.active"
echo "   Note: Web interface managed by Pi-hole FTL built-in server"
echo "   • pihole adlist add/list"
echo "   • pihole allowlist add/list"
echo

echo "📋 Useful Commands:"
echo "   # Check FTL configuration:"
echo "   ssh user@$PIHOLE_HOST 'sudo pihole-FTL --config dns.upstreams'"
echo
echo "   # Run comprehensive test:"
echo "   ssh user@$PIHOLE_HOST 'sudo /usr/local/bin/pihole-test-all'"
echo
echo "   # Update blocklists only:"
echo "   ansible-playbook -i inventory/hosts.yml playbooks/pihole.yml --extra-vars '@.env.yaml' --tags blocklists"
echo

echo "✅ Pi-hole deployment completed successfully!"
echo "   Modern pihole-FTL configuration is now active."
echo "   All configuration uses API commands instead of file manipulation."
echo "   Proper error handling for check mode and API availability."
echo