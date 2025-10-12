# Home Lab Setup - Technical Architecture

This document provides detailed technical information about the home lab setup implementation, architecture decisions, and advanced configuration options.

## 🏗️ Architecture Overview

### System Components

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  Control Node   │    │   Target Node   │    │  Network Clients│
│                 │    │                 │    │                 │
│  ┌───────────┐  │    │  ┌───────────┐  │    │  ┌───────────┐  │
│  │  Ansible  │  │───▶│  │  Pi-hole  │  │◀───│  │  Devices  │  │
│  │           │  │    │  │           │  │    │  │           │  │
│  │ WSL2/Linux│  │    │  │ Ubuntu    │  │    │  │ DNS Queries│  │
│  └───────────┘  │    │  └───────────┘  │    │  └───────────┘  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
     SSH/Ansible            Pi-hole Services         DNS Resolution
```

### Data Flow

1. **Configuration**: `.env.yaml` → Ansible Variables → Target Configuration
2. **Deployment**: Ansible → SSH → Target Machine → Pi-hole Installation
3. **DNS Resolution**: Client → Pi-hole → Upstream DNS/Block Lists
4. **Management**: Web Interface → Pi-hole Admin → Configuration Changes

## 📁 Detailed Project Structure

```
home-lab-setup/
├── .env.template.yaml          # Configuration template with examples
├── .env.yaml                   # User configuration (git-ignored)
├── .gitignore                  # Excludes sensitive files
├── ansible.cfg                 # Ansible behavior configuration
├── requirements.yml            # External Ansible collections
├── LICENSE                     # MIT license
├── README.md                   # Quick start guide
├── Architecture.md             # This technical documentation
│
├── inventory/
│   └── hosts.yml              # Target machine definitions and variables
│
├── playbooks/
│   └── pihole.yml             # Main deployment orchestration
│
└── roles/
    └── pihole/                # Pi-hole deployment role
        ├── tasks/
        │   ├── main.yml       # Task orchestration and inclusion
        │   ├── install.yml    # Pi-hole installation logic
        │   ├── configure.yml  # Post-installation configuration
        │   ├── blocklists.yml # Ad-blocking list management
        │   ├── network.yml    # Network and DNS configuration
        │   └── services.yml   # Service management and monitoring
        ├── templates/
        │   └── setupVars.conf.j2  # Pi-hole configuration template
        └── handlers/
            └── main.yml       # Service restart and reload handlers
```

## 🔧 Technical Implementation Details

### Configuration Management

#### Environment Variables (`.env.yaml`)
```yaml
pihole:
  # Connection Configuration
  ssh_user: "username"           # SSH authentication user
  ssh_host: "192.168.1.100"     # Target machine IP/hostname
  ssh_password: "password"       # SSH password (prefer keys)
  
  # Pi-hole Core Settings
  admin_password: "secure_pass"  # Web interface password
  machine_ip: "192.168.1.100"   # Static IP configuration
  interface: "eth0"              # Network interface binding
  
  # DNS Resolution Chain
  dns_servers:                   # Upstream DNS servers
    - "1.1.1.1"                 # Primary (Cloudflare)
    - "1.0.0.1"                 # Secondary (Cloudflare)
    - "8.8.8.8"                 # Fallback (Google)
  
  # Web Interface Configuration
  web_interface: true            # Enable/disable web UI
  web_port: 80                   # HTTP port for web interface
  
  # DHCP Server Configuration
  dhcp:
    enabled: false               # DHCP server activation
    start_ip: "192.168.1.10"    # DHCP range start
    end_ip: "192.168.1.100"     # DHCP range end
    router_ip: "192.168.1.1"    # Default gateway
    lease_time: "24h"           # IP lease duration
  
  # Network Domain Configuration
  network:
    postfix: "lan"              # Local domain suffix (.lan)
  
  # Custom DNS Records
  custom_dns:
    - domain: "homelab.lan"     # Local service hostnames
      ip: "192.168.1.100"
    - domain: "nas.lan"
      ip: "192.168.1.150"
  
  # Ad-Blocking Configuration
  blocklists:                   # Ad-blocking sources
    - "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
    - "https://someonewhocares.org/hosts/zero/hosts"
  
  whitelist:                    # Never block these domains
    - "github.com"
    - "microsoft.com"
  
  blacklist:                    # Always block these domains
    - "ads.badsite.com"
    - "tracker.evil.com"
  
  regex_blacklist:              # Pattern-based blocking
    - "^(.+[-_.])??adse?rv(er?|ice)?s?[0-9]*[-.]"
```

### Ansible Role Architecture

#### Task Organization
- **`main.yml`**: Task orchestration and flow control
- **`install.yml`**: Pi-hole installation with official installer
- **`configure.yml`**: Post-installation configuration management
- **`blocklists.yml`**: Ad-blocking list management and updates
- **`network.yml`**: Network domain and DNS record configuration
- **`services.yml`**: System service management and monitoring

#### Configuration Templates
- **`setupVars.conf.j2`**: Pi-hole installation configuration template
- Jinja2 templating for dynamic configuration generation
- Support for conditional configuration based on Pi-hole version

#### Event Handlers
- **Service Restart**: `restart pihole-FTL` (lighttpd not needed - FTL provides built-in web server)
- **Configuration Reload**: `update pihole lists`, `update gravity`
- **Conditional Execution**: Only trigger when configuration changes

### Pi-hole Version Compatibility

#### Version Detection
```yaml
- name: Check Pi-hole version
  command: pihole version --short
  register: pihole_version_check

- name: Set version facts
  set_fact:
    is_pihole_v6: "{{ pihole_version_check.stdout is version('6.0', '>=') }}"
```

#### Configuration Method Selection

**Pi-hole v5 and Older:**
- Uses `setupVars.conf` for all configuration
- DHCP settings in setupVars.conf
- Custom dnsmasq files loaded automatically

**Pi-hole v6 and Newer:**
- Enables custom dnsmasq loading: `misc.etc_dnsmasq_d = true`
- DHCP configuration via `/etc/dnsmasq.d/04-pihole-dhcp.conf`
- Enhanced configuration validation

### Network Configuration

#### Local Domain Resolution
```bash
# dnsmasq configuration for local domains
domain=lan                      # Set local domain
expand-hosts                    # Expand hostnames with domain
local=/lan/                     # Handle .lan queries locally
domain-needed                   # Require domain for resolution
bogus-priv                      # Block private IP reverse lookups
```

#### DHCP Configuration (Pi-hole v6+)
```bash
# DHCP server configuration
dhcp-range=192.168.1.10,192.168.1.100,12h  # IP range and lease time
dhcp-option=3,192.168.1.1                   # Default gateway
dhcp-option=6,192.168.1.100                 # DNS server (Pi-hole)
dhcp-option=15,lan                          # Domain name
dhcp-authoritative                          # Authoritative DHCP server
log-dhcp                                    # Log DHCP transactions
```

### Security Implementation

#### Credential Management
- Environment variables isolated in `.env.yaml`
- Git exclusion via `.gitignore`
- SSH key authentication support
- Password-less sudo configuration

#### Network Security
- Interface binding configuration
- Firewall-aware deployment
- Service isolation and monitoring
- Log rotation and management

### Idempotency Design

#### State Management
- File existence checks before creation
- Configuration comparison before updates
- Service status verification before restarts
- Backup creation before modifications

#### Change Detection
```yaml
- name: Configure DNS servers
  lineinfile:
    path: /etc/pihole/setupVars.conf
    regexp: "^PIHOLE_DNS_{{ item.0 + 1 }}="
    line: "PIHOLE_DNS_{{ item.0 + 1 }}={{ item.1 }}"
  loop: "{{ dns_servers | zip(range(dns_servers|length)) | list }}"
  notify: restart pihole-FTL
```

## 🔍 Advanced Configuration Options

### Custom Blocklist Management

#### Automated List Updates
```yaml
- name: Update gravity database
  command: pihole -g
  register: gravity_update
  changed_when: "'Pi-hole blocking is enabled' in gravity_update.stdout"
```

#### List Validation
- URL accessibility checks
- Format validation
- Conflict resolution
- Performance impact monitoring

### DHCP Advanced Configuration

#### Static Reservations
```yaml
# Add to custom dnsmasq configuration
dhcp-host=aa:bb:cc:dd:ee:ff,192.168.1.50,homeserver
dhcp-host=11:22:33:44:55:66,192.168.1.51,workstation
```

#### Network Segmentation
- VLAN support configuration
- Multiple DHCP ranges
- Per-device DNS settings
- Bandwidth limitations

### Monitoring and Alerting

#### Health Checks
```bash
#!/bin/bash
# Pi-hole health monitoring script
echo "=== Pi-hole Health Check ==="
systemctl is-active pihole-FTL
dig @localhost google.com +short > /dev/null && echo "DNS: OK" || echo "DNS: FAILED"
curl -f http://localhost/admin/api.php > /dev/null && echo "Web: OK" || echo "Web: FAILED"
```

#### Log Analysis
- Query pattern analysis
- Performance metrics collection
- Error rate monitoring
- Capacity planning data

### Performance Optimization

#### Memory Management
```yaml
# Pi-hole FTL configuration optimization
CACHE_SIZE=10000               # DNS cache size
MAXDBDAYS=365                  # Database retention
RESOLVE_IPV6=yes              # IPv6 resolution
RATE_LIMIT=1000/60/60         # Query rate limiting
```

#### Storage Optimization
- Log rotation configuration
- Database maintenance scheduling
- Backup automation
- Archive management

## 🚀 Extension Architecture

### Service Integration Points

#### NAS Services Integration
```yaml
# Future NAS service configuration
nas:
  services:
    - samba
    - nfs
    - ftp
  storage:
    - /mnt/storage1
    - /mnt/storage2
```

#### Media Server Integration
```yaml
# Future media server configuration
media:
  plex:
    enabled: true
    port: 32400
  jellyfin:
    enabled: false
    port: 8096
```

#### Monitoring Stack Integration
```yaml
# Future monitoring configuration
monitoring:
  prometheus:
    enabled: true
    port: 9090
  grafana:
    enabled: true
    port: 3000
```

### Plugin Architecture
- Role-based service modules
- Shared variable inheritance
- Common handler patterns
- Unified configuration management

## 📊 Performance Considerations

### Resource Requirements

#### Minimum System Requirements
- **CPU**: 1 core, 1GHz ARM/x86
- **RAM**: 512MB minimum, 1GB recommended
- **Storage**: 2GB minimum, 8GB recommended
- **Network**: 100Mbps Ethernet recommended

#### Scaling Considerations
- DNS query capacity: ~10,000 queries/minute per core
- Blocklist size impact: ~1MB RAM per 100k domains
- Web interface responsiveness: <100ms response time
- Database growth: ~1MB per month per 1000 queries

### Network Performance
- DNS resolution latency: <50ms typical
- Upstream DNS failover: <5 second detection
- DHCP lease processing: <1 second per request
- Web interface loading: <2 seconds initial load

## 🔧 Troubleshooting Guide

### Diagnostic Commands

#### System Health
```bash
# Service status checks
sudo systemctl status pihole-FTL
# Note: lighttpd not used - Pi-hole FTL provides built-in web server

# Network connectivity
ping 1.1.1.1
dig @1.1.1.1 google.com

# Pi-hole specific diagnostics
pihole status
pihole -t                    # Tail logs
pihole -c -e                 # Statistics
```

#### Configuration Validation
```bash
# Verify dnsmasq configuration
sudo dnsmasq --test
sudo pihole restartdns

# Check file permissions
ls -la /etc/pihole/
ls -la /etc/dnsmasq.d/

# Validate custom configurations
cat /etc/pihole/custom.list
cat /etc/dnsmasq.d/*.conf
```

### Common Issue Resolution

#### DNS Resolution Failures
1. **Check upstream DNS servers**: Verify connectivity to configured upstream DNS
2. **Validate Pi-hole configuration**: Ensure setupVars.conf is correct
3. **Test local resolution**: Use `dig @localhost` for local testing
4. **Check network binding**: Verify interface configuration

#### Web Interface Issues
1. **Service status**: Ensure Pi-hole FTL service is running (built-in web server)
2. **Port accessibility**: Check firewall rules for port 80
3. **File permissions**: Verify Pi-hole web directory permissions
4. **FTL configuration**: Check Pi-hole FTL service status (no separate PHP/lighttpd needed)

#### DHCP Server Problems
1. **IP range conflicts**: Ensure no overlap with existing DHCP servers
2. **Authorization issues**: Check DHCP authoritative configuration
3. **Client connectivity**: Verify network interface binding
4. **Lease database**: Check DHCP lease file integrity
5. **Service validation**: Use `/usr/local/bin/pihole-dhcp-check` script for diagnostics
6. **Configuration verification**: Check both v5 (setupVars.conf) and v6+ (dnsmasq.d) configurations

## 📈 Maintenance Procedures

### Regular Maintenance Tasks

#### Weekly Tasks
- Gravity database update (`pihole -g`)
- Log file review and cleanup
- Performance metrics collection
- Security update checks

#### Monthly Tasks
- Blocklist effectiveness review
- Configuration backup creation
- System resource usage analysis
- Network performance testing

#### Quarterly Tasks
- Full system backup
- Configuration audit
- Security vulnerability assessment
- Capacity planning review

### Backup and Recovery

#### Configuration Backup
```bash
# Create configuration backup
sudo tar -czf pihole-backup-$(date +%Y%m%d).tar.gz \
  /etc/pihole/ \
  /etc/dnsmasq.d/ \
  /opt/pihole/ \
  /var/log/pihole/
```

#### Recovery Procedures
1. **Stop services**: `sudo systemctl stop pihole-FTL`
2. **Restore configuration**: Extract backup to original locations
3. **Fix permissions**: `sudo chown -R pihole:pihole /etc/pihole/`
4. **Restart services**: `sudo systemctl start pihole-FTL`
5. **Verify functionality**: Test DNS resolution and web interface

## 🎯 Best Practices

### Configuration Management
- Version control all configuration templates
- Use descriptive variable names
- Implement configuration validation
- Document all customizations

### Security Practices
- Regular security updates
- Strong authentication mechanisms
- Network access controls
- Audit log monitoring

### Performance Optimization
- Monitor resource utilization
- Optimize blocklist selection
- Implement query caching
- Regular performance testing

### Operational Excellence
- Automated monitoring
- Proactive maintenance
- Documentation updates
- Change management processes

---

This architecture document provides the technical foundation for understanding and extending the home lab setup. For quick start instructions, see [README.md](README.md).