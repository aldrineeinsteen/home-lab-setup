#!/bin/bash
# Pi-hole DHCP Testing Script
# This script helps test DHCP functionality after deployment

echo "======================================================"
echo "Pi-hole DHCP Functionality Test"
echo "======================================================"
echo "Date: $(date)"
echo

# Check if .env.yaml exists
if [ ! -f ".env.yaml" ]; then
    echo "❌ ERROR: .env.yaml file not found"
    echo "Please create .env.yaml from .env.template.yaml"
    exit 1
fi

# Extract Pi-hole IP from .env.yaml
PIHOLE_IP=$(grep -A 10 "pihole:" .env.yaml | grep "ssh_host:" | awk '{print $2}' | tr -d '"')

if [ -z "$PIHOLE_IP" ]; then
    echo "❌ ERROR: Could not find Pi-hole IP in .env.yaml"
    exit 1
fi

echo "🔍 Testing Pi-hole at: $PIHOLE_IP"
echo

# Test 1: Pi-hole web interface
echo "1. Testing Pi-hole web interface..."
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "http://$PIHOLE_IP/admin/" 2>/dev/null)
if [ "$HTTP_STATUS" = "200" ]; then
    echo "   ✅ Web interface accessible at http://$PIHOLE_IP/admin/"
else
    echo "   ❌ Web interface not accessible (HTTP $HTTP_STATUS)"
fi
echo

# Test 2: DNS resolution
echo "2. Testing DNS resolution..."
DNS_TEST=$(dig @$PIHOLE_IP google.com +short 2>/dev/null | head -1)
if [ -n "$DNS_TEST" ]; then
    echo "   ✅ DNS resolution working (google.com -> $DNS_TEST)"
else
    echo "   ❌ DNS resolution failed"
fi
echo

# Test 3: Ad blocking
echo "3. Testing ad blocking..."
BLOCK_TEST=$(dig @$PIHOLE_IP doubleclick.net +short 2>/dev/null)
if echo "$BLOCK_TEST" | grep -q "0.0.0.0\|127.0.0.1"; then
    echo "   ✅ Ad blocking working (doubleclick.net blocked)"
else
    echo "   ❌ Ad blocking not working or domain not in blocklist"
fi
echo

# Test 4: DHCP configuration (requires SSH access)
echo "4. Testing DHCP configuration..."
echo "   To test DHCP, run the following command on your Pi-hole server:"
echo "   sudo /usr/local/bin/pihole-dhcp-check"
echo
echo "   Or check DHCP settings manually:"
echo "   grep DHCP /etc/pihole/setupVars.conf"
echo

# Test 5: Instructions for DHCP testing
echo "5. DHCP Functionality Testing Instructions:"
echo "   ======================================================"
echo "   To test DHCP functionality:"
echo
echo "   Method 1 - Check current DHCP status:"
echo "     ssh pi@$PIHOLE_IP"
echo "     sudo /usr/local/bin/pihole-dhcp-check"
echo
echo "   Method 2 - Test with a device:"
echo "     1. Connect a device to your network"
echo "     2. Release and renew IP address:"
echo "        - Windows: ipconfig /release && ipconfig /renew"
echo "        - Linux/Mac: sudo dhclient -r && sudo dhclient"
echo "     3. Check if device got IP from Pi-hole DHCP range"
echo "     4. Verify DNS is set to Pi-hole ($PIHOLE_IP)"
echo
echo "   Method 3 - Check DHCP leases:"
echo "     ssh pi@$PIHOLE_IP"
echo "     cat /etc/pihole/dhcp.leases"
echo
echo "   DHCP Configuration Summary:"
echo "   - DHCP Server: Pi-hole FTL (no separate lighttpd/dnsmasq needed)"
echo "   - Web Interface: http://$PIHOLE_IP/admin/"
echo "   - Check Settings > DHCP tab in web interface"
echo

echo "======================================================"
echo "Test completed. Check results above."
echo "For issues, see Architecture.md for troubleshooting."
echo "======================================================"