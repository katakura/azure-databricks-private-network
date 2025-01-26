output "azurerm_databricks_access_connector_id" {
  value = azurerm_databricks_access_connector.main.id
}

output "azurerm_storage_account_dfs_endpoint" {
  value = azurerm_storage_account.main.primary_dfs_endpoint
}
