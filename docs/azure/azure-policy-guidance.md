# Azure Policy Guardrails

Use the policies below to enforce common security, networking, and governance requirements. Apply them at the subscription level when you want universal enforcement, or at individual resource groups when certain workloads need exceptions.

| Policy | Recommended Scope | What it enforces | Why it matters |
| --- | --- | --- | --- |
| Disallow Public IPs on Virtual Machines and NICs | Subscription (inherit to RGs) | Blocks creation of NICs or VM configurations that attach public IP addresses. | Prevents accidental exposure of compute workloads to the internet; encourages ingress through controlled entry points (Application Gateway, Firewall, Bastion). |
| Require Storage Accounts to Disable Public Network Access | Subscription | Forces `publicNetworkAccess = Disabled` so storage accounts are reachable only via private endpoints or service endpoints. | Stops data exfiltration through open blob endpoints and aligns with zero-trust networking. |
| Enforce Private Endpoints for Storage Accounts | RG (per workload) | Audits/denies storage accounts that lack at least one approved private endpoint. | Guarantees data paths stay inside Azure backbone networks and simplifies firewall rules. |
| Require HTTPS for Storage Services | Subscription | Denies any storage account that allows HTTP traffic. | Ensures encryption in transit for blob/file/queue/table endpoints. |
| Enforce Diagnostic Settings on Critical Resources | Subscription | Requires VMs, Key Vaults, Load Balancers, etc. to send logs and metrics to Log Analytics/Event Hub/Storage. | Provides centralized observability and evidence for compliance investigations. |
| Require Specific Tags on All Resources | Subscription | Blocks deployments missing required metadata (e.g., `environment`, `owner`, `costCenter`). | Enables cost allocation, automation targeting, and lifecycle management. |
| Restrict Network Security Group (NSG) Inbound Rules | Subscription | Denies NSG rules that allow `Any` source to sensitive ports (22, 3389, database ports) or full 0.0.0.0/0 access. | Reduces attack surface and enforces least privilege networking. |
| Limit VM SKUs to Approved List | RG | Allows only sanctioned VM sizes/series (e.g., Dv5, Ev5) for a specific workload. | Controls cost, enforces performance baselines, and ensures compatibility with hardening scripts. |
| Enforce Managed Identity on Virtual Machines | RG | Requires VMs to enable system-assigned or specific user-assigned managed identities. | Removes local credential sprawl and prepares workloads for secret-less authentication. |
| Require Encryption with Customer-Managed Keys (CMK) for Storage | Subscription | Audits or denies storage accounts that are not encrypted via CMK in Key Vault. | Satisfies regulatory mandates where tenants must control encryption keys. |
| Enforce Key Vault Firewall and Private Endpoints | Subscription | Denies key vaults with `publicNetworkAccess = Enabled` unless trusted services/approved IPs are set, and requires at least one private endpoint. | Prevents secrets from being reachable over the public internet and limits vault exposure. |
| Require TLS 1.2+ for App/Function Services | Subscription | Ensures App Service and Function App configurations disable TLS 1.0/1.1. | Maintains compliance with PCI/SOC and mitigates downgrade attacks. |
| Ensure Defender for Cloud Plan Assignment | Subscription | Confirms Defender plans are enabled for Servers, PaaS, and SQL resources. | Activates threat detection signals and JIT access controls across workloads. |
| Deny Public Endpoints for Azure SQL and Synapse | Subscription | Blocks deployments exposing SQL Server endpoints to the internet; requires private endpoints/service endpoints. | Protects data stores from direct internet exposure. |
| Require Just-In-Time (JIT) VM Access | Subscription | DeployIfNotExists policy that enables JIT for VMs with management ports. | Ensures RDP/SSH are only opened on demand, shrinking attack windows. |
| Restrict Resource Locations to Approved Regions | Subscription | Denies resources deployed outside the approved `allowedLocations` list. | Enforces data residency, sovereignty, and latency requirements. |
| Disable Local Auth Keys for PaaS Services | Subscription | Requires Storage, Cosmos DB, Event Hubs, etc. to use Azure AD auth instead of account keys. | Forces identity-based access and simplifies key rotation. |
| Enforce Backup Coverage for Critical Resources | Subscription | DeployIfNotExists ensures VMs/SQL servers are protected by Recovery Services Vault backups. | Guarantees recoverability and meets business continuity policies. |

Tailor the enforcement mode (Audit, Deny, DeployIfNotExists) per policy depending on whether you want soft reporting or hard blocking for each environment.

## Logging & Monitoring Guardrails
- **Diagnostic Settings**: enable policies that deploy standardized diagnostic settings targeting Log Analytics for resource types like Key Vault, Application Gateway, Azure Firewall, Load Balancers, and VNets.
- **Activity Log Export**: configure a subscription-level diagnostic setting that streams the Activity Log to a Log Analytics workspace and/or Event Hub for SIEM ingestion.
- **Azure Monitor Workbooks & Alerts**: pair policies with default workbooks/alerts (e.g., create an initiative that deploys RG-activity alerts like the Terraform module in this repo).
- **Log Analytics Workspace Configuration**: enforce data retention minimums and required solutions (VMInsights, ContainerInsights) using policy assignments.
