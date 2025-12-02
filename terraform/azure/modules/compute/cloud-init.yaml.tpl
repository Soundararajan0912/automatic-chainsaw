#cloud-config
package_update: false
package_upgrade: false
write_files:
  - path: /etc/nginx/conf.d/${nginx_server_name}
    owner: root:root
    permissions: '0644'
    content: |
      server {
              listen 80 default_server;
              listen [::]:80 default_server;

              root /var/www/html;

              index index.html index.htm index.nginx-debian.html;

              server_name ${nginx_server_name};

              location / {
                      try_files $uri $uri/ =404;
                      #auth_basic "Restricted Content";
                      #auth_basic_user_file /etc/nginx/.htpasswd;
              }
      }
  - path: /usr/local/bin/chainsaw-bootstrap.sh
    owner: root:root
    permissions: '0755'
    content: |
      #!/bin/bash
      LOG="/home/${admin_username}/chainsaw-deploy.log"
      touch "$${LOG}"
      chown ${admin_username}:${admin_username} "$${LOG}"
      exec >>"$${LOG}" 2>&1
      set -euo pipefail

      wait_for_apt() {
        while fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1 || \
              fuser /var/lib/apt/lists/lock >/dev/null 2>&1; do
          echo "Waiting for apt locks to be released..."
          sleep 5
        done
      }

      install_packages_with_retry() {
        local attempts=0
        local packages="nginx docker.io certbot python3-certbot-nginx git"
        while true; do
          wait_for_apt
          export DEBIAN_FRONTEND=noninteractive
          if apt-get update; then
            wait_for_apt
            if apt-get install -y $${packages}; then
              break
            fi
          fi
          attempts=$((attempts + 1))
          if [ $attempts -ge 5 ]; then
            echo "Package installation failed after $attempts attempts."
            return 1
          fi
          dpkg --configure -a || true
          apt-get install -f -y || true
          sleep 15
        done
      }

      install_azure_cli_with_retry() {
        local attempts=0
        while true; do
          wait_for_apt
          if curl -sL https://aka.ms/InstallAzureCLIDeb | bash; then
            break
          fi
          attempts=$((attempts + 1))
          if [ $attempts -ge 5 ]; then
            echo "Azure CLI installation failed after $attempts attempts."
            return 1
          fi
          dpkg --configure -a || true
          apt-get install -f -y || true
          sleep 15
        done
      }

      install_docker_compose() {
        local version="v2.24.7"
        local arch="$(uname -m)"
        case "$${arch}" in
          x86_64|amd64)
            arch="x86_64"
            ;;
          aarch64|arm64)
            arch="aarch64"
            ;;
          armv7l|armhf)
            arch="armv7"
            ;;
          *)
            arch="x86_64"
            ;;
        esac
        local plugin_dir="/usr/local/lib/docker/cli-plugins"
        mkdir -p "$${plugin_dir}"
        curl -sSL "https://github.com/docker/compose/releases/download/$${version}/docker-compose-linux-$${arch}" -o "$${plugin_dir}/docker-compose"
        chmod +x "$${plugin_dir}/docker-compose"
        ln -sf "$${plugin_dir}/docker-compose" /usr/local/bin/docker-compose
      }

      install_packages_with_retry
      install_docker_compose
      install_azure_cli_with_retry

      usermod -aG docker ${admin_username}
      systemctl enable docker
      systemctl start docker
      systemctl enable nginx
      systemctl restart nginx

      nginx -t
      systemctl reload nginx || true

      mkdir -p /opt
      rm -rf /opt/automatic-chainsaw
      git clone https://github.com/Soundararajan0912/automatic-chainsaw /opt/automatic-chainsaw
      cd /opt/automatic-chainsaw
      git checkout main

      COMPOSE_CMD="docker compose"
      if ! docker compose version >/dev/null 2>&1; then
        if command -v docker-compose >/dev/null 2>&1; then
          COMPOSE_CMD="docker-compose"
        else
          echo "Docker Compose is unavailable; aborting deployment."
          exit 1
        fi
      fi

      cd /opt/automatic-chainsaw/docker-compose/unified-docker-compose
      $COMPOSE_CMD pull || true
      $COMPOSE_CMD up -d
runcmd:
  - [ bash, /usr/local/bin/chainsaw-bootstrap.sh ]
