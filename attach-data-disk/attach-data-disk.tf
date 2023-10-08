# Configure the Azure provider
provider "azurerm" {
  features {}
}

resource "azurerm_managed_disk" "example" {
  name                 = "data-disk-01"
  location             = "East US"  # Change the location to East US
  resource_group_name  = "application-RG"  # Replace with the actual name of your existing resource group
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 10  # Use a numeric value without quotes

  tags = {
    environment = "staging"
  }
}

resource "azurerm_virtual_machine_data_disk_attachment" "example" {
  managed_disk_id    = azurerm_managed_disk.example.id
  virtual_machine_id = "/subscriptions/23a55b34-95b8-42f4-a8cd-d4c734d74f2e/resourceGroups/application-RG/providers/Microsoft.Compute/virtualMachines/Server-01"  # Replace with the actual subscription ID, resource group name, and VM name

  lun            = 1  # Use a unique LUN value if you have other disks attached
  caching        = "ReadWrite"
  create_option  = "Attach"
}
