# MPC Permissions Setup Example (Azure)

This example demonstrates how to use the MPC permissions module to set up Azure Lighthouse delegation for Preset service principal access.

## Prerequisites

1. **Service Principal Requirements (Preset side):**
   - Service principal must exist in Preset's (managing) tenant
   - App registration must be **multi-tenant** ("Accounts in any organizational directory")
   - Use the **Enterprise Application Object ID** (not App Registration Object ID) for `principal_id`

2. **Azure CLI Installed:**
   - Version >= 2.0

3. **Azure Authentication:**
   ```bash
   az login --tenant <your-tenant-id>
   az account set --subscription <your-subscription-id>
   ```

4. **Terraform Installed:**
   - Version >= 1.6.3

5. **Required Permissions:**
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
managing_tenant_id = "c8309e53-d775-46bd-947f-7fe0d1fb7b7a"  # Preset's tenant ID
principal_id       = "5477b89b-9b58-45e6-91df-6beaadd37c2c"  # Preset service principal Object ID
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
- Lighthouse definition (specifies what access is delegated to Preset's service principal)
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
Preset MPC Management Access  Grants Contributor access to Preset MPC tenant   Preset            Succeeded
```

## Outputs

After successful apply, Terraform will output:

```
Outputs:

lighthouse_definition_id = "/subscriptions/.../providers/Microsoft.ManagedServices/registrationDefinitions/..."
lighthouse_assignment_id = "/subscriptions/.../providers/Microsoft.ManagedServices/registrationAssignments/..."
subscription_id = "your-subscription-id"
managing_tenant_id = "c8309e53-d775-46bd-947f-7fe0d1fb7b7a"
role = "Contributor"
```

## Roles

The module delegates two roles via Azure Lighthouse:

1. **Primary role** (configurable): controls resource management access
2. **User Access Administrator**: always included, allows the service principal to create role assignments in the subscription

| Role                       | Description                                      |
|----------------------------|--------------------------------------------------|
| Owner                      | Full access + manage permissions                 |
| Contributor                | Full access, can't manage permissions (default)  |
| Reader                     | View only                                        |
| User Access Administrator  | Manage role assignments (always granted)         |

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

## Cleanup

To remove the Lighthouse delegation:

```bash
terraform destroy
```

## Support

For issues or questions:
1. Review the module documentation at `../modules/mpc-permissions/README.md`
2. Contact your Preset support representative
