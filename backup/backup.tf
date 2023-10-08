# Configure the Azure provider
provider "azurerm" {
  features {}
 
}
resource "azurerm_recovery_services_vault" "example" {
  name                = "tfex-recovery-vault"
  location            = "East US"
  resource_group_name = "application-RG"
  sku                 = "Standard"
}

resource "azurerm_backup_policy_vm" "example" {
  name                = "tfex-recovery-vault-policy"
  resource_group_name = "application-RG"
  recovery_vault_name = azurerm_recovery_services_vault.example.name

  backup {
    frequency = "Daily"
    time      = "05:30"
  }
  retention_daily {
    count = 10
  }
}

data "azurerm_virtual_machine" "example" {
    
  name                = "Server-01"
  resource_group_name = "application-RG"
}

resource "azurerm_backup_protected_vm" "vm1" {
  resource_group_name = "application-RG"
  recovery_vault_name = azurerm_recovery_services_vault.example.name
  source_vm_id        = data.azurerm_virtual_machine.example.id
  backup_policy_id    = azurerm_backup_policy_vm.example.id
}