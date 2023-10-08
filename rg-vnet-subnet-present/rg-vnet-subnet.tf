provider "azurerm" {
  features {}
}

resource "azurerm_public_ip" "my-public-ip" {
  name                = "public-ip-1"
  location            = "East US"
  resource_group_name = "Linux-Patching-RG"
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "my-nic" {
  name                = "my-nic-1"
  location            = "East US"
  resource_group_name = "Linux-Patching-RG"

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "/subscriptions/23a55b34-95b8-42f4-a8cd-d4c734d74f2e/resourceGroups/Linux-Patching-RG/providers/Microsoft.Network/virtualNetworks/patching-vnet/subnets/Subnet-VM"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id           = azurerm_public_ip.my-public-ip.id
  }
}

resource "azurerm_virtual_machine" "my-vm" {
  name                = "Server01"
  location            = "East US"
  resource_group_name = "Linux-Patching-RG"
  network_interface_ids = [azurerm_network_interface.my-nic.id]
  vm_size             = "Standard_B2s"

  storage_os_disk {
    name              = "myOSDisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "79-gen2"
    version   = "latest"
  }

  os_profile {
    computer_name  = "Redhat01"
    admin_username = "Jayendra"
    admin_password = "Yatindra@123"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}
