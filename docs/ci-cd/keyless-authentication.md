# Keyless Authentication Guide: GitHub Actions to Azure

## Why Keyless Authentication?
Modern CI/CD pipelines should avoid long-lived credentials. GitHub Actions integrates with Microsoft Entra ID (Azure AD) using OpenID Connect (OIDC) to issue **short-lived (≈1 hour)** tokens that a managed identity can exchange for Azure access. This guide walks through creating a user-assigned managed identity, securing it with role assignments at resource-group scope, mapping it to a GitHub repository/environment, and collecting the IDs you need for your workflows.

## Prerequisites
- Azure subscription with permissions to create **User Assigned Managed Identities** and assign **RBAC** roles at the resource group level.
- Target resource group name and region.
- GitHub organization, repository, and (optional but recommended) environment name that will deploy to Azure.
- GitHub Actions workflow that will call `azure/login` (or equivalent) with OIDC; no secrets are required after setup.

## Step 1: Create the Managed Identity in Azure Portal
1. Sign in to [portal.azure.com](https://portal.azure.com) with the appropriate tenant.
2. In the global search bar, type **Managed Identities** and open the blade.
3. Select **Create** and provide:
   - **Subscription**: target subscription.
   - **Resource group**: the resource group that will own the identity.
   - **Region**: usually the same region as your workload.
   - **Name**: e.g., `github-action-oidc`.
4. (Optional) On the **Tags** tab, specify tag key/value pairs for governance, then click **Review + create** and **Create**.

## Step 2: Assign Azure Roles (Resource Group Scope Recommended)
1. After deployment, open the managed identity resource.
2. Under **Settings**, choose **Azure role assignments** → **Add role assignment**.
3. Set **Scope** to **Resource group** (avoid subscription scope for least privilege).
4. Pick the subscription and resource group the identity should control.
5. Select each required role (e.g., `Contributor`, `Reader`, `Storage Blob Data Contributor`) **one at a time**, clicking **Save** after each addition.
6. Verify the assignments list now reflects the roles.

## Step 3: Configure Federated Credentials for GitHub OIDC
1. Within the same managed identity, open **Federated credentials** under **Settings**.
2. Click **+ Add credential** and choose the scenario **GitHub Actions deploying Azure resources**.
3. Provide the GitHub details (these must match your workflow):

   | Field | Description |
   | --- | --- |
   | **Organization** | GitHub org/owner name (e.g., `my-company`). |
   | **Repository** | Repo name (e.g., `infra-deploy`). |
   | **Entity type** | Select **Environment** for best control; you may also target branches, tags, or pull requests. |
   | **Entity value** | Environment name (e.g., `production`). Only workflows targeting this environment can use the credential. |
   | **Name** | Friendly identifier for this credential (e.g., `github-prod-env`). |

4. Save the credential. Repeat the process for every additional repository/environment combination that needs access; each unique tuple requires its own federated credential.
5. Note: Microsoft Entra ID validates every token against these values. A mismatch (different repo, branch, or environment) blocks authentication automatically.

## Step 4: Capture the Required IDs
On the managed identity overview page collect:
- **Client ID** (a.k.a. Application ID) — required by `azure/login`.
- **Subscription ID** — shown in the identity blade or Azure subscription list.
- **Tenant ID** — available from the top-right **Settings** → **Directories + subscriptions** dialog (copy the **Directory ID**).

Keep these values in a secure place (e.g., GitHub Actions variables or repository secrets if needed for other tooling). No client secret is necessary when using OIDC.

