# Azure Infrastructure Access Guide - DevSecOps Admin

## Document Purpose
This document provides the complete access control configuration for **DevSecOps Administrators**. It includes all Azure role assignments, permissions, and configuration details needed to grant full administrative access with billing capabilities.


## Table of Contents
1. [Access Overview](#access-overview)
2. [Complete Access Grant Table](#complete-access-grant-table)
3. [Azure Portal Instructions](#azure-portal-instructions)
4. [Detailed Permissions by Service](#detailed-permissions-by-service)
5. [PIM Configuration](#pim-configuration)
6. [Best Practices & Security Guidelines](#best-practices--security-guidelines)


## 1. Access Overview

### DevSecOps Admin Role Summary

**Purpose:** Full operational control of Azure infrastructure with cost management and billing access

**Access Level:** Subscription Owner (via PIM) + Service-specific administrative roles

**Key Capabilities:**
- ✅ Full resource management (create, modify, delete)
- ✅ Cost management and budget control
- ✅ Billing access and invoice viewing
- ✅ Purchase Azure Reservations and Savings Plans
- ✅ Security posture management
- ✅ Policy and governance enforcement
- ✅ Network infrastructure management
- ✅ Monitoring and alerting configuration
- ✅ Identity and access management

**Total Role Assignments:** ~20-25 roles


## 2. Complete Access Grant Table

### 🎯 For Admin Team: Grant These Roles to DevSecOps Admins

| # | Service/Area | Exact Role Name | Scope | Assignment Type | Priority | Notes |
|---|--------------|-----------------|-------|-----------------|----------|-------|
| **SUBSCRIPTION LEVEL - CRITICAL** |
| 1 | Subscription | **Owner** | `/subscriptions/{subscription-id}` | **PIM Eligible** | 🔴 Critical | Requires approval + MFA |
| 2 | Cost Management | **Cost Management Contributor** | `/subscriptions/{subscription-id}` | Permanent | 🔴 Critical | Manage budgets & alerts |
| 3 | Billing | **Billing Reader** | `/subscriptions/{subscription-id}` | Permanent | 🔴 Critical | View invoices |
| 4 | Reservations | **Reservation Purchaser** | `/subscriptions/{subscription-id}` | **PIM Eligible** | 🟡 High | Purchase Azure Reservations |
| 5 | Savings Plans | **Savings plan Purchaser** | `/subscriptions/{subscription-id}` | **PIM Eligible** | 🟡 High | Purchase Savings Plans |
| 6 | Security | **Security Admin** | `/subscriptions/{subscription-id}` | Permanent | 🔴 Critical | Manage Defender for Cloud |
| 7 | Policy | **Resource Policy Contributor** | `/subscriptions/{subscription-id}` | Permanent | 🔴 Critical | Manage Azure Policies |
| 8 | Monitoring | **Monitoring Contributor** | `/subscriptions/{subscription-id}` | Permanent | 🟡 High | Manage alerts |
| **AZURE ACTIVE DIRECTORY (TENANT LEVEL)** |
| 9 | Azure AD | **Application Administrator** | Tenant Level | Permanent | 🔴 Critical | Manage app registrations |
| 10 | Azure AD | **Cloud Application Administrator** | Tenant Level | Permanent | 🔴 Critical | Manage enterprise apps |
| 11 | Azure AD | **Conditional Access Administrator** | Tenant Level | Permanent | 🟡 High | Manage CA policies (if needed) |
| **MONITORING & LOGGING** |
| 12 | Log Analytics | **Log Analytics Contributor** | `/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.OperationalInsights/workspaces/{workspace}` | Permanent | 🔴 Critical | Manage workspace & queries |
| 13 | Sentinel | **Microsoft Sentinel Contributor** | `/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.OperationalInsights/workspaces/{workspace}` | Permanent | 🔴 Critical | Manage SIEM |
| **NETWORKING** |
| 14 | Networking | **Network Contributor** | `/subscriptions/{sub-id}/resourceGroups/rg-networking-*` | Permanent | 🔴 Critical | Manage VNets, NSGs, Firewall |
| **COMPUTE & CONTAINERS** |
| 15 | Resource Group | **Contributor** | `/subscriptions/{sub-id}/resourceGroups/rg-compute-*` | Permanent | 🔴 Critical | Manage all resources in RG |
| **CONTAINER REGISTRY** |
| 16 | ACR | **AcrPush** | `/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.ContainerRegistry/registries/{acr-name}` | Permanent | 🔴 Critical | Push images |
| 17 | ACR | **AcrPull** | `/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.ContainerRegistry/registries/{acr-name}` | Permanent | 🟢 Standard | Pull images |
| 18 | ACR | **Contributor** | `/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.ContainerRegistry/registries/{acr-name}` | Permanent | 🔴 Critical | Manage ACR settings |
| **KEY VAULT** |
| 19 | Key Vault | **Key Vault Administrator** | `/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.KeyVault/vaults/{kv-name}` | Permanent | 🔴 Critical | Full Key Vault management |
| 20 | Key Vault (Dev) | **Key Vault Secrets User** | `/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.KeyVault/vaults/{kv-dev-name}` | Permanent | 🟢 Standard | Read dev secrets |
| **AZURE OPENAI** |
| 21 | OpenAI | **Cognitive Services OpenAI Contributor** | `/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.CognitiveServices/accounts/{openai-name}` | Permanent | 🔴 Critical | Deploy models, manage settings |
| **STORAGE (IF USED)** |
| 22 | Storage | **Storage Blob Data Contributor** | `/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.Storage/storageAccounts/{storage-name}` | Permanent | 🟡 High | Manage blobs |
| **DATABASE (IF USED)** |
| 23 | PostgreSQL | **Contributor** | `/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.DBforPostgreSQL/*` | Permanent | 🟡 High | Manage database settings |


### Legend

| Symbol | Priority | Meaning |
|--------|----------|---------|
| 🔴 | Critical | Must be assigned for core functionality |
| 🟡 | High | Important for full operational capability |
| 🟢 | Standard | Useful but not essential |
| **PIM Eligible** | - | Assign through Privileged Identity Management (time-bound, requires activation) |
| **Permanent** | - | Standard role assignment (always active) |


## 3. Azure Portal Instructions

### How to Grant Access

#### Step 1: Navigate to Access Control
1. Go to **Azure Portal** (https://portal.azure.com)
2. Navigate to the resource:
   - For **Subscription-level** roles: Go to **Subscriptions** → Select subscription → **Access control (IAM)**
   - For **Resource-level** roles: Navigate to the specific resource → **Access control (IAM)**

#### Step 2: Add Role Assignment
1. Click **+ Add** → **Add role assignment**
2. In the **Role** tab:
   - Search for the exact role name from the table above
   - Select the role
   - Click **Next**

3. In the **Members** tab:
   - Click **+ Select members**
   - Search for the DevSecOps admin user by name or email
   - Select the user
   - Click **Select**
   - Click **Next**

4. In the **Conditions** tab (if applicable):
   - Usually leave as default
   - Click **Next**

5. In the **Review + assign** tab:
   - Review the assignment
   - Click **Review + assign**

#### Step 3: Verify Assignment
1. Go back to **Access control (IAM)**
2. Click **Role assignments** tab
3. Search for the user to verify the role was assigned


### Special: PIM (Privileged Identity Management) Assignments

For roles marked as **PIM Eligible** (Owner, Reservation Purchaser, Savings Plan Purchaser):

#### Step 1: Navigate to PIM
1. In Azure Portal, search for **Privileged Identity Management**
2. Click **Azure resources**
3. Select the subscription

#### Step 2: Add Eligible Assignment
1. Click **Assignments** (left menu)
2. Click **+ Add assignments**
3. Select the role (e.g., "Owner")
4. Click **No member selected** → Select the user → Click **Select**
5. Click **Next**

#### Step 3: Configure Settings
```yaml
Assignment type: Eligible
Permanently eligible: Yes (or set expiration date)
Justification: "DevSecOps Administrator - Full operational access"
```

#### Step 4: Configure Activation Settings
1. Go to **Settings** in PIM
2. Select the role (e.g., "Owner")
3. Click **Edit**
4. Configure:
   ```yaml
   Activation maximum duration: 8 hours
   Require justification on activation: Yes
   Require approval to activate: Yes (for production)
   Require Azure MFA on activation: Yes
   ```
5. Select **Approvers** (e.g., IT Manager, Security Lead)
6. Click **Update**

## 4. Detailed Permissions by Service

### Subscription-Level Roles

#### Owner (via PIM)
**Included Permissions:**
- Full resource management (all Azure services)
- Cost management and billing
- RBAC management (assign roles to others)
- Policy assignment and management
- Blueprint deployment
- All service operations

**Why PIM:**
- Time-bound access (activates for max 8 hours)
- Requires approval and justification
- MFA enforcement on activation
- Audit trail of all activations
- Reduces standing privileges

**When to Activate:**
- Major infrastructure changes
- New service deployments
- RBAC modifications
- Emergency incident response


#### Cost Management Contributor
**Permissions:**
- ✅ View all costs and usage
- ✅ Create and manage budgets
- ✅ Create cost alerts
- ✅ Export cost data
- ✅ Analyze cost trends
- ✅ View cost forecasts
- ❌ View invoices (requires Billing Reader)

**Use Cases:**
- Monthly budget reviews
- Cost optimization initiatives
- Setting up budget alerts
- Cost allocation and chargeback


#### Billing Reader
**Permissions:**
- ✅ View invoices
- ✅ View payment history
- ✅ View subscription details
- ✅ View reservation purchases
- ❌ Manage budgets (requires Cost Management Contributor)

**Use Cases:**
- Invoice reconciliation
- Payment verification
- Billing period reviews

#### Reservation Purchaser (via PIM)
**Permissions:**
- ✅ Purchase Azure Reservations (1 or 3 year commitments)
- ✅ View existing reservations
- ✅ Manage reservation assignments
- ✅ Exchange reservations
- ✅ Cancel reservations (within policy)

**Use Cases:**
- Purchasing 1-year or 3-year VM reservations
- Optimizing costs with committed usage
- Managing reservation lifecycle

**Why PIM:**
- Financial impact (multi-year commitments)
- Requires business approval
- Infrequent action

#### Savings Plan Purchaser (via PIM)
**Permissions:**
- ✅ Purchase Azure Savings Plans
- ✅ View existing savings plans
- ✅ Manage savings plan assignments

**Use Cases:**
- Flexible hourly commitments across services
- Cost optimization at scale

**Why PIM:**
- Financial impact
- Requires business approval


#### Security Admin
**Permissions:**
- ✅ Enable/disable Defender for Cloud plans
- ✅ Configure security policies
- ✅ Manage JIT VM access
- ✅ Configure auto-provisioning
- ✅ Manage security contacts
- ✅ Configure workflow automation
- ✅ View security alerts and recommendations
- ✅ Remediate security issues

**Use Cases:**
- Security posture management
- Threat detection configuration
- Incident response
- Compliance management



#### Resource Policy Contributor
**Permissions:**
- ✅ Create, assign, and delete policies
- ✅ Create, assign, and delete initiatives
- ✅ Manage policy assignments
- ✅ View compliance data
- ✅ Trigger remediation tasks

**Use Cases:**
- Governance enforcement
- Compliance automation
- Resource standardization
- Cost controls (prevent expensive resources)


### Azure Active Directory Roles

#### Application Administrator
**Permissions:**
- ✅ Create and manage app registrations
- ✅ Create and manage service principals
- ✅ Grant admin consent for APIs
- ✅ Manage application credentials
- ❌ Global Administrator actions

**Use Cases:**
- Creating service principals for CI/CD
- Managing application identities
- API permission management


#### Cloud Application Administrator
**Permissions:**
- ✅ Manage enterprise applications
- ✅ Configure SSO and SAML
- ✅ Manage app proxy
- ✅ Manage application access

**Use Cases:**
- Configuring enterprise SaaS integrations
- SSO setup for internal apps


### Monitoring & Logging

#### Log Analytics Contributor
**Permissions:**
- ✅ View all monitoring data
- ✅ Create and edit queries
- ✅ Create and edit alerts
- ✅ Create and edit action groups
- ✅ Configure diagnostic settings
- ✅ Manage workspace settings
- ✅ Create workbooks and dashboards

**Use Cases:**
- Setting up monitoring for new services
- Creating custom alerts
- Troubleshooting with log queries
- Dashboard creation


#### Microsoft Sentinel Contributor
**Permissions:**
- ✅ Manage analytics rules
- ✅ Manage playbooks (Logic Apps automation)
- ✅ Create and edit workbooks
- ✅ Manage data connectors
- ✅ Incident management (create, update, close)
- ✅ Threat hunting

**Use Cases:**
- Security incident investigation
- Creating detection rules
- Automating incident response
- Threat hunting


### Networking

#### Network Contributor
**Permissions:**
- ✅ Manage virtual networks
- ✅ Manage subnets
- ✅ Manage NSGs and security rules
- ✅ Manage Azure Firewall
- ✅ Configure private endpoints
- ✅ Manage DNS zones
- ✅ Manage load balancers
- ✅ Manage VPN gateways

**Use Cases:**
- Network architecture changes
- Firewall rule updates
- Private endpoint creation
- Network troubleshooting



### Container & Compute

#### Contributor (on Resource Groups)
**Permissions:**
- ✅ Create, modify, delete all resources in RG
- ✅ Manage Container Apps
- ✅ Manage app configurations
- ✅ Manage scaling settings
- ✅ View logs and metrics
- ❌ Assign roles (requires Owner)

**Use Cases:**
- Deploying new applications
- Updating container configurations
- Scaling applications
- Resource lifecycle management



#### AcrPush (Container Registry)
**Permissions:**
- ✅ Push container images
- ✅ Pull container images
- ✅ Delete images
- ✅ Manage repositories

**Use Cases:**
- CI/CD pipeline image pushes
- Manual image uploads
- Image cleanup and management


#### AcrPull (Container Registry)
**Permissions:**
- ✅ Pull container images
- ✅ View repositories
- ✅ View image tags

**Use Cases:**
- Local development
- Testing container pulls


### Key Vault

#### Key Vault Administrator
**Permissions:**
- ✅ All operations on keys, secrets, certificates
- ✅ Manage Key Vault access policies
- ✅ Configure Key Vault settings
- ✅ Enable/disable soft delete
- ✅ Purge protection management
- ✅ Configure networking
- ✅ View audit logs

**Use Cases:**
- Secret management
- Certificate lifecycle
- Key rotation
- Access control management


### Azure OpenAI

#### Cognitive Services OpenAI Contributor
**Permissions:**
- ✅ Deploy AI models (GPT-4o, etc.)
- ✅ Manage deployments
- ✅ Configure content filters
- ✅ View usage and metrics
- ✅ Manage networking settings
- ✅ Configure quota limits

**Use Cases:**
- Model deployment
- Performance tuning
- Content filter configuration
- Usage monitoring


## 5. PIM Configuration

### Recommended PIM Settings for Owner Role

#### Activation Settings
```yaml
Role: Owner
Scope: Subscription

Activation:
  Maximum duration: 8 hours
  Require Azure MFA: Yes
  Require justification: Yes
  Require ticket information: Optional
  Require approval: Yes (for production)
  
Approval:
  Approvers:
    - IT Director
    - Security Manager
  Notification: Email to approvers
  
Notifications:
  On activation: Email to user, approvers, and admins
  On expiration: Email to user
```

#### Assignment Settings
```yaml
Assignment type: Eligible (not active)
Duration: Permanent eligible (or time-bound, e.g., 1 year)
Require justification: Yes
Allow permanent active assignment: No
```

#### Access Reviews
```yaml
Frequency: Quarterly
Reviewers: IT Management + Security Team
Duration: 14 days
Auto-decision if no response: Remove access
Require justification: Yes
```



### How DevSecOps Admin Activates PIM Role

#### Step 1: Navigate to My Roles
1. Go to Azure Portal
2. Search for **Privileged Identity Management**
3. Click **My roles**
4. Click **Azure resources**

#### Step 2: Activate Role
1. Find **Owner** role in the list
2. Click **Activate**
3. Fill in:
   - **Duration:** (e.g., 8 hours)
   - **Justification:** (e.g., "Deploying new Azure Firewall configuration for production")
   - **Ticket Number:** (optional, if required)
4. Click **Activate**

#### Step 3: Wait for Approval
- Notification sent to approvers
- Approvers review and approve/deny
- User receives notification of approval

#### Step 4: Verification
- Role is now active for specified duration
- User can perform Owner-level actions
- Audit log records activation



## 6. Best Practices & Security Guidelines

### Access Management
- ✅ **Use PIM for high-privilege roles** (Owner, Reservation Purchaser)
- ✅ **Regular access reviews** (quarterly minimum)
- ✅ **Just-in-time activation** (activate PIM only when needed)
- ✅ **Require MFA** for all administrative actions
- ✅ **Document justifications** for all activations
- ✅ **Time-bound assignments** where possible

### Security Operations
- ✅ **Monitor security alerts** daily (Sentinel, Defender)
- ✅ **Review audit logs** weekly
- ✅ **Update policies** as threats evolve
- ✅ **Patch management** for all resources
- ✅ **Incident response drills** monthly
- ✅ **Security training** ongoing

### Cost Management
- ✅ **Review budgets** monthly
- ✅ **Analyze cost trends** weekly
- ✅ **Optimize resources** continuously
- ✅ **Right-size services** based on usage
- ✅ **Purchase reservations** after 60 days of stable usage
- ✅ **Monitor anomalies** with alerts

### Governance
- ✅ **Enforce tagging** on all resources
- ✅ **Apply policies** at subscription level
- ✅ **Document changes** in change management system
- ✅ **Peer review** major infrastructure changes
- ✅ **Infrastructure as Code** (Terraform, Bicep)
- ✅ **Version control** all configurations

## Checklist for Granting DevSecOps Admin Access

Use this checklist when onboarding a new DevSecOps Administrator:

### Pre-Assignment
- [ ] User has completed security training
- [ ] User has Azure MFA enabled
- [ ] User account is in correct Azure AD group
- [ ] Manager approval obtained
- [ ] Security team notified

### Subscription-Level Assignments
- [ ] Owner (via PIM - Eligible)
- [ ] Cost Management Contributor
- [ ] Billing Reader
- [ ] Reservation Purchaser (via PIM - Eligible)
- [ ] Savings plan Purchaser (via PIM - Eligible)
- [ ] Security Admin
- [ ] Resource Policy Contributor
- [ ] Monitoring Contributor

### Azure AD Assignments
- [ ] Application Administrator
- [ ] Cloud Application Administrator
- [ ] Conditional Access Administrator (if needed)

### Service-Level Assignments
- [ ] Log Analytics Contributor (on workspace)
- [ ] Microsoft Sentinel Contributor (on workspace)
- [ ] Network Contributor (on networking RGs)
- [ ] Contributor (on compute RGs)
- [ ] AcrPush, AcrPull, Contributor (on ACR)
- [ ] Key Vault Administrator (on Key Vaults)
- [ ] Cognitive Services OpenAI Contributor (on OpenAI)
- [ ] Storage Blob Data Contributor (on storage accounts, if used)

### PIM Configuration
- [ ] PIM activation settings configured
- [ ] Approvers designated
- [ ] Access review schedule set
- [ ] User trained on PIM activation process

### Verification
- [ ] Test PIM activation
- [ ] Verify access to Azure Portal
- [ ] Verify access to cost data
- [ ] Verify access to Sentinel
- [ ] Document access grant date

### Post-Assignment
- [ ] Welcome email sent with documentation links

## Document Information

**Version:** 1.0  
**Last Updated:** November 23, 2025  


