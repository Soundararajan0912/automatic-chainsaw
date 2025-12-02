# Keyless GitHub → Azure Authentication with Managed Identity + OIDC

Short-lived OpenID Connect (OIDC) tokens let GitHub Actions authenticate to Azure without storing client secrets. Microsoft Entra ID issues a token that (by default) expires in **1 hour**, so each workflow run gets unique credentials. This guide walks through creating a user-assigned managed identity, granting it least-privilege access, and binding it to a GitHub repository/environment via federated credentials.

## 1. Create the managed identity in the Azure portal

1. Sign in to [https://portal.azure.com](https://portal.azure.com).
2. Use the global search box to look for **Managed Identities** and open the blade.
3. Select **Create** and provide:
   - **Subscription**: The subscription where GitHub should deploy.
   - **Resource group**: e.g., `soundar-rnd-09` (choose or create one dedicated to identities).
   - **Region**: Usually the same region as your workloads.
   - **Name**: A descriptive label such as `github-action-oidc`.
4. Click **Next** to add optional tags (owner, cost center, environment) and then **Review + create** → **Create**.

## 2. Assign Azure roles at resource-group scope

1. After deployment, open the managed identity resource.
2. In the left menu, select **Azure role assignments**.
3. Click **Add role assignment** and configure:
   - **Scope**: choose **Resource group** (avoid subscription-wide scope unless absolutely required).
   - **Subscription / Resource group**: select the target RG that GitHub will manage.
   - **Role**: pick the least-privileged role(s) needed (e.g., `Contributor`, `Storage Blob Data Contributor`). Add each role separately if multiples are required.
4. Save each assignment. Using RG scope enforces the best practice of limiting blast radius.

## 3. Add a federated credential for GitHub Actions

1. Within the same managed identity, go to **Federated credentials** under **Settings**.
2. Choose **Add credential**.
3. Set **Scenario** to **GitHub Actions deploying Azure resources** to preload the correct issuer/audience values.
4. Fill in the GitHub details:
   - **Organization**: e.g., `contoso`.
   - **Repository**: e.g., `contoso/app-platform`.
   - **Entity**: choose **Environment** for the tightest control (e.g., `prod`). You can also target a specific branch or pull-request pattern if preferred.
   - **Name**: friendly label such as `gha-prod-env`.
5. Review the summary and click **Add**.

> ℹ️ Only the specified org/repo/environment combination can now request tokens for this identity. If another repo or environment needs access, create an additional federated credential entry.

## 4. Capture identity metadata for the pipeline

You will need three values in GitHub Actions secrets or variables:

| Value | Where to locate |
|-------|-----------------|
| **Client ID** | Managed identity → **Overview** → *Client ID* |
| **Subscription ID** | Managed identity → **Overview** or Azure portal top bar → *Directory + subscription* |
| **Tenant ID** | Azure portal top bar → *Manage tenant* → copy the **Directory (tenant) ID** |

Optionally, confirm via CLI:

```bash
az identity show \
  --name github-action-oidc \
  --resource-group soundar-rnd-09 \
  --query "{clientId:clientId, principalId:principalId}" -o tsv
```

## 5. Use the identity in GitHub Actions

Store the IDs in GitHub (Secrets or Environment Variables):

- `AZURE_CLIENT_ID`
- `AZURE_TENANT_ID`
- `AZURE_SUBSCRIPTION_ID`

Example workflow snippet:

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: prod
    permissions:
      id-token: write   # required for OIDC
      contents: read
    steps:
      - uses: actions/checkout@v4
      - name: Azure login via OIDC
        uses: azure/login@v2
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
      - name: Terraform plan/apply (example)
        run: |
          cd terraform/azure
          terraform init
          terraform plan
```

Because the workflow exchanges an OIDC token for a Microsoft Entra token at runtime, there are **no long-lived secrets** to rotate. Each run gets a transient credential that expires automatically (default 1 hour), satisfying least-privilege and secret hygiene requirements.

## Automate everything with Azure CLI

If you need to onboard many repositories/environments without using the portal, script the entire flow. The Azure CLI now exposes managed identity federated-credential subcommands, so you can create the identity, assign roles, and wire up GitHub in one go.

### Inputs your script needs

| Variable | Description |
|----------|-------------|
| `SUBSCRIPTION_ID` | Azure subscription where the resources live. |
| `TENANT_ID` | Microsoft Entra tenant ID (use `az account show --query tenantId -o tsv`). |
| `IDENTITY_RG` | Resource group that will contain the managed identity (must exist). |
| `IDENTITY_LOCATION` | Azure region for the identity (e.g., `eastus`). |
| `IDENTITY_NAME` | Friendly name like `github-action-oidc`. |
| `TARGET_RG` | Resource group scope to which GitHub should have access. |
| `ROLE_NAME` | Least-privilege Azure role (e.g., `Contributor`, `Storage Blob Data Contributor`). |
| `GITHUB_ORG` / `GITHUB_REPO` | Repository owner/name (without `.git`). |
| `GITHUB_ENV` | GitHub environment (or supply a branch/pull-request subject if you prefer). |
| `FEDERATED_CREDENTIAL_NAME` | Display name for the federated credential (e.g., `gha-prod-env`). |
| `TAGS` | Optional `key=value` tags for the identity. |

> Make sure you have already run `az login` (service principal or user) and `az account set --subscription $SUBSCRIPTION_ID` before executing the script.


