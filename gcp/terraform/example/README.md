# MPC Permissions Setup Example

This example demonstrates how to use the MPC permissions module to set up Preset MPC access in your GCP project.

## Prerequisites

Before running this example, ensure you have completed the prerequisites:

1. **GCP APIs Enabled:**
   ```bash
   export PROJECT_ID="your-project-id"

   gcloud services enable iam.googleapis.com \
     cloudresourcemanager.googleapis.com \
     serviceusage.googleapis.com \
     --project="$PROJECT_ID"
   ```

2. **Organization Policy (Optional - Can be managed by Terraform):**

   **Option A: Let Terraform Manage It (Recommended)**

   This example has `manage_org_policy = true` by default, which automatically configures the organization policy. Requires Organization Admin permissions.

   **Option B: Manual Setup**

   If you don't have Organization Admin permissions, set `manage_org_policy = false` in your `terraform.tfvars` and manually apply the policy:

   ```bash
   # Create policy file
   cat > project-org-policy.yaml <<EOF
   constraint: constraints/iam.allowedPolicyMemberDomains
   listPolicy:
     allowedValues:
       - C0147pk0i  # Datadog
       - C01i2thyr  # Preset.io
     inheritFromParent: true
   EOF

   # Apply the policy (requires Org Admin access)
   gcloud resource-manager org-policies set-policy \
     --project "$PROJECT_ID" project-org-policy.yaml
   ```

3. **Terraform Installed:**
   - Version >= 1.6.3

4. **GCP Authentication:**
   ```bash
   gcloud auth application-default login
   ```

## Usage

### 1. Copy the Example Configuration

```bash
cp terraform.tfvars.example terraform.tfvars
```

### 2. Edit terraform.tfvars

Edit the `terraform.tfvars` file and set your project ID:

```hcl
project_id = "your-project-id"
```

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Review the Plan

```bash
terraform plan
```

This will show you what resources will be created:
- Custom IAM role with MPC permissions
- MPC service account
- IAM bindings for Preset and MPC service accounts
- Organization policy (if `manage_org_policy = true`)

### 5. Apply the Configuration

```bash
terraform apply
```

Review the planned changes and type `yes` to proceed.

### 6. Save the Output

After successful apply, Terraform will output the MPC service account email:

```
Outputs:

custom_role_id = "projects/your-project-id/roles/PresetMPCAdmin"
custom_role_name = "projects/your-project-id/roles/PresetMPCAdmin"
mpc_service_account_email = "mpc-service-account@your-project-id.iam.gserviceaccount.com"
org_policy_managed = true
```

**Important:** Provide the `mpc_service_account_email` to your Preset contact.

## Troubleshooting

### Permission Denied

If you receive permission denied errors, ensure you have:
- Project Owner or Editor role
- `roles/iam.roleAdmin` permission
- `roles/iam.serviceAccountAdmin` permission
- `roles/resourcemanager.projectIamAdmin` permission

### Organization Policy Violation

If you see errors about organization policy constraints, ensure you've added Preset's organization to your project's allowed domains (see Prerequisites).

### API Not Enabled

If you encounter "API not enabled" errors, run the API enablement commands from the Prerequisites section.

## Migration from Deployment Manager

If you have an existing Deployment Manager deployment and want to migrate to Terraform, see the detailed migration guide: [../MIGRATION.md](../MIGRATION.md)

## Support

For issues or questions:
1. Review the module documentation at `../modules/mpc-permissions/README.md`
2. For migration issues, see `../MIGRATION.md`
3. Contact your Preset support representative
