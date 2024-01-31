provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "my_resource_group" {
  name     = "GenaisnapRg"
  location = "East US"
}

# Define a virtual network
resource "azurerm_virtual_network" "my_vnet" {
  name                = "SnapshotVNet"
  address_space       = ["172.17.0.0/16"]
  location            = azurerm_resource_group.my_resource_group.location
  resource_group_name = azurerm_resource_group.my_resource_group.name
}

# Placeholder for subnet definition
resource "azurerm_subnet" "my_subnet" {
  name                 = "genaisubnet"
  resource_group_name  = azurerm_resource_group.my_resource_group.name
  virtual_network_name = azurerm_virtual_network.my_vnet.name
  address_prefixes     = ["172.17.1.0/24"]
}

# Placeholder for public IP definition
resource "azurerm_public_ip" "my_public_ip" {
  name                = "myPublicIP01"
  location            = azurerm_resource_group.my_resource_group.location
  resource_group_name = azurerm_resource_group.my_resource_group.name
  allocation_method   = "Dynamic"
}

# Define a managed disk for the source
resource "azurerm_managed_disk" "source" {
  name                = "existingOsDisk"
  location            = azurerm_resource_group.my_resource_group.location
  resource_group_name = azurerm_resource_group.my_resource_group.name
  storage_account_type = "Standard_LRS"
  create_option       = "Copy"
  source_resource_id   = "/subscriptions/0effb92e-15ee-4f8c-8799-4776b1f3377c/resourceGroups/Genai-RG/providers/Microsoft.Compute/snapshots/myOsDisk-snapshot-1"
  disk_size_gb        = 127
  

  tags = {
    environment = "staging"
  }
}

# Define a network interface for the Windows workstation
resource "azurerm_network_interface" "windows-workstation_nic" {
  name                = "windows-nic"
  location            = azurerm_resource_group.my_resource_group.location
  resource_group_name = azurerm_resource_group.my_resource_group.name

  ip_configuration {
    name                          = "windows-nic-config"
    subnet_id                     = azurerm_subnet.my_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id           = azurerm_public_ip.my_public_ip.id
  }
}

resource "azurerm_virtual_machine" "windows-workstation" {
  name                  = "genairedeploy"
  location              = azurerm_resource_group.my_resource_group.location
  resource_group_name   = azurerm_resource_group.my_resource_group.name
  network_interface_ids = [azurerm_network_interface.windows-workstation_nic.id]
  depends_on = [azurerm_network_interface.windows-workstation_nic]
  vm_size               = "Standard_B2s"
   storage_os_disk {
    name              = "existingOsDisk"
    create_option     = "Attach"
    os_type = "Windows"
    managed_disk_id   = "${resource.azurerm_managed_disk.source.id}"
  }


}
