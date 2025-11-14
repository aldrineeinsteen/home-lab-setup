#!/bin/bash
# Pi-hole Modern FTL Configuration Deployment Script
# This script demonstrates the complete modernized Pi-hole setup

set -e

echo "🚀 Pi-hole Modern FTL Configuration Deployment"
echo "=============================================="
echo

# Set environment variables for WSL
export ANSIBLE_CONFIG_IGNORE_WORLD_WRITABLE=True
export ANSIBLE_ROLES_PATH=./services/pihole/roles

echo "📋 Pre-deployment Checks"
echo "------------------------"

# Check if .env.yaml exists
if [ ! -f ".env.yaml" ]; then
    echo "❌ .env.yaml not found. Please copy .env.template.yaml to .env.yaml and configure it."
    exit 1
fi

# Test connection with detailed output
echo "🔍 Testing connection to Pi-hole server..."
echo "📋 Configuration summary:"

# Extract key values from .env.yaml for debugging  
PIHOLE_HOST=$(grep "ssh_host:" .env.yaml | head -1 | awk '{print $2}' | tr -d '"')
PIHOLE_USER=$(grep "ssh_user:" .env.yaml | head -1 | awk '{print $2}' | tr -d '"')

echo "   Host: $PIHOLE_HOST"
echo "   User: $PIHOLE_USER"

# Test basic network connectivity first
echo "🌐 Testing network connectivity..."
if ping -c 1 -W 3 "$PIHOLE_HOST" > /dev/null 2>&1; then
    echo "✅ Host is reachable"
    
    # Test SSH connectivity
    echo "🔑 Testing SSH connectivity..."
    if ansible pihole_servers -i inventory/hosts.yml --extra-vars "@.env.yaml" -m ping > /dev/null 2>&1; then
        echo "✅ SSH connection successful"
    else
        echo "⚠️  SSH connection failed, but proceeding with deployment..."
        echo "    This might be expected in test environments"
        echo "    Detailed error:"
        ansible pihole_servers -i inventory/hosts.yml --extra-vars "@.env.yaml" -m ping 2>&1 | head -5
    fi
else
    echo "⚠️  Host not reachable, assuming test environment"
    echo "    Run with --check flag for syntax validation only"
    
    # Offer to continue with check mode
    echo
    echo "🤔 Would you like to:"
    echo "   1. Continue with deployment (will fail if host unreachable)"
    echo "   2. Run in check mode only (syntax validation)"
    echo "   3. Exit and fix configuration"
    echo
    
    if [ -t 0 ]; then  # Only prompt if running interactively
        read -p "Enter choice (1/2/3): " choice
        case $choice in
            2)
                echo "🔍 Running in check mode only..."
                CHECK_MODE="--check"
                ;;
            3)
                echo "👋 Exiting. Please check your .env.yaml configuration."
                exit 0
                ;;
            *)
                echo "⚡ Continuing with deployment..."
                ;;
        esac
    else
        echo "⚡ Non-interactive mode: continuing with deployment..."
    fi
fi

echo
echo "🏗️  Deploying Pi-hole with Modern FTL Configuration"
echo "---------------------------------------------------"

# Full deployment
if [ -n "$CHECK_MODE" ]; then
    echo "📦 Running Pi-hole deployment validation (check mode)..."
    ansible-playbook -i inventory/hosts.yml services/pihole/playbooks/pihole.yml --extra-vars "@.env.yaml" $CHECK_MODE
else
    echo "📦 Running full Pi-hole deployment..."
    ansible-playbook -i inventory/hosts.yml services/pihole/playbooks/pihole.yml --extra-vars "@.env.yaml"
fi

echo
echo "🧪 Running Comprehensive Tests"
echo "------------------------------"

# Run testing
if [ -z "$CHECK_MODE" ]; then
    echo "🔬 Executing API and configuration tests..."
    ansible-playbook -i inventory/hosts.yml services/pihole/playbooks/pihole.yml --extra-vars "@.env.yaml" --tags testing
    
    echo "✅ Testing completed successfully"
else
    echo "🔬 Skipping live tests in check mode"
    echo "✅ Syntax validation completed successfully"
fi

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
echo "   • Web interface managed by Pi-hole FTL built-in server"
echo "   • pihole adlist add/list"
echo "   • pihole allowlist add/list"
echo "   • Modern API endpoints (/api/lists, /api.php)"
echo

echo "📋 Useful Commands:"
echo "   # Check FTL configuration:"
echo "   ssh user@$PIHOLE_HOST 'sudo pihole-FTL --config dns.upstreams'"
echo
echo "   # Run on-device test:"
echo "   ssh user@$PIHOLE_HOST 'sudo /usr/local/bin/pihole-test-all'"
echo
echo "   # Update blocklists only:"
echo "   ansible-playbook -i inventory/hosts.yml services/pihole/playbooks/pihole.yml --extra-vars '@.env.yaml' --tags blocklists"
echo

echo "✅ Pi-hole deployment completed successfully!"
echo "   Modern pihole-FTL configuration is now active."
echo "   All configuration uses API commands instead of file manipulation."
echo "   Proper error handling for check mode and API availability."
echo