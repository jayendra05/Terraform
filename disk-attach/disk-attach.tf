provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "my-RG" {
  name = "genaidiskrg"
  location = "East US"
}

resource "azurerm_virtual_network" "my-vnet" {
  name = "genaidiskvnet"
  address_space       = ["10.0.0.0/16"]
  location = azurerm_resource_group.my-RG.location
  resource_group_name = azurerm_resource_group.my-RG.name
}

resource "azurerm_managed_disk" "my-disk" {
  name = "genaidisk"
  location = azurerm_resource_group.my-RG.location
  resource_group_name = azurerm_resource_group.my-RG.name
  storage_account_type = "Standard_LRS"
  create_option = "Empty"
  disk_size_gb = 32
}



resource "azurerm_subnet" "my-subnet" {
  name = "genaidisksubnet"
  resource_group_name = azurerm_resource_group.my-RG.name
  virtual_network_name = azurerm_virtual_network.my-vnet.name
  address_prefixes = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "genaidisknic" {
  name                = "genaidisknic"
  location = azurerm_resource_group.my-RG.location
  resource_group_name = azurerm_resource_group.my-RG.name

  ip_configuration {
    name = "genaidisknicconfig"
    subnet_id = azurerm_subnet.my-subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine_data_disk_attachment" "genaidisk_data_attachment" {
  managed_disk_id    = azurerm_managed_disk.my-disk.id
  virtual_machine_id = azurerm_virtual_machine.my-vm.id
  lun                = 0  
  caching            = "ReadWrite"
  
}

resource "azurerm_virtual_machine" "my-vm" {
  name = "genaidiskvm"
  location = azurerm_resource_group.my-RG.location
  resource_group_name = azurerm_resource_group.my-RG.name
  network_interface_ids = [azurerm_network_interface.genaidisknic.id]
  vm_size = "Standard_B2ms"

  storage_os_disk {
    name         = "genaidiskosdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name = "genaidiskvm"
    admin_username = "azureuser"
    admin_password = "P@ssw0rd1234"
  }

  os_profile_windows_config {
    enable_automatic_upgrades = true
  }

  storage_image_reference {
    publisher= "MicrosoftWindowsServer"
    offer = "WindowsServer"
    sku  = "2016-Datacenter"
    version = "latest"
  }
}

resource "azurerm_public_ip" "genaidiskpublicip" {
  name                = "genaidiskpublicip"
  resource_group_name = azurerm_resource_group.my-RG.name
  location = azurerm_resource_group.my-RG.location
  allocation_method   = "Dynamic"
}
