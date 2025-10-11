#!/bin/bash

# Home Lab Pi-hole Deployment Script
# This script helps you deploy Pi-hole using Ansible

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Parse command line arguments first
DRY_RUN=false
VERBOSE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run|-d|--check|-c)
            DRY_RUN=true
            shift
            ;;
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --dry-run, -d     Run in dry-run mode (check mode)"
            echo "  --check, -c       Same as --dry-run" 
            echo "  --verbose, -v     Run with verbose output"
            echo "  --help, -h        Show this help message"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"
ANSIBLE_DIR="$PROJECT_ROOT/ansible"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Home Lab Pi-hole Deployment Script${NC}"
echo -e "${BLUE}========================================${NC}"

# Check if .env.sh exists
if [ ! -f "$PROJECT_ROOT/.env.sh" ]; then
    echo -e "${RED}Error: .env.sh file not found!${NC}"
    echo -e "${YELLOW}Please copy .env.template.sh to .env.sh and configure your settings:${NC}"
    echo "  cp .env.template.sh .env.sh"
    echo "  # Edit .env.sh with your actual configuration"
    exit 1
fi

# Source environment variables
echo -e "${GREEN}Loading environment variables...${NC}"
source "$PROJECT_ROOT/.env.sh"

# Validate required variables
if [ -z "$PIHOLE_HOST" ] || [ -z "$PIHOLE_USER" ]; then
    echo -e "${RED}Error: Required environment variables not set!${NC}"
    echo "Please ensure PIHOLE_HOST and PIHOLE_USER are configured in .env.sh"
    exit 1
fi

# Check if Ansible is installed
if ! command -v ansible-playbook &> /dev/null; then
    echo -e "${RED}Error: Ansible is not installed!${NC}"
    echo -e "${YELLOW}Please install Ansible:${NC}"
    echo "  # Ubuntu/Debian:"
    echo "  sudo apt update && sudo apt install ansible"
    echo "  # macOS:"
    echo "  brew install ansible"
    echo "  # Python pip:"
    echo "  pip install ansible"
    exit 1
fi

# Check SSH connectivity
echo -e "${GREEN}Testing SSH connectivity to $PIHOLE_HOST...${NC}"
if ! ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no -i "$SSH_KEY_PATH" "$PIHOLE_USER@$PIHOLE_HOST" "echo 'SSH connection successful'" 2>/dev/null; then
    echo -e "${RED}Error: Cannot connect to $PIHOLE_HOST via SSH!${NC}"
    echo -e "${YELLOW}Please ensure:${NC}"
    echo "  1. The target host is reachable"
    echo "  2. SSH key is properly configured"
    echo "  3. User has appropriate permissions"
    exit 1
fi

echo -e "${GREEN}SSH connectivity test passed!${NC}"

# Change to ansible directory
cd "$ANSIBLE_DIR"

# Run syntax check
echo -e "${GREEN}Checking playbook syntax...${NC}"
ansible-playbook -i inventory/hosts.yml site.yml --syntax-check

# Command line arguments already parsed at the beginning of script

# Build ansible command
ANSIBLE_CMD="ansible-playbook -i inventory/hosts.yml site.yml"

if [ "$DRY_RUN" = true ]; then
    echo -e "${BLUE}Running in DRY-RUN mode - no changes will be made${NC}"
    ANSIBLE_CMD="$ANSIBLE_CMD --check --diff"
else
    # Ask for confirmation only if not dry-run
    echo -e "${YELLOW}Ready to deploy Pi-hole to $PIHOLE_HOST${NC}"
    echo -e "${YELLOW}Web interface will be available at: http://$PIHOLE_HOST:$PIHOLE_WEBPORT/admin/${NC}"
    echo -e "${YELLOW}DNS server will be available at: $PIHOLE_HOST:$PIHOLE_DNSPORT${NC}"
    echo ""
    read -p "Continue with deployment? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Deployment cancelled."
        exit 0
    fi
    ANSIBLE_CMD="$ANSIBLE_CMD --ask-become-pass"
fi

if [ "$VERBOSE" = true ]; then
    ANSIBLE_CMD="$ANSIBLE_CMD -v"
fi

# Run the playbook
if [ "$DRY_RUN" = true ]; then
    echo -e "${GREEN}Starting Pi-hole deployment dry-run...${NC}"
else
    echo -e "${GREEN}Starting Pi-hole deployment...${NC}"
fi

eval $ANSIBLE_CMD

if [ "$DRY_RUN" = true ]; then
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  Dry-Run Complete!${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}No actual changes were made to the system.${NC}"
    echo -e "${BLUE}Review the output above to see what would be changed.${NC}"
else
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  Deployment Complete!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}Pi-hole web interface: http://$PIHOLE_HOST:$PIHOLE_WEBPORT/admin/${NC}"
    echo -e "${GREEN}DNS server: $PIHOLE_HOST:$PIHOLE_DNSPORT${NC}"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo "1. Configure your router to use $PIHOLE_HOST as DNS server"
    echo "2. Or configure individual devices to use this DNS server"
    echo "3. Access the web interface to customize settings"
fi