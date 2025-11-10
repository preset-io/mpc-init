#!/bin/bash
set -e

# MPC Permissions Setup Script
# This script is idempotent and can be run multiple times safely
# It replaces the legacy Deployment Manager template

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default values (use new names to avoid conflicts with old Deployment Manager resources)
MPC_SERVICE_ACCOUNT_ID="${MPC_SERVICE_ACCOUNT_ID:-preset-mpc-sa}"
MPC_ADMIN_ROLE_ID="${MPC_ADMIN_ROLE_ID:-PresetMPCAdminV2}"

# Helper functions
error() {
    echo -e "${RED}ERROR: $1${NC}" >&2
    exit 1
}

info() {
    echo -e "${GREEN}INFO: $1${NC}"
}

warning() {
    echo -e "${YELLOW}WARNING: $1${NC}"
}

# Check if gcloud CLI is installed
if ! command -v gcloud &> /dev/null; then
    error "gcloud CLI is not installed or not in PATH. Please install it from: https://cloud.google.com/sdk/docs/install"
fi

# Check if PROJECT_ID is set
if [[ -z "${PROJECT_ID:-}" ]]; then
    error 'PROJECT_ID environment variable is not set. Please run: export PROJECT_ID="<project-id>"'
fi

# Check if PRESET_SERVICE_ACCOUNT is set
if [[ -z "${PRESET_SERVICE_ACCOUNT:-}" ]]; then
    error 'PRESET_SERVICE_ACCOUNT environment variable is not set. Please run: export PRESET_SERVICE_ACCOUNT="<PRESET_SERVICE_ACCOUNT>"'
fi


info "Setting up MPC permissions for project: $PROJECT_ID"
info "MPC Service Account ID: $MPC_SERVICE_ACCOUNT_ID"
info "MPC Admin Role ID: $MPC_ADMIN_ROLE_ID"
info "Preset Service Account: $PRESET_SERVICE_ACCOUNT"
echo ""

# Ask for user confirmation
read -p "Do you want to continue with this configuration? (y/N): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Setup cancelled by user."
    exit 0
fi
echo ""

# Verify required APIs are enabled
info "Checking required APIs..."
REQUIRED_APIS=(
    "iam.googleapis.com"
    "cloudresourcemanager.googleapis.com"
    "serviceusage.googleapis.com"
)

for api in "${REQUIRED_APIS[@]}"; do
    if gcloud services list --enabled --project="$PROJECT_ID" --filter="name:$api" --format="value(name)" | grep -q "$api"; then
        info "API $api is already enabled"
    else
        warning "API $api is not enabled. Enabling..."
        gcloud services enable "$api" --project="$PROJECT_ID"
    fi
done

# Define all permissions
PERMISSIONS=(
    # CloudSQL permissions
    "cloudsql.databases.create"
    "cloudsql.databases.delete"
    "cloudsql.databases.get"
    "cloudsql.instances.create"
    "cloudsql.instances.delete"
    "cloudsql.instances.list"
    "cloudsql.instances.get"
    "cloudsql.instances.update"
    "cloudsql.users.list"
    "cloudsql.users.get"
    # Compute Engine permissions
    "compute.addresses.create"
    "compute.addresses.delete"
    "compute.addresses.get"
    "compute.addresses.setLabels"
    "compute.instances.create"
    "compute.instances.delete"
    "compute.instances.start"
    "compute.instances.stop"
    "compute.instances.setMetadata"
    "compute.instances.setTags"
    "compute.instances.update"
    "compute.disks.create"
    "compute.disks.delete"
    "compute.disks.update"
    # Storage permissions
    "storage.buckets.create"
    "storage.buckets.delete"
    "storage.buckets.get"
    "storage.buckets.list"
    "storage.objects.create"
    "storage.objects.delete"
    # VPC Network permissions
    "compute.networks.create"
    "compute.networks.delete"
    "compute.networks.get"
    "compute.networks.list"
    "compute.networks.updatePolicy"
    "compute.networks.update"
    "compute.networks.use"
    # Subnet permissions
    "compute.subnetworks.create"
    "compute.subnetworks.delete"
    "compute.subnetworks.expandIpCidrRange"
    "compute.subnetworks.get"
    "compute.subnetworks.list"
    "compute.subnetworks.update"
    # Firewall permissions
    "compute.firewalls.create"
    "compute.firewalls.delete"
    "compute.firewalls.get"
    "compute.firewalls.list"
    "compute.firewalls.update"
    "compute.globalOperations.get"
    "compute.globalOperations.list"
    "compute.globalAddresses.createInternal"
    "compute.globalAddresses.deleteInternal"
    "compute.globalAddresses.get"
    "compute.globalAddresses.create"
    "compute.globalAddresses.setLabels"
    # Routes permissions
    "compute.routes.create"
    "compute.routes.delete"
    "compute.routes.get"
    "compute.routes.list"
    # NAT Gateway permissions
    "compute.routers.create"
    "compute.routers.delete"
    "compute.routers.get"
    "compute.routers.list"
    "compute.routers.update"
    "compute.routers.use"
    # Additional compute permissions
    "compute.regionOperations.get"
    "compute.regionOperations.list"
    "compute.zoneOperations.get"
    "compute.zoneOperations.list"
    "compute.zones.list"
    "compute.securityPolicies.create"
    "compute.securityPolicies.delete"
    "compute.securityPolicies.get"
    "compute.securityPolicies.getIamPolicy"
    "compute.securityPolicies.list"
    "compute.securityPolicies.setIamPolicy"
    "compute.securityPolicies.update"
    "compute.securityPolicies.use"
    "compute.instanceGroupManagers.get"
    "compute.instanceGroupManagers.list"
    # Kubernetes Engine permissions
    "container.clusters.create"
    "container.clusters.delete"
    "container.clusters.get"
    "container.clusters.list"
    "container.clusters.update"
    "container.namespaces.create"
    "container.namespaces.delete"
    "container.namespaces.get"
    "container.operations.get"
    "container.operations.list"
    "container.secrets.create"
    "container.secrets.delete"
    "container.secrets.get"
    "container.secrets.update"
    # DNS permissions
    "dns.managedZones.get"
    "dns.managedZones.list"
    "dns.managedZones.create"
    "dns.managedZones.delete"
    "dns.managedZones.update"
    "dns.changes.create"
    "dns.changes.get"
    "dns.changes.list"
    "dns.resourceRecordSets.create"
    "dns.resourceRecordSets.update"
    "dns.resourceRecordSets.delete"
    "dns.resourceRecordSets.get"
    "dns.resourceRecordSets.list"
    # Service networking permissions
    "servicenetworking.services.addPeering"
    # IAM permissions
    "iam.serviceAccounts.actAs"
    "iam.serviceAccounts.create"
    "iam.serviceAccounts.delete"
    "iam.serviceAccounts.disable"
    "iam.serviceAccounts.enable"
    "iam.serviceAccounts.get"
    "iam.serviceAccounts.getIamPolicy"
    "iam.serviceAccounts.list"
    "iam.serviceAccounts.setIamPolicy"
    "iam.serviceAccounts.update"
    "iam.serviceAccountKeys.create"
    "iam.serviceAccountKeys.delete"
    "iam.serviceAccountKeys.list"
    "iam.serviceAccountKeys.get"
    "iam.policybindings.get"
    "iam.policybindings.list"
    # Workload Identity permissions
    "iam.workloadIdentityPools.create"
    "iam.workloadIdentityPools.delete"
    "iam.workloadIdentityPools.get"
    "iam.workloadIdentityPools.list"
    "iam.workloadIdentityPools.update"
    "iam.workloadIdentityPoolProviders.create"
    "iam.workloadIdentityPoolProviders.delete"
    "iam.workloadIdentityPoolProviders.get"
    "iam.workloadIdentityPoolProviders.list"
    "iam.workloadIdentityPoolProviders.update"
    # Redis permissions
    "redis.instances.get"
    "redis.instances.list"
    "redis.instances.create"
    "redis.instances.update"
    "redis.instances.delete"
    "redis.operations.get"
    "redis.operations.list"
    # Resource Manager permissions
    "resourcemanager.projects.createPolicyBinding"
    "resourcemanager.projects.deletePolicyBinding"
    "resourcemanager.projects.get"
    "resourcemanager.projects.getIamPolicy"
    "resourcemanager.projects.searchPolicyBindings"
    "resourcemanager.projects.setIamPolicy"
    "resourcemanager.projects.updatePolicyBinding"
    # Service Usage permissions
    "serviceusage.services.enable"
    "serviceusage.services.get"
    "serviceusage.services.list"
    # Service Networking permissions
    "servicenetworking.services.get"
    "servicenetworking.services.deleteConnection"
)

# Create or update custom role
info "Creating or updating custom IAM role: $MPC_ADMIN_ROLE_ID"

# Create temporary YAML file for role definition
TMP_ROLE_FILE=$(mktemp /tmp/mpc-role-XXXXXX.yaml)
cat > "$TMP_ROLE_FILE" <<EOF
title: "Preset Admin Access Role"
description: "This role provides Preset access to your Project."
stage: GA
includedPermissions:
EOF

# Add all permissions to the role file
for perm in "${PERMISSIONS[@]}"; do
    echo "- $perm" >> "$TMP_ROLE_FILE"
done

# Check if role exists
if gcloud iam roles describe "$MPC_ADMIN_ROLE_ID" --project="$PROJECT_ID" &>/dev/null; then
    info "Role $MPC_ADMIN_ROLE_ID already exists. Updating..."
    gcloud iam roles update "$MPC_ADMIN_ROLE_ID" \
        --project="$PROJECT_ID" \
        --file="$TMP_ROLE_FILE" \
        --quiet
else
    info "Creating new role: $MPC_ADMIN_ROLE_ID"
    gcloud iam roles create "$MPC_ADMIN_ROLE_ID" \
        --project="$PROJECT_ID" \
        --file="$TMP_ROLE_FILE" \
        --quiet
fi

rm "$TMP_ROLE_FILE"

# Create MPC service account
MPC_SA_EMAIL="${MPC_SERVICE_ACCOUNT_ID}@${PROJECT_ID}.iam.gserviceaccount.com"

info "Creating MPC service account: $MPC_SERVICE_ACCOUNT_ID"

if gcloud iam service-accounts describe "$MPC_SA_EMAIL" --project="$PROJECT_ID" &>/dev/null; then
    info "Service account $MPC_SA_EMAIL already exists. Skipping creation."
else
    info "Creating new service account: $MPC_SA_EMAIL"
    gcloud iam service-accounts create "$MPC_SERVICE_ACCOUNT_ID" \
        --project="$PROJECT_ID" \
        --display-name="Preset MPC Service Account" \
        --description="Service account for Preset to manage MPC infrastructure"
fi

# Grant Token Creator role to Preset service account on MPC service account
info "Granting Token Creator role to Preset service account on MPC service account"
gcloud iam service-accounts add-iam-policy-binding "$MPC_SA_EMAIL" \
    --project="$PROJECT_ID" \
    --member="serviceAccount:$PRESET_SERVICE_ACCOUNT" \
    --role="roles/iam.serviceAccountTokenCreator" \
    --quiet

# Grant custom role to Preset service account at project level
info "Granting custom role to Preset service account"
gcloud projects add-iam-policy-binding "$PROJECT_ID" \
    --member="serviceAccount:$PRESET_SERVICE_ACCOUNT" \
    --role="projects/$PROJECT_ID/roles/$MPC_ADMIN_ROLE_ID" \
    --quiet

# Grant custom role to MPC service account at project level
info "Granting custom role to MPC service account"
gcloud projects add-iam-policy-binding "$PROJECT_ID" \
    --member="serviceAccount:$MPC_SA_EMAIL" \
    --role="projects/$PROJECT_ID/roles/$MPC_ADMIN_ROLE_ID" \
    --quiet

info ""
info "======================================"
info "MPC Permissions Setup Complete!"
info "======================================"
info ""
info "Summary:"
info "  Custom Role ID: $MPC_ADMIN_ROLE_ID"
info "  Custom Role: projects/$PROJECT_ID/roles/$MPC_ADMIN_ROLE_ID"
info "  MPC Service Account: $MPC_SA_EMAIL"
info "  Preset Service Account: $PRESET_SERVICE_ACCOUNT"
info ""
info "Next steps:"
info "  1. Verify the setup with: gcloud iam roles describe $MPC_ADMIN_ROLE_ID --project=$PROJECT_ID"
info "  2. Verify service account: gcloud iam service-accounts describe $MPC_SA_EMAIL --project=$PROJECT_ID"
info ""