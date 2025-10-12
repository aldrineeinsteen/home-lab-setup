# Copilot Instructions

## Goal
Create an Ansible playbook to set up the home lab with multiple machines and Raspberry Pi devices. Start by setting up Pi-hole using the configuration provided in `.env.yaml`. Additionally, create a `.env.template.yaml` file.

## Steps
1. **Create `.env.template.yaml`**:
   - This file should serve as a template for `.env.yaml`.
   - Include placeholders for all required environment variables.

2. **Create `.env.yaml`**:
   - This file should be used to store the actual configuration values.
   - Ensure it is added to `.gitignore` to prevent sensitive data from being committed.

3. **Ansible Playbook**:
   - Write an Ansible playbook to automate the setup of Pi-hole.
   - Use the variables from `.env.yaml` to configure Pi-hole.

4. **Testing**:
   - Test the playbook to ensure it works as expected.
   - Document any prerequisites or dependencies.

5. **Documentation**:
   - Update the `README.md` file with instructions on how to use the playbook.
   - Include steps for setting up `.env.yaml` and running the playbook.


## GitHub Flow
1. Make sure create a new branch from `dev' for your changes - with a descriptive name under feature/bugfix/hotfix.
2. Commit your changes to your branch.
3. Push your branch to GitHub.
4. Open a Pull Request (PR) against the `dev` branch.
5. Once your PR is approved and passes all checks, it can be merged into `dev`.
6. After merging, and if need to create a release, make sure to set a release branch as `release/<version>`.
7. Finally, after testing in the release branch, merge it into `main` and create a tag for the release.
8. Pull the changes into dev to make it ready for next development cycle.

## Notes
- Ensure that sensitive information is not hardcoded in the playbook or committed to the repository.
- Use best practices for Ansible playbook writing, including idempotency and clear variable naming.
- Consider adding error handling and logging for better troubleshooting.
- do not rename the machine to avoid ssh issues.
- Ensure the playbook is compatible with the target operating system with ubuntu 22.04 as a minimum.

## PiHole Configuration
- Use the official Pi-hole installation method via Ansible.
- Configure pi-hole dhcp configuration using https://discourse.pi-hole.net/t/dnsmasq-custom-configurations-in-v6/68469/3?utm_source=chatgpt.com
- Ensure that the web interface is enabled and accessible.
- Set up basic blocking lists and configure upstream DNS servers.
- Configure the admin password from the .env.sh file.
- Ensure that the Pi-hole service is set to start on boot.
- Maintain all blocklists and custom configurations in a separate file that can be easily updated.
- Maintain the lists - both adlists and whitelist/blacklist in separate files that can be easily updated (as a YAML list in the playbook or as separate text files).
- Ensure that the Pi-hole installation is idempotent, meaning running the playbook multiple times should not cause issues or duplicate installations.
- Ensure that the Pi-hole installation is secure, following best practices for security and access control.
- do not change the static IP as it is already setup in the machine.

## Agent instructions
- Use the `.env.sh` file to source environment variables in the playbook.
- Propose the plan and list of ToDos before starting the implementation.
- Before implementing propose the changes and get approval.
- Use wsl Ubuntu 22.04 as the base environment for ansible execution on windows machines (if applicable).

## Example `.env.template.yaml`
```yaml
pihole:
  admin_password: "your_admin_password"
  ssh_user: "your_ssh_user"
  ssh_host: "your_ssh_host" 
  ssh_password: "your_ssh_password"
  machine_ip: "your_machine_ip"
  dns_servers:
    - "1.1.1.1"
    - "1.0.0.1"
    blocklists:
      - "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
      - "https://raw.githubusercontent.com/mitchellkrogza/Badd-Boyz-Hosts/master/hosts" 
    whitelist:
      - "example.com"
    blacklist:
        - "ads.example.com"
    interface: "eth0"

using httpie:
aldrine@Aldrines-Laptop ~ % http --verify=no POST https://192.168.100.99:443/api/auth \
  accept:application/json \
  content-type:application/json \
  password=1uJ0rPRk
HTTP/1.1 200 OK
Access-Control-Allow-Headers: *
Access-Control-Allow-Methods: *
Cache-Control: no-cache, no-store, must-revalidate, private, max-age=0
Connection: keep-alive
Content-Length: 174
Content-Security-Policy: default-src 'self' 'unsafe-inline';
Content-Type: application/json; charset=utf-8
Date: Sun, 12 Oct 2025 13:01:36 GMT
Expires: 0
Pragma: no-cache
Referrer-Policy: strict-origin-when-cross-origin
Set-Cookie: sid=jWWzjV7toKh6sKLX02YarA=; SameSite=Lax; Path=/; Max-Age=1800; HttpOnly
X-Content-Type-Options: nosniff
X-DNS-Prefetch-Control: off
X-Frame-Options: DENY
X-XSS-Protection: 0

{
    "session": {
        "csrf": "mwqi7dkJTrmorAnU9VglMg=",
        "message": "password correct",
        "sid": "jWWzjV7toKh6sKLX02YarA=",
        "totp": false,
        "valid": true,
        "validity": 1800
    },
    "took": 0.300417423248291
}


aldrine@Aldrines-Laptop ~ % http --verify=no GET https://192.168.100.99:443/api/lists \
  Cookie:"SID=jWWzjV7toKh6sKLX02YarA=" \
  accept:application/json
HTTP/1.1 401 Unauthorized
Cache-Control: no-cache, no-store, must-revalidate, private, max-age=0
Connection: keep-alive
Content-Length: 97
Content-Security-Policy: default-src 'self' 'unsafe-inline';
Content-Type: application/json; charset=utf-8
Date: Sun, 12 Oct 2025 13:01:55 GMT
Expires: 0
Pragma: no-cache
Referrer-Policy: strict-origin-when-cross-origin
X-Content-Type-Options: nosniff
X-DNS-Prefetch-Control: off
X-Frame-Options: DENY
X-XSS-Protection: 0

{
    "error": {
        "hint": null,
        "key": "unauthorized",
        "message": "Unauthorized"
    },
    "took": 0.000102996826171875
}


aldrine@Aldrines-Laptop ~ % http --verify=no GET https://192.168.100.99:443/api/lists \
  Cookie:"SID=jWWzjV7toKh6sKLX02YarA=" \
  X-CSRF-Token:mwqi7dkJTrmorAnU9VglMg= \
  accept:application/json
HTTP/1.1 200 OK
Cache-Control: no-cache, no-store, must-revalidate, private, max-age=0
Connection: keep-alive
Content-Length: 3669
Content-Security-Policy: default-src 'self' 'unsafe-inline';
Content-Type: application/json; charset=utf-8
Date: Sun, 12 Oct 2025 13:02:22 GMT
Expires: 0
Pragma: no-cache
Referrer-Policy: strict-origin-when-cross-origin
Set-Cookie: sid=jWWzjV7toKh6sKLX02YarA=; SameSite=Lax; Path=/; Max-Age=1800; HttpOnly
X-Content-Type-Options: nosniff
X-DNS-Prefetch-Control: off
X-Frame-Options: DENY
X-XSS-Protection: 0

{
    "lists": [
        {
            "abp_entries": 0,
            "address": "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts",
            "comment": "Migrated from /etc/pihole/adlists.list",
            "date_added": 1760259986,
            "date_modified": 1760259986,
            "date_updated": 1760259987,
            "enabled": true,
            "groups": [
                0
            ],
            "id": 1,
            "invalid_domains": 1,
            "number": 79876,
            "status": 2,
            "type": "block"
        },
        {
            "abp_entries": 0,
            "address": "https://raw.githubusercontent.com/mitchellkrogza/Badd-Boyz-Hosts/master/hosts",
            "comment": "Added via Ansible automation",
            "date_added": 1760272403,
            "date_modified": 1760272403,
            "date_updated": 1760272902,
            "enabled": true,
            "groups": [
                0
            ],
            "id": 2,
            "invalid_domains": 0,
            "number": 1384,
            "status": 1,
            "type": "block"
        },
        {
            "abp_entries": 0,
            "address": "https://someonewhocares.org/hosts/zero/hosts",
            "comment": "Added via Ansible automation",
            "date_added": 1760272404,
            "date_modified": 1760272404,
            "date_updated": 1760272902,
            "enabled": true,
            "groups": [
                0
            ],
            "id": 3,
            "invalid_domains": 2,
            "number": 11807,
            "status": 1,
            "type": "block"
        },
        {
            "abp_entries": 266,
            "address": "https://raw.githubusercontent.com/AdguardTeam/AdguardFilters/master/BaseFilter/sections/adservers.txt",
            "comment": "Added via Ansible automation",
            "date_added": 1760272406,
            "date_modified": 1760272406,
            "date_updated": 1760272903,
            "enabled": true,
            "groups": [
                0
            ],
            "id": 4,
            "invalid_domains": 550,
            "number": 266,
            "status": 1,
            "type": "block"
        },
        {
            "abp_entries": 0,
            "address": "https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=0&mimetype=plaintext",
            "comment": "Added via Ansible automation",
            "date_added": 1760272408,
            "date_modified": 1760272408,
            "date_updated": 1760272903,
            "enabled": true,
            "groups": [
                0
            ],
            "id": 5,
            "invalid_domains": 0,
            "number": 3438,
            "status": 1,
            "type": "block"
        },
        {
            "abp_entries": 0,
            "address": "example.com",
            "comment": "Whitelisted via Ansible automation",
            "date_added": 1760272409,
            "date_modified": 1760272409,
            "date_updated": 0,
            "enabled": true,
            "groups": [
                0
            ],
            "id": 6,
            "invalid_domains": 0,
            "number": 0,
            "status": 4,
            "type": "allow"
        },
        {
            "abp_entries": 0,
            "address": "github.com",
            "comment": "Whitelisted via Ansible automation",
            "date_added": 1760272411,
            "date_modified": 1760272411,
            "date_updated": 0,
            "enabled": true,
            "groups": [
                0
            ],
            "id": 7,
            "invalid_domains": 0,
            "number": 0,
            "status": 4,
            "type": "allow"
        },
        {
            "abp_entries": 0,
            "address": "microsoft.com",
            "comment": "Whitelisted via Ansible automation",
            "date_added": 1760272412,
            "date_modified": 1760272412,
            "date_updated": 0,
            "enabled": true,
            "groups": [
                0
            ],
            "id": 8,
            "invalid_domains": 0,
            "number": 0,
            "status": 4,
            "type": "allow"
        },
        {
            "abp_entries": 0,
            "address": "apple.com",
            "comment": "Whitelisted via Ansible automation",
            "date_added": 1760272414,
            "date_modified": 1760272414,
            "date_updated": 0,
            "enabled": true,
            "groups": [
                0
            ],
            "id": 9,
            "invalid_domains": 0,
            "number": 0,
            "status": 4,
            "type": "allow"
        },
        {
            "abp_entries": 0,
            "address": "google.com",
            "comment": "Whitelisted via Ansible automation",
            "date_added": 1760272415,
            "date_modified": 1760272415,
            "date_updated": 0,
            "enabled": true,
            "groups": [
                0
            ],
            "id": 10,
            "invalid_domains": 0,
            "number": 0,
            "status": 4,
            "type": "allow"
        },
        {
            "abp_entries": 0,
            "address": "ads.example.com",
            "comment": "Blacklisted via Ansible automation",
            "date_added": 1760272417,
            "date_modified": 1760272417,
            "date_updated": 0,
            "enabled": true,
            "groups": [
                0
            ],
            "id": 11,
            "invalid_domains": 0,
            "number": 0,
            "status": 4,
            "type": "block"
        },
        {
            "abp_entries": 0,
            "address": "tracker.example.com",
            "comment": "Blacklisted via Ansible automation",
            "date_added": 1760272419,
            "date_modified": 1760272419,
            "date_updated": 0,
            "enabled": true,
            "groups": [
                0
            ],
            "id": 12,
            "invalid_domains": 0,
            "number": 0,
            "status": 4,
            "type": "block"
        },
        {
            "abp_entries": 0,
            "address": "analytics.badsite.com",
            "comment": "Blacklisted via Ansible automation",
            "date_added": 1760272421,
            "date_modified": 1760272421,
            "date_updated": 0,
            "enabled": true,
            "groups": [
                0
            ],
            "id": 13,
            "invalid_domains": 0,
            "number": 0,
            "status": 4,
            "type": "block"
        }
    ],
    "took": 0.000586986541748047
}


aldrine@Aldrines-Laptop ~ % 
