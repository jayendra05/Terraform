provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "example" {
  name     = "Vnet-peering-rg"
  location = "East US"
}

resource "azurerm_virtual_network" "example-1" {
  name                = "vnet01"
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.1.0/24"]
  location            = azurerm_resource_group.example.location
}

resource "azurerm_virtual_network" "example-2" {
  name                = "vnet02"
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.2.0/24"]
  location            = azurerm_resource_group.example.location
}

resource "azurerm_virtual_network_peering" "example-1" {
  name                      = "peer1to2"
  resource_group_name       = azurerm_resource_group.example.name
  virtual_network_name      = azurerm_virtual_network.example-1.name
  remote_virtual_network_id = azurerm_virtual_network.example-2.id
}

resource "azurerm_virtual_network_peering" "example-2" {
  name                      = "peer2to1"
  resource_group_name       = azurerm_resource_group.example.name
  virtual_network_name      = azurerm_virtual_network.example-2.name
  remote_virtual_network_id = azurerm_virtual_network.example-1.id
}
