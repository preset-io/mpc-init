# Custom IAM Role with full MPC permissions
resource "google_project_iam_custom_role" "preset_mpc_admin" {
  project     = var.project_id
  role_id     = var.mpc_admin_role_id
  title       = "Preset Admin Access Role"
  description = "This role provides Preset access to your Project."
  stage       = "GA"

  permissions = local.mpc_permissions
}

# MPC Service Account
resource "google_service_account" "mpc_admin" {
  project      = var.project_id
  account_id   = var.mpc_service_account_id
  display_name = "Preset MPC Service Account"
  description  = "Service account for Preset to manage MPC infrastructure"
}

# Allow Preset service account to impersonate the MPC service account
resource "google_service_account_iam_member" "preset_token_creator" {
  service_account_id = google_service_account.mpc_admin.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${var.preset_service_account}"
}

# Bind custom role to Preset service account
resource "google_project_iam_member" "preset_admin_access" {
  project = var.project_id
  role    = google_project_iam_custom_role.preset_mpc_admin.id
  member  = "serviceAccount:${var.preset_service_account}"
}

# Bind custom role to MPC service account
resource "google_project_iam_member" "mpc_admin_access" {
  project = var.project_id
  role    = google_project_iam_custom_role.preset_mpc_admin.id
  member  = "serviceAccount:${google_service_account.mpc_admin.email}"
}

# Organization Policy to allow Preset and Datadog service accounts
resource "google_project_organization_policy" "allowed_policy_member_domains" {
  count   = var.manage_org_policy ? 1 : 0
  project = var.project_id

  constraint = "constraints/iam.allowedPolicyMemberDomains"

  list_policy {
    allow {
      values = concat(
        [
          "C0147pk0i", # Datadog
          "C01i2thyr", # Preset.io
        ],
        var.additional_allowed_domains
      )
    }

    inherit_from_parent = true
  }
}