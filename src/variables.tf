variable "basename" {
  description = "value for the basename"
  type = string
}

variable "resource_group_name" {
  description = "value for the resource group name"
  type = string
}

variable "location" {
  description = "value for the location"
  type = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type    = map(string)
  default = {}
}

variable "vnet_cidr" {
  description = "CIDR block for the VNET"
  type    = list(string)
  default = ["10.10.0.0/16"]
}

variable "databricks_public_subnet" {
  description = "values for the databricks public subnet"
  type = map(string)
  default = {
    cidr = "10.10.0.0/20"
    name = "snet-databricks-public"
  }
}

variable "databricks_private_subnet" {
  description = "values for the databricks private subnet"
  type = map(string)
  default = {
    cidr = "10.10.16.0/20"
    name = "snet-databricks-private"
  }
}

variable "private_link_subnet" {
  description = "values for the private link subnet"
  type = map(string)
  default = {
    cidr = "10.10.32.0/24"
    name = "snet-private-link"
  }
}

variable "container_names" {
  description = "List of container names to create"
  type        = list(string)
  default     = ["schema", "volume"]
}
