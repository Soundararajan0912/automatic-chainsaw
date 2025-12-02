#!/usr/bin/env bash
set -euo pipefail

# -------------------------------------------------------------
# GitHub Actions ↔ Azure OIDC onboarding helper
#
# Usage example:
#   export SUBSCRIPTION_ID="00000000-1111-2222-3333-444444444444"
#   export TENANT_ID="aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
#   export IDENTITY_RG="soundar-identities"
#   export IDENTITY_LOCATION="eastus"
#   export IDENTITY_NAME="github-action-oidc"
#   export TARGET_RG="soundar-rnd-09"
#   export ROLE_NAME="Contributor"
#   export GITHUB_ORG="contoso"
#   export GITHUB_REPO="platform-api"
#   export GITHUB_ENV="prod"
#   export FEDERATED_CREDENTIAL_NAME="gha-prod-env"
#   # Optional: export TAGS="env=prod owner=platform"
#   bash oidc_creation_automation_github_action_with_azure.sh
# -------------------------------------------------------------

: "${SUBSCRIPTION_ID:?Set SUBSCRIPTION_ID}"
: "${TENANT_ID:?Set TENANT_ID}"
: "${IDENTITY_RG:?Set IDENTITY_RG}"
: "${IDENTITY_LOCATION:?Set IDENTITY_LOCATION}"
: "${IDENTITY_NAME:?Set IDENTITY_NAME}"
: "${TARGET_RG:?Set TARGET_RG}"
: "${ROLE_NAME:?Set ROLE_NAME}"
: "${GITHUB_ORG:?Set GITHUB_ORG}"
: "${GITHUB_REPO:?Set GITHUB_REPO}"
: "${GITHUB_ENV:?Set GITHUB_ENV}"
: "${FEDERATED_CREDENTIAL_NAME:?Set FEDERATED_CREDENTIAL_NAME}"

if ! command -v jq >/dev/null 2>&1; then
  echo "jq not found. Attempting installation via apt..."
  sudo apt-get update -y
  sudo apt-get install -y jq
fi

az account set --subscription "$SUBSCRIPTION_ID"

echo "Creating managed identity..."
IDENTITY=$(az identity create \
  --name "$IDENTITY_NAME" \
  --resource-group "$IDENTITY_RG" \
  --location "$IDENTITY_LOCATION" \
  --subscription "$SUBSCRIPTION_ID" \
  --tags ${TAGS:-env=prod})

CLIENT_ID=$(echo "$IDENTITY" | jq -r '.clientId')
PRINCIPAL_ID=$(echo "$IDENTITY" | jq -r '.principalId')
IDENTITY_ID=$(echo "$IDENTITY" | jq -r '.id')

echo "Assigning $ROLE_NAME on RG scope..."
az role assignment create \
  --assignee-object-id "$PRINCIPAL_ID" \
  --assignee-principal-type ServicePrincipal \
  --role "$ROLE_NAME" \
  --scope "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$TARGET_RG"

SUBJECT="repo:${GITHUB_ORG}/${GITHUB_REPO}:environment:${GITHUB_ENV}"

echo "Adding federated credential ($SUBJECT)..."
az identity federated-credential create \
  --name "$FEDERATED_CREDENTIAL_NAME" \
  --identity-name "$IDENTITY_NAME" \
  --resource-group "$IDENTITY_RG" \
  --issuer "https://token.actions.githubusercontent.com" \
  --subject "$SUBJECT" \
  --audiences "api://AzureADTokenExchange"

cat <<EOF

✅ GitHub OIDC onboarding complete
---------------------------------
Azure subscription ID : $SUBSCRIPTION_ID
Azure tenant ID       : $TENANT_ID
Managed identity name : $IDENTITY_NAME
Managed identity ID   : $IDENTITY_ID
Client ID             : $CLIENT_ID
Federated subject     : $SUBJECT

Update the GitHub repository secrets (or environment vars) with:
  AZURE_CLIENT_ID       = $CLIENT_ID
  AZURE_TENANT_ID       = $TENANT_ID
  AZURE_SUBSCRIPTION_ID = $SUBSCRIPTION_ID

EOF
