output "custom_role_id" {
  description = "The ID of the custom IAM role"
  value       = google_project_iam_custom_role.preset_mpc_admin.id
}

output "custom_role_name" {
  description = "The name of the custom IAM role"
  value       = google_project_iam_custom_role.preset_mpc_admin.name
}

output "mpc_service_account_email" {
  description = "The email of the MPC service account"
  value       = google_service_account.mpc_admin.email
}

output "mpc_service_account_id" {
  description = "The ID of the MPC service account"
  value       = google_service_account.mpc_admin.id
}

output "mpc_service_account_unique_id" {
  description = "The unique ID of the MPC service account"
  value       = google_service_account.mpc_admin.unique_id
}

output "org_policy_managed" {
  description = "Whether the organization policy is managed by this module"
  value       = var.manage_org_policy
}