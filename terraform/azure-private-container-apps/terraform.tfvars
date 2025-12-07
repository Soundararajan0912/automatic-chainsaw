# -----------------------------------------------------------------------------
# Sample tfvars for the Azure Container Apps + Application Gateway deployment.
# Replace placeholder IDs/values with those from your environment before running
# `terraform plan` or `terraform apply`.
# -----------------------------------------------------------------------------

resource_group_name     = "<rg-id>"
location                = "eastus"
virtual_network_id      = "/subscriptions/<sub-id>/resourceGroups/<rg-id>/providers/Microsoft.Network/virtualNetworks/<vnet>"
container_app_subnet_id = "/subscriptions/<sub-id>/resourceGroups/<rg-id>/providers/Microsoft.Network/virtualNetworks/<vnet>/subnets/<container-app-subnet>"
app_gateway_subnet_id   = "/subscriptions/<sub-id>/resourceGroups/<rg-id>/providers/Microsoft.Network/virtualNetworks/<vnet>/subnets/appgwsubnet"

name_prefix       = "aca-appgw-demo"
public_hostname   = "app.example.com"
public_ip_dns_label = "contoso-aca-appgw-eastus"
enable_https      = false

# Provide the following two values (and set enable_https = true) once you are ready for TLS.
gateway_certificate_data     = null
gateway_certificate_password = null

tags = {
  environment = "demo"
  workload    = "aca-appgw"
}

container_apps = [
  {
    name        = "app1"
    image       = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
    target_port = 80
    path        = "/"
    is_default  = true
    health_path = "/"
  },
  {
    name        = "app2"
    image       = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
    target_port = 80
    path        = "/app2/*"
    health_path = "/"
  },
  {
    name        = "app3"
    image       = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
    target_port = 80
    path        = "/app3/*"
    health_path = "/"
  }
]
