# Adding a Let's Encrypt Certificate to Azure Application Gateway

This guide walks through importing a Lets Encrypt TLS certificate stored in Azure Key Vault into an Application Gateway listener that fronts backend VMs.

## 1. Prerequisites

- A Standard_v2 / WAF_v2 Application Gateway with:
  - A public frontend IP configuration.
  - Backend pools and HTTP routing already working (port 80).
- A Lets Encrypt certificate exported as `.pfx` (with private key) and uploaded to an Azure Key Vault.
- The Application Gateways **managed identity** has `get` (**Key Vault Secrets User** or certificate access policy) permissions on that Key Vault. Prefer vault access policies over RBAC if the portal reports permission issues.
- Backend web server (e.g., nginx) listening on HTTPS/443 before you switch traffic.

> ⏰ **Manual renewal:** Lets Encrypt certificates expire every 90 days. Because this flow uses manual uploads, plan to re-upload/rotate the certificate manually or via automation (Azure CLI/automation account). Application Gateway won't auto-renew a certificate sourced this way.

## 2. Attach the Key Vault certificate

1. Open the Application Gateway in the Azure portal.
2. Navigate to **Listeners** & **Listener TLS certificates**.
3. Select **+ Add certificate** and configure:
   - **Certificate type:** `Choose a certificate from Key Vault`.
   - **Name:** descriptive (e.g., `letsenc-nginx-cert`).
   - **Managed identity:** pick the identity that has Key Vault permissions.
   - **Key Vault:** choose the vault holding the Lets Encrypt `.pfx`.
   - **Certificate:** pick the uploaded certificate secret version.
4. Save. If you get permission errors, switch the vault to access-policy mode and explicitly grant the managed identity `Get`/`List` on secrets/certificates.

## 3. Create an HTTPS listener using the certificate

1. Still under **Listeners**, click **+ Add listener**.
2. Fill out the form:
   - **Name:** `nginx-https-listener` (any meaningful label).
   - **Frontend IP:** select the public frontend IP.
   - **Protocol:** `HTTPS`.
   - **Port:** `443`.
   - **Certificate:** select `letsenc-nginx-cert` (the one added above).
   - **Listener type:** `Multi-site`.
   - **Host type:** `Single` (one hostname).
   - **Hostname:** enter the FQDN you want to secure (e.g., `nginx.example.com`).
3. Save the listener.

## 4. Map the listener to an existing backend rule

1. Navigate to **Rules** & **Add routing rule**.
2. On the **Basics** tab:
   - **Rule name:** `https-nginx-rule`.
   - **Priority:** choose an available number (lower value = higher priority).
   - **Listener:** select `nginx-https-listener`.
3. On **Backend targets**:
   - **Target type:** `Backend pool`.
   - **Backend target:** pick the pool already serving the HTTP traffic (port 80 backend).
   - **HTTP settings:** reuse the existing backend settings (they typically point to port 80 unless you terminate TLS end-to-end).
4. Save the rule.

## 5. Validate end-to-end HTTPS

1. Confirm the backend VMs web server is listening on port 80/443 as required (e.g., `sudo systemctl status nginx`).
2. From a client, browse to `https://nginx.example.com`.
3. Verify:
   - TLS handshake succeeds with the Lets Encrypt certificate.
   - The web app returns the expected page.
4. In the Application Gateway blade, review **Backend health** for the pool to ensure all instances show **Healthy**.

## 6. Renewal checklist

Because Let's Encrypt certificates expire rapidly:

1. Automate renewal (Azure CLI, DevOps pipeline, or Logic App) that:
    - Requests a new certificate before day 60.
    - Imports the `.pfx` into Key Vault (new secret version).
    - Updates the Application Gateway certificate reference (repoint to the new version).
2. Alternatively, perform the above steps manually every 90 days.

### Manual command reference

Export a renewed certificate to PFX:

```bash
openssl pkcs12 -export \
   -in /etc/letsencrypt/live/<domain>/fullchain.pem \
   -inkey /etc/letsencrypt/live/<domain>/privkey.pem \
   -passout pass:<strong-random-password> \
   -out <output-file>.pfx
```

Import the PFX into Key Vault:

```bash
az keyvault certificate import \
   --vault-name <kv-name> \
   --name <kv-cert-name> \
   --file <output-file>.pfx \
   --password <strong-random-password>
```

Update the Application Gateway SSL certificate reference:

```bash
az network application-gateway ssl-cert update \
   --name <appgw-ssl-cert-name> \
   --gateway-name <appgw-name> \
   --resource-group <rg-name> \
   --key-vault-secret-id "https://<kv-name>.vault.azure.net/secrets/<kv-cert-name>/<version>"
```

### Scripted automation option

The repo includes `scripts/renew-appgw-cert.sh`, which bundles the flow above:

1. Runs `certbot renew` to refresh certificates on the server.
2. Uses `openssl` to export the renewed domain into a password-protected PFX.
3. Uploads the PFX to Key Vault and retrieves the latest secret version.
4. Calls `az network application-gateway ssl-cert update` to point the listener at the new version.

#### How to run the script

```bash
DOMAIN="grafana.example.com" \
KEY_VAULT_NAME="kv-myapp" \
KEY_VAULT_CERT_NAME="grafana-cert" \
APP_GW_NAME="my-grafana-appgw" \
APP_GW_RESOURCE_GROUP="rg-network" \
PFX_PASSWORD="$(openssl rand -base64 24)" \
./scripts/renew-appgw-cert.sh
```

Schedule it via cron/systemd/CI to avoid expired certificates.

Following this procedure secures the Application Gateway listener with your Lets Encrypt certificate while maintaining backend routing behaviour.
