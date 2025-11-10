variable "mpc_service_account_id" {
  description = "The ID for the MPC service account"
  type        = string
  default     = "preset-mpc-sa"
}

variable "mpc_admin_role_id" {
  description = "The ID for the MPC admin custom role"
  type        = string
  default     = "PresetMPCAdminV2"
}

variable "manage_org_policy" {
  description = "Whether to manage the organization policy for allowed IAM domains. Requires Organization Admin permissions. Set to false if you don't have org admin access or prefer to manage this manually."
  type        = bool
  default     = false
}

variable "additional_allowed_domains" {
  description = "Additional organization customer IDs to allow in the IAM policy member domains constraint (beyond Preset and Datadog)"
  type        = list(string)
  default     = []
}