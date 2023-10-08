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
  count               = 2
  name                = "myNIC-${count.index}"
  location            = azurerm_resource_group.my_resource_group.location
  resource_group_name = azurerm_resource_group.my_resource_group.name

  ip_configuration {
    name                          = "myNICConfig"
    subnet_id                     = azurerm_subnet.my_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id           = azurerm_public_ip.my_public_ip.id
  }
}

# Define the internal load balancer
resource "azurerm_lb" "my_internal_lb" {
  name                = "internal-lb"
  location            = azurerm_resource_group.my_resource_group.location
  resource_group_name = azurerm_resource_group.my_resource_group.name
  sku                 = "Basic"
  frontend_ip_configuration {
    name                 = "internal"
    subnet_id            = azurerm_subnet.my_subnet.id
  }
}

# Define the backend pool for the internal load balancer
resource "azurerm_lb_backend_address_pool" "my_internal_lb_backend" {
  name                = "backend-pool"
  lb_id               = azurerm_lb.my_internal_lb.id
}

# Define NAT rules for RDP
resource "azurerm_lb_nat_rule" "rdp_rule" {
  count               = 2
  name                = "rdp-nat-rule-${count.index}"
  lb_id               = azurerm_lb.my_internal_lb.id
  protocol            = "Tcp"
  frontend_port       = 5000 + count.index # Different frontend ports for each VM
  backend_port        = 3389
  frontend_ip_configuration_id = azurerm_lb.my_internal_lb.frontend_ip_configuration[0].id
  enable_floating_ip  = false # Change to true if you need a floating IP
  idle_timeout_in_minutes = 5 # Adjust as needed
}

# Define the first virtual machine (Server01)
resource "azurerm_virtual_machine" "my_vm" {
  count                = 1
  name                  = "Server01"
  location              = azurerm_resource_group.my_resource_group.location
  resource_group_name   = azurerm_resource_group.my_resource_group.name
  network_interface_ids = [azurerm_network_interface.my_nic[count.index].id]
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
  count                = 1
  name                  = "demo-server01"
  location              = azurerm_resource_group.my_resource_group.location
  resource_group_name   = azurerm_resource_group.my_resource_group.name
  network_interface_ids = [azurerm_network_interface.my_nic[1].id] # Use the second NIC
  vm_size               = "Standard_DS1_v2"

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
    admin_username = "YourUsername" # Replace with your desired admin username
    admin_password = "YourPassword" # Replace with your desired password
  }

  os_profile_windows_config {
    enable_automatic_upgrades = true
  }
}

# Update the NSG to allow port 445 to IP address 172.68.1.1
resource "azurerm_network_security_rule" "allow_smb" {
  name                        = "AllowSMB"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "445"
  source_address_prefix       = "*"
  destination_address_prefix  = "172.68.1.1" # Replace with your desired IP address
  resource_group_name         = azurerm_resource_group.my_resource_group.name
  network_security_group_name = azurerm_network_security_group.my_nsg.name
}
