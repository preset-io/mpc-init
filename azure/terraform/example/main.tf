terraform {
  required_version = ">= 1.6.3"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0"
    }
  }
}

variable "subscription_id" {
  description = "Azure subscription ID where Lighthouse will be configured"
  type        = string
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

variable "managing_tenant_id" {
  description = "Tenant ID of the managing tenant (provided by Preset)"
  type        = string
}

variable "principal_id" {
  description = "Object ID of the user/group to grant access (provided by Preset)"
  type        = string
}

variable "role" {
  description = "Role to assign: Owner, Contributor, or Reader"
  type        = string
  default     = "Contributor"
}

variable "principal_name" {
  description = "Display name for the principal"
  type        = string
  default     = "Preset MPC Admin"
}

variable "offer_name" {
  description = "Name of the Lighthouse offer"
  type        = string
  default     = "Preset MPC Management Access"
}

module "preset_mpc_permissions" {
  # source = "github.com/preset-io/mpc-init//azure/terraform/modules/mpc-permissions?ref=master"
  source = "../modules/mpc-permissions"

  managing_tenant_id = var.managing_tenant_id
  principal_id       = var.principal_id
  role               = var.role
  principal_name     = var.principal_name
  offer_name         = var.offer_name
}

output "lighthouse_definition_id" {
  description = "The ID of the Lighthouse definition"
  value       = module.preset_mpc_permissions.lighthouse_definition_id
}

output "lighthouse_assignment_id" {
  description = "The ID of the Lighthouse assignment"
  value       = module.preset_mpc_permissions.lighthouse_assignment_id
}

output "subscription_id" {
  description = "The subscription ID where Lighthouse is configured"
  value       = module.preset_mpc_permissions.subscription_id
}

output "managing_tenant_id" {
  description = "The tenant ID that now has access"
  value       = module.preset_mpc_permissions.managing_tenant_id
}
