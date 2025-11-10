# Migrating from Deployment Manager to Terraform

This guide provides simple instructions for migrating your existing Preset MPC permissions setup from Google Cloud Deployment Manager to Terraform using a **side-by-side migration** approach.

## Overview

Google Cloud Platform is deprecating Deployment Manager. If you previously set up MPC permissions using the Deployment Manager template (`preset-mpc-org`), you can easily migrate to Terraform by creating new resources alongside your existing ones, then switching over.

### Why Side-by-Side Migration?

This approach is **much simpler** than trying to import existing resources:
- ✅ **Zero risk** - Old resources stay untouched during migration
- ✅ **Dead simple** - Just run `terraform apply`, no complex import commands
- ✅ **Testable** - Verify new setup works before Preset switches over
- ✅ **Easy rollback** - If anything breaks, old resources are still there
- ✅ **No support burden** - No troubleshooting import failures

The "cost" is temporarily having two sets of resources (very low cost), which can be cleaned up after migration.

## Migration Process

The migration happens in 5 simple steps:

```
1. Verify existing Deployment Manager resources
2. Create NEW resources with Terraform (alongside old ones)
3. Provide NEW service account email to Preset
4. Wait for Preset to switch over and confirm
5. Clean up old resources
```

## Prerequisites

Before starting the migration:

1. **Install Terraform:**
   - Version >= 1.6.3

2. **Authenticate with GCP:**
   ```bash
   gcloud auth application-default login
   ```

3. **Set your project ID:**
   ```bash
   export PROJECT_ID="your-project-id"
   ```

## Step 1: Verify Existing Resources

First, confirm your existing Deployment Manager resources:

```bash
# List Deployment Manager deployments
gcloud deployment-manager deployments list --project="$PROJECT_ID"

# You should see 'preset-mpc-org' deployment
```

Verify existing resources that will remain unchanged:

```bash
# Old custom role (will stay)
gcloud iam roles describe PresetMPCAdmin --project="$PROJECT_ID" 2>/dev/null && echo "✓ Old role exists"

# Old service account (will stay)
gcloud iam service-accounts describe mpc-service-account@${PROJECT_ID}.iam.gserviceaccount.com \
  --project="$PROJECT_ID" 2>/dev/null && echo "✓ Old service account exists"
```

## Step 2: Create New Resources with Terraform

Use the example directory provided in this repository:

```bash
cd cloud-init/mpc/gcp/terraform/example
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:

```hcl
project_id = "your-project-id"
```

**Note:** The example uses new default names that won't conflict:
- New service account: `preset-mpc-sa` (old was `mpc-service-account`)
- New role: `PresetMPCAdminV2` (old was `PresetMPCAdmin`)

You can also create your own Terraform configuration based on the example if you prefer.

### Initialize and Apply

```bash
terraform init
terraform plan
```

**Review the plan carefully.** It should show:
- Creating new custom role: `PresetMPCAdminV2`
- Creating new service account: `preset-mpc-sa@your-project-id.iam.gserviceaccount.com`
- Creating IAM bindings for the new resources
- (Optional) Creating/updating organization policy

**It should NOT touch your existing resources** (`PresetMPCAdmin` role or `mpc-service-account`).

If everything looks good:

```bash
terraform apply
```

Type `yes` to proceed.

## Step 3: Provide New Service Account to Preset

Get the new service account email from Terraform:

```bash
terraform output new_mpc_service_account_email
```

**Provide this new service account email to your Preset contact.**

Example output:
```
preset-mpc-sa@your-project-id.iam.gserviceaccount.com
```

## Step 4: Wait for Preset to Switch Over

After you provide the new service account email, Preset will:
1. Update their automation to use the new service account for your project
2. Test that everything works with the new setup
3. Confirm the switch is complete

**Do not delete old resources until Preset confirms the switch is complete.**

## Step 5: Clean Up Old Resources (After Confirmation)

Once Preset confirms they're using the new service account, you can clean up the old resources.

**WARNING**: Only do this AFTER Preset confirms the migration is complete!

### Using the Cleanup Script

Download and run the cleanup script:

```bash
# Download the script
curl -O https://raw.githubusercontent.com/preset-io/terraform-live-envs/master/cloud-init/mpc/gcp/shell/cleanup-old-mpc-permissions.sh
chmod +x cleanup-old-mpc-permissions.sh

# Run the script
export PROJECT_ID="your-project-id"
./cleanup-old-mpc-permissions.sh
```

Or if you have this repository cloned:

```bash
cd cloud-init/mpc/gcp/shell
export PROJECT_ID="your-project-id"
./cleanup-old-mpc-permissions.sh
```

## Verification Checklist

After migration, verify everything is working:

- [ ] New role exists: `gcloud iam roles describe PresetMPCAdminV2 --project="$PROJECT_ID"`
- [ ] New SA exists: `gcloud iam service-accounts describe preset-mpc-sa@${PROJECT_ID}.iam.gserviceaccount.com --project="$PROJECT_ID"`
- [ ] New SA email provided to Preset
- [ ] Preset confirmed they're using new SA
- [ ] Your MPC environment is working normally
- [ ] (Optional) Old resources cleaned up

## Troubleshooting

### Terraform Shows Conflicts

**Issue:** Terraform wants to modify or delete existing resources

**Solution:** Check your configuration. The module should use new resource names by default:
- `preset-mpc-sa` (not `mpc-service-account`)
- `PresetMPCAdminV2` (not `PresetMPCAdmin`)

If you accidentally used the old names, you can override them in your configuration:

```hcl
module "preset_mpc_permissions" {
  source = "..."

  mpc_service_account_id = "preset-mpc-sa-new"     # Different name
  mpc_admin_role_id      = "PresetMPCAdminV2New"   # Different name
}
```

### Permission Denied

**Issue:** Can't create resources

**Solution:** Ensure you have required permissions:
- `roles/iam.roleAdmin` - To create custom roles
- `roles/iam.serviceAccountAdmin` - To create service accounts
- `roles/resourcemanager.projectIamAdmin` - To manage IAM bindings

### Organization Policy Errors

**Issue:** Error about `constraints/iam.allowedPolicyMemberDomains`

**Solution:** Either:
1. Set `manage_org_policy = true` and have Org Admin permissions, OR
2. Set `manage_org_policy = false` and manually configure org policy (see main README)

### Old Resources Accidentally Deleted

**Issue:** Accidentally deleted old resources before Preset switched over

**Solution:**
1. The Terraform state has the new resources, which are identical
2. Contact Preset to confirm they're using the new service account
3. If needed, Preset can help re-create old resources temporarily

### Verifying New Resources Were Created

If you want to verify the new resources were created successfully:

```bash
# Check the new service account exists
gcloud iam service-accounts describe \
  preset-mpc-sa@${PROJECT_ID}.iam.gserviceaccount.com \
  --project="$PROJECT_ID"

# Check the new role exists
gcloud iam roles describe PresetMPCAdminV2 --project="$PROJECT_ID"
```

## Rollback Plan

If something goes wrong during migration:

1. **Old resources still exist** - They're untouched
2. **Preset can switch back** to using the old service account
3. **Delete new resources** with `terraform destroy` if needed
4. **No downtime** - Your MPC environment keeps running on old resources

## Benefits of This Approach

### For Customers
- **No complex commands** - Just `terraform apply`
- **Zero risk** - Old setup untouched until confirmed working
- **Easy to understand** - Create new, test, switch, cleanup
- **No Terraform expertise needed** - Basic knowledge is enough

### For Preset
- **Easier support** - No troubleshooting import failures
- **Gradual rollout** - Migrate customers in batches
- **Clear cutover** - Simply update which SA to use
- **One-time change** - Update automation once per customer

## Next Steps

After successful migration:

1. **Commit Terraform configuration** to version control
2. **Set up remote state** (e.g., GCS backend) for team collaboration
3. **Document the new SA** in your internal docs
4. **Use Terraform** for all future MPC permission changes

## Getting Help

If you encounter issues during migration:

1. Check this troubleshooting guide
2. Verify with the verification checklist above
3. Contact your Preset support representative with:
   - Your project ID
   - Error messages from `terraform apply`
   - Output of the verification commands
   - Which step you're stuck on
