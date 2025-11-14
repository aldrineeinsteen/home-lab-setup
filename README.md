# Pi-hole Home Lab Setup

Complete Ansible automation for deploying and managing Pi-hole DNS ad-blocker with DHCP server capabilities.

## 🎯 Features

✅ **Automated Pi-hole v6+ deployment** with modern FTL configuration  
✅ **Web interface authentication** with password protection  
✅ **Custom DNS entries** for local domain resolution  
✅ **Blocklist management** (5+ default lists included)  
✅ **Whitelist/Blacklist** domain management via CLI  
✅ **DHCP server** configuration  
✅ **Static IP configuration** (router-based recommended)  
✅ **Idempotent playbooks** - safe to run multiple times  

## 📋 Prerequisites

### On Your Local Machine:
- **macOS/Linux/WSL** with Ansible installed
- **SSH access** to target server
- **Network access** to target server

### On Target Server:
- **Ubuntu 22.04+** or Debian-based OS
- **Fresh OS installation** recommended
- **Sudo privileges** for the SSH user
- **Internet connection** for downloading Pi-hole

### Install Ansible (macOS):
```bash
brew install ansible
```

### Install Ansible (Ubuntu/Debian):
```bash
sudo apt update
sudo apt install ansible
```

## 🚀 Quick Start

### 1. Clone Repository
```bash
git clone https://github.com/aldrineeinsteen/home-lab-setup.git
cd home-lab-setup
```

### 2. Configure Your Environment

Copy the template and edit with your settings:
```bash
cp .env.template.yaml .env.yaml
nano .env.yaml  # or use your preferred editor
```

**Important settings to configure:**
```yaml
pihole:
  # SSH Connection
  ssh_user: "your_username"           # SSH username
  ssh_host: "192.168.100.99"          # Target server IP
  ssh_password: "your_password"       # SSH/sudo password
  
  # Pi-hole Configuration
  admin_password: "strong_password"   # Web interface password
  machine_ip: "192.168.100.99"        # Should match ssh_host
  interface: "eth0"                   # Network interface (eth0 or wlan0)
  
  # DNS Servers (upstream)
  dns_servers:
    - "94.140.14.15"    # AdGuard DNS
    - "94.140.15.16"    # AdGuard DNS Secondary
  
  # DHCP Configuration (optional)
  dhcp:
    enabled: true                     # Enable DHCP server
    start_ip: "192.168.100.100"       # DHCP range start
    end_ip: "192.168.100.200"         # DHCP range end
    router_ip: "192.168.100.1"        # Gateway IP
    lease_time: "30m"                 # Lease duration
  
  # Network Settings
  network:
    postfix: "lan"                    # Local domain suffix
  
  # Custom DNS Entries
  custom_dns:
    - domain: "pihole.lan"
      ip: "192.168.100.99"
```

### 3. Update Inventory

Edit `inventory/hosts.yml` to match your `.env.yaml`:
```yaml
all:
  children:
    pihole:
      hosts:
        pihole:
          ansible_host: 192.168.100.99  # Must match .env.yaml ssh_host
          ansible_user: your_username    # Must match .env.yaml ssh_user
          ansible_ssh_pass: "{{ pihole.ssh_password }}"
          ansible_become_pass: "{{ pihole.ssh_password }}"
```

### 4. Test Connection
```bash
export ANSIBLE_CONFIG_IGNORE_WORLD_WRITABLE=True
ansible pihole -i inventory/hosts.yml --extra-vars "@.env.yaml" -m ping
```

Expected output:
```
pihole | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

### 5. Deploy Pi-hole

**Option A: Using the deployment script (recommended)**
```bash
./deploy-modern-pihole.sh
```

**Option B: Using Ansible directly**
```bash
export ANSIBLE_CONFIG_IGNORE_WORLD_WRITABLE=True
ansible-playbook -i inventory/hosts.yml playbooks/pihole.yml --extra-vars "@.env.yaml"
```

The deployment will:
1. ✅ Install Pi-hole v6+ with FTL
2. ✅ Configure DNS settings
3. ✅ Set up DHCP server (if enabled)
4. ✅ Configure blocklists (5+ default lists)
5. ✅ Set web admin password
6. ✅ Configure local DNS entries
7. ✅ Verify all services

### 6. Post-Deployment: Configure Static IP

**⚠️ IMPORTANT:** Pi-hole should have a static IP address.

**Recommended Method: Router-Based DHCP Reservation**

This is the safest method that won't cause network connectivity issues:

1. **Access your router's admin interface**
2. **Find DHCP Reservation/Static DHCP settings**
3. **Add a reservation:**
   - MAC Address: (find in router's client list)
   - Reserved IP: `192.168.100.99`
   - Description: "Pi-hole DNS Server"
4. **Reboot the Pi-hole server** to get the reserved IP

**Alternative Method: Server-Side Static IP (Advanced)**

Only use if you have physical/console access to the server:

```bash
# DO NOT run this remotely without console access
ansible-playbook -i inventory/hosts.yml set-static-ip.yml --extra-vars "@.env.yaml"
```

⚠️ **Warning:** This method can cause network connectivity loss if interrupted. Always have console access available.

### 7. Access Pi-hole

- **Web Interface:** http://192.168.100.99/admin/
- **Password:** Your configured `admin_password` from `.env.yaml`
- **Local DNS:** http://pihole.lan/admin/ (after DNS propagation)

### 8. Configure Your Network

**Option A: Router-Level DNS (Recommended)**
1. Access your router's admin interface
2. Set Primary DNS to: `192.168.100.99`
3. Set Secondary DNS to: `192.168.100.99` (or another DNS)
4. Save and reboot router if needed

**Option B: Device-Level DNS**
Configure each device to use `192.168.100.99` as DNS server.

## 🔧 Management & Maintenance

### Manage Blocklists, Whitelist, and Blacklist

Edit `.env.yaml` to add/remove domains:
```yaml
pihole:
  # Blocklists (URLs to blocklist files)
  blocklists:
    - "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
    - "https://your-custom-blocklist-url.com/hosts"
  
  # Whitelist (never block these domains)
  whitelist:
    - "github.com"
    - "microsoft.com"
    - "your-domain.com"
  
  # Blacklist (always block these domains)
  blacklist:
    - "ads.example.com"
    - "tracker.badsite.com"
```

Then run the list management playbook:
```bash
export ANSIBLE_CONFIG_IGNORE_WORLD_WRITABLE=True
ansible-playbook -i inventory/hosts.yml manage-lists.yml --extra-vars "@.env.yaml"
```

### Fix Authentication and DNS Issues

If you need to reconfigure web password or local DNS:
```bash
export ANSIBLE_CONFIG_IGNORE_WORLD_WRITABLE=True
ansible-playbook -i inventory/hosts.yml fix-auth-and-dns.yml --extra-vars "@.env.yaml"
```

### Check Pi-hole Status

```bash
# Via Ansible
export ANSIBLE_CONFIG_IGNORE_WORLD_WRITABLE=True
ansible pihole -i inventory/hosts.yml --extra-vars "@.env.yaml" -m shell -a "pihole status" -b

# Via SSH
ssh your_username@192.168.100.99
pihole status
```

### View Current Lists

```bash
# Blocklists
ansible pihole -i inventory/hosts.yml --extra-vars "@.env.yaml" -m shell -a "pihole adlist list" -b

# Whitelist
ansible pihole -i inventory/hosts.yml --extra-vars "@.env.yaml" -m shell -a "pihole allow -l" -b

# Blacklist
ansible pihole -i inventory/hosts.yml --extra-vars "@.env.yaml" -m shell -a "pihole deny -l" -b
```

## 📊 What Gets Deployed

### Pi-hole Configuration:
- **Version:** Pi-hole v6.2.2+ with FTL v6.3.3+
- **Web Interface:** Built-in FTL web server (port 80)
- **DNS Server:** Port 53 (UDP/TCP, IPv4/IPv6)
- **DHCP Server:** Port 67 (if enabled)

### Default Blocklists (5 lists):
1. StevenBlack hosts (~107,000 domains)
2. Badd-Boyz-Hosts
3. someonewhocares.org
4. AdGuard filters
5. pgl.yoyo.org

### Services:
- `pihole-FTL` - Main Pi-hole service
- DNS resolution on port 53
- Web interface on port 80
- DHCP server on port 67 (if enabled)

## 🔐 Security Best Practices

### 1. Use SSH Keys Instead of Passwords

Generate SSH key:
```bash
ssh-keygen -t ed25519 -C "pihole-access"
```

Copy to server:
```bash
ssh-copy-id your_username@192.168.100.99
```

Remove password from `.env.yaml`:
```yaml
pihole:
  ssh_user: "your_username"
  ssh_host: "192.168.100.99"
  # ssh_password: ""  # Remove or comment out
```

### 2. Strong Passwords

Use strong, unique passwords for:
- SSH/sudo access
- Pi-hole web admin interface

Generate strong passwords:
```bash
openssl rand -base64 32
```

### 3. Firewall Configuration

On the Pi-hole server:
```bash
# Allow SSH
sudo ufw allow 22/tcp

# Allow DNS
sudo ufw allow 53/tcp
sudo ufw allow 53/udp

# Allow HTTP (web interface)
sudo ufw allow 80/tcp

# Allow DHCP (if enabled)
sudo ufw allow 67/udp

# Enable firewall
sudo ufw enable
```

### 4. Keep .env.yaml Secure

- ✅ Never commit `.env.yaml` to git (already in .gitignore)
- ✅ Set proper file permissions: `chmod 600 .env.yaml`
- ✅ Store backups securely

## 🐛 Troubleshooting

### Connection Issues

**Problem:** Cannot connect to Pi-hole server
```bash
# Test network connectivity
ping 192.168.100.99

# Test SSH
ssh your_username@192.168.100.99

# Test Ansible
export ANSIBLE_CONFIG_IGNORE_WORLD_WRITABLE=True
ansible pihole -i inventory/hosts.yml --extra-vars "@.env.yaml" -m ping
```

### Web Interface Not Accessible

**Problem:** Cannot access http://192.168.100.99/admin/

```bash
# Check Pi-hole service
ssh your_username@192.168.100.99
sudo systemctl status pihole-FTL

# Restart if needed
sudo systemctl restart pihole-FTL

# Check if web server is listening
sudo ss -tlnp | grep :80
```

### No Authentication Challenge

**Problem:** Web interface doesn't ask for password

```bash
# Set password manually
ssh your_username@192.168.100.99
pihole setpassword 'your_password'

# Or use the fix playbook
ansible-playbook -i inventory/hosts.yml fix-auth-and-dns.yml --extra-vars "@.env.yaml"
```

### DNS Not Resolving

**Problem:** DNS queries not working

```bash
# Test DNS from Pi-hole server
ssh your_username@192.168.100.99
dig @localhost google.com

# Test DNS from another device
dig @192.168.100.99 google.com

# Check Pi-hole DNS status
pihole status
```

### Local DNS Not Working

**Problem:** pihole.lan doesn't resolve

```bash
# Check custom DNS configuration
ssh your_username@192.168.100.99
cat /etc/dnsmasq.d/05-pihole-custom-dns.conf

# Reload DNS
pihole reloaddns

# Test resolution
dig @192.168.100.99 pihole.lan
```

### Static IP Issues

**Problem:** Server lost connectivity after static IP configuration

**Solution:** Use router-based DHCP reservation instead:
1. Access router admin interface
2. Find Pi-hole server's MAC address in client list
3. Create DHCP reservation for that MAC → 192.168.100.99
4. Reboot Pi-hole server

### Lists Not Updating

**Problem:** Blocklists, whitelist, or blacklist not applying

```bash
# Run the list management playbook
export ANSIBLE_CONFIG_IGNORE_WORLD_WRITABLE=True
ansible-playbook -i inventory/hosts.yml manage-lists.yml --extra-vars "@.env.yaml"

# Manually update gravity
ssh your_username@192.168.100.99
pihole -g

# Check current lists
pihole adlist list
pihole allow -l
pihole deny -l
```

## 📚 Available Playbooks

| Playbook | Purpose | Usage |
|----------|---------|-------|
| `playbooks/pihole.yml` | Full Pi-hole deployment | `ansible-playbook -i inventory/hosts.yml playbooks/pihole.yml --extra-vars "@.env.yaml"` |
| `manage-lists.yml` | Update blocklists/whitelist/blacklist | `ansible-playbook -i inventory/hosts.yml manage-lists.yml --extra-vars "@.env.yaml"` |
| `fix-auth-and-dns.yml` | Fix web password and local DNS | `ansible-playbook -i inventory/hosts.yml fix-auth-and-dns.yml --extra-vars "@.env.yaml"` |
| `set-static-ip.yml` | Configure static IP (use with caution) | `ansible-playbook -i inventory/hosts.yml set-static-ip.yml --extra-vars "@.env.yaml"` |
| `update-pihole.yml` | Update Pi-hole to latest version | `ansible-playbook -i inventory/hosts.yml update-pihole.yml --extra-vars "@.env.yaml"` |
| `update-system.yml` | Update OS packages and security updates | `ansible-playbook -i inventory/hosts.yml update-system.yml --extra-vars "@.env.yaml"` |
| `update-all.yml` | Update both Pi-hole and OS | `ansible-playbook -i inventory/hosts.yml update-all.yml --extra-vars "@.env.yaml"` |

## 🔄 System Updates

### Update Pi-hole Only

Updates Pi-hole core, FTL, web interface, and gravity:
```bash
export ANSIBLE_CONFIG_IGNORE_WORLD_WRITABLE=True
ansible-playbook -i inventory/hosts.yml update-pihole.yml --extra-vars "@.env.yaml"
```

### Update Operating System Only

Updates all OS packages and security updates:
```bash
export ANSIBLE_CONFIG_IGNORE_WORLD_WRITABLE=True
ansible-playbook -i inventory/hosts.yml update-system.yml --extra-vars "@.env.yaml"
```

### Update Everything (Recommended Monthly)

Updates both Pi-hole and the OS in one go:
```bash
export ANSIBLE_CONFIG_IGNORE_WORLD_WRITABLE=True
ansible-playbook -i inventory/hosts.yml update-all.yml --extra-vars "@.env.yaml"
```

**Note:** If a system reboot is required (usually after kernel updates), the playbook will notify you. To reboot:
```bash
ansible pihole -i inventory/hosts.yml --extra-vars "@.env.yaml" -m reboot -b
```

## 🔄 Fresh Installation Guide

If you need to start over with a fresh OS installation:

### 1. Prepare Target Server
- Install Ubuntu 22.04+ or Debian-based OS
- Set up SSH access
- Note the IP address assigned by DHCP
- Ensure internet connectivity

### 2. Update Configuration
Edit `.env.yaml` and `inventory/hosts.yml` with the new IP address

### 3. Deploy
```bash
export ANSIBLE_CONFIG_IGNORE_WORLD_WRITABLE=True
ansible-playbook -i inventory/hosts.yml playbooks/pihole.yml --extra-vars "@.env.yaml"
```

### 4. Configure Static IP (Router Method)
- Access router admin interface
- Create DHCP reservation for Pi-hole's MAC address
- Reserve IP: 192.168.100.99
- Reboot Pi-hole server

### 5. Verify
```bash
# Test connectivity
ping 192.168.100.99

# Access web interface
open http://192.168.100.99/admin/

# Test DNS
dig @192.168.100.99 google.com
```

## 🎓 Learning Resources

- **[Pi-hole Documentation](https://docs.pi-hole.net/)** - Official Pi-hole docs
- **[Pi-hole FTL Documentation](https://ftl.pi-hole.net/)** - FTL configuration reference
- **[Ansible Documentation](https://docs.ansible.com/)** - Ansible automation guide
- **[Architecture.md](Architecture.md)** - Detailed technical implementation

## 📝 Project Structure

```
home-lab-setup/
├── .env.yaml                    # Your configuration (not in git)
├── .env.template.yaml           # Configuration template
├── inventory/
│   └── hosts.yml               # Ansible inventory
├── playbooks/
│   └── pihole.yml              # Main deployment playbook
├── roles/
│   └── pihole/
│       ├── tasks/
│       │   ├── install.yml     # Pi-hole installation
│       │   ├── configure.yml   # Configuration
│       │   ├── services.yml    # Service management
│       │   ├── network_clean.yml # Network settings
│       │   └── lists_api.yml   # List management
│       └── handlers/
│           └── main.yml        # Service handlers
├── manage-lists.yml            # List management playbook
├── fix-auth-and-dns.yml        # Fix authentication & DNS
├── set-static-ip.yml           # Static IP configuration
├── deploy-modern-pihole.sh     # Deployment script
└── README.md                   # This file
```

## 🤝 Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🆘 Support

- **Issues:** [GitHub Issues](https://github.com/aldrineeinsteen/home-lab-setup/issues)
- **Discussions:** [GitHub Discussions](https://github.com/aldrineeinsteen/home-lab-setup/discussions)
- **Documentation:** [Architecture.md](Architecture.md)

---

**Made with ❤️ for home lab enthusiasts**

*Last updated: 2025-11-14*