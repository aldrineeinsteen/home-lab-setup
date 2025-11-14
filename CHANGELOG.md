# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed - 2025-11-14

#### Major Project Reorganization for Multi-Service Support

**Breaking Changes:**
- Reorganized project structure to support multiple Pi-based services
- All Pi-hole specific files moved to `services/pihole/` directory
- Updated all file paths and references

**New Structure:**
```
services/
└── pihole/
    ├── README.md                      # Pi-hole specific documentation
    ├── PIHOLE_FTL_CONFIG_REFERENCE.md
    ├── playbooks/                     # All Pi-hole playbooks
    │   ├── pihole.yml
    │   ├── update-pihole.yml
    │   ├── update-system.yml
    │   ├── update-all.yml
    │   ├── fix-auth-and-dns.yml
    │   └── set-static-ip.yml
    ├── roles/                         # Pi-hole Ansible role
    │   └── pihole/
    └── scripts/                       # Deployment scripts
        └── deploy-modern-pihole.sh
```

**Migration Guide:**

If you have existing scripts or commands, update them as follows:

| Old Path | New Path |
|----------|----------|
| `./deploy-modern-pihole.sh` | `./services/pihole/scripts/deploy-modern-pihole.sh` |
| `playbooks/pihole.yml` | `services/pihole/playbooks/pihole.yml` |
| `update-pihole.yml` | `services/pihole/playbooks/update-pihole.yml` |
| `update-system.yml` | `services/pihole/playbooks/update-system.yml` |
| `update-all.yml` | `services/pihole/playbooks/update-all.yml` |
| `fix-auth-and-dns.yml` | `services/pihole/playbooks/fix-auth-and-dns.yml` |
| `set-static-ip.yml` | `services/pihole/playbooks/set-static-ip.yml` |
| `roles/pihole/` | `services/pihole/roles/pihole/` |

**Updated Commands:**

Deploy Pi-hole:
```bash
# Old
./deploy-modern-pihole.sh

# New
./services/pihole/scripts/deploy-modern-pihole.sh
```

Run playbooks:
```bash
# Old
ansible-playbook -i inventory/hosts.yml playbooks/pihole.yml --extra-vars "@.env.yaml"

# New
ansible-playbook -i inventory/hosts.yml services/pihole/playbooks/pihole.yml --extra-vars "@.env.yaml"
```

**Files Removed:**
- `playbooks/setup-pihole.yml` - Obsolete, functionality in main playbook
- `add-lists.yml` - Temporary test file, functionality integrated
- `manage-lists.yml` - Standalone script, functionality in role

**Configuration Changes:**
- `ansible.cfg`: Updated `roles_path` to `services/pihole/roles`
- All documentation updated with new paths

**Benefits:**
- ✅ Clean separation of services
- ✅ Easier to add new Pi-based services (NAS, media servers, etc.)
- ✅ Better organization and maintainability
- ✅ Service-specific documentation
- ✅ Scalable structure for home lab growth

**No Breaking Changes to:**
- `.env.yaml` configuration format
- `inventory/hosts.yml` structure
- Ansible role functionality
- Pi-hole deployment process

## [1.0.0] - 2025-11-14

### Added
- Initial release with Pi-hole automation
- Modern Pi-hole v6+ FTL configuration
- Comprehensive blocklist management
- DHCP server configuration
- Static IP configuration
- System update playbooks
- Complete documentation

---

**Note:** This reorganization prepares the project for future expansion with additional Pi-based services while maintaining backward compatibility where possible.