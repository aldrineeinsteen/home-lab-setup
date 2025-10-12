git clone https://github.com/aldrineeinsteen/home-lab-setup.git
# Minimal Pi-hole Setup

## Prerequisites
- Remote server (Ubuntu 22.04+ recommended)
- SSH access
- Ansible installed locally
- Configuration in `.env.yaml`

## Setup Steps
1. Edit `.env.yaml` with your Pi-hole server details and admin password.
2. Edit `inventory/hosts.yml` with your remote host info.
3. Run the playbook:
  ```sh
  ansible-playbook -i inventory/hosts.yml playbooks/pihole-minimal.yml --extra-vars "@.env.yaml"
  ```

## API Usage Example (with httpie)
1. Install httpie:
  ```sh
  brew install httpie
  ```
2. Authenticate:
  ```sh
  http --verify=no POST https://<PIHOLE_IP>:443/api/auth \
    accept:application/json \
    content-type:application/json \
    password=<admin_password>
  ```
3. Use the API (pass SID and CSRF from auth response):
  ```sh
  http --verify=no GET https://<PIHOLE_IP>:443/api/lists \
    Cookie:"SID=<sid>" \
    X-CSRF-Token:<csrf> \
    accept:application/json
  ```
  machine_ip: "192.168.1.100"        # Static IP
  interface: "eth0"                  # Network interface
  
  # DNS servers
  dns_servers:
    - "1.1.1.1"    # Cloudflare
    - "1.0.0.1"    # Cloudflare secondary
  
  # Network configuration (optional)
  network:
    postfix: "lan"
  custom_dns:
    - domain: "pihole.lan"
      ip: "192.168.1.100"
    - domain: "homelab.lan" 
      ip: "192.168.1.100"
```

### 5. Test Connection
```bash
# For WSL users - use the convenience script (recommended)
./wsl-setup.sh

# Or manually set environment variable to suppress directory warnings
export ANSIBLE_CONFIG_IGNORE_WORLD_WRITABLE=True

# Test the connection
ansible pihole_servers -i inventory/hosts.yml --extra-vars "@.env.yaml" -m ping
```

### 5. Deploy Pi-hole
```bash
# Deploy Pi-hole to your target machine (recommended)
./deploy-modern-pihole.sh

# Or run Ansible directly
ansible-playbook -i inventory/hosts.yml playbooks/pihole.yml --extra-vars "@.env.yaml"

# Validate configuration quality
./scripts/validate-pihole-config.sh

# Test modern API functionality
./scripts/test-pihole-modern.sh
```

### 7. Access Pi-hole
- **Web Interface**: http://192.168.1.100/admin/
- **Password**: Your configured admin password
- **Configure DNS**: Set router or devices to use `192.168.1.100` as DNS

## 🎯 What You Get

✅ **Modern Pi-hole FTL installation** with official installer  
✅ **pihole-FTL --config API** for all configuration management  
✅ **Custom blocklists** and whitelist management via API  
✅ **Local DNS records** for your home lab services  
✅ **DHCP server** configuration using FTL commands  
✅ **Pi-hole v6+ optimized** with modern configuration methods  
✅ **Comprehensive API testing** and validation  
✅ **Secure setup** with no hardcoded credentials  
✅ **Idempotent** - safe to run multiple times  

## 🔧 Common Commands

```bash
# Use the convenience script (recommended for WSL)
./wsl-setup.sh

# Or set environment variables manually
export ANSIBLE_CONFIG_IGNORE_WORLD_WRITABLE=True
export ANSIBLE_ROLES_PATH=./roles

# Update blocklists only
ansible-playbook -i inventory/hosts.yml playbooks/pihole.yml --extra-vars "@.env.yaml" --tags "blocklists"

# Configure network settings only  
ansible-playbook -i inventory/hosts.yml playbooks/pihole.yml --extra-vars "@.env.yaml" --tags "network"

# Run comprehensive API testing
ansible-playbook -i inventory/hosts.yml playbooks/pihole.yml --extra-vars "@.env.yaml" --tags "testing"

# Check Pi-hole status (multiple methods)
ssh pi@192.168.1.100 "sudo /usr/local/bin/pihole-status"
ssh pi@192.168.1.100 "sudo /usr/local/bin/pihole-test-all"

# Test DHCP functionality
./scripts/test-dhcp.sh

# Check DHCP status using modern FTL commands
ssh pi@192.168.1.100 "sudo pihole-FTL --config dhcp.active"
ssh pi@192.168.1.100 "sudo /usr/local/bin/pihole-dhcp-check"

# Network configuration summary
ssh pi@192.168.1.100 "sudo /usr/local/bin/pihole-network-config-summary"
```

## 🔐 Security Best Practices

1. **Use SSH keys** instead of passwords:
   ```bash
   ssh-keygen -t ed25519
   ssh-copy-id pi@192.168.1.100
   ```
   Then remove `ssh_password` from `.env.yaml`

2. **Never commit** `.env.yaml` (it's already in .gitignore)

3. **Use strong passwords** for Pi-hole admin interface

## � Troubleshooting

**Connection issues:**
```bash
# Test SSH connectivity
ssh pi@192.168.1.100

# Check Ansible connectivity
ansible pihole_servers -i inventory/hosts.yml --extra-vars "@.env.yaml" -m ping
```

**Become method error (fixed):**
If you encounter `"the field 'become' has an invalid value"`, this has been resolved in the inventory configuration. The issue was with `ansible_become` being set to a string instead of a boolean.

**API task sudo error (RESOLVED):**
The sudo error with blocklist API tasks has been resolved by running API calls directly on the Pi-hole machine instead of delegating to localhost. Blocklist management now works seamlessly.

**Note on blocklists:**
Pi-hole comes with default blocklists pre-installed. Your custom blocklists from `.env.yaml` will be added during deployment. You can verify active lists in the web interface under Settings > Blocklists.

**Pi-hole not accessible:**
```bash
# Check services on target machine
ssh pi@192.168.1.100
sudo systemctl status pihole-FTL
# Note: Pi-hole FTL provides built-in web server (no lighttpd needed)

# Check web interface status
sudo systemctl status pihole-FTL
curl -s http://localhost/admin/ | head -1

# Comprehensive testing
sudo /usr/local/bin/pihole-test-all
```

**DNS not working:**
```bash
# Test DNS resolution
dig @192.168.1.100 google.com
```

**Lists not appearing:**
Lists are managed via Pi-hole FTL API and database. Check current status:
```bash
# Check lists via API
curl -s "http://192.168.1.100/api/lists" | jq

# Check via command line
ssh pi@192.168.1.100 "pihole adlist list"
ssh pi@192.168.1.100 "pihole allowlist list"

# Check in web interface: Settings > Blocklists
# Or run comprehensive test
ssh pi@192.168.1.100 "sudo /usr/local/bin/pihole-test-all"
```

## � Modern Pi-hole FTL Configuration

This project uses modern **pihole-FTL --config** commands for all configuration management instead of legacy file manipulation:

```bash
# DNS Configuration
pihole-FTL --config dns.upstreams '["1.1.1.1","1.0.0.1"]'
pihole-FTL --config dns.interface eth0
pihole-FTL --config dns.queryLogging true

# DHCP Configuration  
pihole-FTL --config dhcp.active true
pihole-FTL --config dhcp.start 192.168.1.100
pihole-FTL --config dhcp.end 192.168.1.250
pihole-FTL --config dhcp.router 192.168.1.1

# Web Interface (managed by Pi-hole FTL built-in server)
# No FTL config needed - enabled via setupVars.conf during installation

# Blocklist Management
pihole adlist add "https://example.com/blocklist"
pihole allowlist add "example.com"
pihole denylist add "ads.example.com"
```

### Configuration Benefits:
- ✅ **Real-time updates** - No service restarts needed
- ✅ **API consistency** - Unified with web interface
- ✅ **Better validation** - Built-in parameter checking
- ✅ **Future-proof** - Compatible with Pi-hole v6+

##  Documentation

- **[Architecture.md](Architecture.md)** - Detailed technical implementation
- **[PIHOLE_FTL_CONFIG_REFERENCE.md](PIHOLE_FTL_CONFIG_REFERENCE.md)** - Complete FTL config options reference
- **[Pi-hole Documentation](https://docs.pi-hole.net/)** - Official Pi-hole docs  
- **[Pi-hole FTL Documentation](https://ftl.pi-hole.net/)** - FTL configuration reference
- **Issues & Support** - Use GitHub issues for help

## � Future Services

This project is designed to be extensible for additional home lab services:
- NAS (Samba/NFS)
- Media servers (Plex/Jellyfin)
- Home automation (Home Assistant)
- Monitoring (Prometheus/Grafana)
- VPN (WireGuard)

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

---

**Need help?** Check [Architecture.md](Architecture.md) for detailed documentation or create an issue on GitHub.