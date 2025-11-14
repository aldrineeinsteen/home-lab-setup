# Pi-hole Service

Complete Ansible automation for deploying and managing Pi-hole DNS ad-blocker with DHCP server capabilities.

## 📁 Directory Structure

```
services/pihole/
├── README.md                           # This file
├── PIHOLE_FTL_CONFIG_REFERENCE.md     # Pi-hole FTL configuration reference
├── playbooks/                          # Ansible playbooks
│   ├── pihole.yml                     # Main deployment playbook
│   ├── update-pihole.yml              # Update Pi-hole only
│   ├── update-system.yml              # Update OS only
│   ├── update-all.yml                 # Update both Pi-hole and OS
│   ├── fix-auth-and-dns.yml           # Fix authentication and DNS
│   └── set-static-ip.yml              # Configure static IP
├── roles/                              # Ansible roles
│   └── pihole/                        # Pi-hole role
│       ├── tasks/                     # Task files
│       └── handlers/                  # Handler files
└── scripts/                            # Deployment scripts
    └── deploy-modern-pihole.sh        # Main deployment script
```

## 🚀 Quick Start

### 1. Configure Environment

From the project root, copy and edit the environment file:
```bash
cp .env.template.yaml .env.yaml
nano .env.yaml
```

### 2. Deploy Pi-hole

**Option A: Using the deployment script (recommended)**
```bash
./services/pihole/scripts/deploy-modern-pihole.sh
```

**Option B: Using Ansible directly**
```bash
export ANSIBLE_CONFIG_IGNORE_WORLD_WRITABLE=True
ansible-playbook -i inventory/hosts.yml services/pihole/playbooks/pihole.yml --extra-vars "@.env.yaml"
```

## 🔧 Management Commands

### Update Pi-hole
```bash
ansible-playbook -i inventory/hosts.yml services/pihole/playbooks/update-pihole.yml --extra-vars "@.env.yaml"
```

### Update Operating System
```bash
ansible-playbook -i inventory/hosts.yml services/pihole/playbooks/update-system.yml --extra-vars "@.env.yaml"
```

### Update Everything
```bash
ansible-playbook -i inventory/hosts.yml services/pihole/playbooks/update-all.yml --extra-vars "@.env.yaml"
```

### Fix Authentication and DNS
```bash
ansible-playbook -i inventory/hosts.yml services/pihole/playbooks/fix-auth-and-dns.yml --extra-vars "@.env.yaml"
```

### Configure Static IP
```bash
ansible-playbook -i inventory/hosts.yml services/pihole/playbooks/set-static-ip.yml --extra-vars "@.env.yaml"
```

### Manage Lists Only
```bash
ansible-playbook -i inventory/hosts.yml services/pihole/playbooks/pihole.yml --extra-vars "@.env.yaml" --tags lists
```

## 📚 Documentation

For complete documentation, see the main [README.md](../../README.md) in the project root.

## 🎯 Features

- ✅ Automated Pi-hole v6+ deployment with modern FTL configuration
- ✅ Web interface authentication with password protection
- ✅ Custom DNS entries for local domain resolution
- ✅ Blocklist management (5+ default lists included)
- ✅ Whitelist/Blacklist domain management
- ✅ Regex pattern support for advanced blocking/allowing
- ✅ DHCP server configuration
- ✅ Static IP configuration
- ✅ Idempotent playbooks - safe to run multiple times

## 🔐 Security

- Never commit `.env.yaml` to git
- Use SSH keys instead of passwords when possible
- Keep Pi-hole and OS updated regularly
- Use strong passwords for web interface

---

**Part of the Home Lab Setup project**