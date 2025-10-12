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
