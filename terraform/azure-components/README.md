# Azure Terraform Components Library

A comprehensive collection of reusable Terraform modules for provisioning Azure infrastructure. Each module is designed to be self-contained, well-documented, and production-ready.

## Overview

This library provides standardized Terraform modules for common Azure resources, enabling consistent and automated infrastructure provisioning across your organization without manual intervention.

## Available Modules

### Core Infrastructure
- **[resource-group](./resource-group/)** - Azure Resource Groups with tagging
- **[vnet](./vnet/)** - Virtual Networks with DNS configuration
- **[subnet](./subnet/)** - Subnets with service endpoints and delegations
- **[nsg](./nsg/)** - Network Security Groups with security rules

### Storage & Data
- **[storage-account](./storage-account/)** - Storage Accounts with network rules
- **[key vault](./key%20vault/)** - Key Vaults with access policies

### Identity & Security
- **[managed-identity](./managed-identity/)** - User-Assigned Managed Identities
- **[lock](./lock/)** - Management Locks for resource protection

### Compute
- **[vm](./vm/)** - Virtual Machines (Linux & Windows)
- **[aks](./aks/)** - Azure Kubernetes Service clusters

### Containers
- **[acr](./acr/)** - Azure Container Registry
- **[container-app-env](./container-app-env/)** - Container Apps Environment

### Networking
- **[app-gw](./app-gw/)** - Application Gateway with load balancing

### Monitoring & Management
- **[log-analytics-workspace](./log-analytics-workspace/)** - Log Analytics Workspaces
- **[backup-vaults](./backup-vaults/)** - Azure Backup Vaults

## Quick Start

### Prerequisites

1. Install [Terraform](https://www.terraform.io/downloads.html) (>= 1.0)
2. Install [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
3. Authenticate to Azure:
   ```bash
   az login
   ```

### Module Structure

Each module follows a consistent structure:
```
module-name/
├── main.tf         # Resource definitions
├── variables.tf    # Input variables
├── outputs.tf      # Output values
└── README.md       # Documentation and examples
```

### Basic Usage Example

```hcl
# Configure the Azure Provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Create a resource group
module "resource_group" {
  source   = "./resource-group"
  name     = "rg-prod-eastus-001"
  location = "eastus"
  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# Create a virtual network
module "vnet" {
  source              = "./vnet"
  name                = "vnet-prod-eastus-001"
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  address_space       = ["10.0.0.0/16"]
}

# Create a subnet
module "subnet" {
  source               = "./subnet"
  name                 = "snet-prod-web-001"
  resource_group_name  = module.resource_group.name
  virtual_network_name = module.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
  service_endpoints    = ["Microsoft.Storage", "Microsoft.KeyVault"]
}
```

## Complete Infrastructure Example

See [examples/complete-infrastructure.tf](./examples/complete-infrastructure.tf) for a full example that provisions:
- Resource group
- Virtual network and subnets
- Network security groups
- AKS cluster
- Container registry
- Key vault
- Storage account
- Log Analytics workspace

## Module Outputs

All modules provide outputs that can be referenced by other modules, enabling composition:

```hcl
# Reference outputs from one module in another
module "subnet" {
  source               = "./subnet"
  virtual_network_name = module.vnet.name  # Using output from vnet module
  resource_group_name  = module.resource_group.name
  # ... other variables
}
```

## Best Practices

1. **Naming Conventions**: Use consistent naming patterns (e.g., `rg-{env}-{region}-{instance}`)
2. **Tagging**: Always include environment, cost center, and managed-by tags
3. **Network Planning**: Plan your address spaces carefully before deployment
4. **Security**: Enable network restrictions and use managed identities
5. **State Management**: Use remote state storage (Azure Storage, Terraform Cloud)
6. **Version Control**: Pin module versions in production

## State Management

For production use, configure remote state:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "tfstateprodstorage"
    container_name       = "tfstate"
    key                  = "production.terraform.tfstate"
  }
}
```

## Input Variables Pattern

Each module accepts standardized inputs:
- `name` - Resource name
- `location` - Azure region
- `resource_group_name` - Parent resource group
- `tags` - Key-value pairs for resource tagging
- Resource-specific configuration variables

## Contributing

When adding new modules:
1. Follow the existing structure (main.tf, variables.tf, outputs.tf, README.md)
2. Include comprehensive variable descriptions
3. Provide usage examples in README.md
4. Document all outputs
5. Follow Azure naming conventions

## Folder Structure

```
azure-components/
├── acr/                    # Container Registry
├── aks/                    # Kubernetes Service
├── app-gw/                 # Application Gateway
├── backup-vaults/          # Backup Vaults
├── container-app-env/      # Container Apps
├── key vault/              # Key Vault
├── lock/                   # Resource Locks
├── log-analytics-workspace/# Monitoring
├── managed-identity/       # Managed Identities
├── nsg/                    # Network Security Groups
├── resource-group/         # Resource Groups
├── storage-account/        # Storage Accounts
├── subnet/                 # Subnets
├── vm/                     # Virtual Machines
├── vnet/                   # Virtual Networks
├── examples/               # Usage examples
└── README.md              # This file
```

## Support

For issues or questions:
1. Check the module-specific README.md
2. Review Azure documentation
3. Consult Terraform AzureRM provider documentation

## License

Internal use only - Organization proprietary modules
