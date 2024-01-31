provider "azurerm" {
  features {}
}
variable "rg_name" {
  type        = string
  description = "Name of the resource group where the managed data disks reside"
}

variable "disk_names" {
  type        = list(string)
  description = "Names of the disks to snapshot provided in list format"
}

variable "snapshot_version" {
  type        = string
  default     = "1"
  description = "Snapshot version"
}

variable "tags" {
  description = "The tags to associate with your network and subnets."
  type        = map(string)
  default     = {
    tag1 = ""
    tag2 = ""
  }
}

data "azurerm_resource_group" "rg" {
  name = var.rg_name
}

data "azurerm_managed_disk" "disks" {
  count               = length(var.disk_names)
  name                = var.disk_names[count.index]
  resource_group_name = var.rg_name
}

resource "azurerm_snapshot" "snapshots" {
  count               = length(var.disk_names)
  name                = "${var.disk_names[count.index]}-snapshot-${replace(var.snapshot_version, ".", "-")}"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = var.rg_name
  create_option       = "Copy"
  source_uri          = element(data.azurerm_managed_disk.disks[*].id, count.index)
}

# outputs.tf

output "snapshot_ids" {
  description = "The IDs of Snapshot resources created"
  value       = ["${azurerm_snapshot.snapshots.*.id}"]
}
