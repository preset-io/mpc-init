#!/bin/bash

# Lighthouse Setup Script
# Run this in the tenant that OWNS the subscription (the one granting access)
#
# This script is IDEMPOTENT - safe to run multiple times. It generates a
# deterministic UUID based on subscription + tenant + offer name, so re-running
# will update the existing Lighthouse definition rather than creating duplicates.
#
# Prerequisites:
# - The service principal must exist in the managing tenant (Preset)
# - The app registration must be multi-tenant ("Accounts in any organizational directory")
# - Use the Enterprise Application Object ID (not App Registration Object ID)

set -e

# Configuration - modify these values
MANAGING_TENANT_ID="c8309e53-d775-46bd-947f-7fe0d1fb7b7a"  # Preset tenant (managing tenant)
PRINCIPAL_ID=""  # Enterprise Application Object ID (NOT App Registration Object ID) - provided by Preset
PRINCIPAL_NAME="Preset MPC Service Principal"
OFFER_NAME="Preset MPC Management Access"
OFFER_DESCRIPTION="Grants Contributor access to Preset MPC tenant"
LOCATION="westus2"

# Role Definition IDs
# Owner:       8e3af657-a8ff-443c-a75c-2fe8c4bcb635
# Contributor: b24988ac-6180-42a0-ab88-20f7382dd24c
# Reader:      acdd72a7-3385-48ef-bd42-f606fba81ae7
ROLE_ID="b24988ac-6180-42a0-ab88-20f7382dd24c"  # Contributor

# Validate required configuration
if [[ -z "$PRINCIPAL_ID" ]]; then
  echo "Error: PRINCIPAL_ID is required. Get the Enterprise Application Object ID from Preset."
  echo "Note: This is different from the App Registration Object ID."
  exit 1
fi

# Get current subscription ID
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
if [[ -z "$SUBSCRIPTION_ID" ]]; then
  echo "Error: Could not get subscription ID. Make sure you're logged in with 'az login'."
  exit 1
fi
echo "Subscription ID: $SUBSCRIPTION_ID"

# Generate deterministic UUID based on subscription + managing tenant + offer name
# This makes the script idempotent - same inputs always produce same UUID
HASH_INPUT="${SUBSCRIPTION_ID}${MANAGING_TENANT_ID}${OFFER_NAME}"
if command -v md5sum &> /dev/null; then
  HASH=$(echo -n "$HASH_INPUT" | md5sum | cut -d' ' -f1)
elif command -v md5 &> /dev/null; then
  HASH=$(echo -n "$HASH_INPUT" | md5)
else
  echo "Error: md5sum or md5 command not found"
  exit 1
fi
UUID=$(echo "$HASH" | sed 's/^\(........\)\(....\)\(....\)\(....\)\(............\).*/\1-\2-\3-\4-\5/')
echo "Deterministic UUID: $UUID (based on subscription + tenant + offer name)"

# Create template
cat > lighthouse.json << EOF
{
  "\$schema": "https://schema.management.azure.com/schemas/2019-08-01/subscriptionDeploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {},
  "resources": [
    {
      "type": "Microsoft.ManagedServices/registrationDefinitions",
      "apiVersion": "2022-10-01",
      "name": "$UUID",
      "properties": {
        "registrationDefinitionName": "$OFFER_NAME",
        "description": "$OFFER_DESCRIPTION",
        "managedByTenantId": "$MANAGING_TENANT_ID",
        "authorizations": [
          {
            "principalId": "$PRINCIPAL_ID",
            "roleDefinitionId": "$ROLE_ID",
            "principalIdDisplayName": "$PRINCIPAL_NAME"
          }
        ]
      }
    },
    {
      "type": "Microsoft.ManagedServices/registrationAssignments",
      "apiVersion": "2022-10-01",
      "name": "$UUID",
      "dependsOn": [
        "[resourceId('Microsoft.ManagedServices/registrationDefinitions', '$UUID')]"
      ],
      "properties": {
        "registrationDefinitionId": "[resourceId('Microsoft.ManagedServices/registrationDefinitions', '$UUID')]"
      }
    }
  ]
}
EOF

echo "Created lighthouse.json"
echo ""
echo "Template contents:"
cat lighthouse.json
echo ""
echo ""

# Confirm before deploying
read -p "Deploy now? (y/n): " CONFIRM
if [[ "$CONFIRM" == "y" || "$CONFIRM" == "Y" ]]; then
  echo "Deploying..."
  az deployment sub create --location "$LOCATION" --template-file lighthouse.json
  echo ""
  echo "========================================="
  echo "Verifying deployment..."
  echo "========================================="
  echo ""
  
  echo "1. Deployment status:"
  az deployment sub list --query "[?contains(name, '$UUID')]" --output table
  echo ""
  
  echo "2. Lighthouse definitions:"
  az managedservices definition list --output table
  echo ""
  
  echo "3. Lighthouse assignments:"
  az managedservices assignment list --output table
  echo ""
  
  echo "========================================="
  echo "Deployment complete!"
  echo "========================================="
  echo ""
  echo "The managing tenant ($MANAGING_TENANT_ID) can now access this subscription."
  echo ""
  echo "To verify from the managing tenant, run:"
  echo "  az account list --output table"
  echo ""
else
  echo "Skipped deployment. Run manually with:"
  echo "  az deployment sub create --location $LOCATION --template-file lighthouse.json"
  echo ""
  echo "Then verify with:"
  echo "  az managedservices definition list --output table"
  echo "  az managedservices assignment list --output table"
fi
