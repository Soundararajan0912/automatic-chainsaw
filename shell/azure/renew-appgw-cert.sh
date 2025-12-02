#!/usr/bin/env bash
# renew-appgw-cert.sh
#
# Automates the renewal flow for a Let's Encrypt certificate used by Azure Application Gateway.
#
# Prerequisites:
#   - certbot installed on the VM that owns the domain validation challenges
#   - openssl, az CLI, and jq available in PATH
#   - Logged in to Azure CLI (az account show succeeds)
#   - Access to the Key Vault storing the certificate and to the Application Gateway
#
# Usage:
#   1. Set the environment variables below (see CONFIG section) or pass them inline:
#        DOMAIN="grafana.example.com" \
#        KEY_VAULT_NAME="kv-myapp" \
#        KEY_VAULT_CERT_NAME="grafana-cert" \
#        APP_GW_NAME="my-grafana-appgw" \
#        APP_GW_RESOURCE_GROUP="rg-network" \
#        PFX_PASSWORD="$(openssl rand -base64 24)" \
#        ./renew-appgw-cert.sh
#   2. Run the script and monitor the log output.
#   3. Confirm the Application Gateway listener now references the latest certificate version.
#
# Notes:
#   - The script renews all certificates that are due (certbot renew) then extracts the one for DOMAIN.
#   - Adjust CERTBOT_EMAIL/CERTBOT_WEBROOT to match your environment if you need to run the initial issuance.
#   - Application Gateway does not auto-rotate certificates; schedule this script (cron/systemd/DevOps pipeline) well before day 90.
set -euo pipefail

########################################
# CONFIG (override via environment vars)
########################################
: "${DOMAIN:?Set DOMAIN to the certificate's FQDN (e.g., grafana.example.com)}"
: "${KEY_VAULT_NAME:?Set KEY_VAULT_NAME to the target Azure Key Vault name}"
: "${KEY_VAULT_CERT_NAME:?Set KEY_VAULT_CERT_NAME to the Key Vault certificate object name}"
: "${APP_GW_NAME:?Set APP_GW_NAME to the Application Gateway resource name}"
: "${APP_GW_RESOURCE_GROUP:?Set APP_GW_RESOURCE_GROUP to the Application Gateway resource group}"
: "${PFX_PASSWORD:?Set PFX_PASSWORD to a strong passphrase for the exported PFX (keep it secret!)}"
TMP_DIR=${TMP_DIR:-"/tmp/appgw-cert"}
CERTBOT_LIVE_DIR=${CERTBOT_LIVE_DIR:-"/etc/letsencrypt/live"}

mkdir -p "$TMP_DIR"
PFX_FILE="$TMP_DIR/${DOMAIN//./-}.pfx"
FULLCHAIN="$CERTBOT_LIVE_DIR/$DOMAIN/fullchain.pem"
PRIVKEY="$CERTBOT_LIVE_DIR/$DOMAIN/privkey.pem"

########################################
# 1. Renew certificates with certbot
########################################
echo "[+] Renewing Let's Encrypt certificates via certbot..."
certbot renew --quiet

if [[ ! -f "$FULLCHAIN" || ! -f "$PRIVKEY" ]]; then
  echo "[!] Expected certificates not found under $CERTBOT_LIVE_DIR/$DOMAIN"
  exit 1
fi

########################################
# 2. Export to PFX using openssl
########################################
echo "[+] Exporting $DOMAIN to PFX..."
openssl pkcs12 -export \
  -in "$FULLCHAIN" \
  -inkey "$PRIVKEY" \
  -passout pass:"$PFX_PASSWORD" \
  -out "$PFX_FILE"

echo "[+] PFX saved to $PFX_FILE"

########################################
# 3. Upload to Key Vault (certificate object)
########################################
echo "[+] Importing PFX to Key Vault certificate $KEY_VAULT_CERT_NAME..."
az keyvault certificate import \
  --vault-name "$KEY_VAULT_NAME" \
  --name "$KEY_VAULT_CERT_NAME" \
  --file "$PFX_FILE" \
  --password "$PFX_PASSWORD" \
  --only-show-errors \
  --query id -o tsv

########################################
# 4. Update Application Gateway listener reference
########################################
# Fetch certificate version
CERT_VERSION=$(az keyvault certificate show \
  --vault-name "$KEY_VAULT_NAME" \
  --name "$KEY_VAULT_CERT_NAME" \
  --query "id" -o tsv | awk -F'/' '{print $NF}')

if [[ -z "$CERT_VERSION" ]]; then
  echo "[!] Unable to determine Key Vault certificate version"
  exit 1
fi

echo "[+] Latest Key Vault certificate version: $CERT_VERSION"

# Update App Gateway SSL certificates collection
SSL_CERT_NAME="${KEY_VAULT_CERT_NAME}-ssl"
az network application-gateway ssl-cert update \
  --name "$SSL_CERT_NAME" \
  --gateway-name "$APP_GW_NAME" \
  --resource-group "$APP_GW_RESOURCE_GROUP" \
  --key-vault-secret-id "https://$KEY_VAULT_NAME.vault.azure.net/secrets/$KEY_VAULT_CERT_NAME/$CERT_VERSION" \
  --only-show-errors

echo "[+] Application Gateway SSL certificate '$SSL_CERT_NAME' now references the latest Key Vault secret version"

echo "[OK] Renewal workflow completed successfully"
