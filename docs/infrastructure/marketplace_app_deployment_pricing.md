# Marketplace Environment Pricing Summary

## Document Purpose
Quick reference pricing guide for budget approval - showing each Azure service, its purpose, and monthly cost for both Development and Production environments.


## Total Monthly Cost Summary

| Environment | Monthly Cost | Annual Cost |
|-------------|--------------|-------------|
| **Development** | **$353** | **$4,236** |
| **Production** | **$2,160** | **$25,920** |
| **Total (Both Environments)** | **$2,513** | **$30,156** |

**Recommended Budget Request:** $2,890/month (includes 15% buffer)


## Development Environment - $353/month

### Compute Services - $76/month

| Service | Description | Monthly Cost |
|---------|-------------|--------------|
| **Azure Container Apps** | Serverless hosting for AI agent services (5 agents, scale to zero) | $6 |
| **Virtual Machine (D4s_v3)** | Backend server for databases (4 vCPU, 16GB RAM, 50% uptime with auto-shutdown) | $70 |

### Storage Services - $45/month

| Service | Description | Monthly Cost |
|---------|-------------|--------------|
| **Premium SSD OS Disk** | VM operating system disk (64GB P6) | $10 |
| **Premium SSD Data Disk** | Database storage disk (256GB P15) | $25 |
| **Azure Backup** | VM backup with 7-day retention | $10 |

### Networking Services - $170/month

| Service | Description | Monthly Cost |
|---------|-------------|--------------|
| **Application Gateway (WAF_v2)** | Public entry point with Web Application Firewall (40% allocation) | $110 |
| **Public IP Address** | Standard static IP for Application Gateway | $4 |
| **Data Transfer (Outbound)** | Internet egress traffic (500GB/month) | $35 |
| **Private Endpoints** | Secure connections to Azure services (3 endpoints) | $21 |

### Security Services - $15/month

| Service | Description | Monthly Cost |
|---------|-------------|--------------|
| **Microsoft Defender for Servers** | Threat detection and protection for VM (Plan 2) | $15 |
| **Azure Key Vault** | Secure storage for secrets and certificates (Standard tier) | $0.33 |

### Monitoring & Logging - $38/month

| Service | Description | Monthly Cost |
|---------|-------------|--------------|
| **Log Analytics** | Centralized logging and query service (beyond free tier) | $25 |
| **Application Insights** | Application performance monitoring | $10 |
| **Metrics Storage** | Time-series data storage for monitoring | $3 |

### Other Services - $9/month

| Service | Description | Monthly Cost |
|---------|-------------|--------------|
| **Azure Container Registry** | Docker image repository (Basic tier, 40% allocation) | $2 |
| **Network Watcher** | Network monitoring and flow logs (50GB/month) | $5 |
| **Azure Backup Vault** | Backup infrastructure (no separate charge) | $0 |
| **Virtual Network** | Private network infrastructure (no charge) | $0 |


## Production Environment - $2,160/month

### Compute Services - $682/month

| Service | Description | Monthly Cost |
|---------|-------------|--------------|
| **Azure Container Apps** | Serverless hosting for AI agents (10 agents, 24/7, auto-scale 1-3 replicas) | $402 |
| **Virtual Machine (D8s_v3)** | Backend server for databases (8 vCPU, 32GB RAM, 24/7 uptime) | $280 |

### Storage Services - $159/month

| Service | Description | Monthly Cost |
|---------|-------------|--------------|
| **Premium SSD OS Disk** | VM operating system disk (128GB P10) | $20 |
| **Premium SSD Data Disk** | Database storage disk (1TB P30) | $123 |
| **Azure Backup** | VM backup with 30-day retention, hourly snapshots | $16 |

### Networking Services - $370/month

| Service | Description | Monthly Cost |
|---------|-------------|--------------|
| **Application Gateway (WAF_v2)** | Public entry point with Web Application Firewall (60% allocation) | $165 |
| **Public IP Address** | Standard static IP with DDoS protection | $4 |
| **Data Transfer (Outbound)** | Internet egress traffic (2TB/month) | $165 |
| **Private Endpoints** | Secure connections to Azure services (5 endpoints) | $36 |

### Security Services - $400/month

| Service | Description | Monthly Cost |
|---------|-------------|--------------|
| **Microsoft Defender for Servers** | Threat detection and protection for VM (Plan 2) | $15 |
| **Microsoft Defender for Containers** | Container runtime security and vulnerability scanning (5 vCores) | $35 |
| **Azure Sentinel** | Security Information and Event Management (SIEM) with selective logging (5GB/day) | $150 |
| **DDoS Protection (Per-IP)** | Distributed denial of service attack mitigation | $199 |
| **Azure Key Vault** | Secure storage for secrets and certificates (Standard tier) | $1 |

### Monitoring & Logging - $383/month

| Service | Description | Monthly Cost |
|---------|-------------|--------------|
| **Log Analytics** | Centralized logging and query service (15GB/day, 90-day retention) | $345 |
| **Application Insights** | Application performance monitoring (20GB/month) | $35 |
| **Azure Monitor Alerts** | Metric and log-based alerting rules (20 metrics, 10 queries) | $3 |

### Other Services - $166/month

| Service | Description | Monthly Cost |
|---------|-------------|--------------|
| **Azure Container Registry** | Docker image repository (Basic tier, 60% allocation) | $3 |
| **Azure Bastion** | Secure VM access without public IP (Basic tier, 24/7) | $140 |
| **Network Watcher** | Network monitoring and flow logs (200GB/month) | $20 |
| **Azure Backup Vault** | Backup infrastructure (no separate charge) | $0 |
| **Virtual Network** | Private network infrastructure (no charge) | $0 |


## Cost Breakdown by Category

| Category | Dev | Prod | Total | % of Total |
|----------|-----|------|-------|------------|
| **Compute** | $76 | $682 | $758 | 30% |
| **Networking** | $170 | $370 | $540 | 21% |
| **Security** | $15 | $400 | $415 | 17% |
| **Monitoring** | $38 | $383 | $421 | 17% |
| **Storage** | $45 | $159 | $204 | 8% |
| **Other** | $9 | $166 | $175 | 7% |
| **Total** | **$353** | **$2,160** | **$2,513** | **100%** |



## Cost Optimization Opportunities

### Immediate Savings (Month 1) - Save $400/month

| Optimization | Savings | Status |
|--------------|---------|--------|
| Auto-shutdown dev VM (nights/weekends) | $30/month | Already planned ✅ |
| Container Apps scale to zero (dev) | $20/month | Already planned ✅ |
| Reduce log retention (7 days dev, 30 days prod) | $150/month | Recommended |
| Selective Sentinel logging (critical only) | $200/month | Already planned ✅ |

### 3-Month Savings - Save $260/month

| Optimization | Savings | When to Apply |
|--------------|---------|---------------|
| Azure Reserved Instances (VMs, 1-year) | $140/month | After 3 months stable usage |
| Azure Savings Plan (Container Apps, 1-year) | $80/month | After 3 months stable usage |
| Application Gateway right-sizing | $40/month | After reviewing usage patterns |

### Optimized Total Cost

| Timeframe | Current Cost | Optimized Cost | Savings |
|-----------|--------------|----------------|---------|
| **Month 1-3** | $2,513/month | $2,113/month | $400/month |
| **Month 4+** | $2,513/month | $1,853/month | $660/month |
| **Annual (Year 1)** | $30,156 | $24,420 | $5,736 |


## Key Notes

### What's Included
✅ All compute resources (serverless + VMs)  
✅ Complete networking stack (gateway, private network, data transfer)  
✅ Enterprise security (Defender, Sentinel, DDoS, WAF)  
✅ Comprehensive monitoring (Log Analytics, Application Insights)  
✅ Automated backups and disaster recovery  
✅ Development and production environments  

### What's NOT Included
❌ Azure OpenAI API usage (billed separately per token)  
❌ Premium support plans  
❌ Cross-region data replication (future phase)  
❌ Developer labor costs  
❌ Third-party software licenses  

### Pricing Assumptions
- **Region:** East US (lower cost region)
- **Payment:** Pay-as-you-go (no commitments initially)
- **Dev Uptime:** 50% (220 hours/month with auto-shutdown)
- **Prod Uptime:** 100% (730 hours/month, 24/7)
- **Agent Count:** 5 in dev, 10 in prod
- **Data Transfer:** 500GB dev, 2TB prod

### Payment Options
- **Pay-as-you-go:** Full retail pricing (used in this estimate)
- **1-Year Reserved Instances:** 40% discount on VMs (available after 3 months)
- **3-Year Reserved Instances:** 60% discount on VMs (available after 6 months)
- **Azure Savings Plan:** 20-40% discount on compute (flexible commitment)
- **Enterprise Agreement:** 10-30% discount for $100K+ annual spend


## Budget Approval Request

### Recommended Budget

| Item | Monthly | Annual (Year 1) | 3-Year Total |
|------|---------|-----------------|--------------|
| Base Infrastructure Cost | $2,513 | $30,156 | $90,468 |
| Contingency Buffer (15%) | $377 | $4,523 | $13,570 |
| **Total Budget Request** | **$2,890** | **$34,679** | **$104,038** |

### Why 15% Buffer?
- Unforeseen traffic spikes
- Additional agents beyond initial 15
- Security incidents requiring extra resources
- Testing and experimentation
- Market rate fluctuations

### Cost per Agent (Production)

| Cost Component | Per Agent | Notes |
|----------------|-----------|-------|
| Container Apps compute | $40/month | Serverless, auto-scaling |
| Database allocation (VM) | $28/month | Shared across all agents |
| Networking (Gateway) | $17/month | Shared infrastructure |
| Monitoring & Logging | $38/month | Shared observability |
| Security services | $40/month | Shared security stack |
| **Total per Agent** | **~$163/month** | For 10 agents in production |

### Scaling Cost Impact

| Scenario | Agent Count | Monthly Cost | vs. Current |
|----------|-------------|--------------|-------------|
| **Current (Planned)** | 10 agents | $2,513 | - |
| Double agents | 20 agents | $3,664 | +$1,151 (46%) |
| Triple agents | 30 agents | $4,815 | +$2,302 (92%) |



## Approval Checklist

- [ ] **Budget approved by Finance** ($2,890/month)
- [ ] **Cost allocation model approved** (chargeback to business units)
- [ ] **Reserved Instances timeline agreed** (evaluate at 3 months)
- [ ] **Cost monitoring dashboard setup** (Azure Cost Management)
- [ ] **Quarterly cost review scheduled** (with finance and engineering)
- [ ] **Chargeback process defined** (per agent, per team)
- [ ] **Contingency spend authority defined** (who approves overages)


## Comparison with Alternatives

### Option 1: Proposed Architecture (Container Apps + VM)
**Cost:** $2,513/month | **Best for:** Modern, scalable, cost-effective

### Option 2: All PaaS Services (AKS + Managed DB + Redis)
**Cost:** $2,718/month | **Best for:** Maximum automation, less management

### Option 3: VM-Only Approach (Traditional)
**Cost:** $1,592/month | **Best for:** Lower cost, more manual management

### Option 4: On-Premises
**Cost:** $1,750/month + $23,000 upfront | **Best for:** Very long-term (5+ years)

**Recommendation:** Proposed architecture offers best balance of cost, scalability, and modern cloud benefits.



## Document Information

**Version:** 1.0  
**Date:** November 23, 2025  
**Valid Until:** Pricing subject to Azure rate changes  


## Quick Reference - Monthly Costs

```
DEVELOPMENT ENVIRONMENT: $353/month
├─ Compute: $76
├─ Storage: $45
├─ Network: $170
├─ Security: $15
├─ Monitor: $38
└─ Other: $9

PRODUCTION ENVIRONMENT: $2,160/month
├─ Compute: $682
├─ Storage: $159
├─ Network: $370
├─ Security: $400
├─ Monitor: $383
└─ Other: $166

TOTAL: $2,513/month ($30,156/year)
WITH BUFFER: $2,890/month ($34,679/year)
```

