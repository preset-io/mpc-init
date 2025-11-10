# MPC Permissions Terraform Module

Terraform module for setting up MPC (Managed Private Cloud) permissions in customer GCP projects.

## Overview

This module creates:
1. A custom IAM role (`PresetMPCAdminV2`) with all necessary permissions for Preset to manage MPC infrastructure
2. An MPC service account that Preset uses to manage resources
3. IAM bindings that grant the custom role to both Preset's service account and the MPC service account
4. Token creator permissions allowing Preset to impersonate the MPC service account
5. (Optional) Organization policy to allow Preset and Datadog service accounts

## Prerequisites

Before using this module, ensure the following:

1. **Enable Required APIs:**
   ```bash
   PROJECT_ID=<YOUR_PROJECT_ID>
   gcloud services enable iam.googleapis.com \
     cloudresourcemanager.googleapis.com \
     serviceusage.googleapis.com \
     --project="$PROJECT_ID"
   ```

2. **Set Organization Policy (Optional with Terraform):**

   **Option A: Manage with Terraform (Recommended)**

   Set `manage_org_policy = true` when calling this module. This will automatically configure the organization policy to allow Preset and Datadog service accounts. Requires Organization Admin permissions.

   **Option B: Manual Setup**

   If you don't have Organization Admin permissions or prefer manual setup, add the following organizations to your project's Organization Policy:
   - `C0147pk0i` - Datadog
   - `C01i2thyr` - Preset.io

   ```bash
   # Create a policy file (project-org-policy.yaml):
   constraint: constraints/iam.allowedPolicyMemberDomains
   listPolicy:
     allowedValues:
       - C0147pk0i  # Datadog
       - C01i2thyr  # Preset
     inheritFromParent: true

   # Apply the policy (requires Org Admin access):
   gcloud resource-manager org-policies set-policy \
     --project $PROJECT_ID project-org-policy.yaml
   ```

## Usage

### Basic Example

```hcl
module "preset_mpc_permissions" {
  source = "github.com/preset-io/mpc-init//gcp/terraform/modules/mpc-permissions?ref=1.0.0"

  project_id              = "customer-project-id"
  preset_service_account  = "<PROVIDED BY Preset>"
}
```

### With Organization Policy Management

```hcl
module "preset_mpc_permissions" {
  source = "github.com/preset-io/mpc-init//gcp/terraform/modules/mpc-permissions?ref=1.0.0"

  project_id              = "customer-project-id"
  preset_service_account  = "<PROVIDED BY Preset>"
  # Enable organization policy management (requires Org Admin permissions)
  manage_org_policy       = true
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| project_id | The GCP project ID where MPC resources will be managed | string | - | yes |
| preset_service_account | The Preset service account email | string | - | yes |
| mpc_service_account_id | The ID for the MPC service account | string | "preset-mpc-sa" | no |
| mpc_admin_role_id | The ID for the MPC admin custom role | string | "PresetMPCAdminV2" | no |
| manage_org_policy | Whether to manage the organization policy for allowed IAM domains (requires Org Admin permissions) | bool | false | no |
| additional_allowed_domains | Additional organization customer IDs to allow in the IAM policy member domains | list(string) | [] | no |

## Outputs

| Name | Description |
|------|-------------|
| custom_role_id | The ID of the custom IAM role |
| custom_role_name | The name of the custom IAM role |
| mpc_service_account_email | The email of the MPC service account |
| mpc_service_account_id | The ID of the MPC service account |
| mpc_service_account_unique_id | The unique ID of the MPC service account |
| org_policy_managed | Whether the organization policy is managed by this module |

## Permissions

The custom role includes permissions for:
- **CloudSQL**: Database and instance management
- **Compute Engine**: VMs, disks, addresses, networking
- **VPC**: Networks, subnets, firewalls, routes, NAT gateways
- **GKE**: Kubernetes cluster and workload management
- **Cloud DNS**: Managed zones and DNS records
- **Cloud Storage**: Bucket and object management
- **IAM**: Service account and workload identity management
- **Redis**: Memorystore instance management
- **Service Networking**: VPC peering for private services

## Migration from Deployment Manager

If you're migrating from the legacy Deployment Manager template, see the detailed migration guide: [MIGRATION.md](../../../../MIGRATION.md)

This module uses **side-by-side migration** (no complex import commands needed!):
- Creates NEW resources with different default names
- Old resources stay untouched during migration
- Zero risk, easy rollback

**Default names avoid conflicts with old Deployment Manager resources:**
- New service account: `preset-mpc-sa` (old was `mpc-service-account`)
- New role: `PresetMPCAdminV2` (old was `PresetMPCAdmin`)

**Quick summary:**
1. Run `terraform apply` to create new resources alongside old ones
2. Provide new service account email to Preset
3. Preset switches their automation to use new service account
4. Optionally clean up old resources after confirmation

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.6.3 |
| google | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| google | >= 5.0 |