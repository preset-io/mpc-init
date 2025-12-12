# MPC Permissions Setup Example (Azure)

This example demonstrates how to use the MPC permissions module to set up Azure Lighthouse delegation with a custom MPC admin role for Preset access.

## Prerequisites

1. **Azure CLI Installed:**
   - Version >= 2.0

2. **Azure Authentication:**
   ```bash
   az login --tenant <your-tenant-id>
   az account set --subscription <your-subscription-id>
   ```

3. **Terraform Installed:**
   - Version >= 1.6.3

4. **Required Permissions:**
   - Owner or User Access Administrator on the subscription

## Usage

### 1. Copy the Example Configuration

```bash
cp terraform.tfvars.example terraform.tfvars
```

### 2. Edit terraform.tfvars

Edit the `terraform.tfvars` file with values provided by Preset:

```hcl
subscription_id    = "your-subscription-id"
managing_tenant_id = "c8309e53-d775-46bd-947f-7fe0d1fb7b7a"
principal_id       = "5477b89b-9b58-45e6-91df-6beaadd37c2c"
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
- Custom role definition (`Preset MPC Admin`) with specific MPC permissions
- Lighthouse definition (specifies what access is delegated)
- Lighthouse assignment (activates the delegation)

### 5. Apply the Configuration

```bash
terraform apply
```

Review the planned changes and type `yes` to proceed.

### 6. Verify the Deployment

After successful apply, verify the Lighthouse delegation was created successfully:

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

## Outputs

After successful apply, Terraform will output:

```
Outputs:

lighthouse_definition_id = "/subscriptions/.../providers/Microsoft.ManagedServices/registrationDefinitions/..."
lighthouse_assignment_id = "/subscriptions/.../providers/Microsoft.ManagedServices/registrationAssignments/..."
subscription_id = "your-subscription-id"
managing_tenant_id = "c8309e53-d775-46bd-947f-7fe0d1fb7b7a"
custom_role_id = "..."
custom_role_name = "Preset MPC Admin"
```

## Custom Role Permissions

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

**Safety restrictions:** The role cannot modify authorization/role assignments or elevate access.

## Troubleshooting

### Permission Denied

If you receive permission denied errors, ensure you have:
- Owner or User Access Administrator role on the subscription
- Correct tenant/subscription selected in Azure CLI

### Lighthouse Already Exists

If you see errors about existing Lighthouse definitions, you may need to remove existing delegations:

```bash
az managedservices assignment delete --assignment <assignment-id>
az managedservices definition delete --definition <definition-id>
```

### Custom Role Already Exists

If you see errors about the custom role already existing:

```bash
az role definition delete --name "Preset MPC Admin"
```

## Cleanup

To remove the Lighthouse delegation and custom role:

```bash
terraform destroy
```

## Support

For issues or questions:
1. Review the module documentation at `../modules/mpc-permissions/README.md`
2. Contact your Preset support representative
