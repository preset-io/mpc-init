# MPC Permissions Terraform Module (Azure)

Terraform module for setting up Azure Lighthouse delegation with a custom MPC admin role to allow Preset to manage your subscription.

## Overview

This module creates:
1. A custom IAM role (`Preset MPC Admin`) with specific permissions for MPC infrastructure management
2. A Lighthouse definition that delegates the custom role to Preset's tenant
3. A Lighthouse assignment that activates the delegation on your subscription

## Permissions

The custom role includes permissions for:

| Resource | Description |
|----------|-------------|
| **Azure SQL** | Servers, databases, firewall rules |
| **Redis Cache** | Azure Cache for Redis instances |
| **Storage** | Storage accounts, blob/file services |
| **DNS** | Public and private DNS zones, records |
| **AKS** | Kubernetes clusters and services |
| **Key Vault** | Vaults, certificates, secrets, keys |
| **Networking** | VNets, subnets, peerings |
| **VPN** | Virtual network gateways, connections |
| **NAT Gateway** | NAT gateways, public IPs |
| **Security Groups** | Network security groups |
| **Route Tables** | Custom routing |
| **Load Balancers** | Load balancers, application gateways |
| **Compute** | VMs, scale sets, disks (for AKS) |
| **Container Registry** | ACR for container images |
| **Private Endpoints** | Private link services |
| **Managed Identities** | User-assigned identities |

**Safety restrictions:** The role cannot modify authorization/role assignments or elevate access.

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
  source = "github.com/preset-io/mpc-init//azure/terraform/modules/mpc-permissions?ref=master"

  managing_tenant_id = "<PROVIDED BY Preset>"
  principal_id       = "<PROVIDED BY Preset>"
}
```

### With Custom Names

```hcl
module "preset_mpc_permissions" {
  source = "github.com/preset-io/mpc-init//azure/terraform/modules/mpc-permissions?ref=master"

  managing_tenant_id = "<PROVIDED BY Preset>"
  principal_id       = "<PROVIDED BY Preset>"
  custom_role_name   = "My Custom MPC Role"
  offer_name         = "My MPC Management Access"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| managing_tenant_id | Tenant ID of the managing tenant (provided by Preset) | string | - | yes |
| principal_id | Object ID of the user/group to grant access (provided by Preset) | string | - | yes |
| principal_name | Display name for the principal | string | "Preset MPC Admin" | no |
| offer_name | Name of the Lighthouse offer | string | "Preset MPC Management Access" | no |
| offer_description | Description of the Lighthouse offer | string | "Grants custom MPC admin access to Preset tenant" | no |
| custom_role_name | Name for the custom MPC admin role | string | "Preset MPC Admin" | no |

## Outputs

| Name | Description |
|------|-------------|
| lighthouse_definition_id | The ID of the Lighthouse definition |
| lighthouse_assignment_id | The ID of the Lighthouse assignment |
| subscription_id | The subscription ID where Lighthouse is configured |
| managing_tenant_id | The tenant ID that now has access |
| custom_role_id | The ID of the custom MPC admin role |
| custom_role_name | The name of the custom MPC admin role |

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
Preset MPC Management Access  Grants custom MPC admin access to Preset tenant  Preset            Succeeded
```

To verify the custom role was created:

```bash
az role definition list --name "Preset MPC Admin" --output table
```

## Cleanup

To remove the Lighthouse delegation and custom role:

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
