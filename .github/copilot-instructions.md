# Copilot Instructions

## Goal
Create an Ansible playbook to set up the home lab. Start by setting up Pi-hole using the configuration provided in `.env.sh`. Additionally, create a `.env.template.sh` file.

## Steps
1. **Create `.env.template.sh`**:
   - This file should serve as a template for `.env.sh`.
   - Include placeholders for all required environment variables.

2. **Create `.env.sh`**:
   - This file should be used to store the actual configuration values.
   - Ensure it is added to `.gitignore` to prevent sensitive data from being committed.

3. **Ansible Playbook**:
   - Write an Ansible playbook to automate the setup of Pi-hole.
   - Use the variables from `.env.sh` to configure Pi-hole.

4. **Testing**:
   - Test the playbook to ensure it works as expected.
   - Document any prerequisites or dependencies.

5. **Documentation**:
   - Update the `README.md` file with instructions on how to use the playbook.
   - Include steps for setting up `.env.sh` and running the playbook.


## GitHub Flow
1. Make sure create a new branch from `dev' for your changes - with a descriptive name under feature/bugfix/hotfix.
2. Commit your changes to your branch.
3. Push your branch to GitHub.
4. Open a Pull Request (PR) against the `dev` branch.
5. Once your PR is approved and passes all checks, it can be merged into `dev`.
6. After merging, and if need to create a release, make sure to set a release branch as `release/<version>`.
7. Finally, after testing in the release branch, merge it into `main` and create a tag for the release.
8. Pull the changes into dev to make it ready for next development cycle.

