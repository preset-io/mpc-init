#!/bin/bash
set -e

# MPC Permissions Cleanup Script
# This script removes old Deployment Manager resources after migration to Terraform
# WARNING: Only run this AFTER Preset confirms they are using the new service account

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Old resource names (from Deployment Manager template)
OLD_MPC_SA_ID="mpc-service-account"
OLD_ROLE_ID="PresetMPCAdmin"
OLD_DEPLOYMENT_NAME="preset-mpc-org"
# Check if PRESET_SERVICE_ACCOUNT is set
if [[ -z "${PRESET_SERVICE_ACCOUNT:-}" ]]; then
    error 'PRESET_SERVICE_ACCOUNT environment variable is not set. Please run: export PRESET_SERVICE_ACCOUNT="<PRESET_SERVICE_ACCOUNT>"'
fi

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

OLD_MPC_SA_EMAIL="${OLD_MPC_SA_ID}@${PROJECT_ID}.iam.gserviceaccount.com"

warning "=========================================="
warning "MPC OLD RESOURCES CLEANUP"
warning "=========================================="
echo ""
warning "This script will DELETE the following old resources:"
echo ""
echo "  Project: $PROJECT_ID"
echo "  Service Account: $OLD_MPC_SA_EMAIL"
echo "  Custom Role: $OLD_ROLE_ID"
echo "  Deployment Manager: $OLD_DEPLOYMENT_NAME"
echo ""
warning "ONLY proceed if:"
warning "  1. You have created NEW resources with Terraform"
warning "  2. You have provided the NEW service account to Preset"
warning "  3. Preset has CONFIRMED they are using the NEW service account"
echo ""

# Ask for user confirmation
read -p "Are you SURE you want to delete these old resources? (yes/NO): " -r
echo ""
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "Cleanup cancelled by user."
    exit 0
fi
echo ""

# Remove IAM bindings first
info "Step 1/4: Removing IAM policy bindings..."

info "  Removing Preset SA binding from project..."
gcloud projects remove-iam-policy-binding "$PROJECT_ID" \
    --member="serviceAccount:${PRESET_SERVICE_ACCOUNT}" \
    --role="projects/${PROJECT_ID}/roles/${OLD_ROLE_ID}" \
    --quiet 2>/dev/null || warning "  Binding may not exist or already removed"

info "  Removing MPC SA binding from project..."
gcloud projects remove-iam-policy-binding "$PROJECT_ID" \
    --member="serviceAccount:${OLD_MPC_SA_EMAIL}" \
    --role="projects/${PROJECT_ID}/roles/${OLD_ROLE_ID}" \
    --quiet 2>/dev/null || warning "  Binding may not exist or already removed"

info "  Removing token creator binding..."
gcloud iam service-accounts remove-iam-policy-binding "$OLD_MPC_SA_EMAIL" \
    --member="serviceAccount:${PRESET_SERVICE_ACCOUNT}" \
    --role="roles/iam.serviceAccountTokenCreator" \
    --quiet 2>/dev/null || warning "  Binding may not exist or already removed"

# Delete service account
info "Step 2/4: Deleting old service account..."
if gcloud iam service-accounts describe "$OLD_MPC_SA_EMAIL" --project="$PROJECT_ID" &>/dev/null; then
    gcloud iam service-accounts delete "$OLD_MPC_SA_EMAIL" \
        --project="$PROJECT_ID" \
        --quiet
    info "  Service account deleted: $OLD_MPC_SA_EMAIL"
else
    warning "  Service account not found or already deleted: $OLD_MPC_SA_EMAIL"
fi

# Delete custom role
info "Step 3/4: Deleting old custom role..."
if gcloud iam roles describe "$OLD_ROLE_ID" --project="$PROJECT_ID" &>/dev/null; then
    gcloud iam roles delete "$OLD_ROLE_ID" \
        --project="$PROJECT_ID" \
        --quiet
    info "  Custom role deleted: $OLD_ROLE_ID"
else
    warning "  Custom role not found or already deleted: $OLD_ROLE_ID"
fi

# Delete Deployment Manager deployment
info "Step 4/4: Deleting Deployment Manager deployment..."
if gcloud deployment-manager deployments describe "$OLD_DEPLOYMENT_NAME" --project="$PROJECT_ID" &>/dev/null; then
    gcloud deployment-manager deployments delete "$OLD_DEPLOYMENT_NAME" \
        --project="$PROJECT_ID" \
        --quiet
    info "  Deployment Manager deployment deleted: $OLD_DEPLOYMENT_NAME"
else
    warning "  Deployment Manager deployment not found or already deleted: $OLD_DEPLOYMENT_NAME"
fi

info ""
info "=========================================="
info "Cleanup Complete!"
info "=========================================="
info ""
info "Old MPC resources have been removed from project: $PROJECT_ID"
info ""
info "Your new Terraform-managed resources remain active:"
info "  - Service Account: preset-mpc-sa@${PROJECT_ID}.iam.gserviceaccount.com"
info "  - Custom Role: PresetMPCAdminV2"
info ""