# Pi-hole FTL Configuration Reference

This document contains the correct `pihole-FTL --config` options for Pi-hole v6+.

## ✅ Verified Working FTL Config Options

### DNS Configuration
```bash
# DNS Upstream Servers (JSON array format required)
pihole-FTL --config dns.upstreams '["1.1.1.1","1.0.0.1"]'

# DNS Interface
pihole-FTL --config dns.interface eth0

# Query Logging
pihole-FTL --config dns.queryLogging true
```

### DHCP Configuration
```bash
# DHCP Active Status
pihole-FTL --config dhcp.active true

# DHCP IP Range
pihole-FTL --config dhcp.start 192.168.1.100
pihole-FTL --config dhcp.end 192.168.1.250

# DHCP Router/Gateway
pihole-FTL --config dhcp.router 192.168.1.1

# DHCP Domain
pihole-FTL --config dhcp.domain lan

# DHCP Lease Time
pihole-FTL --config dhcp.leaseTime 24h

# DHCP Logging
pihole-FTL --config dhcp.logging true

# Disable IPv6 DHCP
pihole-FTL --config dhcp.ipv6 false
```

### Privacy and Logging
```bash
# Privacy Level (correct option name)
pihole-FTL --config misc.privacylevel 0
```

### Conditional Forwarding (Modern Alternative to Custom DNSmasq)
```bash
# Enable conditional forwarding for local domains
pihole-FTL --config dns.conditionalForwarding true
pihole-FTL --config dns.conditionalForwarding.domain lan
pihole-FTL --config dns.conditionalForwarding.router 192.168.1.1

# Note: This replaces most need for custom dnsmasq configuration
```

### Custom DNSmasq Configuration (Legacy - Use Sparingly)
```bash
# Enable custom dnsmasq configuration loading (only if needed)
pihole-FTL --config misc.etc_dnsmasq_d true
```

## ❌ Invalid/Deprecated Options

### Web Server Configuration
```bash
# These options do NOT exist in Pi-hole FTL:
pihole-FTL --config webserver.interface    # INVALID
pihole-FTL --config webserver.port         # INVALID

# Web interface is managed by:
# - setupVars.conf (INSTALL_WEB_INTERFACE=true/false)
# - Pi-hole FTL built-in web server (automatic)
```

### Cache Configuration
```bash
# These options may not be available in all versions:
pihole-FTL --config dns.cache.size         # MAY NOT EXIST
pihole-FTL --config dns.cache.optimize     # MAY NOT EXIST

# Use setupVars.conf instead:
# CACHE_SIZE=10000
```

### API Configuration
```bash
# Incorrect option name:
pihole-FTL --config api.privacyLevel        # INVALID

# Correct option name:
pihole-FTL --config misc.privacylevel       # CORRECT
```

## 🔍 How to Check Available Options

To see all available FTL configuration options:

```bash
# Get help
pihole-FTL --help

# Try setting a non-existent option to see suggestions
pihole-FTL --config nonexistent.option

# Check current configuration
pihole-FTL --config dns.upstreams
pihole-FTL --config dhcp.active
```

## 📝 Best Practices

1. **Always test FTL config options** before using them in Ansible
2. **Use setupVars.conf as fallback** for options not available via FTL config
3. **Check Pi-hole version compatibility** - options may vary between versions
4. **Use JSON format for arrays** (e.g., DNS servers)
5. **Handle errors gracefully** with `failed_when: false` for experimental options

## 🚀 Hybrid Configuration Approach

For maximum compatibility, use a hybrid approach:

```yaml
# Try FTL config first
- name: Configure via FTL (preferred)
  command: pihole-FTL --config dns.upstreams '{{ dns_servers | to_json }}'
  register: ftl_result
  failed_when: false

# Fall back to setupVars.conf if needed
- name: Configure via setupVars.conf (fallback)
  lineinfile:
    path: /etc/pihole/setupVars.conf
    regexp: "^PIHOLE_DNS_1="
    line: "PIHOLE_DNS_1={{ dns_servers[0] }}"
  when: ftl_result.rc != 0
```

This ensures your configuration works across different Pi-hole versions.