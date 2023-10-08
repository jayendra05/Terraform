# Define the provider for Azure
provider "azurerm" {
  features {}
}

# Reference the existing virtual network
data "azurerm_virtual_network" "existing" {
  name                = "application-hub-VNet"
  resource_group_name = "application-hub-RG" # Replace with your actual resource group name
}

# Define the subnet
resource "azurerm_subnet" "app_subnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = "application-hub-RG" # Replace with your actual resource group name
  virtual_network_name = data.azurerm_virtual_network.existing.name
  address_prefixes     = ["10.10.2.0/24"] # Customize the subnet address space
}

# # Define the virtual machine
# resource "azurerm_windows_virtual_machine" "jayendra_vm" {
#   name                  = "server01"
#   resource_group_name   = "Application-RG" # Replace with your actual resource group name
#   location              = "East US"        # Replace with your desired Azure region
#   size                  = "Standard_B2s" # Customize the VM size
#   admin_username        = "Jayendra"
#   admin_password        = "Yatindra@123" # Customize the password

#   network_interface_ids = [azurerm_network_interface.app_nic.id]

#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#   }

#   source_image_reference {
#     publisher = "MicrosoftWindowsServer"
#     offer     = "WindowsServer"
#     sku       = "2019-Datacenter"
#     version   = "latest"
#   }
# }

# # Define the network interface
# resource "azurerm_network_interface" "app_nic" {
#   name                = "app-nic"
#   location            = "East US"        # Replace with your desired Azure region
#   resource_group_name = "Application-RG" # Replace with your actual resource group name

#   ip_configuration {
#     name                          = "internal"
#     subnet_id                     = azurerm_subnet.app_subnet.id
#     private_ip_address_allocation = "Dynamic"
#   }
# }
