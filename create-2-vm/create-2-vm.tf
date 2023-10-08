# Configure the Azure provider
provider "azurerm" {
  features {}
}

# Define a resource group
resource "azurerm_resource_group" "my_resource_group" {
  name     = "Application-RG"
  location = "East US"
}

# Define a virtual network
resource "azurerm_virtual_network" "my_vnet" {
  name                = "application-VNet"
  address_space       = ["172.68.0.0/16"]
  location            = azurerm_resource_group.my_resource_group.location
  resource_group_name = azurerm_resource_group.my_resource_group.name
}

# Define a subnet
resource "azurerm_subnet" "my_subnet" {
  name                 = "subnet-vm"
  resource_group_name  = azurerm_resource_group.my_resource_group.name
  virtual_network_name = azurerm_virtual_network.my_vnet.name
  address_prefixes     = ["172.68.0.0/27"]
}

# Define a public IP address
resource "azurerm_public_ip" "my_public_ip" {
  name                = "myPublicIP"
  location            = azurerm_resource_group.my_resource_group.location
  resource_group_name = azurerm_resource_group.my_resource_group.name
  allocation_method   = "Dynamic"
}

# Define a network security group (optional)
resource "azurerm_network_security_group" "my_nsg" {
  name                = "myNetworkSecurityGroup"
  location            = azurerm_resource_group.my_resource_group.location
  resource_group_name = azurerm_resource_group.my_resource_group.name
}

# Define a network interface
resource "azurerm_network_interface" "my_nic" {
  name                = "myNIC"
  location            = azurerm_resource_group.my_resource_group.location
  resource_group_name = azurerm_resource_group.my_resource_group.name

  ip_configuration {
    name                          = "myNICConfig"
    subnet_id                     = azurerm_subnet.my_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id           = azurerm_public_ip.my_public_ip.id
  }
}

# Define the first virtual machine (Server01)
resource "azurerm_virtual_machine" "my_vm" {
  name                  = "Server01"
  location              = azurerm_resource_group.my_resource_group.location
  resource_group_name   = azurerm_resource_group.my_resource_group.name
  network_interface_ids = [azurerm_network_interface.my_nic.id]
  vm_size               = "Standard_B2s"

  storage_os_disk {
    name              = "myOsDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  # Update the image reference for Windows Server 2016
  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  os_profile {
    computer_name  = "Server01"
    admin_username = "Jayendra"
    admin_password = "Yatindra@123" # Replace with your desired password
  }

  os_profile_windows_config {
    enable_automatic_upgrades = true
  }
}

# Define the second virtual machine (demo-server01)
resource "azurerm_virtual_machine" "my_demo_vm" {
  name                  = "demo-server01"
  location              = azurerm_resource_group.my_resource_group.location
  resource_group_name   = azurerm_resource_group.my_resource_group.name
  network_interface_ids = [azurerm_network_interface.my_nic.id]
  vm_size               = "Standard_B2s"

  storage_os_disk {
    name              = "demoOsDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  # Update the image reference for Windows Server 2016
  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  os_profile {
    computer_name  = "demo-server01"
    admin_username = "Jayendra" # Replace with your desired admin username
    admin_password = "Yatindra@123" # Replace with your desired password
  }

  os_profile_windows_config {
    enable_automatic_upgrades = true
  }
}
