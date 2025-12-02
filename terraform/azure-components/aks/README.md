# Azure Kubernetes Service Module

This module creates an Azure Kubernetes Service (AKS) cluster with configurable node pools and networking.

## Usage

```hcl
module "aks" {
  source              = "./aks"
  name                = "aks-prod-eastus-001"
  location            = "eastus"
  resource_group_name = "rg-prod-eastus-001"
  dns_prefix          = "aksprodeastus"
  kubernetes_version  = "1.28"
  
  default_node_pool = {
    name                = "default"
    node_count          = 3
    vm_size             = "Standard_D4s_v3"
    vnet_subnet_id      = "/subscriptions/.../subnets/aks-subnet"
    enable_auto_scaling = true
    min_count           = 3
    max_count           = 10
    max_pods            = 110
    os_disk_size_gb     = 128
  }
  
  identity_type = "SystemAssigned"
  
  network_profile = {
    network_plugin    = "azure"
    network_policy    = "calico"
    dns_service_ip    = "10.0.0.10"
    service_cidr      = "10.0.0.0/16"
    load_balancer_sku = "standard"
  }
  
  log_analytics_workspace_id = "/subscriptions/.../workspaces/law-id"
  
  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the AKS cluster | string | n/a | yes |
| location | Azure region where the AKS cluster will be created | string | n/a | yes |
| resource_group_name | Name of the resource group | string | n/a | yes |
| dns_prefix | DNS prefix for the AKS cluster | string | n/a | yes |
| kubernetes_version | Kubernetes version | string | null | no |
| default_node_pool | Default node pool configuration | object | n/a | yes |
| identity_type | Type of identity (SystemAssigned or UserAssigned) | string | "SystemAssigned" | no |
| identity_ids | User-assigned identity IDs | list(string) | null | no |
| network_profile | Network profile configuration | object | null | no |
| log_analytics_workspace_id | Log Analytics workspace ID for monitoring | string | null | no |
| tags | Tags to apply to the AKS cluster | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the AKS cluster |
| name | The name of the AKS cluster |
| kube_config | Kubernetes configuration (sensitive) |
| kubelet_identity | Kubelet identity object |
| node_resource_group | The auto-generated resource group for the AKS cluster nodes |
