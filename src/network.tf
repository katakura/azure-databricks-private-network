//
// VIRTUAL NETWORK
//
resource "azurerm_virtual_network" "main" {
  name                = local.vnet_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = var.vnet_cidr

  tags = var.tags
}

resource "azurerm_subnet" "databricks_public" {
  name                 = var.databricks_public_subnet.name
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.databricks_public_subnet.cidr]
  delegation {
    name = "databricks-delegation"
    service_delegation {
      name = "Microsoft.Databricks/workspaces"
    }
  }

  lifecycle {
    ignore_changes = [
      delegation
    ]
  }
}

resource "azurerm_subnet" "databricks_private" {
  name                 = var.databricks_private_subnet.name
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.databricks_private_subnet.cidr]

  delegation {
    name = "databricks-delegation"
    service_delegation {
      name = "Microsoft.Databricks/workspaces"
    }
  }

  lifecycle {
    ignore_changes = [
      delegation
    ]
  }
}

resource "azurerm_subnet" "private_link" {
  name                 = var.private_link_subnet.name
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.private_link_subnet.cidr]
}

//
// NETWORK SECURITY GROUP (PUBLIC)
//
resource "azurerm_network_security_group" "databricks_public" {
  name                = local.public_subnet_nsg_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = var.tags
}

resource "azurerm_network_security_rule" "databricks_public_outbound_100" {
  name                        = "Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-databricks-webapp"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.databricks_public.name
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "AzureDatabricks"

  lifecycle {
    ignore_changes = all
  }
}

resource "azurerm_network_security_rule" "databricks_public_outbound_102" {
  name                        = "Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-sql"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.databricks_public.name
  priority                    = 102
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3306"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "Sql"

  lifecycle {
    ignore_changes = all
  }
}

resource "azurerm_network_security_rule" "databricks_public_outbound_103" {
  name                        = "Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-storage"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.databricks_public.name
  priority                    = 103
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "Storage"

  lifecycle {
    ignore_changes = all
  }
}

resource "azurerm_network_security_rule" "databricks_public_outbound_104" {
  name                        = "Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-worker-outbound"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.databricks_public.name
  priority                    = 104
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"

  lifecycle {
    ignore_changes = all
  }
}

resource "azurerm_network_security_rule" "databricks_public_outbound_105" {
  name                        = "Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-eventhub"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.databricks_public.name
  priority                    = 105
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "9093"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "EventHub"

  lifecycle {
    ignore_changes = all
  }
}

resource "azurerm_network_security_rule" "databricks_public_inbound_100" {
  name                        = "Microsoft.Databricks-workspaces_UseOnly_databricks-control-plane-to-worker-ssh"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.databricks_public.name
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "AzureDatabricks"
  destination_address_prefix  = "VirtualNetwork"

  lifecycle {
    ignore_changes = all
  }
}

resource "azurerm_network_security_rule" "databricks_public_inbound_101" {
  name                        = "Microsoft.Databricks-workspaces_UseOnly_databricks-control-plane-to-worker-proxy"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.databricks_public.name
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "5557"
  source_address_prefix       = "AzureDatabricks"
  destination_address_prefix  = "VirtualNetwork"

  lifecycle {
    ignore_changes = all
  }
}

resource "azurerm_network_security_rule" "databricks_public_inbound_102" {
  name                        = "Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-worker-inbound"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.databricks_public.name
  priority                    = 102
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"

  lifecycle {
    ignore_changes = all
  }
}

//
// NETWORK SECURITY GROUP (PRIVATE)
//
resource "azurerm_network_security_group" "databricks_private" {
  name                = local.private_subnet_nsg_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = var.tags
}

resource "azurerm_network_security_rule" "databricks_private_outbound_100" {
  name                        = "Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-databricks-webapp"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.databricks_private.name
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "AzureDatabricks"

  lifecycle {
    ignore_changes = all
  }
}

resource "azurerm_network_security_rule" "databricks_private_outbound_102" {
  name                        = "Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-sql"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.databricks_private.name
  priority                    = 102
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3306"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "Sql"

  lifecycle {
    ignore_changes = all
  }
}

resource "azurerm_network_security_rule" "databricks_private_outbound_103" {
  name                        = "Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-storage"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.databricks_private.name
  priority                    = 103
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "Storage"

  lifecycle {
    ignore_changes = all
  }
}

resource "azurerm_network_security_rule" "databricks_private_outbound_104" {
  name                        = "Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-worker-outbound"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.databricks_private.name
  priority                    = 104
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"

  lifecycle {
    ignore_changes = all
  }
}

resource "azurerm_network_security_rule" "databricks_private_outbound_105" {
  name                        = "Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-eventhub"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.databricks_private.name
  priority                    = 105
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "9093"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "EventHub"

  lifecycle {
    ignore_changes = all
  }
}

resource "azurerm_network_security_rule" "databricks_private_inbound_100" {
  name                        = "Microsoft.Databricks-workspaces_UseOnly_databricks-control-plane-to-worker-ssh"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.databricks_private.name
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "AzureDatabricks"
  destination_address_prefix  = "VirtualNetwork"

  lifecycle {
    ignore_changes = all
  }
}

resource "azurerm_network_security_rule" "databricks_private_inbound_101" {
  name                        = "Microsoft.Databricks-workspaces_UseOnly_databricks-control-plane-to-worker-proxy"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.databricks_private.name
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "5557"
  source_address_prefix       = "AzureDatabricks"
  destination_address_prefix  = "VirtualNetwork"

  lifecycle {
    ignore_changes = all
  }
}

resource "azurerm_network_security_rule" "databricks_private_inbound_102" {
  name                        = "Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-worker-inbound"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.databricks_private.name
  priority                    = 102
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"

  lifecycle {
    ignore_changes = all
  }
}

//
// ATTACH NETWORK SECURITY GROUP TO SUBNET
//
resource "azurerm_subnet_network_security_group_association" "databricks_public" {
  network_security_group_id = azurerm_network_security_group.databricks_public.id
  subnet_id                 = azurerm_subnet.databricks_public.id
}

resource "azurerm_subnet_network_security_group_association" "databricks_private" {
  network_security_group_id = azurerm_network_security_group.databricks_private.id
  subnet_id                 = azurerm_subnet.databricks_private.id

}
