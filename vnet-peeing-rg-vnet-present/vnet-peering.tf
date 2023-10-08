# Assuming you already have the resource group and virtual networks created
provider "azurerm" {
  features {}
}
# Import the existing resource group
data "azurerm_resource_group" "existing" {
  name = "Vnet-peering-rg"
}

# Import the existing virtual networks
data "azurerm_virtual_network" "existing_1" {
  name                = "vnet01"
  resource_group_name = data.azurerm_resource_group.existing.name
}

data "azurerm_virtual_network" "existing_2" {
  name                = "vnet02"
  resource_group_name = data.azurerm_resource_group.existing.name
}

# Create virtual network peering
resource "azurerm_virtual_network_peering" "example-1" {
  name                      = "peer1to2"
  resource_group_name       = data.azurerm_resource_group.existing.name
  virtual_network_name      = data.azurerm_virtual_network.existing_1.name
  remote_virtual_network_id = data.azurerm_virtual_network.existing_2.id

  allow_virtual_network_access = true
  use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "example-2" {
  name                      = "peer2to1"
  resource_group_name       = data.azurerm_resource_group.existing.name
  virtual_network_name      = data.azurerm_virtual_network.existing_2.name
  remote_virtual_network_id = data.azurerm_virtual_network.existing_1.id

  allow_virtual_network_access = true
  use_remote_gateways          = false
}
