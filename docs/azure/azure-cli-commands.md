# Azure CLI Operations Reference

Use this document as a generic, value-agnostic guide for the Azure CLI commands captured in `az vm show --name soundar-rnd-10-vm --re.sh`. Replace the placeholders (shown in ALL_CAPS or `<angle-brackets>`) with values from your environment before running any command.

---

## Prerequisites

```bash
# Sign in (optional if you already have an active session)
az login

# Verify active subscription
az account show

# Switch subscriptions when required
az account set --subscription "<SUBSCRIPTION_ID_OR_NAME>"
```

> **PowerShell note:** Replace trailing `\` with backticks `` ` `` when copying multiline commands.

---

## Inspect VM Custom Data (cloud-init)

```bash
az vm show \
  --name <VM_NAME> \
  --resource-group <RESOURCE_GROUP> \
  --query "osProfile.customData" \
  -o tsv | base64 --decode | head
```

- `head` lets you preview only the beginning of the decoded cloud-init payload.
- Remove `| head` if you need the full script.

---

## Storage Account Context

```bash
# Show storage account resource ID (useful for role assignments)
az storage account show \
  --name <STORAGE_ACCOUNT_NAME> \
  --resource-group <RESOURCE_GROUP> \
  --query id -o tsv
```

Store it for reuse:
```bash
STG_ID=$(az storage account show \
  --name <STORAGE_ACCOUNT_NAME> \
  --resource-group <RESOURCE_GROUP> \
  --query id -o tsv)
```

---

## Storage Container Operations

List all containers:
```bash
az storage container list \
  --account-name <STORAGE_ACCOUNT_NAME> \
  --auth-mode login \
  --output table
```

Create a container:
```bash
az storage container create \
  --account-name <STORAGE_ACCOUNT_NAME> \
  --name <CONTAINER_NAME> \
  --auth-mode login
```

List blobs within a container:
```bash
az storage blob list \
  --account-name <STORAGE_ACCOUNT_NAME> \
  --container-name <CONTAINER_NAME> \
  --auth-mode login \
  --output table
```

---

## Blob Upload & Download

Upload a local file:
```bash
az storage blob upload \
  --account-name <STORAGE_ACCOUNT_NAME> \
  --container-name <CONTAINER_NAME> \
  --name <BLOB_NAME> \
  --file <LOCAL_FILE_PATH> \
  --auth-mode login
```

Download an existing blob:
```bash
az storage blob download \
  --account-name <STORAGE_ACCOUNT_NAME> \
  --container-name <CONTAINER_NAME> \
  --name <BLOB_NAME> \
  --file <DESTINATION_PATH> \
  --auth-mode login
```

---

## Role Assignments for Storage Access

Determine the principal object ID:
```bash
# For a signed-in user
AZURE_OBJECT_ID=$(az ad signed-in-user show --query id -o tsv)

# For a service principal
# AZURE_OBJECT_ID=$(az ad sp show --id <APP_ID_OR_CLIENT_ID> --query id -o tsv)
```

Grant storage roles (examples):
```bash
az role assignment create \
  --assignee $AZURE_OBJECT_ID \
  --role "Storage Blob Data Reader" \
  --scope $STG_ID

az role assignment create \
  --assignee <OBJECT_ID_OR_APP_ID> \
  --role "Storage Blob Data Contributor" \
  --scope /subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<RESOURCE_GROUP>/providers/Microsoft.Storage/storageAccounts/<STORAGE_ACCOUNT_NAME>
```

Use the appropriate built-in role (Reader, Contributor, Owner, etc.) based on the level of access needed.

---

## Quick Reference Table

| Task | Command Template |
|------|------------------|
| View VM cloud-init | `az vm show --name <VM_NAME> --resource-group <RG> --query "osProfile.customData" -o tsv \| base64 --decode` |
| Upload blob | `az storage blob upload --account-name <STG> --container-name <CTR> --name <BLOB> --file <PATH>` |
| Download blob | `az storage blob download --account-name <STG> --container-name <CTR> --name <BLOB> --file <DEST>` |
| List containers | `az storage container list --account-name <STG> --output table` |
| Create container | `az storage container create --account-name <STG> --name <CTR>` |
| List blobs | `az storage blob list --account-name <STG> --container-name <CTR> --output table` |
| Show storage account ID | `az storage account show --name <STG> --resource-group <RG> --query id -o tsv` |
| Assign role | `az role assignment create --assignee <OBJECT_ID> --role "ROLE" --scope <SCOPE>` |

Keep this file alongside the original script so future operators can plug in their own values without reverse-engineering the raw commands.
