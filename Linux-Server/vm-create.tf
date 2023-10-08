provider "azurerm" {
  features {}
}
 
resource "azurerm_resource_group" "my-RG" {
  name = "application-Rg"
  location = "East US"
}
 
resource "azurerm_virtual_network" "my_vnet" {
  name = "application-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.my-RG.location
  resource_group_name = azurerm_resource_group.my-RG.name
}
 
 
resource "azurerm_subnet" "my-subnet" {
  name                 = "application-subnet"
  resource_group_name  = azurerm_resource_group.my-RG.name
  virtual_network_name = azurerm_virtual_network.my_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}
 
resource "azurerm_public_ip" "my-public-ip" {
  name = "application-public-ip"
  location = azurerm_resource_group.my-RG.location
  resource_group_name = azurerm_resource_group.my-RG.name
  allocation_method = "Dynamic"
}
 
 
resource "azurerm_network_interface" "my-nic" {
  name                = "my-nic"
  location            = azurerm_resource_group.my-RG.location
  resource_group_name = azurerm_resource_group.my-RG.name
 
  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.my-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.my-public-ip.id
  }
}
 
 
resource "azurerm_virtual_machine" "my-vm" {
  name = "Server01"
  location = azurerm_resource_group.my-RG.location
  resource_group_name = azurerm_resource_group.my-RG.name
  network_interface_ids = [azurerm_network_interface.my-nic.id]
  vm_size               = "Standard_B2s"
 
  storage_os_disk {
    name="myOSDisk"
    caching = "ReadWrite"
    create_option = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  storage_image_reference {
    publisher = "RedHat"
    offer = "RHEL"
    sku = "79-gen2"
    version   = "latest"
  }
 
  os_profile {
    computer_name = "Server01"
    admin_username = "Jayendra"
    admin_password = "Yatindra@123"
  }
 
  os_profile_linux_config {
   disable_password_authentication = false
  }
 
}
