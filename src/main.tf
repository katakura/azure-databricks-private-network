data "azurerm_subscription" "primary" {
}

resource "random_id" "random_number" {
  byte_length = 4
}

locals {
  random_number = tonumber(format("%d", random_id.random_number.dec))

  vnet_name                        = "vnet-${var.basename}"
  dbws_name                        = "dbws-${var.basename}${local.random_number}"
  dbws_access_connector_name       = "access-connector-${var.basename}"
  dbws_managed_resource_group_name = "rg-${local.dbws_name}-managed"
  public_subnet_nsg_name           = "nsg-${var.basename}-public"
  private_subnet_nsg_name          = "nsg-${var.basename}-private"
  storage_account_name             = "st${var.basename}${local.random_number}"
}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location

  tags = var.tags
}

//
// DATABRICKS WORKSPACE
//
resource "azurerm_databricks_workspace" "main" {
  name                          = local.dbws_name
  resource_group_name           = azurerm_resource_group.main.name
  location                      = azurerm_resource_group.main.location
  sku                           = "premium"
  public_network_access_enabled = true
  managed_resource_group_name   = local.dbws_managed_resource_group_name
  custom_parameters {
    virtual_network_id                                   = azurerm_virtual_network.main.id
    public_subnet_name                                   = azurerm_subnet.databricks_public.name
    private_subnet_name                                  = azurerm_subnet.databricks_private.name
    public_subnet_network_security_group_association_id  = azurerm_network_security_group.databricks_public.id
    private_subnet_network_security_group_association_id = azurerm_network_security_group.databricks_public.id
  }

  lifecycle {
    ignore_changes = all
  }
  tags = var.tags
}

resource "azurerm_databricks_access_connector" "main" {
  name                = local.dbws_access_connector_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

resource "azurerm_role_assignment" "main" {
  scope              = azurerm_storage_account.main.id
  role_definition_id = "${data.azurerm_subscription.primary.id}/providers/Microsoft.Authorization/roleDefinitions/ba92f5b4-2d11-453d-a403-e96b0029c9fe" # Storage Blob Data Contributor
  principal_id       = azurerm_databricks_access_connector.main.identity.0.principal_id
}
