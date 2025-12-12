# MPC Permissions Terraform Module (Azure)

Terraform module for setting up Azure Lighthouse delegation to allow a managing tenant to access your subscription.

## Overview

This module creates:
1. A Lighthouse definition that specifies what access is being delegated
2. A Lighthouse assignment that activates the delegation on your subscription

## Prerequisites

1. **Login to Azure (as the subscription owner):**

```bash
az login --tenant <your-tenant>
az account set --subscription <your-subscription-id>
```

## Usage

### Basic Example

```hcl
module "preset_mpc_permissions" {
  source = "github.com/preset-io/mpc-init//azure/terraform?ref=2.0.0"

  managing_tenant_id = "<PROVIDED BY Preset>"
  principal_id       = "<PROVIDED BY Preset>"
}
```

### With Custom Role

```hcl
module "preset_mpc_permissions" {
  source = "github.com/preset-io/mpc-init//azure/terraform?ref=2.0.0"

  managing_tenant_id = "<PROVIDED BY Preset>"
  principal_id       = "<PROVIDED BY Preset>"
  role               = "Owner"  # Owner, Contributor, or Reader
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| managing_tenant_id | Tenant ID of the managing tenant (the one receiving access) | string | - | yes |
| principal_id | Object ID of the user/group to grant access | string | - | yes |
| principal_name | Display name for the principal | string | "Presetmpc Admin" | no |
| offer_name | Name of the Lighthouse offer | string | "Presetmpc Management Access" | no |
| offer_description | Description of the Lighthouse offer | string | "Grants Contributor access to Presetmpc tenant" | no |
| role | Role to assign: Owner, Contributor, or Reader | string | "Contributor" | no |

## Outputs

| Name | Description |
|------|-------------|
| lighthouse_definition_id | The ID of the Lighthouse definition |
| lighthouse_assignment_id | The ID of the Lighthouse assignment |
| subscription_id | The subscription ID where Lighthouse is configured |
| managing_tenant_id | The tenant ID that now has access |

## Roles

| Role        | Description                              |
|-------------|------------------------------------------|
| Owner       | Full access + manage permissions         |
| Contributor | Full access, can't manage permissions    |
| Reader      | View only                                |

## Verify

After deployment, verify the Lighthouse delegation was created successfully:

```bash
# List Lighthouse definitions with details
az managedservices definition list --query "[].{Name:properties.registrationDefinitionName, Description:properties.description, ManagingTenant:properties.managedByTenantName, State:properties.provisioningState}" --output table

# List Lighthouse assignments
az managedservices assignment list --query "[].{Name:name, State:properties.provisioningState}" --output table
```

Expected output:
```
Name                          Description                                      ManagingTenant    State
----------------------------  -----------------------------------------------  ----------------  ---------
Preset MPC Management Access  Grants Contributor access to Preset MPC tenant   Preset            Succeeded
```

## Cleanup

To remove the Lighthouse delegation:

```bash
terraform destroy
```

## From the Managing Tenant

After deployment, the managing tenant can access the subscription:

```bash
az account list --output table
az resource list --subscription <delegated-subscription-id>
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.6.3 |
| azurerm | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | >= 4.0 |
