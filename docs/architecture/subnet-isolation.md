# Azure VNet – Communication Matrix and NSG Rules

> **Current layout**
> - VNet address space: `10.0.0.0/24`
> - Subnet slices:
>   - `AppGatewaySubnet` – `10.0.0.96/27`
>   - `VMSubnet` – `10.0.0.0/28`
>   - `ContainerAppsSubnet` – `10.0.0.128/25`
>   - `PrivateEndpointsSubnet` – `10.0.0.16/28`
>   - `FutureBufferSubnet` – `10.0.0.64/27`

## Communication Matrix (Allowed Traffic Only)

| From Subnet | To Subnet/Service | Direction | Ports/Proto | Purpose | Notes |
|---|---|---|---|---|---|
| Internet | AppGatewaySubnet | Inbound | 443/TCP | Public HTTPS ingress | Allow WAF on App Gateway; permit platform health probes via AzureLoadBalancer |
| AppGatewaySubnet | ContainerAppsSubnet | Outbound | 80/443 TCP | Reverse proxy to apps | Internal Container Apps ingress via ILB; else external ingress uses infra public IP |
| AppGatewaySubnet | VMSubnet | Outbound | 80/443 TCP | Reverse proxy to VMs behind ILB | Health probes allowed via AzureLoadBalancer |
| VMSubnet | PrivateEndpoints | Outbound | 443/TCP | Access Storage/KeyVault/SQL etc. | Enforce via NSG and route; name resolution via private DNS |
| ContainerAppsSubnet | PrivateEndpoints | Outbound | 443/TCP | Access PaaS resources | UDR supported for Workload Profiles; not supported on Consumption-only env |
| Any Workload | Internet | Outbound | Blocked by default | Prevent unmanaged egress | Prefer egress via Firewall (FutureBuffer) |

---

## NSG Rules by Subnet

### AppGatewaySubnet
```text
Inbound:
- 100 Allow-HTTPS-Internet (Internet → 443/TCP)
- 110 Allow-HealthProbes (AzureLoadBalancer → Any)
- 200 Deny-EastWest (VirtualNetwork → Any)

Outbound:
- 100 Allow-Backends-to-ContainerApps (→ 10.0.0.128/25 ports 80-443 TCP)
- 110 Allow-Backends-to-VMSubnet      (→ 10.0.0.0/28 ports 80-443 TCP)
- 300 Deny-All-Else
```

### ContainerAppsSubnet (Workload Profiles)
```text
Inbound:
- 100 Allow-AppGW-to-ContainerApps (10.0.0.96/27 → 80-443 TCP)
- 120 Allow-ILB-Probes (AzureLoadBalancer → Any)
- 200 Deny-Other-Inbound

Outbound:
- 100 Allow-to-PrivateEndpoints (→ 10.0.0.16/28 443 TCP)
- 110 Allow-required-Azure-Services (→ AzureCloud 443 TCP)
- 300 Deny-Internet
```

### VMSubnet
```text
Inbound:
- 100 Allow-ILB-Frontend (AzureLoadBalancer → app ports TCP)
- 110 Allow-AppGW-Backends (10.0.0.96/27 → 80-443 TCP)
- 200 Deny-Other-Inbound

Outbound:
- 100 Allow-to-PrivateEndpoints (→ 10.0.0.16/28 443 TCP)
- 110 Allow-Required-AzureServices (→ AzureCloud 443 TCP)
- 300 Deny-Internet
```

### PrivateEndpoints (with PE network policies enabled)
```text
Inbound:
- 100 Allow-Workloads-to-PE (10.0.0.0/28 → 443 TCP)
- 110 Allow-ContainerApps-to-PE (10.0.0.128/25 → 443 TCP)
- 200 Deny-Other-Inbound

Outbound:
- 300 Deny-All-Outbound
```

### FutureBuffer (security appliances)
```text
Inbound:
- 100 Allow-Management-Platform (AzureCloud → 443 TCP)

Outbound:
- 100 Allow-Egress-Internet-via-FW (→ Internet Any)
```
