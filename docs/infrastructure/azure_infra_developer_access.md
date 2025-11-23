# Azure Infrastructure Access Guide - Developer

## Document Purpose
This document provides the access control configuration for **Developers**. It includes read-only access to Azure resources for monitoring, troubleshooting, and understanding the infrastructure without the ability to make changes.

## Table of Contents
1. [Access Overview](#access-overview)
2. [Complete Access Grant Table](#complete-access-grant-table)
3. [Azure Portal Instructions](#azure-portal-instructions)
4. [What Developers Can Do](#what-developers-can-do)
5. [What Developers Cannot Do](#what-developers-cannot-do)
6. [Common Use Cases](#common-use-cases)
7. [How to Request Additional Access](#how-to-request-additional-access)

## 1. Access Overview

### Developer Role Summary

**Purpose:** Read-only access to Azure infrastructure for visibility, monitoring, and troubleshooting

**Access Level:** Reader (view-only) with specific query access for logs and metrics

**Key Capabilities:**
- ✅ View all Azure resources and configurations
- ✅ Query logs and metrics for troubleshooting
- ✅ View application logs (Container Apps)
- ✅ View cost data (optional)
- ✅ View monitoring dashboards
- ✅ View container images (pull for local dev, optional)
- ❌ Cannot create, modify, or delete resources
- ❌ Cannot access production secrets
- ❌ Cannot deploy applications

**Total Role Assignments:** 3-6 roles


## 2. Complete Access Grant Table

### 🎯 For Admin Team: Grant These Roles to Developers

| # | Service/Area | Exact Role Name | Scope | Priority | Notes |
|---|--------------|-----------------|-------|----------|-------|
| **SUBSCRIPTION LEVEL - CORE** |
| 1 | Subscription | **Reader** | `/subscriptions/{subscription-id}` | 🔴 Critical | View all resources |
| **MONITORING & LOGGING - CORE** |
| 2 | Log Analytics | **Log Analytics Reader** | `/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.OperationalInsights/workspaces/{workspace}` | 🔴 Critical | Query logs & metrics |
| 3 | Monitoring | **Monitoring Reader** | `/subscriptions/{subscription-id}` | 🔴 Critical | View alerts & metrics |
| **OPTIONAL - BASED ON TEAM NEEDS** |
| 4 | Cost Management | **Cost Management Reader** | `/subscriptions/{subscription-id}` | 🟢 Optional | View costs (team decision) |
| 5 | Container Apps | **ContainerApp Reader** | `/subscriptions/{sub-id}/resourceGroups/rg-compute-*` | 🟡 Recommended | Better log access |
| 6 | Container Registry | **AcrPull** | `/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.ContainerRegistry/registries/{acr-name}` | 🟢 Optional | For local development |
| **DEV ENVIRONMENT ONLY** |
| 7 | Key Vault (Dev) | **Key Vault Secrets User** | `/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.KeyVault/vaults/{kv-dev-name}` | 🟡 Dev Only | Read dev secrets only |
| 8 | OpenAI (Dev) | **Cognitive Services OpenAI User** | `/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.CognitiveServices/accounts/{openai-dev-name}` | 🟡 Dev Only | Use dev AI services |



### Legend

| Symbol | Priority | Meaning |
|--------|----------|---------|
| 🔴 | Critical | Must be assigned for basic functionality |
| 🟡 | Recommended | Helpful for daily work |
| 🟢 | Optional | Nice to have, based on team needs |
| **Dev Only** | - | Only for development environment resources, NEVER production |


### ⚠️ Important Security Restrictions

**NEVER Grant Developers:**
- ❌ **Owner, Contributor, or any write access** to production
- ❌ **Key Vault access** to production secrets
- ❌ **Azure OpenAI access** to production (use Managed Identity)
- ❌ **AcrPush** (cannot push images)
- ❌ **Network Contributor** (cannot modify networking)
- ❌ **Security Admin** (cannot modify security settings)
- ❌ **Policy Contributor** (cannot modify governance)

**Why:** These restrictions protect production systems and ensure proper separation of duties.



## 3. Azure Portal Instructions

### How to Grant Developer Access

#### Standard Developer Access (Required - 3 roles)

**Role 1: Subscription Reader**
1. Go to **Azure Portal** → **Subscriptions**
2. Select the subscription
3. Click **Access control (IAM)**
4. Click **+ Add** → **Add role assignment**
5. Search for **Reader**
6. Select **Reader** role → Click **Next**
7. Click **+ Select members**
8. Search for developer email → Select user → Click **Select**
9. Click **Next** → **Review + assign**

**Role 2: Log Analytics Reader**
1. Navigate to **Log Analytics Workspace**
2. Click **Access control (IAM)**
3. Click **+ Add** → **Add role assignment**
4. Search for **Log Analytics Reader**
5. Select the role → Click **Next**
6. Click **+ Select members** → Select developer → Click **Select**
7. Click **Next** → **Review + assign**

**Role 3: Monitoring Reader**
1. Go to **Subscriptions** → Select subscription
2. Click **Access control (IAM)**
3. Click **+ Add** → **Add role assignment**
4. Search for **Monitoring Reader**
5. Select the role → Click **Next**
6. Select developer → Click **Next** → **Review + assign**


#### Optional Access (Based on Team Needs)

**Cost Management Reader (Optional)**
- Same process as above
- Role: **Cost Management Reader**
- Scope: Subscription level
- **Team Decision:** Check with manager if developers should see costs

**AcrPull for Local Development (Optional)**
- Navigate to **Container Registry** resource
- Role: **AcrPull**
- Scope: Container Registry resource
- **Use Case:** Developers need to pull images for local testing

**Container Apps Reader (Recommended)**
- Navigate to **Resource Group** (e.g., rg-compute-dev)
- Role: **ContainerApp Reader**
- Provides better access to container logs

---

#### Dev Environment Access Only

**Key Vault Secrets User (Dev Environment ONLY)**
1. Navigate to **Key Vault** (DEV environment only - e.g., kv-dev-eastus)
2. Click **Access control (IAM)**
3. Add role: **Key Vault Secrets User**
4. ⚠️ **CRITICAL:** Never grant this for production Key Vault

**OpenAI User (Dev Environment ONLY)**
1. Navigate to **Azure OpenAI** (DEV environment only)
2. Click **Access control (IAM)**
3. Add role: **Cognitive Services OpenAI User**
4. ⚠️ **CRITICAL:** Never grant this for production OpenAI


### Verification Steps

After assigning roles, verify the developer can:

✅ **View Resources**
1. Developer logs into Azure Portal
2. Navigate to resource groups
3. Can see all resources
4. Cannot see "Create", "Delete", or "Modify" buttons (grayed out)

✅ **Query Logs**
1. Navigate to Log Analytics Workspace
2. Click **Logs**
3. Can run queries and view results
4. Can view existing queries and dashboards

✅ **View Metrics**
1. Navigate to any resource (e.g., Container App)
2. Click **Metrics**
3. Can view charts and metrics
4. Cannot create alerts



## 4. What Developers Can Do

### ✅ Viewing Resources

**Subscription Level:**
- View all resource groups
- View all resources in each group
- View resource configurations (read-only)
- View resource properties
- View resource tags
- View resource locations

**Container Apps:**
- View container configurations
- View environment variables (not secret values)
- View revisions and revision history
- View scaling settings
- View ingress configurations
- View replica status

**Container Registry:**
- View repositories
- View image tags
- View image sizes and layers (if Reader access)
- Pull images (if AcrPull granted)

**Networking:**
- View virtual networks
- View subnets
- View NSG rules
- View firewall policies
- View private endpoints
- Cannot modify any network settings



### ✅ Monitoring & Troubleshooting

**Log Analytics:**
- Query application logs
- Query system logs
- View custom logs
- Create personal queries (not shared)
- View existing dashboards
- Export query results to CSV
- View log retention settings

**Example Queries Developers Can Run:**
```kusto
// View Container App logs
ContainerAppConsoleLogs_CL
| where TimeGenerated > ago(1h)
| where ContainerAppName_s == "my-app"
| order by TimeGenerated desc

// View error logs
ContainerAppConsoleLogs_CL
| where Level_s == "Error"
| where TimeGenerated > ago(24h)
| project TimeGenerated, Message_s

// View performance metrics
ContainerAppSystemLogs_CL
| where TimeGenerated > ago(1h)
| summarize avg(CpuUsage_d), avg(MemoryUsage_d) by bin(TimeGenerated, 5m)
```

**Azure Monitor:**
- View metrics for all resources
- View metric charts
- View existing alerts (cannot create)
- View alert history
- View workbooks (read-only)
- View Application Insights data

**Sentinel (if Sentinel Reader granted):**
- View security incidents (read-only)
- View security alerts
- View threat intelligence
- Cannot create rules or modify incidents


### ✅ Cost Analysis (if Cost Management Reader granted)

**What Developers Can View:**
- Daily, monthly costs
- Cost by resource group
- Cost by resource type
- Cost by location
- Cost trends and forecasts
- Budget status (if budgets exist)
- Cannot create budgets or alerts

**Use Cases:**
- Understand cost impact of resources
- Identify cost optimization opportunities
- Report cost metrics to management


### ✅ Container Operations (with appropriate access)

**With AcrPull:**
- Pull container images to local machine
- View image details
- List repositories

**Local Development Example:**
```bash
# Login to Azure Container Registry
az acr login --name <acr-name>

# Pull image
docker pull <acr-name>.azurecr.io/my-app:latest

# Run locally for testing
docker run -p 8080:80 <acr-name>.azurecr.io/my-app:latest
```

---

### ✅ Dev Environment Only (if granted)

**Key Vault (Dev):**
- Read secret values in dev environment
- View secret versions
- View certificate details
- Cannot create or modify secrets

**Azure OpenAI (Dev):**
- Call GPT-4o API from applications
- Test prompts and responses
- View usage metrics
- Cannot deploy models or change settings


## 5. What Developers Cannot Do

### ❌ Resource Management

**Cannot:**
- Create new resources
- Delete existing resources
- Modify resource configurations
- Start or stop resources
- Scale resources
- Deploy applications
- Restart services

**Why:** Prevents accidental changes to production systems



### ❌ Security & Access Control

**Cannot:**
- Assign roles to others
- Modify permissions
- Create service principals
- Generate access keys
- Modify firewall rules
- Change network security groups
- Access Key Vault secrets (production)

**Why:** Maintains security boundaries and compliance


### ❌ Configuration Changes

**Cannot:**
- Modify environment variables
- Change app settings
- Update container images
- Modify scaling policies
- Change ingress settings
- Modify network configurations

**Why:** Ensures stability and change control


### ❌ Cost Management

**Cannot:**
- Create or modify budgets
- Create cost alerts
- Purchase reservations
- View invoices (unless specifically granted)
- Export billing data

**Why:** Financial controls and accountability


### ❌ Container Registry

**Cannot:**
- Push container images
- Delete images
- Modify repository settings
- Change networking or security

**Why:** Prevents unauthorized code deployment

### ❌ Monitoring & Alerting

**Cannot:**
- Create alerts
- Modify alert rules
- Create action groups
- Modify workbooks (can create personal copies)
- Configure diagnostic settings

**Why:** Prevents alert fatigue and maintains operational standards


## 6. Common Use Cases

### Use Case 1: Troubleshooting Application Errors

**Scenario:** Application is throwing errors in production

**Developer Can:**
1. Navigate to Log Analytics Workspace
2. Query Container App logs:
   ```kusto
   ContainerAppConsoleLogs_CL
   | where TimeGenerated > ago(1h)
   | where Level_s == "Error"
   | project TimeGenerated, ContainerAppName_s, Message_s
   ```
3. Analyze error patterns
4. Check metrics for CPU/Memory spikes
5. View recent deployments (revision history)
6. Report findings to DevSecOps team

**Developer Cannot:**
- Restart the application
- Modify configuration
- Roll back deployment
- → Must request DevSecOps team to take action


### Use Case 2: Performance Analysis

**Scenario:** Need to understand application performance

**Developer Can:**
1. View Application Insights metrics
2. Query performance logs
3. View response times
4. View dependency calls
5. Create personal workbooks for analysis
6. Export data for further analysis

**Developer Cannot:**
- Modify telemetry settings
- Change sampling rates
- Configure continuous export
- → Must request DevSecOps if settings need changing


### Use Case 3: Cost Optimization Ideas

**Scenario:** Want to identify cost-saving opportunities

**Developer Can (if Cost Management Reader granted):**
1. View cost by resource
2. Identify most expensive services
3. View cost trends over time
4. Compare costs across environments
5. Provide recommendations to management

**Developer Cannot:**
- Implement changes
- Right-size resources
- Purchase reservations
- → Must propose to DevSecOps team for implementation

### Use Case 4: Local Development

**Scenario:** Need to run production-like environment locally

**Developer Can (if AcrPull granted):**
1. Pull latest container images
2. Run containers locally
3. Test against local database
4. Debug with production-like configuration (using dev secrets)

**Developer Cannot:**
- Pull production secrets
- Access production databases
- Push modified images
- → Must use dev environment credentials


### Use Case 5: Understanding Infrastructure

**Scenario:** New developer needs to understand the system

**Developer Can:**
1. Navigate Azure Portal
2. View all resource groups
3. See how services are connected
4. View network topology
5. Read configuration documentation
6. View tags and naming conventions

**Developer Cannot:**
- Make any changes
- → Read-only learning experience


## 7. How to Request Additional Access

### Access Request Process

#### Step 1: Determine What You Need
- What specific access is required?
- Which environment? (Dev, Staging, Production)
- Why is it needed?
- How long is it needed?

#### Step 2: Submit Request
**Submit to:** IT Service Desk (helpdesk@company.com)

**Include:**
```
Subject: Azure Access Request - [Your Name]

Details:
- Requested Role: [e.g., "AcrPull on dev-acr"]
- Scope: [e.g., "Development Container Registry"]
- Reason: [e.g., "Need to pull images for local testing"]
- Duration: [e.g., "Permanent" or "30 days"]
- Business Justification: [explain impact]
- Manager Approval: [manager name/email]
```

#### Step 3: Approval Process
1. Manager approves the request
2. Security team reviews for compliance
3. Infrastructure team provisions access
4. You receive confirmation email

#### Step 4: Access Review
- Access is reviewed quarterly
- Unused access may be removed
- Justification required to maintain access


### Common Access Requests

**Request:** "I need to push container images for testing"
**Response:** Use CI/CD pipeline instead. Developers should not push directly.
**Alternative:** Submit code via Git, CI/CD pipeline builds and pushes image.

**Request:** "I need access to production secrets"
**Response:** Production secrets are accessed via Managed Identity only.
**Alternative:** Use dev environment secrets, or have app fetch via Managed Identity.

**Request:** "I need to restart the production app"
**Response:** Submit incident ticket to DevSecOps team.
**Alternative:** DevSecOps team can restart or grant temporary elevated access via PIM (rare).

**Request:** "I need to view production database data"
**Response:** Use read-only replica or export process.
**Alternative:** DevSecOps can provide sanitized data export for debugging.


## 8. Tips for Developers

### 🎯 Best Practices

**Monitoring:**
- ✅ Create personal KQL query collections
- ✅ Bookmark frequently used dashboards
- ✅ Set up personal alerts (in dev environment)
- ✅ Document common troubleshooting queries

**Local Development:**
- ✅ Use dev environment for testing
- ✅ Pull latest images regularly
- ✅ Use docker-compose for local setup
- ✅ Never use production credentials locally

**Communication:**
- ✅ Report issues to DevSecOps team with logs
- ✅ Provide KQL queries that demonstrate issue
- ✅ Include timestamps and error messages
- ✅ Suggest solutions based on your analysis

**Security:**
- ✅ Never share credentials
- ✅ Use MFA for Azure access
- ✅ Log out of Azure Portal when done
- ✅ Report suspicious activity immediately


### 📊 Useful Queries for Developers

**View Container App Logs (Last Hour):**
```kusto
ContainerAppConsoleLogs_CL
| where TimeGenerated > ago(1h)
| order by TimeGenerated desc
| project TimeGenerated, ContainerAppName_s, Level_s, Message_s
```

**Find Errors in Last 24 Hours:**
```kusto
ContainerAppConsoleLogs_CL
| where TimeGenerated > ago(24h)
| where Level_s in ("Error", "Critical")
| summarize Count=count() by ContainerAppName_s, Message_s
| order by Count desc
```

**Application Performance (Response Times):**
```kusto
AppRequests
| where TimeGenerated > ago(1h)
| summarize avg(DurationMs), percentile(DurationMs, 95) by bin(TimeGenerated, 5m)
| render timechart
```

**Check Resource Health:**
```kusto
AzureMetrics
| where TimeGenerated > ago(6h)
| where MetricName in ("CpuPercentage", "MemoryPercentage")
| summarize avg(Average) by Resource, MetricName, bin(TimeGenerated, 5m)
| render timechart
```

**View Recent Deployments:**
```kusto
ContainerAppSystemLogs_CL
| where TimeGenerated > ago(7d)
| where Message_s contains "revision"
| project TimeGenerated, Message_s
| order by TimeGenerated desc
```

## Checklist for Granting Developer Access

Use this checklist when onboarding a new developer:

### Pre-Assignment
- [ ] Developer has completed security awareness training
- [ ] Developer has Azure MFA enabled
- [ ] Manager approval obtained
- [ ] Determine optional access needs (AcrPull, Cost Reader, etc.)

### Core Assignments (Required)
- [ ] Reader (Subscription level)
- [ ] Log Analytics Reader (on workspace)
- [ ] Monitoring Reader (Subscription level)

### Optional Assignments (Based on Need)
- [ ] Cost Management Reader (team decision)
- [ ] ContainerApp Reader (on compute RGs)
- [ ] AcrPull (on Container Registry, if needed)

### Dev Environment Only (If Applicable)
- [ ] Key Vault Secrets User (dev Key Vault only)
- [ ] Cognitive Services OpenAI User (dev OpenAI only)

### Verification
- [ ] Developer can log into Azure Portal
- [ ] Developer can view resources (not modify)
- [ ] Developer can query logs
- [ ] Developer can view metrics
- [ ] Developer confirms appropriate access


## Document Information

**Version:** 1.0  
**Last Updated:** November 23, 2025  

