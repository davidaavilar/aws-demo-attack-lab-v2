# Confiruging the Key Vault which will contains secrets like registry access keys.
#   > In similar fasion to Storage Accounts, the Key Vault will be configured with Network Rules to allow access from specific public IPs.
#     These public IPs will be the cortex platform IPs, and the terraform provisioning machine public IP.
#     In case the terraform provisioning IP was not inserted, the Storage Account will be configured as publicly accessible.

# A vault's name must be between 3-24 alphanumeric characters. The name must begin with a letter, end with a letter or digit, and not contain consecutive hyphens
resource "random_string" "key_vault_random_name" {
  length  = 17
  lower   = true
  numeric = true
  upper   = false
  special = false
}

resource "azurerm_key_vault" "outpost_key_vault" {
  name                        = "cortex-${random_string.key_vault_random_name.result}"
  location                    = var.location
  resource_group_name         = var.resource_group_name
  enabled_for_disk_encryption = true
  tenant_id                   = var.azure_tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = true
  sku_name = "standard"

  network_acls {
    bypass                     = "AzureServices"
    default_action             = var.create_public_key_vaults ? "Allow" : "Deny"
    ip_rules                   = var.platform_allowed_ips
    virtual_network_subnet_ids = [azurerm_subnet.outpost_subnet.id]
  }
  tags                   = var.tags_all
}