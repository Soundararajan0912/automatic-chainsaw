# Ansible Maintenance Toolkit

This folder contains opinionated Ansible playbooks that handle host provisioning tasks across multiple Linux distributions (Ubuntu, CentOS, Amazon Linux 2023, RHEL). The playbooks are inventory-driven and rely on Ansible facts to figure out the right package manager commands per host.

## Layout

```
ansible/
├── ansible.cfg                 # Default configuration pointing to inventories/example/hosts.ini
├── group_vars/
│   └── all.yml                 # Package matrix, patching preferences, reboot timers
├── inventories/
│   └── example/hosts.ini       # Sample inventory you can copy and customize
└── playbooks/
    ├── install-packages.yml    # Installs nginx, docker, docker compose per distro
    ├── os-patch.yml            # Applies OS updates/patches per distro
    └── reboot-and-verify.yml   # Reboots hosts and confirms uptime changed
```

## Prerequisites

- Ansible 2.13+ with access to your target hosts over SSH.
- Python 3 on targets (set via `ansible_python_interpreter` in the inventory).
- Sudo privileges on each host (inventory already sets `ansible_become=true`).
- Package repositories enabled for Docker/Docker Compose on RHEL-family distributions.

## Usage

1. Copy the example inventory and update hostnames/IPs and SSH users:
   ```powershell
   cd "/home/ansible"
   copy inventories/example/hosts.ini inventories/prod/hosts.ini
   ```
   Then run playbooks with `-i inventories/prod/hosts.ini` or update `ansible.cfg`.

2. Install packages:
   ```bash
   ansible-playbook playbooks/install-packages.yml
   ```
   - Detects each host’s distribution and runs apt, yum, or dnf accordingly.
   - Installs `nginx`, `docker` (or `docker.io`), and the compose plugin/package.
   - Enables and starts the nginx/docker services.

3. Apply OS patches:
   ```bash
   ansible-playbook playbooks/os-patch.yml
   ```
   - Runs `apt dist-upgrade` on Debian/Ubuntu.
   - Runs `dnf/yum update` on Amazon Linux, CentOS, and RHEL.
   - Reports whether a reboot is required (based on `/var/run/reboot-required` on Debian/Ubuntu).

4. Reboot and verify:
   ```bash
   ansible-playbook playbooks/reboot-and-verify.yml
   ```
   - Captures `uptime -s` before/after reboot.
   - Uses `ansible.builtin.reboot` with a configurable 300-second post-reboot delay.
   - Fails the play if the boot timestamp did not change.

## Customization tips

- Adjust package names per distro in `group_vars/all.yml` if you rely on vendor repositories (e.g., `docker-ce`).
- Extend the inventory with groups (`[ubuntu]`, `[rhel]`, etc.) and limit playbook runs via `-l groupname`.
- Override reboot timers by defining `reboot_defaults` in group or host vars.
- Use Ansible tags if you want to run only parts of a playbook (e.g., add `tags: ['docker']` around package tasks).

## Safety notes

- Always test updates on a staging environment before running against production.
- Consider enabling `serial` execution or maintenance windows for critical fleets.
- Leverage Ansible Vault (or environment variables) for SSH key paths and sensitive inventory data.
