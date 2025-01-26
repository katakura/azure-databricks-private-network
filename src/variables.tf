variable "basename" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "vnet_cidr" {
  type    = list(string)
  default = ["10.10.0.0/16"]
}

variable "databricks_public_subnet" {
  type = map(string)
  default = {
    cidr = "10.10.0.0/20"
    name = "snet-databricks-public"
  }
}

variable "databricks_private_subnet" {
  type    = map(string)
  default = {
    cidr = "10.10.16.0/20"
    name = "snet-databricks-private"
  }
}

variable "private_link_subnet" {
  type    = map(string)
  default = {
    cidr = "10.10.32.0/24"
    name = "snet-private-link"
  }
}
