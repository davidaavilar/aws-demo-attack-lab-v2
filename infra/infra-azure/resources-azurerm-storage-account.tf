# Configuring the Outpost Storage Account. The Storage Account is configured with Network Rules to allow access from specific public IPs.
#    > These public IPs will be the cortex platform IPs, and the terraform provisioning machine public IP.
#      In case the terraform provisioning IP was not inserted, the Storage Account will be configured as publicly accessible.

resource "random_string" "storage_account_random_name" {
  length  = 24
  lower   = true
  numeric = true
  upper   = false
  special = false
}

resource "azurerm_storage_account" "storage_account" {
  # checkov:skip=CKV2_AZURE_1:This Storage Account contains scan metadata and telemetry, therefore using Customer Managed Key encryption is not required. The default Azure-managed encryption will be used
  # checkov:skip=CKV2_AZURE_33:Private endpoint is not required - storage account needs public access from Cortex Platform running in GCP with IP restrictions
  name                     = random_string.storage_account_random_name.result
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # TLS1_2 is the default, but it should be explicitly defined to
  # make SAST happy
  min_tls_version = "TLS1_2"

  #CSB policy requirements
  infrastructure_encryption_enabled = true
  cross_tenant_replication_enabled  = false
  allow_nested_items_to_be_public   = false
  # This is required to allow access from the Cortex Single Tenant, which runs in GCP. We limit the traffic to allow only
  #   specific known IP Addresses to access the storage account.
  public_network_access_enabled = true
  sas_policy {
    expiration_period = var.sas_policy_expiration_period
  }
  network_rules {
    default_action             = var.create_public_storage_accounts ? "Allow" : "Deny"
    ip_rules                   = var.platform_allowed_ips
    virtual_network_subnet_ids = [azurerm_subnet.outpost_subnet.id]
  }
  tags = var.tags_all
}