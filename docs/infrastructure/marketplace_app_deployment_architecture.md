# Marketplace Environment Deployment Architecture

## Document Purpose
This document outlines the planned Azure infrastructure setup for hosting the AI Agent Marketplace - a centralized platform for deploying and managing AI agents across the organization. It details the architecture, security controls, user access patterns, and rationale for design decisions.


## Table of Contents
1. [Executive Summary](#executive-summary)
2. [Environment Architecture](#environment-architecture)
3. [Infrastructure Components](#infrastructure-components)
4. [Deployment Workflow & Strategy](#deployment-workflow--strategy)
5. [Network Architecture & User Flow](#network-architecture--user-flow)
6. [Authentication & Authorization](#authentication--authorization)
7. [Security Services & Controls](#security-services--controls)
8. [Monitoring & Logging](#monitoring--logging)
9. [Cost Management Strategy](#cost-management-strategy)
10. [Scalability & Future Considerations](#scalability--future-considerations)


## 1. Executive Summary

### What is the Marketplace Environment?

The **AI Agent Marketplace** is a centralized hosting platform where AI agents developed across different business units and teams within the organization can be deployed, managed, and accessed by internal users and external stakeholders (clients, demo teams).

### Key Objectives

✅ **Centralized Hosting** - Single platform for all organizational AI agents  
✅ **Simplified Management** - Unified deployment and monitoring  
✅ **Cost Optimization** - Consolidated infrastructure for better cost tracking  
✅ **Secure Access** - SSO integration with flexible authentication options  
✅ **Self-Service** - Teams can deploy and monitor their own agents  
✅ **Production-Ready** - Two-stage deployment (dev/integration → production)


## 2. Environment Architecture

### 2.1 Subscription & Resource Group Structure

#### Single Subscription Approach
```
Azure Subscription: Marketplace-Production
├── Resource Group: rg-marketplace-dev
│   ├── Container Apps Environment (Dev)
│   ├── Virtual Machine (Dev)
│   ├── Application Gateway (Dev)
│   ├── Networking Components (Dev)
│   └── Supporting Services (Dev)
│
└── Resource Group: rg-marketplace-prod
    ├── Container Apps Environment (Prod)
    ├── Virtual Machine (Prod)
    ├── Application Gateway (Prod)
    ├── Networking Components (Prod)
    └── Supporting Services (Prod)
```

**Why Single Subscription?**
- **Simplified Cost Management** - All marketplace costs under one billing entity
- **Unified Cost Allocation** - Easy chargeback and cost analysis
- **Centralized Governance** - Single set of policies and controls
- **Resource Sharing** - Shared services (monitoring, security) across environments
- **Easier Management** - Single pane of glass for all marketplace infrastructure

**Why Separate Resource Groups?**
- **Environment Isolation** - Dev changes don't impact production
- **RBAC Boundaries** - Different access controls per environment
- **Cost Tracking** - Clear separation of dev vs production costs
- **Deployment Safety** - Prevents accidental production deployments
- **Resource Lifecycle** - Can delete/recreate dev without affecting production



### 2.2 Two-Environment Strategy

#### Development Environment (Dual Purpose)

**Primary Purpose:** Marketplace application testing and validation

**Secondary Purpose (Initial Phase):** Integration environment for agent deployment

**Components:**
- Serverless Container Apps for stateless services
- Single VM for databases and backend tools
- Private network with Application Gateway
- Dedicated monitoring and logging

**Why Dual Purpose Initially?**

1. **CI/CD Streamlining**
   - Agents from various teams deploy here first after the validation done at their dev environment 
   - Validates unified deployment approach
   - Tests CI/CD pipelines before production
   - Identifies integration issues early

2. **Stability Validation**
   - Proves deployment patterns work at scale
   - Tests multi-tenant agent hosting
   - Validates resource isolation
   - Ensures monitoring and logging work correctly

3. **Cost Efficiency**
   - Avoids creating separate integration environment initially
   - Utilizes dev environment during non-testing periods
   - Validates architecture before production investment

**Transition Plan:**
- **Phase 1 (Initial):** Dev environment hosts actual agents for stability testing
- **Phase 2 (Post-Stability):** Dedicated integration environment created (optional/ if needed )
- **Phase 3 (Mature):** Dev environment purely for marketplace app testing 


#### Production Environment

**Purpose:** Live hosting of validated AI agents for end users

**Components:**
- Serverless Container Apps for stateless services
- Single VM for databases and backend tools
- Private network with Application Gateway
- Production-grade monitoring and security

**Promotion Criteria:**
- Agent passes all tests in dev/integration
- CI/CD pipeline validated
- Performance benchmarks met
- Security scan passed
- Business approval obtained


## 3. Infrastructure Components

### 3.1 Azure Container Apps (Serverless)

**What:** Fully managed serverless container platform

**Purpose:** Host all stateless AI agent services

**Why Container Apps?**

✅ **Serverless Benefits:**
- **Scale to Zero** - No cost when agents are idle
- **Automatic Scaling** - Scales based on demand (HTTP, queue, CPU, memory)
- **No Infrastructure Management** - No VMs to patch or maintain
- **Fast Deployment** - Rapid rollout and rollback
- **Cost-Effective** - Pay only for actual usage

✅ **Perfect for AI Agents:**
- **Stateless Workloads** - Agents typically don't hold state
- **Event-Driven** - Can trigger on HTTP requests, messages, schedules
- **Microservices** - Each agent is an independent service
- **Multi-Tenant** - Isolated environments per agent
- **Resource Limits** - Control CPU/memory per agent

✅ **Developer-Friendly:**
- **Standard Containers** - Use existing Docker images
- **Revision Management** - Easy version control and rollback
- **Built-in Ingress** - HTTPS endpoints with TLS
- **Environment Variables** - Easy configuration management
- **Secrets Integration** - Direct Key Vault integration

**Configuration per Environment:**
```yaml
Dev Environment:
  Container Apps Environment: marketplace-dev-env
  Minimum Replicas: 0 (scale to zero for cost savings)
  Maximum Replicas: 10
  CPU per Container: 0.25-1 vCPU
  Memory per Container: 0.5-2 GB
  Network: Private (no public ingress)
  
Production Environment:
  Container Apps Environment: marketplace-prod-env
  Minimum Replicas: 1 (always available)
  Maximum Replicas: 20
  CPU per Container: 0.5-2 vCPU
  Memory per Container: 1-4 GB
  Network: Private (no public ingress)
```

**Use Cases in Marketplace:**
- AI agent API services
- Web interfaces for agents
- Background processing services
- Integration connectors
- Utility services


### 3.2 Virtual Machine (Backend Infrastructure)

**What:** Single VM per environment for stateful services

**Purpose:** Host databases, caching, and backend tools that require persistent state

**Why VM Instead of PaaS?**

✅ **Consolidated Backend:**
- **Single Management Point** - One VM for all backend needs
- **Cost Optimization** - More economical than multiple PaaS services initially
- **Flexibility** - Can install any database or tool needed
- **Custom Configuration** - Full control over software stack
- **Rapid Prototyping** - Easy to test different database options

✅ **What Runs on VM:**
- **Databases:**
  - PostgreSQL (with pgvector for AI embeddings)
  - MongoDB (if needed for specific agents)
  - Redis (caching and session management)
  - FalkorDB (graph database for relationships)
  - openmetadata 
  
- **Backend Tools:**
  - Message queues (RabbitMQ, Kafka)
  - ETL tools
  - Backup utilities
  - Management dashboards (Portainer, pgAdmin)

- **Supporting Services:**
  - Prometheus (metrics collection)
  - Grafana (visualization)
  - Custom monitoring tools

**VM Specifications:**

```yaml
Dev Environment VM:
  Size: Standard_D4s_v3 (4 vCPU, 16 GB RAM)
  OS: Ubuntu 22.04 LTS
  Disk: 
    - OS Disk: 128 GB Premium SSD
    - Data Disk: 100 GB Premium SSD (databases)
  Backup: Daily snapshots
  
Production Environment VM:
  Size: Standard_D8s_v3 (8 vCPU, 32 GB RAM)
  OS: Ubuntu 22.04 LTS
  Disk:
    - OS Disk: 128 GB Premium SSD
    - Data Disk: 200 GB Premium SSD (databases)
  Backup: Hourly snapshots, 30-day retention
```

**Security Hardening:**
- No public IP address
- Access via private network only
- JIT (Just-In-Time) VM access enabled
- Disk encryption enabled
- OS patching automated
- Antimalware extension installed
- File integrity monitoring

**Why Not PaaS Databases?**

**Current Approach (VM-hosted):**
- Lower initial cost
- Flexibility to change database choices
- Control over configuration and tuning
- Consolidated management

**Future Migration Path:**
- As usage grows, migrate to Azure Database for PostgreSQL
- Cost-benefit analysis at 6-month intervals
- PaaS provides better HA, backups, and scaling



### 3.3 Application Gateway

**What:** Azure Application Gateway - Layer 7 load balancer and web application firewall

**Purpose:** Single public entry point for all marketplace access

**Why Application Gateway?**

✅ **Security Benefits:**
- **Web Application Firewall (WAF)** - Protects against OWASP top 10
- **SSL Termination** - Handles TLS encryption/decryption
- **Public IP Shielding** - Backend services remain private
- **DDoS Protection** - Integrated protection against attacks
- **URL-based Routing** - Routes to correct agent service

✅ **Traffic Management:**
- **Path-Based Routing** - Different URLs route to different agents
- **Host-Based Routing** - Support for custom domains
- **Health Probes** - Automatic failover for unhealthy backends
- **Session Affinity** - Sticky sessions if needed
- **Request Redirection** - HTTP to HTTPS, etc.

✅ **Performance:**
- **Caching** - Reduce backend load
- **Compression** - Reduce bandwidth usage
- **Connection Pooling** - Efficient backend connections

**Configuration per Environment:**

```yaml
Dev Application Gateway:
  SKU: WAF_v2 (Web Application Firewall)
  Tier: Standard_v2
  Capacity: 2 instances (auto-scale)
  Public IP: 1 (Standard SKU)
  
  Listeners:
    - Port: 443 (HTTPS)
    - Port: 80 (HTTP → redirect to HTTPS)
  
  Backend Pools:
    - Container Apps (private endpoints)
    - VM services (if web-exposed)
  
  Routing Rules:
    - /agent1/* → Agent1 Container App
    - /agent2/* → Agent2 Container App
    - /admin/* → Admin Dashboard

Production Application Gateway:
  SKU: WAF_v2
  Tier: Standard_v2
  Capacity: 3 instances (auto-scale, higher capacity)
  Public IP: 1 (Standard SKU with DDoS Protection)
  
  Same structure as dev, with production backends
```

**WAF Policy:**
```yaml
WAF Mode: Prevention (blocks malicious requests)
Rule Set: OWASP 3.2
Custom Rules:
  - Rate limiting (prevent abuse)
  - Geo-blocking (if required)
  - IP allowlist/blocklist
  - Bot protection
```

**SSL/TLS Configuration:**
- Minimum TLS 1.2
- Strong cipher suites only
- Certificate from trusted CA
- Automatic certificate renewal (via Key Vault integration)



## 4. Deployment Workflow & Strategy

### 4.1 Agent Development Lifecycle

```
┌─────────────────────────────────────────────────────────────────┐
│  PHASE 1: Development at Business Unit / Team Level             │
└─────────────────────────────────────────────────────────────────┘
         │
         │ Agents developed in respective team GitHub repos
         │ Each team has their own Azure cloud environment
         │ CI/CD pipelines deploy to team's own infrastructure
         │
         ↓
┌─────────────────────────────────────────────────────────────────┐
│  PHASE 2: Validation & Testing in Team Environment              │
└─────────────────────────────────────────────────────────────────┘
         │
         │ Agent tested in team's cloud environment
         │ Functionality validated
         │ Performance benchmarked
         │ Security scanned
         │
         ↓
┌─────────────────────────────────────────────────────────────────┐
│  PHASE 3: Integration to Marketplace Dev Environment            │
└─────────────────────────────────────────────────────────────────┘
         │
         │ Agent promoted to marketplace dev/integration
         │ Deployed via unified CI/CD pipeline
         │ Tested in multi-tenant environment
         │ Monitoring and logging validated
         │ Stability assessment (runs for X days)
         │
         ↓
┌─────────────────────────────────────────────────────────────────┐
│  PHASE 4: Production Promotion                                   │
└─────────────────────────────────────────────────────────────────┘
         │
         │ Business approval obtained
         │ Automated deployment to production
         │ Health checks validated
         │ Monitoring dashboards created
         │ User access granted
         │
         ↓
┌─────────────────────────────────────────────────────────────────┐
│  PHASE 5: Production Operations                                 │
└─────────────────────────────────────────────────────────────────┘
         │
         │ Agent live and accessible
         │ Team monitors via logging dashboards
         │ Updates follow same promotion path
         │ Rollback available if issues arise
```



### 4.2 Unified Deployment Approach

**What:** Standardized CI/CD pipeline for all agent deployments

**Why Unified Approach?**

✅ **Consistency:**
- Same deployment process for all agents
- Reduces errors and troubleshooting time
- Easier onboarding for new teams

✅ **Quality Gates:**
- Automated security scanning
- Container image validation
- Configuration checks
- Health probe verification

✅ **Traceability:**
- Every deployment tracked
- Rollback capability
- Audit trail for compliance

✅ **Efficiency:**
- Faster deployments
- Reduced manual intervention
- Self-service for teams

**CI/CD Pipeline Stages:**

```yaml
1. Source Code Commit (Team Repo)
   ↓
2. Build Stage:
   - Code compilation
   - Unit tests
   - Static code analysis
   - Security scanning (SAST)
   
3. Container Build:
   - Docker image creation
   - Image vulnerability scanning
   - Image signing
   - Push to Azure Container Registry
   
4. Dev/Integration Deployment:
   - Deploy to marketplace dev environment
   - Run integration tests
   - Health check validation
   - Smoke tests
   
5. Approval Gate:
   - Manual approval for production
   - Business sign-off
   - Performance review
   
6. Production Deployment:
   - Blue-green deployment strategy
   - Deploy to production
   - Health checks
   - Traffic shifting
   
7. Post-Deployment:
   - Monitoring dashboards created
   - Alerts configured
   - Team notified
   - Documentation updated
```



### 4.3 Dev Environment as Integration Environment (Initial Phase)

**Why This Approach?**

✅ **Validates Deployment Process:**
- Tests CI/CD pipelines with real agents
- Identifies issues before production investment
- Proves multi-tenant hosting works
- Validates resource isolation

✅ **Streamlines Onboarding:**
- Teams learn deployment process in safe environment
- Build confidence in platform
- Gather feedback for improvements

✅ **Cost-Effective:**
- No need for separate integration environment initially
- Dev environment utilized fully
- Delays investment until patterns proven

**Transition Strategy:**

**Months 1-3: Dev as Integration**
- Deploy actual agents to dev environment
- Validate stability and performance
- Refine deployment processes
- Build team confidence

**Months 3-6: Hybrid Approach**
- Most stable agents promoted to production
- Dev used for both testing and new agent integration
- Consider dedicated integration environment if needed

**Month 6+: Mature State**
- Production environment hosts all stable agents
- Dev environment purely for marketplace app testing
- Optional: Dedicated integration environment for complex scenarios



## 5. Network Architecture & User Flow

### 5.1 Network Design

**Architecture Pattern:** Hub-and-Spoke with Private Networking

```
Internet
   ↓
[Application Gateway - Public IP]
   ↓
[Virtual Network: marketplace-vnet]
   ├── Subnet: gateway-subnet (Application Gateway)
   ├── Subnet: containers-subnet (Container Apps - PRIVATE)
   ├── Subnet: vm-subnet (Virtual Machine - PRIVATE)
   └── Subnet: private-endpoints-subnet (PaaS Services)
```

**Why Private Networking?**

✅ **Security:**
- **No Public Exposure** - Container Apps and VM not directly accessible
- **Attack Surface Reduction** - Only Application Gateway has public IP
- **Defense in Depth** - Multiple security layers
- **Compliance** - Meets regulatory requirements for private data

✅ **Control:**
- **All Traffic Through Gateway** - Central point for monitoring and WAF
- **Network Policies** - Control inter-service communication
- **Egress Control** - Manage outbound connections



### 5.2 User Access Flow

#### External User Journey (Browser Access)

```
┌──────────────┐
│ End User     │
│ Browser      │
└──────┬───────┘
       │
       │ Step 1: User navigates to https://marketplace.company.com
       │
       ↓
┌─────────────────────────────────────────┐
│ Public Internet                          │
└─────────────────┬───────────────────────┘
                  │
                  │ Step 2: DNS resolves to Application Gateway public IP
                  │
                  ↓
┌─────────────────────────────────────────┐
│ Application Gateway (Public IP)          │
│ - SSL/TLS Termination                    │
│ - WAF Inspection                         │
│ - Authentication (if at gateway level)   │
└─────────────────┬───────────────────────┘
                  │
                  │ Step 3: Route based on URL path
                  │         /agent1 → Agent 1 backend
                  │         /agent2 → Agent 2 backend
                  │
                  ↓
┌─────────────────────────────────────────┐
│ Private Network (VNet)                   │
│                                          │
│  ┌────────────────────────────────┐    │
│  │ Container App: Agent 1          │    │
│  │ - No public IP                  │    │
│  │ - Private endpoint only         │    │
│  │ - Receives traffic from gateway │    │
│  └────────┬───────────────────────┘    │
│           │                              │
│           │ Step 4: Agent processes     │
│           │         request              │
│           │                              │
│           ↓                              │
│  ┌────────────────────────────────┐    │
│  │ Backend Services (on VM)        │    │
│  │ - PostgreSQL database           │    │
│  │ - Redis cache                   │    │
│  │ - Private access only           │    │
│  └────────────────────────────────┘    │
└─────────────────┬───────────────────────┘
                  │
                  │ Step 5: Response flows back
                  │
                  ↓
┌─────────────────────────────────────────┐
│ Application Gateway                      │
│ - Encrypts response                      │
│ - Applies response headers               │
└─────────────────┬───────────────────────┘
                  │
                  ↓
┌──────────────┐
│ End User     │
│ Receives     │
│ Response     │
└──────────────┘
```

**Key Points:**

1. **Single Entry Point** - All traffic goes through Application Gateway
2. **No Direct Access** - Cannot access Container Apps or VM directly from internet
3. **Path-Based Routing** - URL determines which agent handles request
4. **Backend Privacy** - All backend services on private network
5. **SSL/TLS Everywhere** - Encrypted communication throughout



### 5.3 URL Structure & Routing

**Base URL:** `https://marketplace.company.com`

**URL Patterns:**

```yaml
Agent Access:
  https://marketplace.company.com/agents/sales-assistant
  https://marketplace.company.com/agents/hr-chatbot
  https://marketplace.company.com/agents/data-analyzer

Admin Interface:
  https://marketplace.company.com/admin

Health Checks:
  https://marketplace.company.com/health

API Documentation:
  https://marketplace.company.com/docs
```

**Application Gateway Routing Rules:**

```yaml
Rule 1: Agent Sales Assistant
  Path: /agents/sales-assistant/*
  Backend Pool: container-app-sales-assistant
  Backend Port: 80
  Protocol: HTTP (internal)

Rule 2: Agent HR Chatbot
  Path: /agents/hr-chatbot/*
  Backend Pool: container-app-hr-chatbot
  Backend Port: 80
  Protocol: HTTP (internal)

Rule 3: Admin Dashboard
  Path: /admin/*
  Backend Pool: container-app-admin
  Backend Port: 80
  Protocol: HTTP (internal)
  Authentication: Required
```

**Why Application Gateway as Proxy?**

✅ **Unified Entry Point:**
- Single domain for all agents
- Easier certificate management
- Centralized access logs

✅ **Security:**
- WAF protection for all agents
- Rate limiting across all traffic
- DDoS mitigation

✅ **Operational:**
- Single point for monitoring
- Easier troubleshooting
- Centralized access control



## 6. Authentication & Authorization

### 6.1 Authentication Strategy

**Dual Authentication Approach:**

The marketplace will support **two authentication methods** to accommodate different user types:

#### Option 1: Azure AD SSO (Internal Users)

**Who:** Employees, internal teams, organizational users

**How It Works:**
```
User → Application Gateway → Azure AD OAuth/OIDC → Validate → Allow Access
```

**Why SSO for Internal Users?**

✅ **Security:**
- **Single Identity Source** - No separate passwords to manage
- **MFA Enforcement** - Inherit organization's MFA policies
- **Conditional Access** - Apply security policies (device compliance, location)
- **Audit Trail** - All access logged in Azure AD

✅ **User Experience:**
- **Seamless Access** - Auto-login if already authenticated
- **No Password Fatigue** - One credential for all systems
- **Self-Service** - Password resets via Azure AD

✅ **Management:**
- **Centralized Control** - IT manages access via groups
- **Automatic Provisioning** - New employees get access automatically
- **Automatic Deprovisioning** - Access removed when employees leave

**Implementation:**
- Azure AD integrated with Application Gateway
- OAuth 2.0 / OpenID Connect protocol
- JWT tokens for session management
- Group-based access control



#### Option 2: Username & Password (External Users)

**Who:** Clients, demo teams, external partners, prospects

**How It Works:**
```
User → Login Form → Application validates credentials → Session created → Allow Access
```

**Why Username/Password for External Users?**

✅ **Flexibility:**
- **No Azure AD Required** - Clients don't need organizational accounts
- **Quick Access** - Create accounts on-demand for demos
- **Temporary Access** - Easy to create/delete demo accounts
- **Client-Friendly** - Familiar authentication method

✅ **Business Enablement:**
- **Sales Demos** - Give prospects immediate access
- **POCs** - Clients can test agents during proof-of-concept
- **Training** - External partners can access for training
- **Sandbox Accounts** - Non-production access for exploration

✅ **Control:**
- **Expiring Accounts** - Set time-limited access for demos
- **Usage Tracking** - Monitor external user activity
- **Separate User Base** - Internal and external users segregated

**Implementation:**
- Custom user database (PostgreSQL on VM)
- Password hashing (bcrypt, Argon2)
- Session management (Redis)
- Optional: Email verification, password reset



### 6.2 Where Authentication Happens

**Two Implementation Options:**

#### Option A: Application Gateway Level (API Gateway Pattern)

**Configuration:**
```
Application Gateway → Authentication Policy → Backend Services
```

**Pros:**
- ✅ Centralized authentication (one place to manage)
- ✅ All agents protected automatically
- ✅ No code changes needed in agents
- ✅ Consistent authentication across all services

**Cons:**
- ❌ Limited flexibility per agent
- ❌ Cannot have agent-specific auth logic

**Best For:**
- Internal-only access (SSO)
- Uniform authentication requirements
- API gateway pattern preferred



#### Option B: Application Level (In Marketplace App)

**Configuration:**
```
User → Application Gateway → Marketplace App → Authentication → Route to Agent
```

**Pros:**
- ✅ Flexible authentication per agent
- ✅ Support for both SSO and username/password
- ✅ Better user experience (single login page)
- ✅ Can add authorization logic

**Cons:**
- ❌ Application must handle authentication
- ❌ More complex to implement

**Best For:**
- Mixed user types (internal + external)
- Need for future authorization features
- Product-like experience


### 6.3 Recommended Approach

**Initial Phase:** Application Gateway with Azure AD SSO only
- Start with internal users
- Simplest implementation
- Validates architecture

**Future Phase:** Application-level with dual authentication
- Add username/password for external users
- Migrate SSO to application level
- Prepare for authorization features



### 6.4 Authorization Considerations

**Current State:** No fine-grained authorization

**What Users Can Do:**
- Once authenticated, access all agents in the marketplace
- View logs for agents in their assigned group
- No per-agent access control

**Future State:** Role-based access control in product architecture

**Potential Features:**
```yaml
Roles:
  - Marketplace Admin: Full access to all agents and settings
  - Agent Owner: Manage specific agents (deploy, configure, delete)
  - Agent User: Use specific agents (no management)
  - Log Viewer: View logs for specific agents only

Permissions:
  - Deploy agents
  - Delete agents
  - Configure agents
  - View agent logs
  - Manage users
  - View billing
```

**Why Not Now?**

The marketplace product architecture must be designed to support authorization. This includes:
- User-to-agent mappings in database
- Permission enforcement in code
- Admin interface for access management
- API endpoints for permission checks

**Until Then:**
- Authentication provides basic security (who you are)
- All authenticated users have same access level
- Access control via Azure AD groups for log viewing



## 7. Security Services & Controls

### 7.1 Network Security

#### Azure DDoS Protection Standard

**What:** Protection against Distributed Denial of Service attacks

**Why:**
- **Public-Facing Gateway** - Application Gateway has public IP
- **Availability Protection** - Prevents service disruption
- **Automatic Mitigation** - Detects and blocks attack traffic
- **Cost Protection** - Prevents resource exhaustion bills

**Coverage:**
- Application Gateway public IP
- Monitors traffic patterns
- Blocks malicious traffic automatically
- No impact on legitimate users



#### Network Security Groups (NSGs)

**What:** Stateful firewall rules for subnets and network interfaces

**Purpose:** Control traffic between network segments

**Configuration:**

```yaml
Gateway Subnet NSG:
  Inbound:
    - Allow: Internet → Gateway (443, 80)
    - Allow: Azure Load Balancer → Gateway (health probes)
    - Deny: All other inbound
  
  Outbound:
    - Allow: Gateway → Container Subnet
    - Allow: Gateway → VM Subnet
    - Deny: All other outbound

Container Subnet NSG:
  Inbound:
    - Allow: Gateway Subnet → Containers (80, 443)
    - Allow: Container Subnet → Container Subnet (inter-service)
    - Deny: All other inbound (including Internet)
  
  Outbound:
    - Allow: Containers → VM Subnet (database access)
    - Allow: Containers → Internet (external APIs, if needed)
    - Allow: Containers → Azure services

VM Subnet NSG:
  Inbound:
    - Allow: Container Subnet → VM (database ports)
    - Allow: Azure Bastion → VM (admin access)
    - Deny: All other inbound (including Internet)
  
  Outbound:
    - Allow: VM → Internet (updates, patches)
    - Allow: VM → Azure services (monitoring, backup)
```

**Why NSGs?**
- Micro-segmentation within VNet
- Defense in depth
- Compliance requirement
- Audit trail of network access



#### Azure Firewall (Optional Enhancement)

**What:** Centralized network firewall for egress control

**When to Add:**
- If strict egress filtering required
- If need to log all outbound connections
- If compliance requires it

**Currently:**
- Not required initially (NSGs provide sufficient control)
- Can add later if needed



### 7.2 Application Security

#### Web Application Firewall (WAF)

**What:** Layer 7 firewall integrated with Application Gateway

**Purpose:** Protect against web application attacks

**Protection Against:**
- SQL Injection
- Cross-Site Scripting (XSS)
- Cross-Site Request Forgery (CSRF)
- Remote File Inclusion
- Command Injection
- Session Hijacking
- Malicious Bots

**Rule Sets:**
- OWASP Core Rule Set 3.2
- Bot protection rules
- Custom rules for rate limiting

**Mode:**
- **Development:** Detection mode (log but don't block)
- **Production:** Prevention mode (block malicious requests)

**Why WAF?**
- Agents may have vulnerabilities
- Protects all agents uniformly
- Compliance requirement for public-facing apps
- No code changes needed in agents



#### Container Security

**What:** Multiple layers of container security

**Components:**

**1. Container Image Scanning:**
- Scan images for vulnerabilities before deployment
- Block images with critical vulnerabilities
- Regular rescanning of running images
- Integration with CI/CD pipeline

**2. Microsoft Defender for Containers:**
- Runtime threat detection
- Suspicious activity alerts
- Kubernetes security (if using AKS later)
- Vulnerability assessment

**3. Container Registry Security:**
- Content trust (image signing)
- RBAC for registry access
- Private network access only
- Audit logging of all image operations

**4. Container Apps Security:**
- No privileged containers
- Read-only root filesystem (where possible)
- Resource limits enforced
- Network policies applied

**Why Container Security?**
- Containers can have vulnerabilities
- Supply chain attacks are real
- Compliance requirements
- Protect multi-tenant environment



### 7.3 Compute Security

#### Virtual Machine Security

**What:** Comprehensive VM hardening

**Components:**

**1. Microsoft Defender for Servers (Plan 2):**
- Threat detection for VMs
- File integrity monitoring
- Adaptive application controls
- Vulnerability assessment
- Just-in-time VM access

**2. JIT (Just-In-Time) VM Access:**
- Management ports (SSH) closed by default
- Open ports only when needed
- Time-limited access (max 3 hours)
- Audit trail of all access
- Requires approval

**3. Azure Disk Encryption:**
- OS disk encrypted at rest
- Data disk encrypted at rest
- BitLocker (Windows) / dm-crypt (Linux)
- Keys stored in Azure Key Vault

**4. Update Management:**
- Automated OS patching
- Security updates prioritized
- Maintenance windows configured
- Rollback capability

**5. Antimalware Extension:**
- Real-time protection
- Scheduled scans
- Automatic definition updates
- Alert on threats detected

**6. Azure Bastion (Admin Access):**
- No public IP on VM
- RDP/SSH via Azure Portal
- No need for VPN
- MFA required
- Session recording

**Why VM Security?**
- VM holds sensitive data (databases)
- Attack vector if compromised
- Compliance requirements
- Best practice for IaaS



### 7.4 Data Security

#### Azure Key Vault

**What:** Secure storage for secrets, keys, and certificates

**Purpose:** Centralized secrets management

**What's Stored:**
- Database connection strings
- API keys for external services
- SSL/TLS certificates
- Encryption keys
- Service principal credentials

**Security Features:**
- Hardware Security Module (HSM) backing (Premium tier)
- Soft delete enabled (90-day retention)
- Purge protection enabled
- Private endpoint access only
- RBAC for access control
- Audit logging to Log Analytics

**Access Pattern:**
- Container Apps use Managed Identity
- VM uses Managed Identity
- No credentials in code or config files
- Automatic secret rotation (where possible)

**Why Key Vault?**
- Never store secrets in code
- Centralized secret management
- Audit trail of secret access
- Compliance requirement



#### Backup & Disaster Recovery

**What:** Automated backup solutions

**VM Backup:**
```yaml
Azure Backup for VMs:
  Frequency: 
    - Dev: Daily at 2 AM
    - Prod: Hourly (RPO: 1 hour)
  
  Retention:
    - Dev: 7 days
    - Prod: 30 days (daily), 12 months (weekly), 7 years (yearly)
  
  Features:
    - Application-consistent backups
    - File-level restore
    - Full VM restore
    - Cross-region restore (prod)
```

**Database Backup:**
```yaml
PostgreSQL Backup:
  Method: pg_dump + Azure Blob Storage
  Frequency: Every 6 hours
  Retention: 30 days (dev), 90 days (prod)
  Encryption: AES-256
  Testing: Monthly restore tests

Transaction Log Backup:
  Frequency: Every 15 minutes
  RPO: 15 minutes
```

**Container Apps:**
- Stateless, no backup needed
- Configuration stored in Git (Infrastructure as Code)
- Redeploy from CI/CD if needed

**Why Backup?**
- Data loss protection
- Ransomware recovery
- Compliance requirement
- Business continuity



### 7.5 Monitoring & Threat Detection

#### Azure Sentinel (SIEM)

**What:** Security Information and Event Management system

**Purpose:** Centralized security monitoring and incident response

**Data Sources:**
- Azure Activity Logs (who did what in Azure)
- Azure AD Sign-in Logs (authentication events)
- Microsoft Defender for Cloud alerts
- Network Security Group flow logs
- Application Gateway logs
- VM security logs
- Container Apps logs
- Key Vault access logs

**Detection Rules:**
- Suspicious login attempts (brute force)
- Unusual resource creation
- High-privilege role assignment
- Key Vault anomalies
- VM compromise indicators
- Container escape attempts
- Unusual network traffic

**Automated Response (Playbooks):**
- Block suspicious IP addresses
- Disable compromised accounts
- Isolate compromised VMs
- Notify security team
- Create incident tickets

**Why Sentinel?**
- Centralized security view
- Automated threat detection
- Faster incident response
- Compliance requirement



#### Azure Monitor & Log Analytics

**What:** Comprehensive monitoring and logging platform

**Purpose:** Operational monitoring and troubleshooting

**Metrics Collected:**
```yaml
Container Apps:
  - Request count and latency
  - CPU and memory usage
  - Replica count
  - Error rate
  - Request queue length

VM:
  - CPU, memory, disk, network
  - Database performance (via extensions)
  - Process monitoring
  - Disk IOPS

Application Gateway:
  - Request count
  - Failed requests
  - Backend health
  - WAF events
```

**Logs Collected:**
```yaml
Application Logs:
  - Container stdout/stderr
  - Application error logs
  - Request/response logs
  - Performance traces

Infrastructure Logs:
  - VM syslog
  - Azure Activity Log
  - Resource diagnostic logs
  - Network flow logs
```

**Alerting:**
```yaml
Critical Alerts:
  - Container app down
  - VM CPU > 90% for 5 minutes
  - Database connection failures
  - Application Gateway backend unhealthy
  - Disk space < 10%

Warning Alerts:
  - High error rate (> 5%)
  - Slow response times (> 2 seconds)
  - Memory usage > 80%
  - Backup failures
```

**Dashboards:**
- Marketplace overview dashboard
- Per-agent performance dashboard
- Infrastructure health dashboard
- Security dashboard

**Why Monitor & Log Analytics?**
- Operational visibility
- Troubleshooting capability
- Performance optimization
- SLA tracking


## 8. Monitoring & Logging

### 8.1 End-User Access to Logs

**What:** Self-service log access for agent teams

**Purpose:** Allow teams to debug their own agents without DevSecOps intervention

**Implementation:**

```yaml
Azure AD Groups:
  Group: AgentTeam-SalesAssistant
    Members: Sales team developers
    Access: Log Analytics Reader for sales-assistant logs
  
  Group: AgentTeam-HRChatbot
    Members: HR team developers
    Access: Log Analytics Reader for hr-chatbot logs
  
  Group: AgentTeam-DataAnalyzer
    Members: Data team developers
    Access: Log Analytics Reader for data-analyzer logs
```

**How It Works:**

1. **Azure AD Group Creation:**
   - Create group per agent team
   - Add team members to group
   - Assign "Log Analytics Reader" role to group

2. **Log Filtering:**
   - Each team sees only their agent's logs
   - Implemented via Log Analytics workspace access control
   - Or via separate workspace per agent (if needed)

3. **Access Pattern:**
   - Team member logs into Azure Portal
   - Navigates to Log Analytics
   - Runs queries filtered to their agent
   - Cannot see other agents' logs

**Sample Queries Teams Can Run:**

```kusto
// View my agent's logs from last hour
ContainerAppConsoleLogs_CL
| where ContainerAppName_s == "sales-assistant"
| where TimeGenerated > ago(1h)
| order by TimeGenerated desc

// Find errors in my agent
ContainerAppConsoleLogs_CL
| where ContainerAppName_s == "sales-assistant"
| where Level_s == "Error"
| summarize count() by Message_s

// Performance analysis
ContainerAppSystemLogs_CL
| where ContainerAppName_s == "sales-assistant"
| summarize avg(ResponseTimeMs) by bin(TimeGenerated, 5m)
| render timechart
```

**What Teams Can Do:**
- ✅ View logs for their agent
- ✅ Query and analyze data
- ✅ Create personal dashboards
- ✅ Export log data
- ✅ Set up personal alerts (in their scope)

**What Teams Cannot Do:**
- ❌ View logs for other agents
- ❌ Modify log settings
- ❌ Delete logs
- ❌ Access infrastructure logs
- ❌ Change retention policies

**Why This Approach?**

✅ **Self-Service:**
- Teams don't wait for DevSecOps
- Faster troubleshooting
- More ownership

✅ **Security:**
- Each team sees only their data
- No cross-team data leakage
- Audit trail of log access

✅ **Scalability:**
- Doesn't overload DevSecOps team
- Teams become self-sufficient
- Better developer experience

### 8.2 Shared Monitoring Infrastructure

**What:** Central monitoring for marketplace platform

**Who Has Access:** DevSecOps team, Infrastructure team

**What's Monitored:**
- Application Gateway health
- VM performance and health
- Container Apps platform metrics
- Network performance
- Security alerts
- Backup status
- Cost metrics

**Dashboards:**
```yaml
Platform Health Dashboard:
  - Overall system health
  - Service availability (SLA tracking)
  - Resource utilization
  - Cost trending

Security Dashboard:
  - Active security alerts
  - WAF events
  - Failed login attempts
  - Suspicious activity

Capacity Dashboard:
  - Container replica counts
  - VM resource usage
  - Database size and growth
  - Network bandwidth
```



## 9. Cost Management Strategy

### 9.1 Why Single Subscription?

**Cost Visibility:**
- All marketplace costs in one place
- Easy to see total platform cost
- Simple chargeback to business units

**Cost Allocation:**
```yaml
Tag Strategy:
  Environment: dev | prod
  AgentName: sales-assistant | hr-chatbot | ...
  Team: sales | hr | data | ...
  CostCenter: 1001 | 1002 | ...

Cost Analysis Views:
  - Cost by Environment
  - Cost by Agent
  - Cost by Team
  - Cost per User (if tracking usage)
```

**Budget Alerts:**
```yaml
Dev Environment:
  Monthly Budget: $500
  Alerts: 80%, 100%, 120%

Prod Environment:
  Monthly Budget: $2000
  Alerts: 80%, 100%, 120%

Per-Agent Budget (Optional):
  Budget: $100/month per agent
  Alert when exceeded
```

### 9.2 Cost Optimization

**Container Apps:**
- Scale to zero in dev (when not in use)
- Minimum replicas = 0 for non-critical agents
- Right-size CPU and memory per agent

**VM:**
- Right-size based on usage patterns
- Consider Azure Reserved Instances (after 3 months)
- Auto-shutdown in dev (nights and weekends)

**Storage:**
- Use appropriate disk tier (Premium vs Standard)
- Lifecycle policies for old logs and backups
- Compress backups

**Networking:**
- Application Gateway auto-scaling (don't over-provision)
- Monitor data transfer costs
- Use private endpoints to avoid egress charges

**Monitoring:**
- Set log retention appropriately (90 days vs 365 days)
- Archive old logs to cheaper storage
- Use Log Analytics commitment tiers if usage is high



## 10. Scalability & Future Considerations

### 10.1 Horizontal Scaling

**Container Apps:**
- Automatic scaling based on load
- Scale out to 20+ replicas in production
- Scale to zero in dev (cost savings)

**VM Scaling:**
- Vertical scaling (increase VM size if needed)
- Future: Migrate to Azure Database for PostgreSQL (PaaS)
- Future: Separate VMs for different databases


### 10.2 Multi-Region (Future)

**When Needed:**
- High availability requirements (99.99% SLA)
- Disaster recovery across regions
- Serve users in multiple geographies

**Potential Architecture:**
```
Primary Region: East US
  - All components
  - Active workloads

Secondary Region: West US
  - Replicated databases
  - Cold standby
  - Failover target
```


### 10.3 Migration to PaaS (Future)

**Current:** VM-hosted databases  
**Future:** Azure Database for PostgreSQL

**When to Migrate:**
- Usage grows beyond single VM capacity
- HA and DR requirements increase
- Team prefers managed services
- Cost-benefit becomes favorable

**Benefits:**
- Automatic backups and HA
- Built-in patching and updates
- Better performance at scale
- Point-in-time restore
- Cross-region replication



## Summary

### Key Architectural Decisions

| Decision | Rationale |
|----------|-----------|
| **Single Subscription** | Simplified cost management and governance |
| **Two Resource Groups** | Environment isolation and cost tracking |
| **Serverless Container Apps** | Cost-effective, auto-scaling, stateless workloads |
| **Single VM per Environment** | Consolidated backend, cost-effective initially |
| **Application Gateway** | Secure public entry, WAF protection, routing |
| **Private Networking** | Security, compliance, attack surface reduction |
| **Dev as Integration (Initially)** | Validate deployment process, cost-effective |
| **Dual Authentication** | Support internal (SSO) and external (demo) users |
| **Group-Based Log Access** | Self-service for teams, security boundaries |

### Security Highlights

✅ DDoS Protection  
✅ Web Application Firewall  
✅ Network Security Groups  
✅ Container Security (Defender + Scanning)  
✅ VM Security (Defender + JIT + Encryption)  
✅ Azure Sentinel (SIEM)  
✅ Key Vault (Secrets Management)  
✅ Azure Monitor & Log Analytics  
✅ Automated Backups  
✅ Private Networking  


## Document Information

**Version:** 1.0  
**Last Updated:** November 23, 2025  


