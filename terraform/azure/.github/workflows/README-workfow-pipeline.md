# Terraform CI/CD & Remote State Guide

This document explains how the Terraform automation in this repo works, how to
set up the secure remote backend, and how to run the GitHub Actions workflow
that deploys the Azure infrastructure.

## 1. Remote state backend (versioned & secure)

Terraform now expects an Azure Storage account backend (configured via
`backend.hcl`). Use a dedicated storage account outside of Terraform so that
state is always available before `terraform init` runs.

### 1.1 Provision the backend

```bash
RG_TFSTATE="rg-tfstate-prod"
LOC="eastus"
SA_TFSTATE="statestoreprod001"
CONTAINER="tfstate"

az group create --name $RG_TFSTATE --location $LOC
az storage account create \
  --name $SA_TFSTATE \
  --resource-group $RG_TFSTATE \
  --sku Standard_GRS \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false
# Enable versioning + soft-delete for defense-in-depth
az storage account blob-service-properties update \
  --resource-group $RG_TFSTATE \
  --account-name $SA_TFSTATE \
  --enable-versioning true \
  --delete-retention-days 14
az storage container create \
  --account-name $SA_TFSTATE \
  --name $CONTAINER \
  --auth-mode login
```

These settings give you encrypted storage, replication, TLS enforcement, blob
versioning, and soft delete for rollback/recovery.

### 1.2 Configure `backend.hcl`

1. Copy the sample file and customize it:
   ```bash
   cp backend.hcl.example backend.hcl
   ```
2. Update the values to match the resources you just created:
   ```hcl
   resource_group_name  = "rg-tfstate-prod"
   storage_account_name = "statestoreprod001"
   container_name       = "tfstate"
   key                  = "azure/terraform.tfstate"
   use_azure_ad_auth    = true
   ```
3. Keep `backend.hcl` **out of version control** (it is already ignored). The
   GitHub workflow and local runs both load this file during `terraform init`.

## 2. GitHub Actions workflow

The workflow lives in `.github/workflows/terraform.yml` and runs via the
`workflow_dispatch` trigger so you can specify both the branch and the target
environment when you kick it off. (You can still schedule or reuse it from
other workflows, but the default entry point is manual.)

### 2.1 Workflow inputs (branch + environment)

When you launch the workflow from the **Actions → terraform-ci → Run workflow**
screen you must supply two inputs:

| Input | Description |
| --- | --- |
| `branch_name` | Branch that `actions/checkout` should use. Defaults to `main`. |
| `environment` | Logical deployment environment, either `development` or `production`. This value flows into GitHub Environments, Terraform job logs, and any tfsec issues created during the run. |

Picking `development` keeps the run isolated to that environment (different
approvals/secrets), while `production` routes through the protected environment
gate. Both jobs dynamically detect which environment you selected.

### 2.2 Secrets & OIDC setup

Create a federated credential for your GitHub repo and store these repository
secrets:

| Secret | Description |
| --- | --- |
| `AZURE_CLIENT_ID` | App registration / workload identity client ID |
| `AZURE_TENANT_ID` | Azure AD tenant ID |
| `AZURE_SUBSCRIPTION_ID` | Subscription that hosts the infrastructure |

No client secret is required—the workflow uses OIDC via `azure/login@v2` and
exchanges GitHub’s token for an Azure AD access token at runtime. The same
values are exported as `ARM_*` variables so Terraform authenticate natively.

### 2.3 Jobs & stages

1. **validate-plan** (runs on every PR + push):
   - Checks out the repo and verifies `backend.hcl` exists.
   - Runs `terraform fmt`, `init`, and `validate`.
   - Authenticates to Azure and executes `tfsec` to produce a SARIF security
     report (uploaded to GitHub code scanning).
   - Summarizes any tfsec findings and automatically files a GitHub issue with
     labels for the severity and the selected environment. The workflow marks
     the job as failed if tfsec reported violations so reviewers can triage the
     issue before applying infrastructure changes.
   - Creates a deterministic `terraform plan` and uploads it as an artifact.
2. **apply** (runs for manual dispatches or pushes to `main`):
   - Maps to the GitHub Environment you selected in the dispatch form
     (`development` or `production`). Configure approvals/secrets per
     environment in repo settings.
   - Downloads the previously generated plan artifact and reuses it for
     `terraform apply`, guaranteeing that the applied change set equals the plan
     reviewers approved.

### 2.4 Triggering manually

From the Actions tab select **terraform-ci → Run workflow**, choose the branch
and environment, and click **Run**. The workflow records those inputs in the
logs/artifacts, making it easy to see exactly what combination produced a given
plan.

### 2.5 Local equivalence

For parity with CI you can run the same commands locally:

```bash
terraform -chdir=. fmt
terraform -chdir=. init -backend-config=backend.hcl
terraform -chdir=. validate
terraform -chdir=. plan -out=tfplan
terraform -chdir=. apply tfplan
```

(Ensure Azure CLI is logged in as the same identity the workflow uses.)

## 3. Security controls baked in

- **Remote state hardening**: Blob versioning, soft delete, replication, and TLS
  enforcement protect state history.
- **OIDC authentication**: No secrets stored in GitHub; short-lived tokens are
  minted just-in-time by Azure AD.
- **Static scanning + auto ticketing**: `tfsec` runs on every change, uploads
  SARIF to GitHub code scanning, and files an actionable GitHub issue (tagged
  with the selected environment) when violations are present.
- **Change approvals**: The `production` environment gate requires an explicit
  approval before `terraform apply` runs on `main`.

## 4. Operational checklist

1. Provision the remote backend (Section 1.1) and keep track of its resource
   group/storage account/container.
2. Copy `backend.hcl.example` to `backend.hcl` and commit **only** the example.
3. Configure the GitHub secrets + environment protections.
4. Commit your Terraform changes; open a PR.
5. Review `tfsec` findings and the Terraform plan output in the workflow logs.
6. After merging to `main`, approve the pending deployment if required; the
   `apply` job will finish the rollout automatically.

With these steps you now have a secure, fully automated Terraform delivery
pipeline targeting Azure.
