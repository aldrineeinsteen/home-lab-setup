#!/bin/bash
# WSL Ansible Runner Script
# This script sets the necessary environment variables for running Ansible in WSL
# and suppresses the world-writable directory warning

# Set environment variables to ignore world-writable directory warning and set roles path
export ANSIBLE_CONFIG_IGNORE_WORLD_WRITABLE=True
export ANSIBLE_ROLES_PATH=./roles

echo "🚀 WSL Ansible Environment Configured"
echo "Environment variables set:"
echo "  - ANSIBLE_CONFIG_IGNORE_WORLD_WRITABLE=True"
echo "  - ANSIBLE_ROLES_PATH=./roles"
echo ""

# Check if .env.yaml exists
if [ ! -f ".env.yaml" ]; then
    echo "⚠️  Warning: .env.yaml not found!"
    echo "   Please copy .env.template.yaml to .env.yaml and configure your settings"
    echo "   Command: cp .env.template.yaml .env.yaml"
    echo ""
fi

# Show available commands
echo "📋 Available commands:"
echo "   Test connection:"
echo "   ansible pihole_servers -i inventory/hosts.yml --extra-vars \"@.env.yaml\" -m ping"
echo ""
echo "   Deploy Pi-hole:"
echo "   ansible-playbook -i inventory/hosts.yml playbooks/pihole.yml --extra-vars \"@.env.yaml\""
echo ""
echo "   Update blocklists only:"
echo "   ansible-playbook -i inventory/hosts.yml playbooks/pihole.yml --extra-vars \"@.env.yaml\" --tags \"blocklists\""
echo ""

# Start a new shell with the environment variables
echo "🔧 Starting new shell with configured environment..."
exec bash