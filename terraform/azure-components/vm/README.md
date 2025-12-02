# Azure Virtual Machine Module

This module creates an Azure Virtual Machine (Linux or Windows) with managed disks and managed identity.

## Usage

### Linux VM
```hcl
module "linux_vm" {
  source              = "./vm"
  name                = "vm-prod-linux-001"
  location            = "eastus"
  resource_group_name = "rg-prod-eastus-001"
  vm_size             = "Standard_D4s_v3"
  os_type             = "Linux"
  subnet_id           = "/subscriptions/.../subnets/vm-subnet"
  admin_username      = "azureuser"
  ssh_public_key      = file("~/.ssh/id_rsa.pub")
  
  source_image_reference = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
  
  identity_type = "SystemAssigned"
  
  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

### Windows VM
```hcl
module "windows_vm" {
  source              = "./vm"
  name                = "vm-prod-win-001"
  location            = "eastus"
  resource_group_name = "rg-prod-eastus-001"
  vm_size             = "Standard_D4s_v3"
  os_type             = "Windows"
  subnet_id           = "/subscriptions/.../subnets/vm-subnet"
  admin_username      = "azureadmin"
  admin_password      = "P@ssw0rd123!"
  
  source_image_reference = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
  
  identity_type = "SystemAssigned"
  
  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the virtual machine | string | n/a | yes |
| location | Azure region where the VM will be created | string | n/a | yes |
| resource_group_name | Name of the resource group | string | n/a | yes |
| vm_size | Size of the virtual machine | string | n/a | yes |
| os_type | Operating system type (Linux or Windows) | string | n/a | yes |
| subnet_id | ID of the subnet where the VM will be deployed | string | n/a | yes |
| admin_username | Admin username for the VM | string | n/a | yes |
| admin_password | Admin password for Windows VM | string | null | no |
| ssh_public_key | SSH public key for Linux VM | string | null | no |
| os_disk_storage_account_type | Storage account type for OS disk | string | "Premium_LRS" | no |
| os_disk_size_gb | Size of the OS disk in GB | number | 128 | no |
| source_image_reference | Source image reference | object | n/a | yes |
| identity_type | Type of managed identity | string | "SystemAssigned" | no |
| identity_ids | List of user-assigned managed identity IDs | list(string) | null | no |
| tags | Tags to apply to the VM | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the virtual machine |
| name | The name of the virtual machine |
| private_ip_address | The private IP address of the virtual machine |
| identity_principal_id | The principal ID of the system-assigned managed identity |
