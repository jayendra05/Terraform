provider "azurerm" {
  features {}

}

resource "azurerm_resource_group" "example" {
  name     = "Demo_RG"
  location = "East US"
}
