terraform {
  required_version = ">= 1.6.3"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
}

variable "project_id" {
  description = "Your GCP Project ID"
  type        = string
}

variable "mpc_service_account_id" {
  description = "The ID for the MPC service account (optional)"
  type        = string
  default     = "preset-mpc-sa"
}

variable "mpc_admin_role_id" {
  description = "The ID for the MPC admin custom role (optional)"
  type        = string
  default     = "PresetMPCAdminV2"
}

variable "manage_org_policy" {
  description = "Whether to manage the organization policy for allowed IAM domains. Requires Organization Admin permissions. Set to false if you don't have org admin access."
  type        = bool
  default     = true
}

locals {
  # Preset production service account
  preset_service_account = "<PROVIDED BY Preset"
}

module "preset_mpc_permissions" {
  source = "../modules/mpc-permissions"

  project_id             = var.project_id
  preset_service_account = local.preset_service_account
  mpc_service_account_id = var.mpc_service_account_id
  mpc_admin_role_id      = var.mpc_admin_role_id
  manage_org_policy      = var.manage_org_policy
}

output "mpc_service_account_email" {
  description = "The MPC service account email to provide to Preset"
  value       = module.preset_mpc_permissions.mpc_service_account_email
}

output "custom_role_id" {
  description = "The ID of the custom IAM role"
  value       = module.preset_mpc_permissions.custom_role_id
}

output "custom_role_name" {
  description = "The full name of the custom IAM role"
  value       = module.preset_mpc_permissions.custom_role_name
}

output "org_policy_managed" {
  description = "Whether the organization policy is managed by Terraform"
  value       = module.preset_mpc_permissions.org_policy_managed
}