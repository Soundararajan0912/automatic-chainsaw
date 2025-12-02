# Manual Bootstrap Script

If cloud-init fails or you need to reprovision a VM interactively, you can run `scripts/manual-bootstrap.sh` directly on the Ubuntu host to install nginx, Docker, Docker Compose, Certbot, the Azure CLI, and to deploy the `automatic-chainsaw` stack.

## Prerequisites

- Ubuntu 24.04 (or similar) VM with sudo privileges.
- Outbound internet access to GitHub and the Ubuntu/Canonical apt mirrors.
- `curl` and `git` preinstalled (Cloud Shell and Ubuntu images already include them).

## Usage

1. Copy the script to the VM (Cloud Shell example):
   ```bash
   az storage blob download --account-name <acct> --container-name <container> --name manual-bootstrap.sh --file manual-bootstrap.sh
   ```
   or use `scp` directly from your workstation.

2. Make the script executable and run it with sudo. Optionally pass the nginx server name as the first argument, or set environment variables:
   ```bash
   chmod +x manual-bootstrap.sh
   sudo ADMIN_USERNAME=soundar-rnd-02 NGINX_SERVER_NAME=dev.example.com ./manual-bootstrap.sh
   ```
   - `ADMIN_USERNAME` defaults to the current sudo user if not provided.
   - `NGINX_SERVER_NAME` defaults to `dev.example.com` if no argument is supplied.

3. Review the log at `/home/<admin>/chainsaw-manual-bootstrap.log` for progress and troubleshooting.

## What the script does

- Waits for apt locks, updates package lists, and installs `nginx`, `docker.io`, `certbot`, `python3-certbot-nginx`, and `git` with retry logic.
- Installs the Azure CLI and Docker Compose CLI plugin.
- Configures nginx with the provided `server_name`.
- Enables and restarts `docker` and `nginx` services.
- Clones `https://github.com/Soundararajan0912/automatic-chainsaw`, checks out `main`, and runs `docker compose up -d` in `docker-compose/unified-docker-compose`.

Use this script anytime cloud-init fails or when you need to run the bootstrap manually without redeploying the VM.