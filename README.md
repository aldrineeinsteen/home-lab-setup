# Home Lab Setup

An Ansible-based automation solution for setting up and managing home lab infrastructure, starting with Pi-hole DNS filtering.

## Features

- **Automated Pi-hole Deployment**: Complete Pi-hole installation and configuration
- **Environment-based Configuration**: Secure configuration management using environment files
- **Cross-platform Support**: Works on Linux, macOS, and Windows (with WSL)
- **Firewall Configuration**: Automatic firewall setup for required services
- **Custom Blocklists**: Support for custom blocklist and whitelist management
- **Comprehensive Monitoring**: Service health checks and deployment verification

## Quick Start

### Prerequisites

1. **Ansible**: Install Ansible on your control machine
   ```bash
   # Ubuntu/Debian
   sudo apt update && sudo apt install ansible
   
   # macOS
   brew install ansible
   
   # Python pip
   pip install ansible
   ```

2. **SSH Access**: Ensure SSH key-based authentication to your target host
   ```bash
   ssh-copy-id user@your-pi-hole-host
   ```

### Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/aldrineeinsteen/home-lab-setup.git
   cd home-lab-setup
   ```

2. **Configure environment variables**:
   ```bash
   cp .env.template.sh .env.sh
   nano .env.sh  # Edit with your actual configuration
   ```

3. **Deploy Pi-hole**:
   ```bash
   # Linux/macOS - Full deployment
   chmod +x deploy.sh
   ./deploy.sh
   
   # Linux/macOS - Dry run (check what would be changed)
   ./deploy.sh --dry-run
   
   # Windows PowerShell - Full deployment
   .\deploy.ps1
   
   # Windows PowerShell - Dry run
   .\deploy.ps1 -DryRun
   ```

## Configuration

### Environment Variables

The `.env.sh` file contains all configuration parameters. Key variables include:

#### Pi-hole Configuration
- `PIHOLE_HOST`: IP address of the Pi-hole server
- `PIHOLE_USER`: SSH user for the Pi-hole server
- `PIHOLE_PASSWORD`: Pi-hole web admin password
- `PIHOLE_DNS1/DNS2`: Primary and secondary DNS servers
- `PIHOLE_TIMEZONE`: Timezone for Pi-hole

#### Network Configuration
- `NETWORK_DOMAIN`: Local domain name
- `NETWORK_DHCP_RANGE_START/END`: DHCP range (if using Pi-hole as DHCP server)
- `NETWORK_GATEWAY`: Network gateway

#### Security Configuration
- `SSH_KEY_PATH`: Path to SSH private key
- `SSH_PORT`: SSH port (default: 22)

See `.env.template.sh` for all available configuration options.

### Inventory Configuration

The Ansible inventory is located at `ansible/inventory/hosts.yml`. It defines:
- Target hosts and their connection parameters
- Host-specific variables
- Group variables for Pi-hole servers

## Project Structure

```
├── .env.template.sh          # Environment configuration template
├── .gitignore               # Git ignore rules
├── deploy.sh                # Linux/macOS deployment script
├── deploy.ps1               # Windows PowerShell deployment script
├── README.md                # This file
└── ansible/
    ├── ansible.cfg          # Ansible configuration
    ├── site.yml             # Main playbook
    ├── inventory/
    │   └── hosts.yml        # Inventory file
    ├── group_vars/
    │   └── all.yml          # Global variables
    ├── host_vars/           # Host-specific variables
    └── roles/
        └── pihole/          # Pi-hole role
            ├── defaults/    # Default variables
            ├── files/       # Static files
            ├── handlers/    # Event handlers
            ├── tasks/       # Task definitions
            ├── templates/   # Jinja2 templates
            └── vars/        # Role variables
```

## Manual Deployment

If you prefer to run Ansible commands manually:

```bash
cd ansible

# Check syntax
ansible-playbook -i inventory/hosts.yml site.yml --syntax-check

# Run with check mode (dry run)
ansible-playbook -i inventory/hosts.yml site.yml --check

# Deploy Pi-hole
ansible-playbook -i inventory/hosts.yml site.yml --ask-become-pass

# Deploy with specific tags
ansible-playbook -i inventory/hosts.yml site.yml --tags pihole
```

## Post-Deployment

After successful deployment:

1. **Access Pi-hole Web Interface**: 
   - URL: `http://your-pihole-host/admin/`

2. **Configure DNS**:
   - **Option A**: Update your router's DNS settings to use your Pi-hole server
   - **Option B**: Configure individual devices to use your Pi-hole as DNS server

3. **Verify Operation**:
   - Check the Pi-hole query log to ensure DNS filtering is working
   - Test domain blocking by visiting a known ad-serving domain

## Customization

### Adding Custom Blocklists

**Method 1: JSON Configuration (Recommended)**

The project includes a structured JSON configuration file at `ansible/roles/pihole/files/blocklists.json` that allows you to manage blocklists, whitelists, and regex patterns:

```json
{
  "blocklists": [
    {
      "name": "StevenBlack Unified Hosts",
      "url": "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts",
      "description": "Unified hosts file with base extensions",
      "enabled": true
    }
  ],
  "whitelist": [
    {
      "domain": "github.com",
      "description": "GitHub main domain", 
      "enabled": true
    }
  ],
  "regex_blocklist": [
    {
      "pattern": "^(.+[-_.])??adse?rv(er?|ice)?s?[0-9]*[-.]",
      "description": "Block ad servers",
      "enabled": true
    }
  ]
}
```

**Method 2: Environment Variables (Legacy)**

Configure custom blocklists in `.env.sh`:
```bash
export PIHOLE_BLOCKLISTS="https://example.com/blocklist1,https://example.com/blocklist2"
export PIHOLE_WHITELIST="github.com,githubusercontent.com,example.com"
```

The JSON method is preferred as it provides:
- Better organization and documentation
- Enable/disable individual lists without editing URLs
- Support for regex patterns
- Detailed descriptions for each entry

### DHCP Configuration

To use Pi-hole as DHCP server, configure in `.env.sh`:
```bash
export NETWORK_DHCP_RANGE_START="192.168.1.50"
export NETWORK_DHCP_RANGE_END="192.168.1.150"
```

## Troubleshooting

### Common Issues

1. **SSH Connection Failed**:
   - Verify SSH key is properly configured
   - Check firewall settings on target host
   - Ensure SSH service is running

2. **Ansible Permission Denied**:
   - Ensure user has sudo privileges
   - Check SSH key permissions (should be 600)

3. **Pi-hole Installation Failed**:
   - Check internet connectivity on target host
   - Verify DNS resolution is working
   - Review Pi-hole installation logs

### Logs and Debugging

- **Ansible Logs**: Check Ansible output for detailed error messages
- **Pi-hole Logs**: `/var/log/pihole.log` on the target host
- **Service Status**: `systemctl status pihole-FTL` and `systemctl status lighttpd`

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Make your changes and test thoroughly
4. Commit your changes: `git commit -am 'Add new feature'`
5. Push to the branch: `git push origin feature/your-feature`
6. Submit a pull request against the `dev` branch

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For issues and questions:
- Open an issue on GitHub
- Check the troubleshooting section above
- Review Pi-hole documentation: https://docs.pi-hole.net/

## Roadmap

Future enhancements planned:
- [ ] Support for multiple Pi-hole instances (high availability)
- [ ] Integration with other home lab services (Prometheus monitoring, etc.)
- [ ] Automated backup and restore functionality
- [ ] Docker-based deployment option
- [ ] Web-based configuration interface