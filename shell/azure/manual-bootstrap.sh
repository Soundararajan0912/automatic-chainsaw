#!/usr/bin/env bash
set -euo pipefail

ADMIN_USERNAME="${ADMIN_USERNAME:-${SUDO_USER:-${USER:-}}}"
if [[ -z "${ADMIN_USERNAME}" ]]; then
  echo "Unable to determine admin username. Set the ADMIN_USERNAME env var and retry." >&2
  exit 1
fi

NGINX_SERVER_NAME="${1:-${NGINX_SERVER_NAME:-dev.example.com}}"
LOG_FILE="/home/${ADMIN_USERNAME}/chainsaw-manual-bootstrap.log"
REPO_DIR="/opt/automatic-chainsaw"

mkdir -p "$(dirname "${LOG_FILE}")"
touch "${LOG_FILE}"
chown "${ADMIN_USERNAME}:${ADMIN_USERNAME}" "${LOG_FILE}"
chmod 0644 "${LOG_FILE}"
exec >>"${LOG_FILE}" 2>&1

echo "[INFO] Starting manual bootstrap at $(date --iso-8601=seconds)"

echo "[INFO] Using admin user: ${ADMIN_USERNAME}"
echo "[INFO] Using nginx server name: ${NGINX_SERVER_NAME}"

wait_for_apt() {
  while fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1 || \
        fuser /var/lib/apt/lists/lock >/dev/null 2>&1; do
    echo "[INFO] Waiting for apt locks to be released..."
    sleep 5
  done
}

install_packages_with_retry() {
  local attempts=0
  local packages=(nginx docker.io certbot python3-certbot-nginx git)
  while true; do
    wait_for_apt
    export DEBIAN_FRONTEND=noninteractive
    if apt-get update; then
      wait_for_apt
      if apt-get install -y "${packages[@]}"; then
        return 0
      fi
    fi
    attempts=$((attempts + 1))
    if [[ ${attempts} -ge 5 ]]; then
      echo "[ERROR] Package installation failed after ${attempts} attempts." >&2
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
      return 0
    fi
    attempts=$((attempts + 1))
    if [[ ${attempts} -ge 5 ]]; then
      echo "[ERROR] Azure CLI installation failed after ${attempts} attempts." >&2
      return 1
    fi
    dpkg --configure -a || true
    apt-get install -f -y || true
    sleep 15
  done
}

install_docker_compose() {
  local version="v2.24.7"
  local arch
  arch="$(uname -m)"
  case "${arch}" in
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
  mkdir -p "${plugin_dir}"
  curl -sSL "https://github.com/docker/compose/releases/download/${version}/docker-compose-linux-${arch}" \
    -o "${plugin_dir}/docker-compose"
  chmod +x "${plugin_dir}/docker-compose"
  ln -sf "${plugin_dir}/docker-compose" /usr/local/bin/docker-compose
}

configure_nginx_site() {
  local conf_path="/etc/nginx/conf.d/${NGINX_SERVER_NAME}"
  cat <<CONF >/etc/nginx/conf.d/${NGINX_SERVER_NAME}
server {
        listen 80 default_server;
        listen [::]:80 default_server;

        root /var/www/html;

        index index.html index.htm index.nginx-debian.html;

        server_name ${NGINX_SERVER_NAME};

        location / {
                try_files $uri $uri/ =404;
                #auth_basic "Restricted Content";
                #auth_basic_user_file /etc/nginx/.htpasswd;
        }
}
CONF
  nginx -t
  systemctl reload nginx || true
}

echo "[INFO] Installing core packages"
install_packages_with_retry

echo "[INFO] Installing Docker Compose plugin"
install_docker_compose

echo "[INFO] Installing Azure CLI"
install_azure_cli_with_retry

echo "[INFO] Configuring services"
usermod -aG docker "${ADMIN_USERNAME}"
systemctl enable docker
systemctl start docker
systemctl enable nginx
systemctl restart nginx

configure_nginx_site

echo "[INFO] Deploying automatic-chainsaw repo"
mkdir -p /opt
rm -rf "${REPO_DIR}"
git clone https://github.com/Soundararajan0912/automatic-chainsaw "${REPO_DIR}"
cd "${REPO_DIR}"
git checkout main

COMPOSE_CMD="docker compose"
if ! docker compose version >/dev/null 2>&1; then
  if command -v docker-compose >/dev/null 2>&1; then
    COMPOSE_CMD="docker-compose"
  else
    echo "[ERROR] Docker Compose is unavailable; aborting deployment." >&2
    exit 1
  fi
fi

cd "${REPO_DIR}/docker-compose/unified-docker-compose"
${COMPOSE_CMD} pull || true
${COMPOSE_CMD} up -d

echo "[INFO] Manual bootstrap completed successfully at $(date --iso-8601=seconds)"