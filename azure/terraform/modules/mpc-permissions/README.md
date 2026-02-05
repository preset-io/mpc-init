# MPC Permissions Terraform Module (Azure)

Terraform module for setting up Azure Lighthouse delegation to allow Preset to manage your subscription.

## Overview

This module creates:
1. A Lighthouse definition that delegates access to Preset's tenant
2. A Lighthouse assignment that activates the delegation on your subscription

## Roles

The module delegates two roles via Azure Lighthouse:

1. **Primary role** (configurable via `role` variable): controls resource management access
2. **User Access Administrator**: always included, allows the service principal to create role assignments (`Microsoft.Authorization/roleAssignments/write`)

| Role                       | Description                                     |
|----------------------------|-------------------------------------------------|
| Owner                      | Full access + manage permissions                |
| Contributor                | Full access, can't manage permissions (default) |
| Reader                     | View only                                       |
| User Access Administrator  | Manage role assignments (always granted)        |

## Prerequisites

1. **Service Principal Requirements (Preset side):**
   - Service principal must exist in Preset's (managing) tenant
   - App registration must be **multi-tenant** ("Accounts in any organizational directory")
   - Use the **Enterprise Application Object ID** (not App Registration Object ID) for `principal_id`

2. **Login to Azure (as the subscription owner):**

```bash
az login --tenant <your-tenant>
az account set --subscription <your-subscription-id>
```

## Usage

### Basic Example

```hcl
module "preset_mpc_permissions" {
  source = "github.com/preset-io/mpc-init//azure/terraform/modules/mpc-permissions?ref=master"

  managing_tenant_id = "<PROVIDED BY Preset>"
  principal_id       = "<PROVIDED BY Preset>"
}
```

### With Custom Role

```hcl
module "preset_mpc_permissions" {
  source = "github.com/preset-io/mpc-init//azure/terraform/modules/mpc-permissions?ref=master"

  managing_tenant_id = "<PROVIDED BY Preset>"
  principal_id       = "<PROVIDED BY Preset>"
  role               = "Owner"  # Owner, Contributor, or Reader
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| managing_tenant_id | Tenant ID of the managing tenant (provided by Preset) | string | - | yes |
| principal_id | Object ID of the service principal to grant access (provided by Preset) | string | - | yes |
| principal_name | Display name for the service principal | string | "Preset MPC Service Principal" | no |
| offer_name | Name of the Lighthouse offer | string | "Preset MPC Management Access" | no |
| offer_description | Description of the Lighthouse offer | string | "Grants Contributor access to Preset MPC tenant" | no |
| role | Built-in role to assign: Owner, Contributor, or Reader | string | "Contributor" | no |

## Outputs

| Name | Description |
|------|-------------|
| lighthouse_definition_id | The ID of the Lighthouse definition |
| lighthouse_assignment_id | The ID of the Lighthouse assignment |
| subscription_id | The subscription ID where Lighthouse is configured |
| managing_tenant_id | The tenant ID that now has access |
| role | The role assigned to the service principal |

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
